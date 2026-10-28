import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/localization/my_app_translations.dart';
import '../../../core/my_app_colors/my_app_colors.dart';
import '../../../core/my_app_scaffold/my_app_scaffold.dart';
import '../../../core/my_app_shimmer/my_app_shimmer.dart';
import '../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/heritage_badge.dart';
import '../../../core/widgets/heritage_divider.dart';
import '../../../utils/navigation_manager.dart';
import '../../admin_module/dashboard/data/admin_data_store.dart';
import '../data/repositories/garbi_year_repository.dart';
import 'archive_bloc.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key, this.year});
  final String? year;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ArchiveCubit(const FirestoreGarbiYearRepository())..load(),
      child: Builder(
        builder: (context) {
          return ListenableBuilder(
            listenable: AdminDataStore.instance,
            builder: (context, _) {
              return MyAppScaffold(
                body: BlocConsumer<ArchiveCubit, ArchiveState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return _ArchiveBody(year: year, state: state);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ArchiveBody extends StatelessWidget {
  const _ArchiveBody({this.year, required this.state});
  final String? year;
  final ArchiveState state;

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1040;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 32 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: () {
            if (state is ArchiveLoading || state is ArchiveInitial) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    MyAppShimmer.rectangular(height: 36, width: 200),
                    SizedBox(height: 20),
                    MyAppShimmer.rectangular(height: 60),
                    SizedBox(height: 24),
                    MyAppShimmer.rectangular(height: 240),
                  ],
                ),
              );
            }
            if (state is ArchiveFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: colors.getAccentColor(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (state as ArchiveFailure).message,
                        style: styles.bodyText(context),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.heritageMaroon,
                        ),
                        onPressed: () => context.read<ArchiveCubit>().load(),
                        child: Text(
                          context.tr('retry_btn'),
                          style: styles.cleanSans(
                            context,
                            color: colors.white,
                            size: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final rawYears = (state as ArchiveLoaded).years;
            final seenYears = <int>{};
            final years = rawYears.where((y) => seenYears.add(y.year)).toList();
            final selectedYear = int.tryParse(year ?? '') ?? (years.isNotEmpty ? years.first.year : 2026);

            final allAlbums = AdminDataStore.instance.albums;
            final isGu = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';
            final yearAlbums = allAlbums.where((a) => a.year == selectedYear.toString()).toList();
            final albums = yearAlbums.isNotEmpty
                ? yearAlbums.map((a) => (
                    isGu ? context.trDynamic(a.name) : a.name,
                    a.id,
                    Icons.photo_library_rounded,
                    a.description.isNotEmpty
                        ? (isGu ? context.trDynamic(a.description) : a.description)
                        : (isGu ? '${a.photoCount} તસવીરો' : '${a.photoCount} Photos'),
                    a.coverImageUrl,
                    a.dayTag,
                    a.photoCount,
                  )).toList()
                : [
                    (
                      context.tr('album_main_garbi'),
                      'main-garbi',
                      Icons.temple_hindu_rounded,
                      'Full Night Garbi, Chhand, Stuti & Stage Photos',
                      '',
                      'Day 1',
                      0,
                    ),
                    (
                      context.tr('album_ras'),
                      'raas-dandiya',
                      Icons.music_note_rounded,
                      '2-Taali, 3-Taali & Traditional Saurashtra Hinch',
                      '',
                      'Day 3',
                      0,
                    ),
                    (
                      context.tr('album_special'),
                      'maha-aarti',
                      Icons.local_fire_department_rounded,
                      'Grand Aarti, Deepotsav & Sacred Offerings',
                      '',
                      'Day 9',
                      0,
                    ),
                  ];

            final s = AdminDataStore.instance;
            final langCode = isGu ? 'gu' : 'en';

            final archiveTag = s.getTextOverride(langCode, 'archive_tag') ?? context.tr('archive_tag');
            final archiveTitle = s.getTextOverride(langCode, 'archive_title') ?? context.tr('archive_title');
            final archiveDesc = s.getTextOverride(langCode, 'archive_desc') ?? context.tr('archive_desc');
            final albumsTag = s.getTextOverride(langCode, 'albums_tag') ?? context.tr('albums_tag');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                HeritageBadge(label: archiveTag),
                const SizedBox(height: 16),
                Text(archiveTitle, style: styles.h1(context)),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Text(
                    archiveDesc,
                    style: styles.bodyText(
                      context,
                      size: isMobile ? 14 : 16,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Year selector pills (Responsive Grid)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount = width < 480 ? 3 : (width < 768 ? 4 : (width < 1024 ? 5 : 7));
                    final spacing = width < 480 ? 10.0 : 12.0;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        childAspectRatio: width < 480 ? 2.2 : 2.5,
                      ),
                      itemCount: years.length,
                      itemBuilder: (context, index) {
                        final item = years[index];
                        final isSelected = item.year == selectedYear;
                        return InkWell(
                          onTap: () =>
                              serviceLocator<NavigationManager>().goToArchiveYear(
                                context,
                                year: item.year.toString(),
                              ),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.heritageMaroon
                                  : colors.getCardBackgroundColor(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? colors.heritageGold
                                    : colors.getBorderColor(context),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: colors.getAccentColor(context).withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                              ],
                            ),
                            child: Text(
                              '${item.year}',
                              style: styles.editorialSerif(
                                context,
                                size: width < 480 ? 16 : 19,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? colors.white
                                    : colors.getPrimaryTextColor(context),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const HeritageDivider(verticalPadding: 32),

                // Selected Year Info
                Row(
                  children: [
                    Text(
                      '$selectedYear',
                      style: styles.editorialSerif(
                        context,
                        size: 26,
                        fontWeight: FontWeight.w700,
                        color: colors.getAccentColor(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ $albumsTag',
                      style: styles.eyebrow(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Album Cards Grid
                albums.isEmpty
                    ? CulturalFrameCard(
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.collections_bookmark_outlined,
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
                                context.tr('archive_empty_desc'),
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
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: albums.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: isMobile ? 1.55 : 1.35,
                        ),
                        itemBuilder: (context, index) {
                          final album = albums[index];
                          return _AlbumCard(
                            year: selectedYear,
                            index: index,
                            title: album.$1,
                            slug: album.$2,
                            icon: album.$3,
                            subtitle: album.$4,
                            coverImageUrl: album.$5,
                            dayTag: album.$6,
                            photoCount: album.$7,
                          );
                        },
                      ),
              ],
            );
          }(),
        ),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({
    required this.year,
    required this.index,
    required this.title,
    required this.slug,
    required this.icon,
    required this.subtitle,
    this.coverImageUrl = '',
    this.dayTag = '',
    this.photoCount = 0,
  });

  final int year;
  final int index;
  final String title;
  final String slug;
  final IconData icon;
  final String subtitle;
  final String coverImageUrl;
  final String dayTag;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final hasCoverImage = coverImageUrl.isNotEmpty &&
        coverImageUrl != 'assets/images/pavan_putra_logo.jpg';

    return CulturalFrameCard(
      onTap: () => serviceLocator<NavigationManager>().goToGalleryAlbum(
        context,
        year: year.toString(),
        album: slug,
      ),
      padding: EdgeInsets.zero,
      backgroundColor: index == 0 ? colors.deepMaroon : colors.heritageMaroon,
      borderColor: colors.heritageGold.withValues(alpha: 0.4),
      hasGlow: index == 0,
      child: Stack(
        children: [
          if (hasCoverImage)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.35),
                        colors.deepMaroon.withValues(alpha: 0.92),
                      ],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.srcOver,
                  child: coverImageUrl.startsWith('assets/')
                      ? Image.asset(coverImageUrl, fit: BoxFit.cover)
                      : CachedNetworkImage(
                          imageUrl: coverImageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => const SizedBox(),
                        ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: colors.heritageGold.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                      ),
                      child: Icon(icon, color: colors.lightGold, size: 22),
                    ),
                    HeritageBadge(
                      label: dayTag.isNotEmpty ? dayTag : '$year',
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      textColor: colors.lightGold,
                      borderColor: colors.heritageGold.withValues(alpha: 0.35),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  style: styles.editorialSerif(
                    context,
                    size: 20,
                    fontWeight: FontWeight.w700,
                    color: colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styles.cleanSans(
                    context,
                    size: 12.5,
                    color: const Color(0xFFE2DDD1),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('view_album_btn'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.cleanSans(
                          context,
                          color: colors.lightGold,
                          size: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: colors.lightGold,
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
