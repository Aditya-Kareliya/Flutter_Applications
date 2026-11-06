import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/localization/google_translation_service.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image/app_cached_image.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../data/admin_data_store.dart';

/// Comprehensive Admin view for About Us page content matching Admin HomePage architecture:
/// Dual-language inputs with instant translation, real-time pixel-perfect live previews,
/// default English preview with full theme adaptivity (light & dark), per-section actions,
/// drag-and-drop reordering, and rich modal dialogs.
class AdminAboutPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminAboutPageView({super.key, required this.store});

  @override
  State<AdminAboutPageView> createState() => _AdminAboutPageViewState();
}

class _AdminAboutPageViewState extends State<AdminAboutPageView> {
  // Section 1: Page Header & Story Introduction
  late final TextEditingController _tagBadgeEnCtrl;
  late final TextEditingController _tagBadgeGuCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleGuCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descGuCtrl;

  // Section 2: Heritage Foundation Card & Emblem Image
  late final TextEditingController _historyTitleEnCtrl;
  late final TextEditingController _historyTitleGuCtrl;
  late final TextEditingController _historyBodyEnCtrl;
  late final TextEditingController _historyBodyGuCtrl;
  late final TextEditingController _historyMottoEnCtrl;
  late final TextEditingController _historyMottoGuCtrl;
  String _foundationImageUrl = 'assets/images/pavan_putra_logo.png';

  // Section 3: Cultural Values & Principles Header
  late final TextEditingController _principlesTagEnCtrl;
  late final TextEditingController _principlesTagGuCtrl;
  late final TextEditingController _principlesTitleEnCtrl;
  late final TextEditingController _principlesTitleGuCtrl;

  // Section 4: Organizing Committee Header & Subtitle
  late final TextEditingController _committeeBadgeEnCtrl;
  late final TextEditingController _committeeBadgeGuCtrl;
  late final TextEditingController _committeeTitleEnCtrl;
  late final TextEditingController _committeeTitleGuCtrl;
  late final TextEditingController _committeeDescEnCtrl;
  late final TextEditingController _committeeDescGuCtrl;

  // Section 5: History Link Card & Navigation Route
  late final TextEditingController _ctaTitleEnCtrl;
  late final TextEditingController _ctaTitleGuCtrl;
  late final TextEditingController _ctaDescEnCtrl;
  late final TextEditingController _ctaDescGuCtrl;
  late final TextEditingController _ctaBtnTextEnCtrl;
  late final TextEditingController _ctaBtnTextGuCtrl;
  late final TextEditingController _ctaRouteCtrl;

  // Committee Search & Filter
  final TextEditingController _memberSearchCtrl = TextEditingController();
  String _memberSearchQuery = '';

  // Real-time Preview Language ('en' or 'gu') - Defaults to English ('en')
  String _previewLang = 'en';

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdated);
    widget.store.ensureAboutPageLoaded();
    _reloadAllControllersFromStore();
    _memberSearchCtrl.addListener(() {
      if (mounted) {
        setState(() {
          _memberSearchQuery = _memberSearchCtrl.text.trim().toLowerCase();
        });
      }
    });
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _reloadAllControllersFromStore() {
    final about = widget.store.aboutPageData;

    _tagBadgeEnCtrl = TextEditingController(text: about.tagBadgeEn);
    _tagBadgeGuCtrl = TextEditingController(text: about.tagBadgeGu);
    _titleEnCtrl = TextEditingController(text: about.titleEn);
    _titleGuCtrl = TextEditingController(text: about.titleGu);
    _descEnCtrl = TextEditingController(text: about.descEn);
    _descGuCtrl = TextEditingController(text: about.descGu);

    _historyTitleEnCtrl = TextEditingController(text: about.foundationTitleEn);
    _historyTitleGuCtrl = TextEditingController(text: about.foundationTitleGu);
    _historyBodyEnCtrl = TextEditingController(text: about.foundationDescEn);
    _historyBodyGuCtrl = TextEditingController(text: about.foundationDescGu);
    _historyMottoEnCtrl = TextEditingController(text: about.foundationMottoEn);
    _historyMottoGuCtrl = TextEditingController(text: about.foundationMottoGu);
    _foundationImageUrl = about.foundationImageUrl.isNotEmpty
        ? about.foundationImageUrl
        : 'assets/images/pavan_putra_logo.png';

    _principlesTagEnCtrl = TextEditingController(text: about.valuesTagEn);
    _principlesTagGuCtrl = TextEditingController(text: about.valuesTagGu);
    _principlesTitleEnCtrl = TextEditingController(text: about.valuesTitleEn);
    _principlesTitleGuCtrl = TextEditingController(text: about.valuesTitleGu);

    _committeeBadgeEnCtrl = TextEditingController(text: about.committeeBadgeEn);
    _committeeBadgeGuCtrl = TextEditingController(text: about.committeeBadgeGu);
    _committeeTitleEnCtrl = TextEditingController(text: about.committeeTitleEn);
    _committeeTitleGuCtrl = TextEditingController(text: about.committeeTitleGu);
    _committeeDescEnCtrl = TextEditingController(text: about.committeeDescEn);
    _committeeDescGuCtrl = TextEditingController(text: about.committeeDescGu);

    _ctaTitleEnCtrl = TextEditingController(text: about.ctaTitleEn);
    _ctaTitleGuCtrl = TextEditingController(text: about.ctaTitleGu);
    _ctaDescEnCtrl = TextEditingController(text: about.ctaDescEn);
    _ctaDescGuCtrl = TextEditingController(text: about.ctaDescGu);
    _ctaBtnTextEnCtrl = TextEditingController(text: about.ctaBtnTextEn);
    _ctaBtnTextGuCtrl = TextEditingController(text: about.ctaBtnTextGu);
    _ctaRouteCtrl = TextEditingController(text: about.ctaRoute.isNotEmpty ? about.ctaRoute : '/history');

    _attachLivePreviewListeners();
  }

  void _attachLivePreviewListeners() {
    final controllers = [
      _tagBadgeEnCtrl,
      _tagBadgeGuCtrl,
      _titleEnCtrl,
      _titleGuCtrl,
      _descEnCtrl,
      _descGuCtrl,
      _historyTitleEnCtrl,
      _historyTitleGuCtrl,
      _historyBodyEnCtrl,
      _historyBodyGuCtrl,
      _historyMottoEnCtrl,
      _historyMottoGuCtrl,
      _principlesTagEnCtrl,
      _principlesTagGuCtrl,
      _principlesTitleEnCtrl,
      _principlesTitleGuCtrl,
      _committeeBadgeEnCtrl,
      _committeeBadgeGuCtrl,
      _committeeTitleEnCtrl,
      _committeeTitleGuCtrl,
      _committeeDescEnCtrl,
      _committeeDescGuCtrl,
      _ctaTitleEnCtrl,
      _ctaTitleGuCtrl,
      _ctaDescEnCtrl,
      _ctaDescGuCtrl,
      _ctaBtnTextEnCtrl,
      _ctaBtnTextGuCtrl,
      _ctaRouteCtrl,
    ];
    for (final c in controllers) {
      c.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreUpdated);
    _tagBadgeEnCtrl.dispose();
    _tagBadgeGuCtrl.dispose();
    _titleEnCtrl.dispose();
    _titleGuCtrl.dispose();
    _descEnCtrl.dispose();
    _descGuCtrl.dispose();

    _historyTitleEnCtrl.dispose();
    _historyTitleGuCtrl.dispose();
    _historyBodyEnCtrl.dispose();
    _historyBodyGuCtrl.dispose();
    _historyMottoEnCtrl.dispose();
    _historyMottoGuCtrl.dispose();

    _principlesTagEnCtrl.dispose();
    _principlesTagGuCtrl.dispose();
    _principlesTitleEnCtrl.dispose();
    _principlesTitleGuCtrl.dispose();

    _committeeBadgeEnCtrl.dispose();
    _committeeBadgeGuCtrl.dispose();
    _committeeTitleEnCtrl.dispose();
    _committeeTitleGuCtrl.dispose();
    _committeeDescEnCtrl.dispose();
    _committeeDescGuCtrl.dispose();

    _ctaTitleEnCtrl.dispose();
    _ctaTitleGuCtrl.dispose();
    _ctaDescEnCtrl.dispose();
    _ctaDescGuCtrl.dispose();
    _ctaBtnTextEnCtrl.dispose();
    _ctaBtnTextGuCtrl.dispose();
    _ctaRouteCtrl.dispose();
    _memberSearchCtrl.dispose();

    super.dispose();
  }

  // ===========================================================================
  // PREVIEW LANGUAGE RESOLUTION HELPER
  // ===========================================================================

  String _resolvePreviewText({required String en, required String gu}) {
    if (_previewLang == 'gu') {
      return gu.trim().isNotEmpty ? gu.trim() : en.trim();
    }
    return en.trim().isNotEmpty ? en.trim() : gu.trim();
  }

  // ===========================================================================
  // AUTO-TRANSLATION & SAVING LOGIC
  // ===========================================================================

  Future<void> _autoTranslateIfEmpty(TextEditingController enCtrl, TextEditingController guCtrl) async {
    final enText = enCtrl.text.trim();
    if (enText.isNotEmpty && guCtrl.text.trim().isEmpty) {
      try {
        final translated = await GoogleTranslationService.instance.translateToGujarati(enText);
        if (translated.isNotEmpty) {
          guCtrl.text = translated;
        }
      } catch (_) {}
    }
  }

  AdminAboutPageData _buildCurrentAboutData() {
    return AdminAboutPageData(
      tagBadgeEn: _tagBadgeEnCtrl.text.trim(),
      tagBadgeGu: _tagBadgeGuCtrl.text.trim(),
      titleEn: _titleEnCtrl.text.trim(),
      titleGu: _titleGuCtrl.text.trim(),
      descEn: _descEnCtrl.text.trim(),
      descGu: _descGuCtrl.text.trim(),
      foundationTitleEn: _historyTitleEnCtrl.text.trim(),
      foundationTitleGu: _historyTitleGuCtrl.text.trim(),
      foundationDescEn: _historyBodyEnCtrl.text.trim(),
      foundationDescGu: _historyBodyGuCtrl.text.trim(),
      foundationMottoEn: _historyMottoEnCtrl.text.trim(),
      foundationMottoGu: _historyMottoGuCtrl.text.trim(),
      foundationImageUrl: _foundationImageUrl,
      valuesTagEn: _principlesTagEnCtrl.text.trim(),
      valuesTagGu: _principlesTagGuCtrl.text.trim(),
      valuesTitleEn: _principlesTitleEnCtrl.text.trim(),
      valuesTitleGu: _principlesTitleGuCtrl.text.trim(),
      committeeBadgeEn: _committeeBadgeEnCtrl.text.trim(),
      committeeBadgeGu: _committeeBadgeGuCtrl.text.trim(),
      committeeTitleEn: _committeeTitleEnCtrl.text.trim(),
      committeeTitleGu: _committeeTitleGuCtrl.text.trim(),
      committeeDescEn: _committeeDescEnCtrl.text.trim(),
      committeeDescGu: _committeeDescGuCtrl.text.trim(),
      ctaTitleEn: _ctaTitleEnCtrl.text.trim(),
      ctaTitleGu: _ctaTitleGuCtrl.text.trim(),
      ctaDescEn: _ctaDescEnCtrl.text.trim(),
      ctaDescGu: _ctaDescGuCtrl.text.trim(),
      ctaBtnTextEn: _ctaBtnTextEnCtrl.text.trim(),
      ctaBtnTextGu: _ctaBtnTextGuCtrl.text.trim(),
      ctaRoute: _ctaRouteCtrl.text.trim().isEmpty ? '/history' : _ctaRouteCtrl.text.trim(),
    );
  }

  // --- SAVE ALL ABOUT PAGE ---
  Future<void> _saveAllAboutPage() async {
    await _autoTranslateIfEmpty(_tagBadgeEnCtrl, _tagBadgeGuCtrl);
    await _autoTranslateIfEmpty(_titleEnCtrl, _titleGuCtrl);
    await _autoTranslateIfEmpty(_descEnCtrl, _descGuCtrl);
    await _autoTranslateIfEmpty(_historyTitleEnCtrl, _historyTitleGuCtrl);
    await _autoTranslateIfEmpty(_historyBodyEnCtrl, _historyBodyGuCtrl);
    await _autoTranslateIfEmpty(_historyMottoEnCtrl, _historyMottoGuCtrl);
    await _autoTranslateIfEmpty(_principlesTagEnCtrl, _principlesTagGuCtrl);
    await _autoTranslateIfEmpty(_principlesTitleEnCtrl, _principlesTitleGuCtrl);
    await _autoTranslateIfEmpty(_committeeBadgeEnCtrl, _committeeBadgeGuCtrl);
    await _autoTranslateIfEmpty(_committeeTitleEnCtrl, _committeeTitleGuCtrl);
    await _autoTranslateIfEmpty(_committeeDescEnCtrl, _committeeDescGuCtrl);
    await _autoTranslateIfEmpty(_ctaTitleEnCtrl, _ctaTitleGuCtrl);
    await _autoTranslateIfEmpty(_ctaDescEnCtrl, _ctaDescGuCtrl);
    await _autoTranslateIfEmpty(_ctaBtnTextEnCtrl, _ctaBtnTextGuCtrl);

    final updated = _buildCurrentAboutData();
    await widget.store.saveAboutPageContent(updated);

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'About Page Saved',
        description: 'All about page sections and settings have been saved successfully.',
      );
    }
  }

  // --- SECTION 1: SAVE & CLEAR ---
  Future<void> _saveHeaderSection() async {
    await _autoTranslateIfEmpty(_tagBadgeEnCtrl, _tagBadgeGuCtrl);
    await _autoTranslateIfEmpty(_titleEnCtrl, _titleGuCtrl);
    await _autoTranslateIfEmpty(_descEnCtrl, _descGuCtrl);

    final updated = _buildCurrentAboutData();
    await widget.store.saveAboutPageContent(updated);

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'Header Saved',
        description: 'Page header and story introduction have been updated successfully.',
      );
    }
  }

  void _confirmClearHeaderSection() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Header Section?'),
        content: const Text('Are you sure you want to clear the top badge, headline, and story introduction?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear All',
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _tagBadgeEnCtrl.clear();
                _tagBadgeGuCtrl.clear();
                _titleEnCtrl.clear();
                _titleGuCtrl.clear();
                _descEnCtrl.clear();
                _descGuCtrl.clear();
              });
              MyAppToastMessage.info(context, title: 'Cleared', description: 'Header fields cleared.');
            },
          ),
        ],
      ),
    );
  }

  // --- SECTION 2: SAVE & CLEAR ---
  Future<void> _saveFoundationSection() async {
    await _autoTranslateIfEmpty(_historyTitleEnCtrl, _historyTitleGuCtrl);
    await _autoTranslateIfEmpty(_historyBodyEnCtrl, _historyBodyGuCtrl);
    await _autoTranslateIfEmpty(_historyMottoEnCtrl, _historyMottoGuCtrl);

    final updated = _buildCurrentAboutData();
    await widget.store.saveAboutPageContent(updated);

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'Foundation Story Saved',
        description: 'Heritage foundation card and emblem photo have been updated successfully.',
      );
    }
  }

  void _confirmClearFoundationSection() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Foundation Section?'),
        content: const Text('Are you sure you want to clear the foundation headline, story, and sacred motto?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear All',
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _historyTitleEnCtrl.clear();
                _historyTitleGuCtrl.clear();
                _historyBodyEnCtrl.clear();
                _historyBodyGuCtrl.clear();
                _historyMottoEnCtrl.clear();
                _historyMottoGuCtrl.clear();
              });
              MyAppToastMessage.info(context, title: 'Cleared', description: 'Foundation fields cleared.');
            },
          ),
        ],
      ),
    );
  }

  // --- SECTION 3: SAVE PRINCIPLES HEADER ---
  Future<void> _savePrinciplesSection() async {
    await _autoTranslateIfEmpty(_principlesTagEnCtrl, _principlesTagGuCtrl);
    await _autoTranslateIfEmpty(_principlesTitleEnCtrl, _principlesTitleGuCtrl);

    final updated = _buildCurrentAboutData();
    await widget.store.saveAboutPageContent(updated);

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'Principles Saved',
        description: 'Cultural principles header and items have been updated successfully.',
      );
    }
  }

  // --- SECTION 4: SAVE COMMITTEE HEADER ---
  Future<void> _saveCommitteeSection() async {
    await _autoTranslateIfEmpty(_committeeBadgeEnCtrl, _committeeBadgeGuCtrl);
    await _autoTranslateIfEmpty(_committeeTitleEnCtrl, _committeeTitleGuCtrl);
    await _autoTranslateIfEmpty(_committeeDescEnCtrl, _committeeDescGuCtrl);

    final updated = _buildCurrentAboutData();
    await widget.store.saveAboutPageContent(updated);

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'Committee Saved',
        description: 'Organizing committee header and member list have been updated successfully.',
      );
    }
  }

  // --- SECTION 5: SAVE & CLEAR ---
  Future<void> _saveCtaSection() async {
    await _autoTranslateIfEmpty(_ctaTitleEnCtrl, _ctaTitleGuCtrl);
    await _autoTranslateIfEmpty(_ctaDescEnCtrl, _ctaDescGuCtrl);
    await _autoTranslateIfEmpty(_ctaBtnTextEnCtrl, _ctaBtnTextGuCtrl);

    final updated = _buildCurrentAboutData();
    await widget.store.saveAboutPageContent(updated);

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'Callout Saved',
        description: 'History link card and navigation destination have been updated successfully.',
      );
    }
  }

  void _confirmClearCtaSection() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Callout Section?'),
        content: const Text('Are you sure you want to clear the history link card title, subtitle, and button text?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Clear All',
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _ctaTitleEnCtrl.clear();
                _ctaTitleGuCtrl.clear();
                _ctaDescEnCtrl.clear();
                _ctaDescGuCtrl.clear();
                _ctaBtnTextEnCtrl.clear();
                _ctaBtnTextGuCtrl.clear();
              });
              MyAppToastMessage.info(context, title: 'Cleared', description: 'History link fields cleared.');
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REUSABLE DUAL LANGUAGE FIELD BUILDER (Matching Admin HomePage)
  // ===========================================================================

  Widget _buildDualLanguageField({
    required String title,
    required String enLabel,
    required TextEditingController enCtrl,
    required String guLabel,
    required TextEditingController guCtrl,
    int maxLines = 1,
    String? hintText,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final isDark = colors.isDarkMode(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.heritageGold.withValues(alpha: 0.25) : colors.getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
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
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        enField,
                        const SizedBox(height: 10),
                        guField,
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION HEADER WITH DIRECT ACTIONS (Matching Admin HomePage)
  // ===========================================================================

  Widget _buildSectionHeaderCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> actions,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.heritageGold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: styles.editorialSerif(
                    context,
                    size: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions,
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: colors.heritageGold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: styles.editorialSerif(
                    context,
                    size: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions,
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // LIVE PREVIEW CARD SHELL (Matching Admin HomePage)
  // ===========================================================================

  Widget _buildLivePreviewHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 420;
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
                      title,
                      style: styles.editorialSerif(
                        context,
                        size: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.getPrimaryTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                ),
              ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: styles.editorialSerif(
                      context,
                      size: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.getPrimaryTextColor(context),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            langSelector,
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 1. LIVE HEADER PREVIEW (Pixel-perfect matching AboutScreen lines 100-125)
  // ===========================================================================

  Widget _buildLiveHeaderPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = colors.isDarkMode(context);

    final tag = _resolvePreviewText(en: _tagBadgeEnCtrl.text, gu: _tagBadgeGuCtrl.text);
    final title = _resolvePreviewText(en: _titleEnCtrl.text, gu: _titleGuCtrl.text);
    final desc = _resolvePreviewText(en: _descEnCtrl.text, gu: _descGuCtrl.text);

    final hasContent = tag.isNotEmpty || title.isNotEmpty || desc.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLivePreviewHeader(
            context: context,
            title: 'Live Preview: Page Header & Story Introduction',
            subtitle: 'Real-time updates as you edit below',
          ),
          const SizedBox(height: 14),
          if (!hasContent)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'Header fields are currently empty.\nEnter title and story below to preview.',
                textAlign: TextAlign.center,
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tag.isNotEmpty) ...[
                  HeritageBadge(label: tag),
                  const SizedBox(height: 14),
                ],
                if (isMobile) ...[
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: styles.editorialSerif(
                        context,
                        size: 22,
                        fontWeight: FontWeight.w700,
                        color: colors.getPrimaryTextColor(context),
                      ),
                    ),
                  if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(height: 12),
                  if (desc.isNotEmpty)
                    Text(
                      desc,
                      style: styles.bodyText(context).copyWith(
                        fontSize: 14,
                        height: 1.65,
                        color: colors.getSecondaryTextColor(context),
                      ),
                    ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Expanded(
                          flex: 5,
                          child: Text(
                            title,
                            style: styles.editorialSerif(
                              context,
                              size: 26,
                              fontWeight: FontWeight.w700,
                              color: colors.getPrimaryTextColor(context),
                            ),
                          ),
                        ),
                      if (title.isNotEmpty && desc.isNotEmpty) const SizedBox(width: 28),
                      if (desc.isNotEmpty)
                        Expanded(
                          flex: 6,
                          child: Text(
                            desc,
                            style: styles.bodyText(context).copyWith(
                              fontSize: 14.5,
                              height: 1.7,
                              color: colors.getSecondaryTextColor(context),
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. LIVE FOUNDATION PREVIEW (Pixel-perfect matching AboutScreen lines 128-204)
  // ===========================================================================

  Widget _buildLiveFoundationPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = colors.isDarkMode(context);

    final title = _resolvePreviewText(en: _historyTitleEnCtrl.text, gu: _historyTitleGuCtrl.text);
    final body = _resolvePreviewText(en: _historyBodyEnCtrl.text, gu: _historyBodyGuCtrl.text);
    final motto = _resolvePreviewText(en: _historyMottoEnCtrl.text, gu: _historyMottoGuCtrl.text);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1B0306)
            : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLivePreviewHeader(
            context: context,
            title: 'Live Preview: Heritage & Foundation Story Card',
            subtitle: 'Real-time updates as you edit below',
          ),
          const SizedBox(height: 14),
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            backgroundColor: colors.deepMaroon,
            borderColor: colors.heritageGold.withValues(alpha: 0.4),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.heritageGold, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: _buildEmblemImagePreview(_foundationImageUrl, colors),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        title.isNotEmpty ? title : 'Heritage Foundation Title',
                        textAlign: TextAlign.center,
                        style: styles.editorialSerif(context, size: 19, fontWeight: FontWeight.w700, color: colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        body.isNotEmpty ? body : 'Foundation story and sacred history will appear here...',
                        textAlign: TextAlign.center,
                        style: styles.bodyText(context).copyWith(color: const Color(0xFFE2DDD1), fontSize: 13, height: 1.6),
                      ),
                      if (motto.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          motto,
                          textAlign: TextAlign.center,
                          style: styles.devotionalMotto(context, size: 17, color: colors.lightGold),
                        ),
                      ],
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.heritageGold, width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: _buildEmblemImagePreview(_foundationImageUrl, colors),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.isNotEmpty ? title : 'Heritage Foundation Title',
                              style: styles.editorialSerif(context, size: 21, fontWeight: FontWeight.w700, color: colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              body.isNotEmpty ? body : 'Foundation story and sacred history will appear here...',
                              style: styles.bodyText(context).copyWith(color: const Color(0xFFE2DDD1), fontSize: 13.5, height: 1.6),
                            ),
                            if (motto.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Text(
                                motto,
                                style: styles.devotionalMotto(context, size: 17, color: colors.lightGold),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmblemImagePreview(String url, MyAppColors colors) {
    return AppCachedImage(
      imageUrl: url,
      fit: BoxFit.cover,
      memCacheWidth: 400,
      memCacheHeight: 400,
      fallbackAsset: 'assets/images/pavan_putra_logo.png',
    );
  }

  // ===========================================================================
  // 3. LIVE PRINCIPLES PREVIEW (Pixel-perfect matching AboutScreen lines 208-257)
  // ===========================================================================

  Widget _buildLivePrinciplesPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = colors.isDarkMode(context);

    final tag = _resolvePreviewText(en: _principlesTagEnCtrl.text, gu: _principlesTagGuCtrl.text);
    final title = _resolvePreviewText(en: _principlesTitleEnCtrl.text, gu: _principlesTitleGuCtrl.text);
    final activePrinciples = widget.store.aboutPrinciples.where((p) => p.isActive).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLivePreviewHeader(
            context: context,
            title: 'Live Preview: Cultural Values & Principles',
            subtitle: 'Showing how principles appear on the public About Us page',
          ),
          const SizedBox(height: 14),
          if (tag.isNotEmpty) ...[
            HeritageBadge(label: tag),
            const SizedBox(height: 10),
          ],
          Text(
            title.isNotEmpty ? title : (_previewLang == 'gu' ? 'મંડળના પાયાના સિદ્ધાંતો' : 'Core Principles of the Mandal'),
            style: styles.editorialSerif(
              context,
              size: 18,
              fontWeight: FontWeight.w700,
              color: colors.getPrimaryTextColor(context),
            ),
          ),
          const SizedBox(height: 14),
          if (activePrinciples.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                'No principles added yet. Click "Add Principle" below to add.',
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int crossAxisCount = width < 600 ? 1 : 2;
                const double spacing = 12;

                if (crossAxisCount == 1) {
                  return Column(
                    children: [
                      for (int i = 0; i < activePrinciples.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        _buildPrincipleCardPreview(context, activePrinciples[i]),
                      ],
                    ],
                  );
                }

                final itemWidth = (width - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final p in activePrinciples)
                      SizedBox(
                        width: itemWidth,
                        child: _buildPrincipleCardPreview(context, p),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPrincipleCardPreview(BuildContext context, AdminAboutPrinciple p) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);
    final title = _resolvePreviewText(en: p.titleEn, gu: p.titleGu);
    final desc = _resolvePreviewText(en: p.descEn, gu: p.descGu);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? colors.heritageGold.withValues(alpha: 0.3) : colors.getBorderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.getAccentColor(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.getAccentColor(context).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(p.iconData, size: 16, color: colors.getAccentColor(context)),
                if (p.number.isNotEmpty) ...[
                  const SizedBox(width: 5),
                  Text(
                    p.number,
                    style: styles.devotionalMotto(context, size: 14, color: colors.getAccentColor(context)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isNotEmpty ? title : 'Principle Title',
                  style: styles.editorialSerif(
                    context,
                    size: 14.5,
                    fontWeight: FontWeight.w700,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: styles.bodyText(context).copyWith(
                      fontSize: 12.5,
                      height: 1.5,
                      color: colors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 4. LIVE COMMITTEE PREVIEW (Pixel-perfect matching AboutScreen lines 294-346)
  // ===========================================================================

  Widget _buildLiveCommitteePreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = colors.isDarkMode(context);

    final badge = _resolvePreviewText(en: _committeeBadgeEnCtrl.text, gu: _committeeBadgeGuCtrl.text);
    final title = _resolvePreviewText(en: _committeeTitleEnCtrl.text, gu: _committeeTitleGuCtrl.text);
    final desc = _resolvePreviewText(en: _committeeDescEnCtrl.text, gu: _committeeDescGuCtrl.text);
    final activeMembers = widget.store.committeeMembers.where((m) => m.isActive).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLivePreviewHeader(
            context: context,
            title: 'Live Preview: Organizing Committee & Trustees',
            subtitle: 'Showing first members in live presentation format',
          ),
          const SizedBox(height: 14),
          if (badge.isNotEmpty) ...[
            HeritageBadge(label: badge),
            const SizedBox(height: 10),
          ],
          Text(
            title.isNotEmpty ? title : (_previewLang == 'gu' ? 'ટ્રસ્ટી મંડળ અને સમિતિ' : 'Trustees & Organizing Committee'),
            style: styles.editorialSerif(
              context,
              size: 18,
              fontWeight: FontWeight.w700,
              color: colors.getPrimaryTextColor(context),
            ),
          ),
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              desc,
              style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
            ),
          ],
          const SizedBox(height: 14),
          if (activeMembers.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: Text(
                'No committee members currently added.\nClick "Add Member" below to add.',
                textAlign: TextAlign.center,
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int crossAxisCount = width < 480 ? 1 : (width < 768 ? 2 : 3);
                const double spacing = 12;

                final previewItems = activeMembers.take(6).toList();

                if (crossAxisCount == 1) {
                  return Column(
                    children: [
                      for (final m in previewItems) ...[
                        _buildCommitteeMemberCardPreview(context, m),
                        const SizedBox(height: 10),
                      ],
                    ],
                  );
                }

                final itemWidth = (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final m in previewItems)
                      SizedBox(
                        width: itemWidth,
                        child: _buildCommitteeMemberCardPreview(context, m),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommitteeMemberCardPreview(BuildContext context, AdminCommitteeMember member) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);
    final name = _resolvePreviewText(en: member.nameEn, gu: member.nameGu);
    final desig = _resolvePreviewText(en: member.designationEn, gu: member.designationGu);

    return Container(
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark ? colors.heritageGold.withValues(alpha: 0.3) : colors.getBorderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: SizedBox(
              height: 120,
              child: AppCachedImage(
                imageUrl: member.photoUrl,
                fit: BoxFit.cover,
                memCacheWidth: 300,
                memCacheHeight: 300,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Member Name',
                  style: styles.editorialSerif(
                    context,
                    size: 14.5,
                    fontWeight: FontWeight.w700,
                    color: colors.getPrimaryTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  desig.isNotEmpty ? desig : 'Designation / Role',
                  style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600, color: colors.heritageGold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (member.phone.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 12, color: colors.getSecondaryTextColor(context)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          member.phone,
                          style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
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
    );
  }

  // ===========================================================================
  // 5. LIVE CALLOUT PREVIEW (Pixel-perfect matching AboutScreen lines 349-450)
  // ===========================================================================

  Widget _buildLiveCtaPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = colors.isDarkMode(context);

    final title = _resolvePreviewText(en: _ctaTitleEnCtrl.text, gu: _ctaTitleGuCtrl.text);
    final desc = _resolvePreviewText(en: _ctaDescEnCtrl.text, gu: _ctaDescGuCtrl.text);
    final btn = _resolvePreviewText(en: _ctaBtnTextEnCtrl.text, gu: _ctaBtnTextGuCtrl.text);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLivePreviewHeader(
            context: context,
            title: 'Live Preview: History Link & Callout Card',
            subtitle: 'Real-time updates as you edit below',
          ),
          const SizedBox(height: 14),
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 16 : 22),
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
                            decoration: BoxDecoration(
                              color: colors.getAccentColor(context).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.history_edu_rounded, color: colors.getAccentColor(context), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.isNotEmpty ? title : 'History Link Title',
                                  style: styles.editorialSerif(
                                    context,
                                    size: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.getPrimaryTextColor(context),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  desc.isNotEmpty ? desc : 'Callout description will appear here...',
                                  style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.heritageMaroon,
                            foregroundColor: colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {},
                          child: Text(
                            btn.isNotEmpty ? btn : 'View History',
                            style: styles.cleanSans(context, color: colors.white, size: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colors.getAccentColor(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.history_edu_rounded, color: colors.getAccentColor(context), size: 26),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.isNotEmpty ? title : 'History Link Title',
                              style: styles.editorialSerif(
                                context,
                                size: 17,
                                fontWeight: FontWeight.w700,
                                color: colors.getPrimaryTextColor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc.isNotEmpty ? desc : 'Callout description will appear here...',
                              style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.heritageMaroon,
                          foregroundColor: colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {},
                        child: Text(
                          btn.isNotEmpty ? btn : 'View History',
                          style: styles.cleanSans(context, color: colors.white, size: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIALOGS: ADD / EDIT CULTURAL PRINCIPLES
  // ===========================================================================

  void _openPrincipleDialog([AdminAboutPrinciple? principle]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final numberCtrl = TextEditingController(text: principle?.number ?? '૦${widget.store.aboutPrinciples.length + 1}');
    final titleEnCtrl = TextEditingController(text: principle?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: principle?.titleGu ?? '');
    final descEnCtrl = TextEditingController(text: principle?.descEn ?? '');
    final descGuCtrl = TextEditingController(text: principle?.descGu ?? '');
    final maxOrder = widget.store.aboutPrinciples.isEmpty
        ? 0
        : widget.store.aboutPrinciples.map((p) => p.order).reduce((a, b) => a > b ? a : b);
    final assignedOrder = principle?.order ?? (maxOrder + 1);
    final orderCtrl = TextEditingController(text: '#$assignedOrder (Auto-assigned)');
    String iconKey = principle?.iconKey ?? 'verified';
    bool isActive = principle?.isActive ?? true;

    final icons = [
      {'key': 'verified', 'label': 'Verified', 'icon': Icons.verified_rounded},
      {'key': 'favorite', 'label': 'Devotion', 'icon': Icons.favorite_rounded},
      {'key': 'book', 'label': 'Sahitya', 'icon': Icons.auto_stories_rounded},
      {'key': 'history', 'label': 'Heritage', 'icon': Icons.history_edu_rounded},
      {'key': 'music', 'label': 'Acoustic', 'icon': Icons.music_note_rounded},
      {'key': 'shield', 'label': 'Purity', 'icon': Icons.shield_outlined},
      {'key': 'flame', 'label': 'Aarti / Deep', 'icon': Icons.local_fire_department_rounded},
      {'key': 'spa', 'label': 'Sacred Lotus', 'icon': Icons.spa_rounded},
    ];

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: colors.heritageGold, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  principle == null ? 'Add Cultural Principle' : 'Edit Cultural Principle',
                  style: styles.editorialSerif(context, size: 19, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: numberCtrl,
                          labelText: 'Number Badge (e.g. ૦૧, ૦૨)',
                          showClearIcon: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: orderCtrl,
                          labelText: 'Display Order',
                          readOnly: true,
                          enabled: false,
                          prefixIcon: const Icon(Icons.drag_indicator_rounded, size: 18),
                          showClearIcon: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    targetLanguageController: titleGuCtrl,
                    labelText: 'Title (English)',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Title (Gujarati)',
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
                  const SizedBox(height: 14),
                  Text('Select Icon Style:', style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((item) {
                      final isSelected = iconKey == item['key'];
                      return InkWell(
                        onTap: () => setDlgState(() => iconKey = item['key'] as String),
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        activeColor: colors.heritageMaroon,
                        onChanged: (v) => setDlgState(() => isActive = v ?? true),
                      ),
                      const Text('Active on Website'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              label: principle == null ? 'Add Principle' : 'Save Changes',
              onPressed: () async {
                final titleEn = titleEnCtrl.text.trim();
                var titleGu = titleGuCtrl.text.trim();
                if (titleEn.isEmpty && titleGu.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Title Required', description: 'Please enter a principle title.');
                  return;
                }

                if (titleGu.isEmpty && titleEn.isNotEmpty) {
                  try {
                    titleGu = await GoogleTranslationService.instance.translateToGujarati(titleEn);
                  } catch (_) {}
                }

                var descGu = descGuCtrl.text.trim();
                if (descGu.isEmpty && descEnCtrl.text.trim().isNotEmpty) {
                  try {
                    descGu = await GoogleTranslationService.instance.translateToGujarati(descEnCtrl.text.trim());
                  } catch (_) {}
                }

                final order = assignedOrder;
                final item = AdminAboutPrinciple(
                  id: principle?.id ?? 'principle-${DateTime.now().millisecondsSinceEpoch}',
                  number: numberCtrl.text.trim().isEmpty ? '૦૧' : numberCtrl.text.trim(),
                  titleEn: titleEn,
                  titleGu: titleGu,
                  descEn: descEnCtrl.text.trim(),
                  descGu: descGu,
                  iconKey: iconKey,
                  order: order,
                  isActive: isActive,
                );

                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (principle == null) {
                  widget.store.addAboutPrinciple(item);
                  MyAppToastMessage.success(context, title: 'Principle Added', description: 'New cultural principle added successfully.');
                } else {
                  widget.store.updateAboutPrinciple(item);
                  MyAppToastMessage.success(context, title: 'Principle Updated', description: 'Cultural principle updated successfully.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePrinciple(AdminAboutPrinciple principle) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Principle?'),
        content: Text('Are you sure you want to delete "${principle.titleEn.isNotEmpty ? principle.titleEn : principle.titleGu}"?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () {
              Navigator.pop(ctx);
              widget.store.deleteAboutPrinciple(principle.id);
              MyAppToastMessage.success(context, title: 'Deleted', description: 'Principle removed successfully.');
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // DIALOGS: ADD / EDIT COMMITTEE MEMBERS
  // ===========================================================================

  void _openMemberDialog([AdminCommitteeMember? member]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final nameEnCtrl = TextEditingController(text: member?.nameEn ?? '');
    final nameGuCtrl = TextEditingController(text: member?.nameGu ?? '');
    final desigEnCtrl = TextEditingController(text: member?.designationEn ?? '');
    final desigGuCtrl = TextEditingController(text: member?.designationGu ?? '');
    final phoneCtrl = TextEditingController(text: member?.phone ?? '');
    final maxMemberOrder = widget.store.committeeMembers.isEmpty
        ? 0
        : widget.store.committeeMembers.map((m) => m.order).reduce((a, b) => a > b ? a : b);
    final assignedMemberOrder = member?.order ?? (maxMemberOrder + 1);
    final orderCtrl = TextEditingController(text: '#$assignedMemberOrder');
    String photoUrl = member?.photoUrl ?? 'assets/images/pavan_putra_logo.png';
    bool isActive = member?.isActive ?? true;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Row(
            children: [
              Icon(Icons.groups_rounded, color: colors.heritageGold, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  member == null ? 'Add Committee Member' : 'Edit Member Details',
                  style: styles.editorialSerif(context, size: 19, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyAppImagePicker(
                    label: 'Member Photograph',
                    isCircle: true,
                    height: 130,
                    initialImageUrl: photoUrl,
                    onImageChanged: (url) => setDlgState(() => photoUrl = url),
                  ),
                  const SizedBox(height: 14),
                  MyAppTextFormField(
                    controller: nameEnCtrl,
                    targetLanguageController: nameGuCtrl,
                    labelText: 'Full Name (English)',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: nameGuCtrl,
                    labelText: 'Full Name (Gujarati)',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: desigEnCtrl,
                    targetLanguageController: desigGuCtrl,
                    labelText: 'Role / Designation (English)',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: desigGuCtrl,
                    labelText: 'Role / Designation (Gujarati)',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: phoneCtrl,
                          labelText: 'Contact Phone (Optional)',
                          showClearIcon: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: MyAppTextFormField(
                          controller: orderCtrl,
                          labelText: 'Display Order',
                          readOnly: true,
                          enabled: false,
                          prefixIcon: const Icon(Icons.drag_indicator_rounded, size: 18),
                          showClearIcon: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        activeColor: colors.heritageMaroon,
                        onChanged: (v) => setDlgState(() => isActive = v ?? true),
                      ),
                      const Text('Active Committee Member'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              label: member == null ? 'Add Member' : 'Save Changes',
              onPressed: () async {
                final nameEn = nameEnCtrl.text.trim();
                var nameGu = nameGuCtrl.text.trim();
                if (nameEn.isEmpty && nameGu.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Name Required', description: 'Please enter member full name.');
                  return;
                }

                if (nameGu.isEmpty && nameEn.isNotEmpty) {
                  try {
                    nameGu = await GoogleTranslationService.instance.translateToGujarati(nameEn);
                  } catch (_) {}
                }

                var desigGu = desigGuCtrl.text.trim();
                if (desigGu.isEmpty && desigEnCtrl.text.trim().isNotEmpty) {
                  try {
                    desigGu = await GoogleTranslationService.instance.translateToGujarati(desigEnCtrl.text.trim());
                  } catch (_) {}
                }

                final order = assignedMemberOrder;
                final item = AdminCommitteeMember(
                  id: member?.id ?? 'cm-${DateTime.now().millisecondsSinceEpoch}',
                  nameEn: nameEn,
                  nameGu: nameGu,
                  designationEn: desigEnCtrl.text.trim(),
                  designationGu: desigGu,
                  phone: phoneCtrl.text.trim(),
                  photoUrl: photoUrl,
                  order: order,
                  isActive: isActive,
                );

                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (member == null) {
                  widget.store.addCommitteeMember(item);
                  MyAppToastMessage.success(context, title: 'Member Added', description: 'Committee member added successfully.');
                } else {
                  widget.store.updateCommitteeMember(item);
                  MyAppToastMessage.success(context, title: 'Member Updated', description: 'Committee member updated successfully.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMember(AdminCommitteeMember member) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Committee Member?'),
        content: Text('Are you sure you want to remove "${member.nameEn}" from the committee list?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () {
              Navigator.pop(ctx);
              widget.store.deleteCommitteeMember(member.id);
              MyAppToastMessage.success(context, title: 'Deleted', description: 'Member removed from committee list.');
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MAIN BUILD METHOD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminWebsiteContextBanner(
          websitePageTitle: 'About Us Page',
          websiteRoute: '/about',
          explanation: 'Controls what visitors and devotees see on the About Us page: foundation story, cultural values, organizing committee, and history links.',
        ),
        const SizedBox(height: 12),

        // TOP BAR: ACTIONS & PREVIEW TOGGLE
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 14,
            spacing: 12,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeritageBadge(label: 'ABOUT US'),
                    const SizedBox(height: 6),
                    Text(
                      'About Page Content',
                      style: styles.editorialSerif(
                        context,
                        size: isMobile ? 20 : 22,
                        fontWeight: FontWeight.w700,
                        color: colors.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage the Mandal history, sacred values, emblem photo, organizing committee, and page links with live real-time preview and instant auto-translation.',
                      style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Global Real-time preview language toggle (defaults to 'en')
                  MyAppSegmentView.language(
                    selectedLanguage: _previewLang,
                    onLanguageChanged: (lang) => setState(() => _previewLang = lang),
                  ),

                  // Save All Button
                  MyAppFillButton.icon(
                    onPressed: _saveAllAboutPage,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: 'Save All Changes',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // =====================================================================
        // SECTION 1: HEADER & STORY INTRODUCTION
        // =====================================================================
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeaderCard(
                context: context,
                icon: Icons.title_rounded,
                title: '1. Page Header & Story Introduction',
                actions: [
                  MyAppOutlineButton.icon(
                    isDanger: true,
                    onPressed: _confirmClearHeaderSection,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                    label: 'Clear Section',
                  ),
                  MyAppFillButton.icon(
                    onPressed: _saveHeaderSection,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: 'Save Header',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Preview Box for Header (First in Section)
              _buildLiveHeaderPreview(context),
              const SizedBox(height: 20),

              _buildDualLanguageField(
                title: 'Top Eyebrow Badge Tag',
                enLabel: 'Top Badge (English)',
                enCtrl: _tagBadgeEnCtrl,
                guLabel: 'Top Badge (Gujarati)',
                guCtrl: _tagBadgeGuCtrl,
                hintText: 'e.g. ABOUT PAVAN PUTRA GARBI MANDAL',
              ),
              _buildDualLanguageField(
                title: 'Main Headline',
                enLabel: 'Headline (English)',
                enCtrl: _titleEnCtrl,
                guLabel: 'Headline (Gujarati)',
                guCtrl: _titleGuCtrl,
                hintText: 'e.g. Preserving Prachin Garbi Folk Heritage in Rajkot',
              ),
              _buildDualLanguageField(
                title: 'Introductory Story Paragraph',
                enLabel: 'Story Introduction (English)',
                enCtrl: _descEnCtrl,
                guLabel: 'Story Introduction (Gujarati)',
                guCtrl: _descGuCtrl,
                maxLines: 4,
                hintText: 'Describe the heritage, background, and cultural mission...',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // =====================================================================
        // SECTION 2: HERITAGE & FOUNDATION STORY
        // =====================================================================
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeaderCard(
                context: context,
                icon: Icons.history_edu_rounded,
                title: '2. Heritage & Foundation Story Card',
                actions: [
                  MyAppOutlineButton.icon(
                    isDanger: true,
                    onPressed: _confirmClearFoundationSection,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                    label: 'Clear Section',
                  ),
                  MyAppFillButton.icon(
                    onPressed: _saveFoundationSection,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: 'Save Foundation',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Preview Box for Foundation Card (First in Section)
              _buildLiveFoundationPreview(context),
              const SizedBox(height: 20),

              _buildDualLanguageField(
                title: 'Foundation Card Title',
                enLabel: 'Title (English)',
                enCtrl: _historyTitleEnCtrl,
                guLabel: 'Title (Gujarati)',
                guCtrl: _historyTitleGuCtrl,
                hintText: 'e.g. Four Decades of Continuous Devotion',
              ),
              _buildDualLanguageField(
                title: 'Sacred Foundation Story',
                enLabel: 'History Story (English)',
                enCtrl: _historyBodyEnCtrl,
                guLabel: 'History Story (Gujarati)',
                guCtrl: _historyBodyGuCtrl,
                maxLines: 4,
                hintText: 'Full devotional chronicle of the Mandal since 1989...',
              ),
              _buildDualLanguageField(
                title: 'Devotional Sacred Motto',
                enLabel: 'Sacred Motto (English)',
                enCtrl: _historyMottoEnCtrl,
                guLabel: 'Sacred Motto (Gujarati)',
                guCtrl: _historyMottoGuCtrl,
                hintText: 'e.g. || જાગતી જોગમાયા || પરંપરા • ભક્તિ • સૂર',
              ),
              const SizedBox(height: 8),
              MyAppImagePicker(
                label: 'Mandal Sacred Emblem / Historical Photo',
                initialImageUrl: _foundationImageUrl,
                isCircle: true,
                height: 130,
                onImageChanged: (url) => setState(() => _foundationImageUrl = url),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // =====================================================================
        // SECTION 3: CULTURAL VALUES & PRINCIPLES
        // =====================================================================
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeaderCard(
                context: context,
                icon: Icons.auto_stories_rounded,
                title: '3. Cultural Values & Principles',
                actions: [
                  MyAppOutlineButton.icon(
                    onPressed: () => _openPrincipleDialog(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: 'Add Principle',
                  ),
                  MyAppFillButton.icon(
                    onPressed: _savePrinciplesSection,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: 'Save Principles',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Preview Box for Principles (First in Section)
              _buildLivePrinciplesPreview(context),
              const SizedBox(height: 20),

              _buildDualLanguageField(
                title: 'Section Eyebrow Badge',
                enLabel: 'Badge (English)',
                enCtrl: _principlesTagEnCtrl,
                guLabel: 'Badge (Gujarati)',
                guCtrl: _principlesTagGuCtrl,
                hintText: 'e.g. CORE CULTURAL VALUES',
              ),
              _buildDualLanguageField(
                title: 'Section Main Title',
                enLabel: 'Title (English)',
                enCtrl: _principlesTitleEnCtrl,
                guLabel: 'Title (Gujarati)',
                guCtrl: _principlesTitleGuCtrl,
                hintText: 'e.g. Fundamental Pillars of Pavan Putra Garbi Mandal',
              ),
              const SizedBox(height: 16),

              // Principles list header
              Row(
                children: [
                  Icon(Icons.format_list_numbered_rounded, size: 18, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cultural Principles List (${widget.store.aboutPrinciples.length} total)',
                      style: styles.editorialSerif(
                        context,
                        size: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.getPrimaryTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Principles list items
              if (widget.store.aboutPrinciples.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 36, color: colors.heritageGold),
                      const SizedBox(height: 8),
                      Text(
                        'No principles added yet.',
                        style: styles.editorialSerif(
                          context,
                          size: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.getPrimaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click "Add Principle" above to add cultural principles.',
                        style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                      ),
                    ],
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
                    itemCount: widget.store.aboutPrinciples.length,
                    onReorderItem: (oldIndex, newIndex) {
                      widget.store.reorderAboutPrinciples(oldIndex, newIndex);
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      final principle = widget.store.aboutPrinciples[index];
                      return Container(
                        key: ValueKey(principle.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colors.heritageGold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
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
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          principle.number,
                                          style: styles.devotionalMotto(context, size: 16, color: colors.heritageGold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(principle.iconData, color: colors.heritageGold, size: 20),
                                      if (!principle.isActive) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text('Hidden', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                      const Spacer(),
                                      MyAppIconButton(
                                        tooltip: 'Edit Principle',
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        color: colors.heritageGold,
                                        onPressed: () => _openPrincipleDialog(principle),
                                      ),
                                      MyAppIconButton(
                                        tooltip: 'Delete Principle',
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                        color: Colors.redAccent,
                                        onPressed: () => _confirmDeletePrinciple(principle),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    principle.titleEn,
                                    style: styles.editorialSerif(
                                      context,
                                      size: 15,
                                      fontWeight: FontWeight.w700,
                                      color: colors.getPrimaryTextColor(context),
                                    ),
                                  ),
                                  if (principle.titleGu.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      principle.titleGu,
                                      style: styles.devotionalMotto(context, size: 13, color: colors.heritageGold),
                                    ),
                                  ],
                                  if (principle.descEn.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      principle.descEn,
                                      style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                                    ),
                                  ],
                                ],
                              )
                            : Row(
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
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      principle.number,
                                      style: styles.devotionalMotto(context, size: 16, color: colors.heritageGold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(principle.iconData, color: colors.heritageGold, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              principle.titleEn,
                                              style: styles.editorialSerif(
                                                context,
                                                size: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: colors.getPrimaryTextColor(context),
                                              ),
                                            ),
                                            if (!principle.isActive) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('Hidden', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (principle.titleGu.isNotEmpty)
                                          Text(
                                            principle.titleGu,
                                            style: styles.devotionalMotto(context, size: 12.5, color: colors.heritageGold),
                                          ),
                                        if (principle.descEn.isNotEmpty)
                                          Text(
                                            principle.descEn,
                                            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  MyAppIconButton(
                                    tooltip: 'Edit Principle',
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    color: colors.heritageGold,
                                    onPressed: () => _openPrincipleDialog(principle),
                                  ),
                                  MyAppIconButton(
                                    tooltip: 'Delete Principle',
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    color: Colors.redAccent,
                                    onPressed: () => _confirmDeletePrinciple(principle),
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

        // =====================================================================
        // SECTION 4: ORGANIZING COMMITTEE & TRUSTEES
        // =====================================================================
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeaderCard(
                context: context,
                icon: Icons.groups_rounded,
                title: '4. Organizing Committee & Trustees',
                actions: [
                  MyAppOutlineButton.icon(
                    onPressed: () => _openMemberDialog(),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: 'Add Member',
                  ),
                  MyAppFillButton.icon(
                    onPressed: _saveCommitteeSection,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: 'Save Committee',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Preview Box for Committee Members (First in Section)
              _buildLiveCommitteePreview(context),
              const SizedBox(height: 20),

              _buildDualLanguageField(
                title: 'Section Eyebrow Badge',
                enLabel: 'Badge (English)',
                enCtrl: _committeeBadgeEnCtrl,
                guLabel: 'Badge (Gujarati)',
                guCtrl: _committeeBadgeGuCtrl,
                hintText: 'e.g. LEADERSHIP & SEVAKS',
              ),
              _buildDualLanguageField(
                title: 'Section Main Title',
                enLabel: 'Title (English)',
                enCtrl: _committeeTitleEnCtrl,
                guLabel: 'Title (Gujarati)',
                guCtrl: _committeeTitleGuCtrl,
                hintText: 'e.g. Trustees & Executive Organizing Committee',
              ),
              _buildDualLanguageField(
                title: 'Section Subtitle Description',
                enLabel: 'Subtitle (English)',
                enCtrl: _committeeDescEnCtrl,
                guLabel: 'Subtitle (Gujarati)',
                guCtrl: _committeeDescGuCtrl,
                maxLines: 2,
                hintText: 'Dedicated volunteers carrying the sacred flame across generations...',
              ),
              const SizedBox(height: 16),

              // Member Search & Filter Bar
              MyAppTextFormField(
                controller: _memberSearchCtrl,
                hintText: 'Search committee member by name, role, or phone...',
                prefixIcon: const Icon(Icons.search_rounded),
                showClearIcon: true,
                onChanged: (val) => setState(() => _memberSearchQuery = val.trim()),
              ),
              const SizedBox(height: 14),

              // Members List
              _buildMembersList(context),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // =====================================================================
        // SECTION 5: HISTORY LINK CARD & DESTINATION ROUTE
        // =====================================================================
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeaderCard(
                context: context,
                icon: Icons.call_made_rounded,
                title: '5. History Link & Navigation Card',
                actions: [
                  MyAppOutlineButton.icon(
                    isDanger: true,
                    onPressed: _confirmClearCtaSection,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                    label: 'Clear Section',
                  ),
                  MyAppFillButton.icon(
                    onPressed: _saveCtaSection,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: 'Save Callout',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Preview Box for Callout Card (First in Section)
              _buildLiveCtaPreview(context),
              const SizedBox(height: 20),

              _buildDualLanguageField(
                title: 'History Callout Headline',
                enLabel: 'Title (English)',
                enCtrl: _ctaTitleEnCtrl,
                guLabel: 'Title (Gujarati)',
                guCtrl: _ctaTitleGuCtrl,
                hintText: 'e.g. Explore our Complete 45+ Year Historical Timeline',
              ),
              _buildDualLanguageField(
                title: 'History Callout Subtitle',
                enLabel: 'Subtitle (English)',
                enCtrl: _ctaDescEnCtrl,
                guLabel: 'Subtitle (Gujarati)',
                guCtrl: _ctaDescGuCtrl,
                maxLines: 2,
                hintText: 'Discover photos, sacred documents, founders, and moments since 1989...',
              ),
              _buildDualLanguageField(
                title: 'Callout Button Label',
                enLabel: 'Button Label (English)',
                enCtrl: _ctaBtnTextEnCtrl,
                guLabel: 'Button Label (Gujarati)',
                guCtrl: _ctaBtnTextGuCtrl,
                hintText: 'e.g. View Complete History Archive',
              ),
              const SizedBox(height: 4),
              MyAppDropdown.pageDestination(
                controller: _ctaRouteCtrl,
                labelText: 'Button Destination Page (કયા પેજ પર જવું)',
                defaultRoute: '/history',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // COMMITTEE MEMBERS LIST BUILDER (With Drag & Drop or Filtered View)
  // ===========================================================================

  Widget _buildMembersList(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    final allMembers = widget.store.committeeMembers;
    final isFiltering = _memberSearchQuery.isNotEmpty;
    final filtered = !isFiltering
        ? allMembers
        : allMembers.where((m) {
            return m.nameEn.toLowerCase().contains(_memberSearchQuery) ||
                m.nameGu.toLowerCase().contains(_memberSearchQuery) ||
                m.designationEn.toLowerCase().contains(_memberSearchQuery) ||
                m.designationGu.toLowerCase().contains(_memberSearchQuery) ||
                m.phone.toLowerCase().contains(_memberSearchQuery);
          }).toList();

    if (allMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.group_off_rounded, size: 36, color: colors.heritageGold),
            const SizedBox(height: 8),
            Text(
              'No committee members currently added.',
              style: styles.editorialSerif(
                context,
                size: 16,
                fontWeight: FontWeight.bold,
                color: colors.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Click "Add Member" above to add committee members.',
              style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No members match "$_memberSearchQuery".',
            style: styles.cleanSans(context, size: 13, color: colors.getSecondaryTextColor(context)),
          ),
        ),
      );
    }

    Widget buildMemberItem(AdminCommitteeMember member, int index, {bool canDrag = false}) {
      return Container(
        key: ValueKey(member.id),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.25)),
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (canDrag)
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
                          imageUrl: member.photoUrl,
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.nameEn,
                                    style: styles.editorialSerif(
                                      context,
                                      size: 15,
                                      fontWeight: FontWeight.w700,
                                      color: colors.getPrimaryTextColor(context),
                                    ),
                                  ),
                                ),
                                if (!member.isActive) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Hidden', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ],
                            ),
                            if (member.nameGu.isNotEmpty) ...[
                              const SizedBox(height: 1),
                              Text(
                                member.nameGu,
                                style: styles.devotionalMotto(context, size: 12.5, color: colors.heritageGold),
                              ),
                            ],
                          ],
                        ),
                      ),
                      MyAppIconButton(
                        tooltip: 'Edit Member',
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: colors.heritageGold,
                        onPressed: () => _openMemberDialog(member),
                      ),
                      MyAppIconButton(
                        tooltip: 'Delete Member',
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        color: Colors.redAccent,
                        onPressed: () => _confirmDeleteMember(member),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${member.designationEn} • ${member.designationGu}${member.phone.isNotEmpty ? " • 📞 ${member.phone}" : ""}',
                    style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                  ),
                ],
              )
            : Row(
                children: [
                  if (canDrag)
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
                      imageUrl: member.photoUrl,
                      fit: BoxFit.cover,
                      isCircle: true,
                      memCacheWidth: 100,
                      memCacheHeight: 100,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              member.nameEn,
                              style: styles.editorialSerif(
                                context,
                                size: 15,
                                fontWeight: FontWeight.w700,
                                color: colors.getPrimaryTextColor(context),
                              ),
                            ),
                            if (member.nameGu.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${member.nameGu})',
                                style: styles.devotionalMotto(context, size: 12.5, color: colors.heritageGold),
                              ),
                            ],
                            if (!member.isActive) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('Hidden', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${member.designationEn} • ${member.designationGu}${member.phone.isNotEmpty ? " • 📞 ${member.phone}" : ""}',
                          style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${index + 1}',
                    style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.bold, color: colors.heritageGold),
                  ),
                  const SizedBox(width: 6),
                  MyAppIconButton(
                    tooltip: 'Edit Member',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: colors.heritageGold,
                    onPressed: () => _openMemberDialog(member),
                  ),
                  MyAppIconButton(
                    tooltip: 'Delete Member',
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: Colors.redAccent,
                    onPressed: () => _confirmDeleteMember(member),
                  ),
                ],
              ),
      );
    }

    if (!isFiltering) {
      return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: allMembers.length,
          onReorderItem: (oldIndex, newIndex) {
            widget.store.reorderCommitteeMembers(oldIndex, newIndex);
            setState(() {});
          },
          itemBuilder: (context, index) => buildMemberItem(allMembers[index], index, canDrag: true),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Filtering by "$_memberSearchQuery". Clear search to drag and reorder members.',
            style: styles.cleanSans(context, size: 12, color: colors.heritageGold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) => buildMemberItem(filtered[index], index, canDrag: false),
        ),
      ],
    );
  }
}
