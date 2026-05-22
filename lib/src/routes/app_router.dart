import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/portfolio/presentation/portfolio_screen.dart';
import '../features/preview_app/presentation/screens/home_screen.dart';
import '../features/preview_app/features/qr_module/presentation/screens/qr_dashboard_screen.dart';
import '../features/preview_app/features/qr_module/presentation/screens/qr_generator_screen.dart';
import '../features/preview_app/features/color_palette/presentation/color_palette_screen.dart';
import '../features/preview_app/features/password_generator/presentation/password_screen.dart';
import '../features/preview_app/features/unit_converter/presentation/unit_screen.dart';
import '../features/preview_app/features/bmi_calculator/presentation/bmi_screen.dart';
import '../features/preview_app/features/tip_calculator/presentation/tip_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return PortfolioScreen(location: state.matchedLocation, child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/qr',
          builder: (context, state) => const QRDashboardScreen(),
          routes: [
            GoRoute(path: 'create', builder: (context, state) => const QRGeneratorScreen()),
            GoRoute(
              path: 'edit/:id',
              builder: (context, state) {
                final id = state.pathParameters['id'];
                return QRGeneratorScreen(qrId: id);
              },
            ),
          ],
        ),
        GoRoute(path: '/colors', builder: (context, state) => const ColorPaletteScreen()),
        GoRoute(path: '/password', builder: (context, state) => const PasswordScreen()),
        GoRoute(path: '/units', builder: (context, state) => const UnitScreen()),
        GoRoute(path: '/bmi', builder: (context, state) => const BmiScreen()),
        GoRoute(path: '/tip', builder: (context, state) => const TipScreen()),
      ],
    ),
  ],
);
