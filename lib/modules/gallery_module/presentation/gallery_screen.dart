import 'package:flutter/material.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/localization/my_app_translations.dart';
import '../../../core/my_app_colors/my_app_colors.dart';
import '../../../core/my_app_scaffold/my_app_scaffold.dart';
import '../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/heritage_badge.dart';
import '../../../core/widgets/my_app_ui_components.dart';
import '../../admin_module/dashboard/data/admin_data_store.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, required this.year, required this.album});
  final String year;
  final String album;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    AdminDataStore.instance.ensureGalleryLoaded(
      widget.year,
      widget.album,
    );
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

        final langCode = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
        final s = AdminDataStore.instance;

        final archiveTag = s.getTextOverride(langCode, 'archive_tag') ?? context.tr('archive_tag');
        final officialMediaTag = s.getTextOverride(langCode, 'official_media') ?? context.tr('official_media');
        final galleryDesc = s.getTextOverride(langCode, 'gallery_desc') ?? context.tr('gallery_desc');

        final filterKeys = [
          'filter_all',
          'filter_day1',
          'filter_day2',
          'filter_day3',
        ];

        final allAlbums = s.albums;
        final matchingAlbum = allAlbums.firstWhere(
          (a) => a.id == widget.album || a.name.toLowerCase().contains(widget.album.toLowerCase()),
          orElse: () => AdminAlbum(id: '', year: widget.year, name: '', dayTag: '', description: ''),
        );
        final albumTitleText = matchingAlbum.name.isNotEmpty
            ? (langCode == 'gu' ? context.trDynamic(matchingAlbum.name) : matchingAlbum.name)
            : widget.album.replaceAll('-', ' ').toUpperCase();

        final allPhotosList = s.photos;
        final yearFiltered = widget.year.toLowerCase() == 'all'
            ? allPhotosList
            : allPhotosList.where((p) => p.year.toString() == widget.year).toList();
        final basePhotos = yearFiltered.isNotEmpty ? yearFiltered : allPhotosList;

        final displayPhotos = _selectedFilterIndex == 0
            ? basePhotos
            : basePhotos.where((p) {
                final d = _selectedFilterIndex.toString();
                return p.day.contains(d) ||
                    p.titleGu.contains(d) ||
                    p.titleEn.contains(d);
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
                    // Top Tag & Year Badge (Responsive Wrap so it wraps onto a new line on mobile)
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        HeritageBadge(
                          label: '$archiveTag / ${widget.year}',
                        ),
                        HeritageBadge(
                          label: officialMediaTag,
                          backgroundColor: colors.heritageGold.withValues(
                            alpha: 0.12,
                          ),
                          textColor: colors.getAccentColor(context),
                          borderColor: colors.heritageGold.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Album Title
                    Text(albumTitleText, style: styles.h1(context)),
                    const SizedBox(height: 8),
                    Text(
                      galleryDesc,
                      style: styles.bodyText(context),
                    ),
                    const SizedBox(height: 28),

                    // Filter Chips
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        for (int i = 0; i < filterKeys.length; i++)
                          InkWell(
                            onTap: () => setState(() => _selectedFilterIndex = i),
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedFilterIndex == i
                                    ? colors.heritageMaroon
                                    : colors.getCardBackgroundColor(context),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedFilterIndex == i
                                      ? colors.heritageMaroon
                                      : colors.getBorderColor(context),
                                ),
                              ),
                              child: Text(
                                context.tr(filterKeys[i]),
                                style: styles.cleanSans(
                                  context,
                                  size: 11.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: _selectedFilterIndex == i
                                      ? colors.white
                                      : colors.getPrimaryTextColor(context),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Photos Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = isMobile
                            ? 1
                            : constraints.maxWidth < 900
                                ? 2
                                : 3;
                        if (displayPhotos.isEmpty) {
                          return CulturalFrameCard(
                            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.photo_library_outlined,
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
                          itemCount: displayPhotos.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.25,
                          ),
                          itemBuilder: (context, index) {
                            final photo = displayPhotos[index];
                            final dayLabel = photo.day.trim().isNotEmpty
                                ? photo.day
                                : 'નોરતા ${index + 1}';
                            final isGu = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
                            final caption = isGu
                                ? (photo.titleGu.isNotEmpty ? photo.titleGu : context.trDynamic(photo.titleEn))
                                : (photo.titleEn.isNotEmpty ? photo.titleEn : photo.titleGu);
                            return _PhotoCard(
                              day: dayLabel,
                              caption: caption,
                              imageUrl: photo.imageUrl,
                              index: index,
                              onTap: () => _openViewer(
                                context,
                                dayLabel,
                                caption,
                                photo.imageUrl,
                              ),
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

  void _openViewer(
    BuildContext context,
    String day,
    String title,
    String imageUrl,
  ) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: colors.deepMaroon,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colors.heritageGold.withValues(alpha: 0.5),
            width: 1.4,
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeritageBadge(
                      label: day,
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      textColor: colors.lightGold,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B0104),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.heritageGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildEmblemFallback(colors, styles, dialogContext),
                          )
                        : imageUrl.startsWith('assets/')
                            ? Image.asset(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildEmblemFallback(colors, styles, dialogContext),
                              )
                            : _buildEmblemFallback(colors, styles, dialogContext),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: styles.editorialSerif(
                    dialogContext,
                    size: 18,
                    fontWeight: FontWeight.w700,
                    color: colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmblemFallback(MyAppColors colors, MyAppTextStyles styles, BuildContext dialogContext) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.heritageGold,
                width: 1.6,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                'assets/images/pavan_putra_logo.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            dialogContext.tr('photo_viewer_title'),
            style: styles.editorialSerif(
              dialogContext,
              size: 16,
              fontWeight: FontWeight.w700,
              color: colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dialogContext.tr('photo_viewer_desc'),
            style: styles.cleanSans(
              dialogContext,
              size: 11,
              color: const Color(0xFFC5BFA5),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String day;
  final String caption;
  final String imageUrl;
  final int index;
  final VoidCallback onTap;

  const _PhotoCard({
    required this.day,
    required this.caption,
    required this.imageUrl,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return CulturalFrameCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: index.isEven
                    ? colors.deepMaroon
                    : const Color(0xFF230306),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.startsWith('http'))
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildCardEmblem(colors),
                      ),
                    )
                  else if (imageUrl.startsWith('assets/'))
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildCardEmblem(colors),
                      ),
                    )
                  else
                    _buildCardEmblem(colors),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: HeritageBadge(
                      label: day,
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                      textColor: colors.lightGold,
                      borderColor: colors.heritageGold.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.editorialSerif(
                    context,
                    size: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'PAVAN PUTRA ARCHIVE • HIGH RESOLUTION',
                  style: styles.cleanSans(
                    context,
                    size: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: colors.getAccentColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardEmblem(MyAppColors colors) {
    return Center(
      child: Opacity(
        opacity: 0.85,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.heritageGold,
              width: 1.2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset(
              'assets/images/pavan_putra_logo.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
