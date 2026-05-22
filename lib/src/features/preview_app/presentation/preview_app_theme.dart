import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../logic/preview_provider.dart';

class PreviewAppTheme extends StatelessWidget {
  final Widget child;

  const PreviewAppTheme({super.key, required this.child});

  static const Locale _locale = Locale('en', 'US');

  static const List<LocalizationsDelegate<dynamic>> _delegates = [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate];

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, PlatformProvider>(
      builder: (_, themeProvider, platformProvider, _) {
        final brightness = _resolveBrightness(context, themeProvider.themeMode);
        final effectiveSeedColor = themeProvider.seedColor;

        final ThemeData materialTheme = brightness == Brightness.dark ? MaterialAppTheme.darkTheme(effectiveSeedColor) : MaterialAppTheme.lightTheme(effectiveSeedColor);

        if (platformProvider.useCupertinoStyle) {
          return CupertinoTheme(
            data: CupertinoAppTheme.theme(
              brightness: brightness,
              primaryColor: effectiveSeedColor,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Theme(data: materialTheme, child: _localized(child)),
            ),
          );
        }

        return Theme(data: materialTheme, child: _localized(child));
      },
    );
  }

  Widget _localized(Widget child) {
    return Localizations(locale: _locale, delegates: _delegates, child: child);
  }

  static Brightness _resolveBrightness(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return MediaQuery.of(context).platformBrightness;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
    }
  }
}
