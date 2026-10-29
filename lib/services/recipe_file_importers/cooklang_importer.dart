import '../../models/imported_recipe.dart';
import 'import_fields.dart';

/// Imports recipes from Cooklang (.cook) files.
///
/// Cooklang is a markup language for recipes:
///   - Ingredients: @ingredient{} or @ingredient{amount%unit}
///   - Cookware: #cookware{} or #cookware{count}
///   - Timers: ~{time%unit} or ~timer{time%unit}
///   - Comments: -- line comment, [- block comment -]
///   - Metadata: >> key: value (at top of file), or a block of key: value
///     lines between two --- lines that opens the file
///   - Sections: = Name or == Name ==
///   - Notes: > text
///   - Steps: plain text lines (blank line = new step)
///
/// The braces show where a name of several words ends. A name of one word
/// does without them: "Add @salt and @ground black pepper{} to the #pot."
///
/// Example:
///   >> servings: 4
///   >> source: https://example.com
///
///   Preheat #oven{} to 350°F.
///
///   Mix @flour{2%cups} and @sugar{1/2%cup} in a #bowl{}.
///   Add @eggs{3} and stir for ~{5%minutes}.
///
///   Pour into a greased #baking pan{9x13 inch} and bake for ~{35%minutes}.
class CooklangImporter {
  CooklangImporter._();

  /// Whether [content] is written in Cooklang: it marks an ingredient the
  /// way only Cooklang does, as in "@flour{2%cups}". An at sign alone does
  /// not say so, nor a ">>" line: mail addresses and quoted mail have those.
  static bool looksLikeCooklang(String content) => _bracedIngredient.hasMatch(content);

  static final _bracedIngredient = RegExp(r'@[^\s@#~{}][^@#~{}\n]{0,40}\{[^{}\n]{0,60}\}');

  /// Parse a single .cook file.
  static ImportedRecipe import_(String content, String filename) {
    var text = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    if (text.startsWith('\u{FEFF}')) text = text.substring(1);

    final metadata = <String, List<String>>{};
    text = _takeFrontMatter(text, metadata);

    final ingredients = _IngredientList();
    final steps = <String>[];
    final notes = <String>[];

    // The paragraph being read: a step, or a note when it opened with ">".
    final paragraph = StringBuffer();
    var isNote = false;
    var separator = ' ';
    void endParagraph() {
      final written = _render(paragraph.toString(), isNote ? null : ingredients);
      if (written.isNotEmpty) (isNote ? notes : steps).add(written);
      paragraph.clear();
      isNote = false;
      separator = ' ';
    }

    for (final line in _withoutBlockComments(text).split('\n')) {
      final trimmed = line.trim();

      // Skip line comments
      if (trimmed.startsWith('--')) continue;

      // Remove inline comments
      var noComment = trimmed.contains('--')
          ? trimmed.substring(0, trimmed.indexOf('--')).trim()
          : trimmed;

      // Metadata lines: >> key: value
      if (noComment.startsWith('>>')) {
        final meta = noComment.substring(2).trim();
        final colonIdx = meta.indexOf(':');
        if (colonIdx > 0) {
          final key = meta.substring(0, colonIdx).trim().toLowerCase();
          final value = meta.substring(colonIdx + 1).trim();
          metadata[key] = [value];
        }
        continue;
      }

      // Blank line = end of current step
      if (noComment.isEmpty) {
        endParagraph();
        continue;
      }

      // Section lines: = Name or == Name ==. The name heads the steps that
      // follow, in the form the rest of the app recognises a heading by.
      if (noComment.startsWith('=')) {
        endParagraph();
        final name = _sectionName(noComment);
        if (name.isNotEmpty) steps.add(name.endsWith(':') ? name : '$name:');
        continue;
      }

      // Note lines: > text. A note is for the cook to read, not a step.
      // A line without ">" after a note starts a step again, so its
      // ingredients are not lost inside the note.
      if (isNote && !noComment.startsWith('>')) endParagraph();
      if (noComment.startsWith('>')) {
        if (!isNote) endParagraph();
        isNote = true;
        noComment = noComment.substring(1).trim();
      }

      // A backslash at the end of a line asks for a line break there.
      final breaksAfter = noComment.endsWith(r'\');
      if (breaksAfter) noComment = noComment.substring(0, noComment.length - 1).trimRight();

      if (paragraph.isNotEmpty) paragraph.write(separator);
      paragraph.write(noComment);
      separator = breaksAfter ? '\n' : ' ';
    }
    endParagraph();

    List<String> all(String key) => metadata[key] ?? const [];
    String? first(List<String> keys) {
      for (final key in keys) {
        for (final value in all(key)) {
          if (value.trim().isNotEmpty) return value.trim();
        }
      }
      return null;
    }

    // Build title from filename if no metadata title
    final title = first(const ['title']) ?? _titleFromFilename(filename);

    // Servings, and the amount the recipe makes ("500%ml") when it gives one.
    final servings = first(const ['servings', 'serves']);
    final made = all('yield').map((value) => value.replaceAll('%', ' ').trim()).join(', ');

    // Times. "time" is the whole of it, start to finish.
    final prepTime = ImportFields.minutes(first(const ['prep time', 'time.prep', 'prep']));
    var cookTime = ImportFields.minutes(first(const ['cook time', 'time.cook', 'cook']));
    final totalTime = ImportFields.minutes(first(const ['time required', 'time', 'duration', 'total time']));
    if (cookTime == null && totalTime != null && totalTime > (prepTime ?? 0)) {
      cookTime = totalTime - (prepTime ?? 0);
    }

    // The app's source field holds a web address or a citation. A web
    // address wins, and the named source then goes to the notes.
    var link = first(const ['source.url', 'url']);
    var source = first(const ['source.name', 'source']);
    if (link == null && ImportFields.isWebLink(source)) {
      link = source;
      source = null;
    }
    final author = first(const ['author', 'source.author']);

    // Tags from metadata. The course is one of the app's own when it has a
    // match for it, and a tag when it has none.
    final tags = <String>[];
    for (final value in all('tags')) {
      value.split(',').forEach((tag) => ImportFields.addTag(tags, tag));
    }
    final course = ImportFields.courseFrom([
      for (final value in [...all('course'), ...all('category')]) ...value.split(','),
    ], tags);

    final image = [...all('image'), ...all('images'), ...all('picture'), ...all('pictures')]
        .where(ImportFields.isWebLink)
        .firstOrNull;

    final credits = <String>[
      if (author != null) 'Recipe by $author',
      if (link != null && source != null) 'Source: $source',
      if (servings != null && made.isNotEmpty) 'Yield: $made',
    ];
    final allNotes = <String>[
      [...?metadata['notes'], ...notes].join('\n'),
      credits.join('\n'),
    ].where((n) => n.trim().isNotEmpty).join('\n\n');

    return ImportedRecipe(
      title: title,
      description: first(const ['description', 'introduction']),
      ingredients: ingredients.rows,
      instructions: steps,
      servings: servings ?? (made.isEmpty ? null : made),
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      imageUrl: image?.trim(),
      sourceUrl: link ?? source,
      notes: allNotes.isEmpty ? null : allNotes,
      tags: tags.isEmpty ? null : tags,
      cuisine: first(const ['cuisine']),
      suggestedCourse: course,
      sourceApp: 'cooklang',
      sourceFile: filename,
    );
  }

  /// The block of metadata that opens a file, between two --- lines.
  static final _frontMatter = RegExp(r'^\s*---[ \t]*\n([\s\S]*?)\n---[ \t]*(?:\n|$)');

  /// A line of that block that gives a key its value.
  static final _yamlKey = RegExp(r'^([\p{L}\p{N}_][^:]{0,60}?)[ \t]*:[ \t]*(.*)$', unicode: true);

  /// The mark after a key whose value is the indented text under it.
  static final _yamlTextMark = RegExp(r'^[|>][+-]?$');

  static final _spaceRun = RegExp(r'[ \t]{2,}');

  /// The name in a section line, which has equals signs before it and may
  /// have them after it: "== Ragu ==", "= Ragu".
  static String _sectionName(String line) {
    var start = 0;
    var end = line.length;
    while (start < end && line[start] == '=') {
      start++;
    }
    while (end > start && line[end - 1] == '=') {
      end--;
    }
    return line.substring(start, end).trim();
  }

  /// Reads the metadata block at the top of [text] into [metadata] and
  /// returns the text after it. Text that opens with no such block is
  /// returned as it is.
  static String _takeFrontMatter(String text, Map<String, List<String>> metadata) {
    final block = _frontMatter.firstMatch(text);
    final values = block == null ? null : _readFrontMatter(block[1]!);
    if (values == null) return text;
    metadata.addAll(values);
    return text.substring(block!.end);
  }

  /// Reads the "key: value" lines of a metadata block, which is written in
  /// YAML. A value may be a list, written [a, b] or as "- item" lines under
  /// its key, text that runs over the indented lines under its key, or keys
  /// of its own one level down, which are kept as "time.prep".
  ///
  /// Null when a line is none of these. The lines between two --- are then
  /// not metadata: an older file can use such lines as rules.
  static Map<String, List<String>>? _readFrontMatter(String block) {
    final values = <String, List<String>>{};
    String? key;
    // What joins the lines under the key when they are running text.
    String? joiner;
    void endKey() {
      if (key != null && joiner != null) values[key] = [values[key]!.join(joiner)];
    }

    for (final raw in block.split('\n')) {
      final line = raw.trim();
      final indented = raw.startsWith(' ') || raw.startsWith('\t');
      final inText = joiner != null && indented;
      if (line.isEmpty || (line.startsWith('#') && !inText)) continue;

      final isItem = line == '-' || line.startsWith('- ');
      if (key != null && (indented || isItem)) {
        final under = values[key]!;
        final nested = _yamlKey.firstMatch(line);
        if (inText) {
          under.add(line);
        } else if (isItem) {
          under.addAll(_yamlValues(line.substring(1)));
        } else if (nested != null && under.isEmpty) {
          values['$key.${nested[1]!.trim().toLowerCase()}'] = _yamlValues(nested[2]!);
        } else if (under.length == 1) {
          // A value that runs on to the next line.
          joiner = ' ';
          under.add(line);
        }
        continue;
      }

      final entry = indented ? null : _yamlKey.firstMatch(line);
      if (entry == null) return null;
      endKey();
      key = entry[1]!.trim().toLowerCase();
      final value = entry[2]!.trim();
      final isText = _yamlTextMark.hasMatch(value);
      joiner = !isText ? null : (value.startsWith('|') ? '\n' : ' ');
      values[key] = isText ? [] : _yamlValues(value);
    }
    endKey();
    return values.isEmpty ? null : values;
  }

  /// The value after a key as a list: the items of "[a, b]", or the one
  /// value. Quotes around a value are taken off.
  static List<String> _yamlValues(String value) {
    final text = value.trim();
    final isList = text.length >= 2 && text.startsWith('[') && text.endsWith(']');
    final values = <String>[];
    for (final raw in isList ? text.substring(1, text.length - 1).split(',') : [text]) {
      var item = raw.trim();
      if (item.length >= 2 && (item[0] == '"' || item[0] == "'") && item.endsWith(item[0])) {
        item = item.substring(1, item.length - 1);
      }
      if (item.isNotEmpty) values.add(item);
    }
    return values;
  }

  /// [text] without its [- block comments -]. One that is never closed is
  /// left as written.
  static String _withoutBlockComments(String text) {
    final kept = StringBuffer();
    var from = 0;
    while (true) {
      final open = text.indexOf('[-', from);
      final close = open < 0 ? -1 : text.indexOf('-]', open + 2);
      if (close < 0) break;
      kept.write(text.substring(from, open));
      from = close + 2;
    }
    kept.write(text.substring(from));
    return kept.toString();
  }

  /// Finds @ingredient, #cookware and ~timer. A name ends at its braces and
  /// never runs past another @, # or ~, so a name of one word written
  /// without braces cannot swallow the text up to the next "{". Without
  /// braces a name is one word that starts with a letter, which leaves
  /// "@350F", "#2" and "~20 minutes" in ordinary text alone.
  static final _token = RegExp(
    // 1 to 5: @name{amount%unit}(preparation) or @word, after the marks
    // Cooklang allows there. Not the @ of an e-mail address.
    r'(?<![\p{L}\p{N}])@([&?+@-]*)'
    r'(?:([^\s@#~{}][^@#~{}\n]*?)\{([^{}\n]*)\}(?:\(([^()@#~{}\n]*)\))?'
    r'|([\p{L}\p{M}_][\p{L}\p{M}\p{N}_]*(?:-[\p{L}\p{M}\p{N}_]+)*))'
    // 6 and 7: #name{} or #word.
    r'|#[&?+-]*(?:([^\s@#~{}][^@#~{}\n]*?)\{[^{}\n]*\}'
    r'|([\p{L}\p{M}_][\p{L}\p{M}\p{N}_]*(?:-[\p{L}\p{M}\p{N}_]+)*))'
    // 8 and 9: ~name{amount%unit} or ~{amount%unit}.
    r'|~([^\s@#~{}][^@#~{}\n]*?)?\{([^{}\n]*)\}',
    unicode: true,
  );

  /// [text] as a cook reads it: each ingredient and piece of cookware as its
  /// name, each timer as its time. The ingredients are added to [ingredients]
  /// when there is a list to fill.
  static String _render(String text, _IngredientList? ingredients) {
    return text.replaceAllMapped(_token, (m) {
      final ingredient = m[2] ?? m[5];
      if (ingredient != null) {
        final name = _name(ingredient);
        final preparation = (m[4] ?? '').trim();
        ingredients?.add(
          name,
          amount: _amount(m[3] ?? ''),
          preparation: preparation,
          optional: m[1]!.contains('?'),
        );
        return preparation.isEmpty ? name : '$name ($preparation)';
      }
      final cookware = m[6] ?? m[7];
      if (cookware != null) return _name(cookware);
      // A timer reads as its time, or as its name when it gives no time.
      final time = _amount(m[9]!);
      return time.isEmpty ? (m[8] ?? '').trim() : time;
    }).replaceAll(_spaceRun, ' ').trim();
  }

  /// The name in a token. Another recipe used as an ingredient is written as
  /// its path ("./sauces/Hollandaise") and goes by the last part of it.
  static String _name(String written) {
    final name = written.trim();
    if (!name.startsWith('./') && !name.startsWith('../')) return name;
    return name.split('/').lastWhere((part) => part.isNotEmpty, orElse: () => name);
  }

  /// What the braces of a token hold, in words: "2%tbsp" is "2 tbsp". A
  /// leading "=" only tells Cooklang not to scale the amount.
  static String _amount(String braces) {
    final text = braces.trim();
    return (text.startsWith('=') ? text.substring(1) : text)
        .split('%')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
  }

  /// Extract recipe title from filename (strip path and extension).
  static String _titleFromFilename(String filename) {
    var name = filename.split('/').last.split('\\').last;
    final dot = name.lastIndexOf('.');
    if (dot > 0) name = name.substring(0, dot);
    // Replace underscores/dashes with spaces and title-case
    return name
        .replaceAll(RegExp(r'[_-]'), ' ')
        .replaceAllMapped(
          RegExp(r'(^|\s)(\w)'),
          (m) => '${m.group(1)}${m.group(2)!.toUpperCase()}',
        )
        .trim();
  }
}

/// The ingredients of a recipe, in the order its steps first call for them.
class _IngredientList {
  final rows = <String>[];

  /// Where each ingredient stands in [rows], by its name in lower case.
  final _rowOf = <String, int>{};

  /// The ingredients whose row gives an amount.
  final _measured = <String>{};

  /// Lists an ingredient a step calls for. One that was listed before is not
  /// listed twice, unless the step asks for a further amount of it: that
  /// gets a row of its own, so no quantity is lost.
  void add(
    String name, {
    required String amount,
    required String preparation,
    required bool optional,
  }) {
    final key = name.toLowerCase();
    final row = [
      if (amount.isNotEmpty) '$amount ',
      name,
      if (preparation.isNotEmpty) ', $preparation',
      if (optional) ' (optional)',
    ].join();

    final listed = _rowOf[key];
    if (listed == null) {
      _rowOf[key] = rows.length;
      rows.add(row);
    } else if (amount.isEmpty) {
      return;
    } else if (_measured.contains(key)) {
      rows.add(row);
    } else {
      // The first mention gave no amount. This one does.
      rows[listed] = row;
    }
    if (amount.isNotEmpty) _measured.add(key);
  }
}
