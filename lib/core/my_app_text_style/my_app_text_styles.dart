import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dependency_injection/dependency_injection.dart';
import '../my_app_colors/my_app_colors.dart';

class MyAppTextStyles {
  MyAppTextStyles();

  MyAppColors get colors => serviceLocator<MyAppColors>();

  bool _isGujarati(BuildContext context) {
    return Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
  }

  static const List<String> gujaratiFallback = [
    'Noto Sans Gujarati',
    'Noto Serif Gujarati',
    'Gujarati Sangam MN',
    'Gujarati MT',
    'Shruti',
    'Nirmala UI',
    'Mukta Vaani',
    'Gujarati',
    'sans-serif',
  ];

  static final TextStyle _baseNotoSerifGujarati = GoogleFonts.notoSerifGujarati(textStyle: const TextStyle(fontFamilyFallback: gujaratiFallback));
  static final TextStyle _baseCormorantGaramond = GoogleFonts.cormorantGaramond(textStyle: const TextStyle(fontFamilyFallback: gujaratiFallback));
  static final TextStyle _baseNotoSansGujarati = GoogleFonts.notoSansGujarati(textStyle: const TextStyle(fontFamilyFallback: gujaratiFallback));
  static final TextStyle _baseInter = GoogleFonts.inter(textStyle: const TextStyle(fontFamilyFallback: gujaratiFallback));

  /// Preload all Gujarati & English fonts into Flutter's FontLoader to eliminate tofu glyph boxes
  static Future<void> preloadAllFonts() async {
    try {
      await GoogleFonts.pendingFonts([
        GoogleFonts.notoSansGujarati(fontWeight: FontWeight.w400),
        GoogleFonts.notoSansGujarati(fontWeight: FontWeight.w500),
        GoogleFonts.notoSansGujarati(fontWeight: FontWeight.w600),
        GoogleFonts.notoSansGujarati(fontWeight: FontWeight.w700),
        GoogleFonts.notoSerifGujarati(fontWeight: FontWeight.w400),
        GoogleFonts.notoSerifGujarati(fontWeight: FontWeight.w500),
        GoogleFonts.notoSerifGujarati(fontWeight: FontWeight.w600),
        GoogleFonts.notoSerifGujarati(fontWeight: FontWeight.w700),
        GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w400),
        GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600),
        GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w700),
        GoogleFonts.inter(fontWeight: FontWeight.w400),
        GoogleFonts.inter(fontWeight: FontWeight.w500),
        GoogleFonts.inter(fontWeight: FontWeight.w600),
        GoogleFonts.inter(fontWeight: FontWeight.w700),
      ]);
    } catch (e) {
      debugPrint('Font preload notice: $e');
    }
  }

  /// Language-adaptive Editorial Serif Style
  /// Automatically selects Noto Serif Gujarati for Gujarati or Cormorant Garamond for English.
  TextStyle editorialSerif(BuildContext context, {double? size, Color? color, FontWeight? fontWeight, double? letterSpacing, double? height}) {
    final gujarati = _isGujarati(context);
    final effectiveColor = color ?? colors.getPrimaryTextColor(context);
    final effectiveWeight = fontWeight ?? FontWeight.w600;

    if (gujarati) {
      return _baseNotoSerifGujarati.copyWith(fontSize: size ?? 22, fontWeight: effectiveWeight, color: effectiveColor, letterSpacing: letterSpacing, height: height ?? 1.38);
    }

    return _baseCormorantGaramond.copyWith(fontSize: size ?? 24, fontWeight: effectiveWeight, color: effectiveColor, letterSpacing: letterSpacing, height: height ?? 1.15);
  }

  /// Clean Sans Style (Inter for English, Noto Sans Gujarati for Gujarati)
  /// Used for body text, UI elements, navigation labels.
  TextStyle cleanSans(BuildContext context, {double? size, Color? color, FontWeight? fontWeight, double? letterSpacing, double? height}) {
    final gujarati = _isGujarati(context);
    final effectiveColor = color ?? colors.getPrimaryTextColor(context);
    final effectiveWeight = fontWeight ?? FontWeight.w400;

    if (gujarati) {
      return _baseNotoSansGujarati.copyWith(fontSize: size ?? 14, fontWeight: effectiveWeight, color: effectiveColor, letterSpacing: letterSpacing, height: height ?? 1.55);
    }

    return _baseInter.copyWith(fontSize: size ?? 14, fontWeight: effectiveWeight, color: effectiveColor, letterSpacing: letterSpacing, height: height ?? 1.55);
  }

  /// Explicit Gujarati Serif Style (Noto Serif Gujarati)
  TextStyle gujaratiSerif(BuildContext context, {double? size, Color? color, FontWeight? fontWeight, double? letterSpacing, double? height}) {
    return _baseNotoSerifGujarati.copyWith(
      fontSize: size ?? 16,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? colors.getPrimaryTextColor(context),
      letterSpacing: letterSpacing,
      height: height ?? 1.45,
    );
  }

  /// Explicit English Serif Style
  TextStyle englishSerif(BuildContext context, {double? size, Color? color, FontWeight? fontWeight, double? letterSpacing, double? height}) {
    return _baseCormorantGaramond.copyWith(
      fontSize: size ?? 24,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? colors.getPrimaryTextColor(context),
      letterSpacing: letterSpacing,
      height: height ?? 1.15,
    );
  }

  /// Pre-defined typography tokens
  TextStyle heroHeading(BuildContext context, {double? size, Color? color}) =>
      editorialSerif(context, size: size ?? (_isGujarati(context) ? 46 : 44), fontWeight: FontWeight.w700, height: _isGujarati(context) ? 1.32 : 1.12, color: color);

  TextStyle h1(BuildContext context, {Color? color}) =>
      editorialSerif(context, size: _isGujarati(context) ? 38 : 36, fontWeight: FontWeight.w700, height: _isGujarati(context) ? 1.35 : 1.15, color: color);

  TextStyle h2(BuildContext context, {Color? color}) =>
      editorialSerif(context, size: _isGujarati(context) ? 30 : 28, fontWeight: FontWeight.w600, height: _isGujarati(context) ? 1.35 : 1.2, color: color);

  TextStyle h3(BuildContext context, {Color? color}) =>
      editorialSerif(context, size: _isGujarati(context) ? 24 : 22, fontWeight: FontWeight.w600, height: _isGujarati(context) ? 1.35 : 1.25, color: color);

  TextStyle bodyText(BuildContext context, {Color? color, double? size, double? height}) =>
      cleanSans(context, size: size ?? 14, fontWeight: FontWeight.w400, height: height ?? 1.6, color: color);

  TextStyle bodySmall(BuildContext context, {Color? color}) => cleanSans(context, size: 12, fontWeight: FontWeight.w400, height: 1.5, color: color);

  TextStyle navText(BuildContext context, {Color? color}) =>
      cleanSans(context, size: _isGujarati(context) ? 14 : 12, fontWeight: FontWeight.w600, letterSpacing: _isGujarati(context) ? 0.3 : 1.2, color: color);

  TextStyle eyebrow(BuildContext context, {Color? color}) => cleanSans(
    context,
    size: _isGujarati(context) ? 13 : 11,
    fontWeight: FontWeight.w700,
    letterSpacing: _isGujarati(context) ? 0.8 : 1.4,
    color: color ?? colors.getAccentColor(context),
  );

  TextStyle devotionalMotto(BuildContext context, {Color? color, double? size}) =>
      gujaratiSerif(context, size: size ?? 20, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: color ?? colors.heritageGold, height: 1.4);
}
