/// Lengths of time a recipe step names ("simmer for 10 minutes", "1 Stunde
/// ruhen lassen", "中火で5分"), for one-tap timers in cooking mode.
///
/// The import's time reader (ImportFields.minutes) reads a whole field and
/// adds up every amount in it; a step needs each time on its own, found
/// inside a sentence, in every language the app speaks.
library;

/// A number: "10", "1.5", "1,5", "1½", "1 1/2", "½", "1/2". Groups 1 to 7.
const _number =
    r'(?:(\d{1,3}(?:[.,]\d{1,2})?)(?:\s*([½¼¾⅓⅔])|\s+(\d)/(\d))?|([½¼¾⅓⅔])|(\d)/(\d))';

/// "10 to 15", "10-15", "10 bis 15": the second number is skipped; a timer
/// for the shorter time lets the cook check before it is overdone.
const _rangeTail =
    r'(?:\s*(?:-|–|—|~|〜|～|to|or|bis|oder|a|al|o|à|ou|tot|of|do|lub|до|или)\s*\d{1,3}(?:[.,]\d{1,2})?)?';

/// Units. Those of languages written with spaces need a word end; the CJK
/// ones are written against the next word ("5分ほど", "10分钟后"). Not the
/// Russian "ч": "1 ч. л." is a teaspoon. Not "分の": "3分の1" is a third.
const _hours =
    r'(?:(?:hours?|hrs?|h|stunden?|std\.?|horas?|heures?|ore|ora|uur|uren|godzin[aęy]?|godz\.?|час(?:а|ов)?)(?!\p{L})'
    r'|時間|시간|(?:个|個)?小时|(?:个|個)?小時|(?:个|個)?钟头)';
const _minutes =
    r'(?:(?:minutes?|mins?\.?|minuten?|minutos?|minuti|minuuts?|minut[aęy]?|минут[ауы]?|мин\.?)(?!\p{L})'
    r'|分钟|分鐘|分間|分(?!の)|분)';
const _seconds =
    r'(?:(?:seconds?|secs?\.?|sekunden?|sek\.?|segundos?|seg\.?|secondes?|secondi|secondo|seconden?|sekund[aęy]?|секунд[ауы]?|сек\.?)(?!\p{L})'
    r'|秒钟|秒鐘|秒間|秒|초)';

/// Not inside a number or a word of a language written with spaces ("x10",
/// "1/2"); straight after a CJK word is fine ("中火で5分").
const _before = r'(?<![\da-zA-ZÀ-ɏЀ-ӿ/.,])';

/// After the bare minutes of "1 h 30": no more digits, and no word but
/// "and" (so not "1 h 30 g"; "1 h 30 à 180 °C" is fine).
const _bareMinutesEnd =
    r'(?!\d|[.,:/]\d|\s*(?!(?:à|a|et|e|y|and|und|o|ou|en|i|и)(?!\p{L}))\p{L})';

/// Groups: 8 hours (9 the bare minutes after them, "1h30"), 10 minutes,
/// 11 seconds.
final _time = RegExp(
  '$_before$_number$_rangeTail'
  r'\s*-?\s*'
  '(?:($_hours)(?:'
  r'\s*(\d{1,2})'
  '$_bareMinutesEnd)?|($_minutes)|($_seconds))',
  unicode: true,
  caseSensitive: false,
);

/// What may stand between two amounts of one time: "1 hour and 15 minutes".
final _joiner = RegExp(r'^[\s,]*(?:and|und|y|et|e|en|i|и|과|와)?[\s,]*$', unicode: true);

const _fractions = {'½': 1 / 2, '¼': 1 / 4, '¾': 3 / 4, '⅓': 1 / 3, '⅔': 2 / 3};

/// The longest timer offered: two days. Anything longer is not a cooking
/// timer.
const _longest = 48 * 3600;

double _amount(RegExpMatch m) {
  if (m[6] != null) {
    final below = int.parse(m[7]!);
    return below == 0 ? 0 : int.parse(m[6]!) / below;
  }
  final whole = m[1];
  if (whole == null) return _fractions[m[5]] ?? 0;
  var n = double.tryParse(whole.replaceFirst(',', '.')) ?? 0;
  n += _fractions[m[2]] ?? 0;
  if (m[3] != null) {
    final below = int.parse(m[4]!);
    if (below != 0) n += int.parse(m[3]!) / below;
  }
  return n;
}

/// Every time [text] names, in seconds, in the order written and each once.
/// "1 hour 30 minutes" and "1h30" are one time of 5,400 seconds; a range
/// ("10 to 15 minutes") gives its shorter end.
List<int> stepDurations(String text) {
  final found = <int>[];
  var lastEnd = 0;
  var lastUnit = 0; // 3 hours, 2 minutes, 1 seconds: smaller ones add on
  for (final m in _time.allMatches(text)) {
    final amount = _amount(m);
    final int seconds;
    final int unit;
    if (m[8] != null) {
      seconds = (amount * 3600).round() + int.parse(m[9] ?? '0') * 60;
      unit = 3;
    } else if (m[10] != null) {
      seconds = (amount * 60).round();
      unit = 2;
    } else {
      seconds = amount.round();
      unit = 1;
    }
    if (seconds <= 0) continue;
    final addsOn = found.isNotEmpty &&
        unit < lastUnit &&
        _joiner.hasMatch(text.substring(lastEnd, m.start));
    if (addsOn) {
      found[found.length - 1] += seconds;
    } else {
      found.add(seconds);
    }
    lastEnd = m.end;
    lastUnit = unit;
  }
  return [
    for (final (i, s) in found.indexed)
      if (s <= _longest && found.indexOf(s) == i) s,
  ];
}
