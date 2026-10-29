import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../models/imported_recipe.dart';
import 'import_support.dart';
import 'loose_xml.dart';

/// Imports recipes from MasterCook (.mxp, .mx2, .mz2) files.
///
/// .mxp is the text export: fixed-width, each recipe opened by its
/// "Exported from MasterCook" line.
///
///   *  Exported from  MasterCook  *
///
///                       Recipe Name
///
///   Recipe By     : Author Name
///   Serving Size  : 4    Preparation Time :0:30
///   Categories    : Desserts                  Cakes
///
///     Amount  Measure       Ingredient -- Preparation Method
///   --------  ------------  --------------------------------
///      2      cups          flour
///    1/2      cup           sugar
///      3                    eggs -- beaten
///
///   First paragraph of directions.
///
///   Second paragraph of directions.
///
///   Source:
///     "A label and its quoted value, as MasterCook 5 and later write them"
///                      - - - - - - - - - - - - - - - - - -
///
///   NOTES : Notes, serving ideas and nutrition follow the dashed line.
///
/// A copy of that text taken from a web page, where every run of spaces has
/// become one, is read as well.
///
/// .mx2 is the XML export of MasterCook 5 and later, one `<RcpE>` element per
/// recipe, and .mz2 is a zip holding an .mx2 and the recipes' photos.
class MasterCookImporter {
  MasterCookImporter._();

  /// The line that opens every recipe of a text export. Later versions and
  /// the Mac edition word it a little differently ("MasterCook II",
  /// "MasterCook Mac", braces instead of stars).
  static final _exportLine = RegExp(
    r'^[ \t]*[*{][ \t]*Exported[ \t]+from[ \t]+MasterCook\b[^\r\n]*[*}][ \t]*$',
    multiLine: true,
    caseSensitive: false,
  );

  /// The heading row of the ingredient table.
  static final _tableHeader = RegExp(
    r'^[ \t]*Amount[ \t]+Measure[ \t]+Ingredient',
    multiLine: true,
    caseSensitive: false,
  );

  /// The "- - - - -" line that ends the directions. The dashes are spaced,
  /// which tells it from the solid rule under the table header.
  static final _endLine = RegExp(r'^[ \t]*-(?:[ \t]+-){8,}[ \t]*$');

  /// Whether [content] is a MasterCook text export, going by its export line
  /// or its ingredient table. The words "Serving Size" alone do not make a
  /// file MasterCook's: plain recipes use them too. An .mx2 document is not
  /// one either, though it carries the text export of each recipe inside it.
  static bool looksLikeMxp(String content) =>
      !looksLikeMx2(content) && (_exportLine.hasMatch(content) || _tableHeader.hasMatch(content));

  /// Parse a .mxp file and return all recipes.
  static List<ImportedRecipe> import_(String content, String filename) {
    // A file sent through a transfer that doubled its carriage returns ends
    // every line with two of them. Read as two line ends, that would put a
    // blank line after each row and end the table at its first one.
    final lines = content
        .replaceAll('\r\r\n', '\n')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');

    // A recipe runs from its export line to the next one. Nothing else can
    // divide the file: the dashed rule under the table header and the
    // "- - -" line that ends the directions are both inside a recipe.
    final starts = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (_exportLine.hasMatch(lines[i])) starts.add(i);
    }
    // No export line at all: one recipe copied out of a larger file.
    if (starts.isEmpty) starts.add(-1);

    final recipes = <ImportedRecipe>[];
    for (var n = 0; n < starts.length; n++) {
      final end = n + 1 < starts.length ? starts[n + 1] : lines.length;
      try {
        final recipe = _parseBlock(lines, starts[n] + 1, end)?.toImported(filename);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {}
    }
    return recipes;
  }

  /// Whether [content] is a MasterCook .mx2 document.
  static bool looksLikeMx2(String content) =>
      _mx2Start.hasMatch(content.length > 4096 ? content.substring(0, 4096) : content);

  static final _mx2Start = RegExp(r'<(?:mx2|RcpE)[\s>]', caseSensitive: false);

  /// Parse a .mx2 file and return all recipes.
  ///
  /// [photo] finds the pictures a .mz2 archive carries next to the .mx2.
  static List<ImportedRecipe> importMx2(
    String content,
    String filename, {
    ImportPhotoLookup? photo,
  }) {
    final recipes = <ImportedRecipe>[];
    // A recipe the file stops inside holds only part of itself and is left out.
    for (final element in LooseXml.parse(content).whole('RcpE')) {
      try {
        final recipe = _parseElement(element, photo).toImported(filename);
        if (recipe != null) recipes.add(recipe);
      } catch (_) {}
    }
    return recipes;
  }

  /// Parse a .mz2 file: a zip holding one or more .mx2 documents and the
  /// recipes' photos.
  static Future<List<ImportedRecipe>> importMz2(
    Uint8List bytes,
    String filename,
  ) async {
    // Not a zip: a plain .mx2 that was given the .mz2 name is read as it is.
    if (!ImportSupport.isZip(bytes)) {
      return importMx2(ImportSupport.decodeText(bytes), filename);
    }

    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FormatException(_damaged);
    }

    final photo = ImportSupport.photosIn(archive);
    final recipes = <ImportedRecipe>[];
    var documents = 0;
    var unreadable = false;
    for (final file in archive.files) {
      if (!file.isFile || !file.name.toLowerCase().endsWith('.mx2')) continue;
      documents++;
      final String content;
      try {
        content = ImportSupport.decodeText(file.content as List<int>);
      } catch (_) {
        // The archive lists the file but its data does not unpack.
        unreadable = true;
        continue;
      }
      recipes.addAll(importMx2(content, filename, photo: photo));
    }
    if (documents == 0) {
      throw const FormatException('This .mz2 file does not contain a MasterCook .mx2 document.');
    }
    if (recipes.isEmpty && unreadable) throw const FormatException(_damaged);
    return recipes;
  }

  static const _damaged =
      'This MasterCook file is damaged or incomplete. Export it again and retry.';

  /// Reads one recipe from the lines [start] to [end] of a text export. Null
  /// when they hold no ingredient table: MasterCook writes one for every
  /// recipe, even an empty one, so text without it is not a recipe.
  static _MasterCookRecipe? _parseBlock(List<String> lines, int start, int end) {
    final recipe = _MasterCookRecipe();
    var i = start;

    // The title and the "Label : value" lines above the ingredient table.
    _Columns? columns;
    var inCategories = false;
    for (; i < end; i++) {
      final line = lines[i];
      final text = line.trim();
      if (text.isEmpty) {
        inCategories = false;
        continue;
      }
      // The rule under the table header. Dashes drawn above the title are
      // only decoration.
      if (recipe.title != null) columns = _Columns.fromRule(_expandTabs(line));
      if (columns != null) {
        i++;
        break;
      }
      if (_tableHeader.hasMatch(line)) {
        inCategories = false;
        continue;
      }
      final colon = text.indexOf(':');
      final label = colon < 0 ? '' : text.substring(0, colon).trim().toLowerCase();
      final value = colon < 0 ? '' : text.substring(colon + 1).trim();
      if (label == 'recipe by') {
        recipe.author = value;
      } else if (label == 'serving size') {
        // "Serving Size  : 6     Preparation Time :0:15"
        recipe.servings = _servingCount(_leadingDigits.stringMatch(value));
        recipe.prepMinutes = _minutes(_preparationTime.firstMatch(value)?.group(1));
      } else if (label == 'preparation time') {
        recipe.prepMinutes = _minutes(value);
      } else if (label == 'categories') {
        recipe.addCategories(value);
      } else if (inCategories && (recipe.title != null || line.length != line.trimLeft().length)) {
        // Two categories fit on a line. The rest follow on the lines below,
        // indented. A line at the left edge is one of them only once the
        // title has been read, so the title is never taken for a category.
        recipe.addCategories(text);
        continue;
      } else if (!_MasterCookRecipe._onlyRules.hasMatch(text)) {
        // The first line that is none of the above is the title. It may
        // hold a colon of its own ("Chili: Texas Style").
        recipe.title ??= text;
      }
      inCategories = label == 'categories';
    }
    if (columns == null || recipe.title == null) return null;

    // The ingredient table. A blank line ends it, and so does a line that
    // starts at the left edge with words: that is the directions starting,
    // when the table is empty or no blank line follows it.
    var blankBefore = false;
    for (; i < end; i++) {
      final line = _expandTabs(lines[i]);
      if (line.trim().isEmpty) {
        // A blank line above the first row is passed over, unless the
        // columns are gone and nothing else could tell where the table ends.
        if (recipe.rows.isNotEmpty && columns.aligned && _tableGoesOn(lines, i + 1, end, columns)) continue;
        if (recipe.rows.isNotEmpty || !columns.aligned) break;
        blankBefore = true;
        continue;
      }
      if (_endLine.hasMatch(line)) break;
      // A second rule drawn inside the table is not an ingredient.
      if (_MasterCookRecipe._onlyRules.hasMatch(line)) continue;
      // A section title drawn across the columns: "---------- CAKE ----------".
      if (_MasterCookRecipe._undecorated(line.trim()) != null) {
        recipe.addRow('', '', line);
        continue;
      }
      final cells = columns.cells(line);
      if (cells != null) {
        recipe.addRow(cells.amount, cells.measure, cells.text);
      } else if (columns.isIndented(line) && !blankBefore) {
        // An indented row that does not keep to the columns, typed by hand or
        // with an amount such as "2x". It is taken whole. Under an empty
        // table it would be the directions, set in from the edge.
        recipe.addRow('', '', line);
      } else {
        break;
      }
    }

    // The directions, up to the dashed line. MasterCook 5 and later put
    // labelled blocks (Description, Source, Yield) between the two.
    final directions = StringBuffer();
    void endDirections() {
      recipe.addDirections(directions.toString());
      directions.clear();
    }

    for (; i < end; i++) {
      final text = lines[i].trim();
      if (_endLine.hasMatch(text)) {
        i++;
        break;
      }
      if (text.endsWith(':') && i + 1 < end && _startsQuoted(lines[i + 1])) {
        final label = text.substring(0, text.length - 1).trim();
        if (_fieldLabel.hasMatch(label)) {
          endDirections();
          final (value, last) = _quotedValue(lines, i + 1, end);
          recipe.setField(label, value);
          i = last;
          continue;
        }
      }
      if (_ratingsLine.hasMatch(text)) {
        endDirections();
        // Like the categories, ratings that do not fit on the line carry on
        // below it. None of that is a direction.
        while (i + 1 < end && _continuesRatings(lines[i + 1])) {
          i++;
        }
        continue;
      }
      directions.writeln(text);
    }
    endDirections();

    // Below the dashed line: nutrition, serving ideas and notes, each one
    // starting with its label and running until the next label.
    final kept = <String, StringBuffer>{};
    StringBuffer? field;
    var afterBlank = false;
    for (; i < end; i++) {
      final text = lines[i].trim();
      if (text.isEmpty) {
        afterBlank = true;
        continue;
      }
      final colon = text.indexOf(':');
      final label = colon < 0 ? null : _trailerLabel(text.substring(0, colon));
      if (label != null) {
        // Nutrition is not kept.
        field = label.isEmpty ? null : (kept[label] ??= StringBuffer());
        final value = text.substring(colon + 1).trim();
        if (field != null && value.isNotEmpty) {
          if (field.isNotEmpty) field.write('\n\n');
          field.write(value);
        }
      } else if (_MasterCookRecipe._onlyRules.hasMatch(text)) {
        // A drawn rule ends the notes. What follows it in a file put
        // together from messages is not part of the recipe.
        field = null;
      } else if (field != null) {
        if (field.isNotEmpty) field.write(afterBlank ? '\n\n' : ' ');
        field.write(text);
      }
      afterBlank = false;
    }
    recipe.notes = _text(kept['notes']?.toString());
    recipe.servingIdeas = _text(kept['serving ideas']?.toString());
    recipe.wine = _text(kept['suggested wine']?.toString());

    return recipe;
  }

  /// Reads one `<RcpE>` element of an .mx2 document.
  static _MasterCookRecipe _parseElement(XmlElement element, ImportPhotoLookup? photo) {
    final recipe = _MasterCookRecipe()
      ..title = element.attribute('name')
      ..author = element.attribute('author')
      ..servings = _servingCount(element.find('Serv')?.attribute('qty'))
      ..prepMinutes = _minutes(element.find('PrpT')?.attribute('elapsed'))
      ..totalMinutes = _minutes(element.find('TTim')?.attribute('elapsed'))
      ..description = element.textOf('Desc')
      ..cuisine = element.textOf('Natn')
      ..source = element.textOf('Srce')
      ..copyright = element.textOf('CpyR')
      ..notes = element.textOf('Note')
      ..servingIdeas = element.textOf('SrvI')
      ..wine = element.textOf('Wine');

    final made = element.find('Yield');
    if (made != null) {
      final amount = num.tryParse(made.attribute('qty') ?? '');
      recipe.yieldText = _text([
        if (amount != null) _quantity(amount),
        made.attribute('unit'),
      ].nonNulls.join(' '));
    }

    for (final category in element.all('CatT')) {
      recipe.addCategory(category.text);
    }

    for (final row in element.all('IngR')) {
      final name = row.attribute('name') ?? '';
      final preparation = row.textOf('IPrp');
      recipe.addRow(
        row.attribute('qty') ?? '',
        row.attribute('unit') ?? '',
        preparation == null ? name : '$name -- $preparation',
        // MasterCook marks a section title row ("For the sauce") with S.
        isTitle: row.attribute('code')?.toUpperCase() == 'S',
      );
    }

    for (final direction in element.all('DirT')) {
      recipe.addDirections(direction.text);
    }

    for (final other in element.all('AltS')) {
      final source = other.attribute('source');
      if (source != null) recipe.otherSources.add((other.attribute('label') ?? '', source));
    }
    for (final other in element.all('AltT')) {
      recipe.otherMinutes += _minutes(other.attribute('elapsed')) ?? 0;
    }

    final picture = element.attribute('img');
    final bytes = (picture == null || photo == null) ? null : photo(picture);
    if (bytes != null) recipe.imageData = base64Encode(bytes);

    return recipe;
  }

  /// The labels of the blocks MasterCook 5 and later write under the
  /// directions. "S(...)" is an extra source and "T(...)" an extra time, each
  /// under a label the cook chose.
  static final _fieldLabel = RegExp(
    r'^(?:Description|Cuisine|Source|Copyright|Yield|Start to Finish Time|[ST]\([^)]*\))$',
    caseSensitive: false,
  );

  static final _ratingsLine = RegExp(r'^Ratings[ \t]*:', caseSensitive: false);
  static final _leadingDigits = RegExp(r'^\d+');
  static final _preparationTime = RegExp(
    r'Preparation[ \t]+Time[ \t]*:[ \t]*(\d{1,3}:\d{1,2})',
    caseSensitive: false,
  );
  static final _hoursMinutes = RegExp(r'^(\d{1,3}):(\d{1,2})$');

  /// Whether [line] is the quoted value under a "Label:" line. MasterCook
  /// indents it, but the indent does not survive a web page.
  static bool _startsQuoted(String line) => line.trimLeft().startsWith('"');

  /// Whether [line] carries on the "Ratings :" line above it: they run to the
  /// next blank line, labelled block or the dashed line.
  static bool _continuesRatings(String line) {
    final text = line.trim();
    return text.isNotEmpty && !text.endsWith(':') && !_endLine.hasMatch(text);
  }

  /// Whether the ingredient table carries on after a blank row: the next line
  /// that is not blank is an indented row in the columns, with an amount or a
  /// measure, or a section title. Directions start at the left edge.
  static bool _tableGoesOn(List<String> lines, int i, int end, _Columns columns) {
    for (; i < end; i++) {
      final line = _expandTabs(lines[i]);
      if (line.trim().isEmpty) continue;
      if (!columns.isIndented(line) || _endLine.hasMatch(line)) return false;
      if (_MasterCookRecipe._undecorated(line.trim()) != null) return true;
      final cells = columns.cells(line);
      return cells != null && (cells.amount.isNotEmpty || cells.measure.isNotEmpty);
    }
    return false;
  }

  /// Reads the quoted value that starts on line [i] and may run over several
  /// lines. Returns it without its quotes, with the index of its last line.
  /// A blank line inside the quotes is a paragraph break, as long as the
  /// closing quote comes before the dashed line.
  static (String, int) _quotedValue(List<String> lines, int i, int end) {
    final parts = <String>[];
    var last = i;
    var closes = false;
    if (lines[i].trim().startsWith('"')) {
      for (var j = i; j < end && !_endLine.hasMatch(lines[j].trim()); j++) {
        final t = lines[j].trim();
        if (t.endsWith('"') && (j > i || t.length > 1)) {
          closes = true;
          break;
        }
      }
    }
    for (; i < end; i++) {
      final text = lines[i].trim();
      if (text.isEmpty && closes && parts.isNotEmpty) {
        if (parts.last != '\n') parts.add('\n');
        continue;
      }
      if (text.isEmpty || _endLine.hasMatch(text)) break;
      parts.add(text);
      last = i;
      if (text.endsWith('"') && (parts.length > 1 || text.length > 1)) break;
    }
    var value = parts.join(' ').replaceAll(' \n ', '\n\n');
    if (value.startsWith('"')) value = value.substring(1);
    if (value.endsWith('"')) value = value.substring(0, value.length - 1);
    return (value.trim(), last);
  }

  /// The name of a field that follows the dashed line, an empty string for
  /// one that is not kept, or null when [raw] is not a label at all.
  static String? _trailerLabel(String raw) {
    final label = raw.trim().toLowerCase();
    if (label == 'notes' || label == 'serving ideas' || label == 'suggested wine') return label;
    if (label == 'per serving' ||
        label.startsWith('per serving (') ||
        label == 'food exchanges' ||
        label == 'nutr. assoc.') {
      return '';
    }
    return null;
  }

  /// "1:30" as 90 minutes. Null for a time that is missing or zero, which is
  /// how MasterCook writes one that was never set.
  static int? _minutes(String? text) {
    final match = text == null ? null : _hoursMinutes.firstMatch(text.trim());
    if (match == null) return null;
    final minutes = int.parse(match[1]!) * 60 + int.parse(match[2]!);
    return minutes > 0 ? minutes : null;
  }

  /// The serving count, or null when it is missing or 0, which MasterCook
  /// writes for a recipe that only has a yield ("2 cups").
  static String? _servingCount(String? text) {
    final count = num.tryParse(text?.trim() ?? '');
    return count == null ? null : _quantity(count);
  }

  static const _fractions = [
    (0.125, '1/8'),
    (0.25, '1/4'),
    (1 / 3, '1/3'),
    (0.375, '3/8'),
    (0.5, '1/2'),
    (0.625, '5/8'),
    (2 / 3, '2/3'),
    (0.75, '3/4'),
    (0.875, '7/8'),
  ];

  /// A quantity the way MasterCook prints it in its text export: "2.000000"
  /// as "2" and "1.500000" as "1 1/2". Null for zero, which stands for "not
  /// set", and for anything that is not a sensible quantity.
  static String? _quantity(num value) {
    if (!value.isFinite || value <= 0 || value >= 1000000) return null;
    final whole = value.floor();
    final rest = value - whole;
    if (rest < 0.005) return '$whole';
    if (rest > 0.995) return '${whole + 1}';
    for (final (fraction, text) in _fractions) {
      if ((rest - fraction).abs() < 0.005) return whole == 0 ? text : '$whole $text';
    }
    return value.toString();
  }

  static String? _text(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  /// Tabs as spaces up to the next eight-column stop, so the table columns
  /// line up again in a file an editor saved with tabs.
  static String _expandTabs(String line) {
    if (!line.contains('\t')) return line;
    final out = StringBuffer();
    var column = 0;
    for (final unit in line.codeUnits) {
      if (unit == 0x09) {
        final width = 8 - column % 8;
        out.write(' ' * width);
        column += width;
      } else {
        out.writeCharCode(unit);
        column++;
      }
    }
    return out.toString();
  }
}

/// Where the columns of the ingredient table are, read from the dashed rule
/// under its header, so a file that was indented or shifted still lines up.
class _Columns {
  const _Columns(this.left, this.amountEnd, this.textStart, {required this.aligned});

  /// The first column of the table.
  final int left;

  /// One past the last column of the amount.
  final int amountEnd;

  /// The first column of the ingredient.
  final int textStart;

  /// False when the rule itself has lost its spacing. MasterCook leaves two
  /// spaces between the parts of the rule. A single one means every run of
  /// spaces in the file was collapsed, as a web page does to text copied from
  /// it, and the rows no longer stand under their columns.
  final bool aligned;

  static final _rule = RegExp(r'^([ \t]*)(-{4,})([ \t]+)(-{4,})([ \t]+)-{4,}[ \t]*$');

  /// What may stand in the amount column: digits and fractions, or nothing.
  static final _amount = RegExp(r'^[\d /.,\-¼½¾⅓⅔⅛⅜⅝⅞]*$');

  /// The numbers a row starts with: "2", "1 1/2", "2-3".
  static final _leadingAmount = RegExp(r'^(?:[\d¼½¾⅓⅔⅛⅜⅝⅞][\d/.,\-¼½¾⅓⅔⅛⅜⅝⅞]*(?: +|$))+');

  /// The columns the rule [line] marks, or null when it is not the rule.
  static _Columns? fromRule(String line) {
    final match = _rule.firstMatch(line);
    if (match == null) return null;
    final left = match[1]!.length;
    final amountEnd = left + match[2]!.length;
    return _Columns(
      left,
      amountEnd,
      amountEnd + match[3]!.length + match[4]!.length + match[5]!.length,
      aligned: match[3]!.length > 1 && match[5]!.length > 1,
    );
  }

  /// The cells of one table row, or null when [line] does not keep to the
  /// columns: something other than an amount stands where the amount goes.
  ({String amount, String measure, String text})? cells(String line) {
    if (!aligned) {
      // No columns to go by. The amount is the numbers the row starts with,
      // and the measure stays in front of the ingredient, where it is read.
      final row = line.trim();
      final amount = _leadingAmount.stringMatch(row) ?? '';
      return (amount: amount, measure: '', text: row.substring(amount.length));
    }
    final amountCut = _afterWord(line, amountEnd);
    final amount = line.substring(0, amountCut).trim();
    if (!_amount.hasMatch(amount)) return null;
    final textCut = _afterWord(line, textStart < amountCut ? amountCut : textStart);
    return (
      amount: amount,
      measure: line.substring(amountCut, textCut),
      text: line.substring(textCut),
    );
  }

  /// Whether [line] starts to the right of the table's left edge. Rows may,
  /// the directions do not.
  bool isIndented(String line) => line.length - line.trimLeft().length > left;

  /// [cut], or the end of the word it would otherwise split: a measure too
  /// long for its column runs into the next one.
  static int _afterWord(String line, int cut) {
    if (cut >= line.length) return line.length;
    while (cut > 0 &&
        cut < line.length &&
        line.codeUnitAt(cut - 1) != 0x20 &&
        line.codeUnitAt(cut) != 0x20) {
      cut++;
    }
    return cut;
  }
}

/// One row of the ingredient table.
class _Row {
  _Row(this.amount, this.measure, this.text) : isTitle = false;

  /// A section title such as "CAKE" or "For the frosting".
  _Row.title(this.text)
      : amount = '',
        measure = '',
        isTitle = true;

  final String amount;
  final String measure;
  final bool isTitle;

  /// The ingredient and its preparation as MasterCook writes them,
  /// "apples -- sliced, peeled". Rows that continue this one are added to it.
  String text;

  /// The row as one ingredient line. A title ends in a colon, the form in
  /// which the rest of the app recognises a section heading.
  String get line {
    if (isTitle) return '$text:';
    var body = text;
    if (body.startsWith('-- ')) body = body.substring(3);
    if (body.endsWith(' --')) body = body.substring(0, body.length - 3);
    final parts = body.split(' -- ').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
    var name = parts.isEmpty ? '' : parts.first;
    // Some cooks end the name with a dash of their own.
    if (name.endsWith(' -')) name = name.substring(0, name.length - 2).trimRight();
    final preparation = parts.skip(1).join(', ');
    if (preparation.isNotEmpty) {
      name = preparation.startsWith('(') ? '$name $preparation' : '$name, $preparation';
    }
    return [amount, measure, name].where((s) => s.isNotEmpty).join(' ');
  }
}

/// A MasterCook recipe as read, before it becomes an [ImportedRecipe]. The
/// text export and the XML export carry the same fields, so both fill one of
/// these and the choices about where each field goes are made once.
class _MasterCookRecipe {
  String? title;
  String? author;

  /// The number of servings, when one is set.
  String? servings;

  /// How much the recipe makes: "2 cups", "15 drummettes".
  String? yieldText;

  int? prepMinutes;

  /// Start to finish.
  int? totalMinutes;

  /// The labelled times added up: bake, chill, rise.
  int otherMinutes = 0;

  String? description;
  String? cuisine;
  String? source;
  String? copyright;
  String? notes;
  String? servingIdeas;
  String? wine;
  String? imageData;

  /// Extra sources with the label the cook gave each ("Internet Address").
  final otherSources = <(String, String)>[];

  /// In the order they were written, each one once.
  final categories = <String>{};
  final rows = <_Row>[];
  final steps = <String>[];

  /// An ingredient is a line or two of text. A row that has grown past this
  /// takes no more rows in: by then a bracket left open somewhere is
  /// swallowing the table, and the rows below would be lost in it.
  static const _longestIngredient = 300;

  static final _spaces = RegExp(r'\s+');
  static final _wideGap = RegExp(r'\s{2,}');
  static final _leadingEquals = RegExp(r'^=+\s*');
  static final _leadingDashes = RegExp(r'^-{2,}\s*');
  static final _stepNumber = RegExp(r'^\d{1,2}[.)]\s+');
  static final _onlyRules = RegExp(r'^[\s\-_=*~#.]*$');
  static final _hasLetter = RegExp(r'[^\W\d_]|[^\x00-\x7F]');
  static final _webAddress = RegExp(r'^https?://\S+$', caseSensitive: false);

  /// A row above ends like this when it is not finished.
  static final _unfinished = RegExp(
    r'(?:[,&]|\b(?:and|or|with|plus)|\bsuch as)$',
    caseSensitive: false,
  );

  /// A row starts like this when it finishes the one above.
  static final _carriesOn = RegExp(
    r'^(?:[),;]|(?:and|or|with|into|in|plus)(?=\s|$))',
    caseSensitive: false,
  );

  /// Adds the categories on one line of the text export, which separates
  /// them with runs of spaces.
  void addCategories(String line) => line.trim().split(_wideGap).forEach(addCategory);

  void addCategory(String name) {
    final category = name.trim();
    if (category.isNotEmpty) categories.add(category);
  }

  /// A "Label:" block from under the directions of the text export.
  void setField(String label, String value) {
    if (value.isEmpty) return;
    switch (label.toLowerCase()) {
      case 'description':
        description = value;
      case 'cuisine':
        cuisine = value;
      case 'source':
        source = value;
      case 'copyright':
        copyright = value;
      case 'yield':
        yieldText = value;
      case 'start to finish time':
        totalMinutes = MasterCookImporter._minutes(value);
      default:
        // "T(Bake)" or "S(Internet Address)".
        final name = label.substring(2, label.length - 1).trim();
        if (label.toUpperCase().startsWith('T')) {
          otherMinutes += MasterCookImporter._minutes(value) ?? 0;
        } else {
          otherSources.add((name, value));
        }
    }
  }

  /// Adds a row of the ingredient table. A row with no amount and no measure
  /// is a section title, the rest of the row above, or an ingredient that has
  /// no quantity ("salt to taste").
  void addRow(String amount, String measure, String text, {bool isTitle = false}) {
    amount = amount.replaceAll(_spaces, ' ').trim();
    measure = measure.replaceAll(_spaces, ' ').trim();
    text = text.replaceAll(_spaces, ' ').trim();
    if (amount.isEmpty && measure.isEmpty) {
      // Nothing, or only a row of dashes.
      if (_onlyRules.hasMatch(text)) return;
      final title = _sectionTitle(text) ?? (isTitle ? text : null);
      if (title != null) {
        rows.add(_Row.title(title));
        return;
      }
      // Decoration with no words in it.
      if (_undecorated(text) != null) return;
      final above = rows.isEmpty ? null : rows.last;
      final joins = above != null &&
          !above.isTitle &&
          above.text.length < _longestIngredient &&
          _continues(above.text, text);
      // The "=" only marks the row as a continuation. The dashes do too, and
      // they also stand for the "--" that sets off the preparation.
      text = text.replaceFirst(_leadingEquals, '').replaceFirst(_leadingDashes, '-- ');
      if (above != null && joins) {
        above.text = '${above.text} $text';
        return;
      }
    }
    rows.add(_Row(amount, measure, text));
  }

  /// The text inside a decorated row such as "-----CAKE-----" or
  /// "=== SALAD ===", or null when the row is not decorated.
  static String? _undecorated(String text) {
    var start = 0;
    var end = text.length;
    while (start < end && _isRule(text.codeUnitAt(start))) {
      start++;
    }
    while (end > start && _isRule(text.codeUnitAt(end - 1))) {
      end--;
    }
    return (start >= 2 && text.length - end >= 2) ? text.substring(start, end).trim() : null;
  }

  /// The title in a decorated row or in a row such as "For the sauce:", or
  /// null when the row is not a section title.
  static String? _sectionTitle(String text) {
    final inner = _undecorated(text);
    var title = inner ?? text;
    if (title.endsWith(':')) {
      title = title.substring(0, title.length - 1).trimRight();
    } else if (inner == null) {
      return null;
    }
    return _hasLetter.hasMatch(title) ? title : null;
  }

  /// The characters a rule is drawn with: - = * _ ~ #
  static bool _isRule(int c) =>
      c == 0x2D || c == 0x3D || c == 0x2A || c == 0x5F || c == 0x7E || c == 0x23;

  /// Whether a row with no amount and no measure belongs to the row above.
  ///
  /// MasterCook does not wrap long ingredients: the cook carries on in the
  /// next row, and the file shows that row exactly like an ingredient with no
  /// quantity. So rows are only joined when the words say so. Joining on a
  /// guess would swallow real ingredients ("Salt -- to taste").
  static bool _continues(String above, String text) {
    // "-- finely chopped" carries on the preparation, and "= (or 1 cup
    // broth)" is how MasterCook cooks note an alternative.
    if (text.startsWith('--') || text.startsWith('=')) return true;
    if (_carriesOn.hasMatch(text) || _unfinished.hasMatch(above)) return true;
    return '('.allMatches(above).length > ')'.allMatches(above).length;
  }

  /// Adds direction text. A blank line starts a new step, and so does a line
  /// that opens with a step number. Any other line break is only wrapping.
  void addDirections(String text) {
    final step = StringBuffer();
    void endStep() {
      final written = step.toString().trim();
      // A line of dashes between steps is decoration.
      if (!_onlyRules.hasMatch(written)) steps.add(written);
      step.clear();
    }

    for (final raw in text.split('\n')) {
      var line = raw.trim();
      if (line.isEmpty) {
        endStep();
        continue;
      }
      final number = _stepNumber.firstMatch(line);
      if (number != null) {
        endStep();
        line = line.substring(number.end);
      }
      if (step.isNotEmpty) step.write(' ');
      step.write(line);
    }
    endStep();
  }

  /// The recipe for the app, or null when it has no title or holds neither
  /// ingredients nor steps.
  ImportedRecipe? toImported(String filename) {
    final title = this.title?.trim() ?? '';
    final ingredients = [for (final row in rows) row.line];
    if (title.isEmpty || (ingredients.isEmpty && steps.isEmpty)) return null;

    // The app's source field holds a web address or a citation. A web
    // address wins, and the named source then goes to the notes.
    String? link;
    final labelled = <String>[];
    for (final (label, value) in otherSources) {
      if (link == null && _webAddress.hasMatch(value)) {
        link = value;
      } else {
        labelled.add(label.isEmpty ? value : '$label: $value');
      }
    }

    final by = author?.trim() ?? '';
    final credits = <String>[
      // MasterCook writes "n/a" for an author that was left empty.
      if (by.isNotEmpty && by.toLowerCase() != 'n/a') 'Recipe by $by',
      if (link != null && source != null) 'Source: $source',
      ...labelled,
      if (copyright != null) 'Copyright: $copyright',
      if (servings != null && yieldText != null) 'Yield: $yieldText',
    ];
    final paragraphs = <String>[
      if (notes != null) notes!,
      if (servingIdeas != null) 'Serving ideas: $servingIdeas',
      if (wine != null) 'Suggested wine: $wine',
      if (credits.isNotEmpty) credits.join('\n'),
    ];

    // Baking, chilling and the like are the time the recipe takes beyond
    // its preparation. With none of them, start to finish less the
    // preparation says the same.
    int? cookMinutes = otherMinutes > 0 ? otherMinutes : null;
    final total = totalMinutes;
    if (cookMinutes == null && total != null && total > (prepMinutes ?? 0)) {
      cookMinutes = total - (prepMinutes ?? 0);
    }

    return ImportedRecipe(
      title: title,
      description: description,
      ingredients: ingredients,
      instructions: steps,
      servings: servings ?? yieldText,
      prepTimeMinutes: prepMinutes,
      cookTimeMinutes: cookMinutes,
      sourceUrl: link ?? source,
      notes: paragraphs.isEmpty ? null : paragraphs.join('\n\n'),
      tags: categories.isEmpty ? null : categories.toList(),
      cuisine: cuisine,
      suggestedCourse: ImportSupport.courseFor(categories),
      imageData: imageData,
      sourceApp: 'mastercook',
      sourceFile: filename,
    );
  }
}
