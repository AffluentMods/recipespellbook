/// Nutrition data model for recipes
/// This is stored as JSON in the recipe table
/// Expanded to include vitamins and minerals from USDA data
class NutritionData {
  // === MACRONUTRIENTS ===
  final double? calories;
  final double? protein; // grams
  final double? carbohydrates; // grams
  final double? fat; // grams
  final double? fiber; // grams
  final double? sugar; // grams
  final double? saturatedFat; // grams
  final double? transFat; // grams
  final double? monounsaturatedFat; // grams
  final double? polyunsaturatedFat; // grams

  // === MINERALS ===
  final double? sodium; // mg
  final double? potassium; // mg
  final double? calcium; // mg
  final double? iron; // mg
  final double? magnesium; // mg
  final double? phosphorus; // mg
  final double? zinc; // mg
  final double? copper; // mg
  final double? manganese; // mg
  final double? selenium; // mcg

  // === VITAMINS ===
  final double? vitaminA; // mcg RAE
  final double? vitaminC; // mg
  final double? vitaminD; // mcg
  final double? vitaminE; // mg
  final double? vitaminK; // mcg
  final double? vitaminB1; // mg (Thiamin)
  final double? vitaminB2; // mg (Riboflavin)
  final double? vitaminB3; // mg (Niacin)
  final double? vitaminB5; // mg (Pantothenic Acid)
  final double? vitaminB6; // mg
  final double? vitaminB12; // mcg
  final double? folate; // mcg DFE
  final double? choline; // mg

  // === OTHER ===
  final double? cholesterol; // mg
  final double? water; // grams
  final String? servingSize; // e.g., "1 cup", "100g"

  // === METADATA ===
  final bool? isEstimated; // True if calculated from USDA, false if manually entered
  final DateTime? calculatedAt; // When nutrition was last calculated
  final int? matchedIngredients; // How many ingredients were matched to USDA
  final int? totalIngredients; // Total ingredients in recipe
  final int? calculatedServings; // Servings count when nutrition was calculated (values are TOTAL when set)

  const NutritionData({
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.fiber,
    this.sugar,
    this.saturatedFat,
    this.transFat,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.sodium,
    this.potassium,
    this.calcium,
    this.iron,
    this.magnesium,
    this.phosphorus,
    this.zinc,
    this.copper,
    this.manganese,
    this.selenium,
    this.vitaminA,
    this.vitaminC,
    this.vitaminD,
    this.vitaminE,
    this.vitaminK,
    this.vitaminB1,
    this.vitaminB2,
    this.vitaminB3,
    this.vitaminB5,
    this.vitaminB6,
    this.vitaminB12,
    this.folate,
    this.choline,
    this.cholesterol,
    this.water,
    this.servingSize,
    this.isEstimated,
    this.calculatedAt,
    this.matchedIngredients,
    this.totalIngredients,
    this.calculatedServings,
  });

  bool get hasAnyData =>
      calories != null ||
          protein != null ||
          carbohydrates != null ||
          fat != null ||
          fiber != null ||
          sugar != null ||
          sodium != null ||
          cholesterol != null;

  bool get hasVitamins =>
      vitaminA != null ||
          vitaminC != null ||
          vitaminD != null ||
          vitaminE != null ||
          vitaminK != null ||
          vitaminB1 != null ||
          vitaminB2 != null ||
          vitaminB3 != null ||
          vitaminB5 != null ||
          vitaminB6 != null ||
          vitaminB12 != null ||
          folate != null ||
          choline != null;

  bool get hasMinerals =>
      calcium != null ||
          iron != null ||
          magnesium != null ||
          phosphorus != null ||
          potassium != null ||
          zinc != null ||
          copper != null ||
          manganese != null ||
          selenium != null;

  /// Percentage of ingredients that were matched for calculation
  double? get matchPercentage {
    if (matchedIngredients == null || totalIngredients == null || totalIngredients == 0) {
      return null;
    }
    return (matchedIngredients! / totalIngredients!) * 100;
  }

  /// Create from JSON map (stored in database)
  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      // Macros
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbohydrates: (json['carbohydrates'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      saturatedFat: (json['saturatedFat'] as num?)?.toDouble(),
      transFat: (json['transFat'] as num?)?.toDouble(),
      monounsaturatedFat: (json['monounsaturatedFat'] as num?)?.toDouble(),
      polyunsaturatedFat: (json['polyunsaturatedFat'] as num?)?.toDouble(),
      // Minerals
      sodium: (json['sodium'] as num?)?.toDouble(),
      potassium: (json['potassium'] as num?)?.toDouble(),
      calcium: (json['calcium'] as num?)?.toDouble(),
      iron: (json['iron'] as num?)?.toDouble(),
      magnesium: (json['magnesium'] as num?)?.toDouble(),
      phosphorus: (json['phosphorus'] as num?)?.toDouble(),
      zinc: (json['zinc'] as num?)?.toDouble(),
      copper: (json['copper'] as num?)?.toDouble(),
      manganese: (json['manganese'] as num?)?.toDouble(),
      selenium: (json['selenium'] as num?)?.toDouble(),
      // Vitamins
      vitaminA: (json['vitaminA'] as num?)?.toDouble(),
      vitaminC: (json['vitaminC'] as num?)?.toDouble(),
      vitaminD: (json['vitaminD'] as num?)?.toDouble(),
      vitaminE: (json['vitaminE'] as num?)?.toDouble(),
      vitaminK: (json['vitaminK'] as num?)?.toDouble(),
      vitaminB1: (json['vitaminB1'] as num?)?.toDouble(),
      vitaminB2: (json['vitaminB2'] as num?)?.toDouble(),
      vitaminB3: (json['vitaminB3'] as num?)?.toDouble(),
      vitaminB5: (json['vitaminB5'] as num?)?.toDouble(),
      vitaminB6: (json['vitaminB6'] as num?)?.toDouble(),
      vitaminB12: (json['vitaminB12'] as num?)?.toDouble(),
      folate: (json['folate'] as num?)?.toDouble(),
      choline: (json['choline'] as num?)?.toDouble(),
      // Other
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      water: (json['water'] as num?)?.toDouble(),
      servingSize: json['servingSize'] as String?,
      // Metadata
      isEstimated: json['isEstimated'] as bool?,
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.tryParse(json['calculatedAt'] as String)
          : null,
      matchedIngredients: json['matchedIngredients'] as int?,
      totalIngredients: json['totalIngredients'] as int?,
      calculatedServings: json['calculatedServings'] as int?,
    );
  }

  /// Convert to JSON map for database storage
  Map<String, dynamic> toJson() {
    return {
      // Macros
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbohydrates != null) 'carbohydrates': carbohydrates,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (sugar != null) 'sugar': sugar,
      if (saturatedFat != null) 'saturatedFat': saturatedFat,
      if (transFat != null) 'transFat': transFat,
      if (monounsaturatedFat != null) 'monounsaturatedFat': monounsaturatedFat,
      if (polyunsaturatedFat != null) 'polyunsaturatedFat': polyunsaturatedFat,
      // Minerals
      if (sodium != null) 'sodium': sodium,
      if (potassium != null) 'potassium': potassium,
      if (calcium != null) 'calcium': calcium,
      if (iron != null) 'iron': iron,
      if (magnesium != null) 'magnesium': magnesium,
      if (phosphorus != null) 'phosphorus': phosphorus,
      if (zinc != null) 'zinc': zinc,
      if (copper != null) 'copper': copper,
      if (manganese != null) 'manganese': manganese,
      if (selenium != null) 'selenium': selenium,
      // Vitamins
      if (vitaminA != null) 'vitaminA': vitaminA,
      if (vitaminC != null) 'vitaminC': vitaminC,
      if (vitaminD != null) 'vitaminD': vitaminD,
      if (vitaminE != null) 'vitaminE': vitaminE,
      if (vitaminK != null) 'vitaminK': vitaminK,
      if (vitaminB1 != null) 'vitaminB1': vitaminB1,
      if (vitaminB2 != null) 'vitaminB2': vitaminB2,
      if (vitaminB3 != null) 'vitaminB3': vitaminB3,
      if (vitaminB5 != null) 'vitaminB5': vitaminB5,
      if (vitaminB6 != null) 'vitaminB6': vitaminB6,
      if (vitaminB12 != null) 'vitaminB12': vitaminB12,
      if (folate != null) 'folate': folate,
      if (choline != null) 'choline': choline,
      // Other
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (water != null) 'water': water,
      if (servingSize != null) 'servingSize': servingSize,
      // Metadata
      if (isEstimated != null) 'isEstimated': isEstimated,
      if (calculatedAt != null) 'calculatedAt': calculatedAt!.toIso8601String(),
      if (matchedIngredients != null) 'matchedIngredients': matchedIngredients,
      if (totalIngredients != null) 'totalIngredients': totalIngredients,
      if (calculatedServings != null) 'calculatedServings': calculatedServings,
    };
  }

  /// Create a copy with modified values
  NutritionData copyWith({
    double? calories,
    double? protein,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sugar,
    double? saturatedFat,
    double? transFat,
    double? monounsaturatedFat,
    double? polyunsaturatedFat,
    double? sodium,
    double? potassium,
    double? calcium,
    double? iron,
    double? magnesium,
    double? phosphorus,
    double? zinc,
    double? copper,
    double? manganese,
    double? selenium,
    double? vitaminA,
    double? vitaminC,
    double? vitaminD,
    double? vitaminE,
    double? vitaminK,
    double? vitaminB1,
    double? vitaminB2,
    double? vitaminB3,
    double? vitaminB5,
    double? vitaminB6,
    double? vitaminB12,
    double? folate,
    double? choline,
    double? cholesterol,
    double? water,
    String? servingSize,
    bool? isEstimated,
    DateTime? calculatedAt,
    int? matchedIngredients,
    int? totalIngredients,
    int? calculatedServings,
  }) {
    return NutritionData(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      transFat: transFat ?? this.transFat,
      monounsaturatedFat: monounsaturatedFat ?? this.monounsaturatedFat,
      polyunsaturatedFat: polyunsaturatedFat ?? this.polyunsaturatedFat,
      sodium: sodium ?? this.sodium,
      potassium: potassium ?? this.potassium,
      calcium: calcium ?? this.calcium,
      iron: iron ?? this.iron,
      magnesium: magnesium ?? this.magnesium,
      phosphorus: phosphorus ?? this.phosphorus,
      zinc: zinc ?? this.zinc,
      copper: copper ?? this.copper,
      manganese: manganese ?? this.manganese,
      selenium: selenium ?? this.selenium,
      vitaminA: vitaminA ?? this.vitaminA,
      vitaminC: vitaminC ?? this.vitaminC,
      vitaminD: vitaminD ?? this.vitaminD,
      vitaminE: vitaminE ?? this.vitaminE,
      vitaminK: vitaminK ?? this.vitaminK,
      vitaminB1: vitaminB1 ?? this.vitaminB1,
      vitaminB2: vitaminB2 ?? this.vitaminB2,
      vitaminB3: vitaminB3 ?? this.vitaminB3,
      vitaminB5: vitaminB5 ?? this.vitaminB5,
      vitaminB6: vitaminB6 ?? this.vitaminB6,
      vitaminB12: vitaminB12 ?? this.vitaminB12,
      folate: folate ?? this.folate,
      choline: choline ?? this.choline,
      cholesterol: cholesterol ?? this.cholesterol,
      water: water ?? this.water,
      servingSize: servingSize ?? this.servingSize,
      isEstimated: isEstimated ?? this.isEstimated,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      matchedIngredients: matchedIngredients ?? this.matchedIngredients,
      totalIngredients: totalIngredients ?? this.totalIngredients,
      calculatedServings: calculatedServings ?? this.calculatedServings,
    );
  }

  /// Scale nutrition values by a factor (for serving adjustments)
  NutritionData scaled(double factor) {
    if (factor == 1.0) return this;
    return NutritionData(
      // Macros
      calories: calories != null ? calories! * factor : null,
      protein: protein != null ? protein! * factor : null,
      carbohydrates: carbohydrates != null ? carbohydrates! * factor : null,
      fat: fat != null ? fat! * factor : null,
      fiber: fiber != null ? fiber! * factor : null,
      sugar: sugar != null ? sugar! * factor : null,
      saturatedFat: saturatedFat != null ? saturatedFat! * factor : null,
      transFat: transFat != null ? transFat! * factor : null,
      monounsaturatedFat: monounsaturatedFat != null ? monounsaturatedFat! * factor : null,
      polyunsaturatedFat: polyunsaturatedFat != null ? polyunsaturatedFat! * factor : null,
      // Minerals
      sodium: sodium != null ? sodium! * factor : null,
      potassium: potassium != null ? potassium! * factor : null,
      calcium: calcium != null ? calcium! * factor : null,
      iron: iron != null ? iron! * factor : null,
      magnesium: magnesium != null ? magnesium! * factor : null,
      phosphorus: phosphorus != null ? phosphorus! * factor : null,
      zinc: zinc != null ? zinc! * factor : null,
      copper: copper != null ? copper! * factor : null,
      manganese: manganese != null ? manganese! * factor : null,
      selenium: selenium != null ? selenium! * factor : null,
      // Vitamins
      vitaminA: vitaminA != null ? vitaminA! * factor : null,
      vitaminC: vitaminC != null ? vitaminC! * factor : null,
      vitaminD: vitaminD != null ? vitaminD! * factor : null,
      vitaminE: vitaminE != null ? vitaminE! * factor : null,
      vitaminK: vitaminK != null ? vitaminK! * factor : null,
      vitaminB1: vitaminB1 != null ? vitaminB1! * factor : null,
      vitaminB2: vitaminB2 != null ? vitaminB2! * factor : null,
      vitaminB3: vitaminB3 != null ? vitaminB3! * factor : null,
      vitaminB5: vitaminB5 != null ? vitaminB5! * factor : null,
      vitaminB6: vitaminB6 != null ? vitaminB6! * factor : null,
      vitaminB12: vitaminB12 != null ? vitaminB12! * factor : null,
      folate: folate != null ? folate! * factor : null,
      choline: choline != null ? choline! * factor : null,
      // Other
      cholesterol: cholesterol != null ? cholesterol! * factor : null,
      water: water != null ? water! * factor : null,
      servingSize: servingSize,
      // Metadata (not scaled)
      isEstimated: isEstimated,
      calculatedAt: calculatedAt,
      matchedIngredients: matchedIngredients,
      totalIngredients: totalIngredients,
      calculatedServings: calculatedServings,
    );
  }

  /// Add two nutrition data objects together
  NutritionData operator +(NutritionData other) {
    return NutritionData(
      calories: _addNullable(calories, other.calories),
      protein: _addNullable(protein, other.protein),
      carbohydrates: _addNullable(carbohydrates, other.carbohydrates),
      fat: _addNullable(fat, other.fat),
      fiber: _addNullable(fiber, other.fiber),
      sugar: _addNullable(sugar, other.sugar),
      saturatedFat: _addNullable(saturatedFat, other.saturatedFat),
      transFat: _addNullable(transFat, other.transFat),
      monounsaturatedFat: _addNullable(monounsaturatedFat, other.monounsaturatedFat),
      polyunsaturatedFat: _addNullable(polyunsaturatedFat, other.polyunsaturatedFat),
      sodium: _addNullable(sodium, other.sodium),
      potassium: _addNullable(potassium, other.potassium),
      calcium: _addNullable(calcium, other.calcium),
      iron: _addNullable(iron, other.iron),
      magnesium: _addNullable(magnesium, other.magnesium),
      phosphorus: _addNullable(phosphorus, other.phosphorus),
      zinc: _addNullable(zinc, other.zinc),
      copper: _addNullable(copper, other.copper),
      manganese: _addNullable(manganese, other.manganese),
      selenium: _addNullable(selenium, other.selenium),
      vitaminA: _addNullable(vitaminA, other.vitaminA),
      vitaminC: _addNullable(vitaminC, other.vitaminC),
      vitaminD: _addNullable(vitaminD, other.vitaminD),
      vitaminE: _addNullable(vitaminE, other.vitaminE),
      vitaminK: _addNullable(vitaminK, other.vitaminK),
      vitaminB1: _addNullable(vitaminB1, other.vitaminB1),
      vitaminB2: _addNullable(vitaminB2, other.vitaminB2),
      vitaminB3: _addNullable(vitaminB3, other.vitaminB3),
      vitaminB5: _addNullable(vitaminB5, other.vitaminB5),
      vitaminB6: _addNullable(vitaminB6, other.vitaminB6),
      vitaminB12: _addNullable(vitaminB12, other.vitaminB12),
      folate: _addNullable(folate, other.folate),
      choline: _addNullable(choline, other.choline),
      cholesterol: _addNullable(cholesterol, other.cholesterol),
      water: _addNullable(water, other.water),
    );
  }

  static double? _addNullable(double? a, double? b) {
    if (a == null && b == null) return null;
    return (a ?? 0) + (b ?? 0);
  }

  /// Check if nutrition data is empty (no values set)
  bool get isEmpty =>
      calories == null &&
          protein == null &&
          carbohydrates == null &&
          fat == null &&
          fiber == null &&
          sugar == null;

  /// Check if nutrition data has any values
  bool get isNotEmpty => !isEmpty;

  /// Empty nutrition data constant
  static const empty = NutritionData();
}

/// USDA nutrient IDs for reference
/// These are the official USDA FoodData Central nutrient numbers
class UsdaNutrientIds {
  static const int energy = 1008; // kcal
  static const int protein = 1003;
  static const int totalFat = 1004;
  static const int carbohydrates = 1005;
  static const int fiber = 1079;
  static const int sugars = 2000;
  static const int saturatedFat = 1258;
  static const int transFat = 1257;
  static const int monounsaturatedFat = 1292;
  static const int polyunsaturatedFat = 1293;
  static const int cholesterol = 1253;
  static const int sodium = 1093;
  static const int potassium = 1092;
  static const int calcium = 1087;
  static const int iron = 1089;
  static const int magnesium = 1090;
  static const int phosphorus = 1091;
  static const int zinc = 1095;
  static const int copper = 1098;
  static const int manganese = 1101;
  static const int selenium = 1103;
  static const int vitaminA = 1106; // RAE
  static const int vitaminC = 1162;
  static const int vitaminD = 1114; // D2+D3
  static const int vitaminE = 1109;
  static const int vitaminK = 1185;
  static const int thiamin = 1165; // B1
  static const int riboflavin = 1166; // B2
  static const int niacin = 1167; // B3
  static const int pantothenicAcid = 1170; // B5
  static const int vitaminB6 = 1175;
  static const int vitaminB12 = 1178;
  static const int folate = 1177; // DFE
  static const int choline = 1180;
  static const int water = 1051;

  /// Map nutrient ID to field name
  static String? fieldName(int nutrientId) {
    return _idToField[nutrientId];
  }

  static const Map<int, String> _idToField = {
    1008: 'calories',
    1003: 'protein',
    1004: 'fat',
    1005: 'carbohydrates',
    1079: 'fiber',
    2000: 'sugar',
    1258: 'saturatedFat',
    1257: 'transFat',
    1292: 'monounsaturatedFat',
    1293: 'polyunsaturatedFat',
    1253: 'cholesterol',
    1093: 'sodium',
    1092: 'potassium',
    1087: 'calcium',
    1089: 'iron',
    1090: 'magnesium',
    1091: 'phosphorus',
    1095: 'zinc',
    1098: 'copper',
    1101: 'manganese',
    1103: 'selenium',
    1106: 'vitaminA',
    1162: 'vitaminC',
    1114: 'vitaminD',
    1109: 'vitaminE',
    1185: 'vitaminK',
    1165: 'vitaminB1',
    1166: 'vitaminB2',
    1167: 'vitaminB3',
    1170: 'vitaminB5',
    1175: 'vitaminB6',
    1178: 'vitaminB12',
    1177: 'folate',
    1180: 'choline',
    1051: 'water',
  };

  /// All nutrient IDs we care about
  static const List<int> all = [
    energy, protein, totalFat, carbohydrates, fiber, sugars,
    saturatedFat, transFat, monounsaturatedFat, polyunsaturatedFat,
    cholesterol, sodium, potassium, calcium, iron, magnesium,
    phosphorus, zinc, copper, manganese, selenium,
    vitaminA, vitaminC, vitaminD, vitaminE, vitaminK,
    thiamin, riboflavin, niacin, pantothenicAcid, vitaminB6,
    vitaminB12, folate, choline, water,
  ];
}

/// Daily recommended values for percentage calculations
class DailyValues {
  static const double calories = 2000;
  static const double protein = 50; // g
  static const double carbohydrates = 275; // g
  static const double fat = 78; // g
  static const double fiber = 28; // g
  static const double sugar = 50; // g (added sugars)
  static const double saturatedFat = 20; // g
  static const double sodium = 2300; // mg
  static const double potassium = 4700; // mg
  static const double calcium = 1300; // mg
  static const double iron = 18; // mg
  static const double magnesium = 420; // mg
  static const double phosphorus = 1250; // mg
  static const double zinc = 11; // mg
  static const double copper = 0.9; // mg
  static const double manganese = 2.3; // mg
  static const double selenium = 55; // mcg
  static const double vitaminA = 900; // mcg RAE
  static const double vitaminC = 90; // mg
  static const double vitaminD = 20; // mcg
  static const double vitaminE = 15; // mg
  static const double vitaminK = 120; // mcg
  static const double vitaminB1 = 1.2; // mg
  static const double vitaminB2 = 1.3; // mg
  static const double vitaminB3 = 16; // mg
  static const double vitaminB5 = 5; // mg
  static const double vitaminB6 = 1.7; // mg
  static const double vitaminB12 = 2.4; // mcg
  static const double folate = 400; // mcg DFE
  static const double choline = 550; // mg
  static const double cholesterol = 300; // mg

  /// Get percentage of daily value
  static double? percentOf(String nutrient, double? amount) {
    if (amount == null) return null;
    final dv = _dailyValues[nutrient];
    if (dv == null || dv == 0) return null;
    return (amount / dv) * 100;
  }

  static const Map<String, double> _dailyValues = {
    'calories': calories,
    'protein': protein,
    'carbohydrates': carbohydrates,
    'fat': fat,
    'fiber': fiber,
    'sugar': sugar,
    'saturatedFat': saturatedFat,
    'sodium': sodium,
    'potassium': potassium,
    'calcium': calcium,
    'iron': iron,
    'magnesium': magnesium,
    'phosphorus': phosphorus,
    'zinc': zinc,
    'copper': copper,
    'manganese': manganese,
    'selenium': selenium,
    'vitaminA': vitaminA,
    'vitaminC': vitaminC,
    'vitaminD': vitaminD,
    'vitaminE': vitaminE,
    'vitaminK': vitaminK,
    'vitaminB1': vitaminB1,
    'vitaminB2': vitaminB2,
    'vitaminB3': vitaminB3,
    'vitaminB5': vitaminB5,
    'vitaminB6': vitaminB6,
    'vitaminB12': vitaminB12,
    'folate': folate,
    'choline': choline,
    'cholesterol': cholesterol,
  };
}