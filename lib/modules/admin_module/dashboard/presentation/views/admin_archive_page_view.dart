import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Comprehensive Admin View for Garbi Festival Years Archive (matching Admin Home design system):
/// - Section 1: Page Header & Introduction with real-time EN/GU live preview & dual-language inputs
/// - Section 2: Festival Years Archive management with interactive live preview, search, filter tabs,
///   mobile/desktop responsive cards, active/publish toggle, and detailed modal
/// - Section 3: Bottom Gallery Exploration Action (CTA) with live preview and Destination Page Dropdown
/// - Year Detail Modal with FULL CRUD for Associated Albums, Photos, and Videos
/// - Default English live previews with instant English/Gujarati preview toggle
/// - Theme adaptivity with high contrast across light and dark themes
class AdminArchivePageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminArchivePageView({super.key, required this.store});

  @override
  State<AdminArchivePageView> createState() => _AdminArchivePageViewState();
}

class _AdminArchivePageViewState extends State<AdminArchivePageView> {
  // Section 1: Page Header & Introduction Controllers
  late final TextEditingController _tagEnCtrl;
  late final TextEditingController _tagGuCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleGuCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descGuCtrl;

  // Section 3: Bottom Exploration Action Button (CTA) Controllers
  late final TextEditingController _ctaTextEnCtrl;
  late final TextEditingController _ctaTextGuCtrl;
  late final TextEditingController _ctaRouteCtrl;

  // Search & Filter for Festival Years
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filterStatus = 'all'; // 'all', 'published', 'hidden'

  // Independent Real-time Preview Languages (defaulting to English 'en')
  String _headerPreviewLang = 'en';
  String _yearsPreviewLang = 'en';
  String _ctaPreviewLang = 'en';

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdated);
    _reloadAllControllersFromStore();

    _searchCtrl.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchCtrl.text.trim().toLowerCase();
        });
      }
    });
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _reloadAllControllersFromStore() {
    final s = widget.store;

    _tagEnCtrl = TextEditingController(
      text: s.getTextOverride('en', 'archive_tag'),
    );
    _tagGuCtrl = TextEditingController(
      text: s.getTextOverride('gu', 'archive_tag'),
    );
    _titleEnCtrl = TextEditingController(
      text: s.getTextOverride('en', 'archive_title'),
    );
    _titleGuCtrl = TextEditingController(
      text: s.getTextOverride('gu', 'archive_title'),
    );
    _descEnCtrl = TextEditingController(
      text: s.getTextOverride('en', 'archive_desc'),
    );
    _descGuCtrl = TextEditingController(
      text: s.getTextOverride('gu', 'archive_desc'),
    );

    _ctaTextEnCtrl = TextEditingController(
      text: s.getTextOverride('en', 'archive_cta_text'),
    );
    _ctaTextGuCtrl = TextEditingController(
      text: s.getTextOverride('gu', 'archive_cta_text'),
    );

    final routeVal = s.getTextOverride('en', 'archive_cta_route');
    _ctaRouteCtrl = TextEditingController(
      text: (routeVal != null && routeVal.isNotEmpty) ? routeVal : '/gallery',
    );
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreUpdated);
    _tagEnCtrl.dispose();
    _tagGuCtrl.dispose();
    _titleEnCtrl.dispose();
    _titleGuCtrl.dispose();
    _descEnCtrl.dispose();
    _descGuCtrl.dispose();
    _ctaTextEnCtrl.dispose();
    _ctaTextGuCtrl.dispose();
    _ctaRouteCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DUAL-LANGUAGE LIVE PREVIEW RESOLVER
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // PERSISTENCE ACTIONS
  // ---------------------------------------------------------------------------
  void _saveArchiveHeader() {
    final s = widget.store;
    s.updateSiteContentField(
      'archive_tag',
      valueEn: _tagEnCtrl.text.trim(),
      valueGu: _tagGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'archive_title',
      valueEn: _titleEnCtrl.text.trim(),
      valueGu: _titleGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'archive_desc',
      valueEn: _descEnCtrl.text.trim(),
      valueGu: _descGuCtrl.text.trim(),
    );

    MyAppToastMessage.success(
      context,
      title: 'Header Saved',
      description: 'Festival Archive headlines updated and published.',
    );
  }

  void _saveCtaButton() {
    final s = widget.store;
    s.updateSiteContentField(
      'archive_cta_text',
      valueEn: _ctaTextEnCtrl.text.trim(),
      valueGu: _ctaTextGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'archive_cta_route',
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
    _saveArchiveHeader();
    _saveCtaButton();
    MyAppToastMessage.success(
      context,
      title: 'All Changes Saved',
      description: 'Entire Festival Archive page configuration published.',
    );
  }

  void _confirmResetAll() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: serviceLocator<MyAppColors>().getCardBackgroundColor(
          context,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: serviceLocator<MyAppColors>().heritageGold.withValues(
              alpha: 0.5,
            ),
          ),
        ),
        title: Row(
          children: [
            Icon(
              Icons.restore_rounded,
              color: serviceLocator<MyAppColors>().heritageGold,
            ),
            const SizedBox(width: 8),
            const Text('Reset All Content?'),
          ],
        ),
        content: const Text(
          'This will revert all unsaved headline inputs and action buttons back to their saved values.',
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _reloadAllControllersFromStore();
              });
              MyAppToastMessage.info(
                context,
                title: 'Content Reset',
                description: 'Inputs reloaded from current store values.',
              );
            },
            label: 'Reset',
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
      _descEnCtrl.clear();
      _descGuCtrl.clear();
    });
    MyAppToastMessage.info(
      context,
      title: 'Section Cleared',
      description:
          'Header text inputs cleared. Click "Save Header" to publish.',
    );
  }

  void _clearCta() {
    setState(() {
      _ctaTextEnCtrl.clear();
      _ctaTextGuCtrl.clear();
      _ctaRouteCtrl.text = '/gallery';
    });
    MyAppToastMessage.info(
      context,
      title: 'Section Cleared',
      description:
          'Action button inputs cleared. Click "Save Action Button" to publish.',
    );
  }

  // ---------------------------------------------------------------------------
  // FESTIVAL YEAR CRUD DIALOG
  // ---------------------------------------------------------------------------
  void _openYearDialog([AdminGarbiYear? year]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final yearCtrl = TextEditingController(
      text: year?.year.toString() ?? '2026',
    );
    final titleEnCtrl = TextEditingController(text: year?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: year?.titleGu ?? '');
    final descCtrl = TextEditingController(text: year?.description ?? '');
    final countCtrl = TextEditingController(
      text: year?.albumCount.toString() ?? '1',
    );
    bool isPublished = year?.isPublished ?? true;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colors.heritageGold.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: colors.heritageGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  year == null ? 'Add Festival Year' : 'Edit Festival Year',
                  style: styles.editorialSerif(
                    context,
                    size: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: isMobile
                  ? (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 480.0)
                  : 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppTextFormField(
                    controller: yearCtrl,
                    labelText: 'Festival Year (e.g. 2026)',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    labelText: 'Archive Title (English)',
                    showTranslateIcon: true,
                    targetLanguageController: titleGuCtrl,
                    prefixIcon: const Icon(Icons.title_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Archive Title (Gujarati)',
                    prefixIcon: const Icon(Icons.subtitles_outlined),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descCtrl,
                    labelText: 'Cultural Description & Notes',
                    hintText:
                        'Detailed historical narrative about this festival year...',
                    minLines: 2,
                    maxLines: 4,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: countCtrl,
                    labelText: 'Number of Albums / Documents',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.photo_library_outlined),
                    showClearIcon: true,
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
                                'Published on Website',
                                style: styles.cleanSans(
                                  context,
                                  size: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                isPublished ? 'Visible to public visitors' : 'Draft only (hidden)',
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
            MyAppTextButton(
              onPressed: () => Navigator.pop(ctx),
              label: 'Cancel',
            ),
            MyAppFillButton(
              onPressed: () {
                final yearNum = int.tryParse(yearCtrl.text.trim());
                if (yearNum == null) {
                  MyAppToastMessage.warning(
                    context,
                    title: 'Invalid Year',
                    description: 'Please enter a valid numeric year.',
                  );
                  return;
                }

                final titleEn = titleEnCtrl.text.trim().isEmpty
                    ? 'Navratri Mahotsav $yearNum'
                    : titleEnCtrl.text.trim();
                final count = int.tryParse(countCtrl.text.trim()) ?? 0;

                if (year == null) {
                  widget.store.addYear(
                    AdminGarbiYear(
                      id: 'y-$yearNum',
                      year: yearNum,
                      titleEn: titleEn,
                      titleGu: titleGuCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      isPublished: isPublished,
                      albumCount: count,
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Year Added',
                    description: 'Festival year $yearNum added to archive.',
                  );
                } else {
                  widget.store.updateYear(
                    year.copyWith(
                      year: yearNum,
                      titleEn: titleEn,
                      titleGu: titleGuCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      isPublished: isPublished,
                      albumCount: count,
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Year Updated',
                    description: 'Year $yearNum details saved.',
                  );
                }
                Navigator.pop(ctx);
              },
              label: year == null ? 'Add Year' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AdminGarbiYear year) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Festival Year?',
                style: styles.editorialSerif(
                  context,
                  size: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete festival year ${year.year} from the archive? Linked albums and videos will not be deleted.',
          style: styles.cleanSans(
            context,
            size: 13,
            color: colors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteYear(year.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Year Deleted',
                description: 'Festival year ${year.year} removed.',
              );
            },
            label: 'Delete Year',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // YEAR DETAIL DIALOG WITH FULL CRUD FOR ALBUMS & VIDEOS
  // ---------------------------------------------------------------------------
  void _showYearDetailDialog(AdminGarbiYear year) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          // Re-fetch current state of this year, albums, and videos
          final currentYear = widget.store.years.firstWhere(
            (y) => y.id == year.id,
            orElse: () => year,
          );
          final linkedAlbums = widget.store.albums
              .where((a) => a.year == currentYear.year.toString())
              .toList();
          final linkedVideos = widget.store.videos
              .where((v) => v.year == currentYear.year.toString())
              .toList();
          final isPub = currentYear.isPublished;

          return AlertDialog(
            backgroundColor: colors.getCardBackgroundColor(context),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colors.heritageGold.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: isMobile
                  ? (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 680.0)
                  : 680,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // RESPONSIVE DIALOG HEADER (Fixed overflow)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: colors.deepMaroon,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colors.heritageMaroon,
                                        border: Border.all(
                                          color: colors.heritageGold,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${currentYear.year}',
                                          style: styles.editorialSerif(
                                            context,
                                            size: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: colors.heritageGold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    HeritageBadge(
                                      label: isPub ? 'PUBLISHED' : 'DRAFT',
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  currentYear.titleEn.isNotEmpty
                                      ? currentYear.titleEn
                                      : 'Navratri Mahotsav ${currentYear.year}',
                                  style: styles.editorialSerif(
                                    context,
                                    size: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (currentYear.titleGu.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    currentYear.titleGu,
                                    style: styles.devotionalMotto(
                                      context,
                                      size: 12.5,
                                      color: colors.lightGold,
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.heritageMaroon,
                                    border: Border.all(
                                      color: colors.heritageGold,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${currentYear.year}',
                                      style: styles.editorialSerif(
                                        context,
                                        size: 15,
                                        fontWeight: FontWeight.w800,
                                        color: colors.heritageGold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            currentYear.titleEn.isNotEmpty
                                                ? currentYear.titleEn
                                                : 'Navratri Mahotsav ${currentYear.year}',
                                            style: styles.editorialSerif(
                                              context,
                                              size: 16.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          HeritageBadge(
                                            label: isPub
                                                ? 'PUBLISHED'
                                                : 'DRAFT',
                                          ),
                                        ],
                                      ),
                                      if (currentYear.titleGu.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          currentYear.titleGu,
                                          style: styles.devotionalMotto(
                                            context,
                                            size: 12.5,
                                            color: colors.lightGold,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () => Navigator.pop(ctx),
                                ),
                              ],
                            ),
                    ),

                    // BODY CONTENT
                    Padding(
                      padding: EdgeInsets.all(isMobile ? 14 : 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SUMMARY STATS CHIPS
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                context,
                                icon: Icons.photo_library_outlined,
                                label: 'Linked Albums',
                                value: '${linkedAlbums.length}',
                              ),
                              _buildInfoChip(
                                context,
                                icon: Icons.videocam_outlined,
                                label: 'Linked Videos',
                                value: '${linkedVideos.length}',
                              ),
                              _buildInfoChip(
                                context,
                                icon: Icons.visibility_outlined,
                                label: 'Status',
                                value: isPub ? 'Published' : 'Draft / Hidden',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // HISTORICAL OVERVIEW
                          Text(
                            'Historical Overview & Notes',
                            style: styles.cleanSans(
                              context,
                              size: 12.5,
                              fontWeight: FontWeight.bold,
                              color: colors.heritageGold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.getSurfaceColor(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: colors.heritageGold.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Text(
                              currentYear.description.isNotEmpty
                                  ? currentYear.description
                                  : 'No historical description recorded for festival year ${currentYear.year}. You can add descriptions via Edit Year.',
                              style: styles.cleanSans(
                                context,
                                size: 12.5,
                                color: colors.getPrimaryTextColor(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ASSOCIATED ALBUMS WITH FULL CRUD
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Associated Albums (${linkedAlbums.length})',
                                style: styles.editorialSerif(
                                  context,
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              MyAppOutlineButton.icon(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                icon: const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 15,
                                ),
                                label: '+ Add Album',
                                onPressed: () {
                                  _openAlbumDialogForYear(
                                    defaultYear: currentYear.year.toString(),
                                    onRefresh: () => setDlgState(() {}),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (linkedAlbums.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.getSurfaceColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colors.getBorderColor(context),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: colors.heritageGold,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No photo albums linked to ${currentYear.year} yet. Click "+ Add Album" above to create one.',
                                      style: styles.cleanSans(
                                        context,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: linkedAlbums.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final album = linkedAlbums[idx];
                                final photoCount = widget.store.photos
                                    .where((p) => p.albumId == album.id)
                                    .length;

                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.getSurfaceColor(context),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colors.heritageGold.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: SizedBox(
                                          width: 46,
                                          height: 46,
                                          child:
                                              album.coverImageUrl.startsWith(
                                                'http',
                                              )
                                              ? CachedNetworkImage(
                                                  imageUrl: album.coverImageUrl,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (_, _, _) =>
                                                      Image.asset(
                                                        'assets/images/pavan_putra_logo.jpg',
                                                        fit: BoxFit.cover,
                                                      ),
                                                )
                                              : Image.asset(
                                                  'assets/images/pavan_putra_logo.jpg',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              album.name,
                                              style: styles.cleanSans(
                                                context,
                                                size: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${album.dayTag.isNotEmpty ? "${album.dayTag} • " : ""}$photoCount Photos',
                                              style: styles.cleanSans(
                                                context,
                                                size: 11.5,
                                                color: colors
                                                    .getSecondaryTextColor(
                                                      context,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MyAppOutlineButton.icon(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            icon: const Icon(
                                              Icons.photo_library_outlined,
                                              size: 14,
                                            ),
                                            label: 'Photos ($photoCount)',
                                            onPressed: () {
                                              _openPhotosDialogForAlbum(
                                                album,
                                                () => setDlgState(() {}),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 4),
                                          MyAppIconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 17,
                                            ),
                                            tooltip: 'Edit Album',
                                            color: colors.heritageGold,
                                            onPressed: () {
                                              _openAlbumDialogForYear(
                                                defaultYear: currentYear.year
                                                    .toString(),
                                                album: album,
                                                onRefresh: () =>
                                                    setDlgState(() {}),
                                              );
                                            },
                                          ),
                                          MyAppIconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 17,
                                            ),
                                            tooltip: 'Delete Album',
                                            color: Colors.redAccent,
                                            onPressed: () {
                                              _confirmDeleteAlbumForYear(
                                                album,
                                                () => setDlgState(() {}),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),

                          // ASSOCIATED VIDEOS WITH FULL CRUD
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Associated Videos (${linkedVideos.length})',
                                style: styles.editorialSerif(
                                  context,
                                  size: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              MyAppOutlineButton.icon(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                icon: const Icon(
                                  Icons.video_call_outlined,
                                  size: 16,
                                ),
                                label: '+ Add Video',
                                onPressed: () {
                                  _openVideoDialogForYear(
                                    defaultYear: currentYear.year.toString(),
                                    onRefresh: () => setDlgState(() {}),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (linkedVideos.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.getSurfaceColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colors.getBorderColor(context),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.video_library_outlined,
                                    size: 18,
                                    color: colors.heritageGold,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No videos linked to year ${currentYear.year}. Click "+ Add Video" above to link a sacred video recording.',
                                      style: styles.cleanSans(
                                        context,
                                        size: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: linkedVideos.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final vid = linkedVideos[idx];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.getSurfaceColor(context),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colors.heritageGold.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline_rounded,
                                        color: colors.heritageGold,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              vid.title,
                                              style: styles.cleanSans(
                                                context,
                                                size: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${vid.tag.isNotEmpty ? "${vid.tag} • " : ""}${vid.duration}',
                                              style: styles.cleanSans(
                                                context,
                                                size: 11.5,
                                                color: colors
                                                    .getSecondaryTextColor(
                                                      context,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MyAppIconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 17,
                                            ),
                                            tooltip: 'Edit Video',
                                            color: colors.heritageGold,
                                            onPressed: () {
                                              _openVideoDialogForYear(
                                                defaultYear: currentYear.year
                                                    .toString(),
                                                video: vid,
                                                onRefresh: () =>
                                                    setDlgState(() {}),
                                              );
                                            },
                                          ),
                                          MyAppIconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 17,
                                            ),
                                            tooltip: 'Delete Video',
                                            color: Colors.redAccent,
                                            onPressed: () {
                                              _confirmDeleteVideoForYear(
                                                vid,
                                                () => setDlgState(() {}),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              MyAppTextButton.icon(
                icon: Icon(
                  isPub
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16,
                ),
                label: isPub ? 'Hide from Archive' : 'Publish to Archive',
                onPressed: () {
                  final updated = currentYear.copyWith(isPublished: !isPub);
                  widget.store.updateYear(updated);
                  setDlgState(() {});
                  setState(() {});
                  MyAppToastMessage.info(
                    context,
                    title: 'Status Updated',
                    description:
                        '${currentYear.year} is now ${!isPub ? "published" : "hidden"}.',
                  );
                },
              ),
              MyAppTextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: 'Edit Year',
                color: colors.heritageGold,
                onPressed: () {
                  Navigator.pop(ctx);
                  _openYearDialog(currentYear);
                },
              ),
              MyAppFillButton(
                onPressed: () => Navigator.pop(ctx),
                label: 'Close',
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ALBUM & VIDEO CRUD HELPERS FOR YEAR DETAIL MODAL
  // ---------------------------------------------------------------------------
  void _openAlbumDialogForYear({
    required String defaultYear,
    AdminAlbum? album,
    required VoidCallback onRefresh,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final nameCtrl = TextEditingController(text: album?.name ?? '');
    final yearCtrl = TextEditingController(text: album?.year ?? defaultYear);
    final dayCtrl = TextEditingController(text: album?.dayTag ?? 'Day 1');
    final descCtrl = TextEditingController(text: album?.description ?? '');
    String coverUrl =
        album?.coverImageUrl ?? 'assets/images/pavan_putra_logo.jpg';

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colors.heritageGold.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.photo_library_outlined, color: colors.heritageGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  album == null
                      ? 'Add Album for $defaultYear'
                      : 'Edit Album Details',
                  style: styles.editorialSerif(
                    context,
                    size: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: isMobile
                  ? (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 480.0)
                  : 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppImagePicker(
                    label: 'Album Cover Image',
                    initialImageUrl: coverUrl,
                    height: 140,
                    onImageChanged: (url) => setDlgState(() => coverUrl = url),
                  ),
                  const SizedBox(height: 14),
                  MyAppTextFormField(
                    controller: nameCtrl,
                    labelText: 'Album Title (e.g. Maha Aarti Deepotsav)',
                    prefixIcon: const Icon(Icons.title_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  if (isMobile) ...[
                    MyAppTextFormField(
                      controller: yearCtrl,
                      labelText: 'Festival Year',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      showClearIcon: true,
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: dayCtrl,
                      labelText: 'Occasion / Day Tag',
                      hintText: 'e.g. Day 1, Maha Aarti',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      showClearIcon: true,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: MyAppTextFormField(
                            controller: yearCtrl,
                            labelText: 'Festival Year',
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                            ),
                            showClearIcon: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: MyAppTextFormField(
                            controller: dayCtrl,
                            labelText: 'Occasion / Day Tag',
                            hintText: 'e.g. Day 1',
                            prefixIcon: const Icon(Icons.tag_rounded),
                            showClearIcon: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descCtrl,
                    labelText: 'Album Description / Cultural Narrative',
                    hintText: 'Brief summary of the festival event...',
                    minLines: 2,
                    maxLines: 3,
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
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  MyAppToastMessage.warning(
                    context,
                    title: 'Title Required',
                    description: 'Please enter an album title.',
                  );
                  return;
                }

                if (album == null) {
                  widget.store.addAlbum(
                    AdminAlbum(
                      id: 'alb-${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      year: yearCtrl.text.trim(),
                      dayTag: dayCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      coverImageUrl: coverUrl,
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Album Added',
                    description: 'Album "$name" created.',
                  );
                } else {
                  widget.store.updateAlbum(
                    album.copyWith(
                      name: name,
                      year: yearCtrl.text.trim(),
                      dayTag: dayCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      coverImageUrl: coverUrl,
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Album Updated',
                    description: 'Album "$name" saved.',
                  );
                }
                onRefresh();
                Navigator.pop(ctx);
              },
              label: album == null ? 'Create Album' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAlbumForYear(AdminAlbum album, VoidCallback onRefresh) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Album?',
                style: styles.editorialSerif(
                  context,
                  size: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Delete album "${album.name}" from this festival year? Photos linked to this album will remain in storage.',
          style: styles.cleanSans(
            context,
            size: 13,
            color: colors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteAlbum(album.id);
              onRefresh();
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Album Deleted',
                description: 'Album "${album.name}" removed.',
              );
            },
            label: 'Delete Album',
          ),
        ],
      ),
    );
  }

  void _openVideoDialogForYear({
    required String defaultYear,
    AdminVideo? video,
    required VoidCallback onRefresh,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final titleCtrl = TextEditingController(text: video?.title ?? '');
    final yearCtrl = TextEditingController(text: video?.year ?? defaultYear);
    final tagCtrl = TextEditingController(text: video?.tag ?? 'Garba');
    final urlCtrl = TextEditingController(text: video?.youtubeUrl ?? '');
    final durCtrl = TextEditingController(text: video?.duration ?? '10:00');

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colors.heritageGold.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.video_library_rounded, color: colors.heritageGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  video == null
                      ? 'Add Video for $defaultYear'
                      : 'Edit Video Details',
                  style: styles.editorialSerif(
                    context,
                    size: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: isMobile
                  ? (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 480.0)
                  : 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppTextFormField(
                    controller: titleCtrl,
                    labelText: 'Video Title',
                    hintText: 'e.g. Sacred Aarti & Maha Raas 2026',
                    prefixIcon: const Icon(Icons.title_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: urlCtrl,
                    labelText: 'Video URL or Embed ID',
                    hintText: 'https://youtube.com/watch?v=...',
                    prefixIcon: const Icon(Icons.link_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  if (isMobile) ...[
                    MyAppTextFormField(
                      controller: yearCtrl,
                      labelText: 'Festival Year',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      showClearIcon: true,
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: tagCtrl,
                      labelText: 'Category Tag',
                      hintText: 'e.g. Aarti, Raas, Day 1',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      showClearIcon: true,
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: durCtrl,
                      labelText: 'Duration',
                      hintText: 'e.g. 15:30',
                      prefixIcon: const Icon(Icons.timer_outlined),
                      showClearIcon: true,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: MyAppTextFormField(
                            controller: yearCtrl,
                            labelText: 'Festival Year',
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                            ),
                            showClearIcon: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: MyAppTextFormField(
                            controller: tagCtrl,
                            labelText: 'Category Tag',
                            hintText: 'e.g. Aarti',
                            prefixIcon: const Icon(Icons.tag_rounded),
                            showClearIcon: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: MyAppTextFormField(
                            controller: durCtrl,
                            labelText: 'Duration',
                            hintText: '15:30',
                            prefixIcon: const Icon(Icons.timer_outlined),
                            showClearIcon: true,
                          ),
                        ),
                      ],
                    ),
                  ],
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
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) {
                  MyAppToastMessage.warning(
                    context,
                    title: 'Title Required',
                    description: 'Please enter a video title.',
                  );
                  return;
                }

                if (video == null) {
                  widget.store.addVideo(
                    AdminVideo(
                      id: 'vid-${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      youtubeUrl: urlCtrl.text.trim(),
                      year: yearCtrl.text.trim(),
                      tag: tagCtrl.text.trim(),
                      duration: durCtrl.text.trim().isEmpty
                          ? '10:00'
                          : durCtrl.text.trim(),
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Video Added',
                    description: 'Video "$title" added to $defaultYear.',
                  );
                } else {
                  widget.store.updateVideo(
                    video.copyWith(
                      title: title,
                      youtubeUrl: urlCtrl.text.trim(),
                      year: yearCtrl.text.trim(),
                      tag: tagCtrl.text.trim(),
                      duration: durCtrl.text.trim().isEmpty
                          ? '10:00'
                          : durCtrl.text.trim(),
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Video Updated',
                    description: 'Video "$title" saved.',
                  );
                }
                onRefresh();
                Navigator.pop(ctx);
              },
              label: video == null ? 'Add Video' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteVideoForYear(AdminVideo video, VoidCallback onRefresh) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Video?',
                style: styles.editorialSerif(
                  context,
                  size: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Delete video "${video.title}" from this festival year?',
          style: styles.cleanSans(
            context,
            size: 13,
            color: colors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteVideo(video.id);
              onRefresh();
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Video Deleted',
                description: 'Video "${video.title}" removed.',
              );
            },
            label: 'Delete Video',
          ),
        ],
      ),
    );
  }

  void _openPhotosDialogForAlbum(
    AdminAlbum album,
    VoidCallback onParentRefresh,
  ) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final photos = widget.store.photos
              .where((p) => p.albumId == album.id)
              .toList();

          return AlertDialog(
            backgroundColor: colors.getCardBackgroundColor(context),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colors.heritageGold.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.photo_library_outlined, color: colors.heritageGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        album.name,
                        style: styles.editorialSerif(
                          context,
                          size: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${album.year} • ${album.dayTag} (${photos.length} Photos)',
                        style: styles.cleanSans(
                          context,
                          size: 12,
                          color: colors.heritageGold,
                        ),
                      ),
                    ],
                  ),
                ),
                MyAppOutlineButton.icon(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 14),
                  label: '+ Upload',
                  onPressed: () {
                    _openPhotoDialogForAlbum(
                      album: album,
                      onRefresh: () {
                        setDlgState(() {});
                        onParentRefresh();
                      },
                    );
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: isMobile ? double.infinity : 580,
              height: 420,
              child: photos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 40,
                            color: colors.heritageGold.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No photographs in this album yet.',
                            style: styles.cleanSans(
                              context,
                              size: 13,
                              color: colors.getSecondaryTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          MyAppFillButton.icon(
                            onPressed: () {
                              _openPhotoDialogForAlbum(
                                album: album,
                                onRefresh: () {
                                  setDlgState(() {});
                                  onParentRefresh();
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.add_a_photo_rounded,
                              size: 16,
                            ),
                            label: 'Upload First Photo',
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      itemCount: photos.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, idx) {
                        final photo = photos[idx];
                        return Container(
                          decoration: BoxDecoration(
                            color: colors.getSurfaceColor(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.heritageGold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(9),
                                  ),
                                  child: photo.imageUrl.startsWith('http')
                                      ? CachedNetworkImage(
                                          imageUrl: photo.imageUrl,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, _, _) => Image.asset(
                                            'assets/images/pavan_putra_logo.jpg',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/pavan_putra_logo.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      photo.titleEn,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: styles.cleanSans(
                                        context,
                                        size: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          photo.day.isNotEmpty
                                              ? photo.day
                                              : album.dayTag,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: colors.heritageGold,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            MyAppIconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 15,
                                              ),
                                              tooltip: 'Edit Photo',
                                              color: colors.heritageGold,
                                              onPressed: () {
                                                _openPhotoDialogForAlbum(
                                                  album: album,
                                                  photo: photo,
                                                  onRefresh: () {
                                                    setDlgState(() {});
                                                    onParentRefresh();
                                                  },
                                                );
                                              },
                                            ),
                                            MyAppIconButton(
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 15,
                                              ),
                                              tooltip: 'Delete Photo',
                                              color: Colors.redAccent,
                                              onPressed: () {
                                                _confirmDeletePhotoForAlbum(
                                                  photo,
                                                  () {
                                                    setDlgState(() {});
                                                    onParentRefresh();
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              MyAppFillButton(
                onPressed: () => Navigator.pop(ctx),
                label: 'Close',
              ),
            ],
          );
        },
      ),
    );
  }

  void _openPhotoDialogForAlbum({
    required AdminAlbum album,
    AdminPhoto? photo,
    required VoidCallback onRefresh,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 500;

    final titleEnCtrl = TextEditingController(text: photo?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: photo?.titleGu ?? '');
    final dayCtrl = TextEditingController(text: photo?.day ?? album.dayTag);
    final captionCtrl = TextEditingController(text: photo?.caption ?? '');
    String imgUrl = photo?.imageUrl ?? 'assets/images/pavan_putra_logo.jpg';

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: colors.heritageGold.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          title: Row(
            children: [
              Icon(Icons.add_a_photo_rounded, color: colors.heritageGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  photo == null
                      ? 'Upload Photo to "${album.name}"'
                      : 'Edit Photo Details',
                  style: styles.editorialSerif(
                    context,
                    size: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: isMobile ? double.infinity : 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppImagePicker(
                    label: 'Photograph File / Image Link',
                    initialImageUrl: imgUrl,
                    height: 140,
                    onImageChanged: (url) => setDlgState(() => imgUrl = url),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    labelText: 'Photo Title (English)',
                    showTranslateIcon: true,
                    targetLanguageController: titleGuCtrl,
                    prefixIcon: const Icon(Icons.title_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Photo Title (Gujarati)',
                    prefixIcon: const Icon(Icons.subtitles_outlined),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: dayCtrl,
                    labelText: 'Occasion / Day Tag',
                    hintText: 'e.g. Day 1',
                    prefixIcon: const Icon(Icons.tag_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: captionCtrl,
                    labelText: 'Cultural Caption / Notes',
                    hintText: 'Brief context about this photograph...',
                    minLines: 2,
                    maxLines: 3,
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
              onPressed: () {
                final title = titleEnCtrl.text.trim();
                if (title.isEmpty) {
                  MyAppToastMessage.warning(
                    context,
                    title: 'Title Required',
                    description: 'Please enter photo title.',
                  );
                  return;
                }

                if (photo == null) {
                  widget.store.addPhoto(
                    AdminPhoto(
                      id: 'p-${DateTime.now().millisecondsSinceEpoch}',
                      year: album.year,
                      albumId: album.id,
                      day: dayCtrl.text.trim().isEmpty
                          ? album.dayTag
                          : dayCtrl.text.trim(),
                      titleEn: title,
                      titleGu: titleGuCtrl.text.trim(),
                      imageUrl: imgUrl,
                      caption: captionCtrl.text.trim(),
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Photo Added',
                    description: 'Photo "$title" added to album.',
                  );
                } else {
                  widget.store.updatePhoto(
                    photo.copyWith(
                      day: dayCtrl.text.trim(),
                      titleEn: title,
                      titleGu: titleGuCtrl.text.trim(),
                      imageUrl: imgUrl,
                      caption: captionCtrl.text.trim(),
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Photo Updated',
                    description: 'Photo "$title" saved.',
                  );
                }
                onRefresh();
                Navigator.pop(ctx);
              },
              label: photo == null ? 'Upload Photo' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePhotoForAlbum(AdminPhoto photo, VoidCallback onRefresh) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Photo?',
                style: styles.editorialSerif(
                  context,
                  size: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Delete "${photo.titleEn}" from this album?',
          style: styles.cleanSans(
            context,
            size: 13,
            color: colors.getSecondaryTextColor(context),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deletePhoto(photo.id);
              onRefresh();
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Photo Removed',
                description: 'Photo "${photo.titleEn}" removed.',
              );
            },
            label: 'Delete Photo',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.heritageGold),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: styles.cleanSans(
              context,
              size: 11.5,
              color: colors.getSecondaryTextColor(context),
            ),
          ),
          Text(
            value,
            style: styles.cleanSans(
              context,
              size: 11.5,
              fontWeight: FontWeight.bold,
              color: colors.heritageGold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD METHOD (STANDARDIZED WITH ADMIN HOME)
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Public Website Context Banner
          const AdminWebsiteContextBanner(
            websitePageTitle: 'Festival Archive Page',
            websiteRoute: '/archive',
            explanation:
                'Controls past Navratri editions, annual themes, dates, attendance figures, and descriptions shown on the Archive page.',
          ),
          const SizedBox(height: 16),

          // Portal Top Actions Bar (Reset All & Save All Changes)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const HeritageBadge(label: 'WEBSITE CONTENT / FESTIVAL ARCHIVES'),
              Wrap(
                spacing: 10,
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
                      'Controls the grand title, eyebrow badge, and historical narrative opening paragraph on the public Festival Archive page.',
                  actions: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _clearHeader,
                      icon: const Icon(Icons.clear_all_rounded, size: 16),
                      label: 'Clear Section',
                    ),
                    MyAppFillButton.icon(
                      onPressed: _saveArchiveHeader,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Header',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Preview for Section 1
                _buildLiveHeaderPreview(context),
                const SizedBox(height: 18),

                // Dual-Language Inputs for Section 1
                _buildDualLanguageField(
                  title: '1.1 Cultural Eyebrow Tag (સંસ્કૃતિ ટેગ)',
                  enLabel: 'Eyebrow Tag (English)',
                  enCtrl: _tagEnCtrl,
                  guLabel: 'Eyebrow Tag (Gujarati)',
                  guCtrl: _tagGuCtrl,
                  hintText: 'e.g. Festival Archive',
                ),
                _buildDualLanguageField(
                  title: '1.2 Archive Page Grand Title (મુખ્ય શીર્ષક)',
                  enLabel: 'Archive Title (English)',
                  enCtrl: _titleEnCtrl,
                  guLabel: 'Archive Title (Gujarati)',
                  guCtrl: _titleGuCtrl,
                  hintText: 'e.g. Garbi Festival Years Archive',
                ),
                _buildDualLanguageField(
                  title: '1.3 Archive Narrative Overview (પરિચય વિગત)',
                  enLabel: 'Overview (English)',
                  enCtrl: _descEnCtrl,
                  guLabel: 'Overview (Gujarati)',
                  guCtrl: _descGuCtrl,
                  maxLines: 3,
                  hintText:
                      'Chronological archive celebrating 45+ years of sacred Navratri devotion...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 2: FESTIVAL YEARS ARCHIVE CARDS
          // ===================================================================
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeaderCard(
                  context: context,
                  icon: Icons.calendar_month_outlined,
                  title:
                      '2. Festival Years Archive (${widget.store.years.length})',
                  subtitle:
                      'Manage festival years, publish or hide annual records, and associate albums & videos with each year. Click on any year to inspect and manage its linked media.',
                  actions: [
                    MyAppFillButton.icon(
                      onPressed: () => _openYearDialog(),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: 'Add Year Archive',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Preview for Section 2
                _buildLiveYearsPreview(context),
                const SizedBox(height: 18),

                // Search Bar & Filter Status Tabs
                _buildSearchAndFilterBar(context),
                const SizedBox(height: 16),

                // Years Cards List
                _buildYearsList(context),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 3: BOTTOM EXPLORATION ACTION BUTTON (CTA)
          // ===================================================================
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeaderCard(
                  context: context,
                  icon: Icons.ads_click_rounded,
                  title: '3. Bottom Exploration Action (Call to Action)',
                  subtitle:
                      'Configures the prominent action button displayed at the bottom of the Archive page inviting visitors to explore further.',
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

                // Dual-Language Inputs for Section 3
                _buildDualLanguageField(
                  title: '3.1 Action Button Label (બટન લખાણ)',
                  enLabel: 'Button Label (English)',
                  enCtrl: _ctaTextEnCtrl,
                  guLabel: 'Button Label (Gujarati)',
                  guCtrl: _ctaTextGuCtrl,
                  hintText: 'e.g. Explore Photo Gallery',
                ),
                const SizedBox(height: 6),

                // Destination Page Route Dropdown
                _buildRouteDropdown(context, colors),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER CARD (Standardized across Admin)
  // ---------------------------------------------------------------------------
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: colors.getAccentColor(context).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.heritageGold.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: colors.getAccentColor(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: styles.editorialSerif(
                  context,
                  size: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w700,
                  color: colors.getPrimaryTextColor(context),
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: styles.cleanSans(
              context,
              size: 12.5,
              color: colors.getSecondaryTextColor(context),
              height: 1.45,
            ),
          ),
        ],
        if (actions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE PREVIEW: SECTION 1 (HEADER)
  // ---------------------------------------------------------------------------
  Widget _buildLiveHeaderPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final s = widget.store;
    final fallbackTag = _headerPreviewLang == 'gu'
        ? 'મહોત્સવ સંગ્રહ'
        : 'Festival Archive';
    final fallbackTitle = _headerPreviewLang == 'gu'
        ? 'પાવન પુત્ર ગરબી મહોત્સવ ઈતિહાસ'
        : 'Garbi Festival Years Archive';
    final fallbackDesc = _headerPreviewLang == 'gu'
        ? '૧૯૭૭ થી આજ સુધીની પાવન પરંપરા, આયોજન અને સ્મૃતિઓનો અમૂલ્ય સંગ્રહ.'
        : 'Explore our historical journey and sacred Navratri editions through archival photo albums, videos, and milestones spanning over 45+ years.';

    final rawTag = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _tagEnCtrl.text,
      gu: _tagGuCtrl.text,
    );
    final displayTag = rawTag.isNotEmpty
        ? rawTag
        : (s.getTextOverride(_headerPreviewLang, 'archive_tag') ?? fallbackTag);

    final rawTitle = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _titleEnCtrl.text,
      gu: _titleGuCtrl.text,
    );
    final displayTitle = rawTitle.isNotEmpty
        ? rawTitle
        : (s.getTextOverride(_headerPreviewLang, 'archive_title') ??
              fallbackTitle);

    final rawDesc = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _descEnCtrl.text,
      gu: _descGuCtrl.text,
    );
    final displayDesc = rawDesc.isNotEmpty
        ? rawDesc
        : (s.getTextOverride(_headerPreviewLang, 'archive_desc') ??
              fallbackDesc);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.heritageGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Language Toggle Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : colors.heritageGold.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.heritageGold.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.remove_red_eye_outlined,
                  size: 15,
                  color: colors.heritageGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Header Preview (as seen by public visitors)',
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.heritageGold,
                    ),
                  ),
                ),
                _buildLanguageTogglePill(
                  activeLang: _headerPreviewLang,
                  onChanged: (lang) =>
                      setState(() => _headerPreviewLang = lang),
                  colors: colors,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeritageBadge(label: displayTag),
                const SizedBox(height: 10),
                Text(
                  displayTitle,
                  textAlign: TextAlign.center,
                  style: styles.editorialSerif(
                    context,
                    size: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  displayDesc,
                  textAlign: TextAlign.center,
                  style: styles.cleanSans(
                    context,
                    size: 13,
                    color: colors.getSecondaryTextColor(context),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE PREVIEW: SECTION 2 (YEARS ARCHIVE)
  // ---------------------------------------------------------------------------
  Widget _buildLiveYearsPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final publishedYears = widget.store.years
        .where((y) => y.isPublished)
        .toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.heritageGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : colors.heritageGold.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.heritageGold.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.collections_bookmark_outlined,
                  size: 15,
                  color: colors.heritageGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Archive Timeline Preview (${publishedYears.length} Public Years)',
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.heritageGold,
                    ),
                  ),
                ),
                _buildLanguageTogglePill(
                  activeLang: _yearsPreviewLang,
                  onChanged: (lang) => setState(() => _yearsPreviewLang = lang),
                  colors: colors,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: publishedYears.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No published festival years yet. Click "Add Year Archive" below to publish one.',
                        style: styles.cleanSans(
                          context,
                          size: 12,
                          color: colors.getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 95,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: publishedYears.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, idx) {
                        final yr = publishedYears[idx];
                        final isGu = _yearsPreviewLang == 'gu';
                        final title = (isGu && yr.titleGu.isNotEmpty)
                            ? yr.titleGu
                            : yr.titleEn;

                        return Container(
                          width: 170,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.getSurfaceColor(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.heritageGold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.deepMaroon,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: colors.heritageGold,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Text(
                                      '${yr.year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: colors.heritageGold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${yr.albumCount} Albums',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colors.getSecondaryTextColor(
                                          context,
                                        ),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                title.isNotEmpty ? title : 'Navratri Mahotsav',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.editorialSerif(
                                  context,
                                  size: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE PREVIEW: SECTION 3 (CTA)
  // ---------------------------------------------------------------------------
  Widget _buildLiveCtaPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final s = widget.store;
    final fallbackCta = _ctaPreviewLang == 'gu'
        ? 'ફોટો ગેલેરી જુઓ'
        : 'Explore Photo Gallery';
    final rawCta = _resolvePreviewText(
      lang: _ctaPreviewLang,
      en: _ctaTextEnCtrl.text,
      gu: _ctaTextGuCtrl.text,
    );
    final displayCta = rawCta.isNotEmpty
        ? rawCta
        : (s.getTextOverride(_ctaPreviewLang, 'archive_cta_text') ??
              fallbackCta);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.heritageGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : colors.heritageGold.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.heritageGold.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  size: 15,
                  color: colors.heritageGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Action Button Preview',
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.heritageGold,
                    ),
                  ),
                ),
                _buildLanguageTogglePill(
                  activeLang: _ctaPreviewLang,
                  onChanged: (lang) => setState(() => _ctaPreviewLang = lang),
                  colors: colors,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: MyAppFillButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: displayCta,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LANGUAGE TOGGLE PILL COMPONENT
  // ---------------------------------------------------------------------------
  Widget _buildLanguageTogglePill({
    required String activeLang,
    required ValueChanged<String> onChanged,
    required MyAppColors colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.deepMaroon,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.heritageGold, width: 1),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPillTab(
            label: 'EN',
            isActive: activeLang == 'en',
            onTap: () => onChanged('en'),
            colors: colors,
          ),
          _buildPillTab(
            label: 'ગુજ',
            isActive: activeLang == 'gu',
            onTap: () => onChanged('gu'),
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildPillTab({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required MyAppColors colors,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? colors.heritageGold : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? colors.deepMaroon : colors.heritageGold,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DUAL LANGUAGE INPUT COMPONENT
  // ---------------------------------------------------------------------------
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
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? colors.heritageGold.withValues(alpha: 0.25)
              : colors.getBorderColor(context),
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
          MyAppTextFormField(
            controller: enCtrl,
            labelText: enLabel,
            hintText: hintText,
            maxLines: maxLines,
            showTranslateIcon: true,
            targetLanguageController: guCtrl,
            prefixIcon: const Icon(Icons.language_rounded),
            showClearIcon: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),
          MyAppTextFormField(
            controller: guCtrl,
            labelText: guLabel,
            hintText: hintText,
            maxLines: maxLines,
            prefixIcon: const Icon(Icons.translate_rounded),
            showClearIcon: true,
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ROUTE DROPDOWN (DESTINATION PAGE)
  // ---------------------------------------------------------------------------
  Widget _buildRouteDropdown(BuildContext context, MyAppColors colors) {
    return MyAppDropdown.pageDestination(
      controller: _ctaRouteCtrl,
      defaultRoute: '/gallery',
      labelText: 'Destination Page to Open (કયા પેજ પર જવું)',
      hintText: 'Select which website page visitors explore when clicking this button',
      onChanged: (val) {
        setState(() {
          _ctaRouteCtrl.text = val;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // SEARCH & FILTER BAR
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndFilterBar(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyAppTextFormField(
          controller: _searchCtrl,
          hintText: 'Search years by number, title, or cultural description...',
          prefixIcon: const Icon(Icons.search_rounded),
          showClearIcon: true,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                'All Years (${widget.store.years.length})',
                'all',
                colors,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Published (${widget.store.years.where((y) => y.isPublished).length})',
                'published',
                colors,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Draft / Hidden (${widget.store.years.where((y) => !y.isPublished).length})',
                'hidden',
                colors,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, MyAppColors colors) {
    final isSelected = _filterStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colors.deepMaroon,
      backgroundColor: colors.getSurfaceColor(context),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
        color: isSelected
            ? colors.heritageGold
            : colors.getPrimaryTextColor(context),
      ),
      side: BorderSide(
        color: isSelected
            ? colors.heritageGold
            : colors.getBorderColor(context),
        width: 1,
      ),
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }

  // ---------------------------------------------------------------------------
  // YEARS LIST / CARDS
  // ---------------------------------------------------------------------------
  Widget _buildYearsList(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    final filtered = widget.store.years.where((year) {
      if (_filterStatus == 'published' && !year.isPublished) return false;
      if (_filterStatus == 'hidden' && year.isPublished) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        final matchYear = year.year.toString().contains(q);
        final matchTitleEn = year.titleEn.toLowerCase().contains(q);
        final matchTitleGu = year.titleGu.toLowerCase().contains(q);
        final matchDesc = year.description.toLowerCase().contains(q);
        if (!matchYear && !matchTitleEn && !matchTitleGu && !matchDesc) {
          return false;
        }
      }
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.getBorderColor(context)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 36,
              color: colors.heritageGold,
            ),
            const SizedBox(height: 10),
            Text(
              'No festival years match your criteria.',
              style: styles.editorialSerif(
                context,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your search terms or click "Add Year Archive" above.',
              style: styles.cleanSans(
                context,
                size: 12,
                color: colors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final year = filtered[index];
        final linkedAlbums = widget.store.albums
            .where((a) => a.year == year.year.toString())
            .length;

        if (isMobile) {
          return CulturalFrameCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showYearDetailDialog(year),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.deepMaroon,
                            border: Border.all(
                              color: colors.heritageGold,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${year.year}',
                              style: styles.editorialSerif(
                                context,
                                size: 13.5,
                                fontWeight: FontWeight.w800,
                                color: colors.heritageGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                year.titleEn,
                                style: styles.editorialSerif(
                                  context,
                                  size: 15.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (year.titleGu.isNotEmpty)
                                Text(
                                  year.titleGu,
                                  style: styles.devotionalMotto(
                                    context,
                                    size: 12.5,
                                    color: colors.heritageGold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$linkedAlbums Albums • ${year.description.isNotEmpty ? year.description : "Year-wise Pavan Putra Garbi heritage archive."}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: styles.cleanSans(
                        context,
                        size: 12,
                        color: colors.getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(height: 1, color: colors.getBorderColor(context)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        HeritageBadge(
                          label: year.isPublished ? 'PUBLISHED' : 'DRAFT',
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'View Year Details & Linked Media',
                              child: MyAppIconButton(
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 19,
                                ),
                                color: colors.heritageGold,
                                onPressed: () => _showYearDetailDialog(year),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: year.isPublished
                                  ? 'Published'
                                  : 'Hidden',
                              child: Switch(
                                value: year.isPublished,
                                activeThumbColor: colors.heritageGold,
                                activeTrackColor: colors.heritageMaroon,
                                onChanged: (val) {
                                  widget.store.updateYear(
                                    year.copyWith(isPublished: val),
                                  );
                                  MyAppToastMessage.info(
                                    context,
                                    title: 'Status Updated',
                                    description:
                                        '${year.year} is now ${val ? "published" : "hidden"}.',
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            MyAppIconButton(
                              icon: const Icon(Icons.edit_outlined, size: 19),
                              tooltip: 'Edit Year',
                              color: colors.heritageGold,
                              onPressed: () => _openYearDialog(year),
                            ),
                            const SizedBox(width: 4),
                            MyAppIconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 19,
                              ),
                              tooltip: 'Delete Year',
                              color: Colors.redAccent,
                              onPressed: () => _confirmDelete(year),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Desktop layout
        return CulturalFrameCard(
          padding: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showYearDetailDialog(year),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.deepMaroon,
                      border: Border.all(
                        color: colors.heritageGold,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${year.year}',
                        style: styles.editorialSerif(
                          context,
                          size: 15,
                          fontWeight: FontWeight.w800,
                          color: colors.heritageGold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              year.titleEn,
                              style: styles.editorialSerif(
                                context,
                                size: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            HeritageBadge(
                              label: year.isPublished ? 'PUBLISHED' : 'DRAFT',
                            ),
                          ],
                        ),
                        if (year.titleGu.isNotEmpty)
                          Text(
                            year.titleGu,
                            style: styles.devotionalMotto(
                              context,
                              size: 13,
                              color: colors.heritageGold,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          '$linkedAlbums Albums • ${year.description.isNotEmpty ? year.description : "Year-wise Pavan Putra Garbi heritage archive."}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.cleanSans(
                            context,
                            size: 12,
                            color: colors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Tooltip(
                        message: 'View Year Details & Linked Media',
                        child: MyAppIconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 19),
                          color: colors.heritageGold,
                          onPressed: () => _showYearDetailDialog(year),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message: year.isPublished ? 'Published' : 'Hidden',
                        child: Switch(
                          value: year.isPublished,
                          activeThumbColor: colors.heritageGold,
                          activeTrackColor: colors.heritageMaroon,
                          onChanged: (val) {
                            widget.store.updateYear(
                              year.copyWith(isPublished: val),
                            );
                            MyAppToastMessage.info(
                              context,
                              title: 'Status Updated',
                              description:
                                  '${year.year} is now ${val ? "published" : "hidden"}.',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      MyAppIconButton(
                        icon: const Icon(Icons.edit_outlined, size: 19),
                        tooltip: 'Edit Year',
                        color: colors.heritageGold,
                        onPressed: () => _openYearDialog(year),
                      ),
                      const SizedBox(width: 4),
                      MyAppIconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                        ),
                        tooltip: 'Delete Year',
                        color: Colors.redAccent,
                        onPressed: () => _confirmDelete(year),
                      ),
                    ],
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
