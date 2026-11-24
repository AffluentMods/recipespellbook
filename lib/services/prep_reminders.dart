/// Prep reminders: what a planned meal needs done the evening before.
///
/// Two kinds of prep:
///  * Thawing: an ingredient the pantry only has in the freezer, when it is a
///    food that needs thawing (meat, poultry, fish and seafood, stock and
///    soup, bread and dough, cooked leftovers). Peas, berries, ice cream and
///    the like go into the dish frozen and need nothing.
///  * Time ahead written in the recipe (steps, ingredient lines, notes):
///    overnight, the night or day before, soaking dried beans or grains, or
///    marinating, brining, chilling, rising or resting for about four hours
///    or more. Short waits ("marinate for 30 minutes", "chill 1 hour") and
///    optional tips ("can be made the day before") are not prep.
///
/// Recipe text is matched in all twelve app languages as a best effort, with
/// accents folded (see [foldAccents]). Pure Dart: no Flutter, no database.
library;

import '../data/food_synonyms.dart' show canonicalizeFoodText;
import '../utils/ingredient_utils.dart' show getShoppingCategory;
import '../utils/text_normalize.dart' show foldAccents;
import 'pantry_matcher.dart';

/// What to do ahead for a planned meal.
enum PrepAction {
  /// Take something out of the freezer.
  thaw,

  /// Soak dried beans, chickpeas or grains.
  soak,

  /// Marinate or brine.
  marinate,

  /// Anything else that takes hours or a night: chill, rise, rest, set.
  ahead,
}

// ── Time ahead in recipe text ────────────────────────────────────────────

/// Overnight, the night before, the day before. Matched against text with
/// accents folded.
final _overnight = RegExp(
  // English.
  r'\bover ?night\b|\bthe (?:night|day|evening) before\b|\bday before\b'
  r'|\b(?:a|one|1) day (?:ahead|in advance|before)\b|\bthe previous (?:day|night|evening)\b'
  // German.
  r'|\buber nacht\b|\bvortag|\bam vorabend\b|\bam (?:abend|tag) (?:vorher|davor|zuvor)\b'
  r'|\b(?:einen|1) tag (?:vorher|zuvor|im voraus)\b|\beine nacht\b|\bdie ganze nacht\b'
  // Spanish.
  r'|\btoda la noche\b|\bdurante la noche\b|\buna noche\b|\bla noche (?:anterior|antes)\b'
  r'|\bel dia (?:anterior|antes)\b|\bla vispera\b|\bde un dia para otro\b|\bdesde la noche\b'
  // French.
  r'|\btoute la nuit\b|\bpendant la nuit\b|\bune nuit\b|\bla veille\b'
  r'|\ble jour (?:precedent|d.avant|avant)\b|\bla nuit (?:precedente|d.avant|avant)\b'
  // Italian.
  r'|\btutta la notte\b|\bper (?:una|la) notte\b|\bdurante la notte\b|\buna notte\b'
  r'|\b(?:la sera|il giorno|la notte|il di) (?:prima|precedente)\b'
  // Dutch.
  r'|\been nacht(?:je)?\b|\bnacht(?:je)? over\b|\bovernacht\b|\bde hele nacht\b|\bgedurende de nacht\b'
  r'|\b(?:avond|dag) (?:ervoor|van tevoren|tevoren)\b|\been dag (?:eerder|ervoor)\b'
  // Polish.
  r'|\b(?:przez|na) (?:cala )?noc\b|\bcala noc\b|\bdzien (?:wczesniej|przed)\b'
  r'|\bpoprzedniego (?:dnia|wieczoru)\b|\b(?:przez|na) dobe\b'
  // Portuguese.
  r'|\bdurante a noite\b|\ba noite (?:toda|inteira)\b|\btoda a noite\b|\bpor uma noite\b'
  r'|\bde um dia para o outro\b|\b(?:de|na) vespera\b|\bno dia anterior\b|\bna noite anterior\b'
  // Russian.
  r'|(?<!\p{L})на ночь(?!\p{L})|(?<!\p{L})всю ночь|в течение ночи|(?<!\p{L})накануне'
  r'|за день до|(?<!\p{L})сутки(?!\p{L})'
  // Japanese.
  r'|一晩|ひと晩|一夜|前日|前の晩|前夜|半日|オーバーナイト'
  // Korean.
  r'|하룻밤|밤새|전날|하루 전|반나절|하루 동안'
  // Chinese.
  r'|过夜|過夜|隔夜|一晚|整夜|前一天|前一晚|提前一天|一宿',
  unicode: true,
);

/// Spelled-out numbers before an hour or day unit, folded, and what each
/// counts as. "Several hours" counts as four (long enough), "a few" as
/// three (not).
const _numberWords = <String, double>{
  // English.
  'four': 4, 'five': 5, 'six': 6, 'eight': 8, 'ten': 10, 'twelve': 12,
  'twenty four': 24, 'twenty-four': 24, 'several': 4, 'few': 3,
  // German.
  'vier': 4, 'funf': 5, 'sechs': 6, 'acht': 8, 'zehn': 10, 'zwolf': 12,
  'vierundzwanzig': 24, 'mehrere': 4, 'einige': 4, 'paar': 3,
  // Spanish.
  'cuatro': 4, 'cinco': 5, 'seis': 6, 'ocho': 8, 'diez': 10, 'doce': 12,
  'veinticuatro': 24, 'varias': 4,
  // French.
  'quatre': 4, 'cinq': 5, 'huit': 8, 'dix': 10, 'douze': 12,
  'vingt-quatre': 24, 'plusieurs': 4, 'quelques': 3,
  // Italian.
  'quattro': 4, 'cinque': 5, 'sei': 6, 'otto': 8, 'dieci': 10, 'dodici': 12,
  'ventiquattro': 24, 'diverse': 4, 'alcune': 3, 'qualche': 3,
  // Dutch.
  'vijf': 5, 'zes': 6, 'tien': 10, 'twaalf': 12, 'vierentwintig': 24,
  'meerdere': 4, 'enkele': 3,
  // Polish.
  'cztery': 4, 'piec': 5, 'szesc': 6, 'osiem': 8, 'dziesiec': 10,
  'dwanascie': 12, 'kilka': 4, 'kilkanascie': 12,
  // Portuguese.
  'quatro': 4, 'oito': 8, 'dez': 10, 'doze': 12, 'vinte e quatro': 24,
  'algumas': 3,
  // Russian.
  'четыре': 4, 'пять': 5, 'шесть': 6, 'восемь': 8, 'десять': 10,
  'двенадцать': 12, 'несколько': 4,
  // Japanese, Korean and Chinese.
  '二十四': 24, '十二': 12, '十': 10, '八': 8, '六': 6, '五': 5, '四': 4,
  '数': 4, '數': 4, '几': 4, '幾': 4, '몇': 4,
};

final _cjkScript = RegExp(r'[぀-ヿ㐀-鿿가-힯]');

/// A number, as digits or one of [_numberWords]. Words in a Latin or
/// Cyrillic script stand on their own; CJK ones are written against the
/// words around them.
final String _number = () {
  String alternation(Iterable<String> words) {
    final sorted = words.toList()..sort((a, b) => b.length.compareTo(a.length));
    return sorted.map((w) => w.replaceAll(' ', r'\s+').replaceAll('-', r'[\s-]?')).join('|');
  }

  final cjk = _numberWords.keys.where(_cjkScript.hasMatch);
  final spaced = _numberWords.keys.where((w) => !_cjkScript.hasMatch(w));
  return r'(?:\d+(?:[.,]\d+)?[½¼¾]?'
      '|(?<!\\p{L})(?:${alternation(spaced)})(?!\\p{L})'
      '|${alternation(cjk)})';
}();

/// Joins the two ends of a range ("4 to 6 hours", "8-12 Stunden").
const _rangeJoin = r'(?:-|\u2013|\u2014|~|〜|～|to|bis|a|al|ou|o|or|of|tot|do|lub|ate|до|или|到|至)';

const _hourUnit = r'(?:(?:hours?|hrs?|h|std|stunden?|horas?|heures?|ore|ora|uur|uren|godzin[aey]?|godz'
    r'|час(?:а|ов)?|ч)(?!\p{L})|時間|시간|个小时|個小時|小时|小時|钟头|鐘頭)';
const _dayUnit = r'(?:(?:days?|tag(?:e|en)?|dias?|jours?|giorn[oi]|dag(?:en)?|dzien|dni|dob[ey]?'
    r'|день|дн(?:я|ей)|сут(?:ки|ок))(?!\p{L})|日間|日|天|일)';
const _minuteUnit = r'(?:(?:min[a-z]*|мин\p{L}*)(?!\p{L})|分钟|分鐘|分|분)';

/// A length of time: its (first) number, then hours, days or minutes.
final _duration = RegExp(
  '(?<n>$_number)\\+?(?:\\s*$_rangeJoin\\s*$_number)?\\s*'
  '(?:(?<h>$_hourUnit)|(?<d>$_dayUnit)|(?<m>$_minuteUnit))',
  unicode: true,
);

/// Hours of a [_duration] match: the lower end of a range, days as 24.
double _hoursOf(RegExpMatch m) {
  final raw = m.namedGroup('n')!.replaceAll(RegExp(r'\s+'), ' ').replaceAll(',', '.');
  final digits = RegExp(r'^\d+(?:\.\d+)?').stringMatch(raw);
  var n = digits != null
      ? double.parse(digits) + (raw.contains('½') ? .5 : 0)
      : _numberWords[raw] ?? _numberWords[raw.replaceAll(' ', '-')] ?? 0;
  if (m.namedGroup('d') != null) n *= 24;
  if (m.namedGroup('m') != null) n /= 60;
  return n;
}

/// The least that counts as prep the evening before.
const _longHours = 4.0;

/// "Or" and "up to" just before a time: an alternative or a limit, not what
/// the recipe needs ("30 minutes or overnight", "refrigerate up to 3 days").
final _alternativeBefore = RegExp(
  r'(?<!\p{L})(?:or|oder|o|ou|of|lub|albo|up to|bis|bis zu|hasta|jusqu.a|fino a|tot|ate|или|либо|до)'
  r'(?:\s+(?:even|sogar|auch|incluso|hasta|meme|jusqu.a|anche|fino a|zelfs|tot|nawet|do|mesmo|ate|даже|до))?\s+$'
  r'|(?:〜|～|~|または|또는|에서|이나|到|至|或)\s*$',
  unicode: true,
);

bool _isAlternative(String s, int start) {
  final from = start > 30 ? start - 30 : 0;
  return _alternativeBefore.hasMatch(s.substring(from, start));
}

/// Thawing written in the recipe ("thaw the chicken overnight").
final _thawVerb = RegExp(
  r'\bthaw|\bdefrost|auftau|aufgetaut|descongel|decongel|scongel|ontdooi|rozmroz|rozmraz'
  r'|(?<!\p{L})(?:размороз|разморажив|оттаи|оттая)|解凍|해동|解冻',
  unicode: true,
);

/// Soaking.
final _soakVerb = RegExp(
  r'\bsoak|einweich|eingeweicht|\bquellen\b|\bremoj|\btremp(?:er|e|ez|es|age)\b|\bammoll'
  r'|\binweken\b|\bingeweekt\b|\bgeweekt\b|\bweken\b|\bweekt\b|\bnamocz|\bmoczy|\bdemolh|\bde molho\b'
  r'|(?<!\p{L})(?:замоч|замач|вымоч|вымач)'
  r'|浸け|浸す|浸して|水につけ|水に漬け|戻し|戻す|불려|불리|불린|불림|담가|담그|浸泡|泡发|泡發|泡水|泡软|泡軟|泡一',
  unicode: true,
);

/// Marinating, brining, curing.
final _marinateVerb = RegExp(
  r'\bmarina(?:te|tes|ted|ting|de|des)\b|\bbrin(?:e|es|ed|ing)\b|\bcur(?:e|es|ed|ing)\b'
  r'|marinier|\bbeize|\beinleg|\beingelegt|\bpokel'
  r'|\bmarin(?:ar|ad[oa]s?|e|en|a|ando|er|ez|es|ee|ees|age|are|ata|ate|ato|ati|atura|eren|eer|eert)\b'
  r'|\badob(?:ar|ad[oa]s?|o|e|a)\b|\bsalmuera|\bsaumure|\bsalamoia|\bgemarineerd|\bpekel'
  r'|\bmarynow|\bmarynat|\bzamarynow|\bzamarynuj|\bsolank|\bpeklow|\bsalmoura|\bvinha.d.alhos'
  r'|(?<!\p{L})(?:маринов|маринад|замарин|рассол)'
  r'|漬け|漬込|マリネ|下味|재워|재우|재운|절여|절이|절인|마리네이드|腌|醃|卤|滷',
  unicode: true,
);

/// Chilling, rising, resting, setting, freezing: waits that need a long
/// time to count.
final _restVerb = RegExp(
  r'\bchill|\brefriger|\bfridge\b|\bfreez|\brise\b|\brising\b|\bproof|\bprove\b|\bprov(?:ing|ed)\b'
  r'|\brest(?:s|ed|ing)?\b|\bferment|\bset\b|\bfirm(?:s|ed)? up\b|\bcool\b|\bcongel'
  r'|\bkuhl|\bkalt (?:stellen|gestellt)|\bkaltstellen|\bgehen lassen|\bruhen|\bfest werden|\bgefrier'
  r'|\beinfrier|\bdurchziehen|\bziehen lassen'
  r'|\bnevera\b|\bfrigorifico\b|\bheladera\b|\brepos(?:ar|e|o|ando|er|ez)\b|\bleud|\blevar\b|\bcuaj|\benfri'
  r'|\bfrigo\b|\bfrigidaire\b|\blever\b|\bpousser\b|\bprendre\b|\brefroidi'
  r'|\bfrigorifero\b|\bripos(?:are|o|a)\b|\blievita(?:re|zione|to)?\b|\brassod|\braffredd'
  r'|\bkoelkast\b|\bkoel|\brusten\b|\brijzen\b|\bgisten\b|\bopstijven\b|\bstijf worden\b|\binvriez|\bvriezer\b|\bafkoelen\b'
  r'|\blodowk|\bchlodz|\bschlodz|\bodpocz|\bwyrast|\bwyrosn|\bstezec|\btezec|\bzamroz|\bzamraz|\bostud'
  r'|\bgeladeira\b|\bdescans|\brepous|\bcrescer\b|\blevedar\b|\bfirmar\b|\besfri'
  r'|(?<!\p{L})(?:холодильник|охлад|отдохн|отдых|подня|подойд|расстой|расстаив|броди|брожени|ферментир|засты|заморо|остуд|осты)'
  r'|冷蔵|冷やし|冷やす|寝かせ|寝かす|休ませ|発酵|冷凍|固め|冷ま|냉장|숙성|발효|휴지|굳히|굳혀|식혀|냉동'
  r'|冷藏|冰箱|醒|发酵|發酵|静置|靜置|冷却|冷卻|凝固|冷冻|放凉|放涼',
  unicode: true,
);

/// Dried beans, chickpeas and grains: "soak the beans" needs a night even
/// when no time is written.
final _soakable = RegExp(
  r'\bbeans?\b|\bchick ?peas?\b|\bgarbanzos?\b|\blegumes?\b|\bpulses\b|\bsplit peas\b|\bdried peas\b'
  r'|\bgrains\b|\bwheat berries\b|\bbarley\b|\bfarro\b|\bspelt\b|\bbuckwheat\b|\boats\b|\bfreekeh\b'
  r'|bohnen|kichererbsen|hulsenfruchte|\berbsen|\blinsen|graupen|getreide|\bdinkel'
  r'|\bfrijoles\b|\bjudias\b|\balubias\b|\blegumbres\b|\bhabas\b|\bporotos\b|\blentejas\b|\bcebada\b'
  r'|\bharicots\b|\bpois chiches\b|\blegumineuses\b|\blegumes secs\b|\bfeves\b|\blentilles\b|\borge\b|\bflageolets\b'
  r'|\bfagioli\b|\bceci\b|\blegumi\b|\bfave\b|\blenticchie\b|\borzo\b'
  r'|bonen\b|\bkikkererwten\b|\bpeulvruchten\b|\berwten\b|\blinzen\b|\bgerst\b'
  r'|\bfasol|\bciecierzyc|\bgroch|\bsoczewic|\bstraczk|\bkasz[aeyi]\b'
  r'|\bfeijao|\bfeijoes|\bgraos?.de.bico|\bleguminosas\b|\bfavas\b|\blentilhas\b|\bcevada\b'
  r'|(?<!\p{L})(?:фасол|нут(?!\p{L})|нута|нутом|горох|боб|чечевиц|перловк|крупу|крупа)'
  r'|豆(?!腐|乳|浆|漿|苗|瓣|豉|板)|あずき|穀物|콩|팥|곡물|보리|잡곡|谷物|杂粮|雜糧',
  unicode: true,
);

/// A tip rather than a step: what can be done ahead, how it keeps,
/// leftovers. Such a sentence is never prep.
final _optionalTip = RegExp(
  // English.
  r'\bcan (?:be|also)\b|\bmay be\b|\bcould be\b|\bif desired\b|\bif time allows\b'
  r'|\bif you (?:like|wish|prefer|want|have (?:the )?time)\b|\boptional(?:ly)?\b'
  r'|\b(?:will )?keeps? (?:well|for up to|up to|in the (?:fridge|freezer|refrigerator) for)\b|\bwill keep\b'
  r'|\bleftovers?\b|\bmake.ahead\b|\bstorage\b'
  // German.
  r'|\bkann\b|\bkonnen\b|\bkonnt\b|\bnach belieben\b|\bwer mag\b|\bbei bedarf\b|\breste\b'
  r'|\baufbewahr|\bhalt sich\b|\bhaltbar\b'
  // Spanish.
  r'|\bse puede[ns]?\b|\bpuede[sn]?\b|\bsi (?:lo )?(?:desea|prefiere|quiere)s?\b|\bopcional|\bsobras\b'
  r'|\bse conserva|\bse mantiene'
  // French.
  r'|\bpeu(?:t|vent|x)\b|\bpouvez\b|\bsi vous (?:le )?(?:souhaitez|voulez|preferez)\b|\bfacultati'
  r'|\boptionnel|\brestes\b|\bse conserve'
  // Italian.
  r'|\bsi (?:puo|possono)\b|\bpuoi\b|\bpotete\b|\bse (?:volete|preferite|desiderate)\b|\bfacoltativ'
  r'|\bavanzi\b|\bsi conserva'
  // Dutch.
  r'|\bkan\b|\bkun(?:t|nen)?\b|\bindien gewenst\b|\bnaar wens\b|\boptioneel\b|\brestjes\b|\bhoudbaar\b|\bbewa(?:ar|ren)\b'
  // Polish.
  r'|\bmozna\b|\bmozesz\b|\bmozecie\b|\bopcjonaln|\bwedle uznania\b|\bresztki\b|\bprzechowyw'
  // Portuguese.
  r'|\bpode[ms]?\b|\bse (?:preferir|quiser|desejar)\b|\barmazen'
  // Russian.
  r'|(?<!\p{L})(?:можно|по желанию|остатки|хранит|хранени|если хотите)'
  // Japanese, Korean, Chinese.
  r'|できます|お好みで|作り置き|원하면|기호에|보관|可提前|也可|亦可|剩余|剩下|可选|可選',
  unicode: true,
);

/// Sentence ends: a full stop before a space or the end (not "1.5"), other
/// end marks, line breaks.
final _sentenceEnd = RegExp(r'[。！？!?;；\n\r]+|\.(?=\s|$)');

/// What one sentence (accents folded) asks to do ahead, or null.
PrepAction? _actionIn(String s) {
  if (s.trim().isEmpty || _optionalTip.hasMatch(s)) return null;
  final thaw = _thawVerb.hasMatch(s);
  final soak = _soakVerb.hasMatch(s);
  final marinate = _marinateVerb.hasMatch(s);
  final wait = thaw || soak || marinate || _restVerb.hasMatch(s);
  PrepAction kind() => thaw
      ? PrepAction.thaw
      : soak
          ? PrepAction.soak
          : marinate
              ? PrepAction.marinate
              : PrepAction.ahead;

  for (final m in _overnight.allMatches(s)) {
    if (!_isAlternative(s, m.start)) return kind();
  }
  var timed = false;
  for (final m in _duration.allMatches(s)) {
    timed = true;
    if (wait && _hoursOf(m) >= _longHours && !_isAlternative(s, m.start)) return kind();
  }
  // "Soak the beans": dried beans and grains soak overnight unless a
  // (shorter) time is given.
  if (soak && !timed && _soakable.hasMatch(s)) return PrepAction.soak;
  return null;
}

/// The sentences of [text], accents folded, each with what it asks to do
/// ahead. Sentences that ask nothing are left out.
List<(PrepAction, String)> prepCuesIn(String text) {
  // Full-width digits ("８時間") as plain ones.
  final folded = foldAccents(text).replaceAllMapped(
    RegExp('[０-９]'),
    (m) => String.fromCharCode(m[0]!.codeUnitAt(0) - 0xFF10 + 0x30),
  );
  return [
    for (final sentence in folded.split(_sentenceEnd))
      if (_actionIn(sentence) case final action?) (action, sentence),
  ];
}

/// What [text] asks to do ahead (thawing first, then soaking, marinating,
/// then any other wait), or null when nothing.
PrepAction? prepActionIn(String text) {
  PrepAction? best;
  for (final (action, _) in prepCuesIn(text)) {
    if (best == null || action.index < best.index) best = action;
  }
  return best;
}

// ── Thawing ──────────────────────────────────────────────────────────────

/// Frozen foods that go into the dish (or the oven) frozen: no thawing.
/// Checked before [_thawFoods], so "fish sticks" are not fish to thaw.
final _usedFrozen = RegExp(
  // English.
  r'\bpeas\b|\bpea\b|\bcorn\b|\bsweetcorn\b|\bberr(?:y|ies)\b|\bfruits?\b(?! de mer)|\bice\b|\bice cream\b|\bsorbet\b'
  r'|\bgelato\b|\bvegetables?\b|\bveg\b|\bveggies\b|\bspinach\b|\bedamame\b|\bfries\b|\bchips\b|\btater tots\b'
  r'|\bnuggets\b|\bfish (?:sticks|fingers)\b|\bpizza\b|\bdumplings?\b|\bgyoza\b|\bpotstickers?\b|\bpierogi\b'
  r'|\bwaffles?\b|\bhash browns\b|\b(?:spring|egg) rolls\b|\bmango\b|\bcherries\b|\bbroccoli\b|\bcauliflower\b|\bgreen beans\b'
  // German.
  r'|\berbsen\b|\bmais\b|\bbeeren\b|\bobst\b|\beis\b|\beiswurfel|\bgemuse|\bspinat\b|\bpommes\b|\bfischstabchen'
  r'|\bmaultaschen\b|\bkroketten\b'
  // Spanish.
  r'|\bguisantes\b|\bchicharos\b|\bmaiz\b|\bbayas\b|\bfrutos rojos\b|\bfrutas?\b|\bhielo\b|\bhelados?\b'
  r'|\bverduras\b|\bespinacas?\b|\bpatatas fritas\b|\bpapas fritas\b|\bempanadillas\b'
  // French.
  r'|\bpetits pois\b|\bbaies\b|\bfruits rouges\b|\bglaces?\b|\bglacons\b|\blegumes\b|\bepinards\b|\bfrites\b'
  // Italian.
  r'|\bpiselli\b|\bfrutti di bosco\b|\bfrutta\b|\bghiaccio\b|\bverdur[ae]\b|\bspinaci\b|\bpatatine\b'
  // Dutch.
  r'|\berwten\b|\bdoperwten\b|\bbessen\b|\bijs\b|\bijsblokjes\b|\bgroenten?\b|\bspinazie\b|\bfriet\b|\bpatat\b'
  // Polish.
  r'|\bgroszek\b|\bkukurydz|\bjagody\b|\bowoce\b|\blody\b|\blod\b|\bwarzywa\b|\bszpinak\b|\bfrytki\b|\bpierogi\b'
  // Portuguese.
  r'|\bervilhas?\b|\bmilho\b|\bfrutas vermelhas\b|\bgelo\b|\bsorvetes?\b|\blegumes\b|\bespinafre\b|\bbatatas? fritas?\b'
  // Russian.
  r'|(?<!\p{L})(?:горош|кукуруз|ягод|фрукт|л[её]д|мороженое|овощ|шпинат|картофель фри|пельмен|вареник)'
  // Japanese.
  r'|グリンピース|コーン|ベリー|アイス|氷|野菜|ほうれん草|ポテト|餃子|枝豆'
  // Korean.
  r'|완두콩|옥수수|베리|아이스크림|얼음|채소|야채|시금치|감자튀김|만두|에다마메'
  // Chinese.
  r'|豌豆|玉米|浆果|漿果|冰淇淋|冰激凌|冰块|冰塊|蔬菜|菠菜|薯条|薯條|饺子|餃子|水饺|水餃|汤圆|湯圓|毛豆',
  unicode: true,
);

/// Dough, pastry and bread: thawed even where a word of [_usedFrozen]
/// is in the name ("pizza dough").
final _doughFoods = RegExp(
  r'\bdough\b|\bpastry\b|\bpie crust\b|\btortillas?\b|\bteig\b|teig\b|\bmasa\b|\bhojaldre\b|\bpate (?:feuilletee|brisee|sablee|a)\b'
  r'|\bimpasto\b|\bpasta (?:sfoglia|brisee|frolla)\b|\bdeeg\b|deeg\b|\bciast[oa]\b|\bmassa (?:folhada|de)\b'
  r'|(?<!\p{L})тесто|生地|パイシート|반죽|面团|麵團|酥皮',
  unicode: true,
);

/// Foods that need thawing: meat, poultry, fish and seafood, stock and soup,
/// bread, sauces and cooked leftovers.
final _thawFoods = RegExp(
  // English.
  r'\bchicken\b|\bbeef\b|\bpork\b|\blamb\b|\bmutton\b|\bveal\b|\bturkey\b|\bduck\b|\bgoose\b|\bvenison\b'
  r'|\brabbit\b|\bmince\b|\bminced\b|\bground (?:beef|pork|lamb|turkey|chicken|meat)\b|\bsteaks?\b|\bchops?\b'
  r'|\broast\b|\bribs?\b|\bbrisket\b|\bsausages?\b|\bbacon\b|\bham\b|\bfillets?\b|\bfilets?\b|\bthighs?\b'
  r'|\bbreasts?\b|\bwings?\b|\bdrumsticks?\b|\btenderloin\b|\bloin\b|\bmeat\b|\bpoultry\b|\bfish\b'
  r'|\bsalmon\b|\bcod\b|\btuna\b|\bhaddock\b|\bhalibut\b|\btrout\b|\btilapia\b|\bsea bass\b|\bprawns?\b'
  r'|\bshrimps?\b|\bscallops?\b|\bsquid\b|\bcalamari\b|\boctopus\b|\bmussels\b|\bclams\b|\bcrabs?\b'
  r'|\blobsters?\b|\bseafood\b|\bstock\b|\bbroth\b|\bsoup\b|\bstew\b|\bsauce\b|\bragu\b|\bbolognese\b'
  r'|\bleftovers?\b|\bcooked\b|\bcasserole\b|\blasagne?a?\b|\bbread\b|\brolls\b|\bbuns\b|\bbagels?\b'
  r'|\btortillas?\b|\bpitas?\b|\bnaan\b|\bcake\b'
  // German.
  r'|hahnchen|\bhuhn|huhnchen|\bhuhner|\bhendl|geflugel|\bpute|truthahn|\bente\b|\benten|\bgans\b|\bganse'
  r'|\brind|schwein|\blamm|\bkalb|\bwildfleisch|kaninchen|\bhack|fleisch|schnitzel|kotelett|braten\b'
  r'|rippchen|wurst|wurstchen|\bspeck\b|schinken|keule|brust|schenkel|flugel|fisch|lachs|kabeljau|dorsch'
  r'|forelle|garnelen|\bkrabben|scampi|muscheln|tintenfisch|meeresfruchte|bruhe|\bfond\b|suppe|eintopf'
  r'|\bsosse\b|\breste\b|\bbrot|brotchen|\bsemmel|kuchen'
  // Spanish.
  r'|\bpollo\b|\bpechugas?\b|\bmuslos?\b|\balitas\b|\bcontramuslos?\b|\bternera\b|\bres\b|\bcarne\b'
  r'|\bcerdo\b|\bpuerco\b|\bcordero\b|\bpavo\b|\bpato\b|\bconejo\b|\bchuletas?\b|\bcostillas\b'
  r'|\bsolomillo\b|\blomo\b|\bfiletes?\b|\bbistec\b|\bsalchichas?\b|\bchorizo\b|\btocino\b|\bpanceta\b'
  r'|\bjamon\b|\bpescado\b|\bsalmon\b|\bmerluza\b|\bbacalao\b|\batun\b|\bdorada\b|\blubina\b|\btrucha\b'
  r'|\bgambas\b|\bcamarones\b|\blangostinos\b|\bcalamares\b|\bpulpo\b|\bmejillones\b|\balmejas\b'
  r'|\bmariscos\b|\bcaldo\b|\bsopa\b|\bguiso\b|\bestofado\b|\bsalsa\b|\bpan(?:es)?\b|\bbizcocho\b|\btarta\b'
  // French.
  r'|\bpoulet\b|\bvolaille\b|\bdinde\b|\bcanard\b|\boie\b|\bboeuf\b|\bveau\b|\bporc\b|\bagneau\b|\bmouton\b'
  r'|\blapin\b|\bgibier\b|\bviande\b|\bhachee?\b|\bcotelettes?\b|\bcotes\b|\broti\b|\bcuisses?\b'
  r'|\bblancs? de\b|\bailes\b|\bmagret\b|\bsaucisses?\b|\blardons\b|\bjambon\b|\bpoisson\b|\bsaumon\b'
  r'|\bcabillaud\b|\bmorue\b|\bthon\b|\btruite\b|\bcolin\b|\bmerlu\b|\bcrevettes\b|\bsaint.jacques\b'
  r'|\bseiche\b|\bpoulpe\b|\bmoules\b|\bpalourdes\b|\bfruits de mer\b|\bbouillon\b|\bsoupe\b|\bpotage\b'
  r'|\bragout\b|\brestes\b|\bpain\b|\bbaguettes?\b|\bbrioche\b|\bgateau\b'
  // Italian.
  r'|\bpetto\b|\bcosce\b|\bcoscia\b|\bsovracosce\b|\bali\b|\btacchino\b|\banatra\b|\boca\b|\bmanzo\b'
  r'|\bvitello\b|\bmaiale\b|\bagnello\b|\bconiglio\b|\bmacinat[oa]\b|\bbistecc(?:a|he)\b|\bbraciol[ae]\b'
  r'|\bcostine\b|\barrosto\b|\bfiletto\b|\blonza\b|\bsalsicc(?:ia|e)\b|\bprosciutto\b|\bpesce\b'
  r'|\bsalmone\b|\bmerluzzo\b|\bbaccala\b|\btonno\b|\borata\b|\bbranzino\b|\bspigola\b|\btrota\b'
  r'|\bgamber(?:i|etti)\b|\bseppie\b|\bpolpo\b|\bcozze\b|\bvongole\b|\bfrutti di mare\b|\bbrodo\b'
  r'|\bzuppa\b|\bminestra\b|\bstufato\b|\bsugo\b|\bavanzi\b|\bpane\b|\bpanini\b|\bfocaccia\b|\btorta\b'
  // Dutch.
  r'|\bkip|\bgevogelte\b|\bkalkoen\b|\beend\b|\brundvlees\b|\bvarken|\blams?vlees\b|\bkalfs?vlees\b'
  r'|\bkonijn\b|\bgehakt\b|\bvlees\b|\bbiefstuk\b|\bkarbonade\b|\bspareribs\b|\bworst|\bspek\b'
  r'|\bdijen\b|\bvleugels\b|\bvis\b|\bvisfilet|\bzalm\b|\bkabeljauw\b|\btonijn\b|\bforel\b|\bgarnalen\b'
  r'|\binktvis\b|\bmosselen\b|\bzeevruchten\b|\bsoep\b|\bstoofpot\b|\bsaus\b|\brestjes\b|\bbrood|\btaart\b'
  // Polish.
  r'|\bkurczak|\bkurcz[eę]|\bindyk|\bkaczk|\bwolow|\bwieprzow|\bschab|\bkarkow|\bcielec|\bjagniec|\bbaranin'
  r'|\bkrolik|\bmies(?:o|a|em)\b|\bmielon|\bkotlet|\bzeberk|\bkielbas|\bboczek|\bszynk|\bryb[ay]?\b'
  r'|\bloso|\bdorsz|\btunczyk|\bpstrag|\bkrewet|\bkalmar|\bosmiornic|\bmalz|\bowoce morza\b|\bbulion'
  r'|\brosol|\bwywar|\bzup[ay]?\b|\bgulasz|\bsos\b|\bresztki\b|\bchleb|\bbul(?:ki|ka|eczki)\b|\bpieczyw'
  r'|\budk[ai]|\budziec|\bskrzydel|\bpiers'
  // Portuguese.
  r'|\bfrango\b|\bpeito\b|\bcoxas?\b|\bsobrecoxas?\b|\basas\b|\bperu\b|\bganso\b|\bbovina\b|\bporco\b'
  r'|\bsuina\b|\bborrego\b|\bcabrito\b|\bvitela\b|\bcoelho\b|\bmoida\b|\bbifes?\b|\bcosteletas?\b'
  r'|\bcostela\b|\blombo\b|\bfile\b|\blinguica\b|\bsalsicha\b|\bchourico\b|\bpresunto\b|\bpeixe\b'
  r'|\bsalmao\b|\bbacalhau\b|\batum\b|\bpescada\b|\btruta\b|\bcamarao\b|\bcamaroes\b|\blulas?\b|\bpolvo\b'
  r'|\bmexilhoes\b|\bameijoas\b|\bfrutos do mar\b|\bensopado\b|\bguisado\b|\bmolho\b|\bpao\b|\bpaes\b|\bbolo\b'
  // Russian.
  r'|(?<!\p{L})(?:куриц|курин|цыпл|индейк|утк|гус[ья]|говядин|свинин|баранин|телятин|кролик|мяс|фарш'
  r'|стейк|котлет|р[её]брыш|колбас|сосиск|бекон|ветчин|филе|бедр|грудк|крыл|окорок|рыб|лосос|с[её]мг'
  r'|треск|тун[ец]|форел|креветк|кальмар|осьминог|миди|морепродукт|бульон|суп|рагу|соус|остатки|хлеб'
  r'|булоч|лаваш|торт)'
  // Japanese.
  r'|鶏|チキン|もも肉|むね肉|手羽|ささみ|豚|牛(?!乳)|羊|ラム肉|鴨|七面鳥|ひき肉|挽肉|ミンチ|肉|ステーキ'
  r'|ソーセージ|ベーコン|ハム|魚|鮭|サーモン|鱈|タラ|まぐろ|マグロ|鯖|さば|えび|エビ|海老|いか|イカ|たこ|タコ'
  r'|あさり|ほたて|帆立|シーフード|魚介|スープ|だし|出汁|ブイヨン|残り物|パン(?!粉)|ケーキ|シチュー|カレー|ソース'
  // Korean.
  r'|닭|치킨|돼지|소고기|쇠고기|양고기|오리|칠면조|고기|스테이크|소시지|베이컨|햄|생선|연어|대구|참치'
  r'|고등어|새우|오징어|문어|조개|홍합|해산물|육수|국물|수프|스프|찌개|남은 음식|빵|케이크|소스|갈비|삼겹살|목살'
  // Chinese.
  r'|鸡(?!蛋|精)|雞(?!蛋|精)|鸭|鴨|鹅|鵝|牛肉|猪|豬|羊肉|兔|肉(?!桂|豆蔻)|排骨|牛排|香肠|香腸|培根|火腿'
  r'|鱼(?!露)|魚(?!露)|三文鱼|鲑|鳕|金枪鱼|虾|蝦|鱿鱼|魷魚|章鱼|墨鱼|贝|貝|蛤|青口|海鲜|海鮮|高汤|高湯'
  r'|汤(?!圆)|湯(?!圓)|剩菜|剩饭|面包|麵包|馒头|饅頭|蛋糕',
  unicode: true,
);

/// "Frozen" in a pantry item's name ("frozen chicken thighs"), which says
/// nothing about the food.
final _frozenWord = RegExp(
  r'(?<!\p{L})(?:frozen|tiefgekuhlt|tk|congelad[oa]s?|surgelee?s?|congelat[oaie]|diepvries|mrozon[aey]'
  r'|замороженн\p{L}*)(?!\p{L})|冷凍|冷冻|냉동',
  unicode: true,
);

/// Whether [food], kept frozen, has to be thawed before cooking: meat,
/// poultry, fish and seafood, stock, soup and sauces, bread and dough,
/// cooked leftovers. Frozen peas, berries, vegetables, ice cream, fries
/// and the like are used frozen.
bool needsThawing(String food) {
  final s = foldAccents(food).replaceAll(_frozenWord, ' ').trim();
  if (s.isEmpty) return false;
  if (_doughFoods.hasMatch(s)) return true;
  if (_usedFrozen.hasMatch(s)) return false;
  if (_thawFoods.hasMatch(s)) return true;
  // Names the lists above miss ("ribeye", "tilapia"): the shopping aisle.
  return switch (getShoppingCategory(s)) {
    'meat' || 'seafood' || 'bakery' => true,
    _ => false,
  };
}

// ── A recipe's prep ──────────────────────────────────────────────────────

/// Ingredient rows that are section titles ("For the sauce"), not food. The
/// same marker as [ingredientHeaderMarker].
const _headerMarker = '__header__';

/// One ingredient row of a recipe, as stored.
class PrepIngredient {
  final String name;
  final String? notes;

  const PrepIngredient(this.name, {this.notes});

  /// A section title, not food.
  bool get isHeader => notes == _headerMarker;
}

/// What prep reminders read of a recipe.
class PrepRecipe {
  final String id;
  final String title;

  /// Every ingredient row in order, section titles included.
  final List<PrepIngredient> ingredients;

  /// Every step's text in order, section titles included.
  final List<String> steps;

  final String? notes;

  const PrepRecipe({
    required this.id,
    required this.title,
    this.ingredients = const [],
    this.steps = const [],
    this.notes,
  });
}

/// One thing to do the evening before for a recipe.
class PrepTask {
  final PrepAction action;

  /// What to thaw, soak or marinate, as the pantry or the recipe writes it.
  /// Empty for [PrepAction.ahead]: the recipe as a whole needs time.
  final List<String> items;

  const PrepTask(this.action, [this.items = const []]);

  @override
  bool operator ==(Object other) =>
      other is PrepTask && other.action == action && _sameList(other.items, items);

  @override
  int get hashCode => Object.hash(action, Object.hashAll(items));

  @override
  String toString() => 'PrepTask(${action.name}, $items)';
}

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The pantry as prep reminders see it: what is only in the freezer and
/// needs thawing, and what is on hand otherwise.
class PrepPantry {
  final PantryMatcher _toThaw;
  final PantryMatcher _onHand;

  PrepPantry._(this._toThaw, this._onHand);

  /// [items]: each pantry item with whether it is in the freezer. [basics]:
  /// the always-have basics.
  factory PrepPantry({
    required Iterable<(String, bool)> items,
    Iterable<String> basics = const [],
  }) {
    final frozen = <String>[];
    final fresh = <String>[];
    for (final (name, isFrozen) in items) {
      if (!isFrozen) {
        fresh.add(name);
      } else if (needsThawing(name)) {
        frozen.add(name);
      }
      // Frozen and used frozen (peas, berries): neither to thaw nor needed.
    }
    return PrepPantry._(
      PantryMatcher(pantry: frozen),
      PantryMatcher(pantry: fresh, basics: basics),
    );
  }

  static final empty = PrepPantry(items: const []);

  bool get hasFrozen => !_toThaw.pantryIsEmpty;

  /// The freezer items to take out for an ingredient line, as the pantry
  /// writes them. None when the line is on hand otherwise (a fresh one, or
  /// an alternative the user has).
  List<String> thawFor(IngredientKey key) {
    if (!hasFrozen || key.isEmpty || _onHand.hasLine(key)) return const [];
    for (final alternative in key.alternatives) {
      final items = <String>[];
      for (final phrase in alternative) {
        if (_onHand.hasFood(phrase)) continue;
        items.addAll(_toThaw.pantryItemsFor(IngredientKey(
          alternatives: [
            [phrase],
          ],
          optional: false,
          label: phrase.text,
          phraseLabels: const {},
        )));
      }
      if (items.isNotEmpty) return items;
    }
    return const [];
  }
}

/// An ingredient line of a recipe, reduced for prep.
class _Line {
  final String shown;
  final IngredientKey key;
  final String folded;

  _Line(this.shown, this.key, this.folded);
}

final _nonLetter = RegExp(r'[^\p{L}]+', unicode: true);
final _noteCut = RegExp(r'[,;(（，]');

/// An ingredient's name without its note ("chicken thighs" for "chicken
/// thighs, skin on").
String _shownName(String name) {
  final cut = name.indexOf(_noteCut);
  final shown = (cut > 0 ? name.substring(0, cut) : name).replaceAll(RegExp(r'\s+'), ' ').trim();
  return shown.isEmpty ? name.trim() : shown;
}

/// Whether the folded [sentence] names the food of [line].
bool _mentions(String sentence, Set<String> words, _Line line) {
  for (final alternative in line.key.alternatives) {
    for (final phrase in alternative) {
      if (phrase.cjk) {
        if (sentence.contains(phrase.text)) return true;
      } else if (phrase.tokens.any((t) => t.length >= 3 && words.contains(t))) {
        return true;
      }
    }
  }
  return false;
}

/// What [recipe] needs done the evening before, with [pantry]'s freezer:
/// things to thaw, to soak, to marinate, then (when nothing more precise was
/// found) that the recipe as a whole needs time ahead.
List<PrepTask> prepTasksFor(PrepRecipe recipe, PrepPantry pantry) {
  final thaw = <String>[];
  final soak = <String>[];
  final marinate = <String>[];
  var ahead = false;
  void add(List<String> to, String item) {
    if (!to.contains(item)) to.add(item);
  }

  // Ingredient lines: frozen ones to thaw, and their own notes ("soaked
  // overnight").
  final lines = <_Line>[];
  // Lines the pantry already has a freezer item for: the text need not name
  // them again.
  final thawed = <_Line>{};
  var optionalSection = false;
  for (final row in recipe.ingredients) {
    if (row.isHeader) {
      optionalSection = isOptionalSectionTitle(row.name);
      if (prepActionIn(row.name) != null) ahead = true;
      continue;
    }
    if (row.name.trim().isEmpty) continue;
    final notes = row.notes?.trim();
    final key = ingredientKeyFor(row.name, notes: notes == null || notes.isEmpty ? null : notes);
    final line = _Line(_shownName(row.name), key, foldAccents(row.name));
    lines.add(line);
    if (optionalSection || key.optional) continue;
    for (final item in pantry.thawFor(key)) {
      add(thaw, item);
      thawed.add(line);
    }
    final text = notes == null || notes.isEmpty ? row.name : '${row.name}, $notes';
    switch (prepActionIn(text)) {
      case PrepAction.thaw:
        if (!thawed.contains(line)) add(thaw, line.shown);
      case PrepAction.soak:
        add(soak, line.shown);
      case PrepAction.marinate:
        add(marinate, line.shown);
      case PrepAction.ahead:
        ahead = true;
      case null:
        break;
    }
  }

  // Steps and notes: name the food a sentence soaks or marinates when it is
  // one of the recipe's ingredients of the right kind.
  _Line? named(String sentence, bool Function(_Line) fits) {
    final words = {
      for (final w in canonicalizeFoodText(sentence).split(_nonLetter))
        if (w.isNotEmpty) singularize(w),
    };
    for (final line in lines) {
      if (fits(line) && _mentions(sentence, words, line)) return line;
    }
    return null;
  }

  for (final text in [...recipe.steps, ?recipe.notes]) {
    for (final (action, sentence) in prepCuesIn(text)) {
      switch (action) {
        case PrepAction.thaw:
          final line = named(sentence, (_) => true);
          if (line == null) {
            ahead = true;
          } else if (!thawed.contains(line)) {
            add(thaw, line.shown);
          }
        case PrepAction.soak:
          final line = named(sentence, (l) => _soakable.hasMatch(l.folded));
          if (line != null) {
            add(soak, line.shown);
          } else {
            ahead = true;
          }
        case PrepAction.marinate:
          final line = named(sentence, (l) => needsThawing(l.shown));
          if (line != null) {
            add(marinate, line.shown);
          } else {
            ahead = true;
          }
        case PrepAction.ahead:
          ahead = true;
      }
    }
  }

  return [
    if (thaw.isNotEmpty) PrepTask(PrepAction.thaw, thaw),
    if (soak.isNotEmpty) PrepTask(PrepAction.soak, soak),
    if (marinate.isNotEmpty) PrepTask(PrepAction.marinate, marinate),
    // Named prep says enough; otherwise point at the recipe.
    if (ahead && soak.isEmpty && marinate.isEmpty) const PrepTask(PrepAction.ahead),
  ];
}
