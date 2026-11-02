import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/my_app_bloc/my_app_bloc.dart';
import '../../../core/my_app_bloc/my_app_state.dart';
import '../../../core/my_app_colors/my_app_colors.dart';
import '../../../core/my_app_scaffold/my_app_scaffold.dart';
import '../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/heritage_badge.dart';
import '../../../core/widgets/heritage_divider.dart';
import '../../../utils/navigation_manager.dart';
import '../../admin_module/dashboard/data/admin_data_store.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
    AdminDataStore.instance.ensureAboutPageLoaded();
  }

  static Widget _buildEmblemImage(String url, MyAppColors colors) {
    final baseAsset = Image.asset(
      'assets/images/pavan_putra_logo.png',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
    );

    if (url.isEmpty || url.startsWith('assets/')) {
      return Image.asset(url.isEmpty ? 'assets/images/pavan_putra_logo.png' : url, fit: BoxFit.cover, errorBuilder: (_, _, _) => baseAsset);
    }
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        baseAsset,
        CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 300),
          fadeOutDuration: const Duration(milliseconds: 200),
          placeholder: (_, _) => const SizedBox.shrink(),
          errorWidget: (_, _, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 880;

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) => BlocBuilder<MyAppBloc, MyAppState>(
        builder: (context, state) {
          final lang = state.locale.languageCode;
          final isGujarati = lang == 'gu';
          final s = AdminDataStore.instance;
          final about = s.aboutPageData;
          final aboutHome = s.aboutData;
          final activePrinciples = s.aboutPrinciples.where((p) => p.isActive).toList();
          final activeCommittee = s.committeeMembers.where((m) => m.isActive).toList();

          final tag = about.getTagBadge(lang);
          final title = about.getTitle(lang);
          final desc = about.getDesc(lang);
          final aarti = aboutHome.aarti(lang);

          final valuesTag = about.getValuesTag(lang);
          final valuesTitle = about.getValuesTitle(lang);
          final committeeBadge = about.getCommitteeBadge(lang);
          final committeeTitle = about.getCommitteeTitle(lang);
          final committeeDesc = about.getCommitteeDesc(lang);

          return MyAppScaffold(
            onRefresh: () async {
              await AdminDataStore.instance.reloadAboutPage();
            },
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32, vertical: isMobile ? 32 : 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. PAGE HEADER (Pixel-perfect consistency with Home Screen About Section)
                      _SmoothReveal(
                        delay: Duration.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tag.isNotEmpty) ...[HeritageBadge(label: tag), const SizedBox(height: 16)],
                            if (title.isNotEmpty || desc.isNotEmpty) ...[
                              if (isMobile) ...[
                                if (title.isNotEmpty) Text(title, style: styles.h1(context)),
                                if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(height: 16),
                                if (desc.isNotEmpty) Text(desc, style: styles.bodyText(context).copyWith(fontSize: 15, height: 1.65)),
                              ] else
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (title.isNotEmpty) Expanded(flex: 5, child: Text(title, style: styles.h1(context))),
                                    if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(width: 36),
                                    if (desc.isNotEmpty) Expanded(flex: 6, child: Text(desc, style: styles.bodyText(context).copyWith(fontSize: 15.5, height: 1.7))),
                                  ],
                                ),
                              const SizedBox(height: 36),
                            ],
                          ],
                        ),
                      ),

                      // 2. HERITAGE FOUNDATION CARD
                      _SmoothReveal(
                        delay: const Duration(milliseconds: 100),
                        child: _InteractiveHoverCard(
                          child: CulturalFrameCard(
                            padding: EdgeInsets.all(isMobile ? 22 : 36),
                            backgroundColor: colors.deepMaroon,
                            borderColor: colors.heritageGold.withValues(alpha: 0.4),
                            child: isMobile
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: colors.heritageGold, width: 1.5),
                                        ),
                                        child: ClipRRect(borderRadius: BorderRadius.circular(40), child: _buildEmblemImage(about.foundationImageUrl, colors)),
                                      ),
                                      const SizedBox(height: 20),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            about.getFoundationTitle(lang),
                                            textAlign: TextAlign.center,
                                            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700, color: colors.white),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            about.getFoundationDesc(lang),
                                            textAlign: TextAlign.center,
                                            style: styles.bodyText(context).copyWith(color: const Color(0xFFE2DDD1), height: 1.65),
                                          ),
                                          if (about.getFoundationMotto(lang).isNotEmpty) ...[
                                            const SizedBox(height: 20),
                                            Text(about.getFoundationMotto(lang), style: styles.devotionalMotto(context, size: 20, color: colors.lightGold)),
                                          ],
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: colors.heritageGold, width: 1.5),
                                        ),
                                        child: ClipRRect(borderRadius: BorderRadius.circular(40), child: _buildEmblemImage(about.foundationImageUrl, colors)),
                                      ),
                                      const SizedBox(width: 28),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              about.getFoundationTitle(lang),
                                              style: styles.editorialSerif(context, size: 26, fontWeight: FontWeight.w700, color: colors.white),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(about.getFoundationDesc(lang), style: styles.bodyText(context).copyWith(color: const Color(0xFFE2DDD1), height: 1.65)),
                                            if (about.getFoundationMotto(lang).isNotEmpty) ...[
                                              const SizedBox(height: 20),
                                              Text(about.getFoundationMotto(lang), style: styles.devotionalMotto(context, size: 20, color: colors.lightGold)),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      // 3. CORE PRINCIPLES & CULTURAL VALUES (Managed directly from Admin About Page)
                      if (activePrinciples.isNotEmpty) ...[
                        _SmoothReveal(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const HeritageDivider(verticalPadding: 36),
                              if (valuesTag.isNotEmpty) ...[HeritageBadge(label: valuesTag), const SizedBox(height: 14)],
                              Text(valuesTitle.isNotEmpty ? valuesTitle : (isGujarati ? 'મંડળના પાયાના સિદ્ધાંતો' : 'Core Principles of the Mandal'), style: styles.h2(context)),
                              const SizedBox(height: 24),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  final int crossAxisCount = width < 720 ? 1 : 2;
                                  const double spacing = 18;

                                  if (crossAxisCount == 1) {
                                    return Column(
                                      children: [
                                        for (int i = 0; i < activePrinciples.length; i++) ...[
                                          if (i > 0) const SizedBox(height: 14),
                                          _PrincipleCard(
                                            number: activePrinciples[i].number,
                                            title: activePrinciples[i].getTitle(lang),
                                            desc: activePrinciples[i].getDesc(lang),
                                            icon: activePrinciples[i].iconData,
                                          ),
                                        ],
                                      ],
                                    );
                                  }

                                  final itemWidth = (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                                  return Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing,
                                    children: [
                                      for (final p in activePrinciples)
                                        SizedBox(
                                          width: itemWidth,
                                          child: _PrincipleCard(number: p.number, title: p.getTitle(lang), desc: p.getDesc(lang), icon: p.iconData),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 4. DAILY MAHA AARTI ANNOUNCEMENT BANNER (From Admin Section 3)
                      if (aarti.isNotEmpty) ...[
                        _SmoothReveal(
                          delay: const Duration(milliseconds: 260),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 28),
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
                          ),
                        ),
                      ],

                      // 5. EXECUTIVE COMMITTEE & TRUSTEES BOARD
                      if (activeCommittee.isNotEmpty) ...[
                        _SmoothReveal(
                          delay: const Duration(milliseconds: 320),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const HeritageDivider(verticalPadding: 36),
                              if (committeeBadge.isNotEmpty) ...[HeritageBadge(label: committeeBadge), const SizedBox(height: 14)],
                              Text(
                                committeeTitle.isNotEmpty ? committeeTitle : (isGujarati ? 'ટ્રસ્ટી મંડળ અને સમિતિ' : 'Trustees & Organizing Committee'),
                                style: styles.h2(context),
                              ),
                              if (committeeDesc.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(committeeDesc, style: styles.cleanSans(context, size: 14, color: colors.getSecondaryTextColor(context))),
                              ],
                              const SizedBox(height: 24),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final width = constraints.maxWidth;
                                  final int crossAxisCount = width < 600 ? 1 : (width < 960 ? 2 : 4);
                                  const double spacing = 16;

                                  if (crossAxisCount == 1) {
                                    return Column(
                                      children: [
                                        for (int i = 0; i < activeCommittee.length; i++) ...[
                                          if (i > 0) const SizedBox(height: 16),
                                          _CommitteeMemberCard(member: activeCommittee[i], lang: lang, isGujarati: isGujarati),
                                        ],
                                      ],
                                    );
                                  }

                                  final itemWidth = (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

                                  return Wrap(
                                    spacing: spacing,
                                    runSpacing: spacing,
                                    children: [
                                      for (final m in activeCommittee)
                                        SizedBox(
                                          width: itemWidth,
                                          child: _CommitteeMemberCard(member: m, lang: lang, isGujarati: isGujarati),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      // 6. BOTTOM CALLOUT / HISTORICAL ARCHIVE LINK CARD
                      _SmoothReveal(
                        delay: const Duration(milliseconds: 400),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HeritageDivider(verticalPadding: 36),
                            _InteractiveHoverCard(
                              child: CulturalFrameCard(
                                padding: EdgeInsets.all(isMobile ? 20 : 28),
                                child: isMobile
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 44,
                                                height: 44,
                                                decoration: BoxDecoration(color: colors.getAccentColor(context).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                                child: Icon(Icons.history_edu_rounded, color: colors.getAccentColor(context), size: 24),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(about.getCtaTitle(lang), style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700)),
                                                    const SizedBox(height: 4),
                                                    Text(about.getCtaDesc(lang), style: styles.bodySmall(context).copyWith(color: colors.getMutedTextColor(context))),
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
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              onPressed: () {
                                                final route = about.ctaRoute.trim();
                                                if (route.isNotEmpty) {
                                                  serviceLocator<NavigationManager>().go(context, route);
                                                } else {
                                                  serviceLocator<NavigationManager>().goToHistory(context);
                                                }
                                              },
                                              child: Text(
                                                about.getCtaBtnText(lang),
                                                style: styles.cleanSans(context, color: colors.white, size: 13, fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(color: colors.getAccentColor(context).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                            child: Icon(Icons.history_edu_rounded, color: colors.getAccentColor(context), size: 26),
                                          ),
                                          const SizedBox(width: 18),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(about.getCtaTitle(lang), style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700)),
                                                const SizedBox(height: 4),
                                                Text(about.getCtaDesc(lang), style: styles.bodySmall(context).copyWith(color: colors.getMutedTextColor(context))),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          FilledButton(
                                            style: FilledButton.styleFrom(
                                              backgroundColor: colors.heritageMaroon,
                                              foregroundColor: colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            onPressed: () {
                                              final route = about.ctaRoute.trim();
                                              if (route.isNotEmpty) {
                                                serviceLocator<NavigationManager>().go(context, route);
                                              } else {
                                                serviceLocator<NavigationManager>().goToHistory(context);
                                              }
                                            },
                                            child: Text(
                                              about.getCtaBtnText(lang),
                                              style: styles.cleanSans(context, color: colors.white, size: 13, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Dynamic Cultural Principle Card with gold accent badge and micro-hover interaction
class _PrincipleCard extends StatelessWidget {
  final String number;
  final String title;
  final String desc;
  final IconData icon;

  const _PrincipleCard({required this.number, required this.title, this.desc = '', required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return _InteractiveHoverCard(
      child: CulturalFrameCard(
        padding: const EdgeInsets.all(22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colors.getAccentColor(context).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: colors.getAccentColor(context)),
                  if (number.isNotEmpty) ...[const SizedBox(width: 6), Text(number, style: styles.devotionalMotto(context, size: 16, color: colors.getAccentColor(context)))],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700)),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(desc, style: styles.bodyText(context).copyWith(fontSize: 13.5, height: 1.55, color: colors.getSecondaryTextColor(context))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Committee Member Card with authentic emblem fallback, rounded styling, and hover elevation
class _CommitteeMemberCard extends StatelessWidget {
  final AdminCommitteeMember member;
  final String lang;
  final bool isGujarati;

  const _CommitteeMemberCard({required this.member, required this.lang, required this.isGujarati});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final name = isGujarati && member.nameGu.isNotEmpty ? member.nameGu : member.nameEn;
    final desig = isGujarati && member.designationGu.isNotEmpty ? member.designationGu : member.designationEn;

    return _InteractiveHoverCard(
      child: CulturalFrameCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: SizedBox(
                height: 160,
                child: member.photoUrl.isNotEmpty && !member.photoUrl.startsWith('assets/')
                    ? Stack(
                        fit: StackFit.passthrough,
                        children: [
                          Image.asset(
                            'assets/images/pavan_putra_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                          ),
                          CachedNetworkImage(
                            imageUrl: member.photoUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeOutDuration: const Duration(milliseconds: 200),
                            placeholder: (_, _) => const SizedBox.shrink(),
                            errorWidget: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ],
                      )
                    : Image.asset(
                        member.photoUrl.isNotEmpty ? member.photoUrl : 'assets/images/pavan_putra_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desig,
                    style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600, color: colors.heritageGold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (member.phone.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: colors.getSecondaryTextColor(context)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            member.phone,
                            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}

/// Interactive Micro-Hover Lift Effect (Matching Home Screen)
class _InteractiveHoverCard extends StatefulWidget {
  final Widget child;

  const _InteractiveHoverCard({required this.child});

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
    );
  }
}

/// Smooth Staggered Entrance Animation (Matching Home Screen)
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
    _slide = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

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
