import 'package:flutter/material.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';

/// Segment item definition
class MyAppSegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const MyAppSegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// --------------------------------------------------------------------------
/// MY APP SEGMENT VIEW
/// Capsule pill segmented control matching Heritage Design System:
/// - Rounded capsule container (20px).
/// - Active segment highlighted with checkmark (e.g. ✔ ગુજરાતી / ✔ EN).
/// - 100% responsive with horizontal scroll wrapper (zero RenderFlex overflow).
/// - Theme-adaptive for Light & Dark modes.
/// - Dedicated MyAppSegmentView.language factory for bilingual language switchers.
/// --------------------------------------------------------------------------
class MyAppSegmentView<T> extends StatelessWidget {
  final T selectedValue;
  final List<MyAppSegmentItem<T>> segments;
  final ValueChanged<T> onValueChanged;
  final bool showCheckmark;
  final bool isCompact;

  const MyAppSegmentView({
    super.key,
    required this.selectedValue,
    required this.segments,
    required this.onValueChanged,
    this.showCheckmark = true,
    this.isCompact = true,
  });

  /// Factory helper for bilingual language toggles (Gujarati / English)
  static Widget language({
    Key? key,
    required String selectedLanguage, // 'gu' or 'en'
    required ValueChanged<String> onLanguageChanged,
    bool isCompact = true,
  }) {
    return MyAppSegmentView<String>(
      key: key,
      selectedValue: selectedLanguage,
      onValueChanged: onLanguageChanged,
      showCheckmark: true,
      isCompact: isCompact,
      segments: const [
        MyAppSegmentItem(value: 'en', label: 'EN'),
        MyAppSegmentItem(value: 'gu', label: 'ગુજ'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1B1B) : colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: segments.map((item) {
            final isSelected = item.value == selectedValue;

            final activeBg = isDark
                ? colors.heritageMaroon
                : colors.heritageGold.withValues(alpha: 0.18);

            final activeTextColor = isDark
                ? Colors.white
                : colors.heritageMaroon;

            final activeIconColor = isDark
                ? colors.lightGold
                : colors.heritageMaroon;

            return InkWell(
              onTap: () => onValueChanged(item.value),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 10 : 14,
                  vertical: isCompact ? 5 : 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected && isDark
                      ? [
                          BoxShadow(
                            color: colors.heritageMaroon.withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected && showCheckmark) ...[
                      Icon(
                        Icons.check_rounded,
                        size: isCompact ? 13 : 15,
                        color: activeIconColor,
                      ),
                      const SizedBox(width: 5),
                    ] else if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: isCompact ? 13 : 15,
                        color: isSelected
                            ? activeIconColor
                            : colors.getMutedTextColor(context),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      item.label,
                      style: styles.cleanSans(
                        context,
                        size: isCompact ? 11 : 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? activeTextColor
                            : colors.getMutedTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
