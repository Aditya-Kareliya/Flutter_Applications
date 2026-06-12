import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../utils/platform_info.dart';

class PlatformScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final PreferredSizeWidget? appBar; // Material App Bar
  final ObstructingPreferredSizeWidget? cupertinoNavigationBar; // iOS Nav Bar
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;

  const PlatformScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.appBar,
    this.cupertinoNavigationBar,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: cupertinoNavigationBar,
        backgroundColor: backgroundColor ?? CupertinoColors.systemBackground,
        child: Material( // Added Material ancestor for iOS
          color: Colors.transparent,
          child: SafeArea(
            top: !extendBodyBehindAppBar,
            bottom: false,
            child: body,
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: backgroundColor,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      );
    }
  }
}
