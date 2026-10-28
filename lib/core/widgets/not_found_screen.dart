import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../bootstrap/app_startup_gate.dart';
import '../dependency_injection/dependency_injection.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_scaffold/my_app_scaffold.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import '../widgets/cultural_frame_card.dart';
import '../widgets/heritage_badge.dart';

import '../../modules/about_module/presentation/about_screen.dart';
import '../../modules/admin_module/auth/presentation/admin_auth_gate.dart';
import '../../modules/archive_module/presentation/archive_screen.dart';
import '../../modules/blog_module/presentation/blog_screen.dart';
import '../../modules/contact_module/presentation/contact_screen.dart';
import '../../modules/gallery_module/presentation/gallery_screen.dart';
import '../../modules/history_module/presentation/history_screen.dart';
import '../../modules/videos_module/presentation/videos_screen.dart';

class NotFoundScreen extends StatelessWidget {
  final String? path;

  const NotFoundScreen({super.key, this.path});

  @override
  Widget build(BuildContext context) {
    if (path != null && path!.isNotEmpty) {
      final normalized = path!.trim().toLowerCase().replaceAll(RegExp(r'^/+|/+$'), '');

      // 1. Direct match with standard app modules
      if (normalized == '' || normalized == 'home') {
        return const AppStartupGate();
      }
      if (normalized == 'about') {
        return const AboutScreen();
      }
      if (normalized == 'history') {
        return const HistoryScreen();
      }
      if (normalized == 'archive') {
        return const ArchiveScreen();
      }
      if (normalized.startsWith('archive/')) {
        final year = normalized.replaceFirst('archive/', '');
        return ArchiveScreen(year: year);
      }
      if (normalized == 'gallery') {
        return const GalleryScreen(year: '2025', album: 'all');
      }
      if (normalized.startsWith('gallery/')) {
        final parts = normalized.replaceFirst('gallery/', '').split('/');
        final year = parts.isNotEmpty ? parts[0] : '2025';
        final album = parts.length > 1 ? parts[1] : 'all';
        return GalleryScreen(year: year, album: album);
      }
      if (normalized == 'videos') {
        return const VideosScreen();
      }
      if (normalized == 'blog') {
        return const BlogScreen();
      }
      if (normalized.startsWith('blog/')) {
        final slug = normalized.replaceFirst('blog/', '');
        return BlogScreen(slug: slug);
      }
      if (normalized == 'contact') {
        return const ContactScreen();
      }
      if (normalized == 'admin' || normalized == 'admin/login') {
        return const AdminAuthGate();
      }
    }

    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';

    return MyAppScaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 36 : 64,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: CulturalFrameCard(
              padding: EdgeInsets.all(isMobile ? 24 : 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeritageBadge(
                    label: isGujarati ? '૪૦૪ • પેજ મળ્યું નથી' : '404 • PAGE NOT FOUND',
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.explore_off_rounded,
                    size: isMobile ? 64 : 80,
                    color: colors.heritageGold,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '404',
                    style: styles.editorialSerif(
                      context,
                      size: isMobile ? 38 : 48,
                      fontWeight: FontWeight.w700,
                      color: colors.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isGujarati ? 'આ પૃષ્ઠ ઉપલબ્ધ નથી' : 'Page Not Found',
                    style: styles.cleanSans(
                      context,
                      size: isMobile ? 18 : 22,
                      fontWeight: FontWeight.w700,
                      color: colors.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isGujarati
                        ? 'તમે જે પેજ શોધી રહ્યા છો તે અસ્તિત્વમાં નથી અથવા સ્થળાંતરિત થયેલ છે. કૃપા કરીને નીચેના મુખ્ય વિભાગોમાંથી પસંદ કરો.'
                        : 'The page you are looking for is currently not available or has been moved. Let us guide you back to our sacred archives.',
                    textAlign: TextAlign.center,
                    style: styles.bodyText(context).copyWith(
                          fontSize: isMobile ? 13.5 : 15,
                          height: 1.6,
                        ),
                  ),
                  const SizedBox(height: 28),

                  // Quick navigation links
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildQuickLink(context, 'Home', isGujarati ? 'મુખ્ય પૃષ્ઠ' : 'Home', '/', Icons.home_rounded, colors),
                      _buildQuickLink(context, 'About', isGujarati ? 'પરિચય' : 'About', '/about', Icons.info_outline_rounded, colors),
                      _buildQuickLink(context, 'History', isGujarati ? 'ઇતિહાસ' : 'History', '/history', Icons.history_edu_rounded, colors),
                      _buildQuickLink(context, 'Archive', isGujarati ? 'આર્કાઇવ' : 'Archive', '/archive', Icons.inventory_2_outlined, colors),
                      _buildQuickLink(context, 'Gallery', isGujarati ? 'ગેલેરી' : 'Gallery', '/gallery', Icons.photo_library_outlined, colors),
                      _buildQuickLink(context, 'Videos', isGujarati ? 'વિડિયોઝ' : 'Videos', '/videos', Icons.play_circle_outline_rounded, colors),
                      _buildQuickLink(context, 'Blog', isGujarati ? 'બ્લોગ' : 'Blog', '/blog', Icons.article_outlined, colors),
                      _buildQuickLink(context, 'Contact', isGujarati ? 'સંપર્ક' : 'Contact', '/contact', Icons.mail_outline_rounded, colors),
                    ],
                  ),
                  const SizedBox(height: 24),

                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.heritageMaroon,
                      foregroundColor: colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: colors.heritageGold.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: Text(
                      isGujarati ? 'મુખ્ય પૃષ્ઠ પર પાછા જાઓ' : 'Return to Home',
                      style: styles.cleanSans(
                        context,
                        size: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context,
    String id,
    String label,
    String route,
    IconData icon,
    MyAppColors colors,
  ) {
    return ActionChip(
      avatar: Icon(icon, size: 15, color: colors.heritageGold),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      backgroundColor: colors.getCardBackgroundColor(context),
      side: BorderSide(color: colors.getBorderColor(context)),
      onPressed: () => context.go(route),
    );
  }
}
