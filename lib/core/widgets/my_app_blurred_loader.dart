import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../dependency_injection/dependency_injection.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_text_style/my_app_text_styles.dart';

class MyAppBlurredLoader extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const MyAppBlurredLoader({super.key, this.message, this.isFullScreen = true});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.5.h),
            constraints: BoxConstraints(
              minWidth: 260,
              maxWidth: Device.screenType == ScreenType.mobile ? 85.w : 380,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF171515).withValues(alpha: 0.85) // getCardBackgroundColor
                  : colors.white.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? colors.stone.withValues(alpha: 0.25)
                    : colors.heritageMaroon.withValues(alpha: 0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colors.heritageGold,
                    ),
                    backgroundColor: colors.heritageMaroon.withValues(alpha: 0.18),
                  ),
                ),
                SizedBox(height: 2.2.h),
                Text(
                  message ?? 'Please wait...',
                  textAlign: TextAlign.center,
                  style: styles.editorialSerif(
                    context,
                    size: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
                SizedBox(height: 0.6.h),
                Text(
                  'PAVAN PUTRA GARBI MANDAL',
                  textAlign: TextAlign.center,
                  style: styles.cleanSans(
                    context,
                    size: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: colors.getAccentColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!isFullScreen) {
      return content;
    }

    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: ColoredBox(
            color: (isDark ? Colors.black : colors.ivory).withValues(alpha: 0.55),
            child: content,
          ),
        ),
      ),
    );
  }
}
