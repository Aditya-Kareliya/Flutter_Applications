import 'package:flutter/material.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';

/// --------------------------------------------------------------------------
/// 1. MY APP FILL BUTTON
/// Solid primary button (Heritage Maroon by default, Sacred Red when danger).
/// Supports optional icon, loading spinner, full-width, and theme adaptation.
/// --------------------------------------------------------------------------
class MyAppFillButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool isDanger;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final TextStyle? textStyle;

  const MyAppFillButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isDanger = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius = 10,
    this.textStyle,
  });

  const MyAppFillButton.icon({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isDanger = false,
    this.isLoading = false,
    this.isFullWidth = false,
    this.padding,
    this.borderRadius = 10,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final effectiveBgColor = isDanger ? colors.sacredRed : colors.heritageMaroon;

    final defaultPadding = icon != null ? const EdgeInsets.symmetric(horizontal: 16, vertical: 11) : const EdgeInsets.symmetric(horizontal: 18, vertical: 12);

    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: textStyle ?? styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );

    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: effectiveBgColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: effectiveBgColor.withValues(alpha: 0.5),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        padding: padding ?? defaultPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: isDanger ? BorderSide.none : BorderSide(color: colors.isDarkMode(context) ? colors.heritageGold.withValues(alpha: 0.3) : Colors.transparent, width: 1),
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: buttonChild,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}

/// --------------------------------------------------------------------------
/// 2. MY APP OUTLINE BUTTON
/// Outlined secondary button.
/// Theme-adaptive: Heritage Maroon in Light mode, Light Gold in Dark mode.
/// Supports danger variant (Red outline/text), loading state, and icons.
/// --------------------------------------------------------------------------
class MyAppOutlineButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool isDanger;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final TextStyle? textStyle;
  final Color? color;

  const MyAppOutlineButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isDanger = false,
    this.isLoading = false,
    this.padding,
    this.borderRadius = 10,
    this.textStyle,
    this.color,
  });

  const MyAppOutlineButton.icon({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isDanger = false,
    this.isLoading = false,
    this.padding,
    this.borderRadius = 10,
    this.textStyle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final effectiveColor = isDanger ? Colors.redAccent : color ?? (isDark ? colors.lightGold : colors.heritageMaroon);

    final defaultPadding = icon != null ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10) : const EdgeInsets.symmetric(horizontal: 16, vertical: 11);

    final buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(effectiveColor))),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          IconTheme(
            data: IconThemeData(size: 16, color: effectiveColor),
            child: icon!,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: textStyle ?? styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600, color: effectiveColor),
        ),
      ],
    );

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: effectiveColor,
        disabledForegroundColor: effectiveColor.withValues(alpha: 0.4),
        side: BorderSide(color: effectiveColor.withValues(alpha: isDanger ? 0.6 : 0.45), width: 1.2),
        padding: padding ?? defaultPadding,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      ),
      onPressed: isLoading ? null : onPressed,
      child: buttonChild,
    );
  }
}

/// --------------------------------------------------------------------------
/// 3. MY APP TEXT BUTTON
/// Subtle text-only button with hover feedback.
/// Supports normal state, danger state (e.g. "x Clear"), loading, and icons.
/// --------------------------------------------------------------------------
class MyAppTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool isDanger;
  final bool isCompact;
  final bool isLoading;
  final TextStyle? textStyle;
  final Color? color;

  const MyAppTextButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isDanger = false,
    this.isCompact = false,
    this.isLoading = false,
    this.textStyle,
    this.color,
  });

  const MyAppTextButton.icon({
    super.key,
    required this.onPressed,
    required this.label,
    required this.icon,
    this.isDanger = false,
    this.isCompact = false,
    this.isLoading = false,
    this.textStyle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final effectiveColor = color ?? (isDanger ? Colors.redAccent : (isDark ? colors.lightGold : colors.heritageMaroon));

    final buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.8, valueColor: AlwaysStoppedAnimation<Color>(effectiveColor))),
          const SizedBox(width: 6),
        ] else if (icon != null) ...[
          IconTheme(
            data: IconThemeData(size: isCompact ? 14 : 16, color: effectiveColor),
            child: icon!,
          ),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: textStyle ?? styles.cleanSans(context, size: isCompact ? 11 : 13, fontWeight: FontWeight.w600, color: effectiveColor),
        ),
      ],
    );

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: effectiveColor,
        visualDensity: isCompact ? VisualDensity.compact : VisualDensity.standard,
        padding: isCompact ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4) : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: isLoading ? null : onPressed,
      child: buttonChild,
    );
  }
}

/// --------------------------------------------------------------------------
/// 4. MY APP ICON BUTTON WITH NAME
/// Heritage pill badge selector (used for Pillar Icons, Values, Categories).
/// Active: Heritage Maroon background, Gold border, White text and icon.
/// Inactive: Surface/Cream background, subtle border, Accent icon, Primary text.
/// --------------------------------------------------------------------------
class MyAppIconButtonWithName extends StatelessWidget {
  final IconData icon;
  final String name;
  final bool isSelected;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  const MyAppIconButtonWithName({
    super.key,
    required this.icon,
    required this.name,
    required this.isSelected,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final bgColor = isSelected ? colors.heritageMaroon : (isDark ? const Color(0xFF1E1B1B) : colors.getSurfaceColor(context));

    final borderColor = isSelected ? colors.heritageGold : colors.getBorderColor(context);

    final iconColor = isSelected ? Colors.white : (isDark ? colors.lightGold : colors.heritageGold);

    final textColor = isSelected ? Colors.white : colors.getPrimaryTextColor(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(borderRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: padding,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
          boxShadow: isSelected ? [BoxShadow(color: colors.heritageMaroon.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: iconColor),
            const SizedBox(width: 7),
            Text(
              name,
              style: styles.cleanSans(context, size: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

/// --------------------------------------------------------------------------
/// 5. MY APP ICON BUTTON
/// Unified, theme-adaptive icon button with dedicated constructors:
/// - MyAppIconButton.clear: compact 'x' close/clear icon button.
/// - MyAppIconButton.translate: compact auto-translate icon button.
/// --------------------------------------------------------------------------
class MyAppIconButton extends StatelessWidget {
  final bool isLoading;
  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VisualDensity visualDensity;

  const MyAppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.tooltip,
    this.size = 20,
    this.color,
    this.padding = const EdgeInsets.all(6),
    this.visualDensity = VisualDensity.compact,
  });

  /// Factory constructor for the compact 'x' clear button
  factory MyAppIconButton.clear({Key? key, required VoidCallback? onPressed, double size = 16, String tooltip = 'Clear'}) {
    return MyAppIconButton(
      key: key,
      icon: Icon(Icons.close_rounded, size: size),
      onPressed: onPressed,
      tooltip: tooltip,
      size: size,
      padding: const EdgeInsets.all(4),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Factory constructor for the auto-translate icon button
  factory MyAppIconButton.translate({Key? key, required VoidCallback? onPressed, bool isLoading = false, double size = 18, String tooltip = 'Auto-translate to Gujarati'}) {
    return MyAppIconButton(
      key: key,
      isLoading: isLoading,
      icon: Icon(Icons.g_translate_rounded, size: size),
      onPressed: onPressed,
      tooltip: tooltip,
      size: size,
      padding: const EdgeInsets.all(4),
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final effectiveColor = color ?? colors.getPrimaryTextColor(context);

    if (isLoading) {
      return SizedBox(
        width: size + 16,
        height: size + 16,
        child: Center(
          child: SizedBox(
            width: size * 0.75,
            height: size * 0.75,
            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(effectiveColor)),
          ),
        ),
      );
    }

    final button = IconButton(icon: icon, iconSize: size, color: effectiveColor, visualDensity: visualDensity, padding: padding, tooltip: tooltip, onPressed: onPressed);

    return button;
  }
}
