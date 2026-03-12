import 'dart:convert';
import '../utils/io_stub.dart' if (dart.library.io) 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database.dart';

class ShoppingListService {
  final AppDatabase db;

  ShoppingListService(this.db);

  /// Export list as plain text (for sharing / pasting into other apps)
  Future<String> exportAsText(String listId) async {
    final list = await (db.select(db.shoppingLists)
      ..where((t) => t.id.equals(listId)))
        .getSingle();

    final items = await (db.select(db.shoppingListItems)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();

    final buffer = StringBuffer();
    buffer.writeln('📝 ${list.name}');
    buffer.writeln('─' * 30);
    buffer.writeln();

    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();

    for (final item in unchecked) {
      final qty = item.quantity != null ? '${item.quantity} ' : '';
      buffer.writeln('☐ $qty${item.name}');
    }

    if (checked.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('✅ Completed');
      for (final item in checked) {
        final qty = item.quantity != null ? '${item.quantity} ' : '';
        buffer.writeln('☑ $qty${item.name}');
      }
    }

    buffer.writeln();
    buffer.writeln('Created with Recipe Spellbook');

    return buffer.toString();
  }

  /// Export list as JSON (for import into another Recipe Spellbook app)
  Future<Map<String, dynamic>> exportAsJson(String listId) async {
    final list = await (db.select(db.shoppingLists)
      ..where((t) => t.id.equals(listId)))
        .getSingle();

    final items = await (db.select(db.shoppingListItems)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();

    return {
      'version': 1,
      'type': 'shopping_list',
      'app': 'recipespellbook',
      'exportedAt': DateTime.now().toIso8601String(),
      'list': {
        'name': list.name,
        'items': items.map((item) => {
          'name': item.name,
          'quantity': item.quantity,
          'unit': item.unit,
          'isChecked': item.isChecked,
          'note': item.note,
          'shoppingCategoryId': item.shoppingCategoryId,
          'recipeId': item.recipeId,
        }).toList(),
      },
    };
  }

  /// Export as markdown (good for viewing in any text editor / notes app)
  Future<String> exportAsMarkdown(String listId) async {
    final list = await (db.select(db.shoppingLists)
      ..where((t) => t.id.equals(listId)))
        .getSingle();

    final items = await (db.select(db.shoppingListItems)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([
            (t) => OrderingTerm(expression: t.shoppingCategoryId),
            (t) => OrderingTerm(expression: t.name),
      ]))
        .get();

    final buffer = StringBuffer();
    buffer.writeln('# ${list.name}');
    buffer.writeln();

    final unchecked = items.where((i) => !i.isChecked).toList();
    final checked = items.where((i) => i.isChecked).toList();

    // Group unchecked by category
    if (unchecked.isNotEmpty) {
      final grouped = <String, List<ShoppingListItem>>{};
      for (final item in unchecked) {
        final cat = item.shoppingCategoryId ?? 'other';
        grouped.putIfAbsent(cat, () => []).add(item);
      }

      for (final entry in grouped.entries) {
        final catName = entry.key.isNotEmpty
            ? entry.key[0].toUpperCase() + entry.key.substring(1)
            : 'Other';
        buffer.writeln('## $catName');
        for (final item in entry.value) {
          final qty = item.quantity != null ? '${item.quantity} ' : '';
          buffer.writeln('- [ ] $qty${item.name}');
        }
        buffer.writeln();
      }
    }

    if (checked.isNotEmpty) {
      buffer.writeln('## ✅ Completed');
      for (final item in checked) {
        final qty = item.quantity != null ? '${item.quantity} ' : '';
        buffer.writeln('- [x] $qty${item.name}');
      }
    }

    return buffer.toString();
  }

  /// Share list as file via OS share sheet
  Future<void> shareAsFile(String listId, {String format = 'json'}) async {
    final dir = await getTemporaryDirectory();

    String content;
    String filename;

    switch (format) {
      case 'md':
        content = await exportAsMarkdown(listId);
        filename = 'shopping_list.md';
        break;
      case 'txt':
        content = await exportAsText(listId);
        filename = 'shopping_list.txt';
        break;
      case 'json':
      default:
        content = const JsonEncoder.withIndent('  ').convert(await exportAsJson(listId));
        filename = 'shopping_list.json';
    }

    final file = File(p.join(dir.path, filename));
    await file.writeAsString(content);

    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      subject: 'Shopping List',
    ));
  }

  /// Share list as plain text via OS share sheet
  Future<void> shareAsText(String listId) async {
    final text = await exportAsText(listId);
    await SharePlus.instance.share(ShareParams(text: text, subject: 'Shopping List'));
  }

  /// Import list from JSON (exported by another Recipe Spellbook user)
  Future<ImportListResult> importFromJson(Map<String, dynamic> data) async {
    try {
      if (data['type'] != 'shopping_list') {
        return ImportListResult(success: false, message: 'Invalid file type — expected a Recipe Spellbook shopping list export.');
      }

      final listData = data['list'] as Map<String, dynamic>;
      final items = listData['items'] as List;

      final newListId = 'imported_${DateTime.now().millisecondsSinceEpoch}';

      await db.into(db.shoppingLists).insert(ShoppingListsCompanion.insert(
        id: newListId,
        name: '${listData['name']} (imported)',
      ));

      for (var i = 0; i < items.length; i++) {
        final item = items[i] as Map<String, dynamic>;
        await db.into(db.shoppingListItems).insert(ShoppingListItemsCompanion.insert(
          id: '${newListId}_item_$i',
          listId: newListId,
          name: item['name'] as String,
          quantity: drift.Value(item['quantity'] as String?),
          unit: drift.Value(item['unit'] as String?),
          isChecked: drift.Value(item['isChecked'] as bool? ?? false),
          note: drift.Value(item['note'] as String?),
          shoppingCategoryId: drift.Value(item['shoppingCategoryId'] as String?),
        ));
      }

      return ImportListResult(
        success: true,
        message: 'Imported ${items.length} items',
        listId: newListId,
        listName: '${listData['name']} (imported)',
      );
    } catch (e) {
      return ImportListResult(success: false, message: 'Import failed: $e');
    }
  }
}

class ImportListResult {
  final bool success;
  final String message;
  final String? listId;
  final String? listName;

  ImportListResult({
    required this.success,
    required this.message,
    this.listId,
    this.listName,
  });
}