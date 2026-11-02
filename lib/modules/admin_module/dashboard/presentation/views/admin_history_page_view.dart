import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/heritage_divider.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../data/admin_data_store.dart';

/// Comprehensive Admin view for History & Heritage timeline milestones and page content:
/// - Default English live previews with instant English/Gujarati preview toggle
/// - Full theme adaptivity with high contrast across light and dark themes
/// - Section-specific live previews positioned right alongside editing controls
/// - Dual-language input fields with Google Cloud auto-translation and clear actions
/// - Friendly destination page dropdowns identical to Admin Home Screen
/// - Active/Publish toggle switch in modal dialog
/// - Milestone search, filter, reorder, add, edit, and deletion capabilities
/// - Responsive, unconstrained mobile card layout preventing text and badge truncation
/// - Single, dedicated Add Milestone action placed logically in the Milestones section
class AdminHistoryPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminHistoryPageView({super.key, required this.store});

  @override
  State<AdminHistoryPageView> createState() => _AdminHistoryPageViewState();
}

class _AdminHistoryPageViewState extends State<AdminHistoryPageView> {
  // Section 1: Page Header & Introduction Controllers
  late final TextEditingController _tagEnCtrl;
  late final TextEditingController _tagGuCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleGuCtrl;
  late final TextEditingController _subtitleEnCtrl;
  late final TextEditingController _subtitleGuCtrl;

  // Section 3: Bottom Exploration Action Button (CTA) Controllers
  late final TextEditingController _ctaTextEnCtrl;
  late final TextEditingController _ctaTextGuCtrl;
  late final TextEditingController _ctaRouteCtrl;

  // Search & Filter for Milestones
  final TextEditingController _milestoneSearchCtrl = TextEditingController();
  String _milestoneSearchQuery = '';

  // Independent Real-time Preview Languages (defaulting to English 'en')
  String _headerPreviewLang = 'en';
  String _milestonesPreviewLang = 'en';
  String _ctaPreviewLang = 'en';

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdated);
    widget.store.ensureHistoryLoaded();
    _reloadAllControllersFromStore();

    _milestoneSearchCtrl.addListener(() {
      if (mounted) {
        setState(() {
          _milestoneSearchQuery = _milestoneSearchCtrl.text.trim().toLowerCase();
        });
      }
    });
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _reloadAllControllersFromStore() {
    final s = widget.store;

    _tagEnCtrl = TextEditingController(text: s.getTextOverride('en', 'history_tag'));
    _tagGuCtrl = TextEditingController(text: s.getTextOverride('gu', 'history_tag'));
    _titleEnCtrl = TextEditingController(text: s.getTextOverride('en', 'history_title'));
    _titleGuCtrl = TextEditingController(text: s.getTextOverride('gu', 'history_title'));
    _subtitleEnCtrl = TextEditingController(text: s.getTextOverride('en', 'history_subtitle'));
    _subtitleGuCtrl = TextEditingController(text: s.getTextOverride('gu', 'history_subtitle'));

    _ctaTextEnCtrl = TextEditingController(text: s.getTextOverride('en', 'sec_02_cta'));
    _ctaTextGuCtrl = TextEditingController(text: s.getTextOverride('gu', 'sec_02_cta'));

    final routeVal = s.getTextOverride('en', 'history_cta_route');
    _ctaRouteCtrl = TextEditingController(
      text: (routeVal != null && routeVal.isNotEmpty) ? routeVal : '/archive',
    );
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreUpdated);
    _tagEnCtrl.dispose();
    _tagGuCtrl.dispose();
    _titleEnCtrl.dispose();
    _titleGuCtrl.dispose();
    _subtitleEnCtrl.dispose();
    _subtitleGuCtrl.dispose();
    _ctaTextEnCtrl.dispose();
    _ctaTextGuCtrl.dispose();
    _ctaRouteCtrl.dispose();
    _milestoneSearchCtrl.dispose();
    super.dispose();
  }

  // ===========================================================================
  // DUAL-LANGUAGE LIVE PREVIEW RESOLVER
  // ===========================================================================

  String _resolvePreviewText({
    required String lang,
    required String en,
    required String gu,
  }) {
    if (lang == 'en') {
      return en.trim().isNotEmpty ? en.trim() : gu.trim();
    } else {
      return gu.trim().isNotEmpty ? gu.trim() : en.trim();
    }
  }

  // ===========================================================================
  // SAVE & RESET ACTIONS
  // ===========================================================================

  void _saveHistoryHeader() {
    final s = widget.store;
    s.updateSiteContentField(
      'history_tag',
      valueEn: _tagEnCtrl.text.trim(),
      valueGu: _tagGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'history_title',
      valueEn: _titleEnCtrl.text.trim(),
      valueGu: _titleGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'history_subtitle',
      valueEn: _subtitleEnCtrl.text.trim(),
      valueGu: _subtitleGuCtrl.text.trim(),
    );

    MyAppToastMessage.success(
      context,
      title: 'Header Saved',
      description: 'History and Heritage page headlines updated and published.',
    );
  }

  void _saveCtaButton() {
    final s = widget.store;
    s.updateSiteContentField(
      'sec_02_cta',
      valueEn: _ctaTextEnCtrl.text.trim(),
      valueGu: _ctaTextGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'history_cta_route',
      valueEn: _ctaRouteCtrl.text.trim(),
      valueGu: _ctaRouteCtrl.text.trim(),
    );

    MyAppToastMessage.success(
      context,
      title: 'Action Button Saved',
      description: 'Bottom exploration button details updated and published.',
    );
  }

  void _saveAllSections() {
    _saveHistoryHeader();
    _saveCtaButton();
    MyAppToastMessage.success(
      context,
      title: 'All Changes Saved',
      description: 'Entire History & Heritage page content has been published.',
    );
  }

  void _confirmResetAll() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: serviceLocator<MyAppColors>().getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: serviceLocator<MyAppColors>().heritageGold.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            Icon(Icons.restore_rounded, color: serviceLocator<MyAppColors>().heritageGold),
            const SizedBox(width: 8),
            Text(
              'Reset History Page Fields?',
              style: serviceLocator<MyAppTextStyles>().editorialSerif(
                context,
                size: 18,
                fontWeight: FontWeight.w700,
                color: serviceLocator<MyAppColors>().getPrimaryTextColor(context),
              ),
            ),
          ],
        ),
        content: Text(
          'This will reload all form fields from the saved cloud database. Any unsaved edits will be discarded.',
          style: serviceLocator<MyAppTextStyles>().cleanSans(
            context,
            size: 13,
            color: serviceLocator<MyAppColors>().getSecondaryTextColor(context),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _reloadAllControllersFromStore();
              setState(() {});
              MyAppToastMessage.info(
                context,
                title: 'Fields Reloaded',
                description: 'Content reset to stored database values.',
              );
            },
            icon: const Icon(Icons.restore_rounded, size: 16),
            label: 'Revert',
          ),
        ],
      ),
    );
  }

  void _clearHeader() {
    setState(() {
      _tagEnCtrl.clear();
      _tagGuCtrl.clear();
      _titleEnCtrl.clear();
      _titleGuCtrl.clear();
      _subtitleEnCtrl.clear();
      _subtitleGuCtrl.clear();
    });
    MyAppToastMessage.info(context, title: 'Cleared', description: 'Header input fields have been cleared.');
  }

  void _clearCta() {
    setState(() {
      _ctaTextEnCtrl.clear();
      _ctaTextGuCtrl.clear();
      _ctaRouteCtrl.text = '/archive';
    });
    MyAppToastMessage.info(context, title: 'Cleared', description: 'Action button inputs have been cleared.');
  }

  // ===========================================================================
  // ICON RESOLVER
  // ===========================================================================

  IconData _iconForMilestone(String iconName) {
    switch (iconName) {
      case 'local_fire_department_rounded':
        return Icons.local_fire_department_rounded;
      case 'music_note_rounded':
        return Icons.music_note_rounded;
      case 'military_tech_rounded':
        return Icons.military_tech_rounded;
      case 'auto_stories_rounded':
        return Icons.auto_stories_rounded;
      case 'cloud_done_rounded':
        return Icons.cloud_done_rounded;
      case 'temple_hindu_rounded':
        return Icons.temple_hindu_rounded;
      case 'stars_rounded':
        return Icons.stars_rounded;
      case 'groups_rounded':
        return Icons.groups_rounded;
      case 'volunteer_activism_rounded':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.history_edu_rounded;
    }
  }

  String _labelForMilestoneIcon(String iconName) {
    switch (iconName) {
      case 'local_fire_department_rounded':
        return 'Aarti & Deepam';
      case 'music_note_rounded':
        return 'Music & Orchestra';
      case 'military_tech_rounded':
        return 'Honors & Recognition';
      case 'auto_stories_rounded':
        return 'Chhand & Poetry';
      case 'cloud_done_rounded':
        return 'Digital Archive';
      case 'temple_hindu_rounded':
        return 'Temple & Sanctity';
      case 'stars_rounded':
        return 'Divine Blessings';
      case 'groups_rounded':
        return 'Community Devotion';
      case 'volunteer_activism_rounded':
        return 'Seva & Service';
      default:
        return iconName.isNotEmpty ? iconName.replaceAll('_', ' ') : 'Timeline Era';
    }
  }

  // ===========================================================================
  // DUAL-LANGUAGE FORM FIELD CONTAINER (Light & Dark Theme Adaptive)
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
  // BUTTON CONFIG FIELD WITH DESTINATION PAGE DROPDOWN (Matching Admin Home)
  // ===========================================================================

  Widget _buildButtonConfigField({
    required String title,
    required TextEditingController labelEnCtrl,
    required TextEditingController labelGuCtrl,
    required TextEditingController routeCtrl,
    String? defaultRoute,
    String labelText = 'Destination Page to Open (કયા પેજ પર જવું)',
    String helperText = 'Select which website page visitors explore when clicking this button',
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
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
                labelText: 'Button Label (English)',
                hintText: 'e.g. EXPLORE ARCHIVE',
                showTranslateIcon: true,
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              );

              final guField = MyAppTextFormField(
                controller: labelGuCtrl,
                labelText: 'બટન નામ / લેબલ (ગુજરાતી)',
                hintText: 'દા.ત. સંગ્રહ જુઓ',
                showClearIcon: true,
                onChanged: (_) => setState(() {}),
              );

              final destinationDropdown = _buildDestinationPageSelector(
                routeCtrl: routeCtrl,
                colors: colors,
                styles: styles,
                defaultRoute: defaultRoute ?? '/archive',
                labelText: labelText,
                helperText: helperText,
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

  // ===========================================================================
  // DESTINATION PAGE SELECTOR DROPDOWN (Matching Admin Home)
  // ===========================================================================

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

  // ===========================================================================
  // SECTION HEADER WITH DIRECT ACTIONS (Matching Admin Home & About)
  // ===========================================================================

  Widget _buildSectionHeaderCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required List<Widget> actions,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Column(
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
          )
        else
          Row(
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
          ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // LIVE PREVIEW CARD SHELL (Matching Admin Home & About)
  // ===========================================================================

  Widget _buildLivePreviewHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    required String selectedLanguage,
    required ValueChanged<String> onLanguageChanged,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 420;
        final langSelector = MyAppSegmentView.language(
          selectedLanguage: selectedLanguage,
          onLanguageChanged: onLanguageChanged,
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
                      style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600).copyWith(
                        color: colors.heritageGold,
                        fontWeight: FontWeight.w700,
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
                    style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600).copyWith(
                      color: colors.heritageGold,
                      fontWeight: FontWeight.w700,
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
  // 1. LIVE HEADER PREVIEW (Pixel-perfect matching HistoryScreen lines 136-150)
  // ===========================================================================

  Widget _buildLiveHeaderPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = colors.isDarkMode(context);

    final tag = _resolvePreviewText(lang: _headerPreviewLang, en: _tagEnCtrl.text, gu: _tagGuCtrl.text);
    final title = _resolvePreviewText(lang: _headerPreviewLang, en: _titleEnCtrl.text, gu: _titleGuCtrl.text);
    final subtitle = _resolvePreviewText(lang: _headerPreviewLang, en: _subtitleEnCtrl.text, gu: _subtitleGuCtrl.text);

    final hasContent = tag.isNotEmpty || title.isNotEmpty || subtitle.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F5),
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
            title: 'Live Website Preview (as seen by public visitors)',
            subtitle: 'Real-time updates as you edit fields below',
            selectedLanguage: _headerPreviewLang,
            onLanguageChanged: (val) => setState(() => _headerPreviewLang = val),
          ),
          const Divider(height: 20),
          if (!hasContent)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'Section is currently empty. Enter tagline, headline, and narrative below to preview.',
                textAlign: TextAlign.center,
                style: styles.bodySmall(context).copyWith(
                  color: colors.getSecondaryTextColor(context),
                  fontStyle: FontStyle.italic,
                ),
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
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: styles.h1(context).copyWith(
                      color: colors.getPrimaryTextColor(context),
                      fontSize: isMobile ? 22 : 28,
                    ),
                  ),
                if (title.isNotEmpty && subtitle.isNotEmpty) const SizedBox(height: 10),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: styles.bodyText(context).copyWith(
                      color: colors.getSecondaryTextColor(context),
                      fontSize: isMobile ? 14 : 16,
                      height: 1.6,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. LIVE MILESTONES PREVIEW (Pixel-perfect matching HistoryScreen lines 152-310)
  // ===========================================================================

  Widget _buildLiveMilestonesPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = colors.isDarkMode(context);

    final activeMilestones = widget.store.historyMilestones.where((m) => m.isActive).toList();
    final previewMilestones = activeMilestones.take(3).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F5),
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
            title: 'Live Website Preview (Timeline Milestones)',
            subtitle: 'Real-time updates as you reorder and edit milestones below',
            selectedLanguage: _milestonesPreviewLang,
            onLanguageChanged: (val) => setState(() => _milestonesPreviewLang = val),
          ),
          const Divider(height: 20),
          if (previewMilestones.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Text(
                'No published milestones exist.\nClick "Add Milestone" below to create and publish the first era.',
                textAlign: TextAlign.center,
                style: styles.bodySmall(context).copyWith(
                  color: colors.getSecondaryTextColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: previewMilestones.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final item = previewMilestones[index];
                final badge = _resolvePreviewText(lang: _milestonesPreviewLang, en: item.badgeEn, gu: item.badgeGu);
                final title = _resolvePreviewText(lang: _milestonesPreviewLang, en: item.titleEn, gu: item.titleGu);
                final desc = _resolvePreviewText(lang: _milestonesPreviewLang, en: item.descEn, gu: item.descGu);
                final icon = _iconForMilestone(item.iconName);

                if (isMobile) {
                  return CulturalFrameCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.year,
                              style: styles.editorialSerif(
                                context,
                                size: 17,
                                fontWeight: FontWeight.w700,
                                color: colors.getAccentColor(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: HeritageBadge(
                                label: badge,
                                backgroundColor: colors.heritageGold.withValues(alpha: 0.12),
                                textColor: colors.getAccentColor(context),
                                borderColor: colors.heritageGold.withValues(alpha: 0.35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(icon, size: 18, color: colors.heritageGold),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title.isNotEmpty ? title : 'Milestone Title',
                                style: styles.editorialSerif(
                                  context,
                                  size: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.getPrimaryTextColor(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (desc.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            desc,
                            style: styles.bodyText(context).copyWith(
                              color: colors.getSecondaryTextColor(context),
                              fontSize: 13,
                              height: 1.55,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return CulturalFrameCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Year Pill Column
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.year,
                              style: styles.editorialSerif(
                                context,
                                size: 21,
                                fontWeight: FontWeight.w700,
                                color: colors.getAccentColor(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            HeritageBadge(
                              label: badge,
                              backgroundColor: colors.heritageGold.withValues(alpha: 0.12),
                              textColor: colors.getAccentColor(context),
                              borderColor: colors.heritageGold.withValues(alpha: 0.35),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 56,
                        color: colors.getBorderColor(context),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      // Content Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(icon, size: 18, color: colors.heritageGold),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    title.isNotEmpty ? title : 'Milestone Title',
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
                            if (desc.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                desc,
                                style: styles.bodyText(context).copyWith(
                                  color: colors.getSecondaryTextColor(context),
                                  fontSize: 13.5,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. LIVE CALLOUT CTA PREVIEW (Pixel-perfect matching HistoryScreen lines 313-345)
  // ===========================================================================

  Widget _buildLiveCtaPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isDark = colors.isDarkMode(context);

    final ctaText = _resolvePreviewText(lang: _ctaPreviewLang, en: _ctaTextEnCtrl.text, gu: _ctaTextGuCtrl.text);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark
            ? colors.getSurfaceColor(context).withValues(alpha: 0.7)
            : const Color(0xFFFBF8F5),
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
            title: 'Live Website Preview (Exploration Action)',
            subtitle: 'Real-time updates as you edit button details below',
            selectedLanguage: _ctaPreviewLang,
            onLanguageChanged: (val) => setState(() => _ctaPreviewLang = val),
          ),
          const Divider(height: 20),
          const HeritageDivider(verticalPadding: 16),
          Center(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.heritageMaroon,
                foregroundColor: colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {},
              icon: const Icon(Icons.inventory_2_outlined, size: 18),
              label: Text(
                ctaText.isNotEmpty ? ctaText : 'EXPLORE ARCHIVE',
                style: styles.cleanSans(
                  context,
                  color: colors.white,
                  size: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MILESTONE ADD / EDIT MODAL DIALOG
  // ===========================================================================

  void _openMilestoneDialog([AdminHistoryMilestone? milestone]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final yearCtrl = TextEditingController(text: milestone?.year ?? '');
    final badgeEnCtrl = TextEditingController(text: milestone?.badgeEn ?? 'MILESTONE');
    final badgeGuCtrl = TextEditingController(text: milestone?.badgeGu ?? 'સીમાચિહ્ન');
    final titleEnCtrl = TextEditingController(text: milestone?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: milestone?.titleGu ?? '');
    final descEnCtrl = TextEditingController(text: milestone?.descEn ?? '');
    final descGuCtrl = TextEditingController(text: milestone?.descGu ?? '');

    final maxOrder = widget.store.historyMilestones.isEmpty
        ? 0
        : widget.store.historyMilestones.map((m) => m.order).reduce((a, b) => a > b ? a : b);
    final assignedOrder = milestone?.order ?? (maxOrder + 1);
    final orderCtrl = TextEditingController(text: '#$assignedOrder (Auto-assigned)');

    String imgUrl = milestone?.imageUrl ?? 'assets/images/pavan_putra_logo.png';
    String selectedIcon = milestone?.iconName ?? 'local_fire_department_rounded';
    bool isActive = milestone?.isActive ?? true;

    final availableIcons = <(String, String, IconData)>[
      ('local_fire_department_rounded', 'Aarti & Deepam', Icons.local_fire_department_rounded),
      ('music_note_rounded', 'Music & Orchestra', Icons.music_note_rounded),
      ('military_tech_rounded', 'Honors & Recognition', Icons.military_tech_rounded),
      ('auto_stories_rounded', 'Chhand & Poetry', Icons.auto_stories_rounded),
      ('cloud_done_rounded', 'Digital Archive', Icons.cloud_done_rounded),
      ('temple_hindu_rounded', 'Temple & Sanctity', Icons.temple_hindu_rounded),
      ('stars_rounded', 'Divine Blessings', Icons.stars_rounded),
      ('groups_rounded', 'Community Devotion', Icons.groups_rounded),
      ('volunteer_activism_rounded', 'Seva & Service', Icons.volunteer_activism_rounded),
    ];

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Row(
            children: [
              Icon(
                milestone == null ? Icons.add_circle_outline_rounded : Icons.edit_note_rounded,
                color: colors.heritageGold,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  milestone == null ? 'Add Sacred Milestone' : 'Edit Milestone Details',
                  style: styles.editorialSerif(
                    context,
                    size: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 540.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppImagePicker(
                    label: 'Archival Photograph / Emblem Graphic',
                    initialImageUrl: imgUrl,
                    height: 140,
                    onImageChanged: (url) => setDlgState(() => imgUrl = url),
                  ),
                  const SizedBox(height: 14),

                  // Era Year & Order
                  if (MediaQuery.sizeOf(context).width < 650) ...[
                    MyAppTextFormField(
                      controller: yearCtrl,
                      labelText: 'Festival Era / Year',
                      hintText: 'e.g. ૧૯૭૭ / 1977',
                      prefixIcon: const Icon(Icons.event_note_rounded, size: 18),
                      suffixIcon: MyAppIconButton(
                        icon: const Icon(Icons.g_translate_rounded, size: 18),
                        tooltip: 'Convert numerals to Gujarati (e.g. ૧૯૭૭)',
                        onPressed: () {
                          final val = yearCtrl.text.trim();
                          if (val.isNotEmpty) {
                            const guDigits = {
                              '0': '૦',
                              '1': '૧',
                              '2': '૨',
                              '3': '૩',
                              '4': '૪',
                              '5': '૫',
                              '6': '૬',
                              '7': '૭',
                              '8': '૮',
                              '9': '૯',
                            };
                            final converted = val.split('').map((ch) => guDigits[ch] ?? ch).join('');
                            setDlgState(() => yearCtrl.text = converted);
                          }
                        },
                      ),
                      onChanged: (_) => setDlgState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: orderCtrl,
                      labelText: 'Display Sequence',
                      readOnly: true,
                      enabled: false,
                      prefixIcon: const Icon(Icons.drag_indicator_rounded, size: 18),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: MyAppTextFormField(
                            controller: yearCtrl,
                            labelText: 'Festival Era / Year',
                            hintText: 'e.g. ૧૯૭૭ / 1977',
                            prefixIcon: const Icon(Icons.event_note_rounded, size: 18),
                            suffixIcon: MyAppIconButton(
                              icon: const Icon(Icons.g_translate_rounded, size: 18),
                              tooltip: 'Convert numerals to Gujarati (e.g. ૧૯૭૭)',
                              onPressed: () {
                                final val = yearCtrl.text.trim();
                                if (val.isNotEmpty) {
                                  const guDigits = {
                                    '0': '૦',
                                    '1': '૧',
                                    '2': '૨',
                                    '3': '૩',
                                    '4': '૪',
                                    '5': '૫',
                                    '6': '૬',
                                    '7': '૭',
                                    '8': '૮',
                                    '9': '૯',
                                  };
                                  final converted = val.split('').map((ch) => guDigits[ch] ?? ch).join('');
                                  setDlgState(() => yearCtrl.text = converted);
                                }
                              },
                            ),
                            onChanged: (_) => setDlgState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: MyAppTextFormField(
                            controller: orderCtrl,
                            labelText: 'Display Sequence',
                            readOnly: true,
                            enabled: false,
                            prefixIcon: const Icon(Icons.drag_indicator_rounded, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Category Tag Badge (English + Gujarati)
                  if (MediaQuery.sizeOf(context).width < 650) ...[
                    MyAppTextFormField(
                      controller: badgeEnCtrl,
                      labelText: 'Category Tag (English)',
                      hintText: 'e.g. FOUNDATION',
                      showTranslateIcon: true,
                      targetLanguageController: badgeGuCtrl,
                      onChanged: (_) => setDlgState(() {}),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: badgeGuCtrl,
                      labelText: 'Category Tag (Gujarati)',
                      hintText: 'e.g. સ્થાપના વર્ષ',
                      onChanged: (_) => setDlgState(() {}),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: MyAppTextFormField(
                            controller: badgeEnCtrl,
                            labelText: 'Category Tag (English)',
                            hintText: 'e.g. FOUNDATION',
                            showTranslateIcon: true,
                            targetLanguageController: badgeGuCtrl,
                            onChanged: (_) => setDlgState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MyAppTextFormField(
                            controller: badgeGuCtrl,
                            labelText: 'Category Tag (Gujarati)',
                            hintText: 'e.g. સ્થાપના વર્ષ',
                            onChanged: (_) => setDlgState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Icon Selector
                  Text(
                    'Sacred Milestone Icon Symbol',
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final ic in availableIcons)
                        MyAppIconButtonWithName(
                          icon: ic.$3,
                          name: ic.$2,
                          isSelected: selectedIcon == ic.$1,
                          onPressed: () => setDlgState(() => selectedIcon = ic.$1),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Milestone Title (English + Gujarati)
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    labelText: 'Milestone Headline (English)',
                    hintText: 'e.g. Sacred Foundation at Vankaner Boundary',
                    showTranslateIcon: true,
                    targetLanguageController: titleGuCtrl,
                    onChanged: (_) => setDlgState(() {}),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Milestone Headline (Gujarati)',
                    hintText: 'e.g. વાંકાનેર સીમાડે પવિત્ર સ્થાપના',
                    onChanged: (_) => setDlgState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Milestone Description (English + Gujarati)
                  MyAppTextAreaField(
                    controller: descEnCtrl,
                    labelText: 'Historical Description (English)',
                    hintText: 'Describe historical events and cultural significance...',
                    showTranslateIcon: true,
                    targetLanguageController: descGuCtrl,
                    onChanged: (_) => setDlgState(() {}),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descGuCtrl,
                    labelText: 'Historical Description (Gujarati)',
                    hintText: 'ઐતિહાસિક પ્રસંગો અને સાંસ્કૃતિક મહત્વ...',
                    onChanged: (_) => setDlgState(() {}),
                  ),
                  const SizedBox(height: 14),

                  // Active / Publish Toggle Switch (Matching Admin Home)
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
                                'Publish on Timeline',
                                style: styles.cleanSans(
                                  context,
                                  size: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colors.getPrimaryTextColor(context),
                                ),
                              ),
                              Text(
                                isActive ? 'Visible to public visitors' : 'Draft only (hidden)',
                                style: styles.cleanSans(
                                  context,
                                  size: 11,
                                  color: isActive ? Colors.green : colors.getSecondaryTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.85,
                          child: Switch(
                            value: isActive,
                            activeThumbColor: colors.heritageGold,
                            activeTrackColor: colors.deepMaroon,
                            onChanged: (val) => setDlgState(() => isActive = val),
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
            MyAppTextButton(
              onPressed: () => Navigator.pop(ctx),
              label: 'Cancel',
            ),
            MyAppFillButton.icon(
              onPressed: () {
                final year = yearCtrl.text.trim();
                final titleEn = titleEnCtrl.text.trim();
                final titleGu = titleGuCtrl.text.trim();

                if (year.isEmpty || (titleEn.isEmpty && titleGu.isEmpty)) {
                  MyAppToastMessage.warning(
                    context,
                    title: 'Incomplete Details',
                    description: 'Festival Era / Year and at least one title are required.',
                  );
                  return;
                }

                final order = assignedOrder;

                if (milestone == null) {
                  widget.store.addHistoryMilestone(
                    AdminHistoryMilestone(
                      id: 'hm-${DateTime.now().millisecondsSinceEpoch}',
                      year: year,
                      badgeEn: badgeEnCtrl.text.trim().isNotEmpty ? badgeEnCtrl.text.trim() : 'MILESTONE',
                      badgeGu: badgeGuCtrl.text.trim().isNotEmpty ? badgeGuCtrl.text.trim() : 'સીમાચિહ્ન',
                      titleEn: titleEn,
                      titleGu: titleGu,
                      descEn: descEnCtrl.text.trim(),
                      descGu: descGuCtrl.text.trim(),
                      iconName: selectedIcon,
                      imageUrl: imgUrl,
                      order: order,
                      isActive: isActive,
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Milestone Added',
                    description: '$year milestone successfully preserved and published.',
                  );
                } else {
                  widget.store.updateHistoryMilestone(
                    milestone.copyWith(
                      year: year,
                      badgeEn: badgeEnCtrl.text.trim().isNotEmpty ? badgeEnCtrl.text.trim() : 'MILESTONE',
                      badgeGu: badgeGuCtrl.text.trim().isNotEmpty ? badgeGuCtrl.text.trim() : 'સીમાચિહ્ન',
                      titleEn: titleEn,
                      titleGu: titleGu,
                      descEn: descEnCtrl.text.trim(),
                      descGu: descGuCtrl.text.trim(),
                      iconName: selectedIcon,
                      imageUrl: imgUrl,
                      order: order,
                      isActive: isActive,
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Milestone Updated',
                    description: '$year milestone changes successfully saved.',
                  );
                }
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.check_circle_rounded, size: 16),
              label: milestone == null ? 'Add Milestone' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AdminHistoryMilestone milestone) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: serviceLocator<MyAppColors>().getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Timeline Milestone?',
                style: serviceLocator<MyAppTextStyles>().editorialSerif(
                  context,
                  size: 18,
                  fontWeight: FontWeight.w700,
                  color: serviceLocator<MyAppColors>().getPrimaryTextColor(context),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "${milestone.year} - ${milestone.titleEn.isNotEmpty ? milestone.titleEn : milestone.titleGu}" from the public timeline?',
          style: serviceLocator<MyAppTextStyles>().cleanSans(
            context,
            size: 13,
            color: serviceLocator<MyAppColors>().getSecondaryTextColor(context),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton.icon(
            isDanger: true,
            onPressed: () {
              widget.store.deleteHistoryMilestone(milestone.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Milestone Removed',
                description: '${milestone.year} milestone has been removed from website.',
              );
            },
            icon: const Icon(Icons.delete_forever_rounded, size: 16),
            label: 'Delete',
          ),
        ],
      ),
    );
  }

  void _moveMilestone(AdminHistoryMilestone item, int delta) {
    final list = List<AdminHistoryMilestone>.from(widget.store.historyMilestones);
    final index = list.indexWhere((m) => m.id == item.id);
    if (index == -1) return;

    final targetIndex = index + delta;
    if (targetIndex < 0 || targetIndex >= list.length) return;

    final other = list[targetIndex];
    widget.store.updateHistoryMilestone(item.copyWith(order: other.order));
    widget.store.updateHistoryMilestone(other.copyWith(order: item.order));
  }

  // ===========================================================================
  // BUILD METHOD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminWebsiteContextBanner(
            websitePageTitle: 'History & Heritage Page',
            websiteRoute: '/history',
            explanation:
                'Controls the chronological timeline milestones, introduction narrative, and archive navigation on the public History & Heritage page.',
          ),

          // Main Header Title Row
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            spacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeritageBadge(label: 'WEBSITE CONTENT / HISTORY & HERITAGE'),
                  const SizedBox(height: 6),
                  Text(
                    'History & Heritage Timeline Management',
                    style: styles.editorialSerif(
                      context,
                      size: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w700,
                      color: colors.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage the sacred journey, milestones, and archival records from 1977 to the modern era.',
                    style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MyAppOutlineButton.icon(
                    onPressed: _confirmResetAll,
                    icon: const Icon(Icons.restore_rounded, size: 16),
                    label: 'Reset All',
                  ),
                  MyAppFillButton.icon(
                    onPressed: _saveAllSections,
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: 'Save All Changes',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 1: PAGE HEADER & INTRODUCTION
          // ===================================================================
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeaderCard(
                  context: context,
                  icon: Icons.title_rounded,
                  title: '1. Page Header & Introduction',
                  subtitle:
                      'Controls the grand title, eyebrow badge, and historical narrative opening paragraph on the public History & Heritage page.',
                  actions: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _clearHeader,
                      icon: const Icon(Icons.clear_all_rounded, size: 16),
                      label: 'Clear Section',
                    ),
                    MyAppFillButton.icon(
                      onPressed: _saveHistoryHeader,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Header',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Preview for Section 1
                _buildLiveHeaderPreview(context),
                const SizedBox(height: 18),

                // Dual-Language Input Fields
                _buildDualLanguageField(
                  title: 'Eyebrow Tagline Badge',
                  enLabel: 'Tagline Badge (English)',
                  enCtrl: _tagEnCtrl,
                  guLabel: 'બિરુદ / ટેગ (ગુજરાતી)',
                  guCtrl: _tagGuCtrl,
                  hintText: 'e.g. CHRONOLOGY & MILESTONES',
                ),
                _buildDualLanguageField(
                  title: 'Main Page Headline',
                  enLabel: 'Headline (English)',
                  enCtrl: _titleEnCtrl,
                  guLabel: 'મુખ્ય શીર્ષક (ગુજરાતી)',
                  guCtrl: _titleGuCtrl,
                  hintText: 'e.g. A History of Devotion & Cultural Fortitude.',
                ),
                _buildDualLanguageField(
                  title: 'Narrative Story Introduction',
                  enLabel: 'Introduction (English)',
                  enCtrl: _subtitleEnCtrl,
                  guLabel: 'પરિચય વિગત (ગુજરાતી)',
                  guCtrl: _subtitleGuCtrl,
                  maxLines: 4,
                  hintText: 'Enter narrative historical overview and cultural mission...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 2: TIMELINE MILESTONES & JOURNEY
          // ===================================================================
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeaderCard(
                  context: context,
                  icon: Icons.timeline_rounded,
                  title: '2. Timeline Milestones (${widget.store.historyMilestones.length})',
                  subtitle:
                      'Chronological milestone eras detailing the sacred journey and cultural achievements of the Mandal from 1977 onward.',
                  actions: [
                    MyAppFillButton.icon(
                      onPressed: () => _openMilestoneDialog(),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: 'Add Milestone',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Preview for Section 2
                _buildLiveMilestonesPreview(context),
                const SizedBox(height: 18),

                // Search & Filter Bar
                MyAppTextFormField(
                  controller: _milestoneSearchCtrl,
                  hintText: 'Search milestones by year, title, badge, or description...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  showClearIcon: true,
                  onChanged: (val) => setState(() => _milestoneSearchQuery = val.trim().toLowerCase()),
                ),
                const SizedBox(height: 14),

                // Milestones Reorderable List
                _buildMilestonesList(context),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 3: BOTTOM ARCHIVE EXPLORATION BUTTON (CTA)
          // ===================================================================
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeaderCard(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  title: '3. Bottom Archive Exploration Action',
                  subtitle:
                      'Interactive call-to-action button displayed at the bottom of the timeline inviting visitors to explore the archives.',
                  actions: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _clearCta,
                      icon: const Icon(Icons.clear_all_rounded, size: 16),
                      label: 'Clear Section',
                    ),
                    MyAppFillButton.icon(
                      onPressed: _saveCtaButton,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Action Button',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Preview for Section 3
                _buildLiveCtaPreview(context),
                const SizedBox(height: 18),

                // Button Configuration Field with Destination Page Dropdown (Matching Admin Home)
                _buildButtonConfigField(
                  title: 'Bottom Exploration Action Button',
                  labelEnCtrl: _ctaTextEnCtrl,
                  labelGuCtrl: _ctaTextGuCtrl,
                  routeCtrl: _ctaRouteCtrl,
                  defaultRoute: '/archive',
                  labelText: 'Destination Page to Open (કયા પેજ પર જવું)',
                  helperText: 'Select which website page visitors explore when clicking this timeline button',
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // ===========================================================================
  // MILESTONES LIST BUILDER (Drag & Drop or Filtered View)
  // ===========================================================================

  Widget _buildMilestonesList(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final allMilestones = widget.store.historyMilestones;
    final isFiltering = _milestoneSearchQuery.isNotEmpty;

    final filtered = !isFiltering
        ? allMilestones
        : allMilestones.where((m) {
            return m.year.toLowerCase().contains(_milestoneSearchQuery) ||
                m.badgeEn.toLowerCase().contains(_milestoneSearchQuery) ||
                m.badgeGu.toLowerCase().contains(_milestoneSearchQuery) ||
                m.titleEn.toLowerCase().contains(_milestoneSearchQuery) ||
                m.titleGu.toLowerCase().contains(_milestoneSearchQuery) ||
                m.descEn.toLowerCase().contains(_milestoneSearchQuery) ||
                m.descGu.toLowerCase().contains(_milestoneSearchQuery);
          }).toList();

    if (allMilestones.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.timeline_rounded, size: 40, color: colors.heritageGold.withValues(alpha: 0.6)),
            const SizedBox(height: 10),
            Text(
              'No historical milestones added yet.',
              style: styles.editorialSerif(
                context,
                size: 16,
                fontWeight: FontWeight.w600,
                color: colors.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Click "Add Milestone" to create and publish the first era to the historical timeline.',
              textAlign: TextAlign.center,
              style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 14),
            MyAppFillButton.icon(
              onPressed: () => _openMilestoneDialog(),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: 'Add Milestone',
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
            'No milestones match "$_milestoneSearchQuery".',
            style: styles.cleanSans(context, size: 13, color: colors.getSecondaryTextColor(context)),
          ),
        ),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      child: isFiltering
          ? Column(
              children: [
                for (int i = 0; i < filtered.length; i++)
                  Container(
                    key: ValueKey(filtered[i].id),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildMilestoneAdminCard(
                      filtered[i],
                      i,
                      filtered.length,
                      colors,
                      styles,
                      canDrag: false,
                    ),
                  ),
              ],
            )
          : ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: allMilestones.length,
              onReorderItem: (oldIndex, newIndex) {
                widget.store.reorderHistoryMilestones(oldIndex, newIndex);
                setState(() {});
              },
              itemBuilder: (context, i) {
                final item = allMilestones[i];
                return Container(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildMilestoneAdminCard(
                    item,
                    i,
                    allMilestones.length,
                    colors,
                    styles,
                    canDrag: true,
                  ),
                );
              },
            ),
    );
  }

  // ===========================================================================
  // INDIVIDUAL MILESTONE CARD IN ADMIN LIST (Pixel-Perfect Heritage Design)
  // ===========================================================================

  Widget _buildMilestoneAdminCard(
    AdminHistoryMilestone item,
    int index,
    int totalCount,
    MyAppColors colors,
    MyAppTextStyles styles, {
    bool canDrag = false,
  }) {
    final isDark = colors.isDarkMode(context);
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: colors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? colors.heritageGold.withValues(alpha: 0.25) : colors.getBorderColor(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            // Mobile Top Bar: Drag + Emblem + Year Chip + Status Badge + Switch
            Row(
              children: [
                if (canDrag)
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 20),
                    ),
                  ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.deepMaroon,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.heritageGold, width: 1.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: item.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                            errorWidget: (_, _, _) => Icon(_iconForMilestone(item.iconName), color: colors.heritageGold, size: 18),
                          )
                        : (item.imageUrl.isNotEmpty && item.imageUrl.startsWith('assets/'))
                            ? Image.asset(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(_iconForMilestone(item.iconName), color: colors.heritageGold, size: 18),
                              )
                            : Icon(_iconForMilestone(item.iconName), color: colors.heritageGold, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.deepMaroon,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colors.heritageGold, width: 1),
                        ),
                        child: Text(
                          item.year,
                          style: styles.cleanSans(
                            context,
                            size: 11,
                            fontWeight: FontWeight.w800,
                            color: colors.heritageGold,
                          ),
                        ),
                      ),
                      HeritageBadge(
                        label: item.isActive ? 'PUBLISHED' : 'DRAFT',
                        backgroundColor: item.isActive
                            ? colors.heritageGold.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.15),
                        textColor: item.isActive ? colors.getAccentColor(context) : Colors.grey,
                        borderColor: item.isActive
                            ? colors.heritageGold.withValues(alpha: 0.4)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: item.isActive ? 'Visible on Website' : 'Hidden from Website',
                  child: Switch(
                    value: item.isActive,
                    activeThumbColor: colors.heritageGold,
                    activeTrackColor: colors.heritageMaroon,
                    onChanged: (val) {
                      final updated = item.copyWith(isActive: val);
                      widget.store.updateHistoryMilestone(updated);
                      MyAppToastMessage.info(
                        context,
                        title: 'Status Updated',
                        description: '${item.year} milestone is now ${val ? "published" : "hidden"}.',
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Category Tag Badge (Full width, no truncation!)
            if (item.badgeEn.isNotEmpty) ...[
              HeritageBadge(
                label: item.badgeEn,
                backgroundColor: colors.heritageGold.withValues(alpha: 0.12),
                textColor: colors.getAccentColor(context),
                borderColor: colors.heritageGold.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 6),
            ],

            // English Title (Full width)
            Text(
              item.titleEn.isNotEmpty ? item.titleEn : item.titleGu,
              style: styles.editorialSerif(
                context,
                size: 16,
                fontWeight: FontWeight.w700,
                color: colors.getPrimaryTextColor(context),
              ),
            ),

            // Gujarati Title (Full width)
            if (item.titleGu.isNotEmpty && item.titleEn.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                item.titleGu,
                style: styles.devotionalMotto(context, size: 13, color: colors.heritageGold),
              ),
            ],

            // Description (Full width)
            if (item.descEn.isNotEmpty || item.descGu.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.descEn.isNotEmpty ? item.descEn : item.descGu,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: styles.cleanSans(
                  context,
                  size: 12,
                  color: colors.getSecondaryTextColor(context),
                  height: 1.45,
                ),
              ),
            ],
          ] else ...[
            // Desktop Top Row: Drag Handle + Emblem + Year Title & Badges + Active/Publish Switch
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (canDrag)
                  ReorderableDragStartListener(
                    index: index,
                    child: Tooltip(
                      message: 'Drag to reorder',
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 20),
                      ),
                    ),
                  ),

                // Archival Emblem / Thumbnail / Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.deepMaroon,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.heritageGold, width: 1.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: item.imageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                            errorWidget: (_, _, _) => Icon(_iconForMilestone(item.iconName), color: colors.heritageGold, size: 20),
                          )
                        : (item.imageUrl.isNotEmpty && item.imageUrl.startsWith('assets/'))
                            ? Image.asset(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(_iconForMilestone(item.iconName), color: colors.heritageGold, size: 20),
                              )
                            : Icon(_iconForMilestone(item.iconName), color: colors.heritageGold, size: 20),
                  ),
                ),
                const SizedBox(width: 10),

                // Era & Milestone Title & Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colors.deepMaroon,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.heritageGold, width: 1),
                            ),
                            child: Text(
                              item.year,
                              style: styles.cleanSans(
                                context,
                                size: 11,
                                fontWeight: FontWeight.w800,
                                color: colors.heritageGold,
                              ),
                            ),
                          ),
                          if (item.badgeEn.isNotEmpty)
                            HeritageBadge(
                              label: item.badgeEn,
                              backgroundColor: colors.heritageGold.withValues(alpha: 0.12),
                              textColor: colors.getAccentColor(context),
                              borderColor: colors.heritageGold.withValues(alpha: 0.35),
                            ),
                          HeritageBadge(
                            label: item.isActive ? 'PUBLISHED' : 'DRAFT',
                            backgroundColor: item.isActive
                                ? colors.heritageGold.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                            textColor: item.isActive ? colors.getAccentColor(context) : Colors.grey,
                            borderColor: item.isActive
                                ? colors.heritageGold.withValues(alpha: 0.4)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.titleEn.isNotEmpty ? item.titleEn : item.titleGu,
                        style: styles.editorialSerif(
                          context,
                          size: 15.5,
                          fontWeight: FontWeight.w700,
                          color: colors.getPrimaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Publish / Active Switch
                Tooltip(
                  message: item.isActive ? 'Visible on Website' : 'Hidden from Website',
                  child: Switch(
                    value: item.isActive,
                    activeThumbColor: colors.heritageGold,
                    activeTrackColor: colors.heritageMaroon,
                    onChanged: (val) {
                      final updated = item.copyWith(isActive: val);
                      widget.store.updateHistoryMilestone(updated);
                      MyAppToastMessage.info(
                        context,
                        title: 'Status Updated',
                        description: '${item.year} milestone is now ${val ? "published" : "hidden"}.',
                      );
                    },
                  ),
                ),
              ],
            ),

            if (item.titleGu.isNotEmpty && item.titleEn.isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 54),
                child: Text(
                  item.titleGu,
                  style: styles.devotionalMotto(context, size: 13, color: colors.heritageGold),
                ),
              ),
            ],

            if (item.descEn.isNotEmpty || item.descGu.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 54),
                child: Text(
                  item.descEn.isNotEmpty ? item.descEn : item.descGu,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styles.cleanSans(
                    context,
                    size: 12,
                    color: colors.getSecondaryTextColor(context),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ],

          const SizedBox(height: 10),
          Divider(height: 1, color: colors.getBorderColor(context)),
          const SizedBox(height: 8),

          // Bottom Actions Row (Move Up/Down, Edit, Delete)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _buildMiniBadge(
                    icon: _iconForMilestone(item.iconName),
                    label: _labelForMilestoneIcon(item.iconName),
                    colors: colors,
                  ),
                  if (item.badgeGu.isNotEmpty && item.badgeGu != item.badgeEn)
                    _buildMiniBadge(
                      icon: Icons.language_rounded,
                      label: item.badgeGu,
                      colors: colors,
                    ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index > 0 && !canDrag)
                    MyAppIconButton(
                      tooltip: 'Move Up',
                      icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                      onPressed: () => _moveMilestone(item, -1),
                    ),
                  if (index < totalCount - 1 && !canDrag)
                    MyAppIconButton(
                      tooltip: 'Move Down',
                      icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                      onPressed: () => _moveMilestone(item, 1),
                    ),
                  MyAppIconButton(
                    tooltip: 'Edit Milestone',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: colors.heritageGold,
                    onPressed: () => _openMilestoneDialog(item),
                  ),
                  const SizedBox(width: 4),
                  MyAppIconButton(
                    tooltip: 'Delete Milestone',
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: Colors.redAccent,
                    onPressed: () => _confirmDelete(item),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge({
    required IconData icon,
    required String label,
    required MyAppColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.getAccentColor(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.heritageGold),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.getAccentColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
