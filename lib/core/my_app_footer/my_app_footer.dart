import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sizer/sizer.dart';

import '../dependency_injection/dependency_injection.dart';
import '../localization/my_app_translations.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import '../widgets/heritage_divider.dart';
import '../widgets/brand_logo/brand_logo_widget.dart';
import '../../utils/navigation_manager.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';

class MyAppFooter extends StatelessWidget {
  const MyAppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 700;

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) => RepaintBoundary(
        child: Container(
          width: 100.w,
          color: colors.getFooterBackgroundColor(context),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 36,
        vertical: isMobile ? 32 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Mandal Row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                runSpacing: 28,
                spacing: 36,
                children: [
                  // Mandal Branding
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 100.w : 420,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BrandLogoWidget(
                              size: 44,
                              isCircular: true,
                              border: Border.all(
                                color: colors.heritageGold,
                                width: 1.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (context.tr('app_title').isNotEmpty)
                                    Text(
                                      context.tr('app_title'),
                                      style: styles.editorialSerif(
                                        context,
                                        size: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  if (context.tr('app_subtitle').isNotEmpty)
                                    Text(
                                      context.tr('app_subtitle'),
                                      style: styles.cleanSans(
                                        context,
                                        size: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        color: colors.getAccentColor(context),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (context.tr('footer_tagline').isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            context.tr('footer_tagline'),
                            style: styles
                                .bodyText(context)
                                .copyWith(
                                  color: colors.getSecondaryTextColor(context),
                                  height: 1.55,
                                  fontSize: 13.5,
                                ),
                          ),
                        ],
                        if (context.tr('footer_motto').isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            context.tr('footer_motto'),
                            style: styles.devotionalMotto(
                              context,
                              size: 16,
                              color: colors.getAccentColor(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Quick Links Column 1: Archive & Media
                  Builder(builder: (context) {
                    final store = AdminDataStore.instance;
                    final isGu = Localizations.localeOf(context).languageCode == 'gu';
                    final col1 = store.footerLinks.where((p) => p.column == 'col1' && p.isEnabled).toList();
                    final title = context.tr('footer_links_title');

                    if (title.isEmpty && col1.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: styles.eyebrow(context),
                          ),
                        if (title.isNotEmpty && col1.isNotEmpty) const SizedBox(height: 14),
                        for (final p in col1)
                          _FooterLink(
                            label: isGu ? (p.titleGu.isNotEmpty ? p.titleGu : p.titleEn) : (p.titleEn.isNotEmpty ? p.titleEn : p.titleGu),
                            onTap: () => _handleLinkClick(context, p.url, p.isExternal),
                          ),
                      ],
                    );
                  }),

                  // Quick Links Column 2: Mandal & Contact
                  Builder(builder: (context) {
                    final store = AdminDataStore.instance;
                    final isGu = Localizations.localeOf(context).languageCode == 'gu';
                    final col2 = store.footerLinks.where((p) => p.column == 'col2' && p.isEnabled).toList();

                    final col2Title = context.tr('footer_links2_title');

                    if (col2Title.isEmpty && col2.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (col2Title.isNotEmpty)
                          Text(
                            col2Title,
                            style: styles.eyebrow(context),
                          ),
                        if (col2Title.isNotEmpty && col2.isNotEmpty) const SizedBox(height: 14),
                        for (final p in col2)
                          _FooterLink(
                            label: isGu ? (p.titleGu.isNotEmpty ? p.titleGu : p.titleEn) : (p.titleEn.isNotEmpty ? p.titleEn : p.titleGu),
                            onTap: () => _handleLinkClick(context, p.url, p.isExternal),
                          ),
                      ],
                    );
                  }),

                  // Social & Contact Information
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? 100.w : 280,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (context.tr('footer_social').isNotEmpty) ...[
                          Text(
                            context.tr('footer_social'),
                            style: styles.eyebrow(context),
                          ),
                          const SizedBox(height: 14),
                        ],
                        Builder(builder: (context) {
                          final store = AdminDataStore.instance;
                          final activeSocials = store.footerSocialLinks.where((s) => s.isEnabled).toList();

                          if (activeSocials.isNotEmpty) {
                            return Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                for (final soc in activeSocials)
                                  _SocialPill(
                                    label: soc.platform,
                                    icon: _getSocialIcon(soc.iconKey),
                                    url: soc.url,
                                  ),
                              ],
                            );
                          }

                          return Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              if (store.settings.youtubeChannel.isNotEmpty)
                                _SocialPill(
                                  label: 'YouTube',
                                  icon: Icons.play_arrow_rounded,
                                  url: store.settings.youtubeChannel,
                                ),
                              if (store.settings.instagramHandle.isNotEmpty)
                                _SocialPill(
                                  label: 'Instagram',
                                  icon: Icons.camera_alt_outlined,
                                  url: store.settings.instagramHandle,
                                ),
                              if (store.settings.facebookUrl.isNotEmpty)
                                _SocialPill(
                                  label: 'Facebook',
                                  icon: Icons.public_rounded,
                                  url: store.settings.facebookUrl,
                                ),
                            ],
                          );
                        }),
                        if (context.tr('footer_location').isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: colors.getAccentColor(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.tr('footer_location'),
                                  style: styles.cleanSans(
                                    context,
                                    size: 12,
                                    color: colors.getSecondaryTextColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (AdminDataStore.instance.settings.contactPhone.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.phone_outlined,
                                size: 15,
                                color: colors.getAccentColor(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AdminDataStore.instance.settings.contactPhone,
                                  style: styles.cleanSans(
                                    context,
                                    size: 12,
                                    color: colors.getSecondaryTextColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (AdminDataStore.instance.settings.contactEmail.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 15,
                                color: colors.getAccentColor(context),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AdminDataStore.instance.settings.contactEmail,
                                  style: styles.cleanSans(
                                    context,
                                    size: 12,
                                    color: colors.getSecondaryTextColor(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              if (context.tr('footer_copyright').isNotEmpty) ...[
                const HeritageDivider(verticalPadding: 24),
                // Bottom Copyright
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('footer_copyright'),
                        style: styles.cleanSans(
                          context,
                          size: 11.5,
                          color: colors.getMutedTextColor(context),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  ),
);
  }

  void _handleLinkClick(BuildContext context, String url, bool isExternal) {
    if (url.isEmpty) return;
    if (isExternal || url.startsWith('http://') || url.startsWith('https://')) {
      launchUrl(Uri.parse(url));
    } else if (url == '/admin' || url == 'admin') {
      serviceLocator<NavigationManager>().goToAdminDashboard(context);
    } else {
      serviceLocator<NavigationManager>().go(context, url);
    }
  }

  static IconData _getSocialIcon(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'youtube':
        return Icons.play_arrow_rounded;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'facebook':
        return Icons.public_rounded;
      case 'whatsapp':
        return Icons.chat_rounded;
      case 'twitter':
      case 'x':
        return Icons.tag_rounded;
      case 'telegram':
        return Icons.send_rounded;
      case 'globe':
        return Icons.language_rounded;
      default:
        return Icons.link_rounded;
    }
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final styles = serviceLocator<MyAppTextStyles>();
    final colors = serviceLocator<MyAppColors>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            label,
            style: styles.cleanSans(
              context,
              size: 13,
              fontWeight: FontWeight.w500,
              color: colors.getPrimaryTextColor(context),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? url;

  const _SocialPill({required this.label, required this.icon, this.url});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return InkWell(
      onTap: () {
        if (url != null && url!.isNotEmpty) {
          String uriStr = url!;
          if (uriStr.startsWith('@')) {
            uriStr = 'https://instagram.com/${uriStr.substring(1)}';
          } else if (uriStr.startsWith('+') || RegExp(r'^\d{10,}$').hasMatch(uriStr.replaceAll(' ', ''))) {
            uriStr = 'https://wa.me/${uriStr.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '')}';
          }
          launchUrl(Uri.parse(uriStr));
        }
      },
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.getBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.getAccentColor(context)),
          const SizedBox(width: 6),
          Text(
            label,
            style: styles.cleanSans(
              context,
              size: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
}

