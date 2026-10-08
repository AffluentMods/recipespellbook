import '../recipe_import_engine.dart';
import 'import_support.dart';

/// Readers for the small things every recipe app writes its own way: how long
/// a recipe takes, a numbered step, the course it is filed under.
class ImportFields {
  ImportFields._();

  /// No recipe takes longer than a year. A bigger number is a typing mistake
  /// or not a time at all.
  static const _longestTime = 366 * 24 * 60;

  static final _plainNumber = RegExp(r'^\d{1,6}(?:[.,]\d{1,3})?$');

  /// An ISO 8601 duration, lower-cased: "pt1h30m", "p1dt2h", "pt0s".
  static final _isoTime = RegExp(
    r'^p(?:(\d{1,6}(?:[.,]\d{1,3})?)d)?'
    r'(?:t(?:(\d{1,6}(?:[.,]\d{1,3})?)h)?'
    r'(?:(\d{1,6}(?:[.,]\d{1,3})?)m)?'
    r'(?:(\d{1,6}(?:[.,]\d{1,3})?)s)?)?$',
  );

  /// Hours and minutes as a clock shows them: "1:30", "0:45", "01:30:00".
  static final _clockTime = RegExp(r'(?<![\d:.,])(\d{1,3}):([0-5]\d)(?::[0-5]\d)?(?![\d:])');

  /// One amount of time in words: a number, which may be a decimal ("1.5",
  /// "1,5") or carry a fraction ("1 1/2", "½"), and its unit in English or
  /// one of the other languages people keep recipes in. Hours may be followed
  /// by bare minutes, as in "1h30".
  static final _timeInWords = RegExp(
    r'(\d{1,6}(?:[.,]\d{1,3})?)?(?:\s*(\d{1,3})/(\d{1,3})|\s*([½⅓⅔¼¾]))?\s*'
    r'(?:(hours?|hrs?|heures?|horas?|ore|ora|uur|uren|stunden?|std|h)(?![a-z])\.?'
    r'(?:\s*(\d{1,2})(?!\s*[a-z]|\d|[.,:/]\d))?'
    r'|(minutes?|minuten|minutos?|minuti|minuut|mins?|mn|m)(?![a-z])'
    r'|(days?|jours?|tage?|d[ií]as?|giorn[oi]|dagen|dag|d)(?![a-z]))',
  );

  static const _fractions = {'½': 1 / 2, '⅓': 1 / 3, '⅔': 2 / 3, '¼': 1 / 4, '¾': 3 / 4};

  /// How long [text] says, in minutes. It may be a bare number of minutes
  /// ("45"), words ("30 min", "1 hr 15 min", "1h30", "1 1/2 hours", "45 mn"),
  /// a clock time ("1:30") or an ISO 8601 duration ("PT1H30M"). Several
  /// amounts add up: "10 min (optional marinating 2 hr)" is 130.
  ///
  /// Null when there is no time in it, or the time is zero, which is how apps
  /// write one that was never set.
  static int? minutes(String? text) {
    // A time is a few words at most. Anything much longer is not one.
    if (text == null || text.length > 200) return null;
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return null;

    var total = 0.0;
    final iso = _isoTime.firstMatch(t);
    final clock = _clockTime.firstMatch(t);
    if (_plainNumber.hasMatch(t)) {
      total = _number(t);
    } else if (iso != null) {
      total = _number(iso[1]) * 1440 + _number(iso[2]) * 60 + _number(iso[3]) + _number(iso[4]) / 60;
    } else if (clock != null) {
      total = _number(clock[1]) * 60 + _number(clock[2]);
    } else {
      for (final m in _timeInWords.allMatches(t)) {
        var fraction = _fractions[m[4]];
        if (m[2] != null) {
          final below = _number(m[3]);
          fraction = below == 0 ? 0 : _number(m[2]) / below;
        }
        // A unit with no number in front of it is only a word.
        if (m[1] == null && fraction == null) continue;
        final amount = _number(m[1]) + (fraction ?? 0);
        if (m[5] != null) {
          total += amount * 60 + _number(m[6]);
        } else if (m[7] != null) {
          total += amount;
        } else {
          total += amount * 1440;
        }
      }
    }

    final minutes = total.round();
    return minutes > 0 && minutes <= _longestTime ? minutes : null;
  }

  static double _number(String? digits) =>
      digits == null ? 0 : double.tryParse(digits.replaceFirst(',', '.')) ?? 0;

  static final _stepNumber = RegExp(
    r'^(?:\d{1,3}[.)](?!\d)|step\s+\d{1,3}[:.)])\s*',
    caseSensitive: false,
  );

  /// [line] without the number its step was given ("1. ", "2) ", "Step 3: "),
  /// since the app numbers steps itself. A line that only starts with a
  /// quantity ("2.5 cm of oil goes into the pan.") is left alone.
  static String withoutStepNumber(String line) => line.replaceFirst(_stepNumber, '');

  static final _webLink = RegExp(r'^https?://\S', caseSensitive: false);

  /// Whether [text] is a web address, as opposed to the name of a book or of
  /// the person a recipe came from.
  static bool isWebLink(String? text) => text != null && _webLink.hasMatch(text.trim());

  /// Characters that take no room on screen. Apps leave them in text that
  /// was copied from a web page.
  static final _invisible = RegExp('[\u{200B}-\u{200D}\u{2060}\u{FEFF}]');
  static final _spaces = RegExp(r'\s+');

  /// [text] on one line: line breaks and runs of spaces become single spaces
  /// and invisible characters are dropped.
  static String oneLine(String text) =>
      text.replaceAll(_invisible, '').replaceAll(_spaces, ' ').trim();

  /// Adds [name] to [tags] unless it is blank or already there, however it is
  /// capitalised.
  static void addTag(List<String> tags, String? name) {
    final tag = name == null ? '' : oneLine(name);
    if (tag.isEmpty) return;
    final lower = tag.toLowerCase();
    if (tags.any((t) => t.toLowerCase() == lower)) return;
    tags.add(tag);
  }

  /// A label that is nothing more than the name of one of the app's courses.
  static final _courseName = RegExp(
    r'^(?:appetizer|beverage|breakfast|brunch|dessert|main|sauce|side|snack)(?:\s+(?:dish|course))?(?:e?s)?$',
    caseSensitive: false,
  );

  /// Chooses the course for a recipe filed under [labels] in the app it came
  /// from ("Main Course", "Soups", "Lunch"), and adds to [tags] every label
  /// that would otherwise be lost: one that no course was found for, and one
  /// that says more than the name of its course does ("Soups" is filed under
  /// main dishes, and stays a tag).
  static String? courseFrom(Iterable<String> labels, List<String> tags) {
    final course = ImportSupport.courseFor(labels);
    for (final label in labels) {
      final name = oneLine(label);
      final namesIt = _courseName.hasMatch(name) && RecipeImportEngine.mapToCourseId(name) == course;
      if (!namesIt) addTag(tags, name);
    }
    return course;
  }
}
