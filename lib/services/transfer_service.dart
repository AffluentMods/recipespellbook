import 'dart:convert';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database/database.dart';
import '../database/sync_journal.dart';
import '../services/auth_service.dart';
import '../services/export_import_service.dart';
import '../services/image_service.dart';
import '../services/sync_service.dart';
import '../utils/platform_utils.dart';

// ════════════════════════════════════════════════════════════════
//  TRANSFER RESULT
// ════════════════════════════════════════════════════════════════

class TransferCreateResult {
  final String code;

  /// When the server stops honouring the code, if it said.
  final DateTime? expiresAt;
  final int recipesCount;
  final int cookbooksCount;

  /// Photos that travel with the transfer, and photos on this device that
  /// had to stay behind because one transfer cannot carry them all.
  final int photosSent;
  final int photosLeftOut;

  const TransferCreateResult({
    required this.code,
    required this.expiresAt,
    required this.recipesCount,
    required this.cookbooksCount,
    this.photosSent = 0,
    this.photosLeftOut = 0,
  });
}

class TransferClaimResult {
  final Map<String, dynamic> data;
  final String? authToken;
  final String? userId;
  final String? displayName;
  final String? email;
  final String? avatarUrl;

  /// Rows this device gained or took over from the other one.
  final int importedCount;

  /// Recipes this device already had and kept as they were.
  final int recipesAlreadyHere;

  const TransferClaimResult({
    required this.data,
    this.authToken,
    this.userId,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.importedCount = 0,
    this.recipesAlreadyHere = 0,
  });
}

/// Why a transfer could not be sent or received.
enum TransferFailure {
  /// Sending needs an account, the server refuses it otherwise.
  signInNeeded,

  /// This device is signed in, but the server no longer accepts that
  /// sign-in. Trying again changes nothing until the user signs in afresh.
  signInExpired,

  /// The library does not fit into one transfer, even without its photos.
  tooLarge,

  /// The server could not be reached.
  offline,

  /// The server answered with something other than a transfer.
  server,
  codeNotFound,
  codeExpired,
  codeUsed,

  /// A cloud sync is writing to the database right now.
  syncRunning,

  /// What arrived is not a transfer this app can read.
  unreadable,

  /// The transfer arrived but could not be saved. Nothing was changed.
  notSaved,
}

/// A transfer that failed for a reason the screen can put into words.
class TransferException implements Exception {
  const TransferException(this.failure, [this.detail]);

  final TransferFailure failure;

  /// What the server or the database said, for the log.
  final String? detail;

  @override
  String toString() => 'TransferException(${failure.name}${detail == null ? '' : ': $detail'})';
}

// ════════════════════════════════════════════════════════════════
//  TRANSFER SERVICE
// ════════════════════════════════════════════════════════════════

/// Handles one-time device-to-device data transfer for free-tier users.
///
/// Flow (Send):
///   1. Collect ALL local data from Drift DB (full snapshot, not delta)
///   2. Upload to server via POST /v1/transfer/create
///   3. Server returns a 6-char code and the time it expires
///
/// Flow (Receive):
///   1. Send code to GET /v1/transfer/:code
///   2. Server returns the data bundle
///   3. Merge into local Drift DB (what is already here is not doubled)
///   4. Optionally restore auth session from bundle
class TransferService {
  TransferService._();
  static final instance = TransferService._();

  final _auth = AuthService.instance;
  AppDatabase? _db;

  /// Clearing out a download nobody came back for. A claim waits for it,
  /// so that the two never handle the kept bundle at the same time.
  Future<void> _tidying = Future.value();

  /// Called once with the app's database, when the app starts.
  void setDatabase(AppDatabase db) {
    _db = db;
    _tidying = _keptBundle(null);
  }

  // ════════════════════════════════════════════════════════════════
  //  SEND: Collect + Upload
  // ════════════════════════════════════════════════════════════════

  /// The server refuses a request body over 15 MB, so the whole library,
  /// photos included, has to stay under that. The margin is for whatever
  /// sits between this app and the server.
  static const _maxBodyBytes = 14 * 1024 * 1024;

  /// Collects all local data and uploads it to the server.
  /// Returns a [TransferCreateResult] with the transfer code.
  /// Throws a [TransferException] when it cannot be sent.
  ///
  /// [leaveOutPhotos] is asked, before anything is sent, when the library
  /// holds more photos than one transfer can carry. It is given the number
  /// that would stay behind, and when it answers no, nothing is sent and
  /// the result is null.
  Future<TransferCreateResult?> createTransfer({Future<bool> Function(int photos)? leaveOutPhotos}) async {
    if (_db == null) throw Exception('Database not initialized');

    // The server only takes a transfer from a signed-in sender. Saying so
    // here saves collecting the library just to be turned away.
    if (!_auth.isSignedIn) throw const TransferException(TransferFailure.signInNeeded);

    // Collect everything (no delta — full snapshot for transfer)
    final library = await _collectAllLocalData();

    // Display info travels in the body (NOT the JWT, auth is handled via
    // the Authorization header on the request itself). What the account
    // does not have is left out: the server takes a text or no key at all,
    // and turned away every account without a name or a picture.
    final user = _auth.currentUser;
    final body = <String, dynamic>{
      'data': library.data,
      if (user?.name case final name? when name.isNotEmpty) 'displayName': name,
      if (user?.email case final email? when email.isNotEmpty) 'email': email,
      if (user?.avatarUrl case final avatarUrl? when avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
    };

    // Photos are added last and only while they fit. Every one of them
    // used to go in, and from about 45 recipes with photos on the server
    // turned the whole transfer away with "Internal server error".
    final textBytes = utf8.encode(jsonEncode(body)).length;
    if (textBytes > _maxBodyBytes) throw const TransferException(TransferFailure.tooLarge);
    final photos = await _photosThatFit(library.photos, _maxBodyBytes - textBytes);
    // Asked now, while a backup file is still the better choice. Once the
    // code is on screen the user has a transfer that leaves photos behind,
    // and a backup restored on top of it adds every recipe a second time.
    if (photos.leftOut > 0 && leaveOutPhotos != null && !await leaveOutPhotos(photos.leftOut)) return null;
    final photosSent = await _embedPhotos(photos.fitting);
    final photosLeftOut = photos.leftOut + photos.fitting.length - photosSent;

    debugPrint('[Transfer] Uploading bundle...');

    final response = await _reach(
      () => _auth.post('/v1/transfer/create', body, timeout: const Duration(seconds: 120)),
    );

    // Signed in as far as this device knows, so the server has ended it.
    if (response.statusCode == 401) throw const TransferException(TransferFailure.signInExpired);
    if (response.statusCode == 413) throw const TransferException(TransferFailure.tooLarge);
    final result = response.statusCode == 200 ? _decodeObject(response) : null;
    final code = result?['code'];
    if (result == null || code is! String || code.isEmpty) {
      throw TransferException(TransferFailure.server, _parseError(response));
    }

    debugPrint('[Transfer] Created code=$code '
        '(${result['recipesCount']} recipes, '
        '${result['cookbooksCount']} cookbooks, '
        '$photosSent photos, $photosLeftOut left out)');

    return TransferCreateResult(
      code: code,
      expiresAt: _parseDate(result['expiresAt']),
      recipesCount: _int(result['recipesCount']) ?? 0,
      cookbooksCount: _int(result['cookbooksCount']) ?? 0,
      photosSent: photosSent,
      photosLeftOut: photosLeftOut,
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  RECEIVE: Claim + Import
  // ════════════════════════════════════════════════════════════════

  /// Claims a transfer bundle by code and imports it into the local DB.
  /// Returns a [TransferClaimResult] with import stats.
  /// Throws a [TransferException] when it cannot be received.
  Future<TransferClaimResult> claimTransfer(String code) async {
    if (_db == null) throw Exception('Database not initialized');

    // Everything that can stop the import is asked before the download:
    // the server hands a code out once, so a refusal after it would leave
    // the user with a spent code and nothing imported.
    if (SyncService.instance.isSyncing) throw const TransferException(TransferFailure.syncRunning);

    debugPrint('[Transfer] Claiming code=$code...');

    await _tidying;
    final kept = await _keptBundle(code);
    final bundle = kept ?? await _download(code);
    final data = bundle['data'];
    if (data is! Map<String, dynamic> || data['cookbooks'] is! List || data['recipes'] is! List) {
      await _forgetBundle();
      throw const TransferException(TransferFailure.unreadable);
    }
    // The server hands a code out once, so what it sent is put aside until
    // it is safely in.
    if (kept == null) await _keepBundle(code, data);

    final _ImportStats stats;
    try {
      stats = await _importData(data);
    } catch (e) {
      // The bundle stays on the device, so the same code can be tried again.
      throw TransferException(TransferFailure.notSaved, '$e');
    }
    await _forgetBundle();

    debugPrint('[Transfer] Imported ${stats.written} entities, '
        '${stats.recipesAlreadyHere} recipes were here already');

    return TransferClaimResult(
      data: data,
      authToken: _text(bundle['authToken']),
      userId: _text(bundle['userId']),
      displayName: _text(bundle['displayName']),
      email: _text(bundle['email']),
      avatarUrl: _text(bundle['avatarUrl']),
      importedCount: stats.written,
      recipesAlreadyHere: stats.recipesAlreadyHere,
    );
  }

  /// Downloads the bundle behind [code].
  Future<Map<String, dynamic>> _download(String code) async {
    // The claim endpoint doesn't require auth (receiver might not be signed in)
    final response = await _reach(
      () => _auth.get('/v1/transfer/$code', timeout: const Duration(seconds: 120)),
    );

    if (response.statusCode == 404) throw const TransferException(TransferFailure.codeNotFound);
    if (response.statusCode == 410) throw const TransferException(TransferFailure.codeExpired);
    if (response.statusCode == 409) throw const TransferException(TransferFailure.codeUsed);
    final bundle = response.statusCode == 200 ? _decodeObject(response) : null;
    if (bundle == null) throw TransferException(TransferFailure.server, _parseError(response));
    return bundle;
  }

  /// Runs a request and tells "no answer at all" apart from the answers.
  Future<http.Response> _reach(Future<http.Response> Function() request) async {
    try {
      return await request();
    } catch (e) {
      throw TransferException(TransferFailure.offline, '$e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  A DOWNLOADED BUNDLE, UNTIL IT IS IMPORTED
  // ════════════════════════════════════════════════════════════════
  //
  // The server gives a code out once. If saving the bundle then fails, or
  // the app is closed in the middle, asking again only gets "already used".
  // So the download is put aside first and a second try with the same code
  // picks it up from here instead of from the server.
  //
  // It is a whole library in one file, so it is kept in the app's own
  // folder, not in the temporary folder that desktop systems share between
  // programs, and only the library is kept: who sent it, and any sign-in
  // the server might send along, never reaches a file.

  static const _keptBundleLife = Duration(hours: 24);

  /// The folder the download is put aside in. Each of the steps below asks
  /// for it once and does all its work there.
  Future<String> _bundleFolder() async => (await getApplicationSupportDirectory()).path;

  Future<void> _keepBundle(String code, Map<String, dynamic> data) async {
    if (isWeb) return;
    try {
      final folder = await _bundleFolder();
      await _forgetBundle(folder);
      final bundle = File(p.join(folder, 'transfer_bundle.json'));
      await bundle.parent.create(recursive: true);
      await bundle.writeAsString(jsonEncode(data), flush: true);
      // Written last: the label only exists once the bundle is complete.
      await File(p.join(folder, 'transfer_bundle.txt'))
          .writeAsString('$code\n${DateTime.now().toUtc().toIso8601String()}', flush: true);
    } catch (e) {
      debugPrint('[Transfer] Could not keep the bundle for a retry: $e');
    }
  }

  /// The bundle put aside for [code], if there is one and it is recent.
  /// One that is too old, incomplete or damaged is removed, whichever code
  /// is asked for. Asked with no code, that is all this does.
  Future<Map<String, dynamic>?> _keptBundle(String? code) async {
    if (isWeb) return null;
    String? folder;
    try {
      folder = await _bundleFolder();
      final label = File(p.join(folder, 'transfer_bundle.txt'));
      final lines = await label.exists() ? (await label.readAsString()).split('\n') : const <String>[];
      final keptAt = lines.length > 1 ? DateTime.tryParse(lines[1]) : null;
      if (keptAt != null && DateTime.now().difference(keptAt) < _keptBundleLife) {
        // One kept for another code waits for that code. A mistyped code
        // must not throw away the download it was mistyped for.
        if (lines.first != code) return null;
        final kept = jsonDecode(await File(p.join(folder, 'transfer_bundle.json')).readAsString());
        if (kept is Map<String, dynamic>) return {'data': kept};
      }
    } catch (e) {
      debugPrint('[Transfer] Could not read the kept bundle: $e');
    }
    // Too old or damaged: of no use any more.
    await _forgetBundle(folder);
    return null;
  }

  /// Removes what was put aside, from [folder] when the caller has asked
  /// for it already.
  Future<void> _forgetBundle([String? folder]) async {
    if (isWeb) return;
    for (final name in const ['transfer_bundle.txt', 'transfer_bundle.json']) {
      try {
        final file = File(p.join(folder ??= await _bundleFolder(), name));
        if (await file.exists()) await file.delete();
      } catch (e) {
        debugPrint('[Transfer] Could not remove $name: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  //  DATA COLLECTION (reuses SyncService serialization patterns)
  // ════════════════════════════════════════════════════════════════

  Future<_Library> _collectAllLocalData() async {
    final db = _db!;
    final photos = <_Photo>[];

    // Cookbooks
    final cookbookMaps = <Map<String, dynamic>>[];
    for (final cookbook in await db.select(db.cookbooks).get()) {
      final map = _serializeCookbook(cookbook);
      cookbookMaps.add(map);
      _offerPhoto(photos, map, cookbook.imagePath, _Photo.cookbookCover);
    }

    // Recipes with children. The children are read once for the whole
    // library and handed out by recipe.
    final ingredients = <String, List<Ingredient>>{};
    for (final i in await (db.select(db.ingredients)..orderBy([(i) => OrderingTerm.asc(i.sortOrder)])).get()) {
      (ingredients[i.recipeId] ??= []).add(i);
    }
    final steps = <String, List<Step>>{};
    for (final s in await (db.select(db.steps)..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])).get()) {
      (steps[s.recipeId] ??= []).add(s);
    }
    final recipeTags = <String, List<RecipeTag>>{};
    for (final rt in await db.select(db.recipeTags).get()) {
      (recipeTags[rt.recipeId] ??= []).add(rt);
    }
    final recipeLinks = <String, List<RecipeLink>>{};
    for (final rl in await db.select(db.recipeLinks).get()) {
      (recipeLinks[rl.sourceRecipeId] ??= []).add(rl);
    }

    final recipeMaps = <Map<String, dynamic>>[];
    for (final recipe in await db.select(db.recipes).get()) {
      final live = recipe.deletedAt == null;
      final stepMaps = <Map<String, dynamic>>[];
      for (final step in steps[recipe.id] ?? const <Step>[]) {
        final map = _serializeStep(step);
        stepMaps.add(map);
        _offerPhoto(photos, map, step.imagePath, live ? _Photo.stepPhoto : _Photo.inTheTrash);
      }
      final map = <String, dynamic>{
        ..._serializeRecipe(recipe),
        'imageBase64': null,
        'ingredients': (ingredients[recipe.id] ?? const <Ingredient>[]).map(_serializeIngredient).toList(),
        'steps': stepMaps,
        'recipeTags': (recipeTags[recipe.id] ?? const <RecipeTag>[]).map((rt) => {'tagId': rt.tagId}).toList(),
        'sourceLinks': (recipeLinks[recipe.id] ?? const <RecipeLink>[]).map(_serializeRecipeLink).toList(),
      };
      recipeMaps.add(map);
      _offerPhoto(photos, map, recipe.imagePath, live ? _Photo.recipeCover : _Photo.inTheTrash);
    }

    // Small tables. They have no "changed" column, the journal the sync
    // keeps is the only record of which ones the user has edited.
    final categories = await db.select(db.categories).get();
    final customCategories = await db.select(db.customCategories).get();
    final customCourses = await db.select(db.customCourses).get();
    final tags = await db.select(db.tags).get();
    final shoppingCategories = await db.select(db.shoppingCategories).get();
    final editedCategories = await SyncJournal.touched(db, SyncJournal.categories);
    final editedCustomCategories = await SyncJournal.touched(db, SyncJournal.customCategories);
    final editedCustomCourses = await SyncJournal.touched(db, SyncJournal.customCourses);
    final editedTags = await SyncJournal.touched(db, SyncJournal.tags);
    final editedShoppingCategories = await SyncJournal.touched(db, SyncJournal.shoppingCategories);

    // Meal plans
    final mealPlans = await db.select(db.mealPlans).get();

    // Shopping
    final shoppingLists = await db.select(db.shoppingLists).get();
    final shoppingListItems = await db.select(db.shoppingListItems).get();

    return _Library({
      'cookbooks': cookbookMaps,
      'recipes': recipeMaps,
      'categories': [for (final c in categories) _serializeCategory(c, editedCategories[c.id])],
      'customCategories': [
        for (final c in customCategories) _serializeCustomCategory(c, editedCustomCategories[c.id]),
      ],
      'customCourses': [for (final c in customCourses) _serializeCustomCourse(c, editedCustomCourses[c.id])],
      'tags': [for (final t in tags) _serializeTag(t, editedTags[t.id])],
      'mealPlans': mealPlans.map(_serializeMealPlan).toList(),
      'shoppingLists': shoppingLists.map(_serializeShoppingList).toList(),
      'shoppingListItems': shoppingListItems.map(_serializeShoppingListItem).toList(),
      'shoppingCategories': [
        for (final c in shoppingCategories) _serializeShoppingCategory(c, editedShoppingCategories[c.id]),
      ],
    }, photos);
  }

  /// Puts a photo on the list of those to send, if it is a file on this
  /// device. One that only exists in the cloud travels as its cloud path.
  void _offerPhoto(List<_Photo> photos, Map<String, dynamic> holder, String? path, int rank) {
    if (path == null || path.isEmpty || ImageService.isServerPath(path)) return;
    photos.add(_Photo(holder, path, rank));
  }

  /// Which of the photos go along when there are [room] bytes of request
  /// body for them, and how many have to stay behind. Covers go before step
  /// photos and small files before large ones, so that as many recipes as
  /// possible keep a picture.
  Future<({List<_Photo> fitting, int leftOut})> _photosThatFit(List<_Photo> photos, int room) async {
    if (isWeb) return (fitting: const <_Photo>[], leftOut: 0);

    final onDevice = <_Photo>[];
    for (final photo in photos) {
      try {
        final file = File(photo.path);
        if (!await file.exists()) continue;
        photo.bytes = await file.length();
        onDevice.add(photo);
      } catch (_) {
        // A file that cannot even be looked at is not there to send.
      }
    }
    onDevice.sort((a, b) => a.rank != b.rank ? a.rank.compareTo(b.rank) : a.bytes.compareTo(b.bytes));

    final fitting = <_Photo>[];
    var leftOut = 0;
    for (final photo in onDevice) {
      // Base64 turns every 3 bytes into 4 characters. The rest is the key
      // and the quotes around it.
      final cost = (photo.bytes + 2) ~/ 3 * 4 + 32;
      if (cost > room) {
        leftOut++;
        continue;
      }
      room -= cost;
      fitting.add(photo);
    }
    return (fitting: fitting, leftOut: leftOut);
  }

  /// Reads [photos] into the rows they belong to and says how many of them
  /// could be read. One that cannot stays behind like those that did not fit.
  Future<int> _embedPhotos(List<_Photo> photos) async {
    var sent = 0;
    for (final photo in photos) {
      try {
        photo.holder['imageBase64'] = base64Encode(await File(photo.path).readAsBytes());
        sent++;
      } catch (e) {
        debugPrint('[Transfer] Could not read a photo to send: $e');
      }
    }
    return sent;
  }

  // ════════════════════════════════════════════════════════════════
  //  DATA IMPORT
  // ════════════════════════════════════════════════════════════════

  /// Merges the transfer data into the local database, in one transaction:
  /// either the whole library arrives or nothing changes.
  ///
  /// Nothing this device already has is thrown away or doubled. A row both
  /// devices have takes over the one here only when it says something else
  /// and is the newer of the two, or nobody has touched the one here.
  Future<_ImportStats> _importData(Map<String, dynamic> data) async {
    final db = _db!;
    final stats = _ImportStats();

    // Prepare images directory (native only)
    Directory? imagesDir;
    if (!isWeb) {
      final appDir = await getApplicationDocumentsDirectory();
      imagesDir = Directory(p.join(appDir.path, 'images', 'transferred'));
      if (!await imagesDir.exists()) await imagesDir.create(recursive: true);
    }

    await db.transaction(() async {
      // Parent entities first
      await _mergeCookbooks(db, data['cookbooks'], imagesDir, stats);
      await _mergeRows(db.categories, data['categories'], _toCategoryCompanion, stats,
          mine: await _journalled(
              SyncJournal.categories, await db.select(db.categories).get(), (c) => c.id, (c) => c.createdAt),
          seeded: _seededCategories);
      await _mergeRows(db.customCategories, data['customCategories'], _toCustomCategoryCompanion, stats,
          mine: await _journalled(SyncJournal.customCategories, await db.select(db.customCategories).get(),
              (c) => c.id, (c) => c.createdAt));
      await _mergeRows(db.customCourses, data['customCourses'], _toCustomCourseCompanion, stats,
          mine: await _journalled(
              SyncJournal.customCourses, await db.select(db.customCourses).get(), (c) => c.id, (c) => c.createdAt));
      await _mergeRows(db.tags, data['tags'], _toTagCompanion, stats,
          mine: await _journalled(SyncJournal.tags, await db.select(db.tags).get(), (t) => t.id, (t) => t.createdAt),
          seeded: _seededTags);
      await _mergeRows(db.shoppingCategories, data['shoppingCategories'], _toShoppingCategoryCompanion, stats,
          mine: await _journalled(SyncJournal.shoppingCategories, await db.select(db.shoppingCategories).get(),
              (c) => c.id, (c) => c.createdAt),
          seeded: _seededShoppingCategories);

      // Recipes with children
      final recipeIds = await _mergeRecipes(db, data['recipes'] as List, imagesDir, stats);

      // Remaining tables
      await _mergeRows(db.mealPlans, data['mealPlans'], (d) => _toMealPlanCompanion(d, recipeIds), stats, mine: {
        for (final m in await db.select(db.mealPlans).get()) m.id: (m, _Stamps(m.createdAt, m.updatedAt)),
      });
      await _mergeRows(db.shoppingLists, data['shoppingLists'], _toShoppingListCompanion, stats,
          mine: {
            for (final l in await db.select(db.shoppingLists).get()) l.id: (l, _Stamps(l.createdAt, l.updatedAt)),
          },
          seeded: _seededShoppingLists);
      await _mergeRows(
        db.shoppingListItems,
        data['shoppingListItems'],
        (d) => _toShoppingListItemCompanion(d, recipeIds),
        stats,
        mine: {
          for (final i in await db.select(db.shoppingListItems).get()) i.id: (i, _Stamps(i.createdAt, i.updatedAt)),
        },
      );
    });

    return stats;
  }

  /// Whether the row from the other device takes the place of the one this
  /// device has under the same id, given that the two say different things.
  /// Every install starts with the same cookbook, list, tags and categories,
  /// so going by the id alone let a transfer rename them all back to what
  /// the sender calls them.
  bool _takesOver(_Stamps mine, _Stamps theirs, {bool mineAsSeeded = false, bool theirsAsSeeded = false}) {
    // What a row looked like when the app made it says more than its dates
    // do. Those are thin here: older versions of the app did not date a
    // renamed list, the small tables have no date of their own at all, and
    // a row is dated by things that change nothing a user sees, such as
    // choosing the default list. The two differ, so if one of them still
    // reads the way the app made it, the other is the one somebody changed.
    if (theirsAsSeeded) return false;
    if (mineAsSeeded) return true;
    if (!mine.untouched) return !theirs.untouched && theirs.changed!.isAfter(mine.changed!);
    if (!theirs.untouched) return true;
    // Both were changed and nobody recorded when, or the app did not make
    // the row. Such a change is most likely on the device that has had the
    // row for longer, which is the old phone when moving to a new one.
    final made = theirs.made, madeHere = mine.made;
    return made != null && madeHere != null && made.isBefore(madeHere);
  }

  /// Whether a row from the other device says nothing this device's row
  /// does not say already. When a row was made and last changed is
  /// bookkeeping: a row that differs in that alone is not written again,
  /// and is not counted as something that arrived.
  bool _sameRow<D>(Insertable<D> theirs, Insertable<D> mine) {
    Object? said(Expression? column) => column is Variable ? column.value : column;
    final here = mine.toColumns(false);
    for (final column in theirs.toColumns(false).entries) {
      if (column.key == 'created_at' || column.key == 'updated_at') continue;
      final a = said(column.value), b = said(here[column.key]);
      if (a is DateTime && b is DateTime ? !_sameSecond(a, b) : a != b) return false;
    }
    return true;
  }

  /// The rows of a table without a "changed" column, each with when it was
  /// made and last edited. The journal the sync keeps is the only record of
  /// edits to these.
  Future<Map<String, (D, _Stamps)>> _journalled<D>(
    String entity,
    List<D> rows,
    String Function(D) id,
    DateTime Function(D) made,
  ) async {
    final edited = await SyncJournal.touched(_db!, entity);
    return {for (final row in rows) id(row): (row, _Stamps(made(row), edited[id(row)]))};
  }

  /// Merges the rows of a simple table. [mine] is what this device has,
  /// each row with when it was made and last changed, and [seeded] what
  /// every install starts out with in that table.
  Future<void> _mergeRows<T extends Table, D extends Insertable<D>>(
    TableInfo<T, D> table,
    Object? rows,
    Insertable<D> Function(Map<String, dynamic>) toCompanion,
    _ImportStats stats, {
    required Map<String, (D, _Stamps)> mine,
    Map<String, Insertable<D>> seeded = const {},
  }) async {
    if (rows is! List) return;
    final db = _db!;
    for (final row in rows) {
      // One row that cannot be read or stored is left out. The rest goes on.
      try {
        final d = row as Map<String, dynamic>;
        final id = d['id'] as String;
        final theirs = toCompanion(d);
        final here = mine[id];
        if (here != null) {
          final (local, stamps) = here;
          if (_sameRow(theirs, local)) continue;
          final asSeeded = seeded[id];
          final takesOver = _takesOver(
            stamps,
            _Stamps(_parseDate(d['createdAt']), _parseDate(d['updatedAt'])),
            mineAsSeeded: asSeeded != null && _sameRow(asSeeded, local),
            theirsAsSeeded: asSeeded != null && _sameRow(asSeeded, theirs),
          );
          if (!takesOver) continue;
        }
        await db.into(table).insertOnConflictUpdate(theirs);
        stats.written++;
      } catch (e) {
        debugPrint('[Transfer] Left out a ${table.actualTableName} row: $e');
      }
    }
  }

  Future<void> _mergeCookbooks(AppDatabase db, Object? rows, Directory? imagesDir, _ImportStats stats) async {
    if (rows is! List) return;
    final mine = {for (final c in await db.select(db.cookbooks).get()) c.id: c};
    for (final row in rows) {
      try {
        final d = row as Map<String, dynamic>;
        final id = d['id'] as String;
        if (!_plainId(id)) continue;
        final theirs = _toCookbookCompanion(d);
        final local = mine[id];
        final asSeeded = _seededCookbooks[id];
        final takesOver = local == null ||
            _takesOver(
              _Stamps(local.createdAt, local.updatedAt),
              _Stamps(_parseDate(d['createdAt']), _parseDate(d['updatedAt'])),
              mineAsSeeded: asSeeded != null && local.imagePath == null && _sameRow(asSeeded, local),
              theirsAsSeeded: asSeeded != null && !_carriesCover(d) && _sameRow(asSeeded, theirs),
            );
        var arrived = false;
        if (local == null || (takesOver && !_sameRow(theirs, local))) {
          await db.into(db.cookbooks).insertOnConflictUpdate(theirs);
          arrived = true;
        }
        // The cover comes with the row. A cookbook that stays as it is only
        // gets one when it has none of its own to show.
        if (takesOver || await _photoMissing(local.imagePath)) {
          final cover = await _savePhoto(d['imageBase64'], imagesDir);
          if (cover != null && cover != local?.imagePath) {
            await (db.update(db.cookbooks)..where((t) => t.id.equals(id)))
                .write(CookbooksCompanion(imagePath: Value(cover), imageServerPath: const Value(null)));
            arrived = arrived || takesOver;
          }
        }
        if (arrived) stats.written++;
      } catch (e) {
        debugPrint('[Transfer] Left out a cookbook: $e');
      }
    }
  }

  bool _carriesCover(Map<String, dynamic> d) {
    final photo = d['imageBase64'];
    return (photo is String && photo.isNotEmpty) || _cloudPath(d['imagePath']) != null;
  }

  /// Merges the recipes and returns, for each recipe id in the bundle, the
  /// id that recipe has on this device.
  Future<Map<String, String>> _mergeRecipes(
    AppDatabase db,
    List rows,
    Directory? imagesDir,
    _ImportStats stats,
  ) async {
    final mine = {for (final r in await db.select(db.recipes).get()) r.id: r};
    final knownTags = {for (final t in await db.select(db.tags).get()) t.id};
    final library = ExportImportService(db);

    // A recipe the bundle holds twice is taken once, the way it comes last.
    final incoming = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      if (row is Map<String, dynamic> && _canBeStored(row)) {
        incoming[row['id'] as String] = row;
      } else {
        debugPrint('[Transfer] Left out a recipe that could not be read');
      }
    }

    // What this device has of each recipe. One that had to be filed beside
    // a recipe with the same id sits under an id of its own, so recipes are
    // gathered by the id they started out with.
    final versions = <String, List<Recipe>>{};
    for (final recipe in mine.values) {
      (versions[_originalId(recipe.id)] ??= []).add(recipe);
    }
    final rowsHere = await _rowsUnderRecipes(db, {
      for (final id in incoming.keys)
        for (final recipe in versions[_originalId(id)] ?? const <Recipe>[]) recipe.id,
    });

    // First what happens to each recipe and under which id, then the
    // writing: a link can point at a recipe further down the list. The
    // recipes this device has already are matched before anything else, so
    // that the place of one of them is never given to another.
    final sameHere = <String, Recipe>{};
    final taken = <String>{};
    for (final MapEntry(key: id, value: d) in incoming.entries) {
      final made = _parseDate(d['createdAt']);
      if (made == null) continue;
      Recipe? same;
      for (final recipe in versions[_originalId(id)] ?? const <Recipe>[]) {
        if (!_sameSecond(made, recipe.createdAt) || taken.contains(recipe.id)) continue;
        if (same == null || recipe.id == id) same = recipe;
      }
      if (same == null) continue;
      sameHere[id] = same;
      taken.add(same.id);
    }

    final plans = <String, _RecipePlan>{};
    for (final MapEntry(key: id, value: d) in incoming.entries) {
      try {
        final same = sameHere[id];
        final plan = same != null
            ? _RecipePlan(d, same.id, await _decideSame(d, same, library, rowsHere[same.id]), same, rowsHere[same.id])
            : await _placeOther(d, mine, versions[_originalId(id)] ?? const [], rowsHere, taken, library);
        taken.add(plan.targetId);
        plans[id] = plan;
      } catch (e) {
        debugPrint('[Transfer] Left out a recipe that could not be read: $e');
      }
    }

    final ids = {for (final plan in plans.entries) plan.key: plan.value.targetId};
    for (final plan in plans.values) {
      try {
        switch (plan.action) {
          case _RecipeAction.add:
          case _RecipeAction.replace:
            await _writeRecipe(db, plan, ids, knownTags, imagesDir);
            stats.written++;
          case _RecipeAction.merge:
            if (await _mergeMarks(db, plan)) {
              stats.written++;
            } else {
              stats.recipesAlreadyHere++;
            }
          case _RecipeAction.same:
            await _restoreCover(db, plan, imagesDir);
            stats.recipesAlreadyHere++;
          case _RecipeAction.keep:
            stats.recipesAlreadyHere++;
        }
      } catch (e) {
        debugPrint('[Transfer] Left out a recipe that could not be stored: $e');
      }
    }
    return ids;
  }

  /// Whether a recipe from the bundle has what a recipe needs, and no id
  /// that reads like a path. No id the app makes holds a slash or "..", and
  /// one that does must not get into the library: other screens build file
  /// names from the id of the recipe they are showing.
  bool _canBeStored(Map<String, dynamic> d) {
    bool plainRows(Object? rows) =>
        rows is! List || rows.every((row) => row is! Map || row['id'] is! String || _plainId(row['id']));
    return d['title'] is String &&
        _plainId(d['id']) &&
        _plainId(d['cookbookId']) &&
        plainRows(d['ingredients']) &&
        plainRows(d['steps']);
  }

  bool _plainId(Object? id) =>
      id is String && id.isNotEmpty && !id.contains('/') && !id.contains(r'\') && !id.contains('..');

  /// What this device has under the recipes [wanted]: ingredients, steps,
  /// tags and links, read once for all of them. Asked for recipe by recipe,
  /// every lookup reads its table from end to end on installs that have no
  /// index on the recipe a row belongs to, and each further recipe made
  /// receiving a large library slower than the one before.
  Future<Map<String, RecipeRows>> _rowsUnderRecipes(AppDatabase db, Set<String> wanted) async {
    final here = <String, RecipeRows>{};
    RecipeRows under(String recipeId) => here[recipeId] ??= RecipeRows();

    for (final i in await (db.select(db.ingredients)..orderBy([(i) => OrderingTerm.asc(i.sortOrder)])).get()) {
      if (wanted.contains(i.recipeId)) under(i.recipeId).ingredients.add(i);
    }
    for (final s in await (db.select(db.steps)..orderBy([(s) => OrderingTerm.asc(s.sortOrder)])).get()) {
      if (wanted.contains(s.recipeId)) under(s.recipeId).steps.add(s);
    }
    for (final rt in await db.select(db.recipeTags).get()) {
      if (wanted.contains(rt.recipeId)) under(rt.recipeId).tagIds.add(rt.tagId);
    }
    for (final rl in await db.select(db.recipeLinks).get()) {
      if (wanted.contains(rl.sourceRecipeId)) under(rl.sourceRecipeId).addLink(rl);
    }
    return here;
  }

  static const _besideMark = '_transferred';

  /// The id a recipe has on the device it was made on. One that had to sit
  /// beside a recipe with the same id is filed under that id with
  /// "_transferred" behind it, or "_transferred_2" and so on where that
  /// place was taken as well.
  String _originalId(String id) {
    var end = id.length;
    while (true) {
      var digits = end;
      while (digits > 0 && _isDigit(id.codeUnitAt(digits - 1))) {
        digits--;
      }
      final numbered = digits < end && digits > 0 && id[digits - 1] == '_';
      final mark = (numbered ? digits - 1 : end) - _besideMark.length;
      if (mark <= 0 || !id.startsWith(_besideMark, mark)) return id.substring(0, end);
      end = mark;
    }
  }

  static bool _isDigit(int codeUnit) => codeUnit >= 0x30 && codeUnit <= 0x39;

  /// An id for a recipe that has to sit beside another: its own if nothing
  /// is there, else the first place beside the original that is free.
  String _placeBeside(String id, Map<String, Recipe> mine, Set<String> taken) {
    bool free(String place) => !mine.containsKey(place) && !taken.contains(place);
    if (free(id)) return id;
    final beside = '${_originalId(id)}$_besideMark';
    if (free(beside)) return beside;
    for (var n = 2;; n++) {
      if (free('${beside}_$n')) return '${beside}_$n';
    }
  }

  /// What to do with a recipe from the other device that this device has
  /// as well: the same recipe, made at the same moment, whatever id it is
  /// filed under on either side. The later version wins. Going by the id
  /// alone, a recipe kept beside another one was not recognised when it
  /// came back from the device it was sent to, and every round trip added
  /// one more copy on both.
  /// [rows] is what this device has under its recipe, null for nothing.
  Future<_RecipeAction> _decideSame(
    Map<String, dynamic> d,
    Recipe local,
    ExportImportService library,
    RecipeRows? rows,
  ) async {
    final changed = _parseDate(d['updatedAt']);
    // Nothing says theirs is the better one: the one here stays.
    if (changed == null) return _RecipeAction.keep;
    // A recipe the other device threw away does not take the one in use
    // here with it. A transfer brings things, it never bins them.
    if (d['deletedAt'] != null && local.deletedAt == null) return _RecipeAction.keep;
    if (changed.isAfter(local.updatedAt)) return _RecipeAction.replace;
    if (local.updatedAt.isAfter(changed)) return _RecipeAction.keep;
    // The same version by the clock can still differ: transfers used to
    // lose section headers and step photos on the way, and a photo that
    // did not fit last time may fit now. Sending again brings them. Tags
    // and links are not looked at: older versions of the app changed
    // those without dating the recipe, so a difference there may be this
    // device's own doing.
    final same = await _sameRecipe(d, local, library, rows, tagsAndLinks: false);
    return same ? _RecipeAction.same : _RecipeAction.replace;
  }

  /// Where a recipe from the other device goes that this device does not
  /// have. [versions] is what is here under its id, in any place: recipes
  /// that only share the id, each device having made its own. That is the
  /// starter recipes, and no clock says which of them is the user's.
  Future<_RecipePlan> _placeOther(
    Map<String, dynamic> d,
    Map<String, Recipe> mine,
    List<Recipe> versions,
    Map<String, RecipeRows> rowsHere,
    Set<String> taken,
    ExportImportService library,
  ) async {
    final id = d['id'] as String;
    _RecipePlan at(Recipe recipe, _RecipeAction action) =>
        _RecipePlan(d, recipe.id, action, recipe, rowsHere[recipe.id]);
    if (versions.isEmpty) return _RecipePlan(d, _placeBeside(id, mine, taken), _RecipeAction.add, null, null);

    // The one under the very same id, unless a recipe of the bundle has
    // turned out to be that one.
    final local = taken.contains(id) ? null : mine[id];
    final theirs = _Stamps(_parseDate(d['createdAt']), _parseDate(d['updatedAt']));
    // Not worth a place beside what is here: nothing says it was ever
    // changed, or the other device threw it away.
    if (d['deletedAt'] != null || _untouchedThere(d, theirs)) {
      return at(local ?? versions.first, _RecipeAction.keep);
    }
    // In the trash here: the one in use over there takes its place.
    if (local != null && local.deletedAt != null) return at(local, _RecipeAction.replace);
    // Nobody has touched the one here, so the one from the other device is
    // the user's and takes its place, in the cookbook it is kept in there.
    // Only one that says and holds the very same is left alone: it would be
    // written for nothing and counted as something that arrived.
    if (local != null && await _untouchedHere(local, rowsHere[local.id], library)) {
      final nothingNew = _keptAlike(d, local, rowsHere[local.id]) &&
          await _sameRecipe(d, local, library, rowsHere[local.id]);
      return at(local, nothingNew ? _RecipeAction.same : _RecipeAction.replace);
    }

    // Changed on both. The same recipe, give or take the rating, the heart
    // and the pin, stays one recipe and gets all of them. Two phones that
    // each rated or pinned a few starters used to end up with every one of
    // those twice. It is looked for among what is in use here and not
    // spoken for by a recipe of the bundle.
    final inUse = [
      if (local != null) local,
      for (final recipe in versions)
        if (recipe.id != id && recipe.deletedAt == null && !taken.contains(recipe.id)) recipe,
    ];
    for (final recipe in inUse) {
      if (await _sameRecipe(d, recipe, library, rowsHere[recipe.id], marks: false)) {
        return at(recipe, _RecipeAction.merge);
      }
    }
    // Different recipes by now. Both are kept, so that neither side's work
    // is lost.
    return _RecipePlan(d, _placeBeside(id, mine, taken), _RecipeAction.add, null, null);
  }

  /// Whether the other device has left a recipe the way the app made it.
  bool _untouchedThere(Map<String, dynamic> d, _Stamps theirs) {
    final made = theirs.made, changed = theirs.changed;
    if (made == null || changed == null || !ExportImportService.isStarterId(d['id'])) return theirs.untouched;
    DateTime? lastLinkAt;
    final links = d['sourceLinks'];
    for (final link in links is List ? links : const []) {
      final linkedAt = link is Map ? _parseDate(link['createdAt']) : null;
      if (linkedAt != null && (lastLinkAt == null || linkedAt.isAfter(lastLinkAt))) lastLinkAt = linkedAt;
    }
    return !ExportImportService.changedSinceMade(made, changed, lastLinkAt) && ExportImportService.isShippedStarter(d);
  }

  /// Whether nobody has touched a recipe on this device since it was made.
  Future<bool> _untouchedHere(Recipe local, RecipeRows? rows, ExportImportService library) async =>
      ExportImportService.isStarterId(local.id)
          ? library.untouchedStarter(local, rows ?? RecipeRows())
          : _Stamps(local.createdAt, local.updatedAt).untouched;

  /// Whether the recipe in the bundle is, to the person cooking from it,
  /// the recipe already here. The same test a restore from a backup uses.
  /// Without [marks] the rating, the heart and the pin are not looked at.
  Future<bool> _sameRecipe(
    Map<String, dynamic> d,
    Recipe local,
    ExportImportService library,
    RecipeRows? rows, {
    bool tagsAndLinks = true,
    bool marks = true,
  }) {
    final tags = d['recipeTags'];
    final links = d['sourceLinks'];
    final steps = d['steps'];
    final stepsHere = steps is List ? _sameSteps(steps, rows) : const <Step?>[];
    final carried = {
      ...d,
      if (steps is List)
        'steps': [
          for (final (i, step) in steps.indexed)
            step is Map<String, dynamic> ? {...step, 'notes': _headerMark(step, stepsHere[i])} : step,
        ],
      if (tagsAndLinks && tags is List) 'tagIds': [for (final tag in tags) (tag as Map)['tagId']],
      if (tagsAndLinks && links is List) 'recipeLinks': links,
    };
    if (!marks) _marks.forEach(carried.remove);
    return library.sameAsLocal(carried, local, const {}, rows ?? RecipeRows());
  }

  /// What a cook puts on a recipe without changing what it says.
  static const _marks = ['rating', 'isFavorite', 'isPinned'];

  /// Whether the recipe in the bundle is kept the way [local] is in what
  /// [_sameRecipe] does not look at, because it is not what the recipe
  /// says: the cookbook it is in, its nutrition values, and how much of
  /// which linked recipe goes with which ingredient.
  bool _keptAlike(Map<String, dynamic> d, Recipe local, RecipeRows? rows) {
    if (d['cookbookId'] != local.cookbookId || d['nutritionJson'] != local.nutritionJson) return false;
    final links = d['sourceLinks'];
    if (links is! List) return true;
    final theirs = {
      for (final link in links)
        if (link is Map) (link['ingredientId'], link['linkedRecipeId'], _scale(link)),
    };
    final mine = {
      for (final link in rows?.links ?? const <RecipeLink>[]) (link.ingredientId, link.linkedRecipeId, link.scale),
    };
    return theirs.length == mine.length && theirs.containsAll(mine);
  }

  Map<int, Step> _bySortOrder(RecipeRows? rows) => {
        for (final step in rows?.steps ?? const <Step>[]) step.sortOrder: step,
      };

  /// For each of the [steps] of a recipe in the bundle, the step this
  /// device has that it is, or null: the one in the same place that reads
  /// the same, or else one that reads the same in another place. A step
  /// added or taken out further up on the other device moves every step
  /// below it, and those are still the steps they were. What a bundle does
  /// not say about a step is taken from the one found here.
  List<Step?> _sameSteps(List steps, RecipeRows? rows) {
    final same = List<Step?>.filled(steps.length, null);
    final here = rows?.steps ?? const <Step>[];
    if (here.isEmpty) return same;

    final inPlace = _bySortOrder(rows);
    final found = <String>{};
    for (final (i, step) in steps.indexed) {
      if (step is! Map) continue;
      final candidate = inPlace[_int(step['sortOrder']) ?? 0];
      if (candidate != null && candidate.instruction == step['instruction'] && found.add(candidate.id)) {
        same[i] = candidate;
      }
    }
    // The rest by what they say alone, the first that reads so with the
    // first that reads so. One that kept its place is not given away.
    final elsewhere = <String, List<Step>>{};
    for (final step in here.reversed) {
      if (!found.contains(step.id)) (elsewhere[step.instruction] ??= []).add(step);
    }
    for (final (i, step) in steps.indexed) {
      if (same[i] != null || step is! Map) continue;
      final candidates = elsewhere[step['instruction']];
      if (candidates != null && candidates.isNotEmpty) same[i] = candidates.removeLast();
    }
    return same;
  }

  /// What makes a step from the bundle a section header ('__header__') or
  /// not. The released version of the app does not send it at all, and "not
  /// sent" must not be read as "not a header": a recipe sent back by a
  /// device that has not been updated yet turned every header on this one
  /// into a numbered step. Without the mark, the step keeps the one it has
  /// here, [here] being the step this device has that it is.
  String? _headerMark(Map<String, dynamic> step, Step? here) =>
      step.containsKey('notes') ? _text(step['notes']) : here?.notes;

  /// Stores a recipe from the bundle with everything under it, as a new
  /// recipe or in place of the one this device has.
  Future<void> _writeRecipe(
    AppDatabase db,
    _RecipePlan plan,
    Map<String, String> ids,
    Set<String> knownTags,
    Directory? imagesDir,
  ) async {
    final d = plan.data;
    final recipeId = plan.targetId;
    final local = plan.local;
    final here = plan.rows;
    // Filed under another id than the one it came with, the rows under it
    // move along: most carry the id of their recipe in front of their own.
    final cameAs = '${d['id']}_';
    String rowId(Object? id) {
      final own = id as String;
      if (recipeId == d['id']) return own;
      return '${recipeId}_${own.startsWith(cameAs) ? own.substring(cameAs.length) : own}';
    }

    // Photos. One that arrives is stored here, one that only exists in the
    // cloud is pointed at, and without either the photo this device has is
    // left where it is: no photo coming does not mean there is none.
    var row = _toRecipeCompanion(d).copyWith(id: Value(recipeId));
    final cover = await _savePhoto(d['imageBase64'], imagesDir);
    final cloudCover = _cloudPath(d['imagePath']);
    if (cover != null) {
      // No cloud copy is known for it, the next sync uploads this one.
      row = row.copyWith(imagePath: Value(cover), imageServerPath: const Value(null));
    } else if (cloudCover != null && (local == null || await _photoMissing(local.imagePath))) {
      row = row.copyWith(imagePath: Value(cloudCover));
    }
    // Which recipe was opened last is this device's own history.
    if (local != null) row = row.copyWith(lastViewedAt: const Value.absent());

    final ingredients = <IngredientsCompanion>[
      if (d['ingredients'] is List)
        for (final ingredient in d['ingredients'] as List)
          IngredientsCompanion.insert(
            id: rowId((ingredient as Map<String, dynamic>)['id']),
            recipeId: recipeId,
            sortOrder: _int(ingredient['sortOrder']) ?? 0,
            amount: Value(_text(ingredient['amount'])),
            unit: Value(_text(ingredient['unit'])),
            name: ingredient['name'] as String,
            notes: Value(_text(ingredient['notes'])),
          ),
    ];

    final steps = <StepsCompanion>[];
    if (d['steps'] is List) {
      final carried = d['steps'] as List;
      final stepsHere = _sameSteps(carried, here);
      final spokenFor = {
        for (final step in stepsHere)
          if (step != null) step.id,
      };
      final inPlace = _bySortOrder(here);
      for (final (i, step) in carried.indexed) {
        final s = step as Map<String, dynamic>;
        final sortOrder = _int(s['sortOrder']) ?? 0;
        final photo = await _savePhoto(s['imageBase64'], imagesDir) ?? _cloudPath(s['imagePath']);
        // Without a photo coming, the step keeps the one it has here. A
        // step that was reworded is still the step in its place, unless
        // the one that was there has turned up somewhere else.
        var kept = photo == null ? stepsHere[i] : null;
        if (photo == null && kept == null && !spokenFor.contains(inPlace[sortOrder]?.id)) kept = inPlace[sortOrder];
        steps.add(StepsCompanion.insert(
          id: rowId(s['id']),
          recipeId: recipeId,
          sortOrder: sortOrder,
          instruction: s['instruction'] as String,
          durationMinutes: Value(_int(s['durationMinutes'])),
          notes: Value(_headerMark(s, stepsHere[i])),
          imagePath: Value(photo ?? kept?.imagePath),
          imageServerPath: Value(kept?.imageServerPath),
        ));
      }
    }

    final tags = <RecipeTagsCompanion>[
      if (d['recipeTags'] is List)
        for (final tag in d['recipeTags'] as List)
          // One for a tag this device does not have would point at nothing.
          if (knownTags.contains((tag as Map<String, dynamic>)['tagId']))
            RecipeTagsCompanion.insert(recipeId: recipeId, tagId: tag['tagId'] as String),
    ];

    final links = <RecipeLinksCompanion>[
      if (d['sourceLinks'] is List)
        for (final link in d['sourceLinks'] as List)
          RecipeLinksCompanion.insert(
            sourceRecipeId: recipeId,
            ingredientId: rowId((link as Map<String, dynamic>)['ingredientId']),
            linkedRecipeId: ids[link['linkedRecipeId']] ?? link['linkedRecipeId'] as String,
            scale: Value(_scale(link)),
            sortOrder: Value(_int(link['sortOrder']) ?? 0),
          ),
    ];

    // The recipe and the rows under it go in together or not at all. What
    // was under it before goes out by its own id, which is the one thing
    // every install can look these rows up by without reading them all.
    final oldIngredients = [for (final i in here?.ingredients ?? const <Ingredient>[]) i.id];
    final oldSteps = [for (final s in here?.steps ?? const <Step>[]) s.id];
    await db.transaction(() async {
      await db.into(db.recipes).insertOnConflictUpdate(row);
      await db.batch((batch) {
        if (d['ingredients'] is List) {
          if (oldIngredients.isNotEmpty) batch.deleteWhere(db.ingredients, (i) => i.id.isIn(oldIngredients));
          batch.insertAll(db.ingredients, ingredients);
        }
        if (d['steps'] is List) {
          if (oldSteps.isNotEmpty) batch.deleteWhere(db.steps, (s) => s.id.isIn(oldSteps));
          batch.insertAll(db.steps, steps);
        }
        if (d['recipeTags'] is List) {
          if (here != null) batch.deleteWhere(db.recipeTags, (rt) => rt.recipeId.equals(recipeId));
          batch.insertAll(db.recipeTags, tags, mode: InsertMode.insertOrIgnore);
        }
        if (d['sourceLinks'] is List) {
          if (here != null) batch.deleteWhere(db.recipeLinks, (rl) => rl.sourceRecipeId.equals(recipeId));
          batch.insertAll(db.recipeLinks, links, mode: InsertMode.insertOrReplace);
        }
      });
    });
  }

  /// Puts the rating, the heart and the pin of the recipe from the bundle
  /// onto the same recipe here: a heart or a pin if either device gave one,
  /// and the other device's rating where this one has none. Says whether
  /// that changed anything.
  Future<bool> _mergeMarks(AppDatabase db, _RecipePlan plan) async {
    final local = plan.local!;
    final d = plan.data;
    final rating = (local.rating ?? 0) > 0 ? local.rating : _int(d['rating']);
    final isFavorite = local.isFavorite || d['isFavorite'] == true;
    final isPinned = local.isPinned || d['isPinned'] == true;
    if ((rating ?? 0) == (local.rating ?? 0) && isFavorite == local.isFavorite && isPinned == local.isPinned) {
      return false;
    }
    // Dated now: the recipe changed on this device, and a sync has to see it.
    await (db.update(db.recipes)..where((t) => t.id.equals(local.id))).write(RecipesCompanion(
      rating: Value(rating),
      isFavorite: Value(isFavorite),
      isPinned: Value(isPinned),
      updatedAt: Value(DateTime.now()),
    ));
    return true;
  }

  /// A recipe that stays as it is can still point at a cover file that is
  /// gone: transfers used to store the sender's own file path for a cover
  /// they could not carry. The photo in the bundle takes its place.
  Future<void> _restoreCover(AppDatabase db, _RecipePlan plan, Directory? imagesDir) async {
    final local = plan.local!;
    final carried = plan.data['imageBase64'];
    if (carried is! String || carried.isEmpty || !await _photoMissing(local.imagePath)) return;
    final cover = await _savePhoto(carried, imagesDir);
    if (cover == null) return;
    await (db.update(db.recipes)..where((t) => t.id.equals(local.id)))
        .write(RecipesCompanion(imagePath: Value(cover)));
  }

  // ════════════════════════════════════════════════════════════════
  //  WHAT EVERY INSTALL STARTS OUT WITH
  // ════════════════════════════════════════════════════════════════
  //
  // The rows the app writes on first launch, with what a user can change
  // about each. They repeat what AppDatabase and TagsDao seed and have to
  // stay in step with them. Edits to these rows were not dated before
  // version 1.7, and a cloud sync clears the journal that dates them since,
  // so for most of them nothing says whether the user ever changed them.
  // Comparing with what the app wrote does: a row that still reads like
  // this never takes the place of one that does not.

  static final Map<String, Insertable<Cookbook>> _seededCookbooks = {
    'starter': const CookbooksCompanion(name: Value('My Recipes'), description: Value(null)),
  };

  static final Map<String, Insertable<ShoppingList>> _seededShoppingLists = {
    'list_default': const ShoppingListsCompanion(name: Value('Shopping List'), color: Value(null)),
  };

  static final Map<String, Insertable<Category>> _seededCategories = {
    for (final (id, name, sortOrder) in const [
      ('cat_appetizer', 'Appetizer', 0),
      ('cat_beverage', 'Beverages', 1),
      ('cat_dessert', 'Desserts', 2),
      ('cat_entree', 'Entrée', 3),
      ('cat_side', 'Sides', 4),
      ('cat_sauce', 'Sauces', 5),
    ])
      id: CategoriesCompanion(name: Value(name), sortOrder: Value(sortOrder), isHidden: const Value(false)),
  };

  static final Map<String, Insertable<ShoppingCategory>> _seededShoppingCategories = {
    for (final (id, name, sortOrder) in const [
      ('produce', 'Produce', 1),
      ('bakery', 'Bakery', 2),
      ('deli', 'Deli', 3),
      ('dairy', 'Dairy & Eggs', 4),
      ('meat', 'Meat & Poultry', 5),
      ('seafood', 'Seafood', 6),
      ('frozen', 'Frozen', 7),
      ('breakfastCereal', 'Breakfast & Cereal', 8),
      ('grainsAndPasta', 'Grains, Pasta & Rice', 9),
      ('cannedGoods', 'Canned Goods', 10),
      ('condiments', 'Condiments & Sauces', 11),
      ('spices', 'Spices & Seasonings', 12),
      ('cookingAndBaking', 'Cooking & Baking', 13),
      ('snacks', 'Snacks', 14),
      ('beverages', 'Beverages', 15),
      ('beerWineSpirits', 'Beer, Wine & Spirits', 16),
      ('international', 'International', 17),
      ('baby', 'Baby', 18),
      ('pet', 'Pet Supplies', 19),
      ('household', 'Household', 20),
      ('personalCare', 'Personal Care', 21),
      ('pantry', 'Pantry', 22),
      ('other', 'Other', 99),
    ])
      id: ShoppingCategoriesCompanion(
        name: Value(name),
        iconName: const Value(null),
        sortOrder: Value(sortOrder),
        isHidden: const Value(false),
      ),
  };

  static final Map<String, Insertable<Tag>> _seededTags = {
    for (final (id, name, color, icon, sortOrder) in const [
      ('tag_vegan', 'Vegan', '#4CAF50', '🌱', 0),
      ('tag_vegetarian', 'Vegetarian', '#8BC34A', '🥬', 1),
      ('tag_gluten_free', 'Gluten-Free', '#FF9800', '🌾', 2),
      ('tag_dairy_free', 'Dairy-Free', '#2196F3', '🥛', 3),
      ('tag_keto', 'Keto', '#9C27B0', '🥑', 4),
      ('tag_paleo', 'Paleo', '#795548', '🥩', 5),
      ('tag_low_carb', 'Low Carb', '#00BCD4', '📉', 6),
      ('tag_nut_free', 'Nut-Free', '#FF5722', '🥜', 7),
      ('tag_quick', 'Quick & Easy', '#4CAF50', '⚡', 10),
      ('tag_meal_prep', 'Meal Prep', '#3F51B5', '📦', 11),
      ('tag_weeknight', 'Weeknight Dinner', '#607D8B', '🌙', 12),
      ('tag_weekend', 'Weekend Project', '#FFC107', '☀️', 13),
      ('tag_comfort', 'Comfort Food', '#FF5722', '🔥', 14),
      ('tag_healthy', 'Healthy', '#4CAF50', '💪', 15),
      ('tag_family', 'Family Favorite', '#E91E63', '❤️', 20),
      ('tag_crowd', 'Crowd Pleaser', '#9C27B0', '🎉', 21),
      ('tag_budget', 'Budget Friendly', '#4CAF50', '💰', 22),
      ('tag_kid', 'Kid Friendly', '#FF9800', '👶', 23),
      ('tag_spicy', 'Spicy', '#F44336', '🌶️', 24),
      ('tag_one_pot', 'One Pot', '#795548', '🍲', 25),
    ])
      id: TagsCompanion(name: Value(name), color: Value(color), icon: Value(icon), sortOrder: Value(sortOrder)),
  };

  // ════════════════════════════════════════════════════════════════
  //  COMPANION BUILDERS (JSON → Drift Companion)
  // ════════════════════════════════════════════════════════════════

  CookbooksCompanion _toCookbookCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return CookbooksCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        description: Value(d['description'] as String?),
        // A file path only means something on the device it came from.
        // Left out rather than set to null, so that the cover this device
        // has is not wiped: the photo itself arrives as imageBase64.
        imagePath: _cloudPath(d['imagePath']) != null ? Value(d['imagePath'] as String) : const Value.absent(),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: Value(_parseDateNullable(d['updatedAt'])),
      );
  }

  CategoriesCompanion _toCategoryCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return CategoriesCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        isDefault: Value(d['isDefault'] as bool? ?? false),
        isHidden: Value(d['isHidden'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  CustomCategoriesCompanion _toCustomCategoryCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return CustomCategoriesCompanion(
        id: Value(d['id'] as String),
        cookbookId: Value(d['cookbookId'] as String),
        name: Value(d['name'] as String),
        emoji: Value(d['emoji'] as String? ?? '🏷️'),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  CustomCoursesCompanion _toCustomCourseCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return CustomCoursesCompanion(
        id: Value(d['id'] as String),
        cookbookId: Value(d['cookbookId'] as String),
        name: Value(d['name'] as String),
        emoji: Value(d['emoji'] as String? ?? '🍽️'),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  TagsCompanion _toTagCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return TagsCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        color: Value(d['color'] as String?),
        icon: Value(d['icon'] as String?),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        isBuiltIn: Value(d['isBuiltIn'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  ShoppingCategoriesCompanion _toShoppingCategoryCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      return ShoppingCategoriesCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        iconName: Value(d['iconName'] as String?),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        isDefault: Value(d['isDefault'] as bool? ?? false),
        isHidden: Value(d['isHidden'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
      );
  }

  RecipesCompanion _toRecipeCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      final updatedAt = _parseDate(d['updatedAt']);
      return RecipesCompanion(
        id: Value(d['id'] as String),
        cookbookId: Value(d['cookbookId'] as String),
        title: Value(d['title'] as String),
        description: Value(d['description'] as String?),
        servings: Value(d['servings'] as String?),
        prepTimeMinutes: Value(d['prepTimeMinutes'] as int?),
        cookTimeMinutes: Value(d['cookTimeMinutes'] as int?),
        sourceUrl: Value(d['sourceUrl'] as String?),
        courseId: Value(d['courseId'] as String?),
        categoryId: Value(d['categoryId'] as String?),
        rating: Value(d['rating'] as int?),
        notes: Value(d['notes'] as String?),
        nutritionJson: Value(d['nutritionJson'] as String?),
        isFavorite: Value(d['isFavorite'] as bool? ?? false),
        isPinned: Value(d['isPinned'] as bool? ?? false),
        deletedAt: Value(_parseDateNullable(d['deletedAt'])),
        lastViewedAt: Value(_parseDateNullable(d['lastViewedAt'])),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
      );
  }

  /// [recipeIds] maps a recipe id in the bundle to the id that recipe has
  /// on this device.
  MealPlansCompanion _toMealPlanCompanion(Map<String, dynamic> d, Map<String, String> recipeIds) {
      final date = _parseDate(d['date']);
      final createdAt = _parseDate(d['createdAt']);
      final updatedAt = _parseDate(d['updatedAt']);
      return MealPlansCompanion(
        id: Value(d['id'] as String),
        date: date != null ? Value(date) : const Value.absent(),
        time: Value(_parseDateNullable(d['time'])),
        name: Value(d['name'] as String?),
        mealType: Value(d['mealType'] as String? ?? 'Dinner'),
        customMeal: Value(d['customMeal'] as String?),
        recipeId: Value(recipeIds[d['recipeId']] ?? d['recipeId'] as String?),
        notes: Value(d['notes'] as String?),
        // A bundle from before the colour travelled must not clear the one
        // a meal has here.
        cardColor: d.containsKey('cardColor') ? Value(d['cardColor'] as String?) : const Value.absent(),
        alertEnabled: Value(d['alertEnabled'] as bool? ?? false),
        alertSent: Value(d['alertSent'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
      );
  }

  ShoppingListsCompanion _toShoppingListCompanion(Map<String, dynamic> d) {
      final createdAt = _parseDate(d['createdAt']);
      final updatedAt = _parseDate(d['updatedAt']);
      return ShoppingListsCompanion(
        id: Value(d['id'] as String),
        name: Value(d['name'] as String),
        color: Value(d['color'] as String?),
        isDefault: Value(d['isDefault'] as bool? ?? false),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
      );
  }

  ShoppingListItemsCompanion _toShoppingListItemCompanion(Map<String, dynamic> d, Map<String, String> recipeIds) {
      final createdAt = _parseDate(d['createdAt']);
      final updatedAt = _parseDate(d['updatedAt']);
      return ShoppingListItemsCompanion(
        id: Value(d['id'] as String),
        listId: Value(d['listId'] as String),
        name: Value(d['name'] as String),
        quantity: Value(d['quantity'] as String?),
        unit: Value(d['unit'] as String?),
        shoppingCategoryId: Value(d['shoppingCategoryId'] as String?),
        isChecked: Value(d['isChecked'] as bool? ?? false),
        isFavorite: Value(d['isFavorite'] as bool? ?? false),
        useCount: Value(d['useCount'] as int? ?? 0),
        // An item made from a recipe names that recipe in its note as well.
        note: Value(ExportImportService.renameSources(d['note'] as String?, recipeIds)),
        sortOrder: Value(d['sortOrder'] as int? ?? 0),
        recipeId: Value(recipeIds[d['recipeId']] ?? d['recipeId'] as String?),
        createdAt: createdAt != null ? Value(createdAt) : const Value.absent(),
        updatedAt: updatedAt != null ? Value(updatedAt) : const Value.absent(),
      );
  }

  // ════════════════════════════════════════════════════════════════
  //  SERIALIZATION (Drift → JSON) — mirrors SyncService
  // ════════════════════════════════════════════════════════════════

  String? _iso(DateTime? dt) => dt?.toUtc().toIso8601String();

  /// The cloud copy of a photo, the only path that means anything on
  /// another device. A file path of this device never goes on the wire: the
  /// other side used to store it and show nothing.
  String? _cloudCopy(String? imagePath, [String? imageServerPath]) =>
      imageServerPath ?? (ImageService.isServerPath(imagePath) ? imagePath : null);

  Map<String, dynamic> _serializeCookbook(Cookbook cb) => {
    'id': cb.id, 'name': cb.name, 'description': cb.description,
    'imagePath': _cloudCopy(cb.imagePath), 'createdAt': _iso(cb.createdAt),
    'updatedAt': _iso(cb.updatedAt),
  };

  Map<String, dynamic> _serializeRecipe(Recipe r) => {
    'id': r.id, 'cookbookId': r.cookbookId, 'title': r.title,
    'description': r.description, 'servings': r.servings,
    'prepTimeMinutes': r.prepTimeMinutes, 'cookTimeMinutes': r.cookTimeMinutes,
    'sourceUrl': r.sourceUrl, 'imagePath': _cloudCopy(r.imagePath, r.imageServerPath),
    'courseId': r.courseId, 'categoryId': r.categoryId,
    'rating': r.rating, 'notes': r.notes,
    'nutritionJson': r.nutritionJson, 'isFavorite': r.isFavorite,
    'isPinned': r.isPinned, 'deletedAt': _iso(r.deletedAt),
    'lastViewedAt': _iso(r.lastViewedAt), 'createdAt': _iso(r.createdAt),
    'updatedAt': _iso(r.updatedAt),
  };

  Map<String, dynamic> _serializeIngredient(Ingredient i) => {
    'id': i.id, 'recipeId': i.recipeId, 'sortOrder': i.sortOrder,
    'amount': i.amount, 'unit': i.unit, 'name': i.name, 'notes': i.notes,
  };

  Map<String, dynamic> _serializeStep(Step s) => {
    'id': s.id, 'recipeId': s.recipeId, 'sortOrder': s.sortOrder,
    'instruction': s.instruction, 'durationMinutes': s.durationMinutes,
    'imagePath': _cloudCopy(s.imagePath, s.imageServerPath),
    // notes == '__header__' marks an instruction section header. Without
    // it every header arrived as one more numbered step.
    'notes': s.notes,
  };

  Map<String, dynamic> _serializeRecipeLink(RecipeLink rl) => {
    'sourceRecipeId': rl.sourceRecipeId, 'ingredientId': rl.ingredientId,
    'linkedRecipeId': rl.linkedRecipeId, 'scale': rl.scale,
    'sortOrder': rl.sortOrder, 'createdAt': _iso(rl.createdAt),
  };

  // The small tables have no "changed" column. [editedAt] is when the
  // journal last saw the row edited, null when it never did.

  Map<String, dynamic> _serializeCategory(Category c, DateTime? editedAt) => {
    'id': c.id, 'name': c.name, 'sortOrder': c.sortOrder,
    'isDefault': c.isDefault, 'isHidden': c.isHidden,
    'createdAt': _iso(c.createdAt), 'updatedAt': _iso(editedAt),
  };

  Map<String, dynamic> _serializeCustomCategory(CustomCategory cc, DateTime? editedAt) => {
    'id': cc.id, 'cookbookId': cc.cookbookId, 'name': cc.name,
    'emoji': cc.emoji, 'sortOrder': cc.sortOrder,
    'createdAt': _iso(cc.createdAt), 'updatedAt': _iso(editedAt),
  };

  Map<String, dynamic> _serializeCustomCourse(CustomCourse cc, DateTime? editedAt) => {
    'id': cc.id, 'cookbookId': cc.cookbookId, 'name': cc.name,
    'emoji': cc.emoji, 'sortOrder': cc.sortOrder,
    'createdAt': _iso(cc.createdAt), 'updatedAt': _iso(editedAt),
  };

  Map<String, dynamic> _serializeTag(Tag t, DateTime? editedAt) => {
    'id': t.id, 'name': t.name, 'color': t.color, 'icon': t.icon,
    'sortOrder': t.sortOrder, 'isBuiltIn': t.isBuiltIn,
    'createdAt': _iso(t.createdAt), 'updatedAt': _iso(editedAt),
  };

  Map<String, dynamic> _serializeMealPlan(MealPlan mp) => {
    'id': mp.id, 'date': _iso(mp.date), 'time': _iso(mp.time),
    'name': mp.name, 'mealType': mp.mealType, 'customMeal': mp.customMeal,
    'recipeId': mp.recipeId, 'notes': mp.notes, 'cardColor': mp.cardColor,
    'alertEnabled': mp.alertEnabled, 'alertSent': mp.alertSent,
    'createdAt': _iso(mp.createdAt), 'updatedAt': _iso(mp.updatedAt),
  };

  Map<String, dynamic> _serializeShoppingList(ShoppingList sl) => {
    'id': sl.id, 'name': sl.name, 'color': sl.color,
    'isDefault': sl.isDefault, 'createdAt': _iso(sl.createdAt),
    'updatedAt': _iso(sl.updatedAt),
  };

  Map<String, dynamic> _serializeShoppingListItem(ShoppingListItem si) => {
    'id': si.id, 'listId': si.listId, 'name': si.name,
    'quantity': si.quantity, 'unit': si.unit,
    'shoppingCategoryId': si.shoppingCategoryId,
    'isChecked': si.isChecked, 'isFavorite': si.isFavorite,
    'useCount': si.useCount, 'note': si.note, 'sortOrder': si.sortOrder,
    'recipeId': si.recipeId, 'createdAt': _iso(si.createdAt),
    'updatedAt': _iso(si.updatedAt),
  };

  Map<String, dynamic> _serializeShoppingCategory(ShoppingCategory sc, DateTime? editedAt) => {
    'id': sc.id, 'name': sc.name, 'iconName': sc.iconName,
    'sortOrder': sc.sortOrder, 'isDefault': sc.isDefault,
    'isHidden': sc.isHidden, 'createdAt': _iso(sc.createdAt),
    'updatedAt': _iso(editedAt),
  };

  // ════════════════════════════════════════════════════════════════
  //  UTILITIES
  // ════════════════════════════════════════════════════════════════

  /// Saves a photo the bundle carries and returns where it went, or null
  /// when there is none or it cannot be saved.
  ///
  /// The file is named after its own bytes. The name used to be the recipe
  /// id from the bundle, and an id such as ../../recipe_images/my_cover
  /// wrote over a photo outside the folder. Now nothing the other side
  /// chose is part of a path, and the same photo sent twice is one file.
  Future<String?> _savePhoto(Object? base64, Directory? imagesDir) async {
    if (imagesDir == null || base64 is! String || base64.isEmpty) return null;
    try {
      final bytes = base64Decode(base64);
      final file = File(p.join(imagesDir.path, '${sha1.convert(bytes)}.jpg'));
      if (!await file.exists() || await file.length() != bytes.length) await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('[Transfer] Failed to decode/save photo: $e');
      return null;
    }
  }

  /// Whether a row has no photo this device can show: no path at all, or
  /// the path of a file that is not there.
  Future<bool> _photoMissing(String? path) async {
    if (path == null || path.isEmpty) return true;
    if (isWeb || ImageService.isServerPath(path)) return false;
    return !await File(path).exists();
  }

  /// What the server calls a photo: the id of an account, a slash and a
  /// file name, with nothing in either that a path could be made of.
  static final _cloudPhoto = RegExp(r'^[A-Za-z0-9_-]+/[A-Za-z0-9_.-]+$');

  /// [value] if it is the path of a photo in the cloud, which any device
  /// can load. A file path of the sending device is not, and neither is
  /// one made to look like a place on this device ("../cover.jpg").
  String? _cloudPath(Object? value) =>
      value is String && !value.contains('..') && _cloudPhoto.hasMatch(value) ? value : null;

  String? _text(Object? value) => value is String ? value : null;

  int? _int(Object? value) => value is num ? value.toInt() : null;

  /// How much of the linked recipe a link from the bundle asks for. One
  /// that does not say is the whole recipe, once.
  double _scale(Map link) => (link['scale'] as num?)?.toDouble() ?? 1.0;

  bool _sameSecond(DateTime a, DateTime b) =>
      a.millisecondsSinceEpoch ~/ 1000 == b.millisecondsSinceEpoch ~/ 1000;

  /// The JSON object in the body of [response], or null when the body is
  /// something else, such as the error page of a proxy.
  Map<String, dynamic>? _decodeObject(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Parses a date from various formats. Returns null when parsing fails
  /// so the caller / Drift default can handle missing dates appropriately.
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  DateTime? _parseDateNullable(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  String _parseError(dynamic response) {
    try {
      final body = jsonDecode(response.body);
      return body['error'] ?? body['message'] ?? 'Unknown error';
    } catch (_) {
      return 'HTTP ${response.statusCode}';
    }
  }
}

/// Everything on this device, ready to send, and the photos that go with
/// it as far as there is room.
class _Library {
  _Library(this.data, this.photos);
  final Map<String, dynamic> data;
  final List<_Photo> photos;
}

/// A photo file on this device and the row in the bundle it belongs to.
class _Photo {
  _Photo(this.holder, this.path, this.rank);

  // What is sent first when not everything fits.
  static const cookbookCover = 0;
  static const recipeCover = 1;
  static const stepPhoto = 2;
  static const inTheTrash = 3;

  final Map<String, dynamic> holder;
  final String path;
  final int rank;
  int bytes = 0;
}

/// When a row was made and when it was last changed, as far as that is
/// known.
class _Stamps {
  const _Stamps(this.made, this.changed);
  final DateTime? made;
  final DateTime? changed;

  /// Nothing says the row was changed after it was made. The few seconds
  /// are for rows that are dated once more in the course of being made.
  bool get untouched {
    final made = this.made, changed = this.changed;
    return changed == null || (made != null && changed.difference(made).abs() <= const Duration(seconds: 5));
  }
}

class _ImportStats {
  /// Rows added, or taken over from the other device.
  int written = 0;

  /// Recipes this device already had and kept.
  int recipesAlreadyHere = 0;
}

/// What happens to a recipe from the other device.
enum _RecipeAction {
  /// This device does not have it.
  add,

  /// It takes the place of the one here, under the same id.
  replace,

  /// The one here stays.
  keep,

  /// The one here is the same recipe and stays.
  same,

  /// The one here is the same recipe, give or take its rating, heart and
  /// pin, and takes over what it lacks of those.
  merge,
}

class _RecipePlan {
  _RecipePlan(this.data, this.targetId, this.action, this.local, this.rows);
  final Map<String, dynamic> data;

  /// The id the recipe has, or gets, on this device.
  final String targetId;
  final _RecipeAction action;

  /// The recipe this device has under [targetId], if any, and the rows
  /// under it.
  final Recipe? local;
  final RecipeRows? rows;
}