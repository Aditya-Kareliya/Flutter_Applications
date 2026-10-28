import 'dart:ui';
import 'package:flutter/material.dart';
import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';

/// An individual item inside a [MyAppPopupMenuButton] or [showMyAppPopupMenu].
class MyAppPopupMenuItem<T> {
  final T value;
  final Widget? icon;
  final String? label;
  final Widget? child;
  final bool enabled;

  const MyAppPopupMenuItem({
    required this.value,
    this.icon,
    this.label,
    this.child,
    this.enabled = true,
  }) : assert(label != null || child != null, 'Either label or child must be provided');
}

/// A heritage popup menu button that displays menu items anchored to the button
/// with a sophisticated blurred dismissible backdrop barrier.
/// On compact mobile screens (< 650px), it smartly displays as a polished bottom sheet.
class MyAppPopupMenuButton<T> extends StatefulWidget {
  final List<MyAppPopupMenuItem<T>> Function(BuildContext) itemBuilder;
  final void Function(T)? onSelected;
  final T? initialValue;
  final Widget? icon;
  final Widget? child;
  final String? tooltip;
  final Offset offset;
  final bool enabled;
  final double minWidth;

  const MyAppPopupMenuButton({
    super.key,
    required this.itemBuilder,
    this.onSelected,
    this.initialValue,
    this.icon,
    this.child,
    this.tooltip,
    this.offset = Offset.zero,
    this.enabled = true,
    this.minWidth = 190,
  }) : assert(icon != null || child != null, 'Either icon or child must be provided');

  @override
  State<MyAppPopupMenuButton<T>> createState() => _MyAppPopupMenuButtonState<T>();
}

class _MyAppPopupMenuButtonState<T> extends State<MyAppPopupMenuButton<T>> {
  final GlobalKey _triggerKey = GlobalKey();

  void _showMenu() async {
    if (!widget.enabled) return;

    final renderBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerOffset = renderBox.localToGlobal(Offset.zero);
    final triggerSize = renderBox.size;
    final items = widget.itemBuilder(context);
    if (items.isEmpty) return;

    bool wasSelected = false;
    final selected = await showMyAppPopupMenu<T>(
      context: context,
      triggerOffset: triggerOffset,
      triggerSize: triggerSize,
      items: items,
      initialValue: widget.initialValue,
      offset: widget.offset,
      minWidth: widget.minWidth,
      onSelected: (val) {
        wasSelected = true;
        widget.onSelected?.call(val);
      },
    );

    if (selected != null && mounted && !wasSelected) {
      widget.onSelected?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (widget.child != null) {
      content = InkWell(
        key: _triggerKey,
        borderRadius: BorderRadius.circular(10),
        onTap: widget.enabled ? _showMenu : null,
        child: widget.child,
      );
    } else {
      content = IconButton(
        key: _triggerKey,
        onPressed: widget.enabled ? _showMenu : null,
        icon: widget.icon!,
        tooltip: widget.tooltip,
        splashRadius: 20,
      );
    }

    return content;
  }
}

/// Displays a popup menu anchored to the specified trigger with a blurred dismissible backdrop barrier.
Future<T?> showMyAppPopupMenu<T>({
  required BuildContext context,
  required Offset triggerOffset,
  required Size triggerSize,
  required List<MyAppPopupMenuItem<T>> items,
  T? initialValue,
  Offset offset = Offset.zero,
  double minWidth = 190,
  ValueChanged<T>? onSelected,
}) {
  final colors = serviceLocator<MyAppColors>();
  final styles = serviceLocator<MyAppTextStyles>();
  final isDark = colors.isDarkMode(context);
  final screenSize = MediaQuery.sizeOf(context);

  final bool isMobile = screenSize.width < 600;
  // Responsive width: on mobile screens it dynamically sizes cleanly (~48% width), on tablet/desktop it uses minWidth
  final double effectiveWidth = isMobile
      ? (screenSize.width * 0.48).clamp(165.0, 205.0)
      : minWidth.clamp(170.0, 260.0);

  final double targetY = triggerOffset.dy + triggerSize.height + offset.dy + 6;
  final double estimatedMenuHeight = (items.length * 48.0) + 16.0;
  final bool showAbove = (targetY + estimatedMenuHeight > screenSize.height - 16) && (triggerOffset.dy > estimatedMenuHeight);
  final double menuTop = showAbove
      ? (triggerOffset.dy - estimatedMenuHeight - 6 + offset.dy).clamp(16.0, screenSize.height - 60)
      : targetY.clamp(16.0, screenSize.height - 60);

  // If placing to the right overflows screen, or trigger is on the right half, anchor from the right:
  final bool isAlignRight = (triggerOffset.dx + effectiveWidth > screenSize.width - 16) ||
      ((triggerOffset.dx + triggerSize.width / 2) >= screenSize.width / 2);

  final double? menuRight = isAlignRight
      ? (screenSize.width - (triggerOffset.dx + triggerSize.width) - offset.dx)
          .clamp(12.0, (screenSize.width - effectiveWidth - 12).clamp(12.0, screenSize.width))
      : null;
  final double? menuLeft = !isAlignRight
      ? (triggerOffset.dx + offset.dx)
          .clamp(12.0, (screenSize.width - effectiveWidth - 12).clamp(12.0, screenSize.width))
      : null;

  final Alignment transformAlignment = showAbove
      ? (isAlignRight ? Alignment.bottomRight : Alignment.bottomLeft)
      : (isAlignRight ? Alignment.topRight : Alignment.topLeft);

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss Popup Menu',
    barrierColor: isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.20),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            alignment: transformAlignment,
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curve),
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(dialogContext).pop(),
                    child: const SizedBox.expand(),
                  ),
                ),
                Positioned(
                  top: menuTop,
                  left: menuLeft,
                  right: menuRight,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: effectiveWidth,
                      constraints: BoxConstraints(
                        maxWidth: (screenSize.width - 24).clamp(140.0, 320.0),
                        maxHeight: (screenSize.height * 0.7).clamp(140.0, 480.0),
                      ),
                      decoration: BoxDecoration(
                        color: colors.getCardBackgroundColor(dialogContext),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.heritageGold.withValues(alpha: 0.55),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.22),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < items.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    thickness: 0.8,
                                    indent: 14,
                                    endIndent: 14,
                                    color: colors.getBorderColor(dialogContext).withValues(alpha: 0.35),
                                  ),
                                _buildItemRow<T>(
                                  dialogContext: dialogContext,
                                  rootContext: context,
                                  colors: colors,
                                  styles: styles,
                                  isDark: isDark,
                                  item: items[i],
                                  isSelected: initialValue != null && items[i].value == initialValue,
                                  onSelected: onSelected,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildItemRow<T>({
  required BuildContext dialogContext,
  required BuildContext rootContext,
  required MyAppColors colors,
  required MyAppTextStyles styles,
  required bool isDark,
  required MyAppPopupMenuItem<T> item,
  required bool isSelected,
  ValueChanged<T>? onSelected,
}) {
  final primaryTextColor = isDark ? colors.ivory : colors.black;
  final accentColor = isDark ? colors.lightGold : colors.heritageMaroon;

  return InkWell(
    onTap: item.enabled
        ? () {
            Navigator.of(dialogContext).pop(item.value);
            if (item.value != null) {
              onSelected?.call(item.value);
            }
          }
        : null,
    child: Container(
      color: isSelected
          ? (isDark
              ? colors.heritageMaroon.withValues(alpha: 0.3)
              : colors.heritageGold.withValues(alpha: 0.12))
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.icon != null) ...[
            IconTheme(
              data: IconThemeData(
                size: 18,
                color: isSelected
                    ? accentColor
                    : (isDark ? colors.lightGold : colors.heritageMaroon),
              ),
              child: item.icon!,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: item.child ??
                Text(
                  item.label ?? '',
                  style: styles.cleanSans(
                    rootContext,
                    size: 13.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? accentColor
                        : primaryTextColor,
                  ),
                ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.check_rounded,
              size: 17,
              color: accentColor,
            ),
          ],
        ],
      ),
    ),
  );
}
