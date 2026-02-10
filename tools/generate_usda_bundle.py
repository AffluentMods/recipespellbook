#!/usr/bin/env python3
"""
USDA Common Ingredients Generator (Offline Version)

This script processes downloaded USDA FoodData Central JSON files
and generates a bundled JSON file for the Recipe Spellbook app.

SETUP:
1. Download from https://fdc.nal.usda.gov/download-datasets.html:
   - Foundation Foods JSON (December 2025) - ~467KB zipped
   - SR Legacy JSON (April 2018) - ~12.3MB zipped
2. Unzip both files into a folder
3. Run this script pointing to those files

Usage:
    python generate_usda_bundle.py --foundation foundationDownload.json --sr-legacy FoodData_Central_sr_legacy_food_json_2018-04.json --output common_ingredients.json

Requirements:
    pip install tqdm
"""

import argparse
import json
from pathlib import Path
from tqdm import tqdm

# Essential nutrients only (FDA label + key vitamins/minerals)
NUTRIENT_IDS = {
    1008,  # Energy (kcal)
    1003,  # Protein
    1004,  # Total Fat
    1005,  # Carbohydrates
    1079,  # Fiber
    2000,  # Sugars
    1258,  # Saturated Fat
    1257,  # Trans Fat
    1253,  # Cholesterol
    1093,  # Sodium
    1092,  # Potassium
    1087,  # Calcium
    1089,  # Iron
    1106,  # Vitamin A (RAE)
    1162,  # Vitamin C
    1114,  # Vitamin D
}

# Keywords to identify common cooking ingredients
COMMON_INGREDIENTS = [
    # Proteins
    "chicken", "beef", "pork", "turkey", "salmon", "tuna", "shrimp", "egg",
    "tofu", "bacon", "sausage", "ham", "lamb", "duck", "crab", "lobster",
    "fish", "steak", "ground", "breast", "thigh", "wing",

    # Dairy
    "milk", "butter", "cheese", "cream", "yogurt", "sour cream", "cottage",
    "cheddar", "mozzarella", "parmesan", "feta", "ricotta", "cream cheese",

    # Vegetables
    "onion", "garlic", "tomato", "potato", "carrot", "celery", "broccoli",
    "spinach", "lettuce", "pepper", "mushroom", "cucumber", "zucchini",
    "corn", "peas", "beans", "asparagus", "cabbage", "cauliflower", "kale",
    "eggplant", "squash", "pumpkin", "beet", "radish", "turnip", "leek",

    # Fruits
    "apple", "banana", "orange", "lemon", "lime", "strawberry", "blueberry",
    "raspberry", "grape", "watermelon", "pineapple", "mango", "peach",
    "pear", "cherry", "avocado", "coconut", "cranberry", "fig", "raisin",

    # Grains
    "flour", "rice", "pasta", "bread", "oats", "quinoa", "barley",
    "cornmeal", "wheat", "noodles", "tortilla", "couscous", "cereal",

    # Fats & Oils
    "olive oil", "vegetable oil", "coconut oil", "sesame oil", "canola oil",
    "oil", "lard", "shortening", "margarine",

    # Sweeteners
    "sugar", "honey", "maple syrup", "molasses", "agave", "brown sugar",

    # Spices & Herbs
    "salt", "pepper", "cinnamon", "paprika", "cumin", "oregano", "basil",
    "thyme", "rosemary", "parsley", "cilantro", "dill", "mint", "ginger",
    "turmeric", "chili", "cayenne", "nutmeg", "cloves", "vanilla",

    # Condiments
    "soy sauce", "vinegar", "mustard", "mayonnaise", "ketchup", "hot sauce",
    "worcestershire", "salsa", "pesto",

    # Nuts & Seeds
    "almond", "walnut", "peanut", "cashew", "pecan", "pistachio",
    "sunflower", "pumpkin seed", "sesame", "flax", "chia",

    # Legumes
    "black beans", "kidney beans", "chickpeas", "lentils", "pinto",

    # Baking
    "baking powder", "baking soda", "yeast", "cocoa", "chocolate",
]


def load_usda_json(filepath: Path) -> list:
    """Load USDA JSON file"""
    print(f"Loading {filepath.name}...")
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Handle different JSON structures
    if isinstance(data, dict):
        # Foundation/SR Legacy format: {"FoundationFoods": [...]} or {"SRLegacyFoods": [...]}
        for key in ['FoundationFoods', 'SRLegacyFoods', 'SurveyFoods', 'BrandedFoods']:
            if key in data:
                foods = data[key]
                print(f"  Found {len(foods)} foods in '{key}'")
                return foods
        # If no known key, return empty
        print(f"  Warning: Unknown JSON structure, keys: {list(data.keys())}")
        return []
    elif isinstance(data, list):
        print(f"  Found {len(data)} foods")
        return data

    return []


def extract_nutrients(food: dict) -> dict:
    """Extract essential nutrients from a food item"""
    nutrients = {}

    food_nutrients = food.get('foodNutrients', [])
    for nutrient in food_nutrients:
        # Handle different formats
        nutrient_id = None
        amount = None

        # Format 1: {"nutrient": {"id": 1003}, "amount": 25.0}
        if 'nutrient' in nutrient and isinstance(nutrient['nutrient'], dict):
            nutrient_id = nutrient['nutrient'].get('id')
            amount = nutrient.get('amount')
        # Format 2: {"nutrientId": 1003, "value": 25.0}
        elif 'nutrientId' in nutrient:
            nutrient_id = nutrient.get('nutrientId')
            amount = nutrient.get('value') or nutrient.get('amount')
        # Format 3: {"number": "203", "amount": 25.0} (SR Legacy)
        elif 'number' in nutrient:
            # Map nutrient numbers to IDs (simplified)
            nutrient_id = nutrient.get('id')
            amount = nutrient.get('amount')

        if nutrient_id and nutrient_id in NUTRIENT_IDS and amount is not None:
            nutrients[str(nutrient_id)] = round(amount, 4)

    return nutrients


def generate_search_keywords(description: str) -> str:
    """Generate search keywords from food description"""
    words = description.lower().replace(",", " ").replace("(", " ").replace(")", " ").split()
    stop_words = {"and", "or", "the", "a", "an", "with", "without", "in", "on", "for", "of", "to", "nfs"}
    keywords = [w for w in words if w not in stop_words and len(w) > 2]
    return " ".join(keywords[:15])  # Limit keywords


def is_common_ingredient(description: str) -> bool:
    """Check if food matches common cooking ingredients"""
    desc_lower = description.lower()
    for ingredient in COMMON_INGREDIENTS:
        if ingredient in desc_lower:
            return True
    return False


def process_food(food: dict, data_type: str) -> dict | None:
    """Process a food item into our format"""
    fdc_id = food.get('fdcId')
    description = food.get('description', '')

    if not fdc_id or not description:
        return None

    nutrients = extract_nutrients(food)

    # Skip if no essential nutrients
    if not nutrients or '1008' not in nutrients:  # Must have calories
        return None

    result = {
        "fdcId": fdc_id,
        "description": description,
        "dataType": data_type,
        "nutrients": nutrients,
        "searchKeywords": generate_search_keywords(description),
    }

    # Add optional fields if present
    if food.get('foodCategory'):
        if isinstance(food['foodCategory'], dict):
            result["foodCategory"] = food['foodCategory'].get('description')
        else:
            result["foodCategory"] = food['foodCategory']

    if food.get('servingSize'):
        result["servingSize"] = food['servingSize']
        result["servingSizeUnit"] = food.get('servingSizeUnit', 'g')

    if food.get('householdServingFullText'):
        result["householdServing"] = food['householdServingFullText']

    return result


def main():
    parser = argparse.ArgumentParser(description="Generate USDA common ingredients bundle from downloaded files")
    parser.add_argument("--foundation", type=Path, help="Path to Foundation Foods JSON file")
    parser.add_argument("--sr-legacy", type=Path, help="Path to SR Legacy JSON file")
    parser.add_argument("--output", type=Path, default=Path("common_ingredients.json"), help="Output file path")
    parser.add_argument("--max-foods", type=int, default=2500, help="Maximum foods to include")
    parser.add_argument("--all", action="store_true", help="Include all foods, not just common ingredients")
    args = parser.parse_args()

    if not args.foundation and not args.sr_legacy:
        parser.error("At least one of --foundation or --sr-legacy is required")

    print("=== USDA Common Ingredients Generator (Offline) ===\n")

    all_foods = []

    # Load Foundation Foods (higher quality, preferred)
    if args.foundation and args.foundation.exists():
        foundation_data = load_usda_json(args.foundation)
        for food in tqdm(foundation_data, desc="Processing Foundation"):
            processed = process_food(food, "Foundation")
            if processed:
                all_foods.append(processed)
        print(f"  Processed {len([f for f in all_foods if f['dataType'] == 'Foundation'])} Foundation foods\n")
    elif args.foundation:
        print(f"Warning: {args.foundation} not found\n")

    # Load SR Legacy
    if args.sr_legacy and args.sr_legacy.exists():
        sr_data = load_usda_json(args.sr_legacy)
        sr_count = 0
        for food in tqdm(sr_data, desc="Processing SR Legacy"):
            processed = process_food(food, "SR Legacy")
            if processed:
                all_foods.append(processed)
                sr_count += 1
        print(f"  Processed {sr_count} SR Legacy foods\n")
    elif args.sr_legacy:
        print(f"Warning: {args.sr_legacy} not found\n")

    print(f"Total foods loaded: {len(all_foods)}")

    # Filter to common ingredients (unless --all)
    if not args.all:
        print("Filtering to common cooking ingredients...")
        filtered_foods = [f for f in all_foods if is_common_ingredient(f['description'])]
        print(f"  Matched {len(filtered_foods)} common ingredients")
    else:
        filtered_foods = all_foods

    # Prioritize Foundation foods and limit
    if len(filtered_foods) > args.max_foods:
        # Sort: Foundation first, then by description length (shorter = more basic)
        filtered_foods.sort(key=lambda f: (f['dataType'] != 'Foundation', len(f['description'])))
        filtered_foods = filtered_foods[:args.max_foods]
        print(f"  Limited to {len(filtered_foods)} foods")

    # Sort alphabetically for the final output
    filtered_foods.sort(key=lambda f: f['description'].lower())

    # Save to file
    print(f"\nSaving to {args.output}...")
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(filtered_foods, f, separators=(',', ':'))

    file_size = args.output.stat().st_size / (1024 * 1024)
    print(f"  Done! File size: {file_size:.2f} MB")

    # Stats
    print(f"\n=== Summary ===")
    print(f"Total foods: {len(filtered_foods)}")
    foundation_count = len([f for f in filtered_foods if f['dataType'] == 'Foundation'])
    sr_count = len([f for f in filtered_foods if f['dataType'] == 'SR Legacy'])
    print(f"  Foundation: {foundation_count}")
    print(f"  SR Legacy: {sr_count}")

    # Sample of included foods
    print(f"\nSample foods:")
    for food in filtered_foods[:10]:
        cals = food['nutrients'].get('1008', '?')
        print(f"  - {food['description'][:50]} ({cals} cal)")

    print(f"\nPlace '{args.output}' in your Flutter app's assets/data/ folder")


if __name__ == "__main__":
    main()