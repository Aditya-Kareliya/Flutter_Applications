import 'package:flutter/material.dart';

import '../dependency_injection/dependency_injection.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_text_style/my_app_text_styles.dart';

/// An elegant cultural badge or overline tag
class HeritageBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const HeritageBadge({super.key, required this.label, this.icon, this.backgroundColor, this.textColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = backgroundColor ?? (isDark ? colors.heritageGold.withValues(alpha: 0.15) : colors.heritageMaroon.withValues(alpha: 0.08));
    final fg = textColor ?? (isDark ? colors.lightGold : colors.heritageMaroon);
    final border = borderColor ?? (isDark ? colors.heritageGold.withValues(alpha: 0.45) : colors.heritageMaroon.withValues(alpha: 0.25));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 6)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: styles.eyebrow(context, color: fg).copyWith(color: fg, fontWeight: FontWeight.w700, letterSpacing: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
