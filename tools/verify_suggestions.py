"""Simulates IngredientSuggestionService matching (startsWith on name or
keywords + word-boundary contains) over USDA + supplementary entries to
verify queries the user reported as missing now match."""
import json
import re
import sys

SERVICE = 'lib/services/ingredient_suggestion_service.dart'
USDA = 'assets/data/common_ingredients.json'

entries = []  # (display, searchtext)
for e in json.load(open(USDA, encoding='utf-8')):
    entries.append((e['description'], ((e.get('searchKeywords') or '') + ' ' + e['description']).lower()))
src = open(SERVICE, encoding='utf-8').read()
body = src.split('_buildSupplementaryIngredients()')[-1]
pat = re.compile(r"\(\s*'((?:[^'\\]|\\.)*)'\s*,\s*'[^']*'\s*,\s*(?:'((?:[^'\\]|\\.)*)'|null)\s*\)")
for m in pat.findall(body):
    name = m[0].replace("\\'", "'")
    kw = (m[1] or name).replace("\\'", "'").lower()
    entries.append((name, kw))

print(f'total entries: {len(entries)}')


def matches(q):
    q = q.lower().strip()
    out = []
    for display, search in entries:
        dl = display.lower()
        if dl.startswith(q) or search.startswith(q):
            out.append(display)
        elif re.search(r'(^|[\s,(-])' + re.escape(q), dl) or re.search(r'(^|[\s,(-])' + re.escape(q), search):
            out.append(display)
    return out[:6]


queries = sys.argv[1:] or [
    'jasmine', 'basmati', 'white cheddar', 'mozzarella', 'parmesan',
    'monterey', 'arborio', 'sushi rice', 'oat milk', 'pepper jack',
    'gruyere', 'ricotta', 'honeycrisp', 'shallot', 'panko', 'tofu',
    'rotisserie', 'prosciutto', 'udon', 'ghee',
]
fails = 0
for q in queries:
    m = matches(q)
    status = 'OK ' if m else 'MISS'
    if not m:
        fails += 1
    print(f'{status} "{q}" -> {m}')
sys.exit(1 if fails else 0)
