import 'dart:ui';
import 'package:flutter/material.dart';
import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';
import '../buttons/my_app_buttons.dart';

/// Shows a sophisticated dialog with a blurred dismissible backdrop barrier,
/// matching the heritage design system of the Mandal app.
Future<T?> showMyAppDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
  String? barrierLabel = 'Dismiss Dialog',
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Duration transitionDuration = const Duration(milliseconds: 240),
}) {
  final colors = serviceLocator<MyAppColors>();
  final styles = serviceLocator<MyAppTextStyles>();
  final isDark = colors.isDarkMode(context);

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? 'Dismiss',
    barrierColor: isDark ? Colors.black.withValues(alpha: 0.65) : Colors.black.withValues(alpha: 0.35),
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    transitionDuration: transitionDuration,
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curve),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (barrierDismissible)
                  Positioned.fill(
                    child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(dialogContext).pop(), child: const SizedBox.expand()),
                  ),
                SafeArea(
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {}, // Prevent taps on dialog from dismissing
                        child: Theme(
                          data: Theme.of(dialogContext).copyWith(
                            dialogTheme: DialogThemeData(
                              backgroundColor: colors.getCardBackgroundColor(dialogContext),
                              surfaceTintColor: Colors.transparent,
                              elevation: 16,
                              shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.5), width: 1.2),
                              ),
                              titleTextStyle: styles.editorialSerif(dialogContext, size: 20, fontWeight: FontWeight.w700),
                              contentTextStyle: styles.bodyText(dialogContext).copyWith(fontSize: 14.5, height: 1.55),
                              actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                          child: builder(dialogContext),
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

/// A standard modal dialog container with refined heritage aesthetics.
class MyAppDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? subtitle;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const MyAppDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    required this.content,
    this.actions,
    this.maxWidth = 540,
    this.padding,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);
    final screenSize = MediaQuery.sizeOf(context);
    final effectiveMaxWidth = screenSize.width < (maxWidth + 32) ? (screenSize.width - 24) : maxWidth;

    return Container(
      width: effectiveMaxWidth,
      constraints: BoxConstraints(maxHeight: screenSize.height * 0.90),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.22),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            if (title != null || titleWidget != null || showCloseButton)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: colors.getBorderColor(context).withValues(alpha: 0.4), width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (titleWidget != null) titleWidget! else if (title != null) Text(title!, style: styles.editorialSerif(context, size: 19, fontWeight: FontWeight.w700)),
                          if (subtitle != null) ...[const SizedBox(height: 3), subtitle!],
                        ],
                      ),
                    ),
                    if (showCloseButton)
                      IconButton(
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        tooltip: 'Close',
                        splashRadius: 18,
                        visualDensity: VisualDensity.compact,
                        color: colors.getSecondaryTextColor(context),
                      ),
                  ],
                ),
              ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(physics: const ClampingScrollPhysics(), padding: padding ?? const EdgeInsets.all(20), child: content),
            ),

            // Actions Footer
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.15) : colors.heritageGold.withValues(alpha: 0.05),
                  border: Border(top: BorderSide(color: colors.getBorderColor(context).withValues(alpha: 0.4), width: 1)),
                ),
                child: Wrap(alignment: WrapAlignment.end, crossAxisAlignment: WrapCrossAlignment.center, spacing: 10, runSpacing: 8, children: actions!),
              ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show a standard confirmation modal with blur backdrop
Future<bool?> showMyAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDanger = false,
  IconData? icon,
}) {
  final colors = serviceLocator<MyAppColors>();
  final styles = serviceLocator<MyAppTextStyles>();

  return showMyAppDialog<bool>(
    context: context,
    builder: (dialogContext) => MyAppDialog(
      maxWidth: 440,
      titleWidget: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 20, color: isDanger ? colors.sacredRed : colors.heritageGold), const SizedBox(width: 8)],
          Expanded(
            child: Text(title, style: styles.editorialSerif(dialogContext, size: 19, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      content: Text(message, style: styles.bodyText(dialogContext)),
      actions: [
        MyAppTextButton(onPressed: () => Navigator.of(dialogContext).pop(false), label: cancelLabel),
        MyAppFillButton(isDanger: isDanger, label: confirmLabel, onPressed: () => Navigator.of(dialogContext).pop(true)),
      ],
    ),
  );
}
