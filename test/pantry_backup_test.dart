// A full backup carries the pantry, and restoring it adds the pantry back.
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/database/database.dart';
import 'package:recipespellbook/services/export_import_service.dart';
import 'package:recipespellbook/services/pantry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('a full backup carries the pantry and a restore merges it back', () async {
    SharedPreferences.setMockInitialValues({
      'pantry_items': jsonEncode(['eggs', 'ground beef']),
      'pantry_item_info': jsonEncode({
        'eggs': {'a': 1000},
        'ground beef': {'a': 2000, 'f': 1},
      }),
      'pantry_basics': jsonEncode(['salt', 'flour']),
    });
    PantryService.resetForTesting();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final data = await ExportImportService(db).exportSelective(const ExportOptions.all());
    expect(data['pantry'], isNotNull);

    // A new phone: an empty pantry, then the restore.
    SharedPreferences.setMockInitialValues({});
    PantryService.resetForTesting();
    await ExportImportService(db).importData(jsonDecode(jsonEncode(data)) as Map<String, dynamic>);
    final entries = await PantryService.instance.getEntries();
    expect([for (final e in entries) e.name], ['eggs', 'ground beef']);
    expect(entries.last.frozen, isTrue);
    expect(await PantryService.instance.getBasics(), containsAll(['salt', 'flour']));
  });
}
