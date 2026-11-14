import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// The fonts of the recipe PDFs (print, and share as PDF).
///
/// Noto Sans (SIL OFL) covers Latin, Cyrillic and Greek. It is read from
/// [regularAsset] and [boldAsset] when the build bundles them (then printing
/// such a recipe asks nothing of Google), else fetched from Google Fonts as
/// before. Noto Sans has no Japanese, Korean or Chinese, so a recipe with
/// that text also gets the script's Noto Sans as a fallback, fetched on
/// first use and kept by the printing package: those fonts are 5.7 to 10.6
/// MB per weight, too much to ship to everyone for the few who need them.
class PdfFonts {
  PdfFonts._();

  static const regularAsset = 'assets/google_fonts/NotoSans-Regular.ttf';
  static const boldAsset = 'assets/google_fonts/NotoSans-Bold.ttf';

  static pw.Font? _regular;
  static pw.Font? _bold;
  static final _cjk = <CjkScript, pw.Font>{};

  /// The theme for a PDF showing [text], with its headings in the app's
  /// [languageCode] when given. Falls back to the PDF's built-in fonts when
  /// Noto Sans can be neither read nor fetched.
  static Future<pw.ThemeData> themeFor(String text, {String? languageCode}) async {
    final pw.Font regular;
    final pw.Font bold;
    try {
      regular = _regular ?? _keep(await _bundledOr(regularAsset, PdfGoogleFonts.notoSansRegular), (f) => _regular = f);
      bold = _bold ?? _keep(await _bundledOr(boldAsset, PdfGoogleFonts.notoSansBold), (f) => _bold = f);
    } catch (e) {
      debugPrint('[PdfFonts] Noto Sans unavailable: $e');
      return pw.ThemeData.base();
    }
    final fallback = <pw.Font>[];
    final script = cjkScriptOf(text) ?? CjkScript.forLanguage(languageCode);
    if (script != null) {
      try {
        fallback.add(_cjk[script] ?? _keep(await script.download(), (f) => _cjk[script] = f));
      } catch (e) {
        debugPrint('[PdfFonts] No $script font (offline?): $e');
      }
    }
    // Only regular and bold are kept: italic text prints upright.
    return pw.ThemeData.withFont(
      base: regular,
      bold: bold,
      italic: regular,
      boldItalic: bold,
      fontFallback: fallback,
    );
  }

  /// Keeps [font] for the next PDF only when it is the real font: a failed
  /// download gives a built-in stand-in, to be tried again next time.
  static pw.Font _keep(pw.Font font, void Function(pw.Font) store) {
    if (font is pw.TtfFont) store(font);
    return font;
  }

  static Future<pw.Font> _bundledOr(String asset, Future<pw.Font> Function() download) async {
    try {
      return pw.Font.ttf(await rootBundle.load(asset));
    } catch (_) {
      return download();
    }
  }

  /// The CJK script [text] needs a font for, or null.
  @visibleForTesting
  static CjkScript? cjkScriptOf(String text) {
    var han = false;
    for (final rune in text.runes) {
      if (rune >= 0x3040 && rune <= 0x30FF) return CjkScript.japanese; // kana
      if ((rune >= 0xAC00 && rune <= 0xD7AF) || (rune >= 0x1100 && rune <= 0x11FF) || (rune >= 0x3130 && rune <= 0x318F)) {
        return CjkScript.korean; // Hangul
      }
      if ((rune >= 0x4E00 && rune <= 0x9FFF) || (rune >= 0x3400 && rune <= 0x4DBF)) han = true;
    }
    return han ? CjkScript.chinese : null;
  }
}

/// A script Noto Sans does not cover, with the Noto Sans font that does.
enum CjkScript {
  japanese,
  korean,
  chinese;

  /// The script of the app language [languageCode] (such as "ja" or
  /// "zh_CN"), or null for a language Noto Sans covers.
  static CjkScript? forLanguage(String? languageCode) => switch (languageCode?.split(RegExp('[_-]')).first) {
        'ja' => CjkScript.japanese,
        'ko' => CjkScript.korean,
        'zh' => CjkScript.chinese,
        _ => null,
      };

  Future<pw.Font> download() => switch (this) {
        CjkScript.japanese => PdfGoogleFonts.notoSansJPRegular(),
        CjkScript.korean => PdfGoogleFonts.notoSansKRRegular(),
        CjkScript.chinese => PdfGoogleFonts.notoSansSCRegular(),
      };
}
