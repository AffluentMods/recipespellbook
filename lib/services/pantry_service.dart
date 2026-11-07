import 'dart:convert';
import 'package:flutter/foundation.dart' show ValueNotifier, immutable, visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';

import 'pantry_matcher.dart';
import 'pantry_shelf_life.dart';

/// One thing in the pantry: when it was added (or last confirmed with "Keep")
/// and whether it is in the freezer.
@immutable
class PantryEntry {
  final String name;
  final DateTime addedAt;
  final bool frozen;

  const PantryEntry({required this.name, required this.addedAt, this.frozen = false});

  /// Days it usually keeps, or null when it is never checked.
  int? get shelfLifeDays => pantryShelfLifeDays(name, frozen: frozen);

  /// Whether to ask "Still have these?" about it at [now].
  bool isDue(DateTime now) => pantryItemIsDue(name, addedAt, frozen: frozen, now: now);

  /// Whole days since it was added or confirmed.
  int ageInDays(DateTime now) {
    final from = DateTime(addedAt.year, addedAt.month, addedAt.day);
    final to = DateTime(now.year, now.month, now.day);
    return to.difference(from).inDays.clamp(0, 1 << 20);
  }

  @override
  bool operator ==(Object other) =>
      other is PantryEntry && other.name == name && other.addedAt == addedAt && other.frozen == frozen;

  @override
  int get hashCode => Object.hash(name, addedAt, frozen);
}

/// The pantry: things on hand right now (each with the day it was added and
/// whether it is frozen, so the app can ask "Still have these?" later), and
/// the "always have" basics (water, salt, pepper unless the user changes
/// them), which never run out and are left out of "What can I make?" counts.
///
/// The shopping list generator leaves both unticked by default.
class PantryService {
  static const _key = 'pantry_items';
  static const _infoKey = 'pantry_item_info';
  static const _basicsKey = 'pantry_basics';
  static const _updatedAtKey = 'pantry_updated_at';

  /// Called after every change made on this device (not after a sync or an
  /// import put things in place), so cloud sync can push it soon.
  static void Function()? onLocalChange;

  static PantryService? _instance;
  static PantryService get instance => _instance ??= PantryService._();
  PantryService._();

  /// Forget what was loaded so the next call reads storage again (tests set
  /// new mock preferences between cases).
  @visibleForTesting
  static void resetForTesting() => _instance = null;

  /// The clock, replaceable in tests.
  @visibleForTesting
  DateTime Function() now = DateTime.now;

  /// The basics a new pantry starts with.
  static const defaultBasics = ['water', 'salt', 'black pepper'];

  Set<String> _items = {};
  final Map<String, ({int added, bool frozen})> _info = {};
  Set<String> _basics = {...defaultBasics};
  Future<void>? _loading;

  /// Goes up when the pantry changed from outside the app's own editing
  /// (cloud sync, a restored backup, a transfer), so screens read it again.
  final revision = ValueNotifier<int>(0);

  /// Loads once. Callers that arrive while it is loading wait for the same
  /// load, so a load finishing late cannot wipe an item added meanwhile
  /// (the first pantry use can be a "Put away" while the provider builds).
  Future<void> _ensureLoaded() => _loading ??= _load().then((_) {}, onError: (Object e, StackTrace st) {
        _loading = null; // a failed load is tried again next time
        Error.throwWithStackTrace(e, st);
      });

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _items = _decode(prefs.getString(_key)) ?? {};
    _basics = _decode(prefs.getString(_basicsKey)) ?? {...defaultBasics};
    _info.clear();
    try {
      final raw = prefs.getString(_infoKey);
      if (raw != null) {
        for (final e in (jsonDecode(raw) as Map<String, dynamic>).entries) {
          final v = e.value as Map<String, dynamic>;
          _info[e.key] = (added: (v['a'] as num).toInt(), frozen: v['f'] == 1);
        }
      }
    } catch (_) {
      _info.clear();
    }
    // Items from before dates were kept start their clock today, so an
    // update never greets anyone with a long "Still have these?" list.
    final undated = _items.where((i) => !_info.containsKey(i)).toList();
    if (undated.isNotEmpty) {
      final today = now().millisecondsSinceEpoch;
      for (final i in undated) {
        _info[i] = (added: today, frozen: false);
      }
      await _save(edit: false);
    }
  }

  static Set<String>? _decode(String? json) {
    if (json == null) return null;
    try {
      final list = (jsonDecode(json) as List).cast<String>();
      return list.map(_normalize).where((s) => s.isNotEmpty).toSet();
    } catch (_) {
      return null;
    }
  }

  static String _normalize(String name) => name.toLowerCase().trim();

  /// [edit]: a change made here, which sync should send. [stamp]: the
  /// "last changed" time to record instead of now (a pulled copy keeps the
  /// server's).
  Future<void> _save({bool edit = true, int? stamp}) async {
    final prefs = await SharedPreferences.getInstance();
    _info.removeWhere((name, _) => !_items.contains(name));
    await prefs.setString(_key, jsonEncode(_items.toList()..sort()));
    await prefs.setString(_infoKey, jsonEncode({
      for (final e in _info.entries) e.key: {'a': e.value.added, if (e.value.frozen) 'f': 1},
    }));
    await _stamp(prefs, edit: edit, stamp: stamp);
  }

  Future<void> _saveBasics({bool edit = true, int? stamp}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_basicsKey, jsonEncode(_basics.toList()..sort()));
    await _stamp(prefs, edit: edit, stamp: stamp);
  }

  Future<void> _stamp(SharedPreferences prefs, {required bool edit, int? stamp}) async {
    if (stamp != null) {
      await prefs.setInt(_updatedAtKey, stamp);
    } else if (edit) {
      await prefs.setInt(_updatedAtKey, now().millisecondsSinceEpoch);
      onLocalChange?.call();
    }
  }

  // ── Sync, backups and transfers ──

  /// When the pantry last changed (ms since epoch), 0 if never.
  Future<int> updatedAt() async {
    await _ensureLoaded();
    return (await SharedPreferences.getInstance()).getInt(_updatedAtKey) ?? 0;
  }

  /// The whole pantry as one document: {items: [{name, added, frozen}], basics}.
  Future<Map<String, dynamic>> toDoc() async {
    await _ensureLoaded();
    return {
      'items': [
        for (final name in _items.toList()..sort())
          {
            'name': name,
            'added': _info[name]?.added ?? now().millisecondsSinceEpoch,
            if (_info[name]?.frozen ?? false) 'frozen': true,
          },
      ],
      'basics': _basics.toList()..sort(),
    };
  }

  /// Items and basics from [doc], or null for anything that is not one.
  static ({Map<String, ({int added, bool frozen})> items, Set<String> basics})? _readDoc(Object? doc) {
    if (doc is! Map) return null;
    final items = <String, ({int added, bool frozen})>{};
    final basics = <String>{};
    for (final raw in doc['items'] is List ? doc['items'] as List : const []) {
      if (raw is! Map || raw['name'] is! String) continue;
      final name = _normalize(raw['name'] as String);
      if (name.isEmpty) continue;
      final added = raw['added'] is num ? (raw['added'] as num).toInt() : 0;
      items[name] = (added: added, frozen: raw['frozen'] == true);
    }
    for (final raw in doc['basics'] is List ? doc['basics'] as List : const []) {
      if (raw is String && _normalize(raw).isNotEmpty) basics.add(_normalize(raw));
    }
    return (items: items, basics: basics);
  }

  /// Put the pantry from another device in place of this one (cloud sync,
  /// the newer copy wins), keeping its "last changed" time [stampedAt].
  Future<void> replaceWithDoc(Object? doc, int stampedAt) async {
    final read = _readDoc(doc);
    if (read == null) return;
    await _ensureLoaded();
    _items = read.items.keys.toSet();
    _info
      ..clear()
      ..addAll(read.items);
    _basics = read.basics;
    await _save(stamp: stampedAt);
    await _saveBasics(stamp: stampedAt);
    revision.value++;
  }

  /// Add what [doc] has that this pantry lacks (a backup, a transfer, or the
  /// first sync of a device). An item in both keeps the later date. Counts
  /// as a change here, so sync sends the result.
  Future<void> mergeDoc(Object? doc) async {
    final read = _readDoc(doc);
    if (read == null) return;
    await _ensureLoaded();
    for (final e in read.items.entries) {
      if (_basics.contains(e.key)) continue;
      final mine = _info[e.key];
      if (!_items.contains(e.key) || mine == null || e.value.added > mine.added) {
        _items.add(e.key);
        _info[e.key] = e.value;
      }
    }
    _basics.addAll(read.basics);
    _items.removeAll(_basics);
    await _save();
    await _saveBasics();
    revision.value++;
  }

  // ── Always have ──

  /// The always-have basics (sorted).
  Future<List<String>> getBasics() async {
    await _ensureLoaded();
    return _basics.toList()..sort();
  }

  Future<void> addBasic(String name) => addBasics([name]);

  /// Add to the always-have list. Anything also in the pantry moves over.
  Future<void> addBasics(List<String> names) async {
    await _ensureLoaded();
    var pantryChanged = false;
    for (final name in names) {
      final normalized = _normalize(name);
      if (normalized.isEmpty) continue;
      _basics.add(normalized);
      pantryChanged |= _items.remove(normalized);
    }
    await _saveBasics();
    if (pantryChanged) await _save();
  }

  Future<void> removeBasic(String name) async {
    await _ensureLoaded();
    _basics.remove(_normalize(name));
    await _saveBasics();
  }

  /// Move a pantry item to "always have" (it stops being checked for age).
  Future<void> moveToBasics(String name) => addBasics([name]);

  /// Move an always-have basic back to the pantry, dated today.
  Future<void> moveBasicToPantry(String name) async {
    await _ensureLoaded();
    final normalized = _normalize(name);
    _basics.remove(normalized);
    await _saveBasics();
    await addItems([normalized]);
  }

  // ── Pantry items ──

  /// Get all pantry items (sorted).
  Future<List<String>> getAll() async {
    await _ensureLoaded();
    return _items.toList()..sort();
  }

  /// Every pantry item with its date and freezer flag, sorted by name.
  Future<List<PantryEntry>> getEntries() async {
    await _ensureLoaded();
    final today = now().millisecondsSinceEpoch;
    return [
      for (final name in _items.toList()..sort())
        PantryEntry(
          name: name,
          addedAt: DateTime.fromMillisecondsSinceEpoch(_info[name]?.added ?? today),
          frozen: _info[name]?.frozen ?? false,
        ),
    ];
  }

  /// Ingredient ids (keys of [ingredientIdToName]) whose food is in the
  /// pantry or is an always-have basic.
  Future<Set<String>> filterPantryMatches(Map<String, String> ingredientIdToName) async {
    await _ensureLoaded();
    if (_items.isEmpty && _basics.isEmpty) return {};
    final matcher = PantryMatcher(pantry: _items, basics: _basics);
    return {
      for (final entry in ingredientIdToName.entries)
        if (matcher.hasLine(ingredientKeyFor(entry.value))) entry.key,
    };
  }

  Future<void> addItem(String name, {bool frozen = false}) => addItems([name], frozen: frozen);

  /// Add items dated today. Adding one that is already there restarts its
  /// clock (bought again) and keeps it in the freezer if it was there.
  Future<void> addItems(List<String> names, {bool frozen = false}) async {
    await _ensureLoaded();
    final today = now().millisecondsSinceEpoch;
    for (final name in names) {
      final normalized = _normalize(name);
      if (normalized.isEmpty) continue;
      _items.add(normalized);
      _info[normalized] = (added: today, frozen: frozen || (_info[normalized]?.frozen ?? false));
    }
    await _save();
  }

  /// "Still have it": restart the item's clock.
  Future<void> keepItems(List<String> names) async {
    await _ensureLoaded();
    final today = now().millisecondsSinceEpoch;
    for (final name in names.map(_normalize)) {
      final info = _info[name];
      if (_items.contains(name)) _info[name] = (added: today, frozen: info?.frozen ?? false);
    }
    await _save();
  }

  /// Put an item in the freezer, or take it out. Either way its clock starts
  /// again today.
  Future<void> setFrozen(String name, bool frozen) async {
    await _ensureLoaded();
    final normalized = _normalize(name);
    if (!_items.contains(normalized)) return;
    _info[normalized] = (added: now().millisecondsSinceEpoch, frozen: frozen);
    await _save();
  }

  Future<void> removeItem(String name) => removeItems([name]);

  Future<void> removeItems(List<String> names) async {
    await _ensureLoaded();
    for (final name in names) {
      _items.remove(_normalize(name));
    }
    await _save();
  }

  /// Empty the pantry. The always-have basics stay.
  Future<void> clear() async {
    await _ensureLoaded();
    _items.clear();
    await _save();
  }

  /// Common pantry staples for quick-add suggestions.
  static const commonStaples = [
    'salt', 'black pepper', 'olive oil', 'vegetable oil',
    'butter', 'flour', 'sugar', 'baking powder', 'baking soda',
    'garlic powder', 'onion powder', 'paprika', 'cumin',
    'oregano', 'basil', 'thyme', 'cinnamon', 'cayenne',
    'red pepper flakes', 'italian seasoning', 'bay leaves',
    'soy sauce', 'vinegar', 'vanilla extract',
    'cornstarch', 'honey', 'mustard', 'ketchup',
    'hot sauce', 'worcestershire sauce',
    'rice', 'pasta', 'chicken broth',
    'eggs', 'milk', 'water',
  ];
}
