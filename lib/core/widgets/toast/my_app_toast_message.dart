import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';

/// Centralized, lightweight, sophisticated Toast Notification manager for Pavan Putra Garbi Mandal.
/// Automatically adapts to Light and Dark themes with subtle, modern aesthetics.
class MyAppToastMessage {
  MyAppToastMessage._();

  /// Displays a Success Toast Notification
  static ToastificationItem success(BuildContext context, {required String title, String? description, Duration duration = const Duration(seconds: 4)}) {
    return _showToast(
      context: context,
      type: ToastificationType.success,
      title: title,
      description: description,
      duration: duration,
      icon: Icons.check_circle_rounded,
      accentColor: const Color(0xFF1B873F),
    );
  }

  /// Alias for success matching spelling variations
  static ToastificationItem sucess(BuildContext context, {required String title, String? description, Duration duration = const Duration(seconds: 4)}) {
    return success(context, title: title, description: description, duration: duration);
  }

  /// Displays an Error Toast Notification
  static ToastificationItem error(BuildContext context, {required String title, String? description, Duration duration = const Duration(seconds: 5)}) {
    return _showToast(
      context: context,
      type: ToastificationType.error,
      title: title,
      description: description,
      duration: duration,
      icon: Icons.error_rounded,
      accentColor: const Color(0xFFD32F2F),
    );
  }

  /// Displays a Warning Toast Notification
  static ToastificationItem warning(BuildContext context, {required String title, String? description, Duration duration = const Duration(seconds: 4)}) {
    return _showToast(
      context: context,
      type: ToastificationType.warning,
      title: title,
      description: description,
      duration: duration,
      icon: Icons.warning_rounded,
      accentColor: const Color(0xFFE65100),
    );
  }

  /// Displays an Informational Toast Notification
  static ToastificationItem info(BuildContext context, {required String title, String? description, Duration duration = const Duration(seconds: 4)}) {
    final colors = serviceLocator<MyAppColors>();
    final isDark = colors.isDarkMode(context);

    return _showToast(
      context: context,
      type: ToastificationType.info,
      title: title,
      description: description,
      duration: duration,
      icon: Icons.info_rounded,
      accentColor: isDark ? const Color(0xFFD4AF37) : const Color(0xFF570814),
    );
  }

  static ToastificationItem _showToast({
    required BuildContext context,
    required ToastificationType type,
    required String title,
    String? description,
    required Duration duration,
    required IconData icon,
    required Color accentColor,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;

    final bgColor = isDark ? const Color(0xFF1E1719) : Colors.white;
    final borderColor = isDark ? const Color(0xFF382E31) : const Color(0xFFE8E2D8);
    final titleColor = isDark ? const Color(0xFFF7F5ED) : const Color(0xFF1F1A17);
    final descColor = isDark ? const Color(0xFFB5AFA6) : const Color(0xFF5A544C);

    return toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      alignment: isMobile ? Alignment.topCenter : Alignment.topRight,
      autoCloseDuration: duration,
      animationDuration: const Duration(milliseconds: 280),
      borderRadius: BorderRadius.circular(12),
      backgroundColor: bgColor,
      foregroundColor: titleColor,
      borderSide: BorderSide(color: borderColor, width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
      icon: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: accentColor, size: 17),
      ),
      title: Text(
        title,
        style: styles.cleanSans(context, size: 13.5, fontWeight: FontWeight.w700, color: titleColor),
      ),
      description: description != null && description.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                description,
                style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w400, color: descColor, height: 1.35),
              ),
            )
          : null,
      primaryColor: accentColor,
      showProgressBar: true,
      progressBarTheme: ProgressIndicatorThemeData(color: accentColor, linearTrackColor: accentColor.withValues(alpha: 0.12)),
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.always),
      dragToClose: true,
      closeOnClick: false,
      pauseOnHover: true,
    );
  }
}
