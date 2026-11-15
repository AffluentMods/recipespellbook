// Recipe PDFs: Noto Sans for Latin, Cyrillic and Greek, and a CJK font only
// when the recipe (or the app's language) has Japanese, Korean or Chinese.
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:recipespellbook/services/pdf_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Latin, Cyrillic and Greek need no extra font', () {
    expect(PdfFonts.cjkScriptOf('Crème brûlée, борщ, σπανακόπιτα'), isNull);
  });

  test('kana means Japanese, Hangul Korean, Han alone Chinese', () {
    expect(PdfFonts.cjkScriptOf('肉じゃが'), CjkScript.japanese);
    expect(PdfFonts.cjkScriptOf('김치찌개'), CjkScript.korean);
    expect(PdfFonts.cjkScriptOf('红烧肉'), CjkScript.chinese);
  });

  test('the app language decides when the recipe text does not', () {
    expect(CjkScript.forLanguage('ja'), CjkScript.japanese);
    expect(CjkScript.forLanguage('zh_CN'), CjkScript.chinese);
    expect(CjkScript.forLanguage('ko'), CjkScript.korean);
    expect(CjkScript.forLanguage('ru'), isNull);
    expect(CjkScript.forLanguage(null), isNull);
  });

  test('the bundled Noto Sans is used, so printing asks nothing of Google', () async {
    // Tests have no network: a theme with real fonts can only come from the bundle.
    final theme = await PdfFonts.themeFor('Apple pie');
    final regular = theme.defaultTextStyle.font;
    final bold = theme.defaultTextStyle.fontBold;
    expect(regular, isA<pw.TtfFont>());
    expect(bold, isA<pw.TtfFont>());
    for (final font in [regular! as pw.TtfFont, bold! as pw.TtfFont]) {
      final glyphs = TtfParser(font.data).charToGlyphIndexMap;
      for (final ch in 'éßøłşđ бщ σπ'.runes.where((r) => r != 0x20)) {
        expect(glyphs.containsKey(ch), isTrue, reason: String.fromCharCode(ch));
      }
    }
  });
}
