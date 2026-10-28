import 'package:go_router/go_router.dart';

import '../../modules/about_module/presentation/about_screen.dart';
import '../../modules/admin_module/auth/presentation/admin_auth_gate.dart';
import '../../modules/archive_module/presentation/archive_screen.dart';
import '../../modules/blog_module/presentation/blog_screen.dart';
import '../../modules/contact_module/presentation/contact_screen.dart';
import '../../modules/gallery_module/presentation/gallery_screen.dart';
import '../../modules/history_module/presentation/history_screen.dart';
import '../../modules/videos_module/presentation/videos_screen.dart';
import '../bootstrap/app_startup_gate.dart';
import '../widgets/not_found_screen.dart';

import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<T> _buildPageWithDefaultTransition<T>({required BuildContext context, required GoRouterState state, required Widget child}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) => NotFoundScreen(path: state.uri.path),
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const AppStartupGate()),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const AboutScreen()),
    ),
    GoRoute(
      path: '/history',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const HistoryScreen()),
    ),
    GoRoute(
      path: '/archive',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const ArchiveScreen()),
      routes: [
        GoRoute(
          path: ':year',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: ArchiveScreen(year: state.pathParameters['year']),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/gallery',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(
        context: context,
        state: state,
        child: const GalleryScreen(year: '2025', album: 'all'),
      ),
      routes: [
        GoRoute(
          path: ':year/:album',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: GalleryScreen(year: state.pathParameters['year'] ?? '2025', album: state.pathParameters['album'] ?? 'all'),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/videos',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const VideosScreen()),
    ),
    GoRoute(
      path: '/blog',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const BlogScreen()),
      routes: [
        GoRoute(
          path: ':slug',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(
            context: context,
            state: state,
            child: BlogScreen(slug: state.pathParameters['slug']),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/contact',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const ContactScreen()),
    ),
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const AdminAuthGate()),
      routes: [
        GoRoute(
          path: 'login',
          pageBuilder: (context, state) => _buildPageWithDefaultTransition(context: context, state: state, child: const AdminAuthGate()),
        ),
      ],
    ),
  ],
);
