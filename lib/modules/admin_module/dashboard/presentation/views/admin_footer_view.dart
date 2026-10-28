import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/localization/google_translation_service.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/heritage_divider.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Full comprehensive CRUD management view for Footer Module & Social Media Links
/// Manages Taglines, Sacred Mottos, Quick Links (Columns 1 & 2), Social Channels, Contact Details, and Copyright Notice.
class AdminFooterView extends StatefulWidget {
  final AdminDataStore store;

  const AdminFooterView({super.key, required this.store});

  @override
  State<AdminFooterView> createState() => _AdminFooterViewState();
}

class _AdminFooterViewState extends State<AdminFooterView> {
  // Section 1: Branding, Tagline & Motto
  late final TextEditingController _taglineEnCtrl;
  late final TextEditingController _taglineGuCtrl;
  late final TextEditingController _mottoEnCtrl;
  late final TextEditingController _mottoGuCtrl;
  late final TextEditingController _appTitleEnCtrl;
  late final TextEditingController _appTitleGuCtrl;
  late final TextEditingController _appSubtitleEnCtrl;
  late final TextEditingController _appSubtitleGuCtrl;

  // Section 2 & 3: Columns 1 & 2 Titles
  late final TextEditingController _col1TitleEnCtrl;
  late final TextEditingController _col1TitleGuCtrl;
  late final TextEditingController _col2TitleEnCtrl;
  late final TextEditingController _col2TitleGuCtrl;

  // Section 4: Social Channels Heading
  late final TextEditingController _socialTitleEnCtrl;
  late final TextEditingController _socialTitleGuCtrl;

  // Section 5: Location & Contact
  late final TextEditingController _locationEnCtrl;
  late final TextEditingController _locationGuCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;

  // Section 6: Copyright
  late final TextEditingController _copyrightEnCtrl;
  late final TextEditingController _copyrightGuCtrl;

  String _previewLang = 'gu';
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final s = widget.store.settings;
    _taglineEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'footer_tagline') ?? '',
    );
    _taglineGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'footer_tagline') ?? '',
    );
    _mottoEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'footer_motto') ?? '',
    );
    _mottoGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'footer_motto') ?? '',
    );
    _appTitleEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'app_title') ?? s.mandalNameEn,
    );
    _appTitleGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'app_title') ?? s.mandalNameGu,
    );
    _appSubtitleEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'app_subtitle') ?? 'RAJKOT • GUJARAT • EST. 1977',
    );
    _appSubtitleGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'app_subtitle') ?? 'રાજકોટ • ગુજરાત • સ્થાપના ૧૯૭૭',
    );

    _col1TitleEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'footer_links_title') ?? 'EXPLORE ARCHIVE',
    );
    _col1TitleGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'footer_links_title') ?? 'સંગ્રહ અન્વેષણ',
    );
    _col2TitleEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'footer_links2_title') ?? 'ABOUT THE MANDAL',
    );
    _col2TitleGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'footer_links2_title') ?? 'મંડળ વિશે',
    );

    _socialTitleEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'footer_social') ?? 'OFFICIAL CHANNELS',
    );
    _socialTitleGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'footer_social') ?? 'સત્તાવાર માધ્યમો',
    );

    _locationEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'footer_location') ?? s.address,
    );
    _locationGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'footer_location') ?? s.address,
    );
    _phoneCtrl = TextEditingController(text: s.contactPhone);
    _emailCtrl = TextEditingController(text: s.contactEmail);

    _copyrightEnCtrl = TextEditingController(
      text: widget.store.getTextOverride('en', 'footer_copyright') ?? '',
    );
    _copyrightGuCtrl = TextEditingController(
      text: widget.store.getTextOverride('gu', 'footer_copyright') ?? '',
    );
  }


  @override
  void dispose() {
    _taglineEnCtrl.dispose();
    _taglineGuCtrl.dispose();
    _mottoEnCtrl.dispose();
    _mottoGuCtrl.dispose();
    _appTitleEnCtrl.dispose();
    _appTitleGuCtrl.dispose();
    _appSubtitleEnCtrl.dispose();
    _appSubtitleGuCtrl.dispose();
    _col1TitleEnCtrl.dispose();
    _col1TitleGuCtrl.dispose();
    _col2TitleEnCtrl.dispose();
    _col2TitleGuCtrl.dispose();
    _socialTitleEnCtrl.dispose();
    _socialTitleGuCtrl.dispose();
    _locationEnCtrl.dispose();
    _locationGuCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _copyrightEnCtrl.dispose();
    _copyrightGuCtrl.dispose();
    super.dispose();
  }

  Future<void> _translateField(TextEditingController sourceCtrl, TextEditingController targetCtrl) async {
    final text = sourceCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final translated = await GoogleTranslationService.instance.translateToGujarati(text);
      if (translated.isNotEmpty) {
        targetCtrl.text = translated;
      }
    } catch (_) {}
    if (mounted) setState(() => _isTranslating = false);
  }

  Future<void> _translateAllToGujarati() async {
    setState(() => _isTranslating = true);
    final service = GoogleTranslationService.instance;
    try {
      if (_taglineGuCtrl.text.isEmpty && _taglineEnCtrl.text.isNotEmpty) {
        _taglineGuCtrl.text = await service.translateToGujarati(_taglineEnCtrl.text);
      }
      if (_mottoGuCtrl.text.isEmpty && _mottoEnCtrl.text.isNotEmpty) {
        _mottoGuCtrl.text = await service.translateToGujarati(_mottoEnCtrl.text);
      }
      if (_col1TitleGuCtrl.text.isEmpty && _col1TitleEnCtrl.text.isNotEmpty) {
        _col1TitleGuCtrl.text = await service.translateToGujarati(_col1TitleEnCtrl.text);
      }
      if (_col2TitleGuCtrl.text.isEmpty && _col2TitleEnCtrl.text.isNotEmpty) {
        _col2TitleGuCtrl.text = await service.translateToGujarati(_col2TitleEnCtrl.text);
      }
      if (_socialTitleGuCtrl.text.isEmpty && _socialTitleEnCtrl.text.isNotEmpty) {
        _socialTitleGuCtrl.text = await service.translateToGujarati(_socialTitleEnCtrl.text);
      }
      if (_locationGuCtrl.text.isEmpty && _locationEnCtrl.text.isNotEmpty) {
        _locationGuCtrl.text = await service.translateToGujarati(_locationEnCtrl.text);
      }
      if (_copyrightGuCtrl.text.isEmpty && _copyrightEnCtrl.text.isNotEmpty) {
        _copyrightGuCtrl.text = await service.translateToGujarati(_copyrightEnCtrl.text);
      }
      if (mounted) {
        MyAppToastMessage.info(context, title: 'Auto Translation Done', description: 'Gujarati fields populated via Google Cloud Translate.');
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    if (mounted) setState(() => _isTranslating = false);
  }

  Future<void> _saveAllFooterChanges() async {
    await widget.store.saveFooterContentSettings(
      taglineEn: _taglineEnCtrl.text.trim(),
      taglineGu: _taglineGuCtrl.text.trim(),
      mottoEn: _mottoEnCtrl.text.trim(),
      mottoGu: _mottoGuCtrl.text.trim(),
      col1TitleEn: _col1TitleEnCtrl.text.trim(),
      col1TitleGu: _col1TitleGuCtrl.text.trim(),
      col2TitleEn: _col2TitleEnCtrl.text.trim(),
      col2TitleGu: _col2TitleGuCtrl.text.trim(),
      socialTitleEn: _socialTitleEnCtrl.text.trim(),
      socialTitleGu: _socialTitleGuCtrl.text.trim(),
      locationEn: _locationEnCtrl.text.trim(),
      locationGu: _locationGuCtrl.text.trim(),
      copyrightEn: _copyrightEnCtrl.text.trim(),
      copyrightGu: _copyrightGuCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      appTitleEn: _appTitleEnCtrl.text.trim(),
      appTitleGu: _appTitleGuCtrl.text.trim(),
      appSubtitleEn: _appSubtitleEnCtrl.text.trim(),
      appSubtitleGu: _appSubtitleGuCtrl.text.trim(),
    );

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'Website Footer Saved',
        description: 'All footer content and contact details saved and published to the live website.',
      );
    }
  }


  void _confirmClearAllFooter() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Footer Fields?'),
        content: const Text(
          'This will empty all footer content fields (tagline, motto, copyright, titles).\n'
          'Any empty field will be neatly hidden from the website until you enter new details.',
        ),
        actions: [
          MyAppTextButton(
            onPressed: () => Navigator.pop(ctx),
            label: 'Cancel',
          ),
          MyAppFillButton(
            isDanger: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.store.clearAllFooterFields();
              setState(() {
                _taglineEnCtrl.clear();
                _taglineGuCtrl.clear();
                _mottoEnCtrl.clear();
                _mottoGuCtrl.clear();
                _col1TitleEnCtrl.clear();
                _col1TitleGuCtrl.clear();
                _col2TitleEnCtrl.clear();
                _col2TitleGuCtrl.clear();
                _socialTitleEnCtrl.clear();
                _socialTitleGuCtrl.clear();
                _copyrightEnCtrl.clear();
                _copyrightGuCtrl.clear();
              });
              if (mounted) {
                MyAppToastMessage.warning(
                  context,
                  title: 'Footer Fields Cleared',
                  description: 'All footer text fields have been cleared and hidden from the website.',
                );
              }
            },
            label: 'Clear All',
          ),
        ],
      ),
    );
  }

  // --- Modal Dialog: Add / Edit Footer Navigation Link ---
  void _openFooterLinkDialog([AdminFooterLink? link, String defaultColumn = 'col1']) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final titleEnCtrl = TextEditingController(text: link?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: link?.titleGu ?? '');
    final urlCtrl = TextEditingController(text: link?.url ?? '/about');
    String selectedCol = link?.column ?? defaultColumn;
    int order = link?.order ?? (widget.store.footerLinks.where((l) => l.column == selectedCol).length + 1);
    bool isExternal = link?.isExternal ?? false;
    bool isEnabled = link?.isEnabled ?? true;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dlgCtx, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Text(
            link == null ? 'Add Quick Navigation Link' : 'Edit Quick Navigation Link',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column Placement Selector
                  Text('Target Column', style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Col 1 (Explore Archive)', style: TextStyle(fontSize: 12)),
                        selected: selectedCol == 'col1',
                        onSelected: (val) {
                          if (val) setDlgState(() => selectedCol = 'col1');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Col 2 (About Mandal)', style: TextStyle(fontSize: 12)),
                        selected: selectedCol == 'col2',
                        onSelected: (val) {
                          if (val) setDlgState(() => selectedCol = 'col2');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Link Title (EN) + Auto-translate
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    labelText: 'Link Title (English)',
                    hintText: 'e.g. EXPLORE ARCHIVE',
                    showTranslateIcon: true,
                    targetLanguageController: titleGuCtrl,
                  ),
                  const SizedBox(height: 14),

                  // Link Title (GU)
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Link Title (Gujarati)',
                    hintText: 'e.g. સંગ્રહ અન્વેષણ',
                  ),
                  const SizedBox(height: 14),

                  // External Link Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('External Website Link', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Enable if this link goes to an external site or custom URL', style: TextStyle(fontSize: 11)),
                    value: isExternal,
                    onChanged: (val) => setDlgState(() {
                      isExternal = val;
                      if (!isExternal && !urlCtrl.text.startsWith('/')) {
                        urlCtrl.text = '/about';
                      }
                    }),
                  ),
                  const SizedBox(height: 10),

                  // Destination Page Dropdown or External Link Input
                  if (isExternal)
                    MyAppTextFormField(
                      controller: urlCtrl,
                      labelText: 'External Website URL (https://...)',
                      hintText: 'https://example.com or custom link',
                      prefixIcon: const Icon(Icons.open_in_new_rounded),
                    )
                  else
                    MyAppDropdown.pageDestination(
                      controller: urlCtrl,
                      defaultRoute: '/about',
                      labelText: 'Website Page to Open (કયા પેજ પર જવું)',
                      onChanged: (selectedPath) {
                        setDlgState(() {
                          final match = kAdminPublicPages.where((p) => p.path == selectedPath).firstOrNull;
                          if (match != null) {
                            if (titleEnCtrl.text.trim().isEmpty) {
                              titleEnCtrl.text = match.labelEn;
                            }
                            if (titleGuCtrl.text.trim().isEmpty) {
                              titleGuCtrl.text = match.labelGu;
                            }
                          }
                        });
                      },
                    ),

                  const SizedBox(height: 14),

                  // Order & Active status
                  Builder(
                    builder: (context) {
                      final isNarrow = MediaQuery.sizeOf(context).width < 540;

                      final orderBox = Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: colors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.getBorderColor(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyAppIconButton(
                              icon: const Icon(Icons.remove_rounded, size: 18),
                              tooltip: 'Decrease Order',
                              onPressed: order > 1 ? () => setDlgState(() => order--) : null,
                            ),
                            Text(
                              'Order $order',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            MyAppIconButton(
                              icon: const Icon(Icons.add_rounded, size: 18),
                              tooltip: 'Increase Order',
                              onPressed: () => setDlgState(() => order++),
                            ),
                          ],
                        ),
                      );

                      final statusBox = Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: colors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.getBorderColor(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEnabled ? 'Active' : 'Hidden',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isEnabled ? colors.heritageMaroon : colors.getMutedTextColor(context),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isEnabled,
                                activeThumbColor: colors.heritageMaroon,
                                activeTrackColor: colors.heritageGold.withValues(alpha: 0.5),
                                onChanged: (val) => setDlgState(() => isEnabled = val),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Display Order',
                              style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.w600, color: colors.getSecondaryTextColor(context)),
                            ),
                            const SizedBox(height: 6),
                            orderBox,
                            const SizedBox(height: 12),
                            Text(
                              'Status',
                              style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.w600, color: colors.getSecondaryTextColor(context)),
                            ),
                            const SizedBox(height: 6),
                            statusBox,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Display Order',
                                  style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.w600, color: colors.getSecondaryTextColor(context)),
                                ),
                                const SizedBox(height: 6),
                                orderBox,
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.w600, color: colors.getSecondaryTextColor(context)),
                                ),
                                const SizedBox(height: 6),
                                statusBox,
                              ],
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
          actions: [
            MyAppTextButton(
              onPressed: () => Navigator.pop(ctx),
              label: 'Cancel',
            ),
            MyAppFillButton.icon(
              icon: const Icon(Icons.save_rounded, size: 16),
              label: 'Save Link',
              onPressed: () async {
                final en = titleEnCtrl.text.trim();
                final gu = titleGuCtrl.text.trim();
                final url = urlCtrl.text.trim();
                if (en.isEmpty && gu.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Title Required', description: 'Please provide at least an English or Gujarati title.');
                  return;
                }
                final newLink = AdminFooterLink(
                  id: link?.id ?? 'flink-${DateTime.now().millisecondsSinceEpoch}',
                  titleEn: en.isNotEmpty ? en : gu,
                  titleGu: gu.isNotEmpty ? gu : en,
                  url: url.isNotEmpty ? url : '/',
                  column: selectedCol,
                  order: order,
                  isEnabled: isEnabled,
                  isExternal: isExternal,
                );
                await widget.store.saveFooterLink(newLink);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  setState(() {});
                  MyAppToastMessage.success(context, title: 'Footer Link Saved', description: '"${newLink.titleEn}" saved successfully.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Modal Dialog: Add / Edit Social Channel ---
  void _openFooterSocialDialog([AdminFooterSocialLink? social]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final platformCtrl = TextEditingController(text: social?.platform ?? '');
    final urlCtrl = TextEditingController(text: social?.url ?? '');
    String selectedIcon = social?.iconKey ?? 'youtube';
    int order = social?.order ?? (widget.store.footerSocialLinks.length + 1);
    bool isEnabled = social?.isEnabled ?? true;

    final icons = [
      {'key': 'youtube', 'label': 'YouTube', 'icon': Icons.play_arrow_rounded, 'color': Colors.red},
      {'key': 'instagram', 'label': 'Instagram', 'icon': Icons.camera_alt_outlined, 'color': Colors.purple},
      {'key': 'facebook', 'label': 'Facebook', 'icon': Icons.public_rounded, 'color': Colors.blue},
      {'key': 'whatsapp', 'label': 'WhatsApp', 'icon': Icons.chat_rounded, 'color': Colors.green},
      {'key': 'twitter', 'label': 'Twitter / X', 'icon': Icons.tag_rounded, 'color': Colors.lightBlue},
      {'key': 'telegram', 'label': 'Telegram', 'icon': Icons.send_rounded, 'color': Colors.blueAccent},
      {'key': 'globe', 'label': 'Website', 'icon': Icons.language_rounded, 'color': Colors.teal},
      {'key': 'link', 'label': 'Other Link', 'icon': Icons.link_rounded, 'color': Colors.amber},
    ];

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dlgCtx, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Text(
            social == null ? 'Add Official Social Channel' : 'Edit Official Social Channel',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Social Media Icon', style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((item) {
                      final isSel = selectedIcon == item['key'];
                      return InkWell(
                        onTap: () => setDlgState(() {
                          selectedIcon = item['key'] as String;
                          if (platformCtrl.text.isEmpty) {
                            platformCtrl.text = item['label'] as String;
                          }
                        }),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? colors.heritageGold.withValues(alpha: 0.2) : colors.getSurfaceColor(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? colors.heritageGold : colors.getBorderColor(context),
                              width: isSel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item['icon'] as IconData, size: 16, color: item['color'] as Color),
                              const SizedBox(width: 6),
                              Text(item['label'] as String, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  MyAppTextFormField(
                    controller: platformCtrl,
                    labelText: 'Platform Name',
                    hintText: 'e.g. YouTube, Instagram, Facebook',
                  ),
                  const SizedBox(height: 14),

                  MyAppTextFormField(
                    controller: urlCtrl,
                    labelText: 'Target URL / Handle / Phone',
                    hintText: 'e.g. https://youtube.com/@... or +919876543210',
                    prefixIcon: const Icon(Icons.link_rounded),
                  ),
                  const SizedBox(height: 14),

                  // Order & Active status
                  Builder(
                    builder: (context) {
                      final isNarrow = MediaQuery.sizeOf(context).width < 540;

                      final orderBox = Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: colors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.getBorderColor(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MyAppIconButton(
                              icon: const Icon(Icons.remove_rounded, size: 18),
                              tooltip: 'Decrease Order',
                              onPressed: order > 1 ? () => setDlgState(() => order--) : null,
                            ),
                            Text(
                              'Order $order',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            MyAppIconButton(
                              icon: const Icon(Icons.add_rounded, size: 18),
                              tooltip: 'Increase Order',
                              onPressed: () => setDlgState(() => order++),
                            ),
                          ],
                        ),
                      );

                      final statusBox = Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: colors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.getBorderColor(context)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEnabled ? 'Active' : 'Hidden',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: isEnabled ? colors.heritageMaroon : colors.getMutedTextColor(context),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isEnabled,
                                activeThumbColor: colors.heritageMaroon,
                                activeTrackColor: colors.heritageGold.withValues(alpha: 0.5),
                                onChanged: (val) => setDlgState(() => isEnabled = val),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Display Order',
                              style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.w600, color: colors.getSecondaryTextColor(context)),
                            ),
                            const SizedBox(height: 6),
                            orderBox,
                            const SizedBox(height: 12),
                            Text(
                              'Status',
                              style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.w600, color: colors.getSecondaryTextColor(context)),
                            ),
                            const SizedBox(height: 6),
                            statusBox,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Display Order',
                                  style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.w600, color: colors.getSecondaryTextColor(context)),
                                ),
                                const SizedBox(height: 6),
                                orderBox,
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Status',
                                  style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.w600, color: colors.getSecondaryTextColor(context)),
                                ),
                                const SizedBox(height: 6),
                                statusBox,
                              ],
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
          actions: [
            MyAppTextButton(
              onPressed: () => Navigator.pop(ctx),
              label: 'Cancel',
            ),
            MyAppFillButton.icon(
              icon: const Icon(Icons.save_rounded, size: 16),
              label: 'Save Channel',
              onPressed: () async {
                final platform = platformCtrl.text.trim();
                final url = urlCtrl.text.trim();
                if (platform.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Platform Name Required', description: 'Please provide a platform name.');
                  return;
                }
                final newSoc = AdminFooterSocialLink(
                  id: social?.id ?? 'fsoc-${DateTime.now().millisecondsSinceEpoch}',
                  platform: platform,
                  url: url,
                  iconKey: selectedIcon,
                  order: order,
                  isEnabled: isEnabled,
                );
                await widget.store.saveFooterSocialLink(newSoc);
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  setState(() {});
                  MyAppToastMessage.success(context, title: 'Social Channel Saved', description: '"${newSoc.platform}" saved successfully.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteLink(AdminFooterLink link) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Quick Link?'),
        content: Text('Permanently remove "${link.titleEn.isNotEmpty ? link.titleEn : link.titleGu}" from website footer?'),
        actions: [
          MyAppTextButton(
            onPressed: () => Navigator.pop(ctx),
            label: 'Cancel',
          ),
          MyAppFillButton(
            isDanger: true,
            onPressed: () async {
              await widget.store.deleteFooterLink(link.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                setState(() {});
                MyAppToastMessage.warning(context, title: 'Link Removed', description: 'Quick link removed from website.');
              }
            },
            label: 'Delete',
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSocial(AdminFooterSocialLink soc) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Social Channel?'),
        content: Text('Permanently remove "${soc.platform}" channel from website footer?'),
        actions: [
          MyAppTextButton(
            onPressed: () => Navigator.pop(ctx),
            label: 'Cancel',
          ),
          MyAppFillButton(
            isDanger: true,
            onPressed: () async {
              await widget.store.deleteFooterSocialLink(soc.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                setState(() {});
                MyAppToastMessage.warning(context, title: 'Channel Removed', description: '${soc.platform} channel removed from website.');
              }
            },
            label: 'Delete',
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = context.isMobile;

    final col1Links = widget.store.footerLinks.where((l) => l.column == 'col1').toList();
    final col2Links = widget.store.footerLinks.where((l) => l.column == 'col2').toList();
    final socialLinks = widget.store.footerSocialLinks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminWebsiteContextBanner(
            websitePageTitle: 'Global Website Footer (All Pages)',
            websiteRoute: '/',
            explanation: 'Controls all global footer elements across the entire website: Mandal branding, sacred mottos, Column 1 & 2 quick navigation links, official social channels, location & contacts, and copyright statement.',
          ),
          const SizedBox(height: 12),

          // Header Bar with Quick Action Buttons
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 14,
            spacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeritageBadge(label: 'LAYOUT & GLOBAL BRANDING / FOOTER MODULE'),
                  const SizedBox(height: 6),
                  Text(
                    'Footer & Navigation Management',
                    style: styles.editorialSerif(context, size: 24, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Live website footer management with dual-language Gujarati & English support.',
                    style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                  ),
                ],
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  MyAppOutlineButton.icon(
                    isLoading: _isTranslating,
                    onPressed: _translateAllToGujarati,
                    icon: const Icon(Icons.g_translate_rounded, size: 16),
                    label: 'Auto-Translate All to Gujarati',
                  ),
                  MyAppFillButton.icon(
                    onPressed: _saveAllFooterChanges,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: 'Save Footer Changes',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SECTION 1: MANDAL BRANDING, MOTTO & TAGLINE
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: colors.getAccentColor(context), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '1. Mandal Branding, Sacred Mottos & Taglines',
                        style: styles.editorialSerif(context, size: isMobile ? 16 : 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    MyAppIconButton.translate(
                      tooltip: 'Translate Tagline & Motto',
                      onPressed: () {
                        _translateField(_taglineEnCtrl, _taglineGuCtrl);
                        _translateField(_mottoEnCtrl, _mottoGuCtrl);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (isMobile) ...[
                  MyAppTextFormField(
                    controller: _appTitleEnCtrl,
                    labelText: 'Mandal Name (English)',
                    hintText: 'e.g. Shri Pavan Putra Garbi Mandal',
                    showTranslateIcon: true,
                    targetLanguageController: _appTitleGuCtrl,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _appTitleGuCtrl,
                    labelText: 'Mandal Name (Gujarati)',
                    hintText: 'e.g. શ્રી પવન પુત્ર ગરબી મંડળ',
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _appSubtitleEnCtrl,
                    labelText: 'Mandal Subtitle (English)',
                    hintText: 'e.g. Traditional Navratri Mahotsav',
                    showTranslateIcon: true,
                    targetLanguageController: _appSubtitleGuCtrl,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _appSubtitleGuCtrl,
                    labelText: 'Mandal Subtitle (Gujarati)',
                    hintText: 'e.g. પારંપરિક નવરાત્રી મહોત્સવ',
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _appTitleEnCtrl,
                          labelText: 'Mandal Name (English)',
                          hintText: 'e.g. Shri Pavan Putra Garbi Mandal',
                          showTranslateIcon: true,
                          targetLanguageController: _appTitleGuCtrl,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _appTitleGuCtrl,
                          labelText: 'Mandal Name (Gujarati)',
                          hintText: 'e.g. શ્રી પવન પુત્ર ગરબી મંડળ',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _appSubtitleEnCtrl,
                          labelText: 'Mandal Subtitle (English)',
                          hintText: 'e.g. Traditional Navratri Mahotsav',
                          showTranslateIcon: true,
                          targetLanguageController: _appSubtitleGuCtrl,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _appSubtitleGuCtrl,
                          labelText: 'Mandal Subtitle (Gujarati)',
                          hintText: 'e.g. પારંપરિક નવરાત્રી મહોત્સવ',
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),

                MyAppTextAreaField(
                  controller: _taglineEnCtrl,
                  minLines: 2,
                  maxLines: 4,
                  labelText: 'Footer Tagline (English)',
                  hintText: 'Enter Mandal cultural tagline in English...',
                  showTranslateIcon: true,
                  targetLanguageController: _taglineGuCtrl,
                ),
                const SizedBox(height: 12),
                MyAppTextAreaField(
                  controller: _taglineGuCtrl,
                  minLines: 2,
                  maxLines: 4,
                  labelText: 'Footer Tagline (Gujarati)',
                  hintText: 'મંડળની સાંસ્કૃતિક ટેગલાઈન ગુજરાતીમાં દાખલ કરો...',
                ),
                const SizedBox(height: 14),

                if (isMobile) ...[
                  MyAppTextFormField(
                    controller: _mottoEnCtrl,
                    labelText: 'Sacred Devotional Motto (English / Romanized)',
                    hintText: 'e.g. Jai Mataji',
                    showTranslateIcon: true,
                    targetLanguageController: _mottoGuCtrl,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _mottoGuCtrl,
                    labelText: 'Sacred Devotional Motto (Gujarati)',
                    hintText: 'e.g. જય માતાજી',
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _mottoEnCtrl,
                          labelText: 'Sacred Devotional Motto (English / Romanized)',
                          hintText: 'e.g. Jai Mataji',
                          showTranslateIcon: true,
                          targetLanguageController: _mottoGuCtrl,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _mottoGuCtrl,
                          labelText: 'Sacred Devotional Motto (Gujarati)',
                          hintText: 'e.g. જય માતાજી',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 2: COLUMN 1 QUICK NAVIGATION LINKS
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.explore_outlined, color: colors.getAccentColor(context), size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '2. Quick Links: Column 1 (Explore Archive)',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    MyAppFillButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: 'Add Link',
                      onPressed: () => _openFooterLinkDialog(null, 'col1'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (isMobile) ...[
                  MyAppTextFormField(
                    controller: _col1TitleEnCtrl,
                    labelText: 'Column 1 Header (English)',
                    hintText: 'e.g. Explore Archive',
                    showTranslateIcon: true,
                    targetLanguageController: _col1TitleGuCtrl,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _col1TitleGuCtrl,
                    labelText: 'Column 1 Header (Gujarati)',
                    hintText: 'e.g. સંગ્રહ અન્વેષણ',
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _col1TitleEnCtrl,
                          labelText: 'Column 1 Header (English)',
                          hintText: 'e.g. Explore Archive',
                          showTranslateIcon: true,
                          targetLanguageController: _col1TitleGuCtrl,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _col1TitleGuCtrl,
                          labelText: 'Column 1 Header (Gujarati)',
                          hintText: 'e.g. સંગ્રહ અન્વેષણ',
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                if (col1Links.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.getBorderColor(context)),
                    ),
                    child: Text(
                      'No links in Column 1. Click "Add Link" to add new navigation links.',
                      style: styles.cleanSans(context, size: 12.5, color: colors.getMutedTextColor(context)),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: col1Links.length,
                    // ignore: deprecated_member_use
                    onReorder: (oldIdx, newIdx) {
                      if (oldIdx < newIdx) newIdx -= 1;
                      widget.store.reorderFooterLinks('col1', oldIdx, newIdx);
                    },
                    itemBuilder: (context, index) {
                      final item = col1Links[index];
                      return _buildLinkRow(context, item, colors, styles, Key(item.id), index);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 3: COLUMN 2 MANDAL LINKS
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: colors.getAccentColor(context), size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '3. Quick Links: Column 2 (About The Mandal)',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    MyAppFillButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: 'Add Link',
                      onPressed: () => _openFooterLinkDialog(null, 'col2'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (isMobile) ...[
                  MyAppTextFormField(
                    controller: _col2TitleEnCtrl,
                    labelText: 'Column 2 Header (English)',
                    hintText: 'e.g. About Mandal',
                    showTranslateIcon: true,
                    targetLanguageController: _col2TitleGuCtrl,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _col2TitleGuCtrl,
                    labelText: 'Column 2 Header (Gujarati)',
                    hintText: 'e.g. મંડળ વિશે',
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _col2TitleEnCtrl,
                          labelText: 'Column 2 Header (English)',
                          hintText: 'e.g. About Mandal',
                          showTranslateIcon: true,
                          targetLanguageController: _col2TitleGuCtrl,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _col2TitleGuCtrl,
                          labelText: 'Column 2 Header (Gujarati)',
                          hintText: 'e.g. મંડળ વિશે',
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                if (col2Links.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.getBorderColor(context)),
                    ),
                    child: Text(
                      'No links in Column 2. Click "Add Link" to add new navigation links.',
                      style: styles.cleanSans(context, size: 12.5, color: colors.getMutedTextColor(context)),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: col2Links.length,
                    // ignore: deprecated_member_use
                    onReorder: (oldIdx, newIdx) {
                      if (oldIdx < newIdx) newIdx -= 1;
                      widget.store.reorderFooterLinks('col2', oldIdx, newIdx);
                    },
                    itemBuilder: (context, index) {
                      final item = col2Links[index];
                      return _buildLinkRow(context, item, colors, styles, Key(item.id), index);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 4: OFFICIAL SOCIAL MEDIA CHANNELS
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.share_rounded, color: colors.getAccentColor(context), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '4. Official Social Channels & Connect Links',
                        style: styles.editorialSerif(context, size: isMobile ? 16 : 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MyAppFillButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: isMobile ? 'Add' : 'Add Channel',
                      onPressed: () => _openFooterSocialDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (isMobile) ...[
                  MyAppTextFormField(
                    controller: _socialTitleEnCtrl,
                    labelText: 'Social Section Heading (English)',
                    hintText: 'e.g. Connect With Us',
                    showTranslateIcon: true,
                    targetLanguageController: _socialTitleGuCtrl,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _socialTitleGuCtrl,
                    labelText: 'Social Section Heading (Gujarati)',
                    hintText: 'e.g. અમારી સાથે જોડાઓ',
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _socialTitleEnCtrl,
                          labelText: 'Social Section Heading (English)',
                          hintText: 'e.g. Connect With Us',
                          showTranslateIcon: true,
                          targetLanguageController: _socialTitleGuCtrl,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _socialTitleGuCtrl,
                          labelText: 'Social Section Heading (Gujarati)',
                          hintText: 'e.g. અમારી સાથે જોડાઓ',
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                if (socialLinks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.getBorderColor(context)),
                    ),
                    child: Text(
                      'No social media links configured. Click "Add Channel" to add new social media links.',
                      style: styles.cleanSans(context, size: 12.5, color: colors.getMutedTextColor(context)),
                    ),
                  )
                else
                  Column(
                    children: socialLinks.map((soc) {
                      if (isMobile) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: colors.getBorderColor(context)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: colors.getCardBackgroundColor(context),
                                      child: Icon(_getSocialIcon(soc.iconKey), color: colors.getAccentColor(context), size: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        soc.platform,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colors.getSurfaceColor(context),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text('Order: ${soc.order}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        soc.url.isNotEmpty ? soc.url : 'No URL provided',
                                        style: TextStyle(fontSize: 11.5, color: colors.getSecondaryTextColor(context)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 28,
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Switch(
                                              value: soc.isEnabled,
                                              activeTrackColor: colors.heritageGold,
                                              onChanged: (val) {
                                                widget.store.toggleFooterSocialLinkEnabled(soc.id);
                                              },
                                            ),
                                          ),
                                        ),
                                        MyAppIconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Channel',
                                          onPressed: () => _openFooterSocialDialog(soc),
                                        ),
                                        MyAppIconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                          color: Colors.redAccent,
                                          tooltip: 'Delete Channel',
                                          onPressed: () => _confirmDeleteSocial(soc),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colors.getBorderColor(context)),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.getCardBackgroundColor(context),
                            child: Icon(_getSocialIcon(soc.iconKey), color: colors.getAccentColor(context), size: 20),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  soc.platform,
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.getSurfaceColor(context),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Order: ${soc.order}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            soc.url.isNotEmpty ? soc.url : 'No URL provided',
                            style: TextStyle(fontSize: 12, color: colors.getSecondaryTextColor(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: soc.isEnabled,
                                activeTrackColor: colors.heritageGold,
                                onChanged: (val) {
                                  widget.store.toggleFooterSocialLinkEnabled(soc.id);
                                },
                              ),
                              MyAppIconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                tooltip: 'Edit Channel',
                                onPressed: () => _openFooterSocialDialog(soc),
                              ),
                              MyAppIconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                color: Colors.redAccent,
                                tooltip: 'Delete Channel',
                                onPressed: () => _confirmDeleteSocial(soc),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 5: LOCATION, PHONE & EMAIL COORDINATES
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, color: colors.getAccentColor(context), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '5. Location, Mandir Address & Contact Coordinates',
                        style: styles.editorialSerif(context, size: isMobile ? 16 : 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    MyAppIconButton.translate(
                      tooltip: 'Translate Location',
                      onPressed: () => _translateField(_locationEnCtrl, _locationGuCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                MyAppTextAreaField(
                  controller: _locationEnCtrl,
                  minLines: 2,
                  maxLines: 4,
                  labelText: 'Footer Address / Location (English)',
                  hintText: 'Enter Mandir address in English...',
                  showTranslateIcon: true,
                  targetLanguageController: _locationGuCtrl,
                ),
                const SizedBox(height: 12),

                MyAppTextAreaField(
                  controller: _locationGuCtrl,
                  minLines: 2,
                  maxLines: 4,
                  labelText: 'Footer Address / Location (Gujarati)',
                  hintText: 'મંદિરનું સરનામું ગુજરાતીમાં દાખલ કરો...',
                ),
                const SizedBox(height: 14),

                if (isMobile) ...[
                  MyAppTextFormField(
                    controller: _phoneCtrl,
                    labelText: 'Contact Phone Number',
                    hintText: '+91 98765 43210',
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _emailCtrl,
                    labelText: 'Official Email Address',
                    hintText: 'info@pavanputragarbi.org',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _phoneCtrl,
                          labelText: 'Contact Phone Number',
                          hintText: '+91 98765 43210',
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _emailCtrl,
                          labelText: 'Official Email Address',
                          hintText: 'info@pavanputragarbi.org',
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 6: COPYRIGHT & HERITAGE ATTRIBUTION
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.copyright_rounded, color: colors.getAccentColor(context), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '6. Footer Copyright & Cultural Heritage Notice',
                        style: styles.editorialSerif(context, size: isMobile ? 16 : 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    MyAppIconButton.translate(
                      tooltip: 'Translate Copyright',
                      onPressed: () => _translateField(_copyrightEnCtrl, _copyrightGuCtrl),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                MyAppTextAreaField(
                  controller: _copyrightEnCtrl,
                  minLines: 2,
                  maxLines: 4,
                  labelText: 'Copyright Notice (English)',
                  hintText: 'Enter copyright notice in English...',
                  showTranslateIcon: true,
                  targetLanguageController: _copyrightGuCtrl,
                ),
                const SizedBox(height: 12),

                MyAppTextAreaField(
                  controller: _copyrightGuCtrl,
                  minLines: 2,
                  maxLines: 4,
                  labelText: 'Copyright Notice (Gujarati)',
                  hintText: 'કોપીરાઇટ સૂચના ગુજરાતીમાં દાખલ કરો...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 7: INTERACTIVE REAL-TIME LIVE PREVIEW
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, color: colors.getAccentColor(context), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Live Website Footer Preview',
                              style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyAppSegmentView.language(
                        selectedLanguage: _previewLang,
                        onLanguageChanged: (val) => setState(() => _previewLang = val),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, color: colors.getAccentColor(context), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Live Website Footer Preview',
                            style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      MyAppSegmentView.language(
                        selectedLanguage: _previewLang,
                        onLanguageChanged: (val) => setState(() => _previewLang = val),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),

                _buildFooterLivePreview(context, colors, styles),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Action Bar
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MyAppFillButton.icon(
                  onPressed: _saveAllFooterChanges,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: 'Save All Footer Changes',
                ),
                const SizedBox(height: 10),
                MyAppOutlineButton.icon(
                  isDanger: true,
                  onPressed: _confirmClearAllFooter,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: 'Clear All Footer Fields',
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyAppOutlineButton.icon(
                  isDanger: true,
                  onPressed: _confirmClearAllFooter,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: 'Clear All Footer Fields',
                ),
                MyAppFillButton.icon(
                  onPressed: _saveAllFooterChanges,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: 'Save All Footer Changes',
                ),
              ],
            ),
        ],
      );
  }

  Widget _buildLinkRow(BuildContext context, AdminFooterLink item, MyAppColors colors, MyAppTextStyles styles, Key key, int index) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: item.isEnabled
              ? colors.getBorderColor(context)
              : colors.getBorderColor(context).withValues(alpha: 0.4),
        ),
      ),
      color: item.isEnabled
          ? colors.getCardBackgroundColor(context)
          : colors.getSurfaceColor(context).withValues(alpha: 0.45),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 14,
          vertical: isMobile ? 8 : 10,
        ),
        child: Row(
          children: [
            // 1. Reorder Drag Handle (ReorderableDragStartListener, avoids duplicate == icon)
            ReorderableDragStartListener(
              index: index,
              child: MouseRegion(
                cursor: SystemMouseCursors.grab,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  color: Colors.transparent,
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    size: 20,
                    color: colors.getMutedTextColor(context).withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),

            // 2. Order Number Badge
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.getCardBackgroundColor(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.heritageGold.withValues(alpha: 0.6),
                  width: 1.2,
                ),
              ),
              child: Text(
                '${item.order}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: colors.heritageMaroon,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 3. Link Titles: English & Gujarati (Technical /path omitted for non-technical users)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.titleEn,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: isMobile ? 13 : 14,
                            color: item.isEnabled ? null : colors.getMutedTextColor(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.titleGu.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.getMutedTextColor(context),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.titleGu,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              fontWeight: FontWeight.w500,
                              color: item.isEnabled
                                  ? colors.getSecondaryTextColor(context)
                                  : colors.getMutedTextColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (!item.isEnabled) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Hidden from website',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontStyle: FontStyle.italic,
                        color: colors.getMutedTextColor(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 6),

            // 4. Action Controls: Switch, Edit, Delete (neatly aligned in one line)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: item.isEnabled ? 'Link is visible (click to hide)' : 'Link is hidden (click to show)',
                  child: Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: item.isEnabled,
                      activeThumbColor: colors.heritageMaroon,
                      activeTrackColor: colors.heritageGold.withValues(alpha: 0.5),
                      onChanged: (val) {
                        widget.store.toggleFooterLinkEnabled(item.id);
                      },
                    ),
                  ),
                ),
                MyAppIconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: colors.getSecondaryTextColor(context)),
                  tooltip: 'Edit Link',
                  onPressed: () => _openFooterLinkDialog(item, item.column),
                ),
                MyAppIconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  color: Colors.redAccent,
                  tooltip: 'Delete Link',
                  onPressed: () => _confirmDeleteLink(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLivePreview(BuildContext context, MyAppColors colors, MyAppTextStyles styles) {
    final isGu = _previewLang == 'gu';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = isGu ? (_appTitleGuCtrl.text.isNotEmpty ? _appTitleGuCtrl.text : _appTitleEnCtrl.text) : _appTitleEnCtrl.text;
    final subtitle = isGu ? (_appSubtitleGuCtrl.text.isNotEmpty ? _appSubtitleGuCtrl.text : _appSubtitleEnCtrl.text) : _appSubtitleEnCtrl.text;
    final tagline = isGu ? (_taglineGuCtrl.text.isNotEmpty ? _taglineGuCtrl.text : _taglineEnCtrl.text) : _taglineEnCtrl.text;
    final motto = isGu ? (_mottoGuCtrl.text.isNotEmpty ? _mottoGuCtrl.text : _mottoEnCtrl.text) : _mottoEnCtrl.text;
    final col1Title = isGu ? (_col1TitleGuCtrl.text.isNotEmpty ? _col1TitleGuCtrl.text : _col1TitleEnCtrl.text) : _col1TitleEnCtrl.text;
    final col2Title = isGu ? (_col2TitleGuCtrl.text.isNotEmpty ? _col2TitleGuCtrl.text : _col2TitleEnCtrl.text) : _col2TitleEnCtrl.text;
    final socialTitle = isGu ? (_socialTitleGuCtrl.text.isNotEmpty ? _socialTitleGuCtrl.text : _socialTitleEnCtrl.text) : _socialTitleEnCtrl.text;
    final location = isGu ? (_locationGuCtrl.text.isNotEmpty ? _locationGuCtrl.text : _locationEnCtrl.text) : _locationEnCtrl.text;
    final copyright = isGu ? (_copyrightGuCtrl.text.isNotEmpty ? _copyrightGuCtrl.text : _copyrightEnCtrl.text) : _copyrightEnCtrl.text;

    final col1Links = widget.store.footerLinks.where((l) => l.column == 'col1' && l.isEnabled).take(2).toList();
    final col2Links = widget.store.footerLinks.where((l) => l.column == 'col2' && l.isEnabled).take(2).toList();
    final socials = widget.store.footerSocialLinks.where((s) => s.isEnabled).take(2).toList();

    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colors.deepMaroon : const Color(0xFFF1EDE2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5)),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 24,
            runSpacing: 20,
            children: [
              // Mandal Branding
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.heritageGold, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (title.isNotEmpty)
                                Text(
                                  title,
                                  style: styles.editorialSerif(context, size: 14, fontWeight: FontWeight.w700),
                                ),
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: styles.cleanSans(context, size: 9.5, fontWeight: FontWeight.w700, color: colors.getAccentColor(context)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (tagline.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(tagline, style: styles.bodyText(context).copyWith(fontSize: 12, color: colors.getSecondaryTextColor(context))),
                    ],
                    if (motto.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(motto, style: styles.devotionalMotto(context, size: 13, color: colors.getAccentColor(context))),
                    ],
                  ],
                ),
              ),

              // Column 1
              if (col1Title.isNotEmpty || col1Links.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (col1Title.isNotEmpty) Text(col1Title, style: styles.eyebrow(context)),
                    const SizedBox(height: 8),
                    for (final l in col1Links)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          isGu ? (l.titleGu.isNotEmpty ? l.titleGu : l.titleEn) : l.titleEn,
                          style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),

              // Column 2
              if (col2Title.isNotEmpty || col2Links.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (col2Title.isNotEmpty) Text(col2Title, style: styles.eyebrow(context)),
                    const SizedBox(height: 8),
                    for (final l in col2Links)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          isGu ? (l.titleGu.isNotEmpty ? l.titleGu : l.titleEn) : l.titleEn,
                          style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),

              // Social & Contact Info
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (socialTitle.isNotEmpty) ...[
                      Text(socialTitle, style: styles.eyebrow(context)),
                      const SizedBox(height: 8),
                    ],
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: socials.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colors.getCardBackgroundColor(context),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: colors.getBorderColor(context)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getSocialIcon(s.iconKey), size: 12, color: colors.getAccentColor(context)),
                              const SizedBox(width: 4),
                              Text(s.platform, style: styles.cleanSans(context, size: 10.5, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: colors.getAccentColor(context)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(location, style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context))),
                          ),
                        ],
                      ),
                    ],
                    if (_phoneCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.phone_outlined, size: 13, color: colors.getAccentColor(context)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(_phoneCtrl.text, style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                    if (_emailCtrl.text.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, size: 13, color: colors.getAccentColor(context)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(_emailCtrl.text, style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)), overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (copyright.isNotEmpty) ...[
            const HeritageDivider(verticalPadding: 16),
            Text(
              copyright,
              style: styles.cleanSans(context, size: 11, color: colors.getMutedTextColor(context)),
            ),
          ],
        ],
      ),
    );
  }
}
