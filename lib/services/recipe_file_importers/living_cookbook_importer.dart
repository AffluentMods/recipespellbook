import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../models/imported_recipe.dart';
import 'import_support.dart';
import 'loose_xml.dart';

/// Imports recipes from Living Cookbook (.fdx, .fdxz) files.
///
/// Format: XML file (FDX = Food Data Exchange). A recipe's own values are
/// attributes of its element, and its ingredients and steps are children:
/// ```xml
/// <fdx Source="Living Cookbook 4.0" FileVersion="1.1">
///   <CookbookChapters>
///     <CookbookChapter Name="Desserts" ID="7" />
///   </CookbookChapters>
///   <Recipes>
///     <Recipe Name="..." Servings="6" Yield="1 pan" PreparationTime="15"
///         CookingTime="30" RecipeTypes="Desserts, Fruit" Source="..."
///         WebPage="http://..." Comments="..." CookbookChapterID="7">
///       <RecipeIngredients>
///         <RecipeIngredient Quantity="4" Unit="cups" Ingredient="apples" Heading="N" />
///         <RecipeIngredient Ingredient="Topping" Heading="Y" />
///       </RecipeIngredients>
///       <RecipeProcedures>
///         <RecipeProcedure Heading="N">
///           <ProcedureText>step text</ProcedureText>
///         </RecipeProcedure>
///       </RecipeProcedures>
///       <RecipeTips><RecipeTip>...</RecipeTip></RecipeTips>
///       <RecipeAuthorNotes><RecipeAuthorNote>...</RecipeAuthorNote></RecipeAuthorNotes>
///       <RecipeImage>the photo as base64, or FileName="photo.jpg"</RecipeImage>
///     </Recipe>
///   </Recipes>
/// </fdx>
/// ```
/// Times are in minutes. A .fdxz is a zip of that document, named Data.xml,
/// with the photos it refers to by file name.
///
/// A layout that keeps every value in a child element is read as well:
/// ```xml
/// <fdx:Recipe>
///   <fdx:RecipeName>...</fdx:RecipeName>
///   <fdx:RecipeDescription>...</fdx:RecipeDescription>
///   <fdx:Servings>...</fdx:Servings>
///   <fdx:PreparationTime>PT30M</fdx:PreparationTime>
///   <fdx:CookTime>PT1H</fdx:CookTime>
///   <fdx:IngredientList>
///     <fdx:Ingredient>
///       <fdx:IngredientQuantity>2</fdx:IngredientQuantity>
///       <fdx:IngredientUnit>cups</fdx:IngredientUnit>
///       <fdx:IngredientItem>flour</fdx:IngredientItem>
///       <fdx:IngredientPreparation>sifted</fdx:IngredientPreparation>
///     </fdx:Ingredient>
///   </fdx:IngredientList>
///   <fdx:ProcedureList>
///     <fdx:ProcedureText>step text</fdx:ProcedureText>
///   </fdx:ProcedureList>
///   <fdx:RecipeNotes>...</fdx:RecipeNotes>
///   <fdx:RecipeSource>...</fdx:RecipeSource>
///   <fdx:RecipeCategory>...</fdx:RecipeCategory>
///   <fdx:Rating>4</fdx:Rating>
/// </fdx:Recipe>
/// ```
/// Element names are matched with or without the fdx: prefix.
class LivingCookbookImporter {
  LivingCookbookImporter._();

  /// Whether [content] is a Living Cookbook document.
  static bool looksLikeFdx(String content) =>
      _fdxStart.hasMatch(content.length > 4096 ? content.substring(0, 4096) : content);

  static final _fdxStart = RegExp(r'<fdx[\s:>]', caseSensitive: false);

  /// Parse a Living Cookbook .fdx or .xml file.
  ///
  /// [photo] finds the pictures a .fdxz archive carries next to the document.
  static List<ImportedRecipe> import_(
    String content,
    String filename, {
    ImportPhotoLookup? photo,
  }) {
    final recipes = <ImportedRecipe>[];
    final document = LooseXml.parse(content);

    // A recipe names its chapter ("Desserts") by id.
    final chapters = <String, String>{};
    for (final chapter in document.all('CookbookChapter')) {
      final id = chapter.attribute('ID');
      final name = chapter.attribute('Name');
      if (id != null && name != null) chapters[id] = name;
    }

    // A recipe the file stops inside holds only part of itself and is left out.
    for (final element in document.whole('Recipe')) {
      try {
        final recipe = element.attribute('Name') != null
            ? _parseRecipe(element, filename, chapters, photo)
            : _parseElementRecipe(element, filename);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {}
    }

    return recipes;
  }

  /// Parse a .fdxz file: a zip holding the document and the recipes' photos.
  static Future<List<ImportedRecipe>> importFdxz(
    Uint8List bytes,
    String filename,
  ) async {
    // Not a zip: a plain .fdx that was given the .fdxz name is read as it is.
    if (!ImportSupport.isZip(bytes)) {
      return import_(ImportSupport.decodeText(bytes), filename);
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(_damaged);
    }

    // Living Cookbook names the document Data.xml. An archive put together
    // by hand may hold one or more .fdx files instead, and all of them are read.
    final named = <ArchiveFile>[];
    final others = <ArchiveFile>[];
    for (final file in archive.files) {
      final name = file.name.toLowerCase();
      if (!file.isFile || !(name.endsWith('.xml') || name.endsWith('.fdx'))) continue;
      (name == 'data.xml' || name.endsWith('/data.xml') ? named : others).add(file);
    }

    final photo = ImportSupport.photosIn(archive);
    final recipes = <ImportedRecipe>[];
    var documents = 0;
    var unreadable = false;
    for (final files in [named, others]) {
      if (documents > 0) break;
      for (final file in files) {
        final String content;
        try {
          content = ImportSupport.decodeText(file.content as List<int>);
        } catch (_) {
          // The archive lists the file but its data does not unpack.
          unreadable = true;
          continue;
        }
        if (!looksLikeFdx(content)) continue;
        documents++;
        recipes.addAll(import_(content, filename, photo: photo));
      }
    }
    if (documents == 0) {
      throw FormatException(
          unreadable ? _damaged : 'This .fdxz file does not contain a Living Cookbook document.');
    }
    return recipes;
  }

  static const _damaged =
      'This Living Cookbook file is damaged or incomplete. Export it again and retry.';

  /// A recipe whose values are attributes of its element.
  static ImportedRecipe _parseRecipe(
    XmlElement recipe,
    String filename,
    Map<String, String> chapters,
    ImportPhotoLookup? photo,
  ) {
    // Ingredients. A heading row ("Topping") has no quantity of its own.
    final ingredients = <String>[];
    for (final row in recipe.all('RecipeIngredient')) {
      final name = row.attribute('Ingredient');
      if (_isYes(row.attribute('Heading'))) {
        if (name != null) ingredients.add(_heading(name));
        continue;
      }
      final line = [row.attribute('Quantity'), row.attribute('Unit'), name].nonNulls.join(' ');
      if (line.isNotEmpty) ingredients.add(line);
    }

    // Instructions/Procedures
    final instructions = <String>[];
    for (final procedure in recipe.all('RecipeProcedure')) {
      final text = procedure.textOf('ProcedureText');
      if (text == null) continue;
      instructions.add(_isYes(procedure.attribute('Heading')) ? _heading(text) : text);
    }
    if (instructions.isEmpty) {
      for (final procedure in recipe.all('ProcedureText')) {
        final text = procedure.text.trim();
        if (text.isNotEmpty) instructions.add(text);
      }
    }

    // Metadata
    final servings = recipe.attribute('Servings');
    final made = recipe.attribute('Yield');
    final prepTime = _parseTime(recipe.attribute('PreparationTime'));
    var cookTime = _parseTime(recipe.attribute('CookingTime'));
    final readyIn = _parseTime(recipe.attribute('ReadyInTime'));
    if (cookTime == null && readyIn != null && readyIn > (prepTime ?? 0)) {
      cookTime = readyIn - (prepTime ?? 0);
    }

    // The app's source field holds a web address or a citation. The web
    // page wins, and the named source then goes to the notes.
    final webPage = recipe.attribute('WebPage');
    var source = recipe.attribute('Source');
    final page = recipe.attribute('SourcePageNumber');
    if (source != null && page != null) source = '$source, p. $page';
    final author = recipe.attribute('Author');
    final copyright = recipe.attribute('Copyright');

    final credits = <String>[
      if (author != null) 'Recipe by $author',
      if (webPage != null && source != null) 'Source: $source',
      if (copyright != null) 'Copyright: $copyright',
      if (servings != null && made != null) 'Yield: $made',
    ];
    final notes = <String>[
      for (final note in recipe.all('RecipeAuthorNote')) note.text.trim(),
      for (final tip in recipe.all('RecipeTip')) tip.text.trim(),
      credits.join('\n'),
    ].where((n) => n.isNotEmpty).join('\n\n');

    // Categories/tags
    final tags = _tags([
      ...(recipe.attribute('RecipeTypes') ?? '').split(','),
      chapters[recipe.attribute('CookbookChapterID')] ?? '',
    ]);

    return ImportedRecipe(
      title: recipe.attribute('Name')!,
      description: recipe.attribute('Comments'),
      ingredients: ingredients,
      instructions: instructions,
      servings: servings ?? made,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      sourceUrl: webPage ?? source,
      notes: notes.isEmpty ? null : notes,
      tags: tags.isEmpty ? null : tags,
      suggestedCourse: ImportSupport.courseFor(tags),
      imageData: _photoOf(recipe, photo),
      sourceApp: 'livingcookbook',
      sourceFile: filename,
    );
  }

  /// The recipe's photo as base64: written into the document, or a file of
  /// the .fdxz archive that the document names.
  static String? _photoOf(XmlElement recipe, ImportPhotoLookup? photo) {
    for (final image in recipe.all('RecipeImage')) {
      final inline = image.text.replaceAll(_whitespace, '');
      // Anything this small is a placeholder, not a photo.
      if (inline.length * 3 ~/ 4 > 1024 && _base64.hasMatch(inline)) return inline;
      final name = image.attribute('FileName');
      final bytes = (name == null || photo == null) ? null : photo(name);
      if (bytes != null) return base64Encode(bytes);
    }
    return null;
  }

  static final _whitespace = RegExp(r'\s+');
  static final _base64 = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
  static final _listSeparator = RegExp(r'[,;]');

  static bool _isYes(String? value) => value != null && value.toUpperCase() == 'Y';

  /// A section heading in the form the rest of the app recognises.
  static String _heading(String text) => text.endsWith(':') ? text : '$text:';

  /// The names as tags: blanks left out, and each one once however it is
  /// capitalised.
  static List<String> _tags(Iterable<String> names) {
    final seen = <String>{};
    return [
      for (final name in names.map((n) => n.trim()))
        if (name.isNotEmpty && seen.add(name.toLowerCase())) name,
    ];
  }

  /// A recipe whose values are child elements.
  static ImportedRecipe? _parseElementRecipe(XmlElement recipe, String filename) {
    final title = recipe.textOf('RecipeName') ?? recipe.textOf('Name');
    if (title == null) return null;

    // Ingredients
    final ingredients = <String>[];
    for (final ingredient in recipe.all('Ingredient')) {
      final qty = ingredient.textOf('IngredientQuantity') ?? ingredient.textOf('Quantity') ?? '';
      final unit = ingredient.textOf('IngredientUnit') ?? ingredient.textOf('Unit') ?? '';
      final item = ingredient.textOf('IngredientItem') ??
          ingredient.textOf('Item') ??
          ingredient.textOf('Name') ??
          '';
      final prep =
          ingredient.textOf('IngredientPreparation') ?? ingredient.textOf('Preparation') ?? '';

      final parts = [qty, unit, item, if (prep.isNotEmpty) '($prep)']
          .where((s) => s.isNotEmpty)
          .join(' ');
      if (parts.isNotEmpty) ingredients.add(parts);
    }

    // If no structured ingredients, try raw text
    if (ingredients.isEmpty) {
      ingredients.addAll(_lines(recipe.textOf('IngredientList') ?? recipe.textOf('Ingredients')));
    }

    // Instructions/Procedures
    final instructions = <String>[];
    for (final procedure in recipe.all('ProcedureText')) {
      final text = procedure.text.trim();
      if (text.isNotEmpty) instructions.add(text);
    }

    // If no structured procedures, try raw text
    if (instructions.isEmpty) {
      instructions.addAll(_lines(recipe.textOf('ProcedureList') ??
          recipe.textOf('Procedures') ??
          recipe.textOf('Directions')));
    }

    // Metadata
    final ratingStr = recipe.textOf('Rating');
    final rating = ratingStr != null ? int.tryParse(ratingStr) : null;

    // Categories/tags
    final category = recipe.textOf('RecipeCategory') ?? recipe.textOf('Category') ?? '';
    final tags = _tags(category.split(_listSeparator));

    return ImportedRecipe(
      title: title,
      description: recipe.textOf('RecipeDescription') ?? recipe.textOf('Description'),
      ingredients: ingredients,
      instructions: instructions,
      servings: recipe.textOf('Servings') ?? recipe.textOf('Yield'),
      prepTimeMinutes:
          _parseTime(recipe.textOf('PreparationTime') ?? recipe.textOf('PrepTime')),
      cookTimeMinutes: _parseTime(recipe.textOf('CookTime')),
      sourceUrl: recipe.textOf('RecipeSource') ?? recipe.textOf('Source'),
      notes: recipe.textOf('RecipeNotes') ?? recipe.textOf('Notes'),
      tags: tags.isEmpty ? null : tags,
      suggestedCourse: ImportSupport.courseFor(tags),
      rating: rating,
      sourceApp: 'livingcookbook',
      sourceFile: filename,
    );
  }

  static Iterable<String> _lines(String? text) =>
      (text ?? '').split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);

  static final _clockTime = RegExp(r'^(\d{1,3}):(\d{1,2})(?::\d{1,2})?$');
  static final _isoTime = RegExp(r'^pt(?:(\d+)h)?(?:(\d+)m)?(?:\d+s)?$');
  static final _hours = RegExp(r'(\d+)\s*(?:hr|hour)s?');
  static final _mins = RegExp(r'(\d+)\s*(?:min|minute)s?');

  /// Parse a time: minutes as Living Cookbook writes them ("90"), "1:30", an
  /// ISO 8601 duration ("PT1H30M") or words ("1 hr 30 min"). Null when the
  /// time is missing or zero, which is how one that was never set is written.
  static int? _parseTime(String? time) {
    // A time is a few words at most. Anything much longer is not one.
    if (time == null || time.isEmpty || time.length > 200) return null;
    final t = time.toLowerCase().trim();

    int minutes = 0;
    final plain = int.tryParse(t);
    final clock = _clockTime.firstMatch(t);
    final iso = _isoTime.firstMatch(t);
    if (plain != null) {
      minutes = plain;
    } else if (clock != null) {
      minutes = int.parse(clock.group(1)!) * 60 + int.parse(clock.group(2)!);
    } else if (iso != null) {
      final hours = int.tryParse(iso.group(1) ?? '') ?? 0;
      final mins = int.tryParse(iso.group(2) ?? '') ?? 0;
      minutes = hours * 60 + mins;
    } else {
      final hrMatch = _hours.firstMatch(t);
      if (hrMatch != null) minutes += (int.tryParse(hrMatch.group(1)!) ?? 0) * 60;
      final minMatch = _mins.firstMatch(t);
      if (minMatch != null) minutes += int.tryParse(minMatch.group(1)!) ?? 0;
    }

    return minutes > 0 ? minutes : null;
  }
}
