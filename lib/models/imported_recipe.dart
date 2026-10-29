/// Unified recipe model for all import sources.
/// Replaces both ScrapedRecipe (recipe_scraper_service) and ParsedRecipe (recipe_parser).
class ImportedRecipe {
  String title;
  String? description;
  String? imageUrl;
  String? imageData; // Base64 encoded (from Paprika, etc.)
  String? imagePath; // Local file path (from PDF page extraction, etc.)
  int? prepTimeMinutes;
  int? cookTimeMinutes;
  String? servings;
  List<String> ingredients;
  List<String> instructions;
  String? sourceUrl;
  String? notes;
  List<String>? tags;
  String? cuisine;
  String? suggestedCourse;
  String? suggestedCategory;
  int? rating;
  String? nutritionJson; // The app's own nutrition format (from a scanned product)

  // From the app's own export, which holds every row the way the app stores
  // it. The rows, when set, are what gets saved, exactly as they are. The
  // ingredients and instructions above are then the same lines to read.
  String? exportId; // The id of the recipe in the file, which links between its recipes go by
  bool? isFavorite;
  Map<String, String?>? tagsById; // Its tags by id, each with its name where the file gives it
  String? courseName; // The name of a course of its own that suggestedCourse is the id of
  String? categoryName; // The same for a category of its own
  List<ImportedIngredient>? ingredientRows;
  List<ImportedStep>? stepRows;

  // Bulk import tracking
  String? sourceApp; // "paprika", "recipekeeper", "crouton", etc.
  String? sourceFile; // Original filename

  // OCR quality metadata
  double? parseConfidence; // 0.0 - 1.0 confidence score from OCR/parsing
  String? rawOcrText; // Original OCR text

  ImportedRecipe({
    required this.title,
    this.description,
    this.imageUrl,
    this.imageData,
    this.imagePath,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    required this.ingredients,
    required this.instructions,
    this.sourceUrl,
    this.notes,
    this.tags,
    this.cuisine,
    this.suggestedCourse,
    this.suggestedCategory,
    this.rating,
    this.nutritionJson,
    this.exportId,
    this.isFavorite,
    this.tagsById,
    this.courseName,
    this.categoryName,
    this.ingredientRows,
    this.stepRows,
    this.sourceApp,
    this.sourceFile,
    this.parseConfidence,
    this.rawOcrText,
  });

  /// Convert to the Map format expected by RecipeEditScreen's importedData param.
  Map<String, dynamic> toImportData() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageData': imageData,
      'imagePath': imagePath,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'sourceUrl': sourceUrl,
      'notes': notes,
      'courseId': suggestedCourse,
      'categoryId': suggestedCategory,
      'tags': tags,
      'cuisine': cuisine,
      'rating': rating,
    };
  }

  /// Create from a normalized map (Paprika, RecipeKeeper, etc.)
  factory ImportedRecipe.fromMap(Map<String, dynamic> map) {
    return ImportedRecipe(
      title: map['title']?.toString() ?? 'Imported Recipe',
      description: map['description']?.toString(),
      imageUrl: map['imageUrl']?.toString(),
      imageData: map['imageData']?.toString(),
      prepTimeMinutes: _toInt(map['prepTime'] ?? map['prepTimeMinutes']),
      cookTimeMinutes: _toInt(map['cookTime'] ?? map['cookTimeMinutes']),
      servings: map['servings']?.toString(),
      ingredients: _toStringList(map['ingredients']),
      instructions: _toStringList(map['instructions']),
      sourceUrl: map['sourceUrl']?.toString(),
      notes: map['notes']?.toString(),
      tags: map['tags'] is List ? List<String>.from(map['tags']) : null,
      cuisine: map['cuisine']?.toString(),
      rating: _toInt(map['rating']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.round();
    return null;
  }

  static List<String> _toStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    }
    if (data is String) {
      return data.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    }
    return [];
  }
}

/// An ingredient that arrives already taken apart, the way the app stores it:
/// the amount as it was written, the unit, the name and a note. A section
/// heading among the ingredients has [isHeading] set and only a name.
class ImportedIngredient {
  final String name;
  final String? amount;
  final String? unit;
  final String? notes;
  final bool isHeading;

  /// The recipes this ingredient stands for ("1 Pizza Dough"), each by its
  /// [ImportedRecipe.exportId] and with how much of it goes in.
  final List<({String recipeId, double scale})> links;

  const ImportedIngredient({
    required this.name,
    this.amount,
    this.unit,
    this.notes,
    this.isHeading = false,
    this.links = const [],
  });

  /// The row on one line, as in "2 cup passata (or crushed tomatoes)". A
  /// heading is its title and no more.
  String get line => isHeading
      ? name
      : [
          if (amount != null && amount!.isNotEmpty) amount!,
          if (unit != null && unit!.isNotEmpty) unit!,
          name,
          if (notes != null && notes!.isNotEmpty) '($notes)',
        ].join(' ');
}

/// A step that arrives the way the app stores it: with its timer and its
/// photo. A section heading among the steps has [isHeading] set.
class ImportedStep {
  final String instruction;
  final int? durationMinutes;
  final String? imageData; // Base64 encoded
  final bool isHeading;

  const ImportedStep({required this.instruction, this.durationMinutes, this.imageData, this.isHeading = false});
}