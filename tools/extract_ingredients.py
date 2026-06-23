"""Extracts existing ingredient names (USDA JSON + supplementary Dart tuples)
to tools/existing_ingredients.txt for the expansion audit."""
import json
import re
from collections import Counter

d = json.load(open('assets/data/common_ingredients.json', encoding='utf-8'))
usda = [e['description'] for e in d]

src = open('lib/services/ingredient_suggestion_service.dart', encoding='utf-8').read()
body = src.split('_buildSupplementaryIngredients()')[-1]
# Tuples look like: ('Name', 'Category', 'keywords') or ('Name', 'Category', null)
pat = re.compile(r"\(\s*'((?:[^'\\]|\\.)*)'\s*,\s*'([^']*)'\s*,\s*(?:'(?:[^'\\]|\\.)*'|null)\s*\)")
tuples = pat.findall(body)
supp = [(t[0].replace("\\'", "'"), t[1]) for t in tuples]

cats = sorted({c for _, c in supp})
print('USDA:', len(usda), 'SUPP:', len(supp))
print('CATEGORIES:', cats)
print('per-cat:', Counter(c for _, c in supp).most_common())

allnames = sorted({n.lower() for n in usda} | {n.lower() for n, _ in supp})
with open('tools/existing_ingredients.txt', 'w', encoding='utf-8') as f:
    f.write('\n'.join(allnames))
print('total unique:', len(allnames))
