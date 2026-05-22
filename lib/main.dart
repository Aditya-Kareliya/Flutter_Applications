import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_strategy/url_strategy.dart';

import 'src/core/theme/app_theme.dart';
import 'src/core/theme/theme_provider.dart';
import 'src/routes/app_router.dart';
import 'src/features/portfolio/logic/portfolio_provider.dart';
import 'src/features/preview_app/logic/preview_provider.dart';
import 'src/features/preview_app/features/color_palette/logic/color_palette_provider.dart';
import 'src/features/preview_app/features/password_generator/logic/password_provider.dart';
import 'src/features/preview_app/features/qr_module/logic/qr_provider.dart';
import 'src/features/preview_app/features/bmi_calculator/logic/bmi_provider.dart';
import 'src/features/preview_app/features/tip_calculator/logic/tip_provider.dart';
import 'src/features/preview_app/features/unit_converter/logic/unit_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Removes # from web URLs
  setPathUrlStrategy();

  /// Load saved theme before app starts
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        /// Theme
        ChangeNotifierProvider.value(value: themeProvider),

        /// Core Features
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => PlatformProvider()),

        /// Utility Modules
        ChangeNotifierProvider(create: (_) => QRProvider()),
        ChangeNotifierProvider(create: (_) => ColorPaletteProvider()),
        ChangeNotifierProvider(create: (_) => PasswordProvider()),
        ChangeNotifierProvider(create: (_) => BmiProvider()),
        ChangeNotifierProvider(create: (_) => TipProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,

              /// App name
              title: 'Portfolio',

              /// Light Theme
              theme: MaterialAppTheme.lightTheme(themeProvider.seedColor),

              /// Dark Theme
              darkTheme: MaterialAppTheme.darkTheme(themeProvider.seedColor),

              /// Theme mode
              themeMode: themeProvider.themeMode,

              /// Localization
              localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],

              supportedLocales: const [Locale('en', 'US')],

              /// Router
              routerConfig: appRouter,
            );
          },
        );
      },
    );
  }
}