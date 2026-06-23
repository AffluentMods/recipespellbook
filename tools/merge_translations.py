"""Merges workflow translation output into each locale .arb file.

Input JSON (tools/translations_out.json): {"results":[{"code":"de","translations":[{"key","value"},...]}, ...]}
Only inserts keys that are MISSING from the target .arb (never overwrites
existing translations). Preserves the file's existing content/order and
appends new keys before the closing brace.
"""
import json
import re

ARB_DIR = 'lib/l10n'

data = json.load(open('tools/translations_out.json', encoding='utf-8'))
en = json.load(open(f'{ARB_DIR}/app_en.arb', encoding='utf-8'))

# Keys that carry placeholder metadata in the template — needed so
# non-template locales validate plural/placeholder usage. gen-l10n reads
# placeholder metadata from the TEMPLATE (en) only, so locale files do
# NOT need the @-metadata. We just insert the value strings.
total = 0
for entry in data['results']:
    code = entry['code']
    path = f'{ARB_DIR}/app_{code}.arb'
    arb = json.load(open(path, encoding='utf-8'))
    added = 0
    for t in entry['translations']:
        k, v = t['key'], t['value']
        if k in arb:
            continue  # never overwrite an existing translation
        if k not in en:
            continue  # ignore stray keys not in template
        arb[k] = v
        added += 1
    # Write back as pretty JSON (2-space, preserve unicode)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(arb, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(f'{code}: +{added} keys')
    total += added
print(f'TOTAL inserted: {total}')
