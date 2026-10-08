// What the backup and restore tests share: phones with their own database
// and documents folder, a library that uses everything a backup has to
// carry, and small helpers for building backup files by hand.
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/export_import_service.dart';

const bakingId = 'cookbook_1712345678901';
const categoryId = 'custom_category_1712345600000';
const courseId = 'custom_course_1712345611111';
const holidayTagId = 'tag_1712345699999';
const pieId = '3f2c9a1e-7b1d-4c55-9a1e-0d2f6b7c8a90';
const crustId = '8a44d1c2-11f0-4b6e-b7a3-5c9e2d1f0a11';
const creamId = 'c7e4b2a9-52d3-4f8e-9b61-2a7d9e0c4f33';
const burntId = 'b0d1e2f3-0a1b-4c2d-8e3f-4a5b6c7d8e9f';

const _pathProvider = MethodChannel('plugins.flutter.io/path_provider');

/// The phones of one test file. Call [Phones.install] once in main, then
/// `phones('name')` in a test for a fresh phone that is cleaned up after it.
class Phones {
  Phones._();

  late Directory root;
  final all = <Phone>[];

  static Phones install() {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Every phone in a test is its own in-memory database, on purpose.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final phones = Phones._();
    setUp(() async {
      phones.root = await Directory.systemTemp.createTemp('rsb_backup_');
    });
    tearDown(() async {
      for (final phone in phones.all) {
        await phone.db.close();
      }
      phones.all.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_pathProvider, null);
      await phones.root.delete(recursive: true);
    });
    return phones;
  }

  Phone call(String name) {
    final phone = Phone(root, name);
    all.add(phone);
    return phone;
  }

  /// A full zip backup of a freshly seeded library, made on a phone of its own.
  Future<String> backupZip() async {
    final source = this('old_phone')..use();
    await seedLibrary(source);
    final path = source.file('RecipeSpellbook_Export_2026-10-01.zip');
    await source.service.exportFullZipToPath(path);
    return path;
  }
}

/// One phone: its own database and its own documents folder. The folder
/// sits a few levels below the test's temp directory, so that a restore
/// which climbs out of it still lands where the test can see it and clean
/// it up.
class Phone {
  Phone(Directory root, String name)
      : db = AppDatabase.forTesting(NativeDatabase.memory()),
        home = Directory(p.join(root.path, name, 'sandbox', 'home')) {
    docs.createSync(recursive: true);
    temp.createSync(recursive: true);
    support.createSync(recursive: true);
  }

  final AppDatabase db;
  final Directory home;

  Directory get docs => Directory(p.join(home.path, 'docs'));
  Directory get temp => Directory(p.join(home.path, 'tmp'));

  /// The app's own folder for files the user never sees.
  Directory get support => Directory(p.join(home.path, 'support'));
  Directory get restoredImages => Directory(p.join(docs.path, 'images', 'imported'));
  ExportImportService get service => ExportImportService(db);

  /// Makes this the phone the app is running on.
  void use() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _pathProvider,
      (call) async => switch (call.method) {
        'getTemporaryDirectory' => temp.path,
        'getApplicationSupportDirectory' => support.path,
        _ => docs.path,
      },
    );
  }

  /// A path for a file handed to this phone, such as a backup to restore.
  String file(String name) => p.join(temp.path, name);

  /// Picks [bytes] as a file called [name] in Settings, Import from file.
  Future<ImportResult> pick(String name, List<int> bytes) {
    File(file(name)).writeAsBytesSync(bytes);
    FilePicker.platform = _PickedFile(file(name));
    return service.importFromFile();
  }

  /// Taps Import from file while the picker refuses to open, as it does
  /// when another one is still up.
  Future<ImportResult> pickWhileThePickerIsBusy() {
    FilePicker.platform = _PickedFile(file('never shown'), busy: true);
    return service.importFromFile();
  }

  Future<Recipe> recipeTitled(String title) =>
      (db.select(db.recipes)..where((t) => t.title.equals(title) & t.deletedAt.isNull())).getSingle();

  Future<Cookbook> cookbookNamed(String name) =>
      (db.select(db.cookbooks)..where((t) => t.name.equals(name))).getSingle();

  Future<List<String>> cookbookNames() async =>
      [for (final c in await db.select(db.cookbooks).get()) c.name]..sort();

  Future<List<String>> liveTitles() async => [
        for (final r in await (db.select(db.recipes)..where((t) => t.deletedAt.isNull())).get()) r.title,
      ]..sort();

  Future<List<Ingredient>> ingredientsOf(String recipeId) => (db.select(db.ingredients)
        ..where((t) => t.recipeId.equals(recipeId))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .get();

  Future<List<Step>> stepsOf(String recipeId) => (db.select(db.steps)
        ..where((t) => t.recipeId.equals(recipeId))
        ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
      .get();

  Future<List<RecipeLink>> linksOf(String recipeId) =>
      (db.select(db.recipeLinks)..where((t) => t.sourceRecipeId.equals(recipeId))).get();

  Future<List<String>> tagsOf(String recipeId) async => [
        for (final t in await (db.select(db.recipeTags)..where((t) => t.recipeId.equals(recipeId))).get()) t.tagId,
      ]..sort();
}

/// The file picker, answering with one file as if the user had chosen it.
class _PickedFile extends FilePicker {
  _PickedFile(this.path, {this.busy = false});
  final String path;
  final bool busy;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    if (busy) throw PlatformException(code: 'already_active', message: 'File picker is already active');
    return FilePickerResult([PlatformFile(name: p.basename(path), size: File(path).lengthSync(), path: path)]);
  }
}

/// Bytes that stand in for a photo. The importer only copies them.
Uint8List photo(int seed, [int size = 2048]) {
  final bytes = Uint8List(size);
  bytes.setAll(0, [0xFF, 0xD8, 0xFF, 0xE0]);
  for (var i = 4; i < size; i++) {
    bytes[i] = (i * 31 + seed * 7) & 0xFF;
  }
  return bytes;
}

Uint8List zipOf(Map<String, List<int>> entries) {
  final archive = Archive();
  entries.forEach((name, bytes) => archive.addFile(ArchiveFile(name, bytes.length, bytes)));
  return Uint8List.fromList(ZipEncoder().encode(archive)!);
}

List<int> jsonBytes(Object? data) => utf8.encode(jsonEncode(data));

/// A deep copy, the way a backup arrives after being written to a file.
Map<String, dynamic> throughFile(Map<String, dynamic> data) => jsonDecode(jsonEncode(data)) as Map<String, dynamic>;

/// Every file below [dir] with its size, to tell what a restore wrote.
Map<String, int> filesUnder(Directory dir) => {
      for (final f in dir.listSync(recursive: true).whereType<File>())
        p.relative(f.path, from: dir.path).replaceAll('\\', '/'): f.lengthSync(),
    };

/// A library that uses everything a backup has to carry: a second cookbook
/// with its own category and course, a recipe with photos, section headers,
/// tags, a pin, a link into its own cookbook and one into another, a recipe
/// in the trash, a planned meal and a shopping item made from the recipe.
Future<void> seedLibrary(Phone phone) async {
  final db = phone.db;
  File savedPhoto(String name, int seed) => File(p.join(phone.docs.path, 'photos', name))
    ..createSync(recursive: true)
    ..writeAsBytesSync(photo(seed));
  final pieCover = savedPhoto('pie_cover.jpg', 1);
  final pieStep = savedPhoto('pie_step.jpg', 2);
  final bakingCover = savedPhoto('baking.jpg', 3);

  await db.into(db.cookbooks).insert(CookbooksCompanion.insert(
        id: bakingId,
        name: 'Baking',
        description: const Value('Pies, cakes and breads'),
        imagePath: Value(bakingCover.path),
      ));
  await db.into(db.customCategories).insert(CustomCategoriesCompanion.insert(
      id: categoryId, cookbookId: bakingId, name: 'Thanksgiving', emoji: const Value('🦃')));
  await db.into(db.customCourses).insert(
      CustomCoursesCompanion.insert(id: courseId, cookbookId: bakingId, name: 'Afternoon Tea', emoji: const Value('🫖')));
  await db.into(db.tags).insert(TagsCompanion.insert(
      id: holidayTagId, name: 'Holiday', color: const Value('#AA3300'), sortOrder: const Value(30)));

  Future<void> simpleRecipe(String id, String cookbookId, String title, String ingredient, String step) async {
    await db.into(db.recipes).insert(RecipesCompanion.insert(id: id, cookbookId: cookbookId, title: title));
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
        id: '${id}_ing_0', recipeId: id, sortOrder: 0, name: ingredient, amount: const Value('1'), unit: const Value('cup')));
    await db.into(db.steps).insert(StepsCompanion.insert(id: '${id}_step_0', recipeId: id, sortOrder: 0, instruction: step));
  }

  await simpleRecipe(creamId, 'starter', 'Whipped Cream', 'heavy cream', 'Whip to soft peaks.');
  await simpleRecipe(crustId, bakingId, 'All-Butter Pie Crust', 'all-purpose flour', 'Cut the butter into the flour.');

  await db.into(db.recipes).insert(RecipesCompanion.insert(
        id: pieId,
        cookbookId: bakingId,
        title: 'Deep-Dish Apple Pie',
        description: const Value('Tall, tart and buttery.'),
        servings: const Value('8 slices'),
        prepTimeMinutes: const Value(45),
        cookTimeMinutes: const Value(65),
        sourceUrl: const Value('https://example.com/apple-pie'),
        imagePath: Value(pieCover.path),
        courseId: const Value(courseId),
        categoryId: const Value('dessert,$categoryId'),
        rating: const Value(5),
        notes: const Value('Use a mix of Granny Smith and Honeycrisp.'),
        nutritionJson: const Value('{"calories":3280.0,"calculatedServings":8}'),
        isFavorite: const Value(true),
        isPinned: const Value(true),
        createdAt: Value(DateTime(2024, 3, 5, 18, 30)),
        updatedAt: Value(DateTime(2025, 11, 20, 9)),
        lastViewedAt: Value(DateTime(2026, 9, 1, 12)),
      ));
  const ingredients = <(String, String?, String?, String?)>[
    ('For the crust', null, null, '__header__'),
    ('All-Butter Pie Crust', '1', null, null),
    ('For the filling', null, null, '__header__'),
    ('Granny Smith apples', '3', 'lbs', 'peeled and sliced'),
    ('granulated sugar', '3/4', 'cup', null),
    ('whipped cream', '1', 'cup', 'to serve'),
  ];
  for (var i = 0; i < ingredients.length; i++) {
    await db.into(db.ingredients).insert(IngredientsCompanion.insert(
          id: '${pieId}_ing_$i',
          recipeId: pieId,
          sortOrder: i,
          name: ingredients[i].$1,
          amount: Value(ingredients[i].$2),
          unit: Value(ingredients[i].$3),
          notes: Value(ingredients[i].$4),
        ));
  }
  final steps = <(String, int?, String?, String?)>[
    ('Make the crust', null, '__header__', null),
    ('Roll out the dough and line a deep-dish pan.', 15, null, null),
    ('Toss apples with sugar and fill the crust.', null, null, pieStep.path),
    ('Bake', null, '__header__', null),
    ('Bake at 375F until bubbling.', 65, null, null),
  ];
  for (var i = 0; i < steps.length; i++) {
    await db.into(db.steps).insert(StepsCompanion.insert(
          id: '${pieId}_step_$i',
          recipeId: pieId,
          sortOrder: i,
          instruction: steps[i].$1,
          durationMinutes: Value(steps[i].$2),
          notes: Value(steps[i].$3),
          imagePath: Value(steps[i].$4),
        ));
  }
  await db.into(db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: pieId, tagId: 'tag_family'));
  await db.into(db.recipeTags).insert(RecipeTagsCompanion.insert(recipeId: pieId, tagId: holidayTagId));
  await db.into(db.recipeLinks).insert(
      RecipeLinksCompanion.insert(sourceRecipeId: pieId, ingredientId: '${pieId}_ing_1', linkedRecipeId: crustId));
  await db.into(db.recipeLinks).insert(RecipeLinksCompanion.insert(
      sourceRecipeId: pieId, ingredientId: '${pieId}_ing_5', linkedRecipeId: creamId, scale: const Value(0.5)));

  await db.into(db.recipes).insert(RecipesCompanion.insert(
        id: burntId,
        cookbookId: bakingId,
        title: 'Burnt Experiment',
        deletedAt: Value(DateTime(2026, 9, 25, 8)),
      ));
  await db.into(db.ingredients).insert(
      IngredientsCompanion.insert(id: '${burntId}_ing_0', recipeId: burntId, sortOrder: 0, name: 'charcoal'));

  await db.into(db.mealPlans).insert(MealPlansCompanion.insert(
        id: 'mp_1790000000000',
        date: DateTime(2026, 11, 26),
        recipeId: const Value(pieId),
        cardColor: const Value('rot:120'),
      ));
  await db.into(db.shoppingListItems).insert(ShoppingListItemsCompanion.insert(
        id: 'item_1790000000001',
        listId: 'list_default',
        name: 'Granny Smith apples',
        quantity: const Value('3'),
        unit: const Value('lbs'),
        recipeId: const Value(pieId),
      ));
}
