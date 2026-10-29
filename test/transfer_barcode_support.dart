// What the device transfer tests share: a stand-in for the server that
// behaves like the real one, and the app running on one phone or another.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/auth_service.dart';
import 'package:recipespellbook/services/transfer_service.dart';

import 'backup_restore_support.dart';

/// The transfer endpoints of the server: a 15 MB limit on the request body,
/// sign-in needed to send, and a code that is used up by its first download.
class TransferServer {
  static const bodyLimit = 15 * 1024 * 1024;

  final bundles = <String, Map<String, dynamic>>{};
  final used = <String>{};
  int uploads = 0;
  int downloads = 0;
  int lastBodyBytes = 0;
  int _codes = 0;

  /// What the last upload said about the sender, next to the library.
  Map<String, dynamic> lastSender = const {};

  /// When the codes it hands out expire. Fifteen minutes from now if null.
  DateTime? expiresAt;

  /// Answers the next transfer requests instead of the server, when set.
  http.Response Function(http.Request request)? answer;

  /// Requests that are not transfers wait for this, the way a cloud sync
  /// does that is still running.
  Completer<void>? otherRequests;

  http.Client get client => MockClient((request) async {
        final path = request.url.path;
        if (!path.startsWith('/v1/transfer/')) {
          await otherRequests?.future;
          return json({'error': 'Service unavailable'}, 503);
        }
        if (request.method == 'POST') uploads++;
        if (request.method == 'GET') downloads++;
        final override = answer;
        if (override != null) return override(request);

        if (request.method == 'POST' && path == '/v1/transfer/create') {
          lastBodyBytes = request.bodyBytes.length;
          // The body is parsed before the route looks at who is asking.
          if (request.bodyBytes.length > bodyLimit) return json({'error': 'Internal server error'}, 413);
          if (!(request.headers['Authorization'] ?? '').startsWith('Bearer ')) {
            return json({'error': 'Missing authorization header'}, 401);
          }
          final body = jsonDecode(utf8.decode(request.bodyBytes)) as Map<String, dynamic>;
          // Name, address and picture are each a text or not there at all.
          for (final key in const ['displayName', 'email', 'avatarUrl']) {
            if (body.containsKey(key) && body[key] is! String) return json({'error': 'Validation failed'}, 400);
          }
          lastSender = {...body}..remove('data');
          final data = body['data'] as Map<String, dynamic>;
          final code = 'ABC${(234 + _codes++).toString().padLeft(3, '0')}';
          bundles[code] = {'data': data, 'userId': 'user_1', 'displayName': body['displayName']};
          return json({
            'code': code,
            'expiresAt': (expiresAt ?? DateTime.now().add(const Duration(minutes: 15))).toUtc().toIso8601String(),
            'recipesCount': (data['recipes'] as List).length,
            'cookbooksCount': (data['cookbooks'] as List).length,
          });
        }
        if (request.method == 'GET') {
          final code = path.substring('/v1/transfer/'.length);
          final bundle = bundles[code];
          if (bundle == null) return json({'error': 'Transfer code not found'}, 404);
          if (!used.add(code)) return json({'error': 'Transfer code has already been used'}, 409);
          return json(bundle);
        }
        return json({'error': 'Not found'}, 404);
      });

  static http.Response json(Object body, [int status = 200]) => http.Response.bytes(
        utf8.encode(jsonEncode(body)),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );

  /// What the sender uploaded under [code].
  Map<String, dynamic> sent(String code) => bundles[code]!['data'] as Map<String, dynamic>;

  /// Puts a hand-made bundle on the server, as any signed-in user can.
  String offer(Map<String, dynamic> data, {String code = 'HND234'}) {
    bundles[code] = {'data': data, 'userId': 'user_2'};
    return code;
  }
}

final account = AuthUser(id: 'user_1', email: 'cook@example.com', tier: 'free');

/// Makes [phone] the phone the app is running on, signed in as [user]
/// unless [signedIn] is false.
void turnTo(Phone phone, {bool signedIn = true, AuthUser? user}) {
  phone.use();
  TransferService.instance.setDatabase(phone.db);
  AuthService.instance.debugSetSession(signedIn ? user ?? account : null, signedIn ? 'jwt' : null);
}

/// Runs [body] as the app on [phone], talking to [server].
Future<T> on<T>(
  Phone phone,
  TransferServer server,
  Future<T> Function() body, {
  bool signedIn = true,
  AuthUser? user,
}) {
  turnTo(phone, signedIn: signedIn, user: user);
  return http.runWithClient(body, () => server.client);
}

/// Sends everything on [from], photos that do not fit left behind unasked.
Future<TransferCreateResult> send(TransferServer server, Phone from, {AuthUser? user}) async =>
    (await on<TransferCreateResult?>(from, server, TransferService.instance.createTransfer, user: user))!;

/// The receiving phone is not signed in: receiving needs no account.
Future<TransferClaimResult> receive(TransferServer server, Phone to, String code) =>
    on(to, server, () => TransferService.instance.claimTransfer(code), signedIn: false);

/// Sends everything on [from] and receives it on [to].
Future<TransferClaimResult> transfer(TransferServer server, Phone from, Phone to) async =>
    receive(server, to, (await send(server, from)).code);

/// Why a transfer failed, or null if it did not.
Future<TransferFailure?> failureOf(Future<Object?> attempt) async {
  try {
    await attempt;
    return null;
  } on TransferException catch (e) {
    return e.failure;
  }
}

/// Makes the app on [phone] one that was installed on [day]: everything a
/// fresh install starts out with dates from then.
Future<void> installedOn(Phone phone, DateTime day) async {
  final db = phone.db;
  await db.update(db.cookbooks).write(CookbooksCompanion(createdAt: Value(day)));
  await db.update(db.shoppingLists).write(ShoppingListsCompanion(createdAt: Value(day), updatedAt: Value(day)));
  await db.update(db.categories).write(CategoriesCompanion(createdAt: Value(day)));
  await db.update(db.tags).write(TagsCompanion(createdAt: Value(day)));
  await db.update(db.shoppingCategories).write(ShoppingCategoriesCompanion(createdAt: Value(day)));
}

/// Everything on [phone] the way the released version of the app (1.7.0 and
/// earlier) puts it into a transfer: steps without their header mark or
/// photo, file paths of the sending device in imagePath, no meal colour and
/// no date of the last edit on the small tables.
Future<Map<String, dynamic>> releasedBundle(Phone phone) async {
  final db = phone.db;
  String? iso(DateTime? date) => date?.toUtc().toIso8601String();
  String? cover(String? path) =>
      path != null && File(path).existsSync() ? base64Encode(File(path).readAsBytesSync()) : null;

  return {
    'cookbooks': [
      for (final c in await db.select(db.cookbooks).get())
        {
          'id': c.id, 'name': c.name, 'description': c.description, 'imagePath': c.imagePath,
          'createdAt': iso(c.createdAt), 'updatedAt': iso(c.updatedAt),
        },
    ],
    'recipes': [
      for (final r in await db.select(db.recipes).get())
        {
          'id': r.id, 'cookbookId': r.cookbookId, 'title': r.title, 'description': r.description,
          'servings': r.servings, 'prepTimeMinutes': r.prepTimeMinutes, 'cookTimeMinutes': r.cookTimeMinutes,
          'sourceUrl': r.sourceUrl, 'imagePath': r.imagePath, 'courseId': r.courseId, 'categoryId': r.categoryId,
          'rating': r.rating, 'notes': r.notes, 'nutritionJson': r.nutritionJson, 'isFavorite': r.isFavorite,
          'isPinned': r.isPinned, 'deletedAt': iso(r.deletedAt), 'lastViewedAt': iso(r.lastViewedAt),
          'createdAt': iso(r.createdAt), 'updatedAt': iso(r.updatedAt),
          'imageBase64': cover(r.imagePath),
          'ingredients': [
            for (final i in await phone.ingredientsOf(r.id))
              {
                'id': i.id, 'recipeId': i.recipeId, 'sortOrder': i.sortOrder,
                'amount': i.amount, 'unit': i.unit, 'name': i.name, 'notes': i.notes,
              },
          ],
          'steps': [
            for (final s in await phone.stepsOf(r.id))
              {
                'id': s.id, 'recipeId': s.recipeId, 'sortOrder': s.sortOrder,
                'instruction': s.instruction, 'durationMinutes': s.durationMinutes, 'imagePath': s.imagePath,
              },
          ],
          'recipeTags': [
            for (final tagId in await phone.tagsOf(r.id)) {'tagId': tagId},
          ],
          'sourceLinks': [
            for (final l in await phone.linksOf(r.id))
              {
                'sourceRecipeId': l.sourceRecipeId, 'ingredientId': l.ingredientId,
                'linkedRecipeId': l.linkedRecipeId, 'scale': l.scale, 'sortOrder': l.sortOrder,
                'createdAt': iso(l.createdAt),
              },
          ],
        },
    ],
    'categories': [
      for (final c in await db.select(db.categories).get())
        {
          'id': c.id, 'name': c.name, 'sortOrder': c.sortOrder, 'isDefault': c.isDefault,
          'isHidden': c.isHidden, 'createdAt': iso(c.createdAt),
        },
    ],
    'customCategories': [
      for (final c in await db.select(db.customCategories).get())
        {
          'id': c.id, 'cookbookId': c.cookbookId, 'name': c.name, 'emoji': c.emoji,
          'sortOrder': c.sortOrder, 'createdAt': iso(c.createdAt),
        },
    ],
    'customCourses': [
      for (final c in await db.select(db.customCourses).get())
        {
          'id': c.id, 'cookbookId': c.cookbookId, 'name': c.name, 'emoji': c.emoji,
          'sortOrder': c.sortOrder, 'createdAt': iso(c.createdAt),
        },
    ],
    'tags': [
      for (final t in await db.select(db.tags).get())
        {
          'id': t.id, 'name': t.name, 'color': t.color, 'icon': t.icon, 'sortOrder': t.sortOrder,
          'isBuiltIn': t.isBuiltIn, 'createdAt': iso(t.createdAt),
        },
    ],
    'mealPlans': [
      for (final m in await db.select(db.mealPlans).get())
        {
          'id': m.id, 'date': iso(m.date), 'time': iso(m.time), 'name': m.name, 'mealType': m.mealType,
          'customMeal': m.customMeal, 'recipeId': m.recipeId, 'notes': m.notes,
          'alertEnabled': m.alertEnabled, 'alertSent': m.alertSent,
          'createdAt': iso(m.createdAt), 'updatedAt': iso(m.updatedAt),
        },
    ],
    'shoppingLists': [
      for (final l in await db.select(db.shoppingLists).get())
        {
          'id': l.id, 'name': l.name, 'color': l.color, 'isDefault': l.isDefault,
          'createdAt': iso(l.createdAt), 'updatedAt': iso(l.updatedAt),
        },
    ],
    'shoppingListItems': [
      for (final i in await db.select(db.shoppingListItems).get())
        {
          'id': i.id, 'listId': i.listId, 'name': i.name, 'quantity': i.quantity, 'unit': i.unit,
          'shoppingCategoryId': i.shoppingCategoryId, 'isChecked': i.isChecked, 'isFavorite': i.isFavorite,
          'useCount': i.useCount, 'note': i.note, 'sortOrder': i.sortOrder, 'recipeId': i.recipeId,
          'createdAt': iso(i.createdAt), 'updatedAt': iso(i.updatedAt),
        },
    ],
    'shoppingCategories': [
      for (final c in await db.select(db.shoppingCategories).get())
        {
          'id': c.id, 'name': c.name, 'iconName': c.iconName, 'sortOrder': c.sortOrder,
          'isDefault': c.isDefault, 'isHidden': c.isHidden, 'createdAt': iso(c.createdAt),
        },
    ],
  };
}

Future<void> addRecipe(AppDatabase db, String id, String title, {String cookbookId = 'starter'}) async {
  await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: cookbookId, title: title));
  await db.into(db.ingredients).insert(IngredientsCompanion.insert(
      id: '${id}_ing_0', recipeId: id, sortOrder: 0, name: 'flour', amount: const Value('2'), unit: const Value('cups')));
  await db.into(db.steps).insert(StepsCompanion.insert(id: '${id}_step_0', recipeId: id, sortOrder: 0, instruction: 'Mix.'));
}
