import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CustomSnackbar {
  static void showSuccess(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(
        message: message,
        backgroundColor: Colors.green.shade600,
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(
        message: message,
        backgroundColor: Colors.redAccent.shade400,
        icon: const Icon(Icons.error_outline, color: Colors.white, size: 28),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.info(
        message: message,
        backgroundColor: Colors.blueAccent.shade400,
        icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
