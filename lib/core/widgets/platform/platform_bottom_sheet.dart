import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/platform_info.dart';

class PlatformBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) async {
    if (PlatformInfo.isWeb) {
      return await showDialog<T>(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: SizedBox(
            width: 500,
            child: child,
          ),
        ),
      );
    }
    if (PlatformInfo.isIOS) {
      return await showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          width: double.infinity,
          // Limit height or logic depends on content
          child: SafeArea(
            top: false, 
            child: Material( // Wrap in Material to support Material widgets inside if any
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      );
    } else {
      return await showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        useSafeArea: true,
        builder: (context) => child,
      );
    }
  }
}
