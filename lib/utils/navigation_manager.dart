import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationManager {
  void goToHome(BuildContext context) => context.go('/');
  void goToAbout(BuildContext context) => context.go('/about');
  void goToHistory(BuildContext context) => context.go('/history');

  void goToArchive(BuildContext context) => context.go('/archive');
  void goToArchiveYear(BuildContext context, {required String year}) =>
      context.go('/archive/$year');

  void goToGallery(BuildContext context) => context.go('/gallery');
  void goToGalleryAlbum(
    BuildContext context, {
    required String year,
    required String album,
  }) => context.go('/gallery/$year/$album');

  void goToVideos(BuildContext context) => context.go('/videos');

  void goToBlog(BuildContext context) => context.go('/blog');
  void goToBlogDetail(BuildContext context, {required String slug}) =>
      context.go('/blog/$slug');

  void goToContact(BuildContext context) => context.go('/contact');

  void goToAdminLogin(BuildContext context) => context.go('/admin/login');
  void goToAdminDashboard(BuildContext context) => context.go('/admin');

  void go(BuildContext context, String route) => context.go(route);

  static const List<AppNavItem> mainNavItems = [
    AppNavItem(labelKey: 'nav_home', route: '/', icon: Icons.home_rounded),
    AppNavItem(labelKey: 'nav_about', route: '/about', icon: Icons.info_outline_rounded),
    AppNavItem(labelKey: 'nav_history', route: '/history', icon: Icons.history_edu_rounded),
    AppNavItem(labelKey: 'nav_archive', route: '/archive', icon: Icons.calendar_month_rounded),
    AppNavItem(labelKey: 'nav_gallery', route: '/gallery', icon: Icons.photo_library_rounded),
    AppNavItem(labelKey: 'nav_videos', route: '/videos', icon: Icons.play_circle_outline_rounded),
    AppNavItem(labelKey: 'nav_blog', route: '/blog', icon: Icons.article_outlined),
    AppNavItem(labelKey: 'nav_contact', route: '/contact', icon: Icons.mail_outline_rounded),
  ];
}

class AppNavItem {
  final String labelKey;
  final String route;
  final IconData icon;

  const AppNavItem({
    required this.labelKey,
    required this.route,
    required this.icon,
  });
}
