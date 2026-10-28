import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/localization/my_app_translations.dart';
import '../../../core/my_app_colors/my_app_colors.dart';
import '../../../core/my_app_scaffold/my_app_scaffold.dart';
import '../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../core/utils/youtube_url_helper.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/heritage_badge.dart';
import '../../../core/widgets/my_app_ui_components.dart';
import '../../admin_module/dashboard/data/admin_data_store.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  String _selectedYear = 'All';
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    AdminDataStore.instance.ensureVideosLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final colors = serviceLocator<MyAppColors>();
        final styles = serviceLocator<MyAppTextStyles>();
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isMobile = screenWidth < 768;
        final isGujarati =
            Localizations.maybeLocaleOf(context)?.languageCode == 'gu';

        final live = AdminDataStore.instance.liveStreamSettings;
        final isLiveNow = live.isLive;
        final liveBadge = isLiveNow
            ? (isGujarati ? '● લાઈવ પ્રસારણ શરૂ છે' : '● LIVE BROADCAST')
            : (isGujarati ? 'આગામી લાઈવ પ્રસારણ' : 'UPCOMING BROADCAST');
        final liveTitle = live.title.trim().isNotEmpty
            ? (isGujarati ? context.trDynamic(live.title) : live.title)
            : context.tr('videos_live_title');
        final liveDesc = isLiveNow
            ? (live.announcement.isNotEmpty
                ? live.announcement
                : context.tr('videos_live_desc'))
            : (live.scheduleTime.isNotEmpty
                ? live.scheduleTime
                : context.tr('videos_live_desc'));

        // Filter only published videos for public website
        final allPublished = AdminDataStore.instance.publishedVideos;

        // Collect available years and categories
        final years = ['All', ...allPublished.map((v) => v.year).toSet().toList()..sort((a, b) => b.compareTo(a))];
        final categories = [
          'All',
          ...allPublished.map((v) => v.tag).toSet().toList()..sort(),
        ];

        final filteredVideos = allPublished.where((v) {
          if (_selectedYear != 'All' && v.year != _selectedYear) return false;
          if (_selectedCategory != 'All' && v.tag != _selectedCategory) return false;
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final matchesEn = v.title.toLowerCase().contains(query);
            final matchesGu = v.titleGu.toLowerCase().contains(query);
            final matchesTag = v.tag.toLowerCase().contains(query);
            if (!matchesEn && !matchesGu && !matchesTag) return false;
          }
          return true;
        }).toList();

        return MyAppScaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: isMobile ? 32 : 48,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    HeritageBadge(label: context.tr('videos_tag')),
                    const SizedBox(height: 16),
                    Text(context.tr('videos_title'), style: styles.h1(context)),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Text(
                        context.tr('videos_desc'),
                        style: styles
                            .bodyText(context)
                            .copyWith(fontSize: isMobile ? 14 : 16),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Live Streaming Banner
                    CulturalFrameCard(
                      padding: EdgeInsets.all(isMobile ? 20 : 30),
                      backgroundColor: isLiveNow
                          ? const Color(0xFF380309)
                          : colors.deepMaroon,
                      borderColor: isLiveNow
                          ? Colors.redAccent.withValues(alpha: 0.6)
                          : colors.heritageGold.withValues(alpha: 0.4),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLiveNow
                                  ? const Color(0xFFCC0000)
                                  : const Color(0xFFB8860B),
                              boxShadow: isLiveNow
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withValues(alpha: 0.4),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isLiveNow
                                  ? Icons.sensors_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      liveBadge,
                                      style: styles.cleanSans(
                                        context,
                                        color: isLiveNow
                                            ? const Color(0xFFFF8A80)
                                            : colors.lightGold,
                                        size: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    if (isLiveNow) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  liveTitle,
                                  style: styles.editorialSerif(
                                    context,
                                    size: isMobile ? 16 : 22,
                                    fontWeight: FontWeight.w700,
                                    color: colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  liveDesc,
                                  style: styles
                                      .bodySmall(context)
                                      .copyWith(color: const Color(0xFFE2DDD1)),
                                ),
                              ],
                            ),
                          ),
                          if (isLiveNow && live.streamUrl.isNotEmpty) ...[
                            const SizedBox(width: 16),
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFCC0000),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 20,
                                  vertical: isMobile ? 10 : 14,
                                ),
                              ),
                              onPressed: () {
                                final vidId = YoutubeUrlHelper.extractVideoId(live.streamUrl);
                                if (vidId != null) {
                                  _openVideoPlayerModal(
                                    context,
                                    AdminVideo(
                                      id: 'live-stream',
                                      youtubeVideoId: vidId,
                                      title: live.title,
                                      tag: 'Live Stream',
                                      duration: 'LIVE',
                                      youtubeUrl: live.streamUrl,
                                      year: '2024',
                                      sourceChannel: 'Ratnadeep Sound',
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                              label: Text(
                                isMobile ? 'Watch' : 'Watch Live Now',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Filter & Search Controls
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('videos_featured'),
                          style: styles.h2(context),
                        ),
                        // Search bar
                        SizedBox(
                          width: isMobile ? screenWidth - 32 : 280,
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: isGujarati ? 'વિડિયો શોધો...' : 'Search videos...',
                              prefixIcon: const Icon(Icons.search_rounded, size: 20),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Year Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Row(
                        children: [
                          Text(
                            'Year: ',
                            style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          ...years.map((y) {
                            final isSelected = _selectedYear == y;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(y == 'All' ? 'All Years' : y),
                                selected: isSelected,
                                selectedColor: colors.heritageMaroon,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : colors.getPrimaryTextColor(context),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12.5,
                                ),
                                onSelected: (sel) {
                                  if (sel) setState(() => _selectedYear = y);
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      child: Row(
                        children: [
                          Text(
                            'Category: ',
                            style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          ...categories.map((c) {
                            final isSelected = _selectedCategory == c;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c == 'All' ? 'All Categories' : c),
                                selected: isSelected,
                                selectedColor: colors.heritageGold,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.black : colors.getPrimaryTextColor(context),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                onSelected: (sel) {
                                  if (sel) setState(() => _selectedCategory = c);
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Video Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = isMobile
                            ? 1
                            : constraints.maxWidth < 960
                                ? 2
                                : 3;

                        if (filteredVideos.isEmpty) {
                          return CulturalFrameCard(
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.video_library_outlined,
                                    size: 44,
                                    color: colors.heritageGold,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    context.tr('archive_empty_title'),
                                    style: styles.editorialSerif(
                                      context,
                                      size: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    context.tr('archive_empty'),
                                    textAlign: TextAlign.center,
                                    style: styles.cleanSans(
                                      context,
                                      size: 13,
                                      color: colors.getSecondaryTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredVideos.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 24,
                            childAspectRatio: 1.15,
                          ),
                          itemBuilder: (context, index) {
                            final video = filteredVideos[index];
                            final displayTitle = isGujarati && video.titleGu.isNotEmpty
                                ? video.titleGu
                                : video.title;

                            return _VideoItemCard(
                              video: video,
                              displayTitle: displayTitle,
                              onTap: () => _openVideoPlayerModal(context, video),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openVideoPlayerModal(BuildContext context, AdminVideo video) {
    showMyAppDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _YoutubePlayerDialog(video: video),
    );
  }
}

class _YoutubePlayerDialog extends StatefulWidget {
  final AdminVideo video;

  const _YoutubePlayerDialog({required this.video});

  @override
  State<_YoutubePlayerDialog> createState() => _YoutubePlayerDialogState();
}

class _YoutubePlayerDialogState extends State<_YoutubePlayerDialog> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeVideoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        showVideoAnnotations: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
    final displayTitle = isGujarati && widget.video.titleGu.isNotEmpty
        ? widget.video.titleGu
        : widget.video.title;

    final watchUrl = YoutubeUrlHelper.buildWatchUrl(widget.video.youtubeVideoId);

    return Dialog(
      backgroundColor: colors.deepMaroon,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colors.heritageGold.withValues(alpha: 0.6),
          width: 1.4,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Tag, Channel & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeritageBadge(
                    label: '${widget.video.tag} • ${widget.video.year} • ${widget.video.sourceChannel}',
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    textColor: colors.lightGold,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Embedded YouTube Player
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: YoutubePlayer(
                      controller: _controller,
                      aspectRatio: 16 / 9,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                displayTitle,
                style: styles.editorialSerif(
                  context,
                  size: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // Action Bar: "Watch on YouTube" Fallback & Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Channel: ${widget.video.sourceChannel}',
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      color: const Color(0xFFE2DDD1),
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFCC0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () {
                      launchUrl(
                        Uri.parse(watchUrl),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text(
                      'Watch on YouTube',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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

class _VideoItemCard extends StatelessWidget {
  final AdminVideo video;
  final String displayTitle;
  final VoidCallback onTap;

  const _VideoItemCard({
    required this.video,
    required this.displayTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final tag = '${video.tag} • ${video.year}';
    final thumb = video.thumbnailUrl.isNotEmpty
        ? video.thumbnailUrl
        : YoutubeUrlHelper.buildThumbnailUrl(video.youtubeVideoId);

    return CulturalFrameCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Thumbnail Area with real image and play button
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colors.deepMaroon,
                      child: Center(
                        child: Icon(Icons.videocam_rounded, size: 48, color: colors.lightGold),
                      ),
                    ),
                  ),
                  // Gradient shadow
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),
                  // Play button icon
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFCC0000).withValues(alpha: 0.9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                  // Top Tag Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: HeritageBadge(
                      label: tag,
                      backgroundColor: Colors.black.withValues(alpha: 0.7),
                      textColor: colors.lightGold,
                      borderColor: colors.heritageGold.withValues(alpha: 0.4),
                    ),
                  ),
                  // Duration or Full HD badge
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration.isNotEmpty ? video.duration : 'FULL HD',
                        style: styles.cleanSans(
                          context,
                          size: 10,
                          fontWeight: FontWeight.w700,
                          color: colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Video Title & Channel Area
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styles.editorialSerif(
                    context,
                    size: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      video.sourceChannel,
                      style: styles.cleanSans(
                        context,
                        size: 11,
                        fontWeight: FontWeight.w600,
                        color: colors.getAccentColor(context),
                      ),
                    ),
                    Text(
                      'YOUTUBE ARCHIVE',
                      style: styles.cleanSans(
                        context,
                        size: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: colors.getMutedTextColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
