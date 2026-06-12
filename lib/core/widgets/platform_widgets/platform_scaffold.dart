import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/platform_info.dart';

class PlatformScaffold extends StatelessWidget {
  final Widget body;
  final ObstructingPreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const PlatformScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: appBar,
        backgroundColor: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              body,
              if (floatingActionButton != null)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: floatingActionButton!,
                ),
            ],
          ),
        ),
      );
    } else {
      // Material
      // Convert CupertinoNavigationBar to generic PreferredSizeWidget if possible, but usually we pass specific types.
      // For simplicity, we'll assume the caller passes a widget that can be adapted or we use specific Material/Cupertino builders.
      // Actually, standardizing AppBar across platforms is tricky with strong types.
      // Better approach: Let parent provide platform-specific AppBar logic or use a PlatformAppBar widget.
      // For this simplified implementation, we'll assume standard Scaffold structure.
      
      return Scaffold(
        body: body,
        // Helper specifically for our use case where we might pass a "PlatformAppBar" which returns a specific widget type
        appBar: appBar is PreferredSizeWidget ? (appBar as PreferredSizeWidget) : null, 
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: backgroundColor,
      );
    }
  }
}
