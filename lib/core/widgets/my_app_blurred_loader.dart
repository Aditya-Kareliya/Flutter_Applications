import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../dependency_injection/dependency_injection.dart';
import '../localization/my_app_translations.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import 'brand_logo/brand_logo_widget.dart';

class MyAppBlurredLoader extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const MyAppBlurredLoader({super.key, this.message, this.isFullScreen = true});

  String _resolveMessage(BuildContext context) {
    if (message == null || message!.trim().isEmpty) {
      final defaultMsg = context.tr('loading_wait');
      return defaultMsg.isNotEmpty ? defaultMsg : 'Please wait...';
    }

    final trimmed = message!.trim();
    // If the message is a raw translation key like 'refresh_loading' or 'loading_wait',
    // translate it via the existing localization system.
    final translated = context.tr(trimmed);
    if (translated.isNotEmpty && translated != trimmed) {
      return translated;
    }
    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.sizeOf(context);

    final baseSurface = isDark ? Color.lerp(const Color(0xFF171515), colors.heritageMaroon, 0.12)! : Color.lerp(colors.white, colors.ivory, 0.28)!;

    final highlightedSurface = Color.lerp(baseSurface, colors.heritageGold, isDark ? 0.07 : 0.035)!;

    final displayMessage = _resolveMessage(context);
    final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
    final localizedMandalTitle = context.tr('app_title').isNotEmpty ? context.tr('app_title') : (isGujarati ? 'શ્રી પવનપુત્ર ગરબી મંડળ' : 'PAVAN PUTRA GARBI MANDAL');

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth ? constraints.maxWidth : screenSize.width;
        final cardMaxWidth = math.max(0.0, math.min(420.0, availableWidth - 32.0));
        final cardMinWidth = math.min(260.0, cardMaxWidth);
        final isCompact = screenSize.height < 600 || screenSize.width < 360;
        final cardRadius = BorderRadius.circular(24);

        // Logo and indicator geometry:
        // Logo diameter = 48.0
        // Indicator container = 60.0 (provides a consistent, tight ~3.6px gap around logo)
        // Indicator strokeWidth = 2.4
        // Both are placed inside a Center/Stack so they remain concentric and non-overlapping.
        const double logoSize = 48.0;
        const double indicatorSize = 60.0;
        const double outerTrackSize = 72.0;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: cardMinWidth, maxWidth: cardMaxWidth),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: cardRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.12),
                    blurRadius: 36,
                    spreadRadius: -8,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: colors.heritageGold.withValues(alpha: isDark ? 0.045 : 0.07),
                    blurRadius: 24,
                    spreadRadius: -12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: cardRadius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: isCompact ? 24 : 30, vertical: isCompact ? 26 : 32),
                    decoration: BoxDecoration(
                      borderRadius: cardRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          baseSurface.withValues(alpha: isDark ? 0.95 : 0.96),
                          highlightedSurface.withValues(alpha: isDark ? 0.92 : 0.94),
                        ],
                      ),
                      border: Border.all(color: isDark ? colors.stone.withValues(alpha: 0.24) : colors.heritageMaroon.withValues(alpha: 0.13), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label: displayMessage,
                          liveRegion: true,
                          child: SizedBox(
                            width: outerTrackSize,
                            height: outerTrackSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Subtle ambient heritage glow ring
                                Container(
                                  width: outerTrackSize,
                                  height: outerTrackSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.heritageGold.withValues(alpha: isDark ? 0.06 : 0.04),
                                  ),
                                ),

                                // Perfectly centered brand logo
                                const BrandLogoWidget(size: logoSize, isCircular: true),

                                // Circular progress indicator fitting tightly around the logo
                                SizedBox(
                                  width: indicatorSize,
                                  height: indicatorSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.6,
                                    strokeCap: StrokeCap.round,
                                    valueColor: AlwaysStoppedAnimation<Color>(colors.heritageGold),
                                    backgroundColor: colors.heritageGold.withValues(alpha: isDark ? 0.16 : 0.14),
                                    semanticsLabel: displayMessage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: isCompact ? 20 : 24),

                        Text(
                          displayMessage,
                          textAlign: TextAlign.center,
                          style:
                              (isGujarati
                                      ? styles.gujaratiSerif(context, size: 16, fontWeight: FontWeight.w600, color: colors.getPrimaryTextColor(context))
                                      : styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w600, color: colors.getPrimaryTextColor(context)))
                                  .copyWith(height: 1.3),
                        ),

                        const SizedBox(height: 9),

                        Text(
                          localizedMandalTitle,
                          textAlign: TextAlign.center,
                          style:
                              (isGujarati
                                      ? styles.gujaratiSerif(context, size: 11, fontWeight: FontWeight.w700, color: colors.getAccentColor(context))
                                      : styles.cleanSans(context, size: 9, fontWeight: FontWeight.w700, letterSpacing: 1.35, color: colors.getAccentColor(context)))
                                  .copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!isFullScreen) {
      return content;
    }

    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: ColoredBox(color: (isDark ? Colors.black : colors.ivory).withValues(alpha: 0.55), child: content),
        ),
      ),
    );
  }
}
