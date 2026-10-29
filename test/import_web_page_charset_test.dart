// Reading a page's bytes as text: UTF-8 first, then the charset the page
// declares. Older sites still serve windows-1252, windows-1251 and the like.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:recipespellbook/services/web_page_decoder.dart';

import 'web_import_helpers.dart';

void main() {
  group('page charset', () {
    const borscht = '<!DOCTYPE html><html><head>'
        '<meta http-equiv="Content-Type" content="text/html; charset=windows-1251"><title>Борщ</title>'
        '<script type="application/ld+json">{"@type":"Recipe","name":"Борщ классический",'
        '"recipeIngredient":["500 г говядины","2 свёклы"],'
        '"recipeInstructions":[{"@type":"HowToStep","text":"Сварить бульон из говядины."}]}</script>'
        '</head><body></body></html>';

    const applePie = '<!DOCTYPE html><html><head><title>Pie</title>'
        '<script type="application/ld+json">{"@type":"Recipe","name":"Grandma’s Apple Pie",'
        '"recipeIngredient":["½ cup butter","6 apples \u2013 peeled"],'
        '"recipeInstructions":[{"@type":"HowToStep","text":"Bake at 350°F until it’s golden."}]}</script>'
        '</head><body></body></html>';

    const cremeBrulee = '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Crème Brûlée</title>'
        '<script type="application/ld+json">{"@type":"Recipe","name":"Crème Brûlée",'
        '"recipeIngredient":["½ cup sugar","2 cups cream"],'
        '"recipeInstructions":[{"@type":"HowToStep","text":"Bake at 325°F in a water bath."}]}</script>'
        '</head><body><div class="comment">It';

    /// [text] as windows-1251 bytes (Russian letters and ASCII only).
    Uint8List windows1251(String text) => Uint8List.fromList([
          for (final rune in text.runes)
            if (rune < 0x80)
              rune
            else if (rune >= 0x410 && rune <= 0x44F)
              rune - 0x410 + 0xC0
            else if (rune == 0x451)
              0xB8
            else
              0x3F,
        ]);

    /// [text] as windows-1252 bytes (Latin-1 plus the punctuation used here).
    Uint8List windows1252(String text) {
      const punctuation = {0x2019: 0x92, 0x2013: 0x96, 0x2014: 0x97, 0x20AC: 0x80};
      return Uint8List.fromList([
        for (final rune in text.runes) rune < 0x100 ? rune : (punctuation[rune] ?? 0x3F),
      ]);
    }

    Future<http.Response> Function(http.Request) serve(Uint8List bytes, String contentType) =>
        (_) async => http.Response.bytes(bytes, 200, headers: {'content-type': contentType});

    test('a windows-1251 page is read in Russian, by header or by meta tag', () async {
      for (final contentType in ['text/html; charset=windows-1251', 'text/html']) {
        final recipe = await importUrl('https://povar.example/borsch/', serve(windows1251(borscht), contentType));

        expect(recipe.title, 'Борщ классический', reason: contentType);
        expect(recipe.ingredients, ['500 г говядины', '2 свёклы'], reason: contentType);
        expect(recipe.instructions, ['Сварить бульон из говядины.'], reason: contentType);
      }
    });

    test('curly quotes and dashes survive in a page labelled Latin-1', () async {
      for (final contentType in [
        'text/html; charset=iso-8859-1',
        'text/html; charset=windows-1252',
        'text/html; charset="ISO-8859-1"',
        'text/html',
      ]) {
        final recipe = await importUrl('https://oldsite.example/pie.html', serve(windows1252(applePie), contentType));

        expect(recipe.title, 'Grandma’s Apple Pie', reason: contentType);
        expect(recipe.ingredients, ['½ cup butter', '6 apples \u2013 peeled'], reason: contentType);
        expect(recipe.instructions, ['Bake at 350°F until it’s golden.'], reason: contentType);
      }
    });

    test('one bad byte does not turn a UTF-8 page into Latin-1', () async {
      // A curly apostrophe pasted from Word into a reader comment.
      final bytes = Uint8List.fromList([...utf8.encode(cremeBrulee), 0x92, ...utf8.encode('s great</div></body></html>')]);
      final recipe = await importUrl('https://bistro.example/creme-brulee/', serve(bytes, 'text/html; charset=UTF-8'));

      expect(recipe.title, 'Crème Brûlée');
      expect(recipe.ingredients, ['½ cup sugar', '2 cups cream']);
      expect(recipe.instructions, ['Bake at 325°F in a water bath.']);
    });

    test('a UTF-8 page is read as UTF-8 whatever the server calls it', () async {
      final page = utf8.encode('${cremeBrulee}s great</div></body></html>');

      for (final contentType in ['text/html', 'text/html; charset=iso-8859-1', 'text/html; charset=windows-1251']) {
        final recipe = await importUrl('https://bistro.example/creme-brulee/', serve(page, contentType));

        expect(recipe.title, 'Crème Brûlée', reason: contentType);
        expect(recipe.ingredients.first, '½ cup sugar', reason: contentType);
      }
    });

    test('a stray byte in a UTF-8 page is read as the character it stands for', () async {
      // The title itself holds a windows-1252 apostrophe, next to UTF-8
      // accents and an emoji.
      final page = cremeBrulee.replaceFirst('"name":"Crème Brûlée"', '"name":"Grandma#s Crème Brûlée 🍮"');
      final bytes = Uint8List.fromList(
          [for (final byte in utf8.encode('${page}s great</div></body></html>')) byte == 0x23 ? 0x92 : byte]);
      final recipe = await importUrl('https://bistro.example/creme-brulee/', serve(bytes, 'text/html; charset=UTF-8'));

      expect(recipe.title, 'Grandma’s Crème Brûlée 🍮');
      expect(recipe.ingredients, ['½ cup sugar', '2 cups cream']);
    });

    test('the page is believed when the server calls an older page UTF-8', () async {
      // A server default: the header says UTF-8, the page itself windows-1251.
      final recipe =
          await importUrl('https://povar.example/borsch/', serve(windows1251(borscht), 'text/html; charset=utf-8'));

      expect(recipe.title, 'Борщ классический');
      expect(recipe.ingredients, ['500 г говядины', '2 свёклы']);
    });

    test('a label that names no known charset is read the way browsers read it', () async {
      // Among them Turkish, a Latin charset without a table of its own: its
      // pages import with a few letters wrong, as they always did.
      for (final label in ['utf8mb4', 'none', 'x-user-defined', 'ansi_x3.4-1968', 'iso-8859-9', 'utf-8']) {
        final recipe = await importUrl(
            'https://oldsite.example/pie.html', serve(windows1252(applePie), 'text/html; charset=$label'));

        expect(recipe.title, 'Grandma’s Apple Pie', reason: label);
        expect(recipe.ingredients, ['½ cup butter', '6 apples \u2013 peeled'], reason: label);
      }
    });

    // Shift_JIS bytes for the start and for the whole of "カレーライス".
    const curryStart = [0x83, 0x4A, 0x83, 0x8C, 0x81, 0x5B];
    const curry = [...curryStart, 0x83, 0x89, 0x83, 0x43, 0x83, 0x58];

    /// A page labelled Shift_JIS with its title in that charset and [jsonLd]
    /// for its recipe data.
    Uint8List shiftJisPage(List<int> jsonLd) => Uint8List.fromList([
          ...ascii.encode('<html><head><meta charset="Shift_JIS"><title>'),
          ...curry,
          ...ascii.encode('</title><script type="application/ld+json">'),
          ...jsonLd,
          ...ascii.encode('</script></head><body></body></html>'),
        ]);

    test('a charset the app has no table for is refused, not imported as garbage', () async {
      final bytes = shiftJisPage([
        ...ascii.encode('{"@type":"Recipe","name":"'),
        ...curryStart,
        ...ascii.encode('","recipeIngredient":["2 cups rice"],"recipeInstructions":["Boil the rice."]}'),
      ]);

      expect(
        await importFailure('https://ryori.example/curry', serve(bytes, 'text/html')),
        'Exception: That page uses a text encoding (shift_jis) this app cannot read.',
      );
      expect(
        await importFailure('https://ryori.example/curry', serve(bytes, 'text/html; charset=EUC-KR')),
        'Exception: That page uses a text encoding (euc-kr) this app cannot read.',
      );
      // The same when such a page holds no recipe data at all.
      expect(
        await importFailure('https://ryori.example/curry', serve(shiftJisPage(const []), 'text/html')),
        'Exception: That page uses a text encoding (shift_jis) this app cannot read.',
      );
    });

    test('recipe data written in plain ASCII is still read from such a page', () async {
      // The way PHP writes JSON: every letter outside ASCII as an escape.
      final escaped = jsonEncode({
        '@type': 'Recipe',
        'name': 'カレーライス',
        'recipeIngredient': ['米 2合', 'カレールー 1箱'],
        'recipeInstructions': ['米を炊く。', 'ルーを溶かす。'],
      }).replaceAllMapped(
          RegExp(r'[^\x00-\x7F]'), (match) => '\\u${match[0]!.codeUnitAt(0).toRadixString(16).padLeft(4, '0')}');

      final recipe =
          await importUrl('https://ryori.example/curry', serve(shiftJisPage(ascii.encode(escaped)), 'text/html'));

      expect(recipe.title, 'カレーライス');
      expect(recipe.ingredients, ['米 2合', 'カレールー 1箱']);
      expect(recipe.instructions, ['米を炊く。', 'ルーを溶かす。']);
    });
  });

  group('WebPageDecoder', () {
    String decode(List<int> bytes, String charset) =>
        WebPageDecoder.decode(bytes, contentType: 'text/html; charset=$charset').text;

    test('Polish letters are read from both Central European charsets', () {
      // "żółć" and "Łódź" in each charset.
      expect(decode([0xBF, 0xF3, 0xB3, 0xE6, 0x20, 0xA3, 0xF3, 0x64, 0x9F], 'windows-1250'), 'żółć Łódź');
      expect(decode([0xBF, 0xF3, 0xB3, 0xE6, 0x20, 0xA3, 0xF3, 0x64, 0xBC], 'iso-8859-2'), 'żółć Łódź');
    });

    test('the euro sign and the French ligatures of ISO-8859-15 are read', () {
      expect(decode([0x35, 0xA4, 0x20, 0x62, 0xBD, 0x75, 0x66], 'iso-8859-15'), '5€ bœuf');
      // The same bytes mean something else in Latin-1.
      expect(decode([0x35, 0xA4, 0x20, 0x62, 0xBD, 0x75, 0x66], 'iso-8859-1'), '5¤ b½uf');
    });

    test('the punctuation windows-1252 adds to Latin-1 is read', () {
      expect(decode([0x80, 0x85, 0x91, 0x92, 0x93, 0x94, 0x99], 'windows-1252'), '€…‘’“”™');
      expect(decode([0xE9, 0xE8, 0xFC, 0xDF, 0xF1], 'latin1'), 'éèüßñ');
    });

    test('Cyrillic outside the Russian alphabet is read from windows-1251', () {
      expect(decode([0xA8, 0xB8, 0xAF, 0xBF, 0xB2, 0xB3, 0xB9], 'cp1251'), 'ЁёЇїІі№');
    });

    test('plain ASCII reads the same under every label', () {
      for (final charset in ['utf-8', 'windows-1251', 'iso-8859-2', 'shift_jis', 'made-up']) {
        final page = WebPageDecoder.decode(ascii.encode('2 cups flour'), contentType: 'text/html; charset=$charset');

        expect(page.text, '2 cups flour', reason: charset);
        expect(page.unreadableCharset, isNull, reason: charset);
      }
    });

    test('a page in a charset without a table says which one it is and keeps only its ASCII', () {
      final page = WebPageDecoder.decode(
          [...ascii.encode('<b>'), 0x83, 0x4A, 0x83, 0x8C, 0x81, 0x5B, ...ascii.encode('</b> 200g')],
          contentType: 'text/html; charset=Shift_JIS');

      expect(page.unreadableCharset, 'shift_jis');
      // Every byte outside ASCII is marked as unreadable.
      final mark = String.fromCharCode(0xFFFD);
      expect(page.text, '<b>${mark}J$mark$mark$mark[</b> 200g');
    });

    test('only charsets in another alphabet are given up on', () {
      const bytes = [0x63, 0x61, 0x66, 0xE9, 0x20, 0xE0, 0x20, 0x6C, 0x61, 0x20, 0x63, 0x72, 0xE8, 0x6D, 0x65];

      for (final charset in ['gb2312', 'gbk', 'big5', 'euc-jp', 'iso-2022-jp', 'ks_c_5601-1987', 'windows-1253', 'iso-8859-7', 'koi8-r', 'iso-8859-5', 'windows-1256', 'tis-620']) {
        final page = WebPageDecoder.decode(bytes, contentType: 'text/html; charset=$charset');
        expect(page.unreadableCharset, charset, reason: charset);
      }
      // Latin charsets without a table, and labels that mean nothing.
      for (final charset in ['iso-8859-9', 'windows-1254', 'windows-1257', 'iso-8859-16', 'macintosh', 'binary']) {
        final page = WebPageDecoder.decode(bytes, contentType: 'text/html; charset=$charset');
        expect(page.unreadableCharset, isNull, reason: charset);
        expect(page.text, 'café à la crème', reason: charset);
      }
    });

    test('UTF-8 with a few bytes of windows-1252 in it keeps both', () {
      final bytes = [
        ...utf8.encode('Crème brûlée 🍮 pour l'),
        0x92, // a windows-1252 apostrophe
        ...utf8.encode('été, 5'),
        0x80, // and a euro sign
      ];

      final page = WebPageDecoder.decode(bytes, contentType: 'text/html; charset=utf-8');
      expect(page.text, 'Crème brûlée 🍮 pour l’été, 5€');
      expect(page.unreadableCharset, isNull);
    });

    test('bytes that only look like UTF-8 are not taken for it', () {
      // Each is forbidden: longer than it needs to be, half of a surrogate
      // pair, past the last code point, cut off at the end.
      for (final bad in [
        [0xC0, 0xAF],
        [0xE0, 0x80, 0xAF],
        [0xED, 0xA0, 0x80],
        [0xF5, 0x80, 0x80, 0x80],
        [0xF4, 0x90, 0x80, 0x80],
        [0xE2, 0x82],
      ]) {
        const text = 'crème brûlée déjà prête ';
        final page = WebPageDecoder.decode([...utf8.encode(text), ...bad]);

        // Read one by one instead, as the windows-1252 characters they are.
        expect(page.text, startsWith(text), reason: '$bad');
        expect(page.text.length, text.length + bad.length, reason: '$bad');
        expect(page.text, isNot(contains('\uFFFD')), reason: '$bad');
      }
    });

    test('a byte order mark is not part of the text', () {
      final bytes = [0xEF, 0xBB, 0xBF, ...utf8.encode('Crème brûlée, l'), 0x92, ...utf8.encode('été')];

      expect(WebPageDecoder.decode(bytes).text, 'Crème brûlée, l’été');
    });

    test('the charset is read from an XML declaration too', () {
      final bytes = [...ascii.encode('<?xml version="1.0" encoding="windows-1251"?><html><body>'), 0xC1, 0xEE, 0xF0, 0xF9];

      expect(WebPageDecoder.decode(bytes).text, endsWith('Борщ'));
    });
  });
}
