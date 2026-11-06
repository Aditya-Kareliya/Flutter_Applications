import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/localization/google_translation_service.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/article_detail_modal.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image/app_cached_image.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Comprehensive CRUD management view for Home Screen:
/// Hero Banners, Emblem Image, Stats Bar, About Section, Pillars, Singers/Musicians, and CTA Banner.
class AdminHomePageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminHomePageView({super.key, required this.store});

  @override
  State<AdminHomePageView> createState() => _AdminHomePageViewState();
}

class _AdminHomePageViewState extends State<AdminHomePageView> {
  // Brand & Global Site Title Controllers
  late final TextEditingController _appTitleEnCtrl;
  late final TextEditingController _appTitleGuCtrl;

  // 10 Hero Elements Controllers
  late final TextEditingController _sacredInvocationEnCtrl;
  late final TextEditingController _sacredInvocationGuCtrl;
  late final TextEditingController _heroTagBadgeEnCtrl;
  late final TextEditingController _heroTagBadgeGuCtrl;
  late final TextEditingController _heroTitleEnCtrl;
  late final TextEditingController _heroTitleGuCtrl;
  late final TextEditingController _heroMottoEnCtrl;
  late final TextEditingController _heroMottoGuCtrl;
  late final TextEditingController _heroDescEnCtrl;
  late final TextEditingController _heroDescGuCtrl;
  late final TextEditingController _heroCtaArchiveEnCtrl;
  late final TextEditingController _heroCtaArchiveGuCtrl;
  late final TextEditingController _heroCtaArchiveRouteCtrl;
  late final TextEditingController _heroCtaAboutEnCtrl;
  late final TextEditingController _heroCtaAboutGuCtrl;
  late final TextEditingController _heroCtaAboutRouteCtrl;
  late final TextEditingController _heroBottomBadgeEnCtrl;
  late final TextEditingController _heroBottomBadgeGuCtrl;

  String _heroImageUrl = 'assets/images/pavan_putra_logo.png';
  String _previewLang = 'en';
  String _statsPreviewLang = 'en';

  // Stats Controllers (Dual Language EN + GU for all 4 metric counters)
  late final TextEditingController _stat1TitleEnCtrl;
  late final TextEditingController _stat1TitleGuCtrl;
  late final TextEditingController _stat1DescEnCtrl;
  late final TextEditingController _stat1DescGuCtrl;

  late final TextEditingController _stat2TitleEnCtrl;
  late final TextEditingController _stat2TitleGuCtrl;
  late final TextEditingController _stat2DescEnCtrl;
  late final TextEditingController _stat2DescGuCtrl;

  late final TextEditingController _stat3TitleEnCtrl;
  late final TextEditingController _stat3TitleGuCtrl;
  late final TextEditingController _stat3DescEnCtrl;
  late final TextEditingController _stat3DescGuCtrl;

  late final TextEditingController _stat4TitleEnCtrl;
  late final TextEditingController _stat4TitleGuCtrl;
  late final TextEditingController _stat4DescEnCtrl;
  late final TextEditingController _stat4DescGuCtrl;

  // About Section Controllers
  late final TextEditingController _sec1TagEnCtrl;
  late final TextEditingController _sec1TagGuCtrl;
  late final TextEditingController _sec1TitleEnCtrl;
  late final TextEditingController _sec1TitleGuCtrl;
  late final TextEditingController _sec1DescEnCtrl;
  late final TextEditingController _sec1DescGuCtrl;

  // Daily Aarti Announcement
  late final TextEditingController _aartiAnnounceCtrl;
  late final TextEditingController _aartiAnnounceGuCtrl;
  String _aboutPreviewLang = 'en';

  // Section 4: Sacred Foundations / Pillars Controllers
  late final TextEditingController _pillarsTagEnCtrl;
  late final TextEditingController _pillarsTagGuCtrl;
  late final TextEditingController _pillarsTitleEnCtrl;
  late final TextEditingController _pillarsTitleGuCtrl;

  // Section 5: Singers Troupe Header Controllers
  late final TextEditingController _singersTagEnCtrl;
  late final TextEditingController _singersTagGuCtrl;
  late final TextEditingController _singersTitleEnCtrl;
  late final TextEditingController _singersTitleGuCtrl;
  late final TextEditingController _singersDescEnCtrl;
  late final TextEditingController _singersDescGuCtrl;

  // Section 6: Elders Blessings Controllers
  late final TextEditingController _blessingsTagEnCtrl;
  late final TextEditingController _blessingsTagGuCtrl;
  late final TextEditingController _blessingsTitleEnCtrl;
  late final TextEditingController _blessingsTitleGuCtrl;

  // Section 7: Cultural Stories & Articles Controllers
  late final TextEditingController _articlesTagEnCtrl;
  late final TextEditingController _articlesTagGuCtrl;
  late final TextEditingController _articlesTitleEnCtrl;
  late final TextEditingController _articlesTitleGuCtrl;
  String _articlesPreviewLang = 'en';

  // Section 8: Call To Action Banner Controllers
  late final TextEditingController _ctaInvocationEnCtrl;
  late final TextEditingController _ctaInvocationGuCtrl;
  late final TextEditingController _ctaMottoEnCtrl;
  late final TextEditingController _ctaMottoGuCtrl;
  late final TextEditingController _ctaBtnTextEnCtrl;
  late final TextEditingController _ctaBtnTextGuCtrl;
  late final TextEditingController _ctaBtnRouteCtrl;
  String _selectedPreviewLang = 'en';

  @override
  void initState() {
    super.initState();
    final store = widget.store;
    final s = store.settings;
    _appTitleEnCtrl = TextEditingController(text: store.getTextOverride('en', 'app_title') ?? s.mandalNameEn);
    _appTitleGuCtrl = TextEditingController(text: store.getTextOverride('gu', 'app_title') ?? s.mandalNameGu);

    final hero = store.heroData;

    _sacredInvocationEnCtrl = TextEditingController(text: hero.sacredInvocationEn);
    _sacredInvocationGuCtrl = TextEditingController(text: hero.sacredInvocationGu);

    _heroTagBadgeEnCtrl = TextEditingController(text: hero.tagBadgeEn);
    _heroTagBadgeGuCtrl = TextEditingController(text: hero.tagBadgeGu);

    _heroTitleEnCtrl = TextEditingController(text: hero.titleEn);
    _heroTitleGuCtrl = TextEditingController(text: hero.titleGu);

    _heroMottoEnCtrl = TextEditingController(text: hero.mottoEn);
    _heroMottoGuCtrl = TextEditingController(text: hero.mottoGu);

    _heroDescEnCtrl = TextEditingController(text: hero.descEn);
    _heroDescGuCtrl = TextEditingController(text: hero.descGu);

    _heroCtaArchiveEnCtrl = TextEditingController(text: hero.ctaPrimaryTextEn);
    _heroCtaArchiveGuCtrl = TextEditingController(text: hero.ctaPrimaryTextGu);
    _heroCtaArchiveRouteCtrl = TextEditingController(text: hero.ctaPrimaryRoute);

    _heroCtaAboutEnCtrl = TextEditingController(text: hero.ctaSecondaryTextEn);
    _heroCtaAboutGuCtrl = TextEditingController(text: hero.ctaSecondaryTextGu);
    _heroCtaAboutRouteCtrl = TextEditingController(text: hero.ctaSecondaryRoute);

    _heroBottomBadgeEnCtrl = TextEditingController(text: hero.bottomBadgeEn);
    _heroBottomBadgeGuCtrl = TextEditingController(text: hero.bottomBadgeGu);

    _heroImageUrl = hero.imageUrl.isNotEmpty ? hero.imageUrl : 'assets/images/pavan_putra_logo.png';

    final stats = store.statsData;
    _stat1TitleEnCtrl = TextEditingController(text: stats.stat1.titleEn);
    _stat1TitleGuCtrl = TextEditingController(text: stats.stat1.titleGu);
    _stat1DescEnCtrl = TextEditingController(text: stats.stat1.descEn);
    _stat1DescGuCtrl = TextEditingController(text: stats.stat1.descGu);

    _stat2TitleEnCtrl = TextEditingController(text: stats.stat2.titleEn);
    _stat2TitleGuCtrl = TextEditingController(text: stats.stat2.titleGu);
    _stat2DescEnCtrl = TextEditingController(text: stats.stat2.descEn);
    _stat2DescGuCtrl = TextEditingController(text: stats.stat2.descGu);

    _stat3TitleEnCtrl = TextEditingController(text: stats.stat3.titleEn);
    _stat3TitleGuCtrl = TextEditingController(text: stats.stat3.titleGu);
    _stat3DescEnCtrl = TextEditingController(text: stats.stat3.descEn);
    _stat3DescGuCtrl = TextEditingController(text: stats.stat3.descGu);

    _stat4TitleEnCtrl = TextEditingController(text: stats.stat4.titleEn);
    _stat4TitleGuCtrl = TextEditingController(text: stats.stat4.titleGu);
    _stat4DescEnCtrl = TextEditingController(text: stats.stat4.descEn);
    _stat4DescGuCtrl = TextEditingController(text: stats.stat4.descGu);

    final about = store.aboutData;
    _sec1TagEnCtrl = TextEditingController(text: about.tagEn);
    _sec1TagGuCtrl = TextEditingController(text: about.tagGu);
    _sec1TitleEnCtrl = TextEditingController(text: about.titleEn);
    _sec1TitleGuCtrl = TextEditingController(text: about.titleGu);
    _sec1DescEnCtrl = TextEditingController(text: about.descEn);
    _sec1DescGuCtrl = TextEditingController(text: about.descGu);
    _aartiAnnounceCtrl = TextEditingController(text: about.aartiEn);
    _aartiAnnounceGuCtrl = TextEditingController(text: about.aartiGu);

    final pillarsHeader = store.homePillarsHeader;
    _pillarsTagEnCtrl = TextEditingController(text: pillarsHeader['tagEn']);
    _pillarsTagGuCtrl = TextEditingController(text: pillarsHeader['tagGu']);
    _pillarsTitleEnCtrl = TextEditingController(text: pillarsHeader['titleEn']);
    _pillarsTitleGuCtrl = TextEditingController(text: pillarsHeader['titleGu']);

    final singersHeader = store.homeSingersHeader;
    _singersTagEnCtrl = TextEditingController(text: singersHeader['tagEn']);
    _singersTagGuCtrl = TextEditingController(text: singersHeader['tagGu']);
    _singersTitleEnCtrl = TextEditingController(text: singersHeader['titleEn']);
    _singersTitleGuCtrl = TextEditingController(text: singersHeader['titleGu']);
    _singersDescEnCtrl = TextEditingController(text: singersHeader['descEn']);
    _singersDescGuCtrl = TextEditingController(text: singersHeader['descGu']);

    final blessingsHeader = store.homeBlessingsHeader;
    _blessingsTagEnCtrl = TextEditingController(text: blessingsHeader['tagEn']);
    _blessingsTagGuCtrl = TextEditingController(text: blessingsHeader['tagGu']);
    _blessingsTitleEnCtrl = TextEditingController(text: blessingsHeader['titleEn']);
    _blessingsTitleGuCtrl = TextEditingController(text: blessingsHeader['titleGu']);

    final articlesHeader = store.homeArticlesHeader;
    _articlesTagEnCtrl = TextEditingController(text: articlesHeader['tagEn']);
    _articlesTagGuCtrl = TextEditingController(text: articlesHeader['tagGu']);
    _articlesTitleEnCtrl = TextEditingController(text: articlesHeader['titleEn']);
    _articlesTitleGuCtrl = TextEditingController(text: articlesHeader['titleGu']);

    final ctaData = store.homeCtaData;
    _ctaInvocationEnCtrl = TextEditingController(text: ctaData.invocationEn);
    _ctaInvocationGuCtrl = TextEditingController(text: ctaData.invocationGu);
    _ctaMottoEnCtrl = TextEditingController(text: ctaData.mottoEn);
    _ctaMottoGuCtrl = TextEditingController(text: ctaData.mottoGu);
    _ctaBtnTextEnCtrl = TextEditingController(text: ctaData.btnTextEn);
    _ctaBtnTextGuCtrl = TextEditingController(text: ctaData.btnTextGu);
    _ctaBtnRouteCtrl = TextEditingController(text: ctaData.btnRoute);
  }

  @override
  void dispose() {
    _appTitleEnCtrl.dispose();
    _appTitleGuCtrl.dispose();
    _sacredInvocationEnCtrl.dispose();
    _sacredInvocationGuCtrl.dispose();
    _heroTagBadgeEnCtrl.dispose();
    _heroTagBadgeGuCtrl.dispose();
    _heroTitleEnCtrl.dispose();
    _heroTitleGuCtrl.dispose();
    _heroMottoEnCtrl.dispose();
    _heroMottoGuCtrl.dispose();
    _heroDescEnCtrl.dispose();
    _heroDescGuCtrl.dispose();
    _heroCtaArchiveEnCtrl.dispose();
    _heroCtaArchiveGuCtrl.dispose();
    _heroCtaArchiveRouteCtrl.dispose();
    _heroCtaAboutEnCtrl.dispose();
    _heroCtaAboutGuCtrl.dispose();
    _heroCtaAboutRouteCtrl.dispose();
    _heroBottomBadgeEnCtrl.dispose();
    _heroBottomBadgeGuCtrl.dispose();

    _stat1TitleEnCtrl.dispose();
    _stat1TitleGuCtrl.dispose();
    _stat1DescEnCtrl.dispose();
    _stat1DescGuCtrl.dispose();

    _stat2TitleEnCtrl.dispose();
    _stat2TitleGuCtrl.dispose();
    _stat2DescEnCtrl.dispose();
    _stat2DescGuCtrl.dispose();

    _stat3TitleEnCtrl.dispose();
    _stat3TitleGuCtrl.dispose();
    _stat3DescEnCtrl.dispose();
    _stat3DescGuCtrl.dispose();

    _stat4TitleEnCtrl.dispose();
    _stat4TitleGuCtrl.dispose();
    _stat4DescEnCtrl.dispose();
    _stat4DescGuCtrl.dispose();

    _sec1TagEnCtrl.dispose();
    _sec1TagGuCtrl.dispose();
    _sec1TitleEnCtrl.dispose();
    _sec1TitleGuCtrl.dispose();
    _sec1DescEnCtrl.dispose();
    _sec1DescGuCtrl.dispose();

    _aartiAnnounceCtrl.dispose();
    _aartiAnnounceGuCtrl.dispose();

    _pillarsTagEnCtrl.dispose();
    _pillarsTagGuCtrl.dispose();
    _pillarsTitleEnCtrl.dispose();
    _pillarsTitleGuCtrl.dispose();

    _singersTagEnCtrl.dispose();
    _singersTagGuCtrl.dispose();
    _singersTitleEnCtrl.dispose();
    _singersTitleGuCtrl.dispose();
    _singersDescEnCtrl.dispose();
    _singersDescGuCtrl.dispose();

    _blessingsTagEnCtrl.dispose();
    _blessingsTagGuCtrl.dispose();
    _blessingsTitleEnCtrl.dispose();
    _blessingsTitleGuCtrl.dispose();

    _articlesTagEnCtrl.dispose();
    _articlesTagGuCtrl.dispose();
    _articlesTitleEnCtrl.dispose();
    _articlesTitleGuCtrl.dispose();

    _ctaInvocationEnCtrl.dispose();
    _ctaInvocationGuCtrl.dispose();
    _ctaMottoEnCtrl.dispose();
    _ctaMottoGuCtrl.dispose();
    _ctaBtnTextEnCtrl.dispose();
    _ctaBtnTextGuCtrl.dispose();
    _ctaBtnRouteCtrl.dispose();

    super.dispose();
  }

  Future<void> _saveHeroChanges() async {
    // Auto translate if Gujarati is empty but English is provided
    String sacredGu = _sacredInvocationGuCtrl.text.trim();
    if (sacredGu.isEmpty && _sacredInvocationEnCtrl.text.trim().isNotEmpty) {
      try {
        sacredGu = await GoogleTranslationService.instance.translateToGujarati(_sacredInvocationEnCtrl.text.trim());
        _sacredInvocationGuCtrl.text = sacredGu;
      } catch (_) {}
    }
    String tagGu = _heroTagBadgeGuCtrl.text.trim();
    if (tagGu.isEmpty && _heroTagBadgeEnCtrl.text.trim().isNotEmpty) {
      try {
        tagGu = await GoogleTranslationService.instance.translateToGujarati(_heroTagBadgeEnCtrl.text.trim());
        _heroTagBadgeGuCtrl.text = tagGu;
      } catch (_) {}
    }
    String titleGu = _heroTitleGuCtrl.text.trim();
    if (titleGu.isEmpty && _heroTitleEnCtrl.text.trim().isNotEmpty) {
      try {
        titleGu = await GoogleTranslationService.instance.translateToGujarati(_heroTitleEnCtrl.text.trim());
        _heroTitleGuCtrl.text = titleGu;
      } catch (_) {}
    }
    String mottoGu = _heroMottoGuCtrl.text.trim();
    if (mottoGu.isEmpty && _heroMottoEnCtrl.text.trim().isNotEmpty) {
      try {
        mottoGu = await GoogleTranslationService.instance.translateToGujarati(_heroMottoEnCtrl.text.trim());
        _heroMottoGuCtrl.text = mottoGu;
      } catch (_) {}
    }
    String descGu = _heroDescGuCtrl.text.trim();
    if (descGu.isEmpty && _heroDescEnCtrl.text.trim().isNotEmpty) {
      try {
        descGu = await GoogleTranslationService.instance.translateToGujarati(_heroDescEnCtrl.text.trim());
        _heroDescGuCtrl.text = descGu;
      } catch (_) {}
    }
    String ctaPriGu = _heroCtaArchiveGuCtrl.text.trim();
    if (ctaPriGu.isEmpty && _heroCtaArchiveEnCtrl.text.trim().isNotEmpty) {
      try {
        ctaPriGu = await GoogleTranslationService.instance.translateToGujarati(_heroCtaArchiveEnCtrl.text.trim());
        _heroCtaArchiveGuCtrl.text = ctaPriGu;
      } catch (_) {}
    }
    String ctaSecGu = _heroCtaAboutGuCtrl.text.trim();
    if (ctaSecGu.isEmpty && _heroCtaAboutEnCtrl.text.trim().isNotEmpty) {
      try {
        ctaSecGu = await GoogleTranslationService.instance.translateToGujarati(_heroCtaAboutEnCtrl.text.trim());
        _heroCtaAboutGuCtrl.text = ctaSecGu;
      } catch (_) {}
    }
    String bottomGu = _heroBottomBadgeGuCtrl.text.trim();
    if (bottomGu.isEmpty && _heroBottomBadgeEnCtrl.text.trim().isNotEmpty) {
      try {
        bottomGu = await GoogleTranslationService.instance.translateToGujarati(_heroBottomBadgeEnCtrl.text.trim());
        _heroBottomBadgeGuCtrl.text = bottomGu;
      } catch (_) {}
    }

    String appTitleGu = _appTitleGuCtrl.text.trim();
    if (appTitleGu.isEmpty && _appTitleEnCtrl.text.trim().isNotEmpty) {
      try {
        appTitleGu = await GoogleTranslationService.instance.translateToGujarati(_appTitleEnCtrl.text.trim());
        _appTitleGuCtrl.text = appTitleGu;
      } catch (_) {}
    }
    final newTitleEn = _appTitleEnCtrl.text.trim();
    if (newTitleEn.isNotEmpty || appTitleGu.isNotEmpty) {
      widget.store.updateSiteContentField('app_title', valueEn: newTitleEn, valueGu: appTitleGu);
      final curSettings = widget.store.settings;
      widget.store.updateSettings(curSettings.copyWith(
        mandalNameEn: newTitleEn.isNotEmpty ? newTitleEn : curSettings.mandalNameEn,
        mandalNameGu: appTitleGu.isNotEmpty ? appTitleGu : curSettings.mandalNameGu,
      ));
    }

    final hero = AdminHeroData(
      sacredInvocationEn: _sacredInvocationEnCtrl.text.trim(),
      sacredInvocationGu: sacredGu,
      tagBadgeEn: _heroTagBadgeEnCtrl.text.trim(),
      tagBadgeGu: tagGu,
      titleEn: _heroTitleEnCtrl.text.trim(),
      titleGu: titleGu,
      mottoEn: _heroMottoEnCtrl.text.trim(),
      mottoGu: mottoGu,
      descEn: _heroDescEnCtrl.text.trim(),
      descGu: descGu,
      ctaPrimaryTextEn: _heroCtaArchiveEnCtrl.text.trim(),
      ctaPrimaryTextGu: ctaPriGu,
      ctaPrimaryRoute: _heroCtaArchiveRouteCtrl.text.trim().isEmpty ? '/archive' : _heroCtaArchiveRouteCtrl.text.trim(),
      ctaSecondaryTextEn: _heroCtaAboutEnCtrl.text.trim(),
      ctaSecondaryTextGu: ctaSecGu,
      ctaSecondaryRoute: _heroCtaAboutRouteCtrl.text.trim().isEmpty ? '/about' : _heroCtaAboutRouteCtrl.text.trim(),
      bottomBadgeEn: _heroBottomBadgeEnCtrl.text.trim(),
      bottomBadgeGu: bottomGu,
      imageUrl: _heroImageUrl.trim(),
    );

    await widget.store.saveHeroSection(hero);

    if (mounted) {
      setState(() {});
      MyAppToastMessage.success(context, title: 'Hero Section Saved', description: 'All 10 hero elements saved and published to the live website.');
    }
  }

  void _confirmClearAllHero() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Hero Fields?'),
        content: const Text(
          'This will empty all 10 fields and remove the emblem graphic.\n'
          'Any cleared field is completely hidden from the live website.',
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear All',
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _sacredInvocationEnCtrl.clear();
                _sacredInvocationGuCtrl.clear();
                _heroTagBadgeEnCtrl.clear();
                _heroTagBadgeGuCtrl.clear();
                _heroTitleEnCtrl.clear();
                _heroTitleGuCtrl.clear();
                _heroMottoEnCtrl.clear();
                _heroMottoGuCtrl.clear();
                _heroDescEnCtrl.clear();
                _heroDescGuCtrl.clear();
                _heroCtaArchiveEnCtrl.clear();
                _heroCtaArchiveGuCtrl.clear();
                _heroCtaArchiveRouteCtrl.text = '/archive';
                _heroCtaAboutEnCtrl.clear();
                _heroCtaAboutGuCtrl.clear();
                _heroCtaAboutRouteCtrl.text = '/about';
                _heroBottomBadgeEnCtrl.clear();
                _heroBottomBadgeGuCtrl.clear();
                _heroImageUrl = '';
              });
              _saveHeroChanges();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveStatsChanges() async {
    final trans = GoogleTranslationService.instance;

    String s1TitleGu = _stat1TitleGuCtrl.text.trim();
    if (s1TitleGu.isEmpty && _stat1TitleEnCtrl.text.trim().isNotEmpty) {
      try {
        s1TitleGu = await trans.translateToGujarati(_stat1TitleEnCtrl.text.trim());
        _stat1TitleGuCtrl.text = s1TitleGu;
      } catch (_) {}
    }
    String s1DescGu = _stat1DescGuCtrl.text.trim();
    if (s1DescGu.isEmpty && _stat1DescEnCtrl.text.trim().isNotEmpty) {
      try {
        s1DescGu = await trans.translateToGujarati(_stat1DescEnCtrl.text.trim());
        _stat1DescGuCtrl.text = s1DescGu;
      } catch (_) {}
    }

    String s2TitleGu = _stat2TitleGuCtrl.text.trim();
    if (s2TitleGu.isEmpty && _stat2TitleEnCtrl.text.trim().isNotEmpty) {
      try {
        s2TitleGu = await trans.translateToGujarati(_stat2TitleEnCtrl.text.trim());
        _stat2TitleGuCtrl.text = s2TitleGu;
      } catch (_) {}
    }
    String s2DescGu = _stat2DescGuCtrl.text.trim();
    if (s2DescGu.isEmpty && _stat2DescEnCtrl.text.trim().isNotEmpty) {
      try {
        s2DescGu = await trans.translateToGujarati(_stat2DescEnCtrl.text.trim());
        _stat2DescGuCtrl.text = s2DescGu;
      } catch (_) {}
    }

    String s3TitleGu = _stat3TitleGuCtrl.text.trim();
    if (s3TitleGu.isEmpty && _stat3TitleEnCtrl.text.trim().isNotEmpty) {
      try {
        s3TitleGu = await trans.translateToGujarati(_stat3TitleEnCtrl.text.trim());
        _stat3TitleGuCtrl.text = s3TitleGu;
      } catch (_) {}
    }
    String s3DescGu = _stat3DescGuCtrl.text.trim();
    if (s3DescGu.isEmpty && _stat3DescEnCtrl.text.trim().isNotEmpty) {
      try {
        s3DescGu = await trans.translateToGujarati(_stat3DescEnCtrl.text.trim());
        _stat3DescGuCtrl.text = s3DescGu;
      } catch (_) {}
    }

    String s4TitleGu = _stat4TitleGuCtrl.text.trim();
    if (s4TitleGu.isEmpty && _stat4TitleEnCtrl.text.trim().isNotEmpty) {
      try {
        s4TitleGu = await trans.translateToGujarati(_stat4TitleEnCtrl.text.trim());
        _stat4TitleGuCtrl.text = s4TitleGu;
      } catch (_) {}
    }
    String s4DescGu = _stat4DescGuCtrl.text.trim();
    if (s4DescGu.isEmpty && _stat4DescEnCtrl.text.trim().isNotEmpty) {
      try {
        s4DescGu = await trans.translateToGujarati(_stat4DescEnCtrl.text.trim());
        _stat4DescGuCtrl.text = s4DescGu;
      } catch (_) {}
    }

    final stats = AdminStatsData(
      stat1: AdminHighlightStat(
        titleEn: _stat1TitleEnCtrl.text.trim(),
        titleGu: s1TitleGu,
        descEn: _stat1DescEnCtrl.text.trim(),
        descGu: s1DescGu,
        iconKey: 'book',
      ),
      stat2: AdminHighlightStat(
        titleEn: _stat2TitleEnCtrl.text.trim(),
        titleGu: s2TitleGu,
        descEn: _stat2DescEnCtrl.text.trim(),
        descGu: s2DescGu,
        iconKey: 'music',
      ),
      stat3: AdminHighlightStat(
        titleEn: _stat3TitleEnCtrl.text.trim(),
        titleGu: s3TitleGu,
        descEn: _stat3DescEnCtrl.text.trim(),
        descGu: s3DescGu,
        iconKey: 'flame',
      ),
      stat4: AdminHighlightStat(
        titleEn: _stat4TitleEnCtrl.text.trim(),
        titleGu: s4TitleGu,
        descEn: _stat4DescEnCtrl.text.trim(),
        descGu: s4DescGu,
        iconKey: 'history',
      ),
    );

    await widget.store.saveStatsSection(stats);
    if (!mounted) return;
    setState(() {});
    MyAppToastMessage.success(
      context,
      title: 'Quick Stats Saved',
      description: 'The 4 metric highlights counters have been saved to Firebase.',
    );
  }

  void _confirmClearAllStats() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Stats Counters?'),
        content: const Text(
          'This will clear all 4 metric counters in both English and Gujarati. The highlights bar will be completely hidden on the website until you re-populate it.',
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear All',
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() {
                _stat1TitleEnCtrl.clear();
                _stat1TitleGuCtrl.clear();
                _stat1DescEnCtrl.clear();
                _stat1DescGuCtrl.clear();

                _stat2TitleEnCtrl.clear();
                _stat2TitleGuCtrl.clear();
                _stat2DescEnCtrl.clear();
                _stat2DescGuCtrl.clear();

                _stat3TitleEnCtrl.clear();
                _stat3TitleGuCtrl.clear();
                _stat3DescEnCtrl.clear();
                _stat3DescGuCtrl.clear();

                _stat4TitleEnCtrl.clear();
                _stat4TitleGuCtrl.clear();
                _stat4DescEnCtrl.clear();
                _stat4DescGuCtrl.clear();
              });
              await widget.store.clearAllStats();
              if (mounted) {
                MyAppToastMessage.info(
                  context,
                  title: 'All Stats Cleared',
                  description: 'All 4 metric counters have been cleared and hidden from the website.',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveAboutChanges() async {
    final s = widget.store;
    var tagGu = _sec1TagGuCtrl.text.trim();
    var titleGu = _sec1TitleGuCtrl.text.trim();
    var descGu = _sec1DescGuCtrl.text.trim();
    var aartiGu = _aartiAnnounceGuCtrl.text.trim();

    // Auto translate if Gujarati is empty but English is provided
    if (tagGu.isEmpty && _sec1TagEnCtrl.text.trim().isNotEmpty) {
      try {
        tagGu = await GoogleTranslationService.instance.translateToGujarati(_sec1TagEnCtrl.text.trim());
        _sec1TagGuCtrl.text = tagGu;
      } catch (_) {}
    }
    if (titleGu.isEmpty && _sec1TitleEnCtrl.text.trim().isNotEmpty) {
      try {
        titleGu = await GoogleTranslationService.instance.translateToGujarati(_sec1TitleEnCtrl.text.trim());
        _sec1TitleGuCtrl.text = titleGu;
      } catch (_) {}
    }
    if (descGu.isEmpty && _sec1DescEnCtrl.text.trim().isNotEmpty) {
      try {
        descGu = await GoogleTranslationService.instance.translateToGujarati(_sec1DescEnCtrl.text.trim());
        _sec1DescGuCtrl.text = descGu;
      } catch (_) {}
    }
    if (aartiGu.isEmpty && _aartiAnnounceCtrl.text.trim().isNotEmpty) {
      try {
        aartiGu = await GoogleTranslationService.instance.translateToGujarati(_aartiAnnounceCtrl.text.trim());
        _aartiAnnounceGuCtrl.text = aartiGu;
      } catch (_) {}
    }

    await s.saveAboutSection(
      tagEn: _sec1TagEnCtrl.text.trim(),
      tagGu: tagGu,
      titleEn: _sec1TitleEnCtrl.text.trim(),
      titleGu: titleGu,
      descEn: _sec1DescEnCtrl.text.trim(),
      descGu: descGu,
      aartiEn: _aartiAnnounceCtrl.text.trim(),
      aartiGu: aartiGu,
    );

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'About Section Saved',
        description: 'About Mandal details and announcement saved to Firebase.',
      );
      setState(() {});
    }
  }

  void _clearAboutFields() {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
        ),
        title: Text('Clear About Section?', style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700)),
        content: Text(
          'This will clear all headline, story paragraph, eyebrow badge, and announcement fields. Any empty fields will be removed from the public website.',
          style: styles.bodyText(context),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear',
            onPressed: () {
              setState(() {
                _sec1TagEnCtrl.clear();
                _sec1TagGuCtrl.clear();
                _sec1TitleEnCtrl.clear();
                _sec1TitleGuCtrl.clear();
                _sec1DescEnCtrl.clear();
                _sec1DescGuCtrl.clear();
                _aartiAnnounceCtrl.clear();
                _aartiAnnounceGuCtrl.clear();
              });
              widget.store.clearAboutSection();
              Navigator.pop(ctx);
              MyAppToastMessage.success(
                context,
                title: 'Section Cleared',
                description: 'About section fields cleared in Firebase and website.',
              );
            },
          ),
        ],
      ),
    );
  }

  void _openAboutCardDialog([AdminAboutCard? card]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final titleEnCtrl = TextEditingController(text: card?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: card?.titleGu ?? '');
    final descEnCtrl = TextEditingController(text: card?.descEn ?? '');
    final descGuCtrl = TextEditingController(text: card?.descGu ?? '');
    String selectedIcon = card?.iconKey ?? 'shield';
    int order = card?.order ?? widget.store.aboutCards.length;

    final icons = [
      {'key': 'shield', 'label': 'Shield', 'icon': Icons.shield_outlined},
      {'key': 'music', 'label': 'Music', 'icon': Icons.audiotrack_rounded},
      {'key': 'reverence', 'label': 'Sun / Sacred', 'icon': Icons.brightness_high_rounded},
      {'key': 'flame', 'label': 'Flame', 'icon': Icons.local_fire_department_rounded},
      {'key': 'flower', 'label': 'Lotus / Spa', 'icon': Icons.spa_rounded},
      {'key': 'book', 'label': 'Scripture', 'icon': Icons.auto_stories_rounded},
      {'key': 'history', 'label': 'History', 'icon': Icons.history_rounded},
    ];

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Text(
            card == null ? 'Add Value / Feature Card' : 'Edit Value / Feature Card',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card Icon', style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((item) {
                      final isSelected = selectedIcon == item['key'];
                      return InkWell(
                        onTap: () => setDlgState(() => selectedIcon = item['key'] as String),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? colors.heritageMaroon : colors.getBackgroundColor(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? colors.heritageGold : colors.getBorderColor(context),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 18,
                                color: isSelected ? colors.white : colors.getAccentColor(context),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['label'] as String,
                                style: styles.bodySmall(context).copyWith(
                                  color: isSelected ? colors.white : colors.getPrimaryTextColor(context),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    targetLanguageController: titleGuCtrl,
                    labelText: 'Card Title (English)',
                    hintText: 'e.g. Pure Cultural Sanity',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Card Title (Gujarati)',
                    hintText: 'e.g. સાંસ્કૃતિક શુદ્ધતા',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descEnCtrl,
                    targetLanguageController: descGuCtrl,
                    labelText: 'Card Description (English)',
                    hintText: 'e.g. Strictly traditional Raas, Be-Taali, Tran-Taali performed in reverence.',
                    minLines: 2,
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descGuCtrl,
                    labelText: 'Card Description (Gujarati)',
                    minLines: 2,
                    showClearIcon: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(
              onPressed: () => Navigator.pop(ctx),
              label: 'Cancel',
            ),
            MyAppFillButton(
              label: card == null ? 'Add Card' : 'Update Card',
              onPressed: () {
                final tEn = titleEnCtrl.text.trim();
                final tGu = titleGuCtrl.text.trim();
                final dEn = descEnCtrl.text.trim();
                final dGu = descGuCtrl.text.trim();

                if (tEn.isEmpty && tGu.isEmpty && dEn.isEmpty && dGu.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Content Required', description: 'Please provide at least a title or description for the card.');
                  return;
                }

                if (card == null) {
                  widget.store.addAboutCard(
                    AdminAboutCard(
                      id: 'card-${DateTime.now().millisecondsSinceEpoch}',
                      titleEn: tEn,
                      titleGu: tGu,
                      descEn: dEn,
                      descGu: dGu,
                      iconKey: selectedIcon,
                      order: order,
                    ),
                  );
                  MyAppToastMessage.success(context, title: 'Card Added', description: 'New value card created in Firebase.');
                } else {
                  widget.store.updateAboutCard(
                    card.copyWith(
                      titleEn: tEn,
                      titleGu: tGu,
                      descEn: dEn,
                      descGu: dGu,
                      iconKey: selectedIcon,
                      order: order,
                    ),
                  );
                  MyAppToastMessage.success(context, title: 'Card Updated', description: 'Card updated in Firebase.');
                }
                Navigator.pop(ctx);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAboutCard(AdminAboutCard card) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
        ),
        title: Text('Delete Card?', style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to delete "${card.titleEn.isNotEmpty ? card.titleEn : (card.titleGu.isNotEmpty ? card.titleGu : 'this card')}"? It will be permanently removed from the website and Firebase.',
          style: styles.bodyText(context),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () {
              widget.store.deleteAboutCard(card.id);
              Navigator.pop(ctx);
              MyAppToastMessage.success(context, title: 'Card Deleted', description: 'Value card removed from Firebase.');
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _openSingerDialog([AdminHomeSinger? singer]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final nameEnCtrl = TextEditingController(text: singer?.nameEn ?? '');
    final nameGuCtrl = TextEditingController(text: singer?.nameGu ?? '');
    final roleEnCtrl = TextEditingController(text: singer?.roleEn ?? '');
    final roleGuCtrl = TextEditingController(text: singer?.roleGu ?? '');
    final descEnCtrl = TextEditingController(text: singer?.descEn ?? '');
    final descGuCtrl = TextEditingController(text: singer?.descGu ?? '');
    String imgUrl = singer?.imageUrl ?? 'assets/images/pavan_putra_logo.png';

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Text(singer == null ? 'Add Artist / Musician Card' : 'Edit Musician Details', style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyAppImagePicker(label: 'Musician / Troupe Photograph', initialImageUrl: imgUrl, height: 140, onImageChanged: (url) => setDlgState(() => imgUrl = url)),
                  const SizedBox(height: 14),
                  MyAppTextFormField(
                    controller: nameEnCtrl,
                    targetLanguageController: nameGuCtrl,
                    labelText: 'Troupe / Artist Name (English)',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: nameGuCtrl,
                    labelText: 'Troupe / Artist Name (Gujarati)',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: roleEnCtrl,
                    targetLanguageController: roleGuCtrl,
                    labelText: 'Role / Instrument (English)',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: roleGuCtrl,
                    labelText: 'Role / Instrument (Gujarati)',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descEnCtrl,
                    targetLanguageController: descGuCtrl,
                    labelText: 'Description (English)',
                    minLines: 2,
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descGuCtrl,
                    labelText: 'Description (Gujarati)',
                    minLines: 2,
                    showClearIcon: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              label: singer == null ? 'Add Artist' : 'Save',
              onPressed: () {
                final nameEn = nameEnCtrl.text.trim();
                if (nameEn.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Name Required', description: 'Please provide artist name.');
                  return;
                }

                if (singer == null) {
                  widget.store.addHomeSinger(
                    AdminHomeSinger(
                      id: 'hs-${DateTime.now().millisecondsSinceEpoch}',
                      nameEn: nameEn,
                      nameGu: nameGuCtrl.text.trim(),
                      roleEn: roleEnCtrl.text.trim(),
                      roleGu: roleGuCtrl.text.trim(),
                      descEn: descEnCtrl.text.trim(),
                      descGu: descGuCtrl.text.trim(),
                      imageUrl: imgUrl,
                      order: widget.store.homeSingers.length + 1,
                    ),
                  );
                  MyAppToastMessage.success(context, title: 'Artist Added', description: '$nameEn added to Home screen carousel.');
                } else {
                  widget.store.updateHomeSinger(
                    singer.copyWith(
                      nameEn: nameEn,
                      nameGu: nameGuCtrl.text.trim(),
                      roleEn: roleEnCtrl.text.trim(),
                      roleGu: roleGuCtrl.text.trim(),
                      descEn: descEnCtrl.text.trim(),
                      descGu: descGuCtrl.text.trim(),
                      imageUrl: imgUrl,
                    ),
                  );
                  MyAppToastMessage.success(context, title: 'Artist Updated', description: '$nameEn details saved.');
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteSinger(AdminHomeSinger singer) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Artist Card?'),
        content: Text('Remove "${singer.nameEn}" from Home screen musician list?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () {
              widget.store.deleteHomeSinger(singer.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(context, title: 'Artist Removed', description: '${singer.nameEn} removed from Home screen.');
            },
          ),
        ],
      ),
    );
  }

  Future<void> _savePillarsHeader() async {
    var tagGu = _pillarsTagGuCtrl.text.trim();
    var titleGu = _pillarsTitleGuCtrl.text.trim();

    if (tagGu.isEmpty && _pillarsTagEnCtrl.text.trim().isNotEmpty) {
      try {
        tagGu = await GoogleTranslationService.instance.translateToGujarati(_pillarsTagEnCtrl.text.trim());
        _pillarsTagGuCtrl.text = tagGu;
      } catch (_) {}
    }
    if (titleGu.isEmpty && _pillarsTitleEnCtrl.text.trim().isNotEmpty) {
      try {
        titleGu = await GoogleTranslationService.instance.translateToGujarati(_pillarsTitleEnCtrl.text.trim());
        _pillarsTitleGuCtrl.text = titleGu;
      } catch (_) {}
    }

    await widget.store.saveHomePillarsHeader(
      tagEn: _pillarsTagEnCtrl.text.trim(),
      tagGu: tagGu,
      titleEn: _pillarsTitleEnCtrl.text.trim(),
      titleGu: titleGu,
    );
    if (mounted) {
      MyAppToastMessage.success(context, title: 'Pillars Header Saved', description: 'Sacred Foundations header updated.');
    }
  }

  void _confirmClearPillarsHeader() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Sacred Foundations Header?'),
        content: const Text('This will clear the eyebrow badge and headline for Sacred Foundations. Any empty fields will hide from the website.'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear',
            onPressed: () async {
              setState(() {
                _pillarsTagEnCtrl.clear();
                _pillarsTagGuCtrl.clear();
                _pillarsTitleEnCtrl.clear();
                _pillarsTitleGuCtrl.clear();
              });
              await widget.store.clearHomePillarsHeader();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                MyAppToastMessage.info(context, title: 'Header Cleared', description: 'Sacred Foundations header cleared.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _openPillarDialog([AdminHomePillar? pillar]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final numberCtrl = TextEditingController(text: pillar?.number ?? '૦${widget.store.pillars.length + 1}');
    final titleEnCtrl = TextEditingController(text: pillar?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: pillar?.titleGu ?? '');
    final descEnCtrl = TextEditingController(text: pillar?.descEn ?? '');
    final descGuCtrl = TextEditingController(text: pillar?.descGu ?? '');
    String selectedIcon = pillar?.iconKey ?? 'group';
    int order = pillar?.order ?? widget.store.pillars.length + 1;

    final icons = [
      {'key': 'group', 'label': 'Devotees / Footsteps', 'icon': Icons.group_rounded},
      {'key': 'book', 'label': 'Saint-Poets / Chhand', 'icon': Icons.menu_book_rounded},
      {'key': 'flame', 'label': 'Maha Aarti / Deepotsav', 'icon': Icons.whatshot_rounded},
      {'key': 'music', 'label': 'Acoustic Melody', 'icon': Icons.music_note_rounded},
      {'key': 'shield', 'label': 'Tradition / Sanity', 'icon': Icons.shield_outlined},
      {'key': 'flower', 'label': 'Sacred Lotus', 'icon': Icons.spa_rounded},
    ];

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Text(
            pillar == null ? 'Add Sacred Pillar Card' : 'Edit Sacred Pillar Card',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pillar Icon', style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((item) {
                      final isSelected = selectedIcon == item['key'];
                      return MyAppIconButtonWithName(
                        icon: item['icon'] as IconData,
                        name: item['label'] as String,
                        isSelected: isSelected,
                        onPressed: () => setDlgState(() => selectedIcon = item['key'] as String),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  MyAppTextFormField(
                    controller: numberCtrl,
                    labelText: 'Pillar Display Number',
                    hintText: 'e.g. ૦૧, ૦૨, ૦૩',
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    targetLanguageController: titleGuCtrl,
                    labelText: 'Pillar Title (English) *',
                    hintText: 'e.g. Prachin Raas & Footsteps',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Pillar Title (Gujarati)',
                    hintText: 'e.g. પ્રાચીન રાસ અને પગલાં',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descEnCtrl,
                    targetLanguageController: descGuCtrl,
                    labelText: 'Pillar Description (English)',
                    hintText: 'e.g. Graceful, disciplined synchronized footsteps by devoted participants...',
                    minLines: 2,
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descGuCtrl,
                    labelText: 'Pillar Description (Gujarati)',
                    minLines: 2,
                    showClearIcon: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              label: pillar == null ? 'Add Pillar' : 'Save Changes',
              onPressed: () async {
                final titleEn = titleEnCtrl.text.trim();
                final titleGu = titleGuCtrl.text.trim();
                if (titleEn.isEmpty && titleGu.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Title Required', description: 'Please provide at least an English or Gujarati title.');
                  return;
                }

                if (pillar == null) {
                  await widget.store.addHomePillar(
                    AdminHomePillar(
                      id: 'pillar-${DateTime.now().millisecondsSinceEpoch}',
                      number: numberCtrl.text.trim().isNotEmpty ? numberCtrl.text.trim() : '૦૧',
                      titleEn: titleEn,
                      titleGu: titleGu,
                      descEn: descEnCtrl.text.trim(),
                      descGu: descGuCtrl.text.trim(),
                      iconKey: selectedIcon,
                      order: order,
                    ),
                  );
                  if (mounted) {
                    MyAppToastMessage.success(this.context, title: 'Pillar Added', description: 'Sacred pillar card added to website homepage.');
                  }
                } else {
                  await widget.store.updateHomePillar(
                    pillar.copyWith(
                      number: numberCtrl.text.trim().isNotEmpty ? numberCtrl.text.trim() : pillar.number,
                      titleEn: titleEn,
                      titleGu: titleGu,
                      descEn: descEnCtrl.text.trim(),
                      descGu: descGuCtrl.text.trim(),
                      iconKey: selectedIcon,
                      order: order,
                    ),
                  );
                  if (mounted) {
                    MyAppToastMessage.success(this.context, title: 'Pillar Updated', description: 'Sacred pillar card saved and published to the website.');
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePillar(AdminHomePillar pillar) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sacred Pillar?'),
        content: Text('Permanently remove "${pillar.titleEn.isNotEmpty ? pillar.titleEn : pillar.titleGu}" from the homepage Sacred Foundations section?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () async {
              await widget.store.deleteHomePillar(pillar.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                MyAppToastMessage.warning(context, title: 'Pillar Deleted', description: 'Pillar removed and hidden from the website.');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveSingersHeader() async {
    var tagGu = _singersTagGuCtrl.text.trim();
    var titleGu = _singersTitleGuCtrl.text.trim();
    var descGu = _singersDescGuCtrl.text.trim();

    if (tagGu.isEmpty && _singersTagEnCtrl.text.trim().isNotEmpty) {
      try {
        tagGu = await GoogleTranslationService.instance.translateToGujarati(_singersTagEnCtrl.text.trim());
        _singersTagGuCtrl.text = tagGu;
      } catch (_) {}
    }
    if (titleGu.isEmpty && _singersTitleEnCtrl.text.trim().isNotEmpty) {
      try {
        titleGu = await GoogleTranslationService.instance.translateToGujarati(_singersTitleEnCtrl.text.trim());
        _singersTitleGuCtrl.text = titleGu;
      } catch (_) {}
    }
    if (descGu.isEmpty && _singersDescEnCtrl.text.trim().isNotEmpty) {
      try {
        descGu = await GoogleTranslationService.instance.translateToGujarati(_singersDescEnCtrl.text.trim());
        _singersDescGuCtrl.text = descGu;
      } catch (_) {}
    }

    await widget.store.saveHomeSingersHeader(
      tagEn: _singersTagEnCtrl.text.trim(),
      tagGu: tagGu,
      titleEn: _singersTitleEnCtrl.text.trim(),
      titleGu: titleGu,
      descEn: _singersDescEnCtrl.text.trim(),
      descGu: descGu,
    );
    if (mounted) {
      MyAppToastMessage.success(context, title: 'Singers Header Saved', description: 'Folk artists section header saved.');
    }
  }

  void _confirmClearSingersHeader() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Folk Vocalists Header?'),
        content: const Text('This will clear the eyebrow badge, headline, and description for Folk Vocalists & Troupe. Any empty fields will hide from the website.'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear',
            onPressed: () async {
              setState(() {
                _singersTagEnCtrl.clear();
                _singersTagGuCtrl.clear();
                _singersTitleEnCtrl.clear();
                _singersTitleGuCtrl.clear();
                _singersDescEnCtrl.clear();
                _singersDescGuCtrl.clear();
              });
              await widget.store.clearHomeSingersHeader();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                MyAppToastMessage.info(context, title: 'Header Cleared', description: 'Folk Vocalists header cleared.');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveBlessingsHeader() async {
    var tagGu = _blessingsTagGuCtrl.text.trim();
    var titleGu = _blessingsTitleGuCtrl.text.trim();

    if (tagGu.isEmpty && _blessingsTagEnCtrl.text.trim().isNotEmpty) {
      try {
        tagGu = await GoogleTranslationService.instance.translateToGujarati(_blessingsTagEnCtrl.text.trim());
        _blessingsTagGuCtrl.text = tagGu;
      } catch (_) {}
    }
    if (titleGu.isEmpty && _blessingsTitleEnCtrl.text.trim().isNotEmpty) {
      try {
        titleGu = await GoogleTranslationService.instance.translateToGujarati(_blessingsTitleEnCtrl.text.trim());
        _blessingsTitleGuCtrl.text = titleGu;
      } catch (_) {}
    }

    await widget.store.saveHomeBlessingsHeader(
      tagEn: _blessingsTagEnCtrl.text.trim(),
      tagGu: tagGu,
      titleEn: _blessingsTitleEnCtrl.text.trim(),
      titleGu: titleGu,
    );
    if (mounted) {
      MyAppToastMessage.success(context, title: 'Blessings Header Saved', description: 'Elders blessings header saved.');
    }
  }

  void _confirmClearBlessingsHeader() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Elders & Dignitaries Blessings Header?'),
        content: const Text('This will clear the eyebrow badge and headline for Elders & Dignitaries Blessings. Any empty fields will hide from the website.'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear',
            onPressed: () async {
              setState(() {
                _blessingsTagEnCtrl.clear();
                _blessingsTagGuCtrl.clear();
                _blessingsTitleEnCtrl.clear();
                _blessingsTitleGuCtrl.clear();
              });
              await widget.store.clearHomeBlessingsHeader();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                MyAppToastMessage.info(context, title: 'Header Cleared', description: 'Elders & Dignitaries Blessings header cleared.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _openBlessingDialog([AdminHomeBlessing? blessing]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final authorEnCtrl = TextEditingController(text: blessing?.authorEn ?? '');
    final authorGuCtrl = TextEditingController(text: blessing?.authorGu ?? '');
    final desigEnCtrl = TextEditingController(text: blessing?.designationEn ?? '');
    final desigGuCtrl = TextEditingController(text: blessing?.designationGu ?? '');
    final quoteEnCtrl = TextEditingController(text: blessing?.quoteEn ?? '');
    final quoteGuCtrl = TextEditingController(text: blessing?.quoteGu ?? '');
    String photoUrl = blessing?.photoUrl ?? 'assets/images/pavan_putra_logo.png';
    int order = blessing?.order ?? widget.store.blessings.length + 1;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Text(
            blessing == null ? 'Add Elder / Dignitary Blessing' : 'Edit Blessing Quote',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppImagePicker(
                    label: 'Dignitary Photograph',
                    initialImageUrl: photoUrl,
                    height: 130,
                    onImageChanged: (url) => setDlgState(() => photoUrl = url),
                  ),
                  const SizedBox(height: 14),
                  MyAppTextFormField(
                    controller: authorEnCtrl,
                    targetLanguageController: authorGuCtrl,
                    labelText: 'Author / Dignitary Name (English) *',
                    hintText: 'e.g. Shri Morari Bapu',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: authorGuCtrl,
                    labelText: 'Author / Dignitary Name (Gujarati)',
                    hintText: 'e.g. પૂજ્ય મોરારી બાપુ',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: desigEnCtrl,
                    targetLanguageController: desigGuCtrl,
                    labelText: 'Designation / Title (English)',
                    hintText: 'e.g. Spiritual Guru & Ramcharitmanas Exponent',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: desigGuCtrl,
                    labelText: 'Designation / Title (Gujarati)',
                    hintText: 'e.g. રામાયણી સંત & અધ્યાત્મિક ગુરુ',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: quoteEnCtrl,
                    targetLanguageController: quoteGuCtrl,
                    labelText: 'Blessing Quote (English)',
                    hintText: 'e.g. Pavan Putra Garbi Mandal is the true living mirror...',
                    minLines: 3,
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: quoteGuCtrl,
                    labelText: 'Blessing Quote (Gujarati)',
                    minLines: 3,
                    showClearIcon: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              label: blessing == null ? 'Add Blessing' : 'Save Changes',
              onPressed: () async {
                final authorEn = authorEnCtrl.text.trim();
                final authorGu = authorGuCtrl.text.trim();
                if (authorEn.isEmpty && authorGu.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Author Required', description: 'Please enter dignitary name.');
                  return;
                }

                if (blessing == null) {
                  await widget.store.addHomeBlessing(
                    AdminHomeBlessing(
                      id: 'blessing-${DateTime.now().millisecondsSinceEpoch}',
                      authorEn: authorEn,
                      authorGu: authorGu,
                      designationEn: desigEnCtrl.text.trim(),
                      designationGu: desigGuCtrl.text.trim(),
                      quoteEn: quoteEnCtrl.text.trim(),
                      quoteGu: quoteGuCtrl.text.trim(),
                      photoUrl: photoUrl,
                      order: order,
                    ),
                  );
                  if (mounted) {
                    MyAppToastMessage.success(this.context, title: 'Blessing Added', description: 'Testimonial quote added to home carousel.');
                  }
                } else {
                  await widget.store.updateHomeBlessing(
                    blessing.copyWith(
                      authorEn: authorEn,
                      authorGu: authorGu,
                      designationEn: desigEnCtrl.text.trim(),
                      designationGu: desigGuCtrl.text.trim(),
                      quoteEn: quoteEnCtrl.text.trim(),
                      quoteGu: quoteGuCtrl.text.trim(),
                      photoUrl: photoUrl,
                      order: order,
                    ),
                  );
                  if (mounted) {
                    MyAppToastMessage.success(this.context, title: 'Blessing Updated', description: 'Blessing quote saved and published to the website.');
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBlessing(AdminHomeBlessing blessing) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Blessing Quote?'),
        content: Text('Remove blessing quote from "${blessing.authorEn.isNotEmpty ? blessing.authorEn : blessing.authorGu}"?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () async {
              await widget.store.deleteHomeBlessing(blessing.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                MyAppToastMessage.warning(context, title: 'Blessing Removed', description: 'Quote removed and hidden from the website.');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveCtaBanner() async {
    var invGu = _ctaInvocationGuCtrl.text.trim();
    var mottoGu = _ctaMottoGuCtrl.text.trim();
    var btnGu = _ctaBtnTextGuCtrl.text.trim();

    if (invGu.isEmpty && _ctaInvocationEnCtrl.text.trim().isNotEmpty) {
      try {
        invGu = await GoogleTranslationService.instance.translateToGujarati(_ctaInvocationEnCtrl.text.trim());
        _ctaInvocationGuCtrl.text = invGu;
      } catch (_) {}
    }
    if (mottoGu.isEmpty && _ctaMottoEnCtrl.text.trim().isNotEmpty) {
      try {
        mottoGu = await GoogleTranslationService.instance.translateToGujarati(_ctaMottoEnCtrl.text.trim());
        _ctaMottoGuCtrl.text = mottoGu;
      } catch (_) {}
    }
    if (btnGu.isEmpty && _ctaBtnTextEnCtrl.text.trim().isNotEmpty) {
      try {
        btnGu = await GoogleTranslationService.instance.translateToGujarati(_ctaBtnTextEnCtrl.text.trim());
        _ctaBtnTextGuCtrl.text = btnGu;
      } catch (_) {}
    }

    await widget.store.saveHomeCtaData(
      AdminHomeCtaData(
        invocationEn: _ctaInvocationEnCtrl.text.trim(),
        invocationGu: invGu,
        mottoEn: _ctaMottoEnCtrl.text.trim(),
        mottoGu: mottoGu,
        btnTextEn: _ctaBtnTextEnCtrl.text.trim(),
        btnTextGu: btnGu,
        btnRoute: _ctaBtnRouteCtrl.text.trim().isNotEmpty ? _ctaBtnRouteCtrl.text.trim() : '/contact',
      ),
    );
    if (mounted) {
      MyAppToastMessage.success(context, title: 'CTA Banner Saved', description: 'Cultural Call-To-Action banner saved and published to the website.');
    }
  }

  Future<void> _clearCtaBanner() async {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Call-To-Action Banner?'),
        content: const Text('This will clear and hide the bottom Call-To-Action banner from the website.'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear & Hide',
            onPressed: () async {
              setState(() {
                _ctaInvocationEnCtrl.clear();
                _ctaInvocationGuCtrl.clear();
                _ctaMottoEnCtrl.clear();
                _ctaMottoGuCtrl.clear();
                _ctaBtnTextEnCtrl.clear();
                _ctaBtnTextGuCtrl.clear();
              });
              await widget.store.clearHomeCtaData();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                MyAppToastMessage.info(context, title: 'CTA Banner Cleared', description: 'CTA banner hidden from public website.');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveArticlesHeader() async {
    var tagGu = _articlesTagGuCtrl.text.trim();
    var titleGu = _articlesTitleGuCtrl.text.trim();

    if (tagGu.isEmpty && _articlesTagEnCtrl.text.trim().isNotEmpty) {
      try {
        tagGu = await GoogleTranslationService.instance.translateToGujarati(_articlesTagEnCtrl.text.trim());
        _articlesTagGuCtrl.text = tagGu;
      } catch (_) {}
    }
    if (titleGu.isEmpty && _articlesTitleEnCtrl.text.trim().isNotEmpty) {
      try {
        titleGu = await GoogleTranslationService.instance.translateToGujarati(_articlesTitleEnCtrl.text.trim());
        _articlesTitleGuCtrl.text = titleGu;
      } catch (_) {}
    }

    await widget.store.saveHomeArticlesHeader(
      tagEn: _articlesTagEnCtrl.text.trim(),
      tagGu: tagGu,
      titleEn: _articlesTitleEnCtrl.text.trim(),
      titleGu: titleGu,
    );
    if (mounted) {
      MyAppToastMessage.success(context, title: 'Articles Header Saved', description: 'Cultural stories section header saved and published to the website.');
    }
  }

  Future<void> _clearArticlesHeader() async {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Articles Header?'),
        content: const Text('This will clear the header badge and headline for Cultural Stories & Articles.'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear',
            onPressed: () async {
              setState(() {
                _articlesTagEnCtrl.clear();
                _articlesTagGuCtrl.clear();
                _articlesTitleEnCtrl.clear();
                _articlesTitleGuCtrl.clear();
              });
              await widget.store.clearHomeArticlesHeader();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                MyAppToastMessage.info(context, title: 'Header Cleared', description: 'Section 7 header cleared.');
              }
            },
          ),
        ],
      ),
    );
  }

  void _openArticleDialog([AdminBlog? article]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final titleEnCtrl = TextEditingController(text: article?.title ?? '');
    final titleGuCtrl = TextEditingController(text: article?.titleGu ?? '');
    final snippetEnCtrl = TextEditingController(text: article?.snippet ?? '');
    final snippetGuCtrl = TextEditingController(text: article?.snippetGu ?? '');
    final catCtrl = TextEditingController(text: article?.category ?? 'HERITAGE ARTICLE');
    final slugCtrl = TextEditingController(text: article?.slug ?? '');
    final readTimeCtrl = TextEditingController(text: article?.readTime ?? '5 min read');
    final dateCtrl = TextEditingController(text: article?.date ?? 'October 2025');
    final contentCtrl = TextEditingController(text: article?.content ?? '');
    String imageUrl = article?.imageUrl ?? 'assets/images/pavan_putra_logo.png';
    bool isPublished = article?.isPublished ?? true;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Text(
            article == null ? 'Add Cultural Story / Article' : 'Edit Cultural Article',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppImagePicker(
                    label: 'Article Featured Graphic',
                    initialImageUrl: imageUrl,
                    height: 120,
                    onImageChanged: (url) => setDlgState(() => imageUrl = url),
                  ),
                  const SizedBox(height: 14),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    targetLanguageController: titleGuCtrl,
                    labelText: 'Article Headline (English) *',
                    hintText: 'e.g. The Sacred Spiritual Significance of Prachin Garbi',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Article Headline (Gujarati)',
                    hintText: 'e.g. પ્રાચીન ગરબીનું આધ્યાત્મિક મહત્વ અને પરંપરા',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: snippetEnCtrl,
                    targetLanguageController: snippetGuCtrl,
                    labelText: 'Article Summary / Snippet (English) *',
                    hintText: 'Short preview shown on the homepage card',
                    minLines: 2,
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: snippetGuCtrl,
                    labelText: 'Article Summary / Snippet (Gujarati)',
                    hintText: 'હોમપેજ કાર્ડ પર દર્શાવવામાં આવતો સંક્ષિપ્ત સાર',
                    minLines: 2,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: catCtrl,
                          labelText: 'Category Badge',
                          hintText: 'e.g. HERITAGE ARTICLE',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: readTimeCtrl,
                          labelText: 'Read Time',
                          hintText: 'e.g. 5 min read',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: dateCtrl,
                          labelText: 'Publication Date',
                          hintText: 'e.g. October 2025',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: slugCtrl,
                          labelText: 'URL Slug',
                          hintText: 'e.g. sacred-spiritual-significance',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: contentCtrl,
                    labelText: 'Full Article Content (Optional)',
                    hintText: 'Full story text for detail page reading',
                    minLines: 3,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.getBorderColor(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Publish on Website',
                                style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                isPublished ? 'Visible on public homepage' : 'Draft only (hidden)',
                                style: styles.cleanSans(
                                  context,
                                  size: 11.5,
                                  color: isPublished ? Colors.green : colors.getMutedTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: isPublished,
                            activeThumbColor: colors.heritageGold,
                            activeTrackColor: colors.deepMaroon,
                            onChanged: (val) => setDlgState(() => isPublished = val),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              label: article == null ? 'Publish Article' : 'Save Changes',
              onPressed: () async {
                final titleEn = titleEnCtrl.text.trim();
                final titleGu = titleGuCtrl.text.trim();
                if (titleEn.isEmpty && titleGu.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Title Required', description: 'Please provide at least an English or Gujarati article title.');
                  return;
                }

                var finalTitleGu = titleGu;
                if (finalTitleGu.isEmpty && titleEn.isNotEmpty) {
                  try {
                    finalTitleGu = await GoogleTranslationService.instance.translateToGujarati(titleEn);
                  } catch (_) {}
                }

                var finalSnippetGu = snippetGuCtrl.text.trim();
                if (finalSnippetGu.isEmpty && snippetEnCtrl.text.trim().isNotEmpty) {
                  try {
                    finalSnippetGu = await GoogleTranslationService.instance.translateToGujarati(snippetEnCtrl.text.trim());
                  } catch (_) {}
                }

                final generatedSlug = slugCtrl.text.trim().isNotEmpty
                    ? slugCtrl.text.trim()
                    : titleEn.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

                final finalBlog = AdminBlog(
                  id: article?.id ?? 'blog-${DateTime.now().millisecondsSinceEpoch}',
                  slug: generatedSlug.isNotEmpty ? generatedSlug : 'post-${DateTime.now().millisecondsSinceEpoch}',
                  title: titleEn,
                  titleGu: finalTitleGu,
                  category: catCtrl.text.trim().isNotEmpty ? catCtrl.text.trim() : 'HERITAGE ARTICLE',
                  date: dateCtrl.text.trim().isNotEmpty ? dateCtrl.text.trim() : 'October 2025',
                  readTime: readTimeCtrl.text.trim().isNotEmpty ? readTimeCtrl.text.trim() : '5 min read',
                  snippet: snippetEnCtrl.text.trim(),
                  snippetGu: finalSnippetGu,
                  content: contentCtrl.text.trim(),
                  imageUrl: imageUrl,
                  isPublished: isPublished,
                );

                if (article == null) {
                  widget.store.addBlog(finalBlog);
                } else {
                  widget.store.updateBlog(finalBlog);
                }

                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  MyAppToastMessage.success(
                    this.context,
                    title: article == null ? 'Article Created' : 'Article Updated',
                    description: 'Article saved and published to the live website.',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteArticle(AdminBlog article) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Cultural Article?'),
        content: Text('Permanently remove "${article.title.isNotEmpty ? article.title : article.titleGu}" from the homepage articles section?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () {
              widget.store.deleteBlog(article.id);
              Navigator.pop(ctx);
              if (mounted) {
                MyAppToastMessage.warning(context, title: 'Article Deleted', description: 'Article removed from the website.');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiveArticlesPreview(MyAppColors colors, MyAppTextStyles styles, bool isMobile) {
    final store = widget.store;
    final isGu = _articlesPreviewLang == 'gu';
    final rawTag = isGu ? _articlesTagGuCtrl.text.trim() : _articlesTagEnCtrl.text.trim();
    final effectiveTag = rawTag.isNotEmpty ? rawTag : (isGu ? '૦૭ / સાંસ્કૃતિક વાતો અને લેખો' : '07 / CULTURAL STORIES & ARTICLES');
    final rawTitle = isGu ? _articlesTitleGuCtrl.text.trim() : _articlesTitleEnCtrl.text.trim();
    final effectiveTitle = rawTitle.isNotEmpty ? rawTitle : (isGu ? 'વારસો, ગૌરવ અને આધ્યાત્મિક ચિંતન' : 'Heritage, Meaning & Reflections');
    final blogs = store.blogs.where((b) => b.isPublished).take(2).toList();

    return Container(
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.4), width: 1.2),
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 450;
              final langSelector = MyAppSegmentView.language(
                selectedLanguage: _articlesPreviewLang,
                onLanguageChanged: (val) => setState(() => _articlesPreviewLang = val),
              );

              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_rounded, size: 16, color: colors.heritageGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Live Website Preview (Section 7)',
                            style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w700).copyWith(color: colors.heritageGold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    langSelector,
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.remove_red_eye_rounded, size: 18, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Live Website Preview (Section 7)', style: styles.eyebrow(context)),
                  ),
                  const SizedBox(width: 8),
                  langSelector,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (effectiveTag.isNotEmpty) HeritageBadge(label: effectiveTag),
          const SizedBox(height: 8),
          if (effectiveTitle.isNotEmpty) Text(effectiveTitle, style: styles.h2(context)),
          const SizedBox(height: 16),
          if (blogs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No articles currently added. Add an article above to display cards here.',
                    style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context))),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, c) {
                final double itemWidth = c.maxWidth < 680 ? c.maxWidth : (c.maxWidth - 16) / 2;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final b in blogs)
                      SizedBox(
                        width: itemWidth,
                        height: isMobile ? null : 235,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => showArticleDetailModal(
                            context,
                            title: b.getTitle(isGu ? 'gu' : 'en'),
                            category: b.category,
                            content: b.content.isNotEmpty ? b.content : b.getSnippet(isGu ? 'gu' : 'en'),
                            snippet: b.getSnippet(isGu ? 'gu' : 'en'),
                            date: b.date,
                            readTime: b.readTime,
                          ),
                          child: Container(
                            height: isMobile ? null : 235,
                            constraints: const BoxConstraints(minHeight: 220),
                            child: CulturalFrameCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.menu_book_rounded, size: 14, color: colors.getAccentColor(context)),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              b.category.isNotEmpty ? b.category.toUpperCase() : 'HERITAGE ARTICLE',
                                              style: styles.eyebrow(context).copyWith(fontSize: 10),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        b.getTitle(isGu ? 'gu' : 'en'),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        b.getSnippet(isGu ? 'gu' : 'en'),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context), height: 1.45),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Text(
                                        isGu ? 'વાંચો સંપૂર્ણ લેખ →' : 'READ FULL ARTICLE →',
                                        style: styles.cleanSans(context, color: colors.getAccentColor(context), size: 11, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminWebsiteContextBanner(
          websitePageTitle: 'Website Homepage',
          websiteRoute: '/',
          explanation: 'Controls what visitors see upon opening the main website: the top hero carousel, invitation text, guest singers, and festival stats.',
        ),
        // Page Title & Header Actions
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeritageBadge(label: 'WEBSITE CONTENT / HOME SCREEN'),
                const SizedBox(height: 6),
                Text('Home Screen Complete Management', style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700)),
                Text(
                  'Manage hero banner, emblem image, quick highlights stats, about mandal text, live orchestra artists, and sacred pillars.',
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // SECTION 1: HERO BANNER & EMBLEM IMAGE
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.view_carousel_rounded, color: colors.heritageGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '1. Hero Section & Emblem Image',
                            style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MyAppOutlineButton.icon(
                          isDanger: true,
                          onPressed: _confirmClearAllHero,
                          icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                          label: 'Clear All',
                        ),
                        MyAppFillButton.icon(
                          onPressed: _saveHeroChanges,
                          icon: const Icon(Icons.save_rounded, size: 16),
                          label: 'Save Hero',
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.view_carousel_rounded, color: colors.heritageGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '1. Hero Section & Emblem Image',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyAppOutlineButton.icon(
                          isDanger: true,
                          onPressed: _confirmClearAllHero,
                          icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                          label: 'Clear All',
                        ),
                        const SizedBox(width: 8),
                        MyAppFillButton.icon(
                          onPressed: _saveHeroChanges,
                          icon: const Icon(Icons.save_rounded, size: 16),
                          label: 'Save Hero',
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Text(
                'Complete control over all 10 elements of the website homepage hero card. Any empty or cleared field is immediately hidden from the live website.',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 20),
              _buildLiveHeroPreviewCard(colors, styles),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 850;

                  final leftColumn = Column(
                    children: [
                      MyAppImagePicker(
                        label: 'Hero Emblem / Banner Graphic',
                        helperText: 'Pick from device or paste image URL. Click Remove to hide emblem on public site.',
                        initialImageUrl: _heroImageUrl,
                        isCircle: true,
                        height: 200,
                        onImageChanged: (url) => setState(() => _heroImageUrl = url),
                        onImageRemoved: () => setState(() => _heroImageUrl = ''),
                      ),
                    ],
                  );

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: leftColumn),
                            const SizedBox(width: 24),
                            Expanded(flex: 6, child: _buildHeroInputs()),
                          ],
                        )
                      : Column(children: [leftColumn, const SizedBox(height: 20), _buildHeroInputs()]);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 2: HERITAGE HIGHLIGHTS (4 STATS BAR)
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed_rounded, color: colors.heritageGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '2. Quick Heritage Highlights (4 Metric Counters)',
                            style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MyAppOutlineButton.icon(
                          isDanger: true,
                          onPressed: _confirmClearAllStats,
                          icon: const Icon(Icons.delete_sweep_rounded),
                          label: 'Clear All',
                        ),
                        MyAppFillButton.icon(
                          onPressed: _saveStatsChanges,
                          icon: const Icon(Icons.save_rounded),
                          label: 'Save Stats',
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.speed_rounded, color: colors.heritageGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '2. Quick Heritage Highlights (4 Metric Counters)',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyAppOutlineButton.icon(
                          isDanger: true,
                          onPressed: _confirmClearAllStats,
                          icon: const Icon(Icons.delete_sweep_rounded),
                          label: 'Clear All',
                        ),
                        const SizedBox(width: 8),
                        MyAppFillButton.icon(
                          onPressed: _saveStatsChanges,
                          icon: const Icon(Icons.save_rounded),
                          label: 'Save Stats',
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Text(
                'Full control over all 4 highlight counters shown on the website homepage. Any empty or cleared statistic is neatly hidden.',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 18),
              _buildLiveStatsPreviewCard(colors, styles),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 750;
                  final stat1Widget = _buildStatCard(
                    statNumber: '1',
                    statName: 'Heritage Legacy & Years',
                    icon: Icons.auto_stories_rounded,
                    titleHint: '37+ Years',
                    descHint: 'Continuous heritage in Rajkot',
                    titleEnCtrl: _stat1TitleEnCtrl,
                    titleGuCtrl: _stat1TitleGuCtrl,
                    descEnCtrl: _stat1DescEnCtrl,
                    descGuCtrl: _stat1DescGuCtrl,
                  );
                  final stat2Widget = _buildStatCard(
                    statNumber: '2',
                    statName: 'Authentic Folk Music',
                    icon: Icons.music_note_rounded,
                    titleHint: '100% Prachin',
                    descHint: 'Acoustic live folk instruments',
                    titleEnCtrl: _stat2TitleEnCtrl,
                    titleGuCtrl: _stat2TitleGuCtrl,
                    descEnCtrl: _stat2DescEnCtrl,
                    descGuCtrl: _stat2DescGuCtrl,
                  );
                  final stat3Widget = _buildStatCard(
                    statNumber: '3',
                    statName: 'Divine Devotion',
                    icon: Icons.local_fire_department_rounded,
                    titleHint: 'Maa Jagti Jogmaya',
                    descHint: 'Sacred deepam & daily Maha Aarti',
                    titleEnCtrl: _stat3TitleEnCtrl,
                    titleGuCtrl: _stat3TitleGuCtrl,
                    descEnCtrl: _stat3DescEnCtrl,
                    descGuCtrl: _stat3DescGuCtrl,
                  );
                  final stat4Widget = _buildStatCard(
                    statNumber: '4',
                    statName: 'Digital Archive',
                    icon: Icons.history_rounded,
                    titleHint: 'Digital Archive',
                    descHint: 'Decades of photos & recordings',
                    titleEnCtrl: _stat4TitleEnCtrl,
                    titleGuCtrl: _stat4TitleGuCtrl,
                    descEnCtrl: _stat4DescEnCtrl,
                    descGuCtrl: _stat4DescGuCtrl,
                  );

                  return isWide
                      ? Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: stat1Widget),
                                const SizedBox(width: 16),
                                Expanded(child: stat2Widget),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: stat3Widget),
                                const SizedBox(width: 16),
                                Expanded(child: stat4Widget),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            stat1Widget,
                            const SizedBox(height: 14),
                            stat2Widget,
                            const SizedBox(height: 14),
                            stat3Widget,
                            const SizedBox(height: 14),
                            stat4Widget,
                          ],
                        );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 3: ABOUT MANDAL SECTION & AARTI ANNOUNCEMENT
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: colors.heritageGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '3. About Mandal Highlights & Daily Aarti',
                            style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MyAppOutlineButton.icon(
                            isDanger: true,
                            onPressed: _clearAboutFields,
                            icon: const Icon(Icons.clear_all_rounded, size: 16),
                            label: 'Clear All',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MyAppFillButton.icon(
                            onPressed: _saveAboutChanges,
                            icon: const Icon(Icons.save_rounded, size: 16),
                            label: 'Save About',
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: colors.heritageGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('3. About Mandal Highlights & Daily Aarti', style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _clearAboutFields,
                      icon: const Icon(Icons.clear_all_rounded, size: 16),
                      label: 'Clear All',
                    ),
                    const SizedBox(width: 8),
                    MyAppFillButton.icon(
                      onPressed: _saveAboutChanges,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save About',
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              _buildLiveAboutPreview(colors, styles, isMobile),
              const SizedBox(height: 24),

              // Eyebrow Tag Inputs
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _sec1TagEnCtrl,
                      targetLanguageController: _sec1TagGuCtrl,
                      labelText: 'About Eyebrow Badge (English)',
                      hintText: 'e.g. 01 / THE MANDAL',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _sec1TagGuCtrl,
                      labelText: 'About Eyebrow Badge (Gujarati)',
                      hintText: 'e.g. ૦૧ / ગરબી મંડળ પરિચય',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _sec1TagEnCtrl,
                        targetLanguageController: _sec1TagGuCtrl,
                        labelText: 'About Eyebrow Badge (English)',
                        hintText: 'e.g. 01 / THE MANDAL',
                        showTranslateIcon: true,
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _sec1TagGuCtrl,
                        labelText: 'About Eyebrow Badge (Gujarati)',
                        hintText: 'e.g. ૦૧ / ગરબી મંડળ પરિચય',
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Headline Inputs
              MyAppTextFormField(
                controller: _sec1TitleEnCtrl,
                targetLanguageController: _sec1TitleGuCtrl,
                labelText: 'About Headline (English)',
                hintText: 'Preserving the Pure Essence of Traditional Garbi.',
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _sec1TitleGuCtrl,
                labelText: 'About Headline (Gujarati)',
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Story Paragraph Inputs
              MyAppTextAreaField(
                controller: _sec1DescEnCtrl,
                targetLanguageController: _sec1DescGuCtrl,
                labelText: 'About Story Paragraph (English)',
                hintText: 'Unlike commercial disco dandiya events, Pavan Putra Garbi Mandal remains true...',
                minLines: 3,
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              MyAppTextAreaField(
                controller: _sec1DescGuCtrl,
                labelText: 'About Story Paragraph (Gujarati)',
                minLines: 3,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),

              // Aarti Announcement Inputs
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _aartiAnnounceCtrl,
                      targetLanguageController: _aartiAnnounceGuCtrl,
                      labelText: 'Daily Maha Aarti Announcement (English)',
                      hintText: 'Daily Sacred Maha Aarti at 09:00 PM with 108 Deepam lamps.',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _aartiAnnounceGuCtrl,
                      labelText: 'Daily Maha Aarti Announcement (Gujarati)',
                      hintText: 'દરરોજ રાત્રે ૯:૦૦ કલાકે ૧૦૮ દીવડાઓ સાથે ભવ્ય મહા આરતી દર્શન.',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _aartiAnnounceCtrl,
                        targetLanguageController: _aartiAnnounceGuCtrl,
                        labelText: 'Daily Maha Aarti Announcement (English)',
                        hintText: 'Daily Sacred Maha Aarti at 09:00 PM with 108 Deepam lamps.',
                        showTranslateIcon: true,
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _aartiAnnounceGuCtrl,
                        labelText: 'Daily Maha Aarti Announcement (Gujarati)',
                        hintText: 'દરરોજ રાત્રે ૯:૦૦ કલાકે ૧૦૮ દીવડાઓ સાથે ભવ્ય મહા આરતી દર્શન.',
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // DYNAMIC VALUE / FEATURE CARDS CRUD (Image 2 cards)
              Row(
                children: [
                  Icon(Icons.dashboard_customize_rounded, color: colors.heritageGold, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Feature & Value Cards (${widget.store.aboutCards.length})',
                      style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MyAppFillButton.icon(
                    onPressed: () => _openAboutCardDialog(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: 'Add Card',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Add cards just like "Pure Cultural Sanity", "Acoustic Folk Orchestra", and "Sacred Reverence" seen on the website.',
                style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 14),

              if (widget.store.aboutCards.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.getBorderColor(context)),
                    color: colors.getCardBackgroundColor(context).withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.style_outlined, color: colors.heritageGold, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'No value cards created yet.',
                          style: styles.bodyText(context).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Click "+ Add Card" above to add feature cards to the website.',
                          style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final card in widget.store.aboutCards)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.getCardBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.getBorderColor(context)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: colors.getAccentColor(context).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(card.iconData, color: colors.getAccentColor(context), size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: card.titleEn.isNotEmpty ? card.titleEn : card.titleGu,
                                          style: styles.bodyText(context).copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        if (card.titleEn.isNotEmpty && card.titleGu.isNotEmpty)
                                          TextSpan(
                                            text: ' (${card.titleGu})',
                                            style: styles.bodySmall(context).copyWith(color: colors.heritageGold),
                                          ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    card.descEn.isNotEmpty ? card.descEn : card.descGu,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Card',
                              onPressed: () => _openAboutCardDialog(card),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: colors.sacredRed),
                              tooltip: 'Delete Card',
                              onPressed: () => _confirmDeleteAboutCard(card),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 4: SACRED FOUNDATIONS / PILLARS OF GARBI
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 620;
                  final headerButtons = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MyAppOutlineButton.icon(
                        isDanger: true,
                        onPressed: _confirmClearPillarsHeader,
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: isTight ? 'Clear' : 'Clear All',
                      ),
                      MyAppFillButton.icon(
                        onPressed: _savePillarsHeader,
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: isTight ? 'Save' : 'Save Header',
                      ),
                    ],
                  );

                  if (isTight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_rounded, color: colors.heritageGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '4. Sacred Foundations / Pillars of Garbi',
                                style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        headerButtons,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.account_balance_rounded, color: colors.heritageGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '4. Sacred Foundations / Pillars of Garbi',
                                style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      headerButtons,
                    ],
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Manage Sacred Foundation Pillars (02 / SACRED FOUNDATIONS). Add, edit, or remove cards anytime. Empty cards hide immediately.',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              _buildLivePillarsPreview(colors, styles, isMobile),
              const SizedBox(height: 24),

              // Pillars Eyebrow Tag Inputs
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _pillarsTagEnCtrl,
                      targetLanguageController: _pillarsTagGuCtrl,
                      labelText: 'Pillars Eyebrow Badge (English)',
                      hintText: 'e.g. 02 / SACRED FOUNDATIONS',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _pillarsTagGuCtrl,
                      labelText: 'Pillars Eyebrow Badge (Gujarati)',
                      hintText: 'e.g. ૦૨ / ગરબીના પાયા',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _pillarsTagEnCtrl,
                        targetLanguageController: _pillarsTagGuCtrl,
                        labelText: 'Pillars Eyebrow Badge (English)',
                        hintText: 'e.g. 02 / SACRED FOUNDATIONS',
                        showTranslateIcon: true,
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _pillarsTagGuCtrl,
                        labelText: 'Pillars Eyebrow Badge (Gujarati)',
                        hintText: 'e.g. ૦૨ / ગરબીના પાયા',
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Pillars Headline Inputs
              MyAppTextFormField(
                controller: _pillarsTitleEnCtrl,
                targetLanguageController: _pillarsTitleGuCtrl,
                labelText: 'Pillars Headline (English)',
                hintText: 'e.g. Poetry, Rhythm & Divine Grace',
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _pillarsTitleGuCtrl,
                labelText: 'Pillars Headline (Gujarati)',
                hintText: 'e.g. કવિતા, તાલ અને દિવ્ય કૃપા',
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // PILLAR CARDS LIST
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text('Sacred Pillar Cards (${widget.store.pillars.length})', style: styles.cleanSans(context, size: 14, fontWeight: FontWeight.w700)),
                  MyAppFillButton.icon(
                    onPressed: () => _openPillarDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: 'Add Card',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.store.pillars.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.getBorderColor(context)),
                  ),
                  child: Center(
                    child: Text('No pillar cards added. Click "Add Card" to create one.', style: styles.bodySmall(context)),
                  ),
                )
              else
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: widget.store.pillars.length,
                    onReorderItem: (oldIndex, newIndex) {
                      widget.store.reorderHomePillars(oldIndex, newIndex);
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      final pillar = widget.store.pillars[index];
                      return Container(
                        key: ValueKey(pillar.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.getBorderColor(context)),
                        ),
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Tooltip(
                                message: 'Drag to reorder',
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 22),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.heritageGold.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                pillar.number,
                                style: styles.devotionalMotto(context, size: 16, color: colors.heritageGold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(pillar.iconData, color: colors.getAccentColor(context), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: pillar.titleEn.isNotEmpty ? pillar.titleEn : pillar.titleGu,
                                          style: styles.bodyText(context).copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        if (pillar.titleEn.isNotEmpty && pillar.titleGu.isNotEmpty)
                                          TextSpan(
                                            text: ' (${pillar.titleGu})',
                                            style: styles.bodySmall(context).copyWith(color: colors.heritageGold),
                                          ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (pillar.descEn.isNotEmpty || pillar.descGu.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      pillar.descEn.isNotEmpty ? pillar.descEn : pillar.descGu,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Pillar',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () => _openPillarDialog(pillar),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: colors.sacredRed),
                              tooltip: 'Delete Pillar',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () => _confirmDeletePillar(pillar),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 5: VOCALISTS & MUSICIANS TROUPE (HEADER + ARTISTS CRUD)
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 620;
                  final headerButtons = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MyAppOutlineButton.icon(
                        isDanger: true,
                        onPressed: _confirmClearSingersHeader,
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: isTight ? 'Clear' : 'Clear All',
                      ),
                      MyAppFillButton.icon(
                        onPressed: _saveSingersHeader,
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: isTight ? 'Save' : 'Save Header',
                      ),
                    ],
                  );

                  if (isTight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.library_music_rounded, color: colors.heritageGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '5. Folk Vocalists & Live Orchestra Troupe',
                                style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        headerButtons,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.library_music_rounded, color: colors.heritageGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('5. Folk Vocalists & Live Orchestra Troupe', style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      headerButtons,
                    ],
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Manage Folk Vocalists carousel header and artist cards. Cleared fields or empty artist lists hide cleanly from the live website.',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              _buildLiveSingersPreview(colors, styles, isMobile),
              const SizedBox(height: 24),

              // Singers Eyebrow Tag Inputs
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _singersTagEnCtrl,
                      targetLanguageController: _singersTagGuCtrl,
                      labelText: 'Singers Eyebrow Badge (English)',
                      hintText: 'e.g. 03 / FOLK VOCALISTS & MUSICIANS',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _singersTagGuCtrl,
                      labelText: 'Singers Eyebrow Badge (Gujarati)',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _singersTagEnCtrl,
                        targetLanguageController: _singersTagGuCtrl,
                        labelText: 'Singers Eyebrow Badge (English)',
                        hintText: 'e.g. 03 / FOLK VOCALISTS & MUSICIANS',
                        showTranslateIcon: true,
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _singersTagGuCtrl,
                        labelText: 'Singers Eyebrow Badge (Gujarati)',
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Singers Headline Inputs
              MyAppTextFormField(
                controller: _singersTitleEnCtrl,
                targetLanguageController: _singersTitleGuCtrl,
                labelText: 'Singers Headline (English)',
                hintText: 'Master Vocalists & Live Orchestra',
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _singersTitleGuCtrl,
                labelText: 'Singers Headline (Gujarati)',
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Singers Subtitle/Description Inputs
              MyAppTextAreaField(
                controller: _singersDescEnCtrl,
                targetLanguageController: _singersDescGuCtrl,
                labelText: 'Singers Subtitle / Description (English)',
                hintText: 'Renowned classical Gujarati folk singers leading every divine night of Navratri...',
                showTranslateIcon: true,
                showClearIcon: true,
                minLines: 2,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              MyAppTextAreaField(
                controller: _singersDescGuCtrl,
                labelText: 'Singers Subtitle / Description (Gujarati)',
                showClearIcon: true,
                minLines: 2,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // ARTISTS LIST
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text(
                    'Troupe Artists (${widget.store.homeSingers.length})',
                    style: styles.cleanSans(context, size: 14, fontWeight: FontWeight.w700),
                  ),
                  MyAppFillButton.icon(
                    onPressed: () => _openSingerDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: 'Add Artist',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              widget.store.homeSingers.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.getBorderColor(context)),
                      ),
                      child: Center(
                        child: Text('No artist cards added. Click "Add Artist" to create one.', style: styles.bodySmall(context)),
                      ),
                    )
                  : Theme(
                      data: Theme.of(context).copyWith(
                        canvasColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: widget.store.homeSingers.length,
                        onReorderItem: (oldIndex, newIndex) {
                          widget.store.reorderHomeSingers(oldIndex, newIndex);
                          setState(() {});
                        },
                        itemBuilder: (context, index) {
                          final singer = widget.store.homeSingers[index];
                          return Container(
                            key: ValueKey(singer.id),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.getBackgroundColor(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.getBorderColor(context)),
                            ),
                            child: Row(
                              children: [
                                ReorderableDragStartListener(
                                  index: index,
                                  child: Tooltip(
                                    message: 'Drag to reorder',
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 22),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: colors.heritageGold, width: 1.5),
                                  ),
                                  child: AppCachedImage(
                                    imageUrl: singer.imageUrl,
                                    fit: BoxFit.cover,
                                    isCircle: true,
                                    memCacheWidth: 150,
                                    memCacheHeight: 150,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(singer.nameEn, style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700)),
                                      Text(
                                        singer.roleEn,
                                        style: styles.cleanSans(context, size: 12, color: colors.heritageGold, fontWeight: FontWeight.w600),
                                      ),
                                      if (singer.descEn.isNotEmpty)
                                        Text(
                                          singer.descEn,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context)),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit Artist',
                                  icon: const Icon(Icons.edit_outlined, size: 19),
                                  color: colors.heritageGold,
                                  onPressed: () => _openSingerDialog(singer),
                                ),
                                IconButton(
                                  tooltip: 'Delete Artist',
                                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                                  color: Colors.redAccent,
                                  onPressed: () => _confirmDeleteSinger(singer),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 6: ELDERS & DIGNITARIES BLESSINGS CRUD
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 620;
                  final headerButtons = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MyAppOutlineButton.icon(
                        isDanger: true,
                        onPressed: _confirmClearBlessingsHeader,
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: isTight ? 'Clear' : 'Clear All',
                      ),
                      MyAppFillButton.icon(
                        onPressed: _saveBlessingsHeader,
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: isTight ? 'Save' : 'Save Header',
                      ),
                    ],
                  );

                  if (isTight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.format_quote_rounded, color: colors.heritageGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '6. Elders & Dignitaries Blessings',
                                style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        headerButtons,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.format_quote_rounded, color: colors.heritageGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '6. Elders & Dignitaries Blessings',
                                style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      headerButtons,
                    ],
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Manage testimonial quotes and blessings from revered saints and community leaders. If no blessings exist or fields are cleared, the section hides cleanly from the website.',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              _buildLiveBlessingsPreview(colors, styles, isMobile),
              const SizedBox(height: 24),

              // Blessings Eyebrow Tag Inputs
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _blessingsTagEnCtrl,
                      targetLanguageController: _blessingsTagGuCtrl,
                      labelText: 'Blessings Eyebrow Badge (English)',
                      hintText: 'e.g. 05 / WORDS OF REVERENCE',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _blessingsTagGuCtrl,
                      labelText: 'Blessings Eyebrow Badge (Gujarati)',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _blessingsTagEnCtrl,
                        targetLanguageController: _blessingsTagGuCtrl,
                        labelText: 'Blessings Eyebrow Badge (English)',
                        hintText: 'e.g. 05 / WORDS OF REVERENCE',
                        showTranslateIcon: true,
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _blessingsTagGuCtrl,
                        labelText: 'Blessings Eyebrow Badge (Gujarati)',
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Blessings Headline Inputs
              MyAppTextFormField(
                controller: _blessingsTitleEnCtrl,
                targetLanguageController: _blessingsTitleGuCtrl,
                labelText: 'Blessings Headline (English)',
                hintText: 'e.g. Blessings from Community Elders',
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _blessingsTitleGuCtrl,
                labelText: 'Blessings Headline (Gujarati)',
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // BLESSINGS LIST
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Text(
                    'Revered Blessings (${widget.store.blessings.length})',
                    style: styles.cleanSans(context, size: 14, fontWeight: FontWeight.w700),
                  ),
                  MyAppFillButton.icon(
                    onPressed: () => _openBlessingDialog(),
                    icon: const Icon(Icons.add, size: 16),
                    label: 'Add Blessing',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.store.blessings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.getBorderColor(context)),
                  ),
                  child: Center(
                    child: Text('No blessing quotes added. Click "Add Blessing Quote" to create one.', style: styles.bodySmall(context)),
                  ),
                )
              else
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: widget.store.blessings.length,
                    onReorderItem: (oldIndex, newIndex) {
                      widget.store.reorderHomeBlessings(oldIndex, newIndex);
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      final blessing = widget.store.blessings[index];
                      return Container(
                        key: ValueKey(blessing.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.getBorderColor(context)),
                        ),
                        child: Row(
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Tooltip(
                                message: 'Drag to reorder',
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 22),
                                ),
                              ),
                            ),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: colors.heritageGold, width: 1.5),
                              ),
                              child: AppCachedImage(
                                imageUrl: blessing.photoUrl,
                                fit: BoxFit.cover,
                                isCircle: true,
                                memCacheWidth: 150,
                                memCacheHeight: 150,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: blessing.authorEn.isNotEmpty ? blessing.authorEn : blessing.authorGu,
                                          style: styles.bodyText(context).copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        if (blessing.designationEn.isNotEmpty || blessing.designationGu.isNotEmpty) ...[
                                          const TextSpan(text: ' '),
                                          TextSpan(
                                            text: '(${blessing.designationEn.isNotEmpty ? blessing.designationEn : blessing.designationGu})',
                                            style: styles.bodySmall(context).copyWith(color: colors.heritageGold),
                                          ),
                                        ],
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    blessing.quoteEn.isNotEmpty ? blessing.quoteEn : blessing.quoteGu,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Blessing',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () => _openBlessingDialog(blessing),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: colors.sacredRed),
                              tooltip: 'Delete Blessing',
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              onPressed: () => _confirmDeleteBlessing(blessing),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 7: CULTURAL STORIES & ARTICLES (BLOGS CRUD)
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 800;
                  final headerButtons = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      MyAppOutlineButton.icon(
                        isDanger: true,
                        onPressed: _clearArticlesHeader,
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: isTight ? 'Clear' : 'Clear All',
                      ),
                      MyAppFillButton.icon(
                        onPressed: _saveArticlesHeader,
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: isTight ? 'Save' : 'Save Header',
                      ),
                    ],
                  );

                  if (isTight) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_stories_rounded, color: colors.heritageGold, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '7. Cultural Stories & Articles (Blogs)',
                                style: styles.editorialSerif(context, size: isMobile ? 17 : 18, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        headerButtons,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.auto_stories_rounded, color: colors.heritageGold, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '7. Cultural Stories & Articles (Blogs)',
                                style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      headerButtons,
                    ],
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Manage the cultural stories, folklore essays, and heritage reflections displayed on the homepage. All changes are published directly to the live website.',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              _buildLiveArticlesPreview(colors, styles, isMobile),
              const SizedBox(height: 24),

              // Eyebrow Badge Inputs
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _articlesTagEnCtrl,
                      targetLanguageController: _articlesTagGuCtrl,
                      labelText: 'Eyebrow Badge (English)',
                      hintText: 'e.g. 07 / CULTURAL STORIES & ARTICLES',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _articlesTagGuCtrl,
                      labelText: 'Eyebrow Badge (Gujarati)',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _articlesTagEnCtrl,
                        targetLanguageController: _articlesTagGuCtrl,
                        labelText: 'Eyebrow Badge (English)',
                        hintText: 'e.g. 07 / CULTURAL STORIES & ARTICLES',
                        showTranslateIcon: true,
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _articlesTagGuCtrl,
                        labelText: 'Eyebrow Badge (Gujarati)',
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 14),

              // Title Headline Inputs
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _articlesTitleEnCtrl,
                      targetLanguageController: _articlesTitleGuCtrl,
                      labelText: 'Section Main Headline (English)',
                      hintText: 'e.g. Heritage, Meaning & Reflections',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _articlesTitleGuCtrl,
                      labelText: 'Section Main Headline (Gujarati)',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _articlesTitleEnCtrl,
                        targetLanguageController: _articlesTitleGuCtrl,
                        labelText: 'Section Main Headline (English)',
                        hintText: 'e.g. Heritage, Meaning & Reflections',
                        showTranslateIcon: true,
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _articlesTitleGuCtrl,
                        labelText: 'Section Main Headline (Gujarati)',
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Articles CRUD Sub-section
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_books_rounded, size: 18, color: colors.heritageGold),
                      const SizedBox(width: 8),
                      Text(
                        'Homepage Cultural Articles (${widget.store.blogs.length})',
                        style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  MyAppFillButton.icon(
                    onPressed: () => _openArticleDialog(),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: 'Add Article',
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (widget.store.blogs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.getCardBackgroundColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.getBorderColor(context)),
                  ),
                  child: Center(
                    child: Text(
                      'No cultural articles found. Click "Add Article" above to create one.',
                      style: styles.cleanSans(context, size: 13, color: colors.getSecondaryTextColor(context)),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final art in widget.store.blogs)
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                        decoration: BoxDecoration(
                          color: colors.getCardBackgroundColor(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
                        ),
                        child: LayoutBuilder(
                          builder: (context, cardConstraints) {
                            final isCardTight = cardConstraints.maxWidth < 480;

                            final badges = Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.getAccentColor(context).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    art.category.isNotEmpty ? art.category.toUpperCase() : 'HERITAGE ARTICLE',
                                    style: styles.eyebrow(context).copyWith(fontSize: 10, color: colors.getAccentColor(context)),
                                  ),
                                ),
                                if (art.readTime.isNotEmpty)
                                  Text(
                                    art.readTime,
                                    style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: art.isPublished ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    art.isPublished ? 'PUBLISHED' : 'DRAFT',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: art.isPublished ? Colors.green : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            );

                            final actionButtons = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: 'Edit Article',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _openArticleDialog(art),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, size: 18, color: colors.sacredRed),
                                  tooltip: 'Delete Article',
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _confirmDeleteArticle(art),
                                ),
                              ],
                            );

                            if (isCardTight) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: colors.heritageGold.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.menu_book_rounded, color: colors.heritageGold, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: badges),
                                      actionButtons,
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    art.title.isNotEmpty ? art.title : art.titleGu,
                                    style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                                  ),
                                  if (art.titleGu.isNotEmpty && art.title.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      art.titleGu,
                                      style: styles.cleanSans(context, size: 12, color: colors.heritageGold, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Text(
                                    art.snippet.isNotEmpty ? art.snippet : art.snippetGu,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context), fontSize: 12),
                                  ),
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colors.heritageGold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.menu_book_rounded, color: colors.heritageGold, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      badges,
                                      const SizedBox(height: 6),
                                      Text(
                                        art.title.isNotEmpty ? art.title : art.titleGu,
                                        style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                                      ),
                                      if (art.titleGu.isNotEmpty && art.title.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          art.titleGu,
                                          style: styles.cleanSans(context, size: 13, color: colors.heritageGold, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Text(
                                        art.snippet.isNotEmpty ? art.snippet : art.snippetGu,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                actionButtons,
                              ],
                            );
                          },
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 8: CULTURAL CALL-TO-ACTION BANNER
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign_rounded, color: colors.heritageGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '8. Cultural Call-To-Action Banner',
                            style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: MyAppOutlineButton.icon(
                            isDanger: true,
                            onPressed: _clearCtaBanner,
                            icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                            label: 'Clear Banner',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MyAppFillButton.icon(
                            onPressed: _saveCtaBanner,
                            icon: const Icon(Icons.save_rounded, size: 16),
                            label: 'Save Banner',
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.campaign_rounded, color: colors.heritageGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '8. Cultural Call-To-Action Banner',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MyAppOutlineButton.icon(
                          isDanger: true,
                          onPressed: _clearCtaBanner,
                          icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                          label: 'Clear Banner',
                        ),
                        const SizedBox(width: 8),
                        MyAppFillButton.icon(
                          onPressed: _saveCtaBanner,
                          icon: const Icon(Icons.save_rounded, size: 16),
                          label: 'Save Banner',
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 6),
              Text(
                'Manage the bottom Call-To-Action banner. Full control over invocation chant, motto, button text, and destination page. Cleared banner hides completely.',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 18),
              _buildLiveCtaPreview(colors, styles),
              const SizedBox(height: 24),

              // Invocation Inputs
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _ctaInvocationEnCtrl,
                      targetLanguageController: _ctaInvocationGuCtrl,
                      labelText: 'Sacred Invocation / Chant (English)',
                      hintText: 'e.g. || JAgti Jogmaya ||',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _ctaInvocationGuCtrl,
                      labelText: 'Sacred Invocation / Chant (Gujarati)',
                      hintText: 'e.g. || જાગતી જોગમાયા ||',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _ctaInvocationEnCtrl,
                        targetLanguageController: _ctaInvocationGuCtrl,
                        labelText: 'Sacred Invocation / Chant (English)',
                        hintText: 'e.g. || JAgti Jogmaya ||',
                        showTranslateIcon: true,
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _ctaInvocationGuCtrl,
                        labelText: 'Sacred Invocation / Chant (Gujarati)',
                        hintText: 'e.g. || જાગતી જોગમાયા ||',
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              // Motto Inputs
              MyAppTextFormField(
                controller: _ctaMottoEnCtrl,
                targetLanguageController: _ctaMottoGuCtrl,
                labelText: 'Banner Motto / Inspiring Heading (English)',
                hintText: 'Experience the Devotion, Sacred Echoes & Joy of Traditional Garbi.',
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _ctaMottoGuCtrl,
                labelText: 'Banner Motto / Inspiring Heading (Gujarati)',
                hintText: 'ભક્તિ, આસ્થા અને પવિત્ર સંસ્કૃતિના સાક્ષી બનો.',
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              // Button Text & Route
              if (isMobile)
                Column(
                  children: [
                    MyAppTextFormField(
                      controller: _ctaBtnTextEnCtrl,
                      targetLanguageController: _ctaBtnTextGuCtrl,
                      labelText: 'Button Label (English)',
                      hintText: 'Connect With Mandal',
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: _ctaBtnTextGuCtrl,
                      labelText: 'Button Label (Gujarati)',
                      hintText: 'સંપર્ક કરો',
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    _buildDestinationPageSelector(
                      routeCtrl: _ctaBtnRouteCtrl,
                      colors: colors,
                      styles: styles,
                      defaultRoute: '/contact',
                      labelText: 'CTA Button Destination Page (કયા પેજ પર જવું)',
                      helperText: 'Select which website page opens when visitors click this CTA banner button',
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MyAppTextFormField(
                            controller: _ctaBtnTextEnCtrl,
                            targetLanguageController: _ctaBtnTextGuCtrl,
                            labelText: 'Button Label (English)',
                            hintText: 'Connect With Mandal',
                            showTranslateIcon: true,
                            showClearIcon: true,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyAppTextFormField(
                            controller: _ctaBtnTextGuCtrl,
                            labelText: 'Button Label (Gujarati)',
                            hintText: 'સંપર્ક કરો',
                            showClearIcon: true,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDestinationPageSelector(
                      routeCtrl: _ctaBtnRouteCtrl,
                      colors: colors,
                      styles: styles,
                      defaultRoute: '/contact',
                      labelText: 'CTA Button Destination Page (કયા પેજ પર જવું)',
                      helperText: 'Select which website page opens when visitors click this CTA banner button',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. Website & Mandal Title (Global Brand Header & Meta)
        _buildDualLanguageField(
          title: '0. Mandal Name / Website Title (Global Brand Header & Meta)',
          enLabel: 'Mandal Brand Name (English)',
          enCtrl: _appTitleEnCtrl,
          guLabel: 'મંડળનું સત્તાવાર નામ (ગુજરાતી)',
          guCtrl: _appTitleGuCtrl,
          hintText: 'Pavan Putra Garbi Mandal',
        ),

        // 1. Sacred Invocation Badge (Top Left Pill)
        _buildDualLanguageField(
          title: '1. Sacred Invocation Badge (Top Left Pill)',
          enLabel: 'Invocation Text (English)',
          enCtrl: _sacredInvocationEnCtrl,
          guLabel: 'આવાહન મંત્ર (ગુજરાતી)',
          guCtrl: _sacredInvocationGuCtrl,
          hintText: '|| ૐ નમો ભગવતે ||',
        ),

        // 2. Tradition / Tagline Badge (Top Right Pill)
        _buildDualLanguageField(
          title: '2. Tradition & Heritage Badge (Top Right Pill)',
          enLabel: 'Heritage Tagline (English)',
          enCtrl: _heroTagBadgeEnCtrl,
          guLabel: 'પરંપરા બિરુદ (ગુજરાતી)',
          guCtrl: _heroTagBadgeGuCtrl,
          hintText: 'RAJKOT / SAURASHTRA / FOLK HERITAGE',
        ),

        // 3. Hero Main Headline
        _buildDualLanguageField(
          title: '3. Hero Headline (Grand Editorial Title)',
          enLabel: 'Headline (English)',
          enCtrl: _heroTitleEnCtrl,
          guLabel: 'મુખ્ય શીર્ષક (ગુજરાતી)',
          guCtrl: _heroTitleGuCtrl,
          hintText: 'The Living Legacy of\nPrachin Garbi.',
          maxLines: 2,
        ),

        // 4. Sacred Devotional Motto
        _buildDualLanguageField(
          title: '4. Sacred Devotional Motto',
          enLabel: 'Devotional Motto (English)',
          enCtrl: _heroMottoEnCtrl,
          guLabel: 'ભક્તિ સૂત્ર (ગુજરાતી)',
          guCtrl: _heroMottoGuCtrl,
          hintText: '|| જાગતી જોગમાયા || પરંપરા • ભક્તિ • સૂર',
        ),

        // 5. Hero Description Paragraph
        _buildDualLanguageField(
          title: '5. Hero Introduction Paragraph',
          enLabel: 'Story / Overview (English)',
          enCtrl: _heroDescEnCtrl,
          guLabel: 'પરિચય વિગત (ગુજરાતી)',
          guCtrl: _heroDescGuCtrl,
          hintText: 'Since 1989 in Rajkot, Shree Pavan Putra Prachin Garbi Mandal...',
          maxLines: 3,
        ),

        // 6. Primary Action Button
        _buildButtonConfigField(
          title: '6. Primary Action Button',
          labelEnCtrl: _heroCtaArchiveEnCtrl,
          labelGuCtrl: _heroCtaArchiveGuCtrl,
          routeCtrl: _heroCtaArchiveRouteCtrl,
        ),

        // 7. Secondary Action Button
        _buildButtonConfigField(
          title: '7. Secondary Action Button',
          labelEnCtrl: _heroCtaAboutEnCtrl,
          labelGuCtrl: _heroCtaAboutGuCtrl,
          routeCtrl: _heroCtaAboutRouteCtrl,
        ),

        // 8. Bottom Official Archival Badge
        _buildDualLanguageField(
          title: '8. Official Archival Badge (Bottom Accent Row)',
          enLabel: 'Archival Tag (English)',
          enCtrl: _heroBottomBadgeEnCtrl,
          guLabel: 'સત્તાવાર આર્કાઇવ બિરુદ (ગુજરાતી)',
          guCtrl: _heroBottomBadgeGuCtrl,
          hintText: 'OFFICIAL CULTURAL HERITAGE ARCHIVE',
        ),
      ],
    );
  }

  Widget _buildDualLanguageField({
    required String title,
    required String enLabel,
    required TextEditingController enCtrl,
    required String guLabel,
    required TextEditingController guCtrl,
    int maxLines = 1,
    String? hintText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              if (enCtrl.text.isNotEmpty || guCtrl.text.isNotEmpty)
                MyAppTextButton.icon(
                  isDanger: true,
                  isCompact: true,
                  onPressed: () {
                    setState(() {
                      enCtrl.clear();
                      guCtrl.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_rounded),
                  label: 'Clear',
                ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 520;
              final enField = maxLines > 1
                  ? MyAppTextAreaField(
                      controller: enCtrl,
                      targetLanguageController: guCtrl,
                      labelText: enLabel,
                      hintText: hintText,
                      minLines: maxLines,
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    )
                  : MyAppTextFormField(
                      controller: enCtrl,
                      targetLanguageController: guCtrl,
                      labelText: enLabel,
                      hintText: hintText,
                      showTranslateIcon: true,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    );

              final guField = maxLines > 1
                  ? MyAppTextAreaField(
                      controller: guCtrl,
                      labelText: guLabel,
                      hintText: hintText,
                      minLines: maxLines,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    )
                  : MyAppTextFormField(
                      controller: guCtrl,
                      labelText: guLabel,
                      hintText: hintText,
                      showClearIcon: true,
                      onChanged: (_) => setState(() {}),
                    );

              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: enField),
                        const SizedBox(width: 12),
                        Expanded(child: guField),
                      ],
                    )
                  : Column(children: [enField, const SizedBox(height: 10), guField]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtonConfigField({
    required String title,
    required TextEditingController labelEnCtrl,
    required TextEditingController labelGuCtrl,
    required TextEditingController routeCtrl,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final defaultRoute = title.toLowerCase().contains('secondary') ? '/about' : '/archive';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              ),
              if (labelEnCtrl.text.isNotEmpty || labelGuCtrl.text.isNotEmpty)
                MyAppTextButton.icon(
                  isDanger: true,
                  isCompact: true,
                  onPressed: () {
                    setState(() {
                      labelEnCtrl.clear();
                      labelGuCtrl.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_rounded),
                  label: 'Clear',
                ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 520;
              final enField = MyAppTextFormField(
                controller: labelEnCtrl,
                targetLanguageController: labelGuCtrl,
                labelText: 'Label (English)',
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              );

              final guField = MyAppTextFormField(
                controller: labelGuCtrl,
                labelText: 'નામ (ગુજરાતી)',
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              );

              final destinationDropdown = _buildDestinationPageSelector(
                routeCtrl: routeCtrl,
                colors: colors,
                styles: styles,
                defaultRoute: defaultRoute,
                labelText: 'Destination Page to Open (કયા પેજ પર જવું)',
                helperText: 'Select which website page visitors explore when clicking this button',
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isWide
                      ? Row(
                          children: [
                            Expanded(child: enField),
                            const SizedBox(width: 12),
                            Expanded(child: guField),
                          ],
                        )
                      : Column(children: [enField, const SizedBox(height: 10), guField]),
                  const SizedBox(height: 12),
                  destinationDropdown,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationPageSelector({
    required TextEditingController routeCtrl,
    required MyAppColors colors,
    required MyAppTextStyles styles,
    String? defaultRoute,
    String labelText = 'Destination Page to Open (કયા પેજ પર જવું)',
    String helperText = 'Select which website page visitors explore when clicking this button',
  }) {
    return MyAppDropdown.pageDestination(
      controller: routeCtrl,
      defaultRoute: defaultRoute ?? '/archive',
      labelText: labelText,
      hintText: helperText,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildLiveHeroPreviewCard(MyAppColors colors, MyAppTextStyles styles) {
    final isGu = _previewLang == 'gu';
    final invocation = isGu ? _sacredInvocationGuCtrl.text.trim() : _sacredInvocationEnCtrl.text.trim();
    final tagBadge = isGu ? _heroTagBadgeGuCtrl.text.trim() : _heroTagBadgeEnCtrl.text.trim();
    final title = isGu ? _heroTitleGuCtrl.text.trim() : _heroTitleEnCtrl.text.trim();
    final motto = isGu ? _heroMottoGuCtrl.text.trim() : _heroMottoEnCtrl.text.trim();
    final desc = isGu ? _heroDescGuCtrl.text.trim() : _heroDescEnCtrl.text.trim();
    final cta1 = isGu ? _heroCtaArchiveGuCtrl.text.trim() : _heroCtaArchiveEnCtrl.text.trim();
    final cta2 = isGu ? _heroCtaAboutGuCtrl.text.trim() : _heroCtaAboutEnCtrl.text.trim();
    final bottomBadge = isGu ? _heroBottomBadgeGuCtrl.text.trim() : _heroBottomBadgeEnCtrl.text.trim();
    final hasImg = _heroImageUrl.trim().isNotEmpty;

    final hasAny =
        invocation.isNotEmpty ||
        tagBadge.isNotEmpty ||
        title.isNotEmpty ||
        motto.isNotEmpty ||
        desc.isNotEmpty ||
        cta1.isNotEmpty ||
        cta2.isNotEmpty ||
        bottomBadge.isNotEmpty ||
        hasImg;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B0306),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 380;
              final langSelector = MyAppSegmentView.language(
                selectedLanguage: _previewLang,
                onLanguageChanged: (val) => setState(() => _previewLang = val),
              );

              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility_rounded, color: colors.heritageGold, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Live Preview',
                            style: styles.editorialSerif(context, size: 13, fontWeight: FontWeight.w700, color: colors.lightGold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    langSelector,
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.visibility_rounded, color: colors.heritageGold, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Live Preview',
                      style: styles.editorialSerif(context, size: 13, fontWeight: FontWeight.w700, color: colors.lightGold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  langSelector,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          if (!hasAny)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                'All fields are empty.\nHero section will be hidden on public website.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            )
          else ...[
            if (invocation.isNotEmpty || tagBadge.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (invocation.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2B070B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        invocation,
                        style: TextStyle(color: colors.lightGold, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (tagBadge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        tagBadge,
                        style: const TextStyle(color: Color(0xFFE8E4DA), fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 6),
            ],
            if (motto.isNotEmpty) ...[
              Text(
                motto,
                style: TextStyle(color: colors.lightGold, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
            ],
            if (desc.isNotEmpty) ...[
              Text(
                desc,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFD6D1C4), fontSize: 11, height: 1.4),
              ),
              const SizedBox(height: 10),
            ],
            if (cta1.isNotEmpty || cta2.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (cta1.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: colors.heritageMaroon, borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            cta1,
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  if (cta2.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            cta2,
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            if (bottomBadge.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors.heritageGold),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    bottomBadge,
                    style: TextStyle(color: colors.heritageGold, fontSize: 9.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String statNumber,
    required String statName,
    required IconData icon,
    required String titleHint,
    required String descHint,
    required TextEditingController titleEnCtrl,
    required TextEditingController titleGuCtrl,
    required TextEditingController descEnCtrl,
    required TextEditingController descGuCtrl,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final hasAny = titleEnCtrl.text.isNotEmpty ||
        titleGuCtrl.text.isNotEmpty ||
        descEnCtrl.text.isNotEmpty ||
        descGuCtrl.text.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.getAccentColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: colors.getAccentColor(context), size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stat $statNumber: $statName',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              if (hasAny)
                MyAppTextButton.icon(
                  isDanger: true,
                  isCompact: true,
                  onPressed: () {
                    setState(() {
                      titleEnCtrl.clear();
                      titleGuCtrl.clear();
                      descEnCtrl.clear();
                      descGuCtrl.clear();
                    });
                  },
                  icon: const Icon(Icons.clear_rounded, size: 14),
                  label: 'Clear',
                ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 380;
              final tEnField = MyAppTextFormField(
                controller: titleEnCtrl,
                targetLanguageController: titleGuCtrl,
                labelText: 'Title (English)',
                hintText: titleHint,
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              );
              final tGuField = MyAppTextFormField(
                controller: titleGuCtrl,
                labelText: 'શીર્ષક (ગુજરાતી)',
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              );

              return isWide
                  ? Row(
                      children: [
                        Expanded(child: tEnField),
                        const SizedBox(width: 10),
                        Expanded(child: tGuField),
                      ],
                    )
                  : Column(
                      children: [
                        tEnField,
                        const SizedBox(height: 8),
                        tGuField,
                      ],
                    );
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 380;
              final dEnField = MyAppTextAreaField(
                controller: descEnCtrl,
                targetLanguageController: descGuCtrl,
                labelText: 'Description (English)',
                hintText: descHint,
                showTranslateIcon: true,
                showClearIcon: true,
                minLines: 1,
                onChanged: (_) => setState(() {}),
              );
              final dGuField = MyAppTextAreaField(
                controller: descGuCtrl,
                labelText: 'વિગત (ગુજરાતી)',
                showClearIcon: true,
                minLines: 1,
                onChanged: (_) => setState(() {}),
              );

              return isWide
                  ? Row(
                      children: [
                        Expanded(child: dEnField),
                        const SizedBox(width: 10),
                        Expanded(child: dGuField),
                      ],
                    )
                  : Column(
                      children: [
                        dEnField,
                        const SizedBox(height: 8),
                        dGuField,
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStatsPreviewCard(MyAppColors colors, MyAppTextStyles styles) {
    final isGu = _statsPreviewLang == 'gu';

    String getT(TextEditingController en, TextEditingController gu) {
      final e = en.text.trim();
      final g = gu.text.trim();
      return isGu ? (g.isNotEmpty ? g : e) : (e.isNotEmpty ? e : g);
    }

    String getD(TextEditingController en, TextEditingController gu) {
      final e = en.text.trim();
      final g = gu.text.trim();
      return isGu ? (g.isNotEmpty ? g : e) : (e.isNotEmpty ? e : g);
    }

    final s1T = getT(_stat1TitleEnCtrl, _stat1TitleGuCtrl);
    final s1D = getD(_stat1DescEnCtrl, _stat1DescGuCtrl);
    final s2T = getT(_stat2TitleEnCtrl, _stat2TitleGuCtrl);
    final s2D = getD(_stat2DescEnCtrl, _stat2DescGuCtrl);
    final s3T = getT(_stat3TitleEnCtrl, _stat3TitleGuCtrl);
    final s3D = getD(_stat3DescEnCtrl, _stat3DescGuCtrl);
    final s4T = getT(_stat4TitleEnCtrl, _stat4TitleGuCtrl);
    final s4D = getD(_stat4DescEnCtrl, _stat4DescGuCtrl);

    final rawStats = [
      (s1T, s1D, Icons.auto_stories_rounded),
      (s2T, s2D, Icons.music_note_rounded),
      (s3T, s3D, Icons.local_fire_department_rounded),
      (s4T, s4D, Icons.history_rounded),
    ];

    final activeStats = rawStats.where((s) => s.$1.isNotEmpty || s.$2.isNotEmpty).take(2).toList();

    return Container(
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.getBorderColor(context)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 420;
              final langSelector = MyAppSegmentView.language(
                selectedLanguage: _statsPreviewLang,
                onLanguageChanged: (val) => setState(() => _statsPreviewLang = val),
              );

              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility_rounded, color: colors.heritageGold, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Live Stats Strip Preview',
                            style: styles.editorialSerif(context, size: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    langSelector,
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.visibility_rounded, color: colors.heritageGold, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Live Stats Strip Preview',
                      style: styles.editorialSerif(context, size: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  langSelector,
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          if (activeStats.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'All 4 stats are empty.\nThe highlights strip will be completely hidden on public website.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.getMutedTextColor(context), fontSize: 11),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return isWide
                    ? Row(
                        children: [
                          for (int i = 0; i < activeStats.length; i++) ...[
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: colors.getAccentColor(context).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
                                    ),
                                    child: Icon(activeStats[i].$3, color: colors.getAccentColor(context), size: 17),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (activeStats[i].$1.isNotEmpty)
                                          Text(
                                            activeStats[i].$1,
                                            style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (activeStats[i].$2.isNotEmpty)
                                          Text(
                                            activeStats[i].$2,
                                            style: styles.cleanSans(context, size: 10.5, color: colors.getMutedTextColor(context)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (i < activeStats.length - 1)
                              Container(
                                height: 38,
                                width: 1,
                                color: colors.getBorderColor(context),
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                          ],
                        ],
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < activeStats.length; i++) ...[
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: colors.getAccentColor(context).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
                                  ),
                                  child: Icon(activeStats[i].$3, color: colors.getAccentColor(context), size: 17),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (activeStats[i].$1.isNotEmpty)
                                        Text(
                                          activeStats[i].$1,
                                          style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                                        ),
                                      if (activeStats[i].$2.isNotEmpty)
                                        Text(
                                          activeStats[i].$2,
                                          style: styles.cleanSans(context, size: 10.5, color: colors.getMutedTextColor(context)),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (i < activeStats.length - 1) Divider(color: colors.getBorderColor(context), height: 16),
                          ],
                        ],
                      );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLiveAboutPreview(MyAppColors colors, MyAppTextStyles styles, bool isMobile) {
    final lang = _aboutPreviewLang;
    final tag = lang == 'gu' ? _sec1TagGuCtrl.text.trim() : _sec1TagEnCtrl.text.trim();
    final title = lang == 'gu' ? _sec1TitleGuCtrl.text.trim() : _sec1TitleEnCtrl.text.trim();
    final desc = lang == 'gu' ? _sec1DescGuCtrl.text.trim() : _sec1DescEnCtrl.text.trim();
    final aarti = lang == 'gu' ? _aartiAnnounceGuCtrl.text.trim() : _aartiAnnounceCtrl.text.trim();
    final cards = widget.store.aboutCards.where((c) => c.isActive).take(2).toList();

    final isSectionEmpty = tag.isEmpty && title.isEmpty && desc.isEmpty && cards.isEmpty && aarti.isEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 420;
              final langSelector = MyAppSegmentView.language(
                selectedLanguage: _aboutPreviewLang,
                onLanguageChanged: (val) => setState(() => _aboutPreviewLang = val),
              );

              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility_rounded, size: 16, color: colors.heritageGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Live Website Preview (as seen by public visitors)',
                            style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600).copyWith(color: colors.heritageGold, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    langSelector,
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.visibility_rounded, size: 16, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Website Preview (as seen by public visitors)',
                      style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600).copyWith(color: colors.heritageGold, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  langSelector,
                ],
              );
            },
          ),
          const Divider(height: 20),
          if (isSectionEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Section is currently empty. It is completely hidden on the public website.',
                  style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context), fontStyle: FontStyle.italic),
                ),
              ),
            )
          else ...[
            if (tag.isNotEmpty) ...[
              HeritageBadge(label: tag),
              const SizedBox(height: 12),
            ],
            if (title.isNotEmpty || desc.isNotEmpty) ...[
              if (isMobile) ...[
                if (title.isNotEmpty) Text(title, style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.bold)),
                if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(height: 10),
                if (desc.isNotEmpty) Text(desc, style: styles.bodySmall(context).copyWith(height: 1.6)),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Expanded(
                        flex: 5,
                        child: Text(title, style: styles.editorialSerif(context, size: 24, fontWeight: FontWeight.bold)),
                      ),
                    if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(width: 24),
                    if (desc.isNotEmpty)
                      Expanded(
                        flex: title.isNotEmpty ? 6 : 1,
                        child: Text(desc, style: styles.bodySmall(context).copyWith(height: 1.6)),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
            ],
            if (cards.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final int crossAxisCount = width < 560 ? 1 : 2;
                  const double spacing = 12;

                  if (crossAxisCount == 1) {
                    return Column(
                      children: [
                        for (int i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(height: 12),
                          _buildPreviewCard(cards[i], lang, colors, styles),
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
                          child: _buildPreviewCard(card, lang, colors, styles),
                        ),
                    ],
                  );
                },
              ),
            if (aarti.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.heritageGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.brightness_high_rounded, color: colors.heritageGold, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        aarti,
                        style: styles.bodySmall(context).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewCard(AdminAboutCard card, String lang, MyAppColors colors, MyAppTextStyles styles) {
    final cTitle = card.getTitle(lang);
    final cDesc = card.getDesc(lang);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.getBorderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.getAccentColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(card.iconData, color: colors.getAccentColor(context), size: 18),
          ),
          if (cTitle.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(cTitle, style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700)),
          ],
          if (cDesc.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(cDesc, style: styles.bodySmall(context).copyWith(fontSize: 12, height: 1.45, color: colors.getSecondaryTextColor(context))),
          ],
        ],
      ),
    );
  }

  // LIVE WEBSITE PREVIEW FOR PILLARS (02 / SACRED FOUNDATIONS)
  Widget _buildLivePillarsPreview(MyAppColors colors, MyAppTextStyles styles, bool isMobile) {
    final isDark = colors.isDarkMode(context);
    final tag = _selectedPreviewLang == 'gu'
        ? (_pillarsTagGuCtrl.text.isNotEmpty ? _pillarsTagGuCtrl.text : _pillarsTagEnCtrl.text)
        : (_pillarsTagEnCtrl.text.isNotEmpty ? _pillarsTagEnCtrl.text : _pillarsTagGuCtrl.text);

    final title = _selectedPreviewLang == 'gu'
        ? (_pillarsTitleGuCtrl.text.isNotEmpty ? _pillarsTitleGuCtrl.text : _pillarsTitleEnCtrl.text)
        : (_pillarsTitleEnCtrl.text.isNotEmpty ? _pillarsTitleEnCtrl.text : _pillarsTitleGuCtrl.text);

    final hasContent = tag.isNotEmpty || title.isNotEmpty || widget.store.pillars.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 450;
              final langToggle = MyAppSegmentView.language(
                selectedLanguage: _selectedPreviewLang,
                onLanguageChanged: (val) => setState(() => _selectedPreviewLang = val),
              );

              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_rounded, size: 16, color: colors.getAccentColor(context)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Live Website Preview (Sacred Foundations)',
                            style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    langToggle,
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.remove_red_eye_rounded, size: 16, color: colors.getAccentColor(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Website Preview (Sacred Foundations)',
                      style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  langToggle,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (!hasContent)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'Section hidden on live website (all fields are empty)',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
            )
          else ...[
            if (tag.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? colors.heritageMaroon.withValues(alpha: 0.3) : const Color(0xFFF5EBE6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? colors.heritageGold.withValues(alpha: 0.4) : const Color(0xFFD9B9AE)),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isDark ? colors.lightGold : const Color(0xFF6B2D24),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: styles.editorialSerif(context, size: 24, fontWeight: FontWeight.w700, color: colors.getPrimaryTextColor(context)),
              ),
              const SizedBox(height: 20),
            ],
            if (widget.store.pillars.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final int crossAxisCount = width < 560 ? 1 : 2;
                  const double spacing = 14;

                  final previewPillars = widget.store.pillars.take(2).toList();
                  final cards = previewPillars.map((pillar) {
                    final pTitle = pillar.getTitle(_selectedPreviewLang);
                    final pDesc = pillar.getDesc(_selectedPreviewLang);
                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.getCardBackgroundColor(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.getBorderColor(context), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pillar.number,
                                style: styles.devotionalMotto(context, size: 22, color: colors.heritageGold),
                              ),
                              Icon(pillar.iconData, size: 20, color: colors.getAccentColor(context)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (pTitle.isNotEmpty)
                            Text(
                              pTitle,
                              style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700, color: colors.getPrimaryTextColor(context)),
                            ),
                          if (pDesc.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              pDesc,
                              style: styles.bodySmall(context).copyWith(
                                color: colors.getSecondaryTextColor(context),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList();

                  if (crossAxisCount == 1) {
                    return Column(
                      children: [
                        for (int i = 0; i < cards.length; i++) ...[
                          if (i > 0) const SizedBox(height: 14),
                          cards[i],
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
                          child: card,
                        ),
                    ],
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  // LIVE WEBSITE PREVIEW FOR FOLK VOCALISTS & MUSICIANS (MAX 2 ITEMS)
  Widget _buildLiveSingersPreview(MyAppColors colors, MyAppTextStyles styles, bool isMobile) {
    final isDark = colors.isDarkMode(context);
    final tag = _selectedPreviewLang == 'gu'
        ? (_singersTagGuCtrl.text.isNotEmpty ? _singersTagGuCtrl.text : _singersTagEnCtrl.text)
        : (_singersTagEnCtrl.text.isNotEmpty ? _singersTagEnCtrl.text : _singersTagGuCtrl.text);

    final title = _selectedPreviewLang == 'gu'
        ? (_singersTitleGuCtrl.text.isNotEmpty ? _singersTitleGuCtrl.text : _singersTitleEnCtrl.text)
        : (_singersTitleEnCtrl.text.isNotEmpty ? _singersTitleEnCtrl.text : _singersTitleGuCtrl.text);

    final desc = _selectedPreviewLang == 'gu'
        ? (_singersDescGuCtrl.text.isNotEmpty ? _singersDescGuCtrl.text : _singersDescEnCtrl.text)
        : (_singersDescEnCtrl.text.isNotEmpty ? _singersDescEnCtrl.text : _singersDescGuCtrl.text);

    final previewSingers = widget.store.homeSingers.take(2).toList();
    final hasContent = tag.isNotEmpty || title.isNotEmpty || previewSingers.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 450;
              final langToggle = MyAppSegmentView.language(
                selectedLanguage: _selectedPreviewLang,
                onLanguageChanged: (val) => setState(() => _selectedPreviewLang = val),
              );

              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_rounded, size: 16, color: colors.getAccentColor(context)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Live Website Preview (Troupe Artists)',
                            style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    langToggle,
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.remove_red_eye_rounded, size: 18, color: colors.getAccentColor(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Website Preview (Troupe Artists)',
                      style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  langToggle,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (!hasContent)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                'Section 5 is currently cleared or empty.\nIt will hide completely on the live website.',
                textAlign: TextAlign.center,
                style: styles.bodySmall(context).copyWith(color: colors.getMutedTextColor(context)),
              ),
            )
          else ...[
            if (tag.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? colors.heritageMaroon.withValues(alpha: 0.3) : const Color(0xFFF5EBE6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? colors.heritageGold.withValues(alpha: 0.4) : const Color(0xFFD9B9AE)),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isDark ? colors.lightGold : const Color(0xFF6B2D24),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: styles.editorialSerif(context, size: 24, fontWeight: FontWeight.w700, color: colors.getPrimaryTextColor(context)),
              ),
              const SizedBox(height: 8),
            ],
            if (desc.isNotEmpty) ...[
              Text(
                desc,
                style: styles.cleanSans(context, size: 13, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 20),
            ],
            if (previewSingers.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final cards = previewSingers.map((s) {
                    final isGu = _selectedPreviewLang == 'gu';
                    final name = isGu && s.nameGu.isNotEmpty ? s.nameGu : s.nameEn;
                    final role = isGu && s.roleGu.isNotEmpty ? s.roleGu : s.roleEn;
                    final sDesc = isGu && s.descGu.isNotEmpty ? s.descGu : s.descEn;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.getCardBackgroundColor(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.getBorderColor(context), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: AppCachedImage(
                                imageUrl: s.imageUrl,
                                fit: BoxFit.cover,
                                memCacheWidth: 150,
                                memCacheHeight: 150,
                                fallbackWidget: Container(
                                  color: colors.heritageGold.withValues(alpha: 0.15),
                                  child: Icon(Icons.person, color: colors.heritageGold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(name, style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700)),
                                if (role.isNotEmpty)
                                  Text(
                                    role,
                                    style: styles.cleanSans(context, size: 11.5, color: colors.heritageGold, fontWeight: FontWeight.w600),
                                  ),
                                if (sDesc.isNotEmpty)
                                  Text(
                                    sDesc,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();

                  if (isWide && cards.length == 2) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: cards[0]),
                        const SizedBox(width: 14),
                        Expanded(child: cards[1]),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      for (int i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        cards[i],
                      ],
                    ],
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  // LIVE WEBSITE PREVIEW FOR BLESSINGS
  Widget _buildLiveBlessingsPreview(MyAppColors colors, MyAppTextStyles styles, bool isMobile) {
    final isDark = colors.isDarkMode(context);
    final tag = _selectedPreviewLang == 'gu'
        ? (_blessingsTagGuCtrl.text.isNotEmpty ? _blessingsTagGuCtrl.text : _blessingsTagEnCtrl.text)
        : (_blessingsTagEnCtrl.text.isNotEmpty ? _blessingsTagEnCtrl.text : _blessingsTagGuCtrl.text);

    final title = _selectedPreviewLang == 'gu'
        ? (_blessingsTitleGuCtrl.text.isNotEmpty ? _blessingsTitleGuCtrl.text : _blessingsTitleEnCtrl.text)
        : (_blessingsTitleEnCtrl.text.isNotEmpty ? _blessingsTitleEnCtrl.text : _blessingsTitleGuCtrl.text);

    final hasContent = tag.isNotEmpty || title.isNotEmpty || widget.store.blessings.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 450;
              final langToggle = MyAppSegmentView.language(
                selectedLanguage: _selectedPreviewLang,
                onLanguageChanged: (val) => setState(() => _selectedPreviewLang = val),
              );

              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_rounded, size: 16, color: colors.getAccentColor(context)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Live Website Preview (Elders Blessings)',
                            style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    langToggle,
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.remove_red_eye_rounded, size: 16, color: colors.getAccentColor(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Live Website Preview (Elders Blessings)',
                      style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  langToggle,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          if (!hasContent)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'Section hidden on live website (all fields are empty)',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
            )
          else ...[
            if (tag.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? colors.heritageMaroon.withValues(alpha: 0.3) : const Color(0xFFF5EBE6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? colors.heritageGold.withValues(alpha: 0.4) : const Color(0xFFD9B9AE)),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isDark ? colors.lightGold : const Color(0xFF6B2D24),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: styles.editorialSerif(context, size: 24, fontWeight: FontWeight.w700, color: colors.getPrimaryTextColor(context)),
              ),
              const SizedBox(height: 20),
            ],
            if (widget.store.blessings.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final previewBlessings = widget.store.blessings.take(2).toList();
                  final cards = previewBlessings.map((b) {
                    final author = b.getAuthor(_selectedPreviewLang);
                    final desig = b.getDesignation(_selectedPreviewLang);
                    final quote = b.getQuote(_selectedPreviewLang);

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: colors.getCardBackgroundColor(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.getBorderColor(context), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.format_quote_rounded, color: colors.heritageGold, size: 24),
                          const SizedBox(height: 8),
                          if (quote.isNotEmpty)
                            Text(
                              '"$quote"',
                              style: styles.bodySmall(context).copyWith(
                                fontStyle: FontStyle.italic,
                                color: colors.getPrimaryTextColor(context).withValues(alpha: 0.85),
                                fontSize: 12.5,
                                height: 1.5,
                              ),
                            ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colors.heritageGold, width: 1.2),
                                ),
                                child: AppCachedImage(
                                  imageUrl: b.photoUrl,
                                  fit: BoxFit.cover,
                                  isCircle: true,
                                  memCacheWidth: 100,
                                  memCacheHeight: 100,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (author.isNotEmpty)
                                      Text(author, style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w700, color: colors.getAccentColor(context))),
                                    if (desig.isNotEmpty)
                                      Text(desig, style: styles.cleanSans(context, size: 10.5, color: colors.getSecondaryTextColor(context))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList();

                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < cards.length; i++) ...[
                              if (i > 0) const SizedBox(width: 14),
                              Expanded(child: cards[i]),
                            ],
                          ],
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < cards.length; i++) ...[
                              if (i > 0) const SizedBox(height: 14),
                              cards[i],
                            ],
                          ],
                        );
                },
              ),
          ],
        ],
      ),
    );
  }

  // LIVE WEBSITE PREVIEW FOR CTA BANNER
  Widget _buildLiveCtaPreview(MyAppColors colors, MyAppTextStyles styles) {
    final inv = _selectedPreviewLang == 'gu'
        ? (_ctaInvocationGuCtrl.text.isNotEmpty ? _ctaInvocationGuCtrl.text : _ctaInvocationEnCtrl.text)
        : (_ctaInvocationEnCtrl.text.isNotEmpty ? _ctaInvocationEnCtrl.text : _ctaInvocationGuCtrl.text);

    final motto = _selectedPreviewLang == 'gu'
        ? (_ctaMottoGuCtrl.text.isNotEmpty ? _ctaMottoGuCtrl.text : _ctaMottoEnCtrl.text)
        : (_ctaMottoEnCtrl.text.isNotEmpty ? _ctaMottoEnCtrl.text : _ctaMottoGuCtrl.text);

    final btn = _selectedPreviewLang == 'gu'
        ? (_ctaBtnTextGuCtrl.text.isNotEmpty ? _ctaBtnTextGuCtrl.text : _ctaBtnTextEnCtrl.text)
        : (_ctaBtnTextEnCtrl.text.isNotEmpty ? _ctaBtnTextEnCtrl.text : _ctaBtnTextGuCtrl.text);

    final hasContent = inv.isNotEmpty || motto.isNotEmpty || btn.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.heritageMaroon, colors.deepMaroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Live Banner Preview',
                  style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w700, color: colors.lightGold),
                ),
              ),
              const SizedBox(width: 8),
              MyAppSegmentView.language(
                selectedLanguage: _selectedPreviewLang,
                onLanguageChanged: (val) => setState(() => _selectedPreviewLang = val),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (!hasContent)
            Text(
              'Call-To-Action Banner completely hidden on live website (all fields cleared)',
              textAlign: TextAlign.center,
              style: styles.cleanSans(context, size: 12, color: Colors.white70),
            )
          else ...[
            if (inv.isNotEmpty) ...[
              Text(
                inv,
                style: styles.devotionalMotto(context, size: 20, color: colors.lightGold),
              ),
              const SizedBox(height: 12),
            ],
            if (motto.isNotEmpty) ...[
              Text(
                motto,
                textAlign: TextAlign.center,
                style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(height: 18),
            ],
            if (btn.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                child: Text(
                  btn,
                  style: styles.cleanSans(context, color: colors.getAccentColor(context), size: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
