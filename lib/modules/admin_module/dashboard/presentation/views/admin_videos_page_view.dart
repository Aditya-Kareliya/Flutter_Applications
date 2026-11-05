import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/utils/youtube_url_helper.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image/app_cached_image.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Comprehensive Admin View for Videos & Live Stream Broadcast (matching Gallery & Archive design system):
/// - Section 1: Page Header & Introduction with real-time EN/GU live preview & dual-language inputs
/// - Section 2: Live Stream Broadcast Control with instant YouTube validation, live player preview, & EN/GU toggle
/// - Section 3: Video Archive & Hierarchy Explorer with Year folders, search, filter chips, and video cards
/// - Section 4: Bottom Call-To-Action (CTA) with live preview and Destination Page Dropdown (Image 1 bottom sheet)
/// - Interactive Video Add/Edit Dialog with YouTube URL verification & thumbnail builder
/// - Video Lightbox Viewer Modal for immediate preview and testing
class AdminVideosPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminVideosPageView({super.key, required this.store});

  @override
  State<AdminVideosPageView> createState() => _AdminVideosPageViewState();
}

class _AdminVideosPageViewState extends State<AdminVideosPageView> {
  // ---------------------------------------------------------------------------
  // SECTION 1: PAGE HEADER & INTRODUCTION CONTROLLERS
  // ---------------------------------------------------------------------------
  late final TextEditingController _tagEnCtrl;
  late final TextEditingController _tagGuCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleGuCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descGuCtrl;

  String _headerPreviewLang = 'en';

  // ---------------------------------------------------------------------------
  // SECTION 2: LIVE STREAM BROADCAST CONTROLLERS
  // ---------------------------------------------------------------------------
  late bool _isLive;
  late final TextEditingController _streamTitleEnCtrl;
  late final TextEditingController _streamTitleGuCtrl;
  late final TextEditingController _streamUrlCtrl;
  late final TextEditingController _streamAnnounceEnCtrl;
  late final TextEditingController _streamAnnounceGuCtrl;
  late final TextEditingController _streamScheduleCtrl;

  String _streamPreviewLang = 'en';

  // ---------------------------------------------------------------------------
  // SECTION 3: VIDEO ARCHIVE SEARCH & FILTER
  // ---------------------------------------------------------------------------
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedYear;
  String _archiveStatusFilter = 'ALL'; // 'ALL', 'PUBLISHED', 'DRAFT'
  String _selectedCategoryFilter = 'ALL';
  String _selectedStatusFilter =
      'ALL'; // 'ALL', 'PUBLISHED', 'DRAFT', 'FEATURED'

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdated);
    widget.store.ensureVideosLoaded();
    widget.store.ensureGalleryLoaded();

    _tagEnCtrl = TextEditingController();
    _tagGuCtrl = TextEditingController();
    _titleEnCtrl = TextEditingController();
    _titleGuCtrl = TextEditingController();
    _descEnCtrl = TextEditingController();
    _descGuCtrl = TextEditingController();

    final l = widget.store.liveStreamSettings;
    _isLive = l.isLive;
    _streamTitleEnCtrl = TextEditingController(text: l.title);
    _streamTitleGuCtrl = TextEditingController();
    _streamUrlCtrl = TextEditingController(text: l.streamUrl);
    _streamAnnounceEnCtrl = TextEditingController(text: l.announcement);
    _streamAnnounceGuCtrl = TextEditingController();
    _streamScheduleCtrl = TextEditingController(text: l.scheduleTime);

    _reloadAllControllersFromStore();

    _searchCtrl.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchCtrl.text.trim().toLowerCase();
        });
      }
    });
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

    _streamTitleEnCtrl.dispose();
    _streamTitleGuCtrl.dispose();
    _streamUrlCtrl.dispose();
    _streamAnnounceEnCtrl.dispose();
    _streamAnnounceGuCtrl.dispose();
    _streamScheduleCtrl.dispose();

    _searchCtrl.dispose();
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _reloadAllControllersFromStore() {
    final s = widget.store;
    _tagEnCtrl.text = s.getTextOverride('en', 'videos_tag') ?? '';
    _tagGuCtrl.text = s.getTextOverride('gu', 'videos_tag') ?? '';
    _titleEnCtrl.text = s.getTextOverride('en', 'videos_title') ?? '';
    _titleGuCtrl.text = s.getTextOverride('gu', 'videos_title') ?? '';
    _descEnCtrl.text = s.getTextOverride('en', 'videos_desc') ?? '';
    _descGuCtrl.text = s.getTextOverride('gu', 'videos_desc') ?? '';

    final l = s.liveStreamSettings;
    _isLive = l.isLive;
    if (_streamTitleEnCtrl.text.isEmpty) {
      _streamTitleEnCtrl.text = l.title;
    }
    _streamTitleGuCtrl.text =
        s.getTextOverride('gu', 'videos_stream_title') ?? '';
    _streamUrlCtrl.text = l.streamUrl;
    if (_streamAnnounceEnCtrl.text.isEmpty) {
      _streamAnnounceEnCtrl.text = l.announcement;
    }
    _streamAnnounceGuCtrl.text =
        s.getTextOverride('gu', 'videos_stream_announce') ?? '';
    _streamScheduleCtrl.text = l.scheduleTime;
  }

  String _resolvePreviewText({
    required String lang,
    required String en,
    required String gu,
  }) {
    if (lang == 'gu') return gu.isNotEmpty ? gu : en;
    return en.isNotEmpty ? en : gu;
  }

  // ---------------------------------------------------------------------------
  // SAVE & RESET ACTIONS
  // ---------------------------------------------------------------------------
  void _saveHeader() {
    final s = widget.store;
    s.updateSiteContentField(
      'videos_tag',
      valueEn: _tagEnCtrl.text.trim(),
      valueGu: _tagGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'videos_title',
      valueEn: _titleEnCtrl.text.trim(),
      valueGu: _titleGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'videos_desc',
      valueEn: _descEnCtrl.text.trim(),
      valueGu: _descGuCtrl.text.trim(),
    );

    MyAppToastMessage.success(
      context,
      title: 'Header Saved',
      description: 'Videos page header & introduction published.',
    );
  }

  void _saveLiveStreamConfig() {
    final rawUrl = _streamUrlCtrl.text.trim();
    if (rawUrl.isNotEmpty && !YoutubeUrlHelper.isValid(rawUrl)) {
      MyAppToastMessage.warning(
        context,
        title: 'Invalid YouTube URL',
        description:
            'Please enter a valid YouTube live stream URL or video ID.',
      );
      return;
    }

    final updated = widget.store.liveStreamSettings.copyWith(
      isLive: _isLive,
      title: _streamTitleEnCtrl.text.trim(),
      streamUrl: rawUrl,
      announcement: _streamAnnounceEnCtrl.text.trim(),
      scheduleTime: _streamScheduleCtrl.text.trim(),
    );
    widget.store.updateLiveStream(updated);

    if (_streamTitleGuCtrl.text.isNotEmpty) {
      widget.store.updateSiteContentField(
        'videos_stream_title',
        valueEn: _streamTitleEnCtrl.text.trim(),
        valueGu: _streamTitleGuCtrl.text.trim(),
      );
    }
    if (_streamAnnounceGuCtrl.text.isNotEmpty) {
      widget.store.updateSiteContentField(
        'videos_stream_announce',
        valueEn: _streamAnnounceEnCtrl.text.trim(),
        valueGu: _streamAnnounceGuCtrl.text.trim(),
      );
    }

    MyAppToastMessage.success(
      context,
      title: 'Live Stream Saved',
      description: 'Broadcast status: ${_isLive ? "LIVE NOW 🔴" : "OFFLINE"}',
    );
  }

  void _saveAllSections() {
    _saveHeader();
    _saveLiveStreamConfig();
    MyAppToastMessage.success(
      context,
      title: 'All Changes Saved',
      description: 'All Videos & Live Stream settings successfully published.',
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
      title: 'Header Cleared',
      description:
          'Header text inputs have been cleared. Click "Save Header" to publish.',
    );
  }

  void _confirmResetAll() {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colors.heritageGold.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.restore_rounded, color: colors.heritageGold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Revert All Changes?',
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
          'Discard unpersisted edits and reload all stored values from the database?',
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
              Navigator.pop(ctx);
              setState(() {
                _reloadAllControllersFromStore();
              });
              MyAppToastMessage.info(
                context,
                title: 'Changes Discarded',
                description: 'Content reloaded from current store values.',
              );
            },
            label: 'Discard Edits',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VIDEO CRUD DIALOGS
  // ---------------------------------------------------------------------------
  void _openVideoDialog([AdminVideo? video, String? defaultYear]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final titleCtrl = TextEditingController(text: video?.title ?? '');
    final titleGuCtrl = TextEditingController(text: video?.titleGu ?? '');
    final urlCtrl = TextEditingController(text: video?.youtubeUrl ?? '');
    final categoryCtrl = TextEditingController(text: video?.tag ?? 'Garbi');
    final durationCtrl = TextEditingController(
      text: video?.duration ?? '10:00',
    );
    final yearCtrl = TextEditingController(
      text: video?.year ?? (defaultYear ?? _selectedYear ?? '2025'),
    );
    final channelCtrl = TextEditingController(
      text: video?.sourceChannel ?? 'Ratnadeep Sound',
    );
    bool isPublished = video?.isPublished ?? true;
    bool isFeatured = video?.isFeatured ?? false;
    String? previewThumb = video?.thumbnailUrl;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: colors.getCardBackgroundColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: colors.heritageGold.withValues(alpha: 0.6),
                width: 1.2,
              ),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 20,
            ),
            title: Row(
              children: [
                Icon(
                  video == null
                      ? Icons.add_circle_outline_rounded
                      : Icons.edit_note_rounded,
                  color: colors.heritageGold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    video == null
                        ? 'Add Video Recording'
                        : 'Edit Video Recording',
                    style: styles.editorialSerif(
                      context,
                      size: 20,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: isMobile
                    ? (MediaQuery.sizeOf(context).width - 28).clamp(
                        280.0,
                        520.0,
                      )
                    : 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppTextFormField(
                      controller: urlCtrl,
                      labelText: 'YouTube URL or Video ID *',
                      hintText:
                          'e.g. https://www.youtube.com/watch?v=... or youtu.be',
                      prefixIcon: const Icon(Icons.link_rounded),
                      showClearIcon: true,
                      onChanged: (val) {
                        final extractedId = YoutubeUrlHelper.extractVideoId(
                          val,
                        );
                        setDialogState(() {
                          previewThumb = extractedId != null
                              ? YoutubeUrlHelper.buildThumbnailUrl(extractedId)
                              : null;
                        });
                      },
                    ),
                    if (previewThumb != null && previewThumb!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AppCachedImage(
                                imageUrl: previewThumb,
                                fit: BoxFit.cover,
                                memCacheWidth: 640,
                                memCacheHeight: 360,
                                fallbackWidget: Container(
                                  color: colors.heritageMaroon,
                                  child: const Icon(
                                    Icons.video_camera_back,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Colors.greenAccent,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Valid Video ID',
                                    style: TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    MyAppTextFormField(
                      controller: titleCtrl,
                      labelText: 'Video Title (English) *',
                      hintText:
                          'e.g. Chand-Mund no Raas — Pavanputra Garbi Live',
                      showTranslateIcon: true,
                      targetLanguageController: titleGuCtrl,
                      prefixIcon: const Icon(Icons.title_rounded),
                      showClearIcon: true,
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: titleGuCtrl,
                      labelText: 'Video Title (Gujarati)',
                      hintText: 'દા.ત. ચંડ-મુંડ નો રાસ — પવનપુત્ર ગરબી લાઈવ',
                      prefixIcon: const Icon(Icons.subtitles_outlined),
                      showClearIcon: true,
                    ),
                    const SizedBox(height: 12),
                    if (isMobile) ...[
                      MyAppTextFormField(
                        controller: yearCtrl,
                        labelText: 'Festival Year *',
                        hintText: 'e.g. 2025',
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                        showClearIcon: true,
                      ),
                      const SizedBox(height: 12),
                      MyAppDropdown<String>(
                        labelText: 'Category Tag *',
                        value:
                            [
                              'Garbi',
                              'Raas',
                              'Aarti',
                              'Live Recording',
                              'Archive',
                            ].contains(categoryCtrl.text)
                            ? categoryCtrl.text
                            : 'Garbi',
                        items: const [
                          MyAppDropdownItem(
                            value: 'Garbi',
                            label: 'Garbi (ગરબી)',
                          ),
                          MyAppDropdownItem(value: 'Raas', label: 'Raas (રાસ)'),
                          MyAppDropdownItem(
                            value: 'Aarti',
                            label: 'Aarti (આરતી)',
                          ),
                          MyAppDropdownItem(
                            value: 'Live Recording',
                            label: 'Live Recording (લાઈવ દર્શન)',
                          ),
                          MyAppDropdownItem(
                            value: 'Archive',
                            label: 'Archive (ઐતિહાસિક સંગ્રહ)',
                          ),
                        ],
                        onChanged: (val) => categoryCtrl.text = val,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: MyAppTextFormField(
                              controller: yearCtrl,
                              labelText: 'Festival Year *',
                              hintText: 'e.g. 2025',
                              prefixIcon: const Icon(
                                Icons.calendar_today_rounded,
                              ),
                              showClearIcon: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyAppDropdown<String>(
                              labelText: 'Category Tag *',
                              value:
                                  [
                                    'Garbi',
                                    'Raas',
                                    'Aarti',
                                    'Live Recording',
                                    'Archive',
                                  ].contains(categoryCtrl.text)
                                  ? categoryCtrl.text
                                  : 'Garbi',
                              items: const [
                                MyAppDropdownItem(
                                  value: 'Garbi',
                                  label: 'Garbi (ગરબી)',
                                ),
                                MyAppDropdownItem(
                                  value: 'Raas',
                                  label: 'Raas (રાસ)',
                                ),
                                MyAppDropdownItem(
                                  value: 'Aarti',
                                  label: 'Aarti (આરતી)',
                                ),
                                MyAppDropdownItem(
                                  value: 'Live Recording',
                                  label: 'Live Recording (લાઈવ દર્શન)',
                                ),
                                MyAppDropdownItem(
                                  value: 'Archive',
                                  label: 'Archive (ઐતિહાસિક સંગ્રહ)',
                                ),
                              ],
                              onChanged: (val) => categoryCtrl.text = val,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (isMobile) ...[
                      MyAppTextFormField(
                        controller: channelCtrl,
                        labelText: 'Source Channel / Mandal Recording',
                        hintText: 'Ratnadeep Sound / Mandal',
                        prefixIcon: const Icon(Icons.tv_rounded),
                        showClearIcon: true,
                      ),
                      const SizedBox(height: 12),
                      MyAppTextFormField(
                        controller: durationCtrl,
                        labelText: 'Duration (optional)',
                        hintText: 'e.g. 15:30 or blank',
                        prefixIcon: const Icon(Icons.timer_outlined),
                        showClearIcon: true,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: MyAppTextFormField(
                              controller: channelCtrl,
                              labelText: 'Source Channel',
                              hintText: 'Ratnadeep Sound / Mandal',
                              prefixIcon: const Icon(Icons.tv_rounded),
                              showClearIcon: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyAppTextFormField(
                              controller: durationCtrl,
                              labelText: 'Duration',
                              hintText: 'e.g. 15:30',
                              prefixIcon: const Icon(Icons.timer_outlined),
                              showClearIcon: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colors.getBorderColor(context),
                        ),
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
                                  isPublished
                                      ? 'Visible to public visitors'
                                      : 'Draft only (hidden)',
                                  style: styles.cleanSans(
                                    context,
                                    size: 11.5,
                                    color: isPublished
                                        ? Colors.green
                                        : colors.getMutedTextColor(context),
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
                              onChanged: (val) =>
                                  setDialogState(() => isPublished = val),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.getSurfaceColor(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colors.getBorderColor(context),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Featured Recording',
                                  style: styles.cleanSans(
                                    context,
                                    size: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  isFeatured
                                      ? 'Highlighted in top carousel'
                                      : 'Standard listing',
                                  style: styles.cleanSans(
                                    context,
                                    size: 11.5,
                                    color: isFeatured
                                        ? colors.heritageGold
                                        : colors.getMutedTextColor(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.scale(
                            scale: 0.85,
                            child: Switch(
                              value: isFeatured,
                              activeThumbColor: colors.heritageGold,
                              activeTrackColor: colors.deepMaroon,
                              onChanged: (val) =>
                                  setDialogState(() => isFeatured = val),
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
                  final title = titleCtrl.text.trim();
                  final rawUrl = urlCtrl.text.trim();
                  final extractedId = YoutubeUrlHelper.extractVideoId(rawUrl);

                  if (title.isEmpty) {
                    MyAppToastMessage.warning(
                      context,
                      title: 'Title Required',
                      description: 'Please enter video title.',
                    );
                    return;
                  }
                  if (extractedId == null) {
                    MyAppToastMessage.warning(
                      context,
                      title: 'Valid YouTube URL Required',
                      description:
                          'Please paste a valid YouTube watch, shorts, live, or youtu.be URL.',
                    );
                    return;
                  }

                  if (video == null) {
                    final isDuplicate = widget.store.videos.any(
                      (v) => v.youtubeVideoId == extractedId,
                    );
                    if (isDuplicate) {
                      MyAppToastMessage.warning(
                        context,
                        title: 'Duplicate Video',
                        description:
                            'A video with YouTube ID ($extractedId) already exists in the archive.',
                      );
                      return;
                    }
                  }

                  final canonicalUrl = YoutubeUrlHelper.buildWatchUrl(
                    extractedId,
                  );
                  final thumb = YoutubeUrlHelper.buildThumbnailUrl(extractedId);
                  final assignedYear = yearCtrl.text.trim().isEmpty
                      ? '2025'
                      : yearCtrl.text.trim();
                  final assignedYearNum = int.tryParse(assignedYear);
                  if (assignedYearNum != null &&
                      !widget.store.years.any(
                        (y) => y.year == assignedYearNum,
                      )) {
                    widget.store.addYear(
                      AdminGarbiYear(
                        id: 'y-$assignedYearNum',
                        year: assignedYearNum,
                        titleEn: 'Navratri Mahotsav $assignedYearNum',
                        titleGu: 'નવરાત્રિ મહોત્સવ $assignedYearNum',
                        description:
                            'Garbi video recordings for year $assignedYearNum',
                        isPublished: true,
                      ),
                    );
                  }

                  if (video == null) {
                    widget.store.addVideo(
                      AdminVideo(
                        id: 'vid-${DateTime.now().millisecondsSinceEpoch}',
                        youtubeVideoId: extractedId,
                        title: title,
                        titleGu: titleGuCtrl.text.trim(),
                        youtubeUrl: canonicalUrl,
                        thumbnailUrl: thumb,
                        duration: durationCtrl.text.trim(),
                        tag: categoryCtrl.text.trim().isEmpty
                            ? 'Garbi'
                            : categoryCtrl.text.trim(),
                        year: assignedYear,
                        sourceChannel: channelCtrl.text.trim().isEmpty
                            ? 'Ratnadeep Sound'
                            : channelCtrl.text.trim(),
                        isPublished: isPublished,
                        isFeatured: isFeatured,
                      ),
                    );
                    MyAppToastMessage.success(
                      context,
                      title: 'Video Added',
                      description: 'Video "$title" added successfully.',
                    );
                  } else {
                    widget.store.updateVideo(
                      video.copyWith(
                        youtubeVideoId: extractedId,
                        title: title,
                        titleGu: titleGuCtrl.text.trim(),
                        youtubeUrl: canonicalUrl,
                        thumbnailUrl: thumb,
                        duration: durationCtrl.text.trim(),
                        tag: categoryCtrl.text.trim().isEmpty
                            ? 'Garbi'
                            : categoryCtrl.text.trim(),
                        year: assignedYear,
                        sourceChannel: channelCtrl.text.trim().isEmpty
                            ? 'Ratnadeep Sound'
                            : channelCtrl.text.trim(),
                        isPublished: isPublished,
                        isFeatured: isFeatured,
                      ),
                    );
                    MyAppToastMessage.success(
                      context,
                      title: 'Video Updated',
                      description: 'Video "$title" updated.',
                    );
                  }
                  setState(() {});
                  Navigator.pop(ctx);
                },
                label: video == null ? 'Add Video' : 'Save Changes',
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVideoViewer(AdminVideo video) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: colors.heritageGold.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: isMobile
              ? (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 560.0)
              : 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: AppCachedImage(
                          imageUrl: video.thumbnailUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 640,
                          memCacheHeight: 360,
                          fallbackWidget: Container(
                            color: colors.deepMaroon,
                            child: const Icon(
                              Icons.video_camera_back_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final url = YoutubeUrlHelper.buildWatchUrl(
                          video.youtubeVideoId,
                        );
                        launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.duration.isNotEmpty
                              ? video.duration
                              : 'HD VIDEO',
                          style: styles.cleanSans(
                            context,
                            size: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          HeritageBadge(label: video.year),
                          HeritageBadge(label: video.tag),
                          HeritageBadge(
                            label: video.isPublished
                                ? 'PUBLISHED'
                                : 'DRAFT / HIDDEN',
                            backgroundColor: video.isPublished
                                ? colors.heritageGold.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                            textColor: video.isPublished
                                ? colors.getAccentColor(context)
                                : Colors.grey,
                          ),
                          if (video.isFeatured)
                            const HeritageBadge(
                              label: '★ FEATURED',
                              backgroundColor: Color(0xFFB8860B),
                              textColor: Colors.white,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        video.title,
                        style: styles.editorialSerif(
                          context,
                          size: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (video.titleGu.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          video.titleGu,
                          style: styles.devotionalMotto(
                            context,
                            size: 13,
                            color: colors.heritageGold,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Recorded by: ${video.sourceChannel}',
                        style: styles.cleanSans(
                          context,
                          size: 12,
                          color: colors.getSecondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 14),
                      MyAppOutlineButton.icon(
                        icon: const Icon(Icons.open_in_new_rounded, size: 15),
                        label: 'Watch on YouTube (${video.youtubeVideoId})',
                        onPressed: () {
                          final url = YoutubeUrlHelper.buildWatchUrl(
                            video.youtubeVideoId,
                          );
                          launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
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
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Close'),
          MyAppOutlineButton.icon(
            icon: const Icon(Icons.edit_outlined, size: 15),
            label: 'Edit Video',
            onPressed: () {
              Navigator.pop(ctx);
              _openVideoDialog(video);
            },
          ),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              Navigator.pop(ctx);
              _confirmDeleteVideo(video);
            },
            label: 'Delete',
          ),
        ],
      ),
    );
  }

  void _confirmDeleteVideo(AdminVideo video) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
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
                'Delete Video Recording?',
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
          'Are you sure you want to remove "${video.title}" from the video vault? This will hide it from visitors.',
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
              Navigator.pop(ctx);
              setState(() {});
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

  // ---------------------------------------------------------------------------
  // FESTIVAL YEAR ARCHIVE CRUD & RESOLUTION
  // ---------------------------------------------------------------------------
  List<AdminGarbiYear> _getResolvedYears() {
    final Map<int, AdminGarbiYear> yearMap = {};

    for (final y in widget.store.years) {
      if (!yearMap.containsKey(y.year) ||
          (y.titleEn.isNotEmpty && yearMap[y.year]!.titleEn.isEmpty)) {
        yearMap[y.year] = y;
      }
    }

    for (final v in widget.store.videos) {
      final yNum = int.tryParse(v.year);
      if (yNum != null && !yearMap.containsKey(yNum)) {
        yearMap[yNum] = AdminGarbiYear(
          id: 'y-$yNum',
          year: yNum,
          titleEn: 'Navratri Mahotsav $yNum',
          titleGu: 'નવરાત્રિ મહોત્સવ $yNum',
          description:
              'Historical Garbi celebrations and live recordings for year $yNum',
          isPublished: true,
        );
      }
    }

    final storeYears = yearMap.values.toList();
    storeYears.sort((a, b) => b.year.compareTo(a.year));
    return storeYears;
  }

  void _openYearArchiveDialog([AdminGarbiYear? year]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final initialYear =
        year?.year.toString() ?? (_selectedYear ?? '${DateTime.now().year}');
    final yearCtrl = TextEditingController(text: initialYear);
    final titleEnCtrl = TextEditingController(text: year?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: year?.titleGu ?? '');
    final descCtrl = TextEditingController(text: year?.description ?? '');
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
                  year == null
                      ? 'Add Festival Year Archive'
                      : 'Edit Year Archive Details',
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
                  ? (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 500.0)
                  : 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppTextFormField(
                    controller: yearCtrl,
                    labelText: 'Festival Year (e.g. 2025) *',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    labelText: 'Archive Title (English)',
                    hintText: 'e.g. Navratri Mahotsav 2025',
                    showTranslateIcon: true,
                    targetLanguageController: titleGuCtrl,
                    prefixIcon: const Icon(Icons.title_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Archive Title (Gujarati)',
                    hintText: 'દા.ત. નવરાત્રિ મહોત્સવ ૨૦૨૫',
                    prefixIcon: const Icon(Icons.subtitles_outlined),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descCtrl,
                    labelText: 'Cultural Narrative / Theme Notes',
                    hintText:
                        'Historical description of this year\'s Garbi celebrations, live telecasts, and sacred events...',
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
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
                                'Publish Archive on Website',
                                style: styles.cleanSans(
                                  context,
                                  size: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                isPublished
                                    ? 'Visible to public visitors'
                                    : 'Draft only (hidden)',
                                style: styles.cleanSans(
                                  context,
                                  size: 11,
                                  color: isPublished
                                      ? Colors.green
                                      : colors.getMutedTextColor(context),
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
                            onChanged: (val) =>
                                setDlgState(() => isPublished = val),
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
                if (yearNum == null || yearNum < 1900 || yearNum > 2100) {
                  MyAppToastMessage.warning(
                    context,
                    title: 'Invalid Year',
                    description:
                        'Please enter a valid 4-digit numeric year (e.g. 2025).',
                  );
                  return;
                }

                final titleEn = titleEnCtrl.text.trim().isEmpty
                    ? 'Navratri Mahotsav $yearNum'
                    : titleEnCtrl.text.trim();
                final titleGu = titleGuCtrl.text.trim().isEmpty
                    ? 'નવરાત્રિ મહોત્સવ $yearNum'
                    : titleGuCtrl.text.trim();

                if (year == null) {
                  final newYear = AdminGarbiYear(
                    id: 'y-$yearNum',
                    year: yearNum,
                    titleEn: titleEn,
                    titleGu: titleGu,
                    description: descCtrl.text.trim(),
                    isPublished: isPublished,
                  );
                  widget.store.addYear(newYear);
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedYear = yearNum.toString();
                  });
                  MyAppToastMessage.success(
                    context,
                    title: 'Archive Year Created',
                    description:
                        'Festival year $yearNum added to Video Archive.',
                  );
                } else {
                  final oldYearStr = year.year.toString();
                  final newYearStr = yearNum.toString();
                  final updatedYear = year.copyWith(
                    year: yearNum,
                    titleEn: titleEn,
                    titleGu: titleGu,
                    description: descCtrl.text.trim(),
                    isPublished: isPublished,
                  );
                  widget.store.updateYear(updatedYear);

                  if (oldYearStr != newYearStr) {
                    final linkedVideos = widget.store.videos
                        .where((v) => v.year == oldYearStr)
                        .toList();
                    for (final v in linkedVideos) {
                      widget.store.updateVideo(v.copyWith(year: newYearStr));
                    }
                    if (_selectedYear == oldYearStr) {
                      _selectedYear = newYearStr;
                    }
                  }

                  Navigator.pop(ctx);
                  setState(() {});
                  MyAppToastMessage.success(
                    context,
                    title: 'Archive Year Updated',
                    description: 'Festival year $yearNum details updated.',
                  );
                }
              },
              label: year == null ? 'Add Year Archive' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteYearArchive(AdminGarbiYear year) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final yearStr = year.year.toString();
    final linkedVideos = widget.store.videos
        .where((v) => v.year == yearStr)
        .toList();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
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
                'Delete Year $yearStr Archive?',
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
          linkedVideos.isNotEmpty
              ? 'Year $yearStr has ${linkedVideos.length} recorded video(s). Removing this year removes the archive metadata. Do you want to proceed?'
              : 'Are you sure you want to delete festival year $yearStr from the video archive?',
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
              Navigator.pop(ctx);
              widget.store.deleteYear(year.id);
              if (_selectedYear == yearStr) {
                setState(() => _selectedYear = null);
              } else {
                setState(() {});
              }
              MyAppToastMessage.success(
                context,
                title: 'Archive Deleted',
                description: 'Year $yearStr removed from Video Archive.',
              );
            },
            label: 'Delete Year Archive',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------------------------------------
          // WEBSITE CONTEXT BANNER
          // -----------------------------------------------------------------
          const AdminWebsiteContextBanner(
            websitePageTitle: 'Videos & Live Stream',
            websiteRoute: '/videos',
            explanation:
                'Controls YouTube Live Stream broadcasts, schedule announcements, and historical Video Vault recordings across 45+ years.',
          ),
          const SizedBox(height: 16),

          // -----------------------------------------------------------------
          // MASTER ACTION BAR
          // -----------------------------------------------------------------
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const HeritageBadge(
                label: 'WEBSITE CONTENT / VIDEOS & BROADCAST',
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
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
                      'Controls the grand title, eyebrow badge, and historical overview paragraph on the public Videos & Live Stream page.',
                  actions: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _clearHeader,
                      icon: const Icon(Icons.clear_all_rounded, size: 16),
                      label: 'Clear Section',
                    ),
                    MyAppFillButton.icon(
                      onPressed: _saveHeader,
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
                  hintText: 'e.g. AUDIO-VISUAL ARCHIVE',
                ),
                _buildDualLanguageField(
                  title: '1.2 Video Page Grand Title (મુખ્ય શીર્ષક)',
                  enLabel: 'Video Title (English)',
                  enCtrl: _titleEnCtrl,
                  guLabel: 'Video Title (Gujarati)',
                  guCtrl: _titleGuCtrl,
                  hintText:
                      'e.g. Watch the Sacred Nights. Hear the Timeless Rhythms.',
                ),
                _buildDualLanguageField(
                  title: '1.3 Audio-Visual Narrative Overview (પરિચય વિગત)',
                  enLabel: 'Overview (English)',
                  enCtrl: _descEnCtrl,
                  guLabel: 'Overview (Gujarati)',
                  guCtrl: _descGuCtrl,
                  maxLines: 3,
                  hintText:
                      'Relive 45+ years of divine Rasotsav celebrations and live YouTube recordings...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 2: LIVE STREAM BROADCAST CONTROL
          // ===================================================================
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeaderCard(
                  context: context,
                  icon: Icons.sensors_rounded,
                  title: '2. Live Stream Broadcast Control',
                  subtitle:
                      'Controls real-time live broadcasting, YouTube feed links, announcement banners, and upcoming schedule countdowns.',
                  actions: [
                    HeritageBadge(
                      label: _isLive
                          ? '🔴 BROADCAST ACTIVE'
                          : 'BROADCAST OFFLINE',
                      backgroundColor: _isLive
                          ? Colors.red.withValues(alpha: 0.15)
                          : null,
                      textColor: _isLive ? Colors.redAccent : null,
                    ),
                    MyAppFillButton.icon(
                      onPressed: _saveLiveStreamConfig,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Stream Config',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Live Preview for Section 2
                _buildLiveStreamPreview(context),
                const SizedBox(height: 18),

                // Controls
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.heritageGold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              _isLive
                                  ? Icons.sensors_rounded
                                  : Icons.sensors_off_rounded,
                              color: _isLive
                                  ? Colors.redAccent
                                  : colors.getMutedTextColor(context),
                              size: 26,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLive
                                        ? 'LIVE BROADCAST IS ACTIVE'
                                        : 'BROADCAST IS OFFLINE',
                                    style: styles.cleanSans(
                                      context,
                                      size: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: _isLive
                                          ? Colors.redAccent
                                          : colors.getMutedTextColor(context),
                                    ),
                                  ),
                                  Text(
                                    _isLive
                                        ? 'Visitors see a live red banner & video player on the website'
                                        : 'Visitors see the upcoming broadcast schedule notice',
                                    style: styles.cleanSans(
                                      context,
                                      size: 11.5,
                                      color: colors.getSecondaryTextColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Switch(
                        value: _isLive,
                        activeThumbColor: Colors.redAccent,
                        onChanged: (val) => setState(() => _isLive = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                _buildDualLanguageField(
                  title: '2.1 Live Stream Title (લાઈવ શીર્ષક)',
                  enLabel: 'Stream Title (English)',
                  enCtrl: _streamTitleEnCtrl,
                  guLabel: 'Stream Title (Gujarati)',
                  guCtrl: _streamTitleGuCtrl,
                  hintText: 'e.g. Navratri Day 1 Maha Aarti Live Broadcast',
                ),

                // YouTube URL with live preview thumbnail
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.heritageGold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2.2 YouTube Live Feed Link / Video ID',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colors.getPrimaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyAppTextFormField(
                        controller: _streamUrlCtrl,
                        labelText: 'YouTube Stream URL or Embed ID',
                        hintText:
                            'e.g. https://www.youtube.com/watch?v=... or live stream ID',
                        prefixIcon: const Icon(Icons.live_tv_rounded),
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (YoutubeUrlHelper.extractVideoId(
                            _streamUrlCtrl.text.trim(),
                          ) !=
                          null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.greenAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Valid YouTube ID: ${YoutubeUrlHelper.extractVideoId(_streamUrlCtrl.text.trim())}',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                _buildDualLanguageField(
                  title:
                      '2.3 Announcement Banner / Schedule Notice (જાહેરાત લખાણ)',
                  enLabel: 'Announcement (English)',
                  enCtrl: _streamAnnounceEnCtrl,
                  guLabel: 'Announcement (Gujarati)',
                  guCtrl: _streamAnnounceGuCtrl,
                  maxLines: 2,
                  hintText:
                      'e.g. Special live broadcast from Sorathiyavadi Garbi Ground...',
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.heritageGold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2.4 Broadcast Timing & Channel Info',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colors.getPrimaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyAppTextFormField(
                        controller: _streamScheduleCtrl,
                        labelText:
                            'Schedule Time Text (e.g. Daily 8:00 PM to 12:00 AM IST)',
                        hintText: 'e.g. Tonight at 8:00 PM IST',
                        prefixIcon: const Icon(Icons.schedule_rounded),
                        showClearIcon: true,
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 3: VIDEO ARCHIVE & HIERARCHY EXPLORER
          // ===================================================================
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: _buildVideoArchiveExplorer(context, isMobile),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 3: VIDEO ARCHIVE EXPLORER
  // ---------------------------------------------------------------------------
  Widget _buildVideoArchiveExplorer(BuildContext context, bool isMobile) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final resolvedYears = _getResolvedYears();
    final allVideos = widget.store.videos;

    // Filter years for Year Archive view
    final filteredYears = resolvedYears.where((year) {
      if (_archiveStatusFilter == 'PUBLISHED' && !year.isPublished) {
        return false;
      }
      if (_archiveStatusFilter == 'DRAFT' && year.isPublished) {
        return false;
      }
      if (_selectedYear == null && _searchQuery.isNotEmpty) {
        final q = _searchQuery;
        final matchYear = year.year.toString().contains(q);
        final matchEn = year.titleEn.toLowerCase().contains(q);
        final matchGu = year.titleGu.toLowerCase().contains(q);
        final matchDesc = year.description.toLowerCase().contains(q);
        if (!matchYear && !matchEn && !matchGu && !matchDesc) {
          return false;
        }
      }
      return true;
    }).toList();

    // Filter videos for the selected year
    final videosInSelectedYear = _selectedYear != null
        ? allVideos.where((v) => v.year == _selectedYear).toList()
        : allVideos;

    final filteredVideos = videosInSelectedYear.where((v) {
      if (_selectedCategoryFilter != 'ALL' &&
          v.tag != _selectedCategoryFilter) {
        return false;
      }
      if (_selectedStatusFilter == 'PUBLISHED' && !v.isPublished) return false;
      if (_selectedStatusFilter == 'DRAFT' && v.isPublished) return false;
      if (_selectedStatusFilter == 'FEATURED' && !v.isFeatured) return false;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        final mEn = v.title.toLowerCase().contains(q);
        final mGu = v.titleGu.toLowerCase().contains(q);
        final mTag = v.tag.toLowerCase().contains(q);
        final mChannel = v.sourceChannel.toLowerCase().contains(q);
        final mYear = v.year.toLowerCase().contains(q);
        if (!mEn && !mGu && !mTag && !mChannel && !mYear) return false;
      }
      return true;
    }).toList();

    final AdminGarbiYear? selectedYearObj = _selectedYear != null
        ? resolvedYears.firstWhere(
            (y) => y.year.toString() == _selectedYear,
            orElse: () => AdminGarbiYear(
              id: 'y-$_selectedYear',
              year: int.tryParse(_selectedYear!) ?? 2025,
              titleEn: 'Navratri Mahotsav $_selectedYear',
              titleGu: 'નવરાત્રિ મહોત્સવ $_selectedYear',
              description: '',
            ),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeaderCard(
          context: context,
          icon: Icons.video_library_rounded,
          title: '3. Video Archive Hierarchy Explorer',
          subtitle:
              'Navigate Festival Year Archives > Manage Videos & Live Broadcasts. Add, edit, update, delete, and view archives and recordings.',
          actions: [
            if (_selectedYear == null) ...[
              MyAppFillButton.icon(
                onPressed: () => _openYearArchiveDialog(),
                icon: const Icon(Icons.create_new_folder_outlined, size: 16),
                label: 'Add Year Archive',
              ),
              MyAppOutlineButton.icon(
                onPressed: () => _openVideoDialog(null, null),
                icon: const Icon(Icons.video_call_outlined, size: 16),
                label: 'Add Video Recording',
              ),
            ] else ...[
              MyAppOutlineButton.icon(
                onPressed: () => setState(() => _selectedYear = null),
                icon: const Icon(Icons.arrow_back_rounded, size: 15),
                label: 'Back to All Years',
              ),
              MyAppFillButton.icon(
                onPressed: () => _openVideoDialog(null, _selectedYear),
                icon: const Icon(Icons.video_call_outlined, size: 16),
                label: 'Add Video to $_selectedYear',
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Breadcrumb Navigation Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.getCardBackgroundColor(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colors.heritageGold.withValues(alpha: 0.3),
            ),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 6,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  InkWell(
                    onTap: () => setState(() => _selectedYear = null),
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_copy_outlined,
                            size: 16,
                            color: colors.heritageGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'All Years (${resolvedYears.length})',
                            style: styles.cleanSans(
                              context,
                              size: 12.5,
                              fontWeight: _selectedYear == null
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: _selectedYear == null
                                  ? colors.heritageGold
                                  : colors.getPrimaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedYear != null) ...[
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colors.getMutedTextColor(context),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.deepMaroon,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: colors.heritageGold,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'Year $_selectedYear (${videosInSelectedYear.length} Videos)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: colors.heritageGold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (_selectedYear != null)
                MyAppTextButton.icon(
                  isCompact: true,
                  onPressed: () => setState(() => _selectedYear = null),
                  icon: const Icon(Icons.arrow_back_rounded, size: 14),
                  label: 'Back to Years',
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // If inside a year, show Selected Year Banner
        if (_selectedYear != null && selectedYearObj != null) ...[
          _buildSelectedYearBanner(selectedYearObj, colors, styles, isMobile),
        ],

        // Search Bar (Archive-level or Video-level)
        MyAppTextFormField(
          controller: _searchCtrl,
          hintText: _selectedYear == null
              ? 'Search festival archives by year, title, or cultural notes...'
              : 'Search videos in $_selectedYear by title, category, or channel...',
          prefixIcon: const Icon(Icons.search_rounded),
          showClearIcon: true,
        ),
        const SizedBox(height: 10),

        // Filter chips: Archive filters when on All Years, Video filters when inside Year
        if (_selectedYear == null) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'All Years (${resolvedYears.length})',
                  _archiveStatusFilter == 'ALL',
                  () {
                    setState(() => _archiveStatusFilter = 'ALL');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Published (${resolvedYears.where((y) => y.isPublished).length})',
                  _archiveStatusFilter == 'PUBLISHED',
                  () {
                    setState(() => _archiveStatusFilter = 'PUBLISHED');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Draft / Hidden (${resolvedYears.where((y) => !y.isPublished).length})',
                  _archiveStatusFilter == 'DRAFT',
                  () {
                    setState(() => _archiveStatusFilter = 'DRAFT');
                  },
                  colors,
                ),
              ],
            ),
          ),
        ] else ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'All Categories',
                  _selectedCategoryFilter == 'ALL',
                  () {
                    setState(() => _selectedCategoryFilter = 'ALL');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Garbi',
                  _selectedCategoryFilter == 'Garbi',
                  () {
                    setState(() => _selectedCategoryFilter = 'Garbi');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Raas', _selectedCategoryFilter == 'Raas', () {
                  setState(() => _selectedCategoryFilter = 'Raas');
                }, colors),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Aarti',
                  _selectedCategoryFilter == 'Aarti',
                  () {
                    setState(() => _selectedCategoryFilter = 'Aarti');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Live Recording',
                  _selectedCategoryFilter == 'Live Recording',
                  () {
                    setState(() => _selectedCategoryFilter = 'Live Recording');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Archive',
                  _selectedCategoryFilter == 'Archive',
                  () {
                    setState(() => _selectedCategoryFilter = 'Archive');
                  },
                  colors,
                ),
                const SizedBox(width: 14),
                Container(
                  width: 1,
                  height: 20,
                  color: colors.heritageGold.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 14),
                _buildFilterChip(
                  'All Status',
                  _selectedStatusFilter == 'ALL',
                  () {
                    setState(() => _selectedStatusFilter = 'ALL');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Published',
                  _selectedStatusFilter == 'PUBLISHED',
                  () {
                    setState(() => _selectedStatusFilter = 'PUBLISHED');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip('Draft', _selectedStatusFilter == 'DRAFT', () {
                  setState(() => _selectedStatusFilter = 'DRAFT');
                }, colors),
                const SizedBox(width: 8),
                _buildFilterChip(
                  '★ Featured',
                  _selectedStatusFilter == 'FEATURED',
                  () {
                    setState(() => _selectedStatusFilter = 'FEATURED');
                  },
                  colors,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        // CONTENT: Years Grid or Videos Grid
        _selectedYear == null
            ? _buildYearsGrid(context, filteredYears, allVideos, colors, styles)
            : _buildVideosGrid(context, filteredVideos, colors, styles),
      ],
    );
  }

  Widget _buildSelectedYearBanner(
    AdminGarbiYear year,
    MyAppColors colors,
    MyAppTextStyles styles,
    bool isMobile,
  ) {
    final yearStr = year.year.toString();
    final videosInYear = widget.store.videos
        .where((v) => v.year == yearStr)
        .toList();
    final publishedCount = videosInYear.where((v) => v.isPublished).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.heritageGold.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.deepMaroon,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.heritageGold, width: 1),
                    ),
                    child: Text(
                      'FESTIVAL YEAR ${year.year}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: colors.heritageGold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: year.isPublished
                          ? Colors.green.shade900
                          : Colors.orange.shade900,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      year.isPublished ? '● PUBLISHED' : '○ DRAFT ARCHIVE',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  MyAppFillButton.icon(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    onPressed: () => _openVideoDialog(null, yearStr),
                    icon: const Icon(Icons.video_call_outlined, size: 15),
                    label: 'Add Video to $yearStr',
                  ),
                  MyAppOutlineButton.icon(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    onPressed: () => _openYearArchiveDialog(year),
                    icon: const Icon(Icons.edit_note_rounded, size: 15),
                    label: 'Edit Archive',
                  ),
                  MyAppIconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: Colors.redAccent,
                    tooltip: 'Delete Year Archive',
                    onPressed: () => _confirmDeleteYearArchive(year),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            year.titleEn.isNotEmpty
                ? year.titleEn
                : 'Navratri Mahotsav ${year.year}',
            style: styles.editorialSerif(
              context,
              size: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (year.titleGu.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              year.titleGu,
              style: styles.devotionalMotto(
                context,
                size: 13,
                color: colors.heritageGold,
              ),
            ),
          ],
          if (year.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              year.description,
              style: styles.cleanSans(
                context,
                size: 12,
                color: colors.getSecondaryTextColor(context),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Divider(height: 1, color: colors.getBorderColor(context)),
          const SizedBox(height: 8),
          Text(
            '${videosInYear.length} Video Recordings • $publishedCount Live Streams Broadcasted',
            style: styles.cleanSans(
              context,
              size: 11.5,
              fontWeight: FontWeight.w600,
              color: colors.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    MyAppColors colors,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.deepMaroon
              : colors.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colors.heritageGold
                : colors.heritageGold.withValues(alpha: 0.3),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? colors.heritageGold
                : colors.getPrimaryTextColor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildYearsGrid(
    BuildContext context,
    List<AdminGarbiYear> years,
    List<AdminVideo> allVideos,
    MyAppColors colors,
    MyAppTextStyles styles,
  ) {
    if (years.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: colors.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 44,
              color: colors.heritageGold.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No Year Archives Found',
              style: styles.editorialSerif(
                context,
                size: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Click "+ Add Year Archive" above to start documenting festival years.',
              style: styles.cleanSans(
                context,
                size: 13,
                color: colors.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            MyAppFillButton.icon(
              onPressed: () => _openYearArchiveDialog(),
              icon: const Icon(Icons.create_new_folder_outlined, size: 16),
              label: 'Create First Archive',
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Responsive columns & aspect ratios:
        // - Mobile (< 560px): strictly 2 columns, childAspectRatio: 0.62 (preserves mobile view, zero overflow)
        // - Tablet (560 - 880px): 3 columns, childAspectRatio: 1.05
        // - Laptop (880 - 1200px): 4 columns, childAspectRatio: 1.10
        // - Monitor / Desktop (>= 1200px): 5 columns, childAspectRatio: 1.15
        final int cols;
        final double childAspectRatio;
        if (w < 560) {
          cols = 2;
          childAspectRatio = 0.62;
        } else if (w < 880) {
          cols = 3;
          childAspectRatio = 1.05;
        } else if (w < 1200) {
          cols = 4;
          childAspectRatio = 1.10;
        } else {
          cols = 5;
          childAspectRatio = 1.15;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: years.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, idx) {
            final year = years[idx];
            final yearStr = year.year.toString();
            final vInYear = allVideos.where((v) => v.year == yearStr).toList();
            final pubCount = vInYear.where((v) => v.isPublished).length;
            AdminVideo? latestVideo;
            for (final v in vInYear) {
              if (v.thumbnailUrl.trim().isNotEmpty) {
                latestVideo = v;
                break;
              }
            }
            final hasThumb =
                latestVideo != null && latestVideo.thumbnailUrl.trim().isNotEmpty;

            return InkWell(
              onTap: () => setState(() => _selectedYear = yearStr),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.getCardBackgroundColor(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.heritageGold.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Cover / Visual area takes flexible remaining height
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(13),
                            ),
                            child: hasThumb
                                ? AppCachedImage(
                                    imageUrl: latestVideo.thumbnailUrl.trim(),
                                    fit: BoxFit.cover,
                                    memCacheWidth: 640,
                                    memCacheHeight: 360,
                                    fallbackWidget: _buildDefaultYearCover(year, colors, styles),
                                  )
                                : _buildDefaultYearCover(year, colors, styles),
                          ),
                          // Subtle dark gradient overlay ONLY for real video thumbnails so badges remain crisp
                          if (hasThumb)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(13),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.45),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                            ),
                          // Year Badge top-left
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.deepMaroon,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colors.heritageGold,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                yearStr,
                                style: styles.cleanSans(
                                  context,
                                  size: 11,
                                  fontWeight: FontWeight.w800,
                                  color: colors.heritageGold,
                                ),
                              ),
                            ),
                          ),
                          // Video count pill top-right
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.videocam_outlined,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${vInYear.length}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Publication status pill bottom-left
                          Positioned(
                            bottom: 6,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: year.isPublished
                                    ? Colors.green.shade900
                                    : Colors.orange.shade900,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                year.isPublished ? 'PUBLISHED' : 'DRAFT',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Details & Actions Area: natural size, zero overflow
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            year.titleEn.isNotEmpty
                                ? year.titleEn
                                : 'Navratri Mahotsav $yearStr',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: styles.editorialSerif(
                              context,
                              size: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${vInYear.length} Videos • $pubCount Live',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: styles.cleanSans(
                              context,
                              size: 10.5,
                              color: colors.getSecondaryTextColor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Divider(
                            height: 1,
                            color: colors.getBorderColor(context),
                          ),
                          const SizedBox(height: 4),
                          // Action row: [ Manage (N) ] [ ✏️ ] [ 🗑️ ]
                          Row(
                            children: [
                              Expanded(
                                child: MyAppOutlineButton.icon(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 3,
                                  ),
                                  icon: const Icon(
                                    Icons.video_library_outlined,
                                    size: 12,
                                  ),
                                  label: 'Manage (${vInYear.length})',
                                  onPressed: () =>
                                      setState(() => _selectedYear = yearStr),
                                ),
                              ),
                              const SizedBox(width: 2),
                              MyAppIconButton(
                                icon: const Icon(Icons.edit_outlined, size: 15),
                                tooltip: 'Edit Year Archive',
                                color: colors.heritageGold,
                                onPressed: () => _openYearArchiveDialog(year),
                              ),
                              MyAppIconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 15,
                                ),
                                tooltip: 'Delete Year Archive',
                                color: Colors.redAccent,
                                onPressed: () =>
                                    _confirmDeleteYearArchive(year),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultYearCover(
    AdminGarbiYear year,
    MyAppColors colors,
    MyAppTextStyles styles,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.deepMaroon,
            const Color(0xFF6E0D1B),
            const Color(0xFF380309),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: colors.heritageGold,
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.heritageGold.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/pavan_putra_logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${year.year}',
              style: styles.editorialSerif(
                context,
                size: 14,
                fontWeight: FontWeight.w800,
                color: colors.heritageGold,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              'NAVRATRI MAHOTSAV',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 7.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: colors.heritageGold.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideosGrid(
    BuildContext context,
    List<AdminVideo> videos,
    MyAppColors colors,
    MyAppTextStyles styles,
  ) {
    if (videos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: colors.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: colors.heritageGold.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No Matching Videos Found',
              style: styles.editorialSerif(
                context,
                size: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No video recordings match your filter criteria in year $_selectedYear.',
              style: styles.cleanSans(
                context,
                size: 13,
                color: colors.getSecondaryTextColor(context),
              ),
            ),
            if (_selectedYear != null) ...[
              const SizedBox(height: 16),
              MyAppFillButton.icon(
                onPressed: () => _openVideoDialog(null, _selectedYear),
                icon: const Icon(Icons.video_call_outlined, size: 16),
                label: 'Add First Video to $_selectedYear',
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Responsive columns & aspect ratios:
        // - Mobile (< 600px): 1 column, aspect ratio: 0.78 (generous vertical room, zero overflow)
        // - Tablet (600 - 950px): 2 columns, aspect ratio: 0.94
        // - Laptop (950 - 1350px): 3 columns, aspect ratio: 0.98
        // - Monitor / Desktop (>= 1350px): 4 columns, aspect ratio: 1.02
        final int cols;
        final double childAspectRatio;

        if (w < 600) {
          cols = 1;
          childAspectRatio = 0.78;
        } else if (w < 950) {
          cols = 2;
          childAspectRatio = 0.94;
        } else if (w < 1350) {
          cols = 3;
          childAspectRatio = 0.98;
        } else {
          cols = 4;
          childAspectRatio = 1.02;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, idx) {
            final video = videos[idx];

            // Auto-resolve thumbnail: if custom thumbnailUrl is missing, extract from YouTube URL!
            String thumbUrl = video.thumbnailUrl.trim();
            if (thumbUrl.isEmpty && video.youtubeUrl.trim().isNotEmpty) {
              final ytId = YoutubeUrlHelper.extractVideoId(video.youtubeUrl);
              if (ytId != null) {
                thumbUrl = YoutubeUrlHelper.buildThumbnailUrl(ytId);
              }
            }
            final bool hasValidThumb = thumbUrl.isNotEmpty;

            return Container(
              decoration: BoxDecoration(
                color: colors.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: video.isPublished
                      ? colors.heritageGold.withValues(alpha: 0.35)
                      : Colors.orange.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 16:9 Cinematic Video Thumbnail (NOT stretched or square!)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(13),
                          ),
                          child: hasValidThumb
                              ? AppCachedImage(
                                  imageUrl: thumbUrl,
                                  fit: BoxFit.cover,
                                  memCacheWidth: 640,
                                  memCacheHeight: 360,
                                  fallbackWidget: _buildDefaultVideoThumbnail(
                                    video,
                                    colors,
                                    styles,
                                  ),
                                )
                              : _buildDefaultVideoThumbnail(
                                  video,
                                  colors,
                                  styles,
                                ),
                        ),
                        // Dark gradient overlay for badges and play button legibility
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(13),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.45),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.65),
                              ],
                            ),
                          ),
                        ),
                        // YouTube Play Button Overlay
                        Center(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showVideoViewer(video),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.45),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Top Status Badge (PUBLISHED / DRAFT)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: video.isPublished
                                  ? Colors.green.shade900
                                  : Colors.orange.shade900,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              video.isPublished ? '● PUBLISHED' : '○ DRAFT',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Featured Badge (Top Right)
                        if (video.isFeatured)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8860B),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                '★ FEATURED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        // Duration Badge (Bottom Right)
                        if (video.duration.isNotEmpty)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                video.duration,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Metadata & Actions Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Upper Metadata block
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: HeritageBadge(
                                      label: video.tag.isNotEmpty
                                          ? video.tag
                                          : 'Garbi',
                                    ),
                                  ),
                                  if (video.sourceChannel.trim().isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        video.sourceChannel.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: styles.cleanSans(
                                          context,
                                          size: 10.5,
                                          color: colors
                                              .getSecondaryTextColor(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                video.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.editorialSerif(
                                  context,
                                  size: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (video.titleGu.trim().isNotEmpty &&
                                  video.titleGu.trim() !=
                                      video.title.trim()) ...[
                                const SizedBox(height: 2),
                                Text(
                                  video.titleGu,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.devotionalMotto(
                                    context,
                                    size: 11.5,
                                    color: colors.heritageGold,
                                  ),
                                ),
                              ],
                            ],
                          ),

                          // Bottom Actions Row (Always cleanly visible!)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Divider(
                                height: 1,
                                color: colors.getBorderColor(context),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: MyAppOutlineButton.icon(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      icon: const Icon(
                                        Icons.play_circle_outline_rounded,
                                        size: 14,
                                      ),
                                      label: 'Preview',
                                      onPressed: () => _showVideoViewer(video),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Tooltip(
                                    message: video.isFeatured
                                        ? 'Unmark Featured'
                                        : 'Mark as Featured',
                                    child: MyAppIconButton(
                                      icon: Icon(
                                        video.isFeatured
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        size: 17,
                                      ),
                                      color: video.isFeatured
                                          ? colors.heritageGold
                                          : colors.getMutedTextColor(context),
                                      onPressed: () {
                                        widget.store.toggleVideoFeatured(
                                          video.id,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Tooltip(
                                    message: video.isPublished
                                        ? 'Unpublish Video'
                                        : 'Publish Video',
                                    child: MyAppIconButton(
                                      icon: Icon(
                                        video.isPublished
                                            ? Icons.visibility_rounded
                                            : Icons.visibility_off_rounded,
                                        size: 17,
                                      ),
                                      color: video.isPublished
                                          ? Colors.green
                                          : Colors.grey,
                                      onPressed: () {
                                        widget.store.toggleVideoPublish(
                                          video.id,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  MyAppIconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 17,
                                    ),
                                    tooltip: 'Edit Video',
                                    color: colors.heritageGold,
                                    onPressed: () => _openVideoDialog(video),
                                  ),
                                  MyAppIconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 17,
                                    ),
                                    tooltip: 'Delete Video',
                                    color: Colors.redAccent,
                                    onPressed: () => _confirmDeleteVideo(video),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultVideoThumbnail(
    AdminVideo video,
    MyAppColors colors,
    MyAppTextStyles styles,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.deepMaroon,
            const Color(0xFF6E0D1B),
            const Color(0xFF380309),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: colors.heritageGold,
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.heritageGold.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/pavan_putra_logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              video.tag.isNotEmpty ? video.tag.toUpperCase() : 'GARBI VIDEO',
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 8,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: colors.heritageGold.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE WEBSITE PREVIEW (SECTION 1)
  // ---------------------------------------------------------------------------
  Widget _buildLiveHeaderPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final s = widget.store;
    final fallbackTag = _headerPreviewLang == 'gu'
        ? 'વિડિઓ સંગ્રહ'
        : 'AUDIO-VISUAL ARCHIVE';
    final fallbackTitle = _headerPreviewLang == 'gu'
        ? 'ગરબીની રાતો જુઓ. અમર સૂર-તાલ માણો.'
        : 'Watch the Sacred Nights. Hear the Timeless Rhythms.';
    final fallbackDesc = _headerPreviewLang == 'gu'
        ? '૪૫+ વર્ષોના દિવ્ય રાસોત્સવની સ્મૃતિઓ ફરી માણો. સત્તાવાર યુટ્યુબ વિડિઓ અને લાઈવ દર્શન.'
        : 'Relive 45+ years of divine Rasotsav celebrations across high-definition YouTube recordings and live streams.';

    final rawTag = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _tagEnCtrl.text,
      gu: _tagGuCtrl.text,
    );
    final displayTag = rawTag.isNotEmpty
        ? rawTag
        : (s.getTextOverride(_headerPreviewLang, 'videos_tag') ?? fallbackTag);

    final rawTitle = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _titleEnCtrl.text,
      gu: _titleGuCtrl.text,
    );
    final displayTitle = rawTitle.isNotEmpty
        ? rawTitle
        : (s.getTextOverride(_headerPreviewLang, 'videos_title') ??
              fallbackTitle);

    final rawDesc = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _descEnCtrl.text,
      gu: _descGuCtrl.text,
    );
    final displayDesc = rawDesc.isNotEmpty
        ? rawDesc
        : (s.getTextOverride(_headerPreviewLang, 'videos_desc') ??
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
                const SizedBox(height: 12),
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
  // LIVE WEBSITE PREVIEW (SECTION 2: LIVE STREAM)
  // ---------------------------------------------------------------------------
  Widget _buildLiveStreamPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final rawTitle = _resolvePreviewText(
      lang: _streamPreviewLang,
      en: _streamTitleEnCtrl.text,
      gu: _streamTitleGuCtrl.text,
    );
    final displayTitle = rawTitle.isNotEmpty
        ? rawTitle
        : (_streamPreviewLang == 'gu'
              ? 'સત્તાવાર યુટ્યુબ ચેનલ — નવરાત્રિ લાઈવ પ્રસારણ'
              : 'Official YouTube Channel — Live Broadcast');

    final rawAnnounce = _resolvePreviewText(
      lang: _streamPreviewLang,
      en: _streamAnnounceEnCtrl.text,
      gu: _streamAnnounceGuCtrl.text,
    );
    final displayDesc = _isLive
        ? (rawAnnounce.isNotEmpty
              ? rawAnnounce
              : (_streamPreviewLang == 'gu'
                    ? 'નવરાત્રિ દરમિયાન સોરઠીયાવાડી ગરબી ચોકથી સીધું પ્રસારણ.'
                    : 'Live streaming broadcast from Sorathiyavadi Garbi Ground.'))
        : (_streamScheduleCtrl.text.isNotEmpty
              ? _streamScheduleCtrl.text
              : (_streamPreviewLang == 'gu'
                    ? 'આગામી લાઈવ પ્રસારણ: દરરોજ રાત્રે ૮:૦૦ વાગ્યે'
                    : 'Upcoming Broadcast: Tonight at 8:00 PM IST'));

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
                  Icons.remove_red_eye_outlined,
                  size: 15,
                  color: colors.heritageGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Live Player Banner Preview (as seen by public visitors)',
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.heritageGold,
                    ),
                  ),
                ),
                _buildLanguageTogglePill(
                  activeLang: _streamPreviewLang,
                  onChanged: (lang) =>
                      setState(() => _streamPreviewLang = lang),
                  colors: colors,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CulturalFrameCard(
              padding: const EdgeInsets.all(18),
              backgroundColor: _isLive
                  ? const Color(0xFF380309)
                  : colors.deepMaroon,
              borderColor: _isLive
                  ? Colors.redAccent.withValues(alpha: 0.6)
                  : colors.heritageGold.withValues(alpha: 0.4),
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
                          color: _isLive
                              ? const Color(0xFFCC0000)
                              : const Color(0xFFB8860B),
                          boxShadow: _isLive
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          _isLive
                              ? Icons.sensors_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 2,
                              children: [
                                Text(
                                  _isLive
                                      ? (_streamPreviewLang == 'gu'
                                            ? '● લાઈવ પ્રસારણ'
                                            : '● LIVE BROADCAST')
                                      : (_streamPreviewLang == 'gu'
                                            ? 'આગામી પ્રસારણ'
                                            : 'UPCOMING BROADCAST'),
                                  style: styles.cleanSans(
                                    context,
                                    color: _isLive
                                        ? const Color(0xFFFF8A80)
                                        : colors.lightGold,
                                    size: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (_isLive)
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              displayTitle,
                              style: styles.editorialSerif(
                                context,
                                size: 16.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    displayDesc,
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      color: const Color(0xFFE2DDD1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER WIDGETS
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? colors.heritageGold : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isActive ? colors.deepMaroon : colors.heritageGold,
          ),
        ),
      ),
    );
  }

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: actions,
          ),
        ],
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
}
