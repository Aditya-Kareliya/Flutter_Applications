import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/localization/my_app_translations.dart';
import '../../../core/my_app_colors/my_app_colors.dart';
import '../../../core/my_app_scaffold/my_app_scaffold.dart';
import '../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/heritage_badge.dart';
import '../../../core/widgets/heritage_divider.dart';
import '../../../core/widgets/article_detail_modal.dart';
import '../../../utils/navigation_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../admin_module/dashboard/data/admin_data_store.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) => const MyAppScaffold(body: _HomeBody()),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SmoothReveal(delay: Duration.zero, child: _HeritageHeroSection()),
        _SmoothReveal(delay: Duration(milliseconds: 120), child: _HeritageStatsStrip()),
        _SmoothReveal(delay: Duration(milliseconds: 200), child: _AboutMandalSection()),
        HeritageDivider(verticalPadding: 32),
        _SmoothReveal(delay: Duration(milliseconds: 260), child: _PillarsOfGarbiSection()),
        HeritageDivider(verticalPadding: 32),
        _SmoothReveal(delay: Duration(milliseconds: 320), child: _SingerBannerCarousel()),
        HeritageDivider(verticalPadding: 32),
        _SmoothReveal(delay: Duration(milliseconds: 380), child: _EldersBlessingsSection()),
        HeritageDivider(verticalPadding: 32),
        _SmoothReveal(delay: Duration(milliseconds: 500), child: _YearArchiveSection()),
        HeritageDivider(verticalPadding: 32),
        _SmoothReveal(delay: Duration(milliseconds: 560), child: _VideosLiveSection()),
        HeritageDivider(verticalPadding: 32),
        _SmoothReveal(delay: Duration(milliseconds: 620), child: _BlogSectionPreview()),
        _SmoothReveal(delay: Duration(milliseconds: 680), child: _CulturalCallToActionBanner()),
        SizedBox(height: 48),
      ],
    );
  }
}

// SMOOTH ANIMATIONS & INTERACTIVE HELPERS
class _SmoothReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _SmoothReveal({required this.child, this.delay = Duration.zero});

  @override
  State<_SmoothReveal> createState() => _SmoothRevealState();
}

class _SmoothRevealState extends State<_SmoothReveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _InteractiveHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _InteractiveHoverCard({required this.child, this.onTap});

  @override
  State<_InteractiveHoverCard> createState() => _InteractiveHoverCardState();
}

class _InteractiveHoverCardState extends State<_InteractiveHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isHovered ? [BoxShadow(color: const Color(0xFFC5A059).withValues(alpha: 0.16), blurRadius: 18, offset: const Offset(0, 8))] : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _HeroActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isFilled;
  final VoidCallback onTap;

  const _HeroActionButton({required this.icon, required this.label, required this.isFilled, required this.onTap});

  @override
  State<_HeroActionButton> createState() => _HeroActionButtonState();
}

class _HeroActionButtonState extends State<_HeroActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final bg = widget.isFilled ? (_isHovered ? const Color(0xFF8C1D27) : colors.heritageMaroon) : (_isHovered ? Colors.white.withValues(alpha: 0.12) : Colors.transparent);

    final border = widget.isFilled
        ? Border.all(color: colors.heritageGold.withValues(alpha: _isHovered ? 0.95 : 0.65), width: 1.2)
        : Border.all(color: _isHovered ? colors.white : const Color(0xFFDDD7CB).withValues(alpha: 0.6), width: 1.2);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(24),
            border: border,
            boxShadow: _isHovered ? [BoxShadow(color: colors.heritageMaroon.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 17, color: colors.white),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.cleanSans(context, color: colors.white, size: 12.5, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. HERO SECTION (REDESIGNED)
class _HeritageHeroSection extends StatelessWidget {
  const _HeritageHeroSection();

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 880;

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final hero = AdminDataStore.instance.heroData;
        final lang = Localizations.maybeLocaleOf(context)?.languageCode ?? 'gu';

        // If all hero elements are completely empty, hide the entire section gracefully
        final hasAnyContent =
            hero.hasSacredInvocation ||
            hero.hasTagBadge ||
            hero.hasTitle ||
            hero.hasMotto ||
            hero.hasDesc ||
            hero.hasCtaPrimary ||
            hero.hasCtaSecondary ||
            hero.hasBottomBadge ||
            hero.hasImage;

        if (!hasAnyContent) {
          return const SizedBox.shrink();
        }

        final showImage = hero.hasImage;

        return Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, isMobile ? 16 : 28, isMobile ? 16 : 32, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF240609), Color(0xFF140203)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3), width: 1.2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 36, offset: const Offset(0, 14))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Subtle Radial Glow behind logo (only when image is present)
                      if (showImage)
                        Positioned(
                          right: isMobile ? -60 : 30,
                          top: isMobile ? -60 : 20,
                          child: Container(
                            width: isMobile ? 260 : 420,
                            height: isMobile ? 260 : 420,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [colors.heritageMaroon.withValues(alpha: 0.28), Colors.transparent]),
                            ),
                          ),
                        ),

                      // Hero Content
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48, vertical: isMobile ? 32 : 52),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showImage) ...[
                                    Center(child: _buildEmblem(colors, hero.imageUrl, size: 190.0)),
                                    const SizedBox(height: 28),
                                  ],
                                  _buildHeroTextContent(context, colors, styles, hero, lang, isMobile: true, hasImage: showImage),
                                ],
                              )
                            : (showImage
                                  ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(flex: 7, child: _buildHeroTextContent(context, colors, styles, hero, lang, isMobile: false, hasImage: true)),
                                        const SizedBox(width: 32),
                                        Expanded(
                                          flex: 5,
                                          child: Center(
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                final double safeSize = (constraints.maxWidth - 20.0).clamp(160.0, 310.0);
                                                return _buildEmblem(colors, hero.imageUrl, size: safeSize);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : _buildHeroTextContent(context, colors, styles, hero, lang, isMobile: false, hasImage: false)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmblem(MyAppColors colors, String imageUrl, {double size = 300.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: colors.heritageGold.withValues(alpha: 0.65),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.deepMaroon.withValues(alpha: 0.50),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: colors.heritageGold.withValues(alpha: 0.22),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: _renderEmblemImage(imageUrl, size: size),
      ),
    );
  }

  Widget _renderEmblemImage(String imageUrl, {required double size}) {
    final baseAsset = Image.asset(
      'assets/images/pavan_putra_logo.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Image.asset(
        'assets/images/pavan_putra_logo.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );

    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIdx = imageUrl.indexOf(',');
        final base64Data = commaIdx != -1 ? imageUrl.substring(commaIdx + 1) : imageUrl;
        return Image.memory(
          base64Decode(base64Data),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => baseAsset,
        );
      } catch (_) {
        return baseAsset;
      }
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          baseAsset,
          CachedNetworkImage(
            imageUrl: imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 200),
            placeholder: (_, _) => const SizedBox.shrink(),
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
        ],
      );
    }

    if (imageUrl.isNotEmpty &&
        imageUrl.startsWith('assets/') &&
        imageUrl != 'assets/images/pavan_putra_logo.png' &&
        imageUrl != 'assets/images/pavan_putra_logo.jpg') {
      return Image.asset(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => baseAsset,
      );
    }

    return baseAsset;
  }

  Widget _buildHeroTextContent(
    BuildContext context,
    MyAppColors colors,
    MyAppTextStyles styles,
    AdminHeroData hero,
    String lang, {
    required bool isMobile,
    required bool hasImage,
  }) {
    final hasBadge1 = hero.hasSacredInvocation;
    final hasBadge2 = hero.hasTagBadge;
    final hasBtn1 = hero.hasCtaPrimary;
    final hasBtn2 = hero.hasCtaSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Two Badges Row (only shown if at least one badge is populated)
        if (hasBadge1 || hasBadge2) ...[
          Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (hasBadge1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F0407),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.55), width: 1.1),
                  ),
                  child: Text(
                    hero.getSacredInvocation(lang),
                    style: styles.gujaratiSerif(context, size: isMobile ? 11.5 : 12.5, fontWeight: FontWeight.w700, color: colors.lightGold),
                  ),
                ),
              if (hasBadge2)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.1),
                  ),
                  child: Text(
                    hero.getTagBadge(lang),
                    style: styles.cleanSans(context, size: isMobile ? 11 : 12, fontWeight: FontWeight.w600, color: const Color(0xFFE8E4DA)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // 2. Grand Editorial Title (only if populated)
        if (hero.hasTitle) ...[
          Text(
            hero.getTitle(lang),
            style: styles.editorialSerif(context, size: isMobile ? 30 : 48, fontWeight: FontWeight.w700, color: colors.white, height: 1.16),
          ),
          const SizedBox(height: 16),
        ],

        // 3. Sacred Motto in Gujarati (only if populated)
        if (hero.hasMotto) ...[
          Builder(
            builder: (context) {
              String motto = hero.getMotto(lang);
              if (isMobile) {
                motto = motto.replaceAll(' || ', ' ||\n');
              }
              return Text(
                motto,
                style: styles.devotionalMotto(context, size: isMobile ? 19 : 24, color: colors.lightGold),
              );
            },
          ),
          const SizedBox(height: 18),
        ],

        // 4. Description Paragraph (only if populated)
        if (hero.hasDesc) ...[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: (isMobile || !hasImage) ? double.infinity : 640),
            child: Text(
              hero.getDesc(lang),
              style: styles.bodyText(context).copyWith(color: const Color(0xFFDDD8CD), height: 1.68, fontSize: isMobile ? 13.5 : 15),
            ),
          ),
          const SizedBox(height: 32),
        ],

        // 5. Action Buttons Row (only if at least one button is populated)
        if (hasBtn1 || hasBtn2) ...[
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasBtn1)
                      _HeroActionButton(
                        icon: Icons.inventory_2_outlined,
                        label: hero.getCtaPrimaryText(lang),
                        isFilled: true,
                        onTap: () => _navigateToRoute(context, hero.ctaPrimaryRoute),
                      ),
                    if (hasBtn1 && hasBtn2) const SizedBox(height: 12),
                    if (hasBtn2)
                      _HeroActionButton(
                        icon: Icons.info_outline_rounded,
                        label: hero.getCtaSecondaryText(lang),
                        isFilled: false,
                        onTap: () => _navigateToRoute(context, hero.ctaSecondaryRoute),
                      ),
                  ],
                )
              : Wrap(
                  spacing: 14,
                  runSpacing: 12,
                  children: [
                    if (hasBtn1)
                      _HeroActionButton(
                        icon: Icons.inventory_2_outlined,
                        label: hero.getCtaPrimaryText(lang),
                        isFilled: true,
                        onTap: () => _navigateToRoute(context, hero.ctaPrimaryRoute),
                      ),
                    if (hasBtn2)
                      _HeroActionButton(
                        icon: Icons.info_outline_rounded,
                        label: hero.getCtaSecondaryText(lang),
                        isFilled: false,
                        onTap: () => _navigateToRoute(context, hero.ctaSecondaryRoute),
                      ),
                  ],
                ),
          const SizedBox(height: 28),
        ],

        // 6. Bottom Official Archival Badge (only if populated)
        if (hero.hasBottomBadge) ...[
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(shape: BoxShape.circle, color: colors.heritageGold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hero.getBottomBadge(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.cleanSans(context, color: colors.heritageGold.withValues(alpha: 0.9), size: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    final nav = serviceLocator<NavigationManager>();
    switch (route.trim()) {
      case '/archive':
        nav.goToArchive(context);
        break;
      case '/about':
        nav.goToAbout(context);
        break;
      case '/history':
        nav.goToHistory(context);
        break;
      case '/videos':
        nav.goToVideos(context);
        break;
      case '/contact':
        nav.goToContact(context);
        break;
      default:
        if (route.trim().isNotEmpty) {
          context.go(route.trim());
        }
    }
  }
}

// 2. HERITAGE STATS / HIGHLIGHTS STRIP
class _HeritageStatsStrip extends StatelessWidget {
  const _HeritageStatsStrip();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final colors = serviceLocator<MyAppColors>();
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isMobile = screenWidth < 768;
        final lang = Localizations.localeOf(context).languageCode;

        final statsData = AdminDataStore.instance.statsData;
        final activeStats = statsData.activeStats;

        if (activeStats.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, 24, isMobile ? 16 : 32, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 20),
                decoration: BoxDecoration(
                  color: colors.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.getBorderColor(context)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isMobile
                    ? Column(
                        children: [
                          for (int i = 0; i < activeStats.length; i++) ...[
                            _StatItem(title: activeStats[i].getTitle(lang), desc: activeStats[i].getDesc(lang), icon: activeStats[i].iconData),
                            if (i < activeStats.length - 1) Divider(color: colors.getBorderColor(context), height: 24),
                          ],
                        ],
                      )
                    : Row(
                        children: [
                          for (int i = 0; i < activeStats.length; i++) ...[
                            Expanded(
                              child: _StatItem(title: activeStats[i].getTitle(lang), desc: activeStats[i].getDesc(lang), icon: activeStats[i].iconData),
                            ),
                            if (i < activeStats.length - 1)
                              Container(height: 48, width: 1, color: colors.getBorderColor(context), margin: const EdgeInsets.symmetric(horizontal: 16)),
                          ],
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;

  const _StatItem({required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final hasTitle = title.trim().isNotEmpty;
    final hasDesc = desc.trim().isNotEmpty;

    if (!hasTitle && !hasDesc) return const SizedBox.shrink();

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.getAccentColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: colors.getAccentColor(context), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasTitle)
                Text(
                  title,
                  style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                ),
              if (hasTitle && hasDesc) const SizedBox(height: 2),
              if (hasDesc) Text(desc, style: styles.cleanSans(context, size: 11.5, color: colors.getMutedTextColor(context))),
            ],
          ),
        ),
      ],
    );
  }
}

// 3. ABOUT THE MANDAL SECTION
class _AboutMandalSection extends StatelessWidget {
  const _AboutMandalSection();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final styles = serviceLocator<MyAppTextStyles>();
        final colors = serviceLocator<MyAppColors>();
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isMobile = screenWidth < 880;
        final lang = Localizations.localeOf(context).languageCode;
        final store = AdminDataStore.instance;
        final about = store.aboutData;
        final cards = store.aboutCards.where((c) => c.isActive).toList();

        final tag = about.tag(lang);
        final title = about.title(lang);
        final desc = about.desc(lang);
        final aarti = about.aarti(lang);

        if (tag.isEmpty && title.isEmpty && desc.isEmpty && cards.isEmpty && aarti.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, 48, isMobile ? 16 : 32, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tag.isNotEmpty) ...[HeritageBadge(label: tag), const SizedBox(height: 16)],
                  if (title.isNotEmpty || desc.isNotEmpty) ...[
                    if (isMobile) ...[
                      if (title.isNotEmpty) Text(title, style: styles.h1(context)),
                      if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(height: 16),
                      if (desc.isNotEmpty) Text(desc, style: styles.bodyText(context).copyWith(height: 1.65)),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title.isNotEmpty) Expanded(flex: 5, child: Text(title, style: styles.h1(context))),
                          if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(width: 36),
                          if (desc.isNotEmpty)
                            Expanded(
                              flex: title.isNotEmpty ? 6 : 1,
                              child: Text(desc, style: styles.bodyText(context).copyWith(fontSize: 15.5, height: 1.7)),
                            ),
                        ],
                      ),
                    const SizedBox(height: 32),
                  ],

                  // Dynamic Value / About Cards (Image 2)
                  if (cards.isNotEmpty) ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final int crossAxisCount = width < 680
                            ? 1
                            : width < 1020
                            ? 2
                            : (cards.length == 4 ? 2 : (cards.length < 3 ? cards.length : 3));
                        const double spacing = 20;

                        if (crossAxisCount == 1) {
                          return Column(
                            children: [
                              for (int i = 0; i < cards.length; i++) ...[
                                if (i > 0) const SizedBox(height: 16),
                                _ValueCard(title: cards[i].getTitle(lang), desc: cards[i].getDesc(lang), icon: cards[i].iconData),
                              ],
                            ],
                          );
                        }

                        final itemWidth = (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final card in cards)
                              SizedBox(
                                width: itemWidth,
                                child: _ValueCard(title: card.getTitle(lang), desc: card.getDesc(lang), icon: card.iconData),
                              ),
                          ],
                        );
                      },
                    ),
                  ],

                  // Daily Maha Aarti Announcement Banner
                  if (aarti.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.heritageGold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.brightness_high_rounded, color: colors.heritageGold, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              aarti,
                              style: styles.bodyText(context).copyWith(color: colors.getPrimaryTextColor(context), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ValueCard extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;

  const _ValueCard({required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return _InteractiveHoverCard(
      child: CulturalFrameCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: colors.getAccentColor(context).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: colors.getAccentColor(context), size: 22),
            ),
            if (title.isNotEmpty) ...[const SizedBox(height: 18), Text(title, style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700))],
            if (desc.isNotEmpty) ...[const SizedBox(height: 8), Text(desc, style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context), height: 1.55))],
          ],
        ),
      ),
    );
  }
}

// 4. CORE PILLARS OF PRACHIN GARBI
class _PillarsOfGarbiSection extends StatelessWidget {
  const _PillarsOfGarbiSection();

  @override
  Widget build(BuildContext context) {
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
    final lang = isGujarati ? 'gu' : 'en';

    final header = AdminDataStore.instance.homePillarsHeader;
    final tag = header['tag_$lang']?.isNotEmpty == true ? header['tag_$lang']! : (header['tag_en']?.isNotEmpty == true ? header['tag_en']! : '');
    final title = header['title_$lang']?.isNotEmpty == true ? header['title_$lang']! : (header['title_en']?.isNotEmpty == true ? header['title_en']! : '');

    final pillars = AdminDataStore.instance.pillars;

    // Strict zero-dummy fallback: if no pillars and no title/tag, hide entirely
    if (pillars.isEmpty && title.isEmpty && tag.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tag.isNotEmpty) ...[HeritageBadge(label: tag), const SizedBox(height: 14)],
              if (title.isNotEmpty) ...[Text(title, style: styles.h1(context)), const SizedBox(height: 28)],
              if (pillars.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final int crossAxisCount = width < 680
                        ? 1
                        : width < 1020
                        ? 2
                        : (pillars.length == 4 ? 2 : (pillars.length < 3 ? pillars.length : 3));
                    const double spacing = 20;

                    if (crossAxisCount == 1) {
                      return Column(
                        children: [
                          for (int i = 0; i < pillars.length; i++) ...[
                            if (i > 0) const SizedBox(height: 16),
                            _PillarCard(number: pillars[i].number, title: pillars[i].getTitle(lang), desc: pillars[i].getDesc(lang), icon: pillars[i].iconData),
                          ],
                        ],
                      );
                    }

                    final itemWidth = (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final p in pillars)
                          SizedBox(
                            width: itemWidth,
                            child: _PillarCard(number: p.number, title: p.getTitle(lang), desc: p.getDesc(lang), icon: p.iconData),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final String number;
  final String title;
  final String desc;
  final IconData icon;

  const _PillarCard({required this.number, required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return _InteractiveHoverCard(
      child: CulturalFrameCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (number.isNotEmpty) Text(number, style: styles.devotionalMotto(context, size: 24, color: colors.heritageGold)) else const SizedBox.shrink(),
                Icon(icon, size: 22, color: colors.getAccentColor(context)),
              ],
            ),
            if (title.isNotEmpty) ...[const SizedBox(height: 18), Text(title, style: styles.editorialSerif(context, size: 19, fontWeight: FontWeight.w700))],
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(desc, style: styles.bodyText(context).copyWith(color: colors.getSecondaryTextColor(context), fontSize: 13.5, height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}

// 5. VOCALISTS & MUSICIANS BANNER CAROUSEL
class _SingerBannerCarousel extends StatelessWidget {
  const _SingerBannerCarousel();

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';

    final singers = AdminDataStore.instance.homeSingers;
    if (singers.isEmpty) {
      return const SizedBox.shrink();
    }

    final lang = isGujarati ? 'gu' : 'en';
    final header = AdminDataStore.instance.homeSingersHeader;
    final tag = header['tag_$lang']?.isNotEmpty == true ? header['tag_$lang']! : (header['tag_en']?.isNotEmpty == true ? header['tag_en']! : '');
    final title = header['title_$lang']?.isNotEmpty == true ? header['title_$lang']! : (header['title_en']?.isNotEmpty == true ? header['title_en']! : '');
    final desc = header['desc_$lang']?.isNotEmpty == true ? header['desc_$lang']! : (header['desc_en']?.isNotEmpty == true ? header['desc_en']! : '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (tag.isNotEmpty) ...[HeritageBadge(label: tag), const SizedBox(height: 14)],
        if (title.isNotEmpty) ...[Text(title, style: styles.h1(context), textAlign: TextAlign.center), const SizedBox(height: 12)],
        if (desc.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: Text(desc, style: styles.bodyText(context).copyWith(height: 1.6), textAlign: TextAlign.center),
            ),
          ),
          const SizedBox(height: 28),
        ] else if (tag.isNotEmpty || title.isNotEmpty) ...[
          const SizedBox(height: 16),
        ],
        CarouselSlider(
          options: CarouselOptions(
            height: isMobile ? 400 : 340,
            autoPlay: singers.length > 1,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 1200),
            autoPlayCurve: Curves.easeInOutQuart,
            enlargeCenterPage: true,
            viewportFraction: isMobile ? 0.92 : 0.72,
          ),
          items: singers.map((singer) {
            final name = isGujarati && singer.nameGu.isNotEmpty ? singer.nameGu : singer.nameEn;
            final role = isGujarati && singer.roleGu.isNotEmpty ? singer.roleGu : singer.roleEn;
            final desc = isGujarati && singer.descGu.isNotEmpty ? singer.descGu : singer.descEn;

            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: double.infinity,
                  padding: isMobile ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [colors.deepMaroon, colors.heritageMaroon], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.6), width: 2),
                    boxShadow: [BoxShadow(color: colors.heritageGold.withValues(alpha: 0.15), blurRadius: 22, spreadRadius: 2)],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        bottom: -30,
                        child: Opacity(opacity: 0.07, child: Icon(Icons.music_note_rounded, size: 220, color: colors.heritageGold)),
                      ),
                      isMobile
                          ? Column(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22)),
                                      child: singer.imageUrl.startsWith('http')
                                          ? Stack(
                                              fit: StackFit.passthrough,
                                              children: [
                                                Image.asset(
                                                  'assets/images/pavan_putra_logo.png',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                                                ),
                                                CachedNetworkImage(
                                                  imageUrl: singer.imageUrl,
                                                  fit: BoxFit.cover,
                                                  fadeInDuration: const Duration(milliseconds: 300),
                                                  placeholder: (_, _) => const SizedBox.shrink(),
                                                  errorWidget: (_, _, _) => const SizedBox.shrink(),
                                                ),
                                              ],
                                            )
                                          : Image.asset(
                                              singer.imageUrl.isNotEmpty ? singer.imageUrl : 'assets/images/pavan_putra_logo.png',
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                                            ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (role.isNotEmpty) ...[
                                          HeritageBadge(
                                            label: role,
                                            backgroundColor: colors.white.withValues(alpha: 0.08),
                                            textColor: colors.lightGold,
                                            borderColor: colors.heritageGold.withValues(alpha: 0.4),
                                          ),
                                          const SizedBox(height: 12),
                                        ],
                                        Text(
                                          name,
                                          style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700, color: colors.white),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (desc.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            desc,
                                            style: styles.bodyText(context).copyWith(color: const Color(0xFFE2DDD1), fontSize: 12.5, height: 1.45),
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                _buildArtistImage(singer.imageUrl, size: 148, colors: colors),
                                const SizedBox(width: 32),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (role.isNotEmpty) ...[
                                        HeritageBadge(
                                          label: role,
                                          backgroundColor: colors.white.withValues(alpha: 0.08),
                                          textColor: colors.lightGold,
                                          borderColor: colors.heritageGold.withValues(alpha: 0.4),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      Text(
                                        name,
                                        style: styles.editorialSerif(context, size: 30, fontWeight: FontWeight.w700, color: colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (desc.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Text(
                                          desc,
                                          style: styles.bodyText(context).copyWith(color: const Color(0xFFE2DDD1), fontSize: 14, height: 1.55),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildArtistImage(String imageUrl, {required double size, required MyAppColors colors}) {
    final baseAsset = Image.asset(
      'assets/images/pavan_putra_logo.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Image.asset(
        'assets/images/pavan_putra_logo.jpg',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );

    final imageWidget = imageUrl.startsWith('http')
        ? Stack(
            fit: StackFit.passthrough,
            children: [
              baseAsset,
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ],
          )
        : Image.asset(
            imageUrl.isNotEmpty ? imageUrl : 'assets/images/pavan_putra_logo.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => baseAsset,
          );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.heritageGold, width: 2.2),
        boxShadow: [BoxShadow(color: colors.heritageGold.withValues(alpha: 0.3), blurRadius: 16, spreadRadius: 1)],
      ),
      child: ClipOval(child: imageWidget),
    );
  }
}

// 7. ELDERS & DIGNITARIES BLESSINGS
class _EldersBlessingsSection extends StatelessWidget {
  const _EldersBlessingsSection();

  @override
  Widget build(BuildContext context) {
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
    final lang = isGujarati ? 'gu' : 'en';

    final header = AdminDataStore.instance.homeBlessingsHeader;
    final tag = header['tag_$lang']?.isNotEmpty == true ? header['tag_$lang']! : (header['tag_en']?.isNotEmpty == true ? header['tag_en']! : '');
    final title = header['title_$lang']?.isNotEmpty == true ? header['title_$lang']! : (header['title_en']?.isNotEmpty == true ? header['title_en']! : '');

    final blessings = AdminDataStore.instance.blessings;

    // Strict zero dummy fallback
    if (blessings.isEmpty && title.isEmpty && tag.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (tag.isNotEmpty) ...[HeritageBadge(label: tag), const SizedBox(height: 14)],
        if (title.isNotEmpty) ...[Text(title, style: styles.h1(context), textAlign: TextAlign.center), const SizedBox(height: 28)],
        if (blessings.length >= 3)
          CarouselSlider(
            options: CarouselOptions(
              height: isMobile ? 420 : 310,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 1000),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              viewportFraction: isMobile ? 0.85 : 0.45,
            ),
            items: blessings.map((b) {
              final author = b.getAuthor(lang);
              final desig = b.getDesignation(lang);
              final quote = b.getQuote(lang);
              final authorDisplay = desig.isNotEmpty ? '$author ($desig)' : author;
              return Builder(
                builder: (BuildContext context) {
                  return _QuoteCard(quote: quote, author: authorDisplay, imagePath: b.photoUrl);
                },
              );
            }).toList(),
          )
        else if (blessings.length == 1)
          Center(
            child: SizedBox(
              width: isMobile ? screenWidth * 0.9 : 620,
              height: isMobile ? 400 : 310,
              child: _QuoteCard(
                quote: blessings.first.getQuote(lang),
                author: blessings.first.getDesignation(lang).isNotEmpty
                    ? '${blessings.first.getAuthor(lang)} (${blessings.first.getDesignation(lang)})'
                    : blessings.first.getAuthor(lang),
                imagePath: blessings.first.photoUrl,
              ),
            ),
          )
        else if (blessings.length == 2)
          isMobile
              ? Column(
                  children: [
                    for (final b in blessings) ...[
                      SizedBox(
                        width: screenWidth * 0.9,
                        height: 400,
                        child: _QuoteCard(
                          quote: b.getQuote(lang),
                          author: b.getDesignation(lang).isNotEmpty
                              ? '${b.getAuthor(lang)} (${b.getDesignation(lang)})'
                              : b.getAuthor(lang),
                          imagePath: b.photoUrl,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < blessings.length; i++) ...[
                          if (i > 0) const SizedBox(width: 24),
                          Expanded(
                            child: SizedBox(
                              height: 310,
                              child: _QuoteCard(
                                quote: blessings[i].getQuote(lang),
                                author: blessings[i].getDesignation(lang).isNotEmpty
                                    ? '${blessings[i].getAuthor(lang)} (${blessings[i].getDesignation(lang)})'
                                    : blessings[i].getAuthor(lang),
                                imagePath: blessings[i].photoUrl,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
      ],
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final String quote;
  final String author;
  final String? imagePath;

  const _QuoteCard({required this.quote, required this.author, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    Widget imageWidget = Container(
      width: isMobile ? double.infinity : 140,
      height: isMobile ? 160 : double.infinity,
      decoration: BoxDecoration(
        color: colors.getAccentColor(context).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.getAccentColor(context).withValues(alpha: 0.2), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: imagePath != null && imagePath!.isNotEmpty
            ? (imagePath!.startsWith('http')
                  ? Image.network(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                    )
                  : Image.asset(
                      imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                    ))
            : Icon(Icons.person_rounded, size: 60, color: colors.getAccentColor(context).withValues(alpha: 0.3)),
      ),
    );

    Widget quoteWidget = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.format_quote_rounded, color: colors.heritageGold, size: 26),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              quote,
              maxLines: isMobile ? 4 : 5,
              overflow: TextOverflow.ellipsis,
              style: styles.bodyText(context).copyWith(fontStyle: FontStyle.italic, height: 1.5, fontSize: 13.5),
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, width: 40, color: colors.heritageGold.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          Text(
            author,
            style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
          ),
        ],
      ),
    );

    return CulturalFrameCard(
      padding: const EdgeInsets.all(22),
      child: isMobile
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [imageWidget, const SizedBox(height: 16), quoteWidget])
          : Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [imageWidget, const SizedBox(width: 24), quoteWidget]),
    );
  }
}

// 8. YEAR ARCHIVE SHOWCASE
class _YearArchiveSection extends StatelessWidget {
  const _YearArchiveSection();

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeritageBadge(label: context.tr('sec_02_tag')),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('sec_02_title'), style: styles.h1(context)),
                        const SizedBox(height: 8),
                        Text(context.tr('sec_02_desc'), style: styles.bodyText(context)),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    TextButton.icon(
                      onPressed: () => serviceLocator<NavigationManager>().goToArchive(context),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text(
                        context.tr('sec_02_cta'),
                        style: styles.cleanSans(context, color: colors.getAccentColor(context), size: 13, fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),

              // Year Cards Horizontal Scroller
              Builder(
                builder: (context) {
                  final years = AdminDataStore.instance.years.where((y) => y.isPublished).toList();
                  if (years.isEmpty) {
                    return CulturalFrameCard(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      child: Center(
                        child: Text(
                          context.tr('archive_empty'),
                          textAlign: TextAlign.center,
                          style: styles.cleanSans(context, size: 13, color: colors.getSecondaryTextColor(context)),
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 126,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      itemCount: years.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final y = years[index];
                        final year = y.year;
                        return InkWell(
                          onTap: () => serviceLocator<NavigationManager>().goToArchiveYear(context, year: year.toString()),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: isMobile ? 140 : 170,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: colors.getCardBackgroundColor(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.getBorderColor(context)),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$year',
                                  style: styles.editorialSerif(context, size: 28, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        context.tr('sec_02_media_type'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: styles.cleanSans(context, size: 10, fontWeight: FontWeight.w600, color: colors.getMutedTextColor(context)),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_rounded, size: 14, color: colors.heritageGold),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              if (isMobile) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => serviceLocator<NavigationManager>().goToArchive(context),
                  child: Text(
                    context.tr('sec_02_cta'),
                    style: styles.cleanSans(context, color: colors.getAccentColor(context), size: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// 9. YOUTUBE LIVE & VIDEOS SECTION
class _VideosLiveSection extends StatelessWidget {
  const _VideosLiveSection();

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final live = AdminDataStore.instance.liveStreamSettings;
    final isLiveNow = live.isLive;
    final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
    final liveBadgeText = isLiveNow ? (isGujarati ? '● લાઈવ પ્રસારણ શરૂ છે' : '● LIVE NOW') : (isGujarati ? 'આગામી લાઈવ પ્રસારણ' : 'UPCOMING STREAM');
    final liveTitleText = live.title.trim().isNotEmpty ? live.title : context.tr('videos_live_title');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeritageBadge(label: context.tr('sec_videos_tag')),
              const SizedBox(height: 14),
              Text(context.tr('sec_videos_title'), style: styles.h1(context)),
              const SizedBox(height: 24),

              // YouTube Channel Live Banner
              CulturalFrameCard(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                backgroundColor: colors.deepMaroon,
                borderColor: colors.heritageGold.withValues(alpha: 0.4),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: isLiveNow ? const Color(0xFFCC0000) : const Color(0xFFB8860B)),
                                child: Icon(isLiveNow ? Icons.live_tv_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          liveBadgeText,
                                          style: styles.cleanSans(context, color: colors.lightGold, size: 11, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      liveTitleText,
                                      style: styles.editorialSerif(context, color: colors.white, size: isMobile ? 16 : 20, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.heritageMaroon,
                                foregroundColor: colors.white,
                                side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.5)),
                              ),
                              onPressed: () => serviceLocator<NavigationManager>().goToVideos(context),
                              child: Text(
                                context.tr('videos_live_cta'),
                                style: styles.cleanSans(context, size: 12, color: colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: isLiveNow ? const Color(0xFFCC0000) : const Color(0xFFB8860B)),
                            child: Icon(isLiveNow ? Icons.live_tv_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      liveBadgeText,
                                      style: styles.cleanSans(context, color: colors.lightGold, size: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  liveTitleText,
                                  style: styles.editorialSerif(context, color: colors.white, size: isMobile ? 16 : 20, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.heritageMaroon,
                              foregroundColor: colors.white,
                              side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.5)),
                            ),
                            onPressed: () => serviceLocator<NavigationManager>().goToVideos(context),
                            child: Text(
                              context.tr('videos_live_cta'),
                              style: styles.cleanSans(context, size: 12, color: colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 10. BLOG & CULTURAL STORIES PREVIEW
class _BlogSectionPreview extends StatelessWidget {
  const _BlogSectionPreview();

  @override
  Widget build(BuildContext context) {
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final store = AdminDataStore.instance;
        final isGu = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
        final header = store.homeArticlesHeader;
        final rawTag = (isGu ? header['tagGu'] : header['tagEn'])?.trim() ?? '';
        final effectiveTag = rawTag.isNotEmpty ? rawTag : context.tr('sec_blog_tag');

        final rawTitle = (isGu ? header['titleGu'] : header['titleEn'])?.trim() ?? '';
        final effectiveTitle = rawTitle.isNotEmpty ? rawTitle : context.tr('sec_blog_title');

        final publishedBlogs = store.blogs.where((b) => b.isPublished).toList();

        // Strict zero-dummy fallback: if no blogs exist and header was wiped, hide section cleanly
        if (publishedBlogs.isEmpty && rawTag.isEmpty && rawTitle.isEmpty && store.blogs.isEmpty) {
          return const SizedBox.shrink();
        }

        final List<({String title, String snippet, String slug, String category, String content, String date, String readTime})> displayArticles = publishedBlogs.isNotEmpty
            ? publishedBlogs.map((b) => (
                title: b.getTitle(isGu ? 'gu' : 'en'),
                snippet: b.getSnippet(isGu ? 'gu' : 'en'),
                slug: b.slug,
                category: b.category,
                content: b.content,
                date: b.date,
                readTime: b.readTime,
              )).toList()
            : [
                (
                  title: context.tr('blog_1_title'),
                  snippet: context.tr('blog_1_snippet'),
                  slug: 'post-1',
                  category: 'HERITAGE ARTICLE',
                  content: context.tr('blog_1_snippet'),
                  date: 'October 2025',
                  readTime: '5 min read',
                ),
                (
                  title: context.tr('blog_2_title'),
                  snippet: context.tr('blog_2_snippet'),
                  slug: 'post-2',
                  category: 'HERITAGE ARTICLE',
                  content: context.tr('blog_2_snippet'),
                  date: 'September 2025',
                  readTime: '6 min read',
                ),
                (
                  title: context.tr('blog_3_title'),
                  snippet: context.tr('blog_3_snippet'),
                  slug: 'post-3',
                  category: 'HERITAGE ARTICLE',
                  content: context.tr('blog_3_snippet'),
                  date: 'August 2025',
                  readTime: '4 min read',
                ),
              ];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (effectiveTag.isNotEmpty) ...[HeritageBadge(label: effectiveTag), const SizedBox(height: 14)],
                  if (effectiveTitle.isNotEmpty) ...[Text(effectiveTitle, style: styles.h1(context)), const SizedBox(height: 28)],
                  LayoutBuilder(
                    builder: (context, c) {
                      final double itemWidth;
                      if (c.maxWidth < 680) {
                        itemWidth = c.maxWidth;
                      } else if (c.maxWidth < 1050) {
                        itemWidth = (c.maxWidth - 16) / 2;
                      } else {
                        itemWidth = (c.maxWidth - 32) / 3;
                      }

                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final art in displayArticles)
                            SizedBox(
                              width: itemWidth,
                              height: isMobile ? null : 240,
                              child: _ArticleCard(
                                title: art.title,
                                snippet: art.snippet,
                                slug: art.slug,
                                category: art.category,
                                content: art.content,
                                date: art.date,
                                readTime: art.readTime,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String title;
  final String snippet;
  final String slug;
  final String category;
  final String content;
  final String date;
  final String readTime;

  const _ArticleCard({
    required this.title,
    required this.snippet,
    required this.slug,
    this.category = 'HERITAGE ARTICLE',
    this.content = '',
    this.date = '',
    this.readTime = '',
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return _InteractiveHoverCard(
      onTap: () => showArticleDetailModal(
        context,
        title: title,
        category: category,
        content: content.isNotEmpty ? content : snippet,
        snippet: snippet,
        date: date,
        readTime: readTime,
      ),
      child: Container(
        height: isMobile ? null : 240,
        constraints: const BoxConstraints(minHeight: 225),
        child: CulturalFrameCard(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 16, color: colors.getAccentColor(context)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          category.isNotEmpty ? category.toUpperCase() : 'HERITAGE ARTICLE',
                          style: styles.eyebrow(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snippet,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: styles.bodySmall(context).copyWith(
                      color: colors.getSecondaryTextColor(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    context.tr('blog_read_more'),
                    style: styles.cleanSans(
                      context,
                      color: colors.getAccentColor(context),
                      size: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 11. CULTURAL CALL TO ACTION BANNER
class _CulturalCallToActionBanner extends StatelessWidget {
  const _CulturalCallToActionBanner();

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
    final lang = isGujarati ? 'gu' : 'en';

    final ctaData = AdminDataStore.instance.homeCtaData;
    if (ctaData.isEmpty) {
      return const SizedBox.shrink();
    }

    final invocation = ctaData.getInvocation(lang);
    final motto = ctaData.getMotto(lang);
    final btnText = ctaData.getBtnText(lang);

    if (invocation.isEmpty && motto.isEmpty && btnText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, 48, isMobile ? 16 : 32, 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48, vertical: isMobile ? 36 : 48),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colors.heritageMaroon, colors.deepMaroon], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5), width: 1.2),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: Column(
              children: [
                if (invocation.isNotEmpty) ...[
                  Text(
                    invocation,
                    style: styles.devotionalMotto(context, size: isMobile ? 22 : 28, color: colors.lightGold),
                  ),
                  const SizedBox(height: 14),
                ],
                if (motto.isNotEmpty) ...[
                  Text(
                    motto,
                    textAlign: TextAlign.center,
                    style: styles.editorialSerif(context, size: isMobile ? 20 : 26, fontWeight: FontWeight.w600, color: colors.white),
                  ),
                  const SizedBox(height: 24),
                ],
                if (btnText.isNotEmpty)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.white,
                      foregroundColor: colors.getAccentColor(context),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () {
                      final route = ctaData.btnRoute.trim();
                      if (route.contains('archive')) {
                        serviceLocator<NavigationManager>().goToArchive(context);
                      } else if (route.contains('about')) {
                        serviceLocator<NavigationManager>().goToAbout(context);
                      } else {
                        serviceLocator<NavigationManager>().goToContact(context);
                      }
                    },
                    child: Text(
                      btnText,
                      style: styles.cleanSans(context, color: colors.getAccentColor(context), size: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
