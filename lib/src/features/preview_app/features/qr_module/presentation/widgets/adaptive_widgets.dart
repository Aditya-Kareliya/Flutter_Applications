import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';

import '../../../../logic/preview_provider.dart';

bool _isCupertino(BuildContext context) => Provider.of<PlatformProvider>(context).useCupertinoStyle;

class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? leading;

  const AdaptiveScaffold({
    super.key,
    required this.body,
    required this.title,
    this.floatingActionButton,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    if (_isCupertino(context)) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: actions ?? [],
          ),
          leading: leading,
        ),
        child: SafeArea(child: body),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
          leading: leading,
        ),
        body: body,
        floatingActionButton: floatingActionButton,
      );
    }
  }
}

class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const AdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    if (_isCupertino(context)) {
      return CupertinoButton(
        color: isPrimary ? CupertinoColors.activeBlue : null,
        onPressed: onPressed,
        child: Text(text),
      );
    } else {
      return isPrimary
          ? ElevatedButton(onPressed: onPressed, child: Text(text))
          : TextButton(onPressed: onPressed, child: Text(text));
    }
  }
}

class AdaptiveLoader extends StatelessWidget {
  const AdaptiveLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isCupertino(context)
          ? const CupertinoActivityIndicator()
          : const CircularProgressIndicator(),
    );
  }
}

class AdaptiveSwitch extends StatelessWidget {
    final bool value;
    final ValueChanged<bool> onChanged;
    final Color activeColor;
    
    const AdaptiveSwitch({super.key, required this.value, required this.onChanged, required this.activeColor});
    
    @override
    Widget build(BuildContext context) {
        if (_isCupertino(context)) {
            return CupertinoSwitch(value: value, onChanged: onChanged, activeColor: activeColor);
        } else {
            return Switch(value: value, onChanged: onChanged, activeColor: activeColor);
        }
    }
}

void showAdaptiveFeedback(BuildContext context, String message, {bool isError = false}) {
  if (!context.mounted) return;
  final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  if (isIOS) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(isError ? 'Error' : 'Success'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } else {
    DelightToastBar(
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      builder: (toastContext) => ToastCard(
        leading: Icon(
          isError ? Icons.error_outline : Icons.check_circle_outline,
          color: isError ? Colors.red : Colors.green,
          size: 28,
        ),
        title: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: isDarkMode ? Colors.white : Colors.black87),
        ),
      ),
    ).show(context);
  }
}
