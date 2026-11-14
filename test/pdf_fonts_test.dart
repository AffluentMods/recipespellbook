// Recipe PDFs: Noto Sans for Latin, Cyrillic and Greek, and a CJK font only
// when the recipe (or the app's language) has Japanese, Korean or Chinese.
import 'package:flutter_test/flutter_test.dart';
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

  test('without the fonts and offline a PDF still gets a theme', () async {
    // Tests have no network: the download fails and the built-in fonts are used.
    expect(await PdfFonts.themeFor('Apple pie'), isNotNull);
  });
}
