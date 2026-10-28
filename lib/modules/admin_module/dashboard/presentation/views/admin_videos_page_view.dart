import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/utils/youtube_url_helper.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Full CRUD management view for Live Stream & Video Recordings in a Hierarchical structure (Year -> Videos)
class AdminVideosPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminVideosPageView({super.key, required this.store});

  @override
  State<AdminVideosPageView> createState() => _AdminVideosPageViewState();
}

class _AdminVideosPageViewState extends State<AdminVideosPageView> {
  // Live Stream Controllers
  late bool _isLive;
  late final TextEditingController _streamTitleCtrl;
  late final TextEditingController _streamUrlCtrl;
  late final TextEditingController _streamAnnounceCtrl;
  late final TextEditingController _streamScheduleCtrl;

  String? _selectedYear;

  @override
  void initState() {
    super.initState();
    final l = widget.store.liveStreamSettings;
    _isLive = l.isLive;
    _streamTitleCtrl = TextEditingController(text: l.title);
    _streamUrlCtrl = TextEditingController(text: l.streamUrl);
    _streamAnnounceCtrl = TextEditingController(text: l.announcement);
    _streamScheduleCtrl = TextEditingController(text: l.scheduleTime);
  }

  @override
  void dispose() {
    _streamTitleCtrl.dispose();
    _streamUrlCtrl.dispose();
    _streamAnnounceCtrl.dispose();
    _streamScheduleCtrl.dispose();
    super.dispose();
  }

  void _saveLiveStreamConfig() {
    final rawUrl = _streamUrlCtrl.text.trim();
    if (rawUrl.isNotEmpty && !YoutubeUrlHelper.isValid(rawUrl)) {
      MyAppToastMessage.warning(
        context,
        title: 'Invalid YouTube URL',
        description: 'Please enter a valid YouTube live stream URL or video ID.',
      );
      return;
    }

    final updated = widget.store.liveStreamSettings.copyWith(
      isLive: _isLive,
      title: _streamTitleCtrl.text.trim(),
      streamUrl: rawUrl,
      announcement: _streamAnnounceCtrl.text.trim(),
      scheduleTime: _streamScheduleCtrl.text.trim(),
    );
    widget.store.updateLiveStream(updated);
    MyAppToastMessage.success(
      context,
      title: 'Live Stream Configured',
      description: 'Broadcast status: ${_isLive ? "LIVE NOW 🔴" : "OFFLINE"}',
    );
  }

  void _openVideoDialog([AdminVideo? video]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final titleCtrl = TextEditingController(text: video?.title ?? '');
    final titleGuCtrl = TextEditingController(text: video?.titleGu ?? '');
    final urlCtrl = TextEditingController(text: video?.youtubeUrl ?? '');
    final categoryCtrl = TextEditingController(text: video?.tag ?? 'Garbi');
    final durationCtrl = TextEditingController(text: video?.duration ?? '');
    final yearCtrl = TextEditingController(text: video?.year ?? (_selectedYear ?? '2024'));
    final channelCtrl = TextEditingController(text: video?.sourceChannel ?? 'Ratnadeep Sound');
    bool isPublished = video?.isPublished ?? true;
    bool isFeatured = video?.isFeatured ?? false;
    String? previewThumb = video?.thumbnailUrl;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isMobile = MediaQuery.sizeOf(context).width < 700;

          return AlertDialog(
            backgroundColor: colors.getCardBackgroundColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            title: Row(
              children: [
                Icon(video == null ? Icons.add_circle_outline_rounded : Icons.edit_note_rounded,
                    color: colors.heritageGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    video == null ? 'Add Video Recording' : 'Edit Video Recording',
                    style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: isMobile ? double.infinity : 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyAppTextFormField(
                      controller: urlCtrl,
                      labelText: 'YouTube URL or Video ID *',
                      hintText: 'e.g. https://www.youtube.com/watch?v=OfSiIzkxW8g or youtu.be',
                      prefixIcon: const Icon(Icons.link_rounded),
                      onChanged: (val) {
                        final extractedId = YoutubeUrlHelper.extractVideoId(val);
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
                              Image.network(
                                previewThumb!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: colors.heritageMaroon,
                                  child: const Icon(Icons.video_camera_back, color: Colors.white, size: 36),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Valid Video ID',
                                    style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    MyAppTextFormField(
                      controller: titleCtrl,
                      labelText: 'Video Title (English) *',
                      hintText: 'e.g. Chand-Mund no Raas — Pavanputra Garbi Live',
                      showTranslateIcon: true,
                      targetLanguageController: titleGuCtrl,
                      prefixIcon: const Icon(Icons.title_rounded),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: titleGuCtrl,
                      labelText: 'Video Title (Gujarati)',
                      hintText: 'e.g. ચંડ-મુંડ નો રાસ — પવનપુત્ર ગરબી લાઈવ',
                      prefixIcon: const Icon(Icons.subtitles_outlined),
                    ),
                    const SizedBox(height: 12),
                    if (isMobile) ...[
                      MyAppTextFormField(
                        controller: yearCtrl,
                        labelText: 'Festival Year *',
                        hintText: 'e.g. 2024',
                        prefixIcon: const Icon(Icons.calendar_today_rounded),
                      ),
                      const SizedBox(height: 12),
                      MyAppDropdown<String>(
                        labelText: 'Category *',
                        value: ['Garbi', 'Raas', 'Aarti', 'Live Recording', 'Archive'].contains(categoryCtrl.text)
                            ? categoryCtrl.text
                            : 'Garbi',
                        items: const [
                          MyAppDropdownItem(value: 'Garbi', label: 'Garbi (ગરબી)'),
                          MyAppDropdownItem(value: 'Raas', label: 'Raas (રાસ)'),
                          MyAppDropdownItem(value: 'Aarti', label: 'Aarti (આરતી)'),
                          MyAppDropdownItem(value: 'Live Recording', label: 'Live Recording (લાઈવ)'),
                          MyAppDropdownItem(value: 'Archive', label: 'Archive (આર્કાઇવ)'),
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
                              hintText: 'e.g. 2024',
                              prefixIcon: const Icon(Icons.calendar_today_rounded),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyAppDropdown<String>(
                              labelText: 'Category *',
                              value: ['Garbi', 'Raas', 'Aarti', 'Live Recording', 'Archive'].contains(categoryCtrl.text)
                                  ? categoryCtrl.text
                                  : 'Garbi',
                              items: const [
                                MyAppDropdownItem(value: 'Garbi', label: 'Garbi (ગરબી)'),
                                MyAppDropdownItem(value: 'Raas', label: 'Raas (રાસ)'),
                                MyAppDropdownItem(value: 'Aarti', label: 'Aarti (આરતી)'),
                                MyAppDropdownItem(value: 'Live Recording', label: 'Live Recording (લાઈવ)'),
                                MyAppDropdownItem(value: 'Archive', label: 'Archive (આર્કાઇવ)'),
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
                        labelText: 'Source Channel',
                        hintText: 'Ratnadeep Sound / Pavanputra',
                        prefixIcon: const Icon(Icons.tv_rounded),
                      ),
                      const SizedBox(height: 12),
                      MyAppTextFormField(
                        controller: durationCtrl,
                        labelText: 'Duration (optional)',
                        hintText: 'e.g. 18:42 or blank',
                        prefixIcon: const Icon(Icons.timer_outlined),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: MyAppTextFormField(
                              controller: channelCtrl,
                              labelText: 'Source Channel',
                              hintText: 'Ratnadeep Sound / Pavanputra',
                              prefixIcon: const Icon(Icons.tv_rounded),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MyAppTextFormField(
                              controller: durationCtrl,
                              labelText: 'Duration (optional)',
                              hintText: 'e.g. 18:42 or blank',
                              prefixIcon: const Icon(Icons.timer_outlined),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Switches
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Published to Public Website'),
                      subtitle: const Text('When disabled, this video remains draft and hidden from public.'),
                      value: isPublished,
                      activeTrackColor: Colors.green,
                      onChanged: (val) => setDialogState(() => isPublished = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Featured Video'),
                      subtitle: const Text('Highlights this video in the top carousel and featured sections.'),
                      value: isFeatured,
                      activeTrackColor: colors.heritageGold,
                      onChanged: (val) => setDialogState(() => isFeatured = val),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
              MyAppFillButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final rawUrl = urlCtrl.text.trim();
                  final extractedId = YoutubeUrlHelper.extractVideoId(rawUrl);

                  if (title.isEmpty) {
                    MyAppToastMessage.warning(context, title: 'Title Required', description: 'Please enter video title.');
                    return;
                  }
                  if (extractedId == null) {
                    MyAppToastMessage.warning(
                      context,
                      title: 'Valid YouTube URL Required',
                      description: 'Please paste a valid YouTube watch, shorts, live, or youtu.be URL.',
                    );
                    return;
                  }

                  // Check duplicate when adding new video
                  if (video == null) {
                    final isDuplicate = widget.store.videos.any((v) => v.youtubeVideoId == extractedId);
                    if (isDuplicate) {
                      MyAppToastMessage.warning(
                        context,
                        title: 'Duplicate Video',
                        description: 'A video with YouTube ID ($extractedId) already exists in the archive.',
                      );
                      return;
                    }
                  }

                  final canonicalUrl = YoutubeUrlHelper.buildWatchUrl(extractedId);
                  final thumb = YoutubeUrlHelper.buildThumbnailUrl(extractedId);

                  if (video == null) {
                    widget.store.addVideo(AdminVideo(
                      id: 'vid-${DateTime.now().millisecondsSinceEpoch}',
                      youtubeVideoId: extractedId,
                      title: title,
                      titleGu: titleGuCtrl.text.trim(),
                      youtubeUrl: canonicalUrl,
                      thumbnailUrl: thumb,
                      duration: durationCtrl.text.trim(),
                      tag: categoryCtrl.text.trim().isEmpty ? 'Garbi' : categoryCtrl.text.trim(),
                      year: yearCtrl.text.trim().isEmpty ? '2024' : yearCtrl.text.trim(),
                      sourceChannel: channelCtrl.text.trim().isEmpty ? 'Ratnadeep Sound' : channelCtrl.text.trim(),
                      isPublished: isPublished,
                      isFeatured: isFeatured,
                    ));
                    MyAppToastMessage.success(context, title: 'Video Added', description: 'Video "$title" added successfully.');
                  } else {
                    widget.store.updateVideo(video.copyWith(
                      youtubeVideoId: extractedId,
                      title: title,
                      titleGu: titleGuCtrl.text.trim(),
                      youtubeUrl: canonicalUrl,
                      thumbnailUrl: thumb,
                      duration: durationCtrl.text.trim(),
                      tag: categoryCtrl.text.trim().isEmpty ? 'Garbi' : categoryCtrl.text.trim(),
                      year: yearCtrl.text.trim().isEmpty ? '2024' : yearCtrl.text.trim(),
                      sourceChannel: channelCtrl.text.trim().isEmpty ? 'Ratnadeep Sound' : channelCtrl.text.trim(),
                      isPublished: isPublished,
                      isFeatured: isFeatured,
                    ));
                    MyAppToastMessage.success(context, title: 'Video Updated', description: 'Video "$title" updated.');
                  }
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

  void _confirmDeleteVideo(AdminVideo video) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Video?'),
        content: Text('Are you sure you want to remove "${video.title}" from the archive?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteVideo(video.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(context, title: 'Video Deleted', description: 'Video "${video.title}" deleted.');
            },
            label: 'Delete',
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
          websitePageTitle: 'Live Stream & Videos',
          websiteRoute: '/videos',
          explanation: 'Controls YouTube Live Stream configuration and manages the historical Video Archive with verified Ratnadeep Sound / Mandal recordings.',
        ),

        // -------------------------------------------------------------
        // LIVE STREAM SECTION (Always Visible at Top)
        // -------------------------------------------------------------
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              'Live Stream Broadcast Control',
              style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
            ),
            HeritageBadge(
              label: _isLive ? '🔴 BROADCAST ACTIVE' : 'BROADCAST OFFLINE',
              backgroundColor: _isLive ? Colors.red.withValues(alpha: 0.15) : null,
              textColor: _isLive ? Colors.redAccent : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        CulturalFrameCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _isLive ? Icons.sensors_rounded : Icons.sensors_off_rounded,
                          color: _isLive ? Colors.redAccent : colors.getMutedTextColor(context),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLive ? 'LIVE BROADCAST IS RUNNING' : 'BROADCAST IS OFFLINE',
                                style: styles.cleanSans(
                                  context,
                                  size: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _isLive ? Colors.redAccent : colors.getMutedTextColor(context),
                                ),
                              ),
                              Text(
                                _isLive ? 'Public visitors see "LIVE NOW" banner on the website' : 'Public visitors see upcoming schedule banner',
                                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: _isLive,
                    activeThumbColor: Colors.redAccent,
                    onChanged: (val) => setState(() => _isLive = val),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isMobile) ...[
                MyAppTextFormField(
                  controller: _streamTitleCtrl,
                  labelText: 'Stream Title (e.g. Navratri Day 1 Maha Aarti Live)',
                  prefixIcon: const Icon(Icons.title_rounded),
                ),
                const SizedBox(height: 12),
                MyAppTextFormField(
                  controller: _streamUrlCtrl,
                  labelText: 'YouTube Live Stream URL or Video ID',
                  prefixIcon: const Icon(Icons.live_tv_rounded),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _streamTitleCtrl,
                        labelText: 'Stream Title (e.g. Navratri Day 1 Maha Aarti Live)',
                        prefixIcon: const Icon(Icons.title_rounded),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _streamUrlCtrl,
                        labelText: 'YouTube Live Stream URL or Video ID',
                        prefixIcon: const Icon(Icons.live_tv_rounded),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              if (isMobile) ...[
                MyAppTextFormField(
                  controller: _streamScheduleCtrl,
                  labelText: 'Schedule Time (e.g. Tonight at 8:00 PM IST)',
                  prefixIcon: const Icon(Icons.schedule_rounded),
                ),
                const SizedBox(height: 12),
                MyAppTextAreaField(
                  controller: _streamAnnounceCtrl,
                  labelText: 'Announcement Banner Text',
                  hintText: 'e.g. Special live broadcast from Sorathiyavadi Garbi Ground',
                  minLines: 2,
                  maxLines: 3,
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _streamScheduleCtrl,
                        labelText: 'Schedule Time (e.g. Tonight at 8:00 PM IST)',
                        prefixIcon: const Icon(Icons.schedule_rounded),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyAppTextAreaField(
                        controller: _streamAnnounceCtrl,
                        labelText: 'Announcement Banner Text',
                        hintText: 'e.g. Special live broadcast from Sorathiyavadi Garbi Ground',
                        minLines: 2,
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: MyAppFillButton.icon(
                  onPressed: _saveLiveStreamConfig,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: 'Save Stream Configuration',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // -------------------------------------------------------------
        // VIDEO ARCHIVE HIERARCHY
        // -------------------------------------------------------------
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeritageBadge(label: 'WEBSITE CONTENT / VIDEO ARCHIVES'),
                const SizedBox(height: 6),
                Text(
                  'Video Archive Explorer',
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Manage recordings by Year with direct YouTube validation, thumbnail preview, and publish controls.',
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
            MyAppFillButton.icon(
              onPressed: () => _openVideoDialog(),
              icon: const Icon(Icons.video_call_outlined, size: 18),
              label: _selectedYear != null ? 'Add Video to $_selectedYear' : 'Add Video',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Interactive Breadcrumbs Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.getCardBackgroundColor(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.getBorderColor(context)),
          ),
          child: Row(
            children: [
              _buildCrumb('All Years', isActive: _selectedYear == null, onTap: () {
                setState(() => _selectedYear = null);
              }, colors: colors, styles: styles),
              if (_selectedYear != null) ...[
                _buildCrumbSeparator(colors),
                _buildCrumb(_selectedYear!, isActive: true, onTap: () {}, colors: colors, styles: styles),
              ]
            ],
          ),
        ),
        const SizedBox(height: 24),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentLevelContent(context, colors, styles),
        ),
      ],
    );
  }

  Widget _buildCrumbSeparator(MyAppColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Icon(Icons.chevron_right_rounded, size: 18, color: colors.getMutedTextColor(context)),
    );
  }

  Widget _buildCrumb(String label, {required bool isActive, required VoidCallback onTap, required MyAppColors colors, required MyAppTextStyles styles}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: styles.cleanSans(
            context,
            size: 13,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
            color: isActive ? (colors.isDarkMode(context) ? colors.heritageGold : colors.heritageMaroon) : colors.getPrimaryTextColor(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLevelContent(BuildContext context, MyAppColors colors, MyAppTextStyles styles) {
    if (_selectedYear == null) {
      return _buildYearsGrid(context, colors, styles);
    } else {
      return _buildVideosGrid(context, colors, styles);
    }
  }

  Widget _buildYearsGrid(BuildContext context, MyAppColors colors, MyAppTextStyles styles) {
    final uniqueYears = widget.store.videos.map((v) => v.year).toSet().toList()..sort((a, b) => b.compareTo(a));

    if (uniqueYears.isEmpty) {
      return const CulturalFrameCard(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No videos in archive. Click "Add Video" to add one.')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: uniqueYears.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final year = uniqueYears[index];
        final allVideosInYear = widget.store.videos.where((v) => v.year == year).toList();
        final publishedCount = allVideosInYear.where((v) => v.isPublished).length;

        return InkWell(
          onTap: () => setState(() => _selectedYear = year),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: colors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.heritageGold.withValues(alpha: 0.4), width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library_rounded, size: 40, color: colors.heritageGold),
                const SizedBox(height: 12),
                Text(
                  year,
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '${allVideosInYear.length} Videos ($publishedCount Live)',
                  style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideosGrid(BuildContext context, MyAppColors colors, MyAppTextStyles styles) {
    final yearVideos = widget.store.videos.where((v) => v.year == _selectedYear).toList();

    if (yearVideos.isEmpty) {
      return const CulturalFrameCard(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No videos in this year. Click "Add Video to [Year]".')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 1100 ? 3 : (width > 700 ? 2 : 1);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: yearVideos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            final video = yearVideos[index];
            return Container(
              decoration: BoxDecoration(
                color: colors.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: video.isPublished
                      ? colors.getBorderColor(context)
                      : Colors.orange.withValues(alpha: 0.6),
                  width: 1.4,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.network(
                            video.thumbnailUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: colors.heritageMaroon,
                              child: const Icon(Icons.video_file, color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                        // YouTube Play badge
                        Center(
                          child: InkWell(
                            onTap: () {
                              final url = YoutubeUrlHelper.buildWatchUrl(video.youtubeVideoId);
                              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                            ),
                          ),
                        ),
                        // Badges
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: video.isPublished ? Colors.green.shade800 : Colors.black87,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video.isPublished ? '● PUBLISHED' : '○ DRAFT / HIDDEN',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (video.isFeatured)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB8860B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '★ FEATURED',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        if (video.duration.isNotEmpty)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                video.duration,
                                style: styles.cleanSans(context, size: 10, color: Colors.white, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: HeritageBadge(label: '${video.tag} • ${video.sourceChannel}'),
                            ),
                            const SizedBox(width: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MyAppIconButton(
                                  icon: Icon(
                                    video.isPublished ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    size: 19,
                                  ),
                                  tooltip: video.isPublished ? 'Unpublish' : 'Publish',
                                  color: video.isPublished ? Colors.green : Colors.grey,
                                  onPressed: () => widget.store.toggleVideoPublish(video.id),
                                ),
                                const SizedBox(width: 4),
                                MyAppIconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 19),
                                  tooltip: 'Edit details',
                                  color: colors.heritageGold,
                                  onPressed: () => _openVideoDialog(video),
                                ),
                                const SizedBox(width: 4),
                                MyAppIconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
                                  tooltip: 'Delete',
                                  color: Colors.redAccent,
                                  onPressed: () => _confirmDeleteVideo(video),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          video.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                        ),
                        if (video.titleGu.isNotEmpty)
                          Text(
                            video.titleGu,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: styles.devotionalMotto(context, size: 12, color: colors.getSecondaryTextColor(context)),
                          ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () {
                            final url = YoutubeUrlHelper.buildWatchUrl(video.youtubeVideoId);
                            launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.open_in_new_rounded, size: 13, color: Colors.blueAccent),
                              const SizedBox(width: 4),
                              Text(
                                'Watch on YouTube (${video.youtubeVideoId})',
                                style: const TextStyle(fontSize: 11, color: Colors.blueAccent, decoration: TextDecoration.underline),
                              ),
                            ],
                          ),
                        ),
                      ],
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
}
