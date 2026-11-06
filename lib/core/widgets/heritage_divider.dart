import 'package:flutter/material.dart';

import '../dependency_injection/dependency_injection.dart';
import '../my_app_colors/my_app_colors.dart';

/// An elegant ornamental separator with a subtle cultural emblem in the center.
class HeritageDivider extends StatelessWidget {
  final double verticalPadding;
  final double? width;
  final Color? color;

  const HeritageDivider({super.key, this.verticalPadding = 24, this.width, this.color});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = color ?? (isDark ? colors.stone.withValues(alpha: 0.25) : const Color(0xFFDDD7CB));
    final emblemColor = isDark ? colors.heritageGold : colors.heritageMaroon;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Center(
        child: SizedBox(
          width: width,
          child: Row(
            mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [dividerColor.withValues(alpha: 0.0), dividerColor])),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      transform: Matrix4.rotationZ(0.785398),
                      decoration: BoxDecoration(color: emblemColor.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(1)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      transform: Matrix4.rotationZ(0.785398),
                      decoration: BoxDecoration(
                        color: emblemColor,
                        borderRadius: BorderRadius.circular(1.5),
                        boxShadow: [BoxShadow(color: emblemColor.withValues(alpha: 0.3), blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 5,
                      height: 5,
                      transform: Matrix4.rotationZ(0.785398),
                      decoration: BoxDecoration(color: emblemColor.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(1)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(gradient: LinearGradient(colors: [dividerColor, dividerColor.withValues(alpha: 0.0)])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
