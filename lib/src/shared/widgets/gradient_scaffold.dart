import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_provider.dart';
import '../../features/preview_app/logic/preview_provider.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final Widget? endDrawer;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final ObstructingPreferredSizeWidget? navigationBar;

  const GradientScaffold({super.key, required this.body, this.bottomNavigationBar, this.appBar, this.endDrawer, this.navigationBar});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, PlatformProvider>(
      builder: (_, themeProvider, platformProvider, _) {
        return platformProvider.shouldUseCupertinoUI(context) ? _buildCupertino(context, themeProvider) : _buildMaterial(context, themeProvider);
      },
    );
  }

  /// -------------------- CUPERTINO --------------------
  Widget _buildCupertino(BuildContext context, ThemeProvider themeProvider) {
    final cupertinoTheme = CupertinoTheme.of(context);
    final isDark = cupertinoTheme.brightness == Brightness.dark;

    final topColor = themeProvider.seedColor;
    final bottomColor = isDark ? CupertinoColors.black : CupertinoColors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [topColor, bottomColor]),
      ),
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.transparent,
        navigationBar: navigationBar,
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: bottomNavigationBar != null ? 80 : 0),
                child: body,
              ),
              if (bottomNavigationBar != null) Positioned(left: 0, right: 0, bottom: 0, child: bottomNavigationBar!),
            ],
          ),
        ),
      ),
    );
  }

  /// -------------------- MATERIAL --------------------
  Widget _buildMaterial(BuildContext context, ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topColor = themeProvider.seedColor;
    final bottomColor = isDark ? Colors.black : Colors.white;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [topColor, bottomColor]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: SafeArea(child: body),
        bottomNavigationBar: bottomNavigationBar,
        endDrawer: endDrawer,
      ),
    );
  }
}
