import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/platform_info.dart';

class PlatformButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;

  const PlatformButton({
    super.key,
    this.onPressed,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        disabledColor: CupertinoColors.quaternarySystemFill,
        child: child,
      );
    } else {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        child: child,
      );
    }
  }
}
