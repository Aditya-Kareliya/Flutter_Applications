import 'package:flutter/material.dart';

class MyAppColors {
  const MyAppColors();

  // Color Palette from Figma Heritage Design System
  Color get heritageMaroon => const Color(0xFF570814);
  Color get deepMaroon => const Color(0xFF330206);
  Color get sacredRed => const Color(0xFF8B1522);
  Color get heritageGold => const Color(0xFFC89B3C);
  Color get lightGold => const Color(0xFFE8C872);
  Color get ivory => const Color(0xFFF7F5ED);
  Color get warmCream => const Color(0xFFFAF7F0);
  Color get white => const Color(0xFFFFFFFF);
  Color get black => const Color(0xFF090909);
  Color get stone => const Color(0xFFBAB3A8);

  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // Dynamic Theme Colors (with smooth ThemeExtension interpolation)
  Color getPrimaryTextColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.primaryTextColor;
    return isDarkMode(context) ? ivory : black;
  }

  Color getSecondaryTextColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.secondaryTextColor;
    return isDarkMode(context) ? stone : const Color(0xFF4A443E);
  }

  Color getMutedTextColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.mutedTextColor;
    return isDarkMode(context) ? stone.withValues(alpha: 0.8) : const Color(0xFF6E6862);
  }

  Color getBackgroundColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.backgroundColor;
    return isDarkMode(context) ? const Color(0xFF0F0E0E) : warmCream;
  }

  Color getCardBackgroundColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.cardBackgroundColor;
    return isDarkMode(context) ? const Color(0xFF171515) : white;
  }

  Color getElevatedCardBackgroundColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.elevatedCardBackgroundColor;
    return isDarkMode(context) ? const Color(0xFF221F1F) : const Color(0xFFF9F6EE);
  }

  Color getBorderColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.borderColor;
    return isDarkMode(context) ? const Color(0xFF332F2F) : const Color(0xFFDDD7CB);
  }

  Color getSurfaceColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.surfaceColor;
    return isDarkMode(context) ? const Color(0xFF171515) : white;
  }

  Color getAccentColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.accentColor;
    return isDarkMode(context) ? lightGold : heritageMaroon;
  }

  Color getFooterBackgroundColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.footerBackgroundColor;
    return isDarkMode(context) ? deepMaroon : const Color(0xFFF1EDE2);
  }

  Color getSidebarBackgroundColor(BuildContext context) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    if (ext != null) return ext.sidebarBackgroundColor;
    return isDarkMode(context) ? const Color(0xFF19060B) : const Color(0xFFFAF7F2);
  }

  Color getCardShadowColor(BuildContext context, {bool hasGlow = false}) {
    final ext = Theme.of(context).extension<MyHeritageColors>();
    final base = ext?.cardShadowColor ??
        (isDarkMode(context) ? const Color(0x47000000) : const Color(0x0D000000));
    if (hasGlow) {
      return base.withValues(alpha: (base.a * 1.8).clamp(0.0, 1.0));
    }
    return base;
  }
}

/// ThemeExtension that enables butter-smooth 300ms interpolation of all design tokens
class MyHeritageColors extends ThemeExtension<MyHeritageColors> {
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color mutedTextColor;
  final Color backgroundColor;
  final Color cardBackgroundColor;
  final Color elevatedCardBackgroundColor;
  final Color borderColor;
  final Color surfaceColor;
  final Color accentColor;
  final Color footerBackgroundColor;
  final Color sidebarBackgroundColor;
  final Color cardShadowColor;

  const MyHeritageColors({
    required this.primaryTextColor,
    required this.secondaryTextColor,
    required this.mutedTextColor,
    required this.backgroundColor,
    required this.cardBackgroundColor,
    required this.elevatedCardBackgroundColor,
    required this.borderColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.footerBackgroundColor,
    required this.sidebarBackgroundColor,
    required this.cardShadowColor,
  });

  static const light = MyHeritageColors(
    primaryTextColor: Color(0xFF090909),
    secondaryTextColor: Color(0xFF4A443E),
    mutedTextColor: Color(0xFF6E6862),
    backgroundColor: Color(0xFFFAF7F0),
    cardBackgroundColor: Color(0xFFFFFFFF),
    elevatedCardBackgroundColor: Color(0xFFF9F6EE),
    borderColor: Color(0xFFDDD7CB),
    surfaceColor: Color(0xFFFFFFFF),
    accentColor: Color(0xFF570814),
    footerBackgroundColor: Color(0xFFF1EDE2),
    sidebarBackgroundColor: Color(0xFFFAF7F2),
    cardShadowColor: Color(0x0D000000),
  );

  static const dark = MyHeritageColors(
    primaryTextColor: Color(0xFFF7F5ED),
    secondaryTextColor: Color(0xFFBAB3A8),
    mutedTextColor: Color(0xCCBAB3A8),
    backgroundColor: Color(0xFF0F0E0E),
    cardBackgroundColor: Color(0xFF171515),
    elevatedCardBackgroundColor: Color(0xFF221F1F),
    borderColor: Color(0xFF332F2F),
    surfaceColor: Color(0xFF171515),
    accentColor: Color(0xFFE8C872),
    footerBackgroundColor: Color(0xFF19060B),
    sidebarBackgroundColor: Color(0xFF19060B),
    cardShadowColor: Color(0x47000000),
  );

  @override
  MyHeritageColors copyWith({
    Color? primaryTextColor,
    Color? secondaryTextColor,
    Color? mutedTextColor,
    Color? backgroundColor,
    Color? cardBackgroundColor,
    Color? elevatedCardBackgroundColor,
    Color? borderColor,
    Color? surfaceColor,
    Color? accentColor,
    Color? footerBackgroundColor,
    Color? sidebarBackgroundColor,
    Color? cardShadowColor,
  }) {
    return MyHeritageColors(
      primaryTextColor: primaryTextColor ?? this.primaryTextColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      mutedTextColor: mutedTextColor ?? this.mutedTextColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      elevatedCardBackgroundColor: elevatedCardBackgroundColor ?? this.elevatedCardBackgroundColor,
      borderColor: borderColor ?? this.borderColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      accentColor: accentColor ?? this.accentColor,
      footerBackgroundColor: footerBackgroundColor ?? this.footerBackgroundColor,
      sidebarBackgroundColor: sidebarBackgroundColor ?? this.sidebarBackgroundColor,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
    );
  }

  @override
  MyHeritageColors lerp(ThemeExtension<MyHeritageColors>? other, double t) {
    if (other is! MyHeritageColors) return this;
    return MyHeritageColors(
      primaryTextColor: Color.lerp(primaryTextColor, other.primaryTextColor, t) ?? primaryTextColor,
      secondaryTextColor: Color.lerp(secondaryTextColor, other.secondaryTextColor, t) ?? secondaryTextColor,
      mutedTextColor: Color.lerp(mutedTextColor, other.mutedTextColor, t) ?? mutedTextColor,
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t) ?? backgroundColor,
      cardBackgroundColor: Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t) ?? cardBackgroundColor,
      elevatedCardBackgroundColor: Color.lerp(elevatedCardBackgroundColor, other.elevatedCardBackgroundColor, t) ?? elevatedCardBackgroundColor,
      borderColor: Color.lerp(borderColor, other.borderColor, t) ?? borderColor,
      surfaceColor: Color.lerp(surfaceColor, other.surfaceColor, t) ?? surfaceColor,
      accentColor: Color.lerp(accentColor, other.accentColor, t) ?? accentColor,
      footerBackgroundColor: Color.lerp(footerBackgroundColor, other.footerBackgroundColor, t) ?? footerBackgroundColor,
      sidebarBackgroundColor: Color.lerp(sidebarBackgroundColor, other.sidebarBackgroundColor, t) ?? sidebarBackgroundColor,
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t) ?? cardShadowColor,
    );
  }
}
