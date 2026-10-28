import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/localization/google_translation_service.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/heritage_divider.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../data/admin_data_store.dart';

/// Full management view for History & Heritage timeline milestones,
/// page introduction, and archive exploration call-to-action.
class AdminHistoryPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminHistoryPageView({super.key, required this.store});

  @override
  State<AdminHistoryPageView> createState() => _AdminHistoryPageViewState();
}

class _AdminHistoryPageViewState extends State<AdminHistoryPageView> {
  // Page Header Controllers
  late final TextEditingController _tagEnCtrl;
  late final TextEditingController _tagGuCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleGuCtrl;
  late final TextEditingController _subtitleEnCtrl;
  late final TextEditingController _subtitleGuCtrl;

  // Bottom CTA Button Controllers
  late final TextEditingController _ctaTextEnCtrl;
  late final TextEditingController _ctaTextGuCtrl;
  late final TextEditingController _ctaRouteCtrl;

  String _previewLang = 'gu';
  String _previewTheme = 'auto'; // 'auto', 'dark', 'light'
  bool _isTranslatingHeader = false;
  bool _isTranslatingCta = false;

  @override
  void initState() {
    super.initState();
    final s = widget.store;

    _tagEnCtrl = TextEditingController(
      text: s.getTextOverride('en', 'history_tag'),
    );
    _tagGuCtrl = TextEditingController(
      text: s.getTextOverride('gu', 'history_tag'),
    );

    _titleEnCtrl = TextEditingController(
      text: s.getTextOverride('en', 'history_title'),
    );
    _titleGuCtrl = TextEditingController(
      text: s.getTextOverride('gu', 'history_title'),
    );

    _subtitleEnCtrl = TextEditingController(
      text: s.getTextOverride('en', 'history_subtitle'),
    );
    _subtitleGuCtrl = TextEditingController(
      text: s.getTextOverride('gu', 'history_subtitle'),
    );

    _ctaTextEnCtrl = TextEditingController(
      text: s.getTextOverride('en', 'sec_02_cta'),
    );
    _ctaTextGuCtrl = TextEditingController( 
      text: s.getTextOverride('gu', 'sec_02_cta'),
    );
    _ctaRouteCtrl = TextEditingController(
      text: s.getTextOverride('en', 'history_cta_route'),
    );
  }

  @override
  void dispose() {
    _tagEnCtrl.dispose();
    _tagGuCtrl.dispose();
    _titleEnCtrl.dispose();
    _titleGuCtrl.dispose();
    _subtitleEnCtrl.dispose();
    _subtitleGuCtrl.dispose();
    _ctaTextEnCtrl.dispose();
    _ctaTextGuCtrl.dispose();
    _ctaRouteCtrl.dispose();
    super.dispose();
  }

  // --- SAVE ACTIONS ---
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

  // --- TRANSLATION ACTIONS ---
  Future<void> _autoTranslateHeader() async {
    setState(() => _isTranslatingHeader = true);
    try {
      if (_tagEnCtrl.text.isNotEmpty && _tagGuCtrl.text.isEmpty) {
        _tagGuCtrl.text = await GoogleTranslationService.instance.translateToGujarati(_tagEnCtrl.text.trim());
      }
      if (_titleEnCtrl.text.isNotEmpty && _titleGuCtrl.text.isEmpty) {
        _titleGuCtrl.text = await GoogleTranslationService.instance.translateToGujarati(_titleEnCtrl.text.trim());
      }
      if (_subtitleEnCtrl.text.isNotEmpty && _subtitleGuCtrl.text.isEmpty) {
        _subtitleGuCtrl.text = await GoogleTranslationService.instance.translateToGujarati(_subtitleEnCtrl.text.trim());
      }
      if (mounted) {
        MyAppToastMessage.success(context, title: 'Translation Complete', description: 'Gujarati fields auto-filled.');
      }
    } catch (_) {
      if (mounted) {
        MyAppToastMessage.warning(context, title: 'Translation Notice', description: 'Please enter Gujarati translation manually.');
      }
    } finally {
      if (mounted) setState(() => _isTranslatingHeader = false);
    }
  }

  Future<void> _autoTranslateCta() async {
    setState(() => _isTranslatingCta = true);
    try {
      if (_ctaTextEnCtrl.text.isNotEmpty && _ctaTextGuCtrl.text.isEmpty) {
        _ctaTextGuCtrl.text = await GoogleTranslationService.instance.translateToGujarati(_ctaTextEnCtrl.text.trim());
      }
      if (mounted) {
        MyAppToastMessage.success(context, title: 'Translation Complete', description: 'Gujarati button label auto-filled.');
      }
    } catch (_) {
      if (mounted) {
        MyAppToastMessage.warning(context, title: 'Translation Notice', description: 'Please enter Gujarati label manually.');
      }
    } finally {
      if (mounted) setState(() => _isTranslatingCta = false);
    }
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
  }

  // --- MILESTONES MANAGEMENT ---
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
    final orderCtrl = TextEditingController(
      text: (milestone?.order ?? (widget.store.historyMilestones.length + 1)).toString(),
    );
    String imgUrl = milestone?.imageUrl ?? 'assets/images/pavan_putra_logo.jpg';
    String selectedIcon = milestone?.iconName ?? 'local_fire_department_rounded';
    bool isTranslatingDialog = false;

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
                  style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 580 ? double.infinity : 540,
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
                                const guDigits = {'0': '૦', '1': '૧', '2': '૨', '3': '૩', '4': '૪', '5': '૫', '6': '૬', '7': '૭', '8': '૮', '9': '૯'};
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
                          keyboardType: TextInputType.number,
                          labelText: 'Display Sequence',
                          prefixIcon: const Icon(Icons.format_list_numbered_rounded, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category Tag Badge (English + Gujarati)
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
                  const SizedBox(height: 14),

                  // Icon Selector
                  Text(
                    'Sacred Milestone Icon Symbol',
                    style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w700),
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

                  // Quick Auto-Translate Dialog Fields Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: MyAppTextButton.icon(
                      isCompact: true,
                      onPressed: isTranslatingDialog
                          ? null
                          : () async {
                              setDlgState(() => isTranslatingDialog = true);
                              try {
                                if (badgeEnCtrl.text.isNotEmpty && badgeGuCtrl.text.isEmpty) {
                                  badgeGuCtrl.text = await GoogleTranslationService.instance
                                      .translateToGujarati(badgeEnCtrl.text.trim());
                                }
                                if (titleEnCtrl.text.isNotEmpty && titleGuCtrl.text.isEmpty) {
                                  titleGuCtrl.text = await GoogleTranslationService.instance
                                      .translateToGujarati(titleEnCtrl.text.trim());
                                }
                                if (descEnCtrl.text.isNotEmpty && descGuCtrl.text.isEmpty) {
                                  descGuCtrl.text = await GoogleTranslationService.instance
                                      .translateToGujarati(descEnCtrl.text.trim());
                                }
                              } catch (_) {} finally {
                                setDlgState(() => isTranslatingDialog = false);
                              }
                            },
                      isLoading: isTranslatingDialog,
                      icon: const Icon(Icons.g_translate_rounded, size: 16),
                      label: 'Auto-Translate Details to Gujarati',
                    ),
                  ),

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

                final order = int.tryParse(orderCtrl.text.trim()) ?? 1;

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
        title: const Text('Delete Timeline Milestone?'),
        content: Text(
          'Are you sure you want to remove "${milestone.year} - ${milestone.titleEn.isNotEmpty ? milestone.titleEn : milestone.titleGu}" from the public timeline?',
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
                    'History & Heritage Timeline',
                    style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Manage the sacred journey, milestones, and archival records from 1977 to the modern era.',
                    style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                  ),
                ],
              ),
              MyAppFillButton.icon(
                onPressed: () => _openMilestoneDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: 'Add Milestone',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SECTION 1: PAGE HEADER & INTRODUCTION
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.title_rounded, color: colors.heritageGold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '1. Page Header & Introduction',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          MyAppOutlineButton.icon(
                            onPressed: _isTranslatingHeader ? null : _autoTranslateHeader,
                            isLoading: _isTranslatingHeader,
                            icon: const Icon(Icons.g_translate_rounded, size: 15),
                            label: 'Auto-Translate',
                          ),
                          const SizedBox(width: 8),
                          MyAppIconButton(
                            tooltip: 'Clear Header Fields',
                            icon: const Icon(Icons.clear_all_rounded, size: 18),
                            color: Colors.redAccent,
                            onPressed: _clearHeader,
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.title_rounded, color: colors.heritageGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '1. Page Header & Introduction',
                          style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                      MyAppOutlineButton.icon(
                        onPressed: _isTranslatingHeader ? null : _autoTranslateHeader,
                        isLoading: _isTranslatingHeader,
                        icon: const Icon(Icons.g_translate_rounded, size: 15),
                        label: 'Auto-Translate',
                      ),
                      const SizedBox(width: 6),
                      MyAppIconButton(
                        tooltip: 'Clear Header Fields',
                        icon: const Icon(Icons.clear_all_rounded, size: 18),
                        color: Colors.redAccent,
                        onPressed: _clearHeader,
                      ),
                    ],
                  ),
                const SizedBox(height: 14),

                // Tagline Badge (English & Gujarati)
                isMobile
                    ? Column(
                        children: [
                          MyAppTextFormField(
                            controller: _tagEnCtrl,
                            labelText: 'Eyebrow Tagline Badge (English)',
                            hintText: 'e.g. CHRONOLOGY & MILESTONES',
                            showTranslateIcon: true,
                            targetLanguageController: _tagGuCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          MyAppTextFormField(
                            controller: _tagGuCtrl,
                            labelText: 'Eyebrow Tagline Badge (Gujarati)',
                            hintText: 'e.g. ઇતિહાસ અને સીમાચિહ્નો',
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: MyAppTextFormField(
                              controller: _tagEnCtrl,
                              labelText: 'Eyebrow Tagline Badge (English)',
                              hintText: 'e.g. CHRONOLOGY & MILESTONES',
                              showTranslateIcon: true,
                              targetLanguageController: _tagGuCtrl,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyAppTextFormField(
                              controller: _tagGuCtrl,
                              labelText: 'Eyebrow Tagline Badge (Gujarati)',
                              hintText: 'e.g. ઇતિહાસ અને સીમાચિહ્નો',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),

                // Main Headline Title (English & Gujarati)
                isMobile
                    ? Column(
                        children: [
                          MyAppTextFormField(
                            controller: _titleEnCtrl,
                            labelText: 'Main Page Headline (English)',
                            hintText: 'e.g. A History of Devotion & Cultural Fortitude.',
                            showTranslateIcon: true,
                            targetLanguageController: _titleGuCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          MyAppTextFormField(
                            controller: _titleGuCtrl,
                            labelText: 'Main Page Headline (Gujarati)',
                            hintText: 'e.g. ભક્તિ અને સાંસ્કૃતિક અસ્મિતાનો ઇતિહાસ.',
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: MyAppTextFormField(
                              controller: _titleEnCtrl,
                              labelText: 'Main Page Headline (English)',
                              hintText: 'e.g. A History of Devotion & Cultural Fortitude.',
                              showTranslateIcon: true,
                              targetLanguageController: _titleGuCtrl,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyAppTextFormField(
                              controller: _titleGuCtrl,
                              labelText: 'Main Page Headline (Gujarati)',
                              hintText: 'e.g. ભક્તિ અને સાંસ્કૃતિક અસ્મિતાનો ઇતિહાસ.',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),

                // Subtitle / Narrative Introduction
                isMobile
                    ? Column(
                        children: [
                          MyAppTextAreaField(
                            controller: _subtitleEnCtrl,
                            labelText: 'Narrative Introduction (English)',
                            hintText: 'Enter narrative overview for the history section...',
                            showTranslateIcon: true,
                            targetLanguageController: _subtitleGuCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          MyAppTextAreaField(
                            controller: _subtitleGuCtrl,
                            labelText: 'Narrative Introduction (Gujarati)',
                            hintText: 'ઇતિહાસ વિભાગ માટે પરિચય...',
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyAppTextAreaField(
                              controller: _subtitleEnCtrl,
                              labelText: 'Narrative Introduction (English)',
                              hintText: 'Enter narrative overview for the history section...',
                              showTranslateIcon: true,
                              targetLanguageController: _subtitleGuCtrl,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyAppTextAreaField(
                              controller: _subtitleGuCtrl,
                              labelText: 'Narrative Introduction (Gujarati)',
                              hintText: 'ઇતિહાસ વિભાગ માટે પરિચય...',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),

                Align(
                  alignment: isMobile ? Alignment.center : Alignment.centerRight,
                  child: MyAppFillButton.icon(
                    isFullWidth: isMobile,
                    onPressed: _saveHistoryHeader,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: 'Save Header Changes',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 2: TIMELINE MILESTONES
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.history_edu_rounded, color: colors.heritageGold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '2. Timeline Milestones (${widget.store.historyMilestones.length})',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    MyAppFillButton.icon(
                      onPressed: () => _openMilestoneDialog(),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: 'Add Milestone',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (widget.store.historyMilestones.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: colors.getBackgroundColor(context),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.getBorderColor(context)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.timeline_rounded, size: 40, color: colors.heritageGold.withValues(alpha: 0.6)),
                        const SizedBox(height: 10),
                        Text(
                          'No historical milestones added yet.',
                          style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w600),
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
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < widget.store.historyMilestones.length; i++) ...[
                        _buildMilestoneAdminCard(
                          widget.store.historyMilestones[i],
                          i,
                          widget.store.historyMilestones.length,
                          colors,
                          styles,
                          isMobile,
                        ),
                        if (i < widget.store.historyMilestones.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 3: BOTTOM ARCHIVE EXPLORATION BUTTON (CTA)
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.inventory_2_outlined, color: colors.heritageGold, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '3. Bottom Archive Exploration Button',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyAppOutlineButton.icon(
                        onPressed: _isTranslatingCta ? null : _autoTranslateCta,
                        isLoading: _isTranslatingCta,
                        icon: const Icon(Icons.g_translate_rounded, size: 15),
                        label: 'Auto-Translate',
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, color: colors.heritageGold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '3. Bottom Archive Exploration Button',
                          style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                        ),
                      ),
                      MyAppOutlineButton.icon(
                        onPressed: _isTranslatingCta ? null : _autoTranslateCta,
                        isLoading: _isTranslatingCta,
                        icon: const Icon(Icons.g_translate_rounded, size: 15),
                        label: 'Auto-Translate',
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Text(
                  'Controls the interactive button displayed below the timeline on the public page.',
                  style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                ),
                const SizedBox(height: 14),

                isMobile
                    ? Column(
                        children: [
                          MyAppTextFormField(
                            controller: _ctaTextEnCtrl,
                            labelText: 'Button Text (English)',
                            hintText: 'e.g. Explore Full Archival Records',
                            showTranslateIcon: true,
                            targetLanguageController: _ctaTextGuCtrl,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          MyAppTextFormField(
                            controller: _ctaTextGuCtrl,
                            labelText: 'Button Text (Gujarati)',
                            hintText: 'e.g. સમગ્ર ઐતિહાસિક સંગ્રહ જુઓ',
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: MyAppTextFormField(
                              controller: _ctaTextEnCtrl,
                              labelText: 'Button Text (English)',
                              hintText: 'e.g. Explore Full Archival Records',
                              showTranslateIcon: true,
                              targetLanguageController: _ctaTextGuCtrl,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyAppTextFormField(
                              controller: _ctaTextGuCtrl,
                              labelText: 'Button Text (Gujarati)',
                              hintText: 'e.g. સમગ્ર ઐતિહાસિક સંગ્રહ જુઓ',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 14),

                // Friendly Destination Page Selector Dropdown (Non-Technical)
                MyAppDropdown.pageDestination(
                  controller: _ctaRouteCtrl,
                  defaultRoute: '/archive',
                  labelText: 'Destination Page to Open (કયા પેજ પર જવું)',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: isMobile ? Alignment.center : Alignment.centerRight,
                  child: MyAppFillButton.icon(
                    isFullWidth: isMobile,
                    onPressed: _saveCtaButton,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: 'Save Action Button',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 4: LIVE WEBSITE PREVIEW (MATCHING HOME SCREEN STANDARD)
          _buildLiveHistoryPreview(colors, styles, isMobile),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // --- INDIVIDUAL MILESTONE CARD IN ADMIN LIST ---
  Widget _buildMilestoneAdminCard(
    AdminHistoryMilestone item,
    int index,
    int totalCount,
    MyAppColors colors,
    MyAppTextStyles styles,
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.getBorderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Archival Thumbnail or Icon Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.heritageMaroon.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: item.imageUrl.startsWith('http')
                  ? Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(_iconForMilestone(item.iconName), color: colors.heritageGold),
                    )
                  : Icon(_iconForMilestone(item.iconName), color: colors.heritageGold),
            ),
          ),
          const SizedBox(width: 12),

          // Milestone Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.deepMaroon,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.heritageGold, width: 1),
                      ),
                      child: Text(
                        item.year,
                        style: styles.cleanSans(context, size: 11, fontWeight: FontWeight.w800, color: colors.heritageGold),
                      ),
                    ),
                    if (item.badgeEn.isNotEmpty)
                      HeritageBadge(
                        label: item.badgeEn,
                        backgroundColor: colors.heritageGold.withValues(alpha: 0.12),
                        textColor: colors.getAccentColor(context),
                        borderColor: colors.heritageGold.withValues(alpha: 0.35),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: item.titleEn.isNotEmpty ? item.titleEn : item.titleGu,
                        style: styles.bodyText(context).copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (item.titleGu.isNotEmpty && item.titleEn.isNotEmpty) ...[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: '(${item.titleGu})',
                          style: styles.bodySmall(context).copyWith(color: colors.heritageGold),
                        ),
                      ],
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.descEn.isNotEmpty || item.descGu.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.descEn.isNotEmpty ? item.descEn : item.descGu,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: styles.bodySmall(context).copyWith(color: colors.getSecondaryTextColor(context)),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons: Reorder, Edit, Delete
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index > 0)
                MyAppIconButton(
                  tooltip: 'Move Up',
                  icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                  onPressed: () => _moveMilestone(item, -1),
                ),
              if (index < totalCount - 1)
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
    );
  }

  // --- LIVE WEBSITE PREVIEW (MATCHING HOME SCREEN STANDARD) ---
  Widget _buildLiveHistoryPreview(MyAppColors colors, MyAppTextStyles styles, bool isMobile) {
    final isGu = _previewLang == 'gu';

    final tag = isGu
        ? (_tagGuCtrl.text.isNotEmpty ? _tagGuCtrl.text : _tagEnCtrl.text)
        : (_tagEnCtrl.text.isNotEmpty ? _tagEnCtrl.text : _tagGuCtrl.text);

    final title = isGu
        ? (_titleGuCtrl.text.isNotEmpty ? _titleGuCtrl.text : _titleEnCtrl.text)
        : (_titleEnCtrl.text.isNotEmpty ? _titleEnCtrl.text : _titleGuCtrl.text);

    final subtitle = isGu
        ? (_subtitleGuCtrl.text.isNotEmpty ? _subtitleGuCtrl.text : _subtitleEnCtrl.text)
        : (_subtitleEnCtrl.text.isNotEmpty ? _subtitleEnCtrl.text : _subtitleGuCtrl.text);

    final ctaText = isGu
        ? (_ctaTextGuCtrl.text.isNotEmpty ? _ctaTextGuCtrl.text : _ctaTextEnCtrl.text)
        : (_ctaTextEnCtrl.text.isNotEmpty ? _ctaTextEnCtrl.text : _ctaTextGuCtrl.text);

    final milestones = widget.store.historyMilestones.take(2).toList();

    final appIsDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIsDark = _previewTheme == 'auto' ? appIsDark : (_previewTheme == 'dark');

    final containerBg = effectiveIsDark ? const Color(0xFF141212) : const Color(0xFFFAF7F0);
    final containerBorder = colors.heritageGold.withValues(alpha: effectiveIsDark ? 0.45 : 0.35);
    final primaryTextColor = effectiveIsDark ? colors.ivory : colors.black;
    final secondaryTextColor = effectiveIsDark ? colors.stone : const Color(0xFF4A443E);
    final cardBg = effectiveIsDark ? const Color(0xFF1B1818) : Colors.white;
    final cardBorder = effectiveIsDark ? const Color(0xFF332F2F) : const Color(0xFFDDD7CB);
    final accentColor = effectiveIsDark ? colors.lightGold : colors.heritageMaroon;

    final previewThemeData = effectiveIsDark
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0F0E0E),
            cardColor: const Color(0xFF1B1818),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFFAF7F0),
            cardColor: Colors.white,
          );

    return Theme(
      data: previewThemeData,
      child: Builder(
        builder: (previewCtx) => Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: containerBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: containerBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: effectiveIsDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Preview Header with Responsive Controls (Language & Theme Mode)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isTight = constraints.maxWidth < 620;

                  final langSelector = MyAppSegmentView.language(
                    selectedLanguage: _previewLang,
                    onLanguageChanged: (val) => setState(() => _previewLang = val),
                  );

                  final themeSelector = MyAppSegmentView<String>(
                    selectedValue: _previewTheme,
                    onValueChanged: (val) => setState(() => _previewTheme = val),
                    segments: const [
                      MyAppSegmentItem(
                        value: 'auto',
                        icon: Icons.brightness_auto_rounded,
                        label: 'Auto',
                      ),
                      MyAppSegmentItem(
                        value: 'dark',
                        icon: Icons.dark_mode_rounded,
                        label: 'Dark',
                      ),
                      MyAppSegmentItem(
                        value: 'light',
                        icon: Icons.light_mode_rounded,
                        label: 'Light',
                      ),
                    ],
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
                                'Live Website Preview (History & Heritage)',
                                style: styles.editorialSerif(
                                  context,
                                  size: 14,
                                  fontWeight: FontWeight.w700,
                                  color: effectiveIsDark ? colors.heritageGold : colors.heritageMaroon,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            langSelector,
                            themeSelector,
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Icon(Icons.visibility_rounded, color: colors.heritageGold, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Live Website Preview (History & Heritage)',
                          style: styles.editorialSerif(
                            context,
                            size: 14,
                            fontWeight: FontWeight.w700,
                            color: effectiveIsDark ? colors.heritageGold : colors.heritageMaroon,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      langSelector,
                      const SizedBox(width: 8),
                      themeSelector,
                    ],
                  );
                },
              ),
              Divider(
                height: 24,
                color: effectiveIsDark
                    ? colors.heritageGold.withValues(alpha: 0.25)
                    : colors.getBorderColor(context).withValues(alpha: 0.5),
              ),

              // Live Public Page Simulation
              if (tag.isNotEmpty) ...[
                HeritageBadge(
                  label: tag,
                  backgroundColor: colors.heritageGold.withValues(alpha: 0.12),
                  textColor: accentColor,
                  borderColor: colors.heritageGold.withValues(alpha: 0.35),
                ),
                const SizedBox(height: 12),
              ],

              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: styles.editorialSerif(
                    previewCtx,
                    size: isMobile ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (subtitle.isNotEmpty) ...[
                Text(
                  subtitle,
                  style: styles.cleanSans(
                    previewCtx,
                    size: isMobile ? 13 : 15,
                    color: secondaryTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Timeline Cards in Live Preview
              if (milestones.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Text(
                    'No milestones exist. Public website will show authentic fallback timeline.',
                    style: styles.bodySmall(previewCtx).copyWith(
                      color: secondaryTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (final item in milestones) ...[
                      CulturalFrameCard(
                        padding: EdgeInsets.all(isMobile ? 14 : 20),
                        backgroundColor: cardBg,
                        borderColor: cardBorder,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.year,
                                  style: styles.editorialSerif(
                                    previewCtx,
                                    size: isMobile ? 18 : 22,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: HeritageBadge(
                                    label: isGu && item.badgeGu.isNotEmpty ? item.badgeGu : item.badgeEn,
                                    backgroundColor: colors.heritageGold.withValues(alpha: 0.12),
                                    textColor: accentColor,
                                    borderColor: colors.heritageGold.withValues(alpha: 0.35),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(_iconForMilestone(item.iconName), size: 18, color: colors.heritageGold),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isGu && item.titleGu.isNotEmpty ? item.titleGu : item.titleEn,
                                    style: styles.editorialSerif(
                                      previewCtx,
                                      size: isMobile ? 16 : 18,
                                      fontWeight: FontWeight.w700,
                                      color: primaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isGu && item.descGu.isNotEmpty ? item.descGu : item.descEn,
                              style: styles.cleanSans(
                                previewCtx,
                                size: 13,
                                color: secondaryTextColor,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),

              const HeritageDivider(verticalPadding: 24),

              // Live Bottom Exploration Button Simulation
              Center(
                child: MyAppFillButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.inventory_2_outlined, size: 17),
                  label: ctaText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
