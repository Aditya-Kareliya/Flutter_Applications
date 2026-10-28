import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';

/// Reusable banner for Admin pages that clearly explains which public website section
/// is controlled by the current admin view, with a direct button to preview on the live website.
class AdminWebsiteContextBanner extends StatelessWidget {
  final String websitePageTitle;
  final String websiteRoute;
  final String explanation;

  const AdminWebsiteContextBanner({
    super.key,
    required this.websitePageTitle,
    required this.websiteRoute,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF221517) : const Color(0xFFFBF6EE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF452B2F) : const Color(0xFFE5D5BA),
              width: 1,
            ),
          ),
          child: isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.language_rounded,
                          size: 18,
                          color: isDark ? colors.heritageGold : colors.heritageMaroon,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            websitePageTitle,
                            style: styles.cleanSans(
                              context,
                              size: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? colors.heritageGold : colors.heritageMaroon,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      explanation,
                      style: styles.cleanSans(
                        context,
                        size: 11,
                        color: colors.getMutedTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(
                            color: isDark ? colors.heritageGold.withValues(alpha: 0.6) : colors.heritageMaroon.withValues(alpha: 0.6),
                          ),
                          foregroundColor: isDark ? colors.heritageGold : colors.heritageMaroon,
                        ),
                        onPressed: () => context.go(websiteRoute),
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: const Text('View on Website', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colors.heritageGold.withValues(alpha: 0.15)
                            : colors.heritageMaroon.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.language_rounded,
                        size: 20,
                        color: isDark ? colors.heritageGold : colors.heritageMaroon,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Controls Website Page: ',
                                  style: styles.cleanSans(
                                    context,
                                    size: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: colors.getSecondaryTextColor(context),
                                  ),
                                ),
                                TextSpan(
                                  text: websitePageTitle,
                                  style: styles.cleanSans(
                                    context,
                                    size: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? colors.heritageGold : colors.heritageMaroon,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            explanation,
                            style: styles.cleanSans(
                              context,
                              size: 11,
                              color: colors.getMutedTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        side: BorderSide(
                          color: isDark ? colors.heritageGold.withValues(alpha: 0.6) : colors.heritageMaroon.withValues(alpha: 0.6),
                        ),
                        foregroundColor: isDark ? colors.heritageGold : colors.heritageMaroon,
                      ),
                      onPressed: () => context.go(websiteRoute),
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      label: const Text('View on Website', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
