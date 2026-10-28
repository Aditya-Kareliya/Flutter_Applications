import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Full CRUD management view for Garbi Years (Archive Module)
class AdminArchivePageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminArchivePageView({super.key, required this.store});

  @override
  State<AdminArchivePageView> createState() => _AdminArchivePageViewState();
}

class _AdminArchivePageViewState extends State<AdminArchivePageView> {
  void _openYearDialog([AdminGarbiYear? year]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final yearCtrl = TextEditingController(text: year?.year.toString() ?? '2025');
    final titleEnCtrl = TextEditingController(text: year?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: year?.titleGu ?? '');
    final descCtrl = TextEditingController(text: year?.description ?? '');
    final countCtrl = TextEditingController(text: year?.albumCount.toString() ?? '1');
    bool isPublished = year?.isPublished ?? true;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Text(
            year == null ? 'Add Garbi Festival Year' : 'Edit Year Archive',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 500 ? double.infinity : 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyAppTextFormField(
                    controller: yearCtrl,
                    labelText: 'Festival Year (e.g. 2025)',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    labelText: 'Archive Title (English)',
                    showTranslateIcon: true,
                    targetLanguageController: titleGuCtrl,
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Archive Title (Gujarati)',
                    prefixIcon: const Icon(Icons.subtitles_outlined),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descCtrl,
                    labelText: 'Cultural Description & Notes',
                    hintText: 'Detailed notes on this festival year',
                    minLines: 2,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: countCtrl,
                    labelText: 'Number of Albums / Documents',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.photo_library_outlined),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Published on Website', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('When disabled, this year is hidden from the public archive.'),
                    value: isPublished,
                    activeThumbColor: colors.heritageGold,
                    activeTrackColor: colors.heritageMaroon,
                    onChanged: (val) => setDlgState(() => isPublished = val),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              onPressed: () {
                final yearNum = int.tryParse(yearCtrl.text.trim());
                if (yearNum == null) {
                  MyAppToastMessage.warning(context, title: 'Invalid Year', description: 'Please enter a valid numeric year.');
                  return;
                }

                final titleEn = titleEnCtrl.text.trim().isEmpty ? 'Navratri Mahotsav $yearNum' : titleEnCtrl.text.trim();
                final count = int.tryParse(countCtrl.text.trim()) ?? 0;

                if (year == null) {
                  widget.store.addYear(AdminGarbiYear(
                    id: 'y-$yearNum',
                    year: yearNum,
                    titleEn: titleEn,
                    titleGu: titleGuCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    isPublished: isPublished,
                    albumCount: count,
                  ));
                  MyAppToastMessage.success(context, title: 'Year Added', description: 'Year $yearNum added to archive.');
                } else {
                  widget.store.updateYear(year.copyWith(
                    year: yearNum,
                    titleEn: titleEn,
                    titleGu: titleGuCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    isPublished: isPublished,
                    albumCount: count,
                  ));
                  MyAppToastMessage.success(context, title: 'Year Updated', description: 'Year $yearNum details saved.');
                }
                Navigator.pop(ctx);
              },
              label: year == null ? 'Add Year' : 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AdminGarbiYear year) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Festival Year?'),
        content: Text('Are you sure you want to delete year ${year.year} from the archive?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteYear(year.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(context, title: 'Year Deleted', description: 'Year ${year.year} removed from archive.');
            },
            label: 'Delete',
          ),
        ],
      ),
    );
  }

  void _showYearDetailDialog(AdminGarbiYear year) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    final linkedAlbums = widget.store.albums.where((a) => a.year == year.year.toString()).toList();
    final linkedVideos = widget.store.videos.where((v) => v.year == year.year.toString()).toList();

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final isPub = year.isPublished;
          return AlertDialog(
            backgroundColor: colors.getCardBackgroundColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
            ),
            contentPadding: EdgeInsets.zero,
            content: SizedBox(
              width: isMobile ? double.infinity : 680,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DIALOG HEADER
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: colors.deepMaroon,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.heritageMaroon,
                              border: Border.all(color: colors.heritageGold, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '${year.year}',
                                style: styles.editorialSerif(
                                  context,
                                  size: 16,
                                  fontWeight: FontWeight.w800,
                                  color: colors.heritageGold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        year.titleEn.isNotEmpty ? year.titleEn : 'Navratri Mahotsav ${year.year}',
                                        style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.bold, color: colors.white),
                                      ),
                                    ),
                                    HeritageBadge(label: isPub ? 'PUBLISHED' : 'DRAFT'),
                                  ],
                                ),
                                if (year.titleGu.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    year.titleGu,
                                    style: styles.devotionalMotto(context, size: 13, color: colors.lightGold),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                    ),

                    // BODY CONTENT
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SUMMARY STATS CHIPS
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _buildInfoChip(
                                context,
                                icon: Icons.photo_library_outlined,
                                label: 'Linked Albums',
                                value: '${linkedAlbums.isNotEmpty ? linkedAlbums.length : year.albumCount}',
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
                                label: 'Visibility',
                                value: isPub ? 'Public on Website' : 'Hidden / Draft',
                              ),
                              _buildInfoChip(
                                context,
                                icon: Icons.fingerprint_rounded,
                                label: 'Record ID',
                                value: year.id,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // DESCRIPTION
                          Text(
                            'Historical Overview & Notes',
                            style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.bold, color: colors.heritageGold),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.getSurfaceColor(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
                            ),
                            child: Text(
                              year.description.isNotEmpty
                                  ? year.description
                                  : 'No historical description or notes recorded for festival year ${year.year}. You can add descriptions via Edit Year.',
                              style: styles.cleanSans(context, size: 13, color: colors.getPrimaryTextColor(context)),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // LINKED ALBUMS SECTION
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Associated Albums (${linkedAlbums.length})',
                                style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.bold),
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
                                border: Border.all(color: colors.getBorderColor(context)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: colors.heritageGold),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No photo albums specifically linked to ${year.year} yet. Create albums in the Gallery & Media module with festival year "${year.year}".',
                                      style: styles.cleanSans(context, size: 12),
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
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final album = linkedAlbums[idx];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.getSurfaceColor(context),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: album.coverImageUrl.startsWith('http')
                                              ? CachedNetworkImage(
                                                  imageUrl: album.coverImageUrl,
                                                  fit: BoxFit.cover,
                                                  errorWidget: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                                                )
                                              : Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(album.name, style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.bold)),
                                            Text(
                                              '${album.dayTag.isNotEmpty ? "${album.dayTag} • " : ""}${album.photoCount} Photos',
                                              style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 18),

                          // LINKED VIDEOS SECTION
                          Text(
                            'Associated Videos (${linkedVideos.length})',
                            style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (linkedVideos.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.getSurfaceColor(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.getBorderColor(context)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.video_library_outlined, size: 18, color: colors.heritageGold),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'No videos linked to year ${year.year}. Link videos by entering "${year.year}" in the Video year field.',
                                      style: styles.cleanSans(context, size: 12),
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
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final vid = linkedVideos[idx];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: colors.getSurfaceColor(context),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.play_circle_outline_rounded, color: colors.heritageGold, size: 28),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(vid.title, style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.bold)),
                                            Text(
                                              '${vid.tag.isNotEmpty ? "${vid.tag} • " : ""}${vid.duration}',
                                              style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context)),
                                            ),
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
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              MyAppTextButton.icon(
                icon: Icon(isPub ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16),
                label: isPub ? 'Hide from Archive' : 'Publish to Archive',
                onPressed: () {
                  final updated = year.copyWith(isPublished: !isPub);
                  widget.store.updateYear(updated);
                  setDlgState(() {});
                  setState(() {});
                  MyAppToastMessage.info(
                    context,
                    title: 'Status Updated',
                    description: '${year.year} is now ${!isPub ? "published" : "hidden"}.',
                  );
                },
              ),
              MyAppTextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: 'Edit Year',
                color: colors.heritageGold,
                onPressed: () {
                  Navigator.pop(ctx);
                  _openYearDialog(year);
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

  Widget _buildInfoChip(BuildContext context, {required IconData icon, required String label, required String value}) {
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
          Text('$label: ', style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context))),
          Text(value, style: styles.cleanSans(context, size: 11.5, fontWeight: FontWeight.bold, color: colors.heritageGold)),
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
          websitePageTitle: 'Festival Archive Page',
          websiteRoute: '/archive',
          explanation: 'Controls past Navratri editions, annual themes, dates, attendance figures, and descriptions shown on the Archive page.',
        ),
        // Title & Actions Bar
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeritageBadge(label: 'WEBSITE CONTENT / FESTIVAL ARCHIVES'),
                const SizedBox(height: 6),
                Text(
                  'Garbi Festival Years Archive',
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Manage festival years, publish or hide annual records, and track album links across 45+ years.',
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
            MyAppFillButton.icon(
              onPressed: () => _openYearDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: 'Add Year Archive',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // YEARS LIST CARDS
        widget.store.years.isEmpty
            ? const CulturalFrameCard(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No festival years archived. Click "Add Year Archive" above.')),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.store.years.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final year = widget.store.years[index];
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
                                      border: Border.all(color: colors.heritageGold, width: 1.5),
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
                                          style: styles.editorialSerif(context, size: 15.5, fontWeight: FontWeight.w700),
                                        ),
                                        if (year.titleGu.isNotEmpty)
                                          Text(
                                            year.titleGu,
                                            style: styles.devotionalMotto(context, size: 12.5, color: colors.heritageGold),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.info_outline_rounded, size: 18, color: Colors.white54),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${year.albumCount} Albums • ${year.description.isNotEmpty ? year.description : "No description"}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                              ),
                              const SizedBox(height: 8),
                              Divider(height: 1, color: colors.getBorderColor(context)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  HeritageBadge(label: year.isPublished ? 'PUBLISHED' : 'DRAFT'),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Tooltip(
                                        message: 'View Year Details',
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
                                            widget.store.updateYear(year.copyWith(isPublished: val));
                                            MyAppToastMessage.info(
                                              context,
                                              title: 'Status Updated',
                                              description: '${year.year} is now ${val ? "published" : "hidden"}.',
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
                                        icon: const Icon(Icons.delete_outline_rounded, size: 19),
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
                                border: Border.all(color: colors.heritageGold, width: 1.5),
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
                                        style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                                      ),
                                      HeritageBadge(label: year.isPublished ? 'PUBLISHED' : 'DRAFT'),
                                    ],
                                  ),
                                  if (year.titleGu.isNotEmpty)
                                    Text(
                                      year.titleGu,
                                      style: styles.devotionalMotto(context, size: 13, color: colors.heritageGold),
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${year.albumCount} Albums • ${year.description.isNotEmpty ? year.description : "No description"}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
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
                                      widget.store.updateYear(year.copyWith(isPublished: val));
                                      MyAppToastMessage.info(
                                        context,
                                        title: 'Status Updated',
                                        description: '${year.year} is now ${val ? "published" : "hidden"}.',
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
                                  icon: const Icon(Icons.delete_outline_rounded, size: 19),
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
              ),
      ],
    );
  }
}
