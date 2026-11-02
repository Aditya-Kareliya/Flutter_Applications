import 'package:flutter/material.dart';

import '../dependency_injection/dependency_injection.dart';
import '../my_app_colors/my_app_colors.dart';

/// Reusable card with subtle cultural framing, elegant borders, and responsive styling.
class CulturalFrameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool hasGlow;

  const CulturalFrameCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();

    final bg = backgroundColor ?? colors.getCardBackgroundColor(context);
    final border = borderColor ?? colors.getBorderColor(context);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: colors.getCardShadowColor(context, hasGlow: hasGlow),
            blurRadius: hasGlow ? 20 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: padding ?? const EdgeInsets.all(22),
                    child: child,
                  ),
                )
              : Padding(
                  padding: padding ?? const EdgeInsets.all(22),
                  child: child,
                ),
        ),
      ),
    );
  }
}
