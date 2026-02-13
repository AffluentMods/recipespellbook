/// Unified recipe model for all import sources.
/// Replaces both ScrapedRecipe (recipe_scraper_service) and ParsedRecipe (recipe_parser).
class ImportedRecipe {
  String title;
  String? description;
  String? imageUrl;
  String? imageData; // Base64 encoded (from Paprika, etc.)
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

  // Bulk import tracking
  String? sourceApp; // "paprika", "recipekeeper", "crouton", etc.
  String? sourceFile; // Original filename

  ImportedRecipe({
    required this.title,
    this.description,
    this.imageUrl,
    this.imageData,
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
    this.sourceApp,
    this.sourceFile,
  });

  /// Convert to the Map format expected by RecipeEditScreen's importedData param.
  Map<String, dynamic> toImportData() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageData': imageData,
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