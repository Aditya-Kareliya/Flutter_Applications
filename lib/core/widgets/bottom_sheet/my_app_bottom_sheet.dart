import 'dart:ui';
import 'package:flutter/material.dart';
import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';

/// Item definition for [showMyAppBottomSheet].
class MyAppBottomSheetItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final bool isDestructive;

  const MyAppBottomSheetItem({required this.value, required this.label, this.subtitle, this.icon, this.iconColor, this.isDestructive = false});
}

/// Displays a polished, modern mobile bottom sheet with:
/// - Smooth, linear bottom-to-top open and top-to-down close transitions.
/// - Full-screen blurred backdrop dismissible barrier (matching [showMyAppPopupMenu]).
/// - Floating rounded card (radius 15) with subtle gold border and shadow.
/// - Prominent title on top-left and "Cancel" on top-right.
/// - Full-width action rows with vibrant left icons, clear typography, and trailing checkmarks.
Future<T?> showMyAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  String cancelLabel = 'Cancel',
  required List<MyAppBottomSheetItem<T>> items,
  T? selectedValue,
  double? fixedHeight,
}) {
  final colors = serviceLocator<MyAppColors>();
  final styles = serviceLocator<MyAppTextStyles>();
  final isDark = colors.isDarkMode(context);
  final screenSize = MediaQuery.sizeOf(context);

  final sheetHeight = fixedHeight ?? (screenSize.height * 0.50).clamp(320.0, 460.0);

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Bottom Sheet',
    barrierColor: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.22),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Stack(
          children: [
            // Tap outside to dismiss
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(dialogContext).pop(), child: const SizedBox.expand()),
            ),

            // Bottom sheet floating card sliding up smoothly from bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(curve),
                child: SafeArea(
                  top: false,
                  child: Container(
                    height: sheetHeight,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: colors.getCardBackgroundColor(context),
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.22),
                          blurRadius: 28,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Header: Title on Left, Cancel on Right
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: styles.cleanSans(context, size: 17.5, fontWeight: FontWeight.w800, color: colors.getPrimaryTextColor(context)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () => Navigator.of(dialogContext).pop(),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      cancelLabel,
                                      style: styles.cleanSans(context, size: 15, fontWeight: FontWeight.w600, color: isDark ? colors.lightGold : colors.heritageMaroon),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Subtle header divider
                          Divider(height: 1, thickness: 0.8, color: colors.getBorderColor(context).withValues(alpha: 0.4)),

                          // Scrollable Items List with 8px space on all 4 sides (left, right, top, bottom)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: ListView.separated(
                                physics: const ClampingScrollPhysics(),
                                padding: const EdgeInsets.only(top: 8, bottom: 4),
                                itemCount: items.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 4, thickness: 0.6, indent: 8, endIndent: 8, color: colors.getBorderColor(context).withValues(alpha: 0.35)),
                                itemBuilder: (context, index) {
                                  final item = items[index];
                                  final isSelected = item.value == selectedValue;

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () {
                                      Navigator.of(dialogContext).pop(item.value);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? (isDark ? colors.heritageMaroon.withValues(alpha: 0.25) : colors.heritageGold.withValues(alpha: 0.12))
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      child: Row(
                                        children: [
                                          // Left Icon
                                          if (item.icon != null) ...[
                                            Icon(
                                              item.icon,
                                              size: 22,
                                              color: item.isDestructive ? colors.sacredRed : (item.iconColor ?? (isDark ? colors.heritageGold : const Color(0xFFD97706))),
                                            ),
                                            const SizedBox(width: 14),
                                          ],

                                          // Label & Subtitle
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item.label,
                                                  style: styles.cleanSans(
                                                    context,
                                                    size: 15.5,
                                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                    color: item.isDestructive
                                                        ? colors.sacredRed
                                                        : (isSelected ? (isDark ? colors.lightGold : colors.heritageMaroon) : colors.getPrimaryTextColor(context)),
                                                  ),
                                                ),
                                                if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                                                  const SizedBox(height: 3),
                                                  Text(item.subtitle!, style: styles.cleanSans(context, size: 12, color: colors.getMutedTextColor(context))),
                                                ],
                                              ],
                                            ),
                                          ),

                                          // Suffix Selection Checkmark (Only when selected; no chevron)
                                          if (isSelected) Icon(Icons.check_rounded, size: 22, color: isDark ? colors.lightGold : colors.heritageMaroon),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Persistent bottom padding: exactly 8px matching left, right, and top!
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
