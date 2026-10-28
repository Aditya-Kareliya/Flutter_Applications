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

/// Full CRUD management view for Gallery: Year -> Album -> Photo hierarchy
class AdminGalleryPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminGalleryPageView({super.key, required this.store});

  @override
  State<AdminGalleryPageView> createState() => _AdminGalleryPageViewState();
}

class _AdminGalleryPageViewState extends State<AdminGalleryPageView> {
  String? _selectedYear;
  String? _selectedAlbumId;

  void _openAlbumDialog([AdminAlbum? album]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final nameCtrl = TextEditingController(text: album?.name ?? '');
    final yearCtrl = TextEditingController(text: album?.year ?? (_selectedYear ?? '2025'));
    final dayCtrl = TextEditingController(text: album?.dayTag ?? 'Day 1');
    final descCtrl = TextEditingController(text: album?.description ?? '');
    String coverUrl = album?.coverImageUrl ?? 'assets/images/pavan_putra_logo.jpg';

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: Text(
            album == null ? 'Create Photo Album' : 'Edit Album Details',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  ),
                  const SizedBox(height: 12),
                  if (MediaQuery.sizeOf(context).width < 450) ...[
                    MyAppTextFormField(
                      controller: yearCtrl,
                      labelText: 'Year (e.g. 2025)',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: dayCtrl,
                      labelText: 'Day Tag (e.g. Day 1)',
                      prefixIcon: const Icon(Icons.tag_rounded),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: MyAppTextFormField(
                            controller: yearCtrl,
                            labelText: 'Year (e.g. 2025)',
                            prefixIcon: const Icon(Icons.calendar_today_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyAppTextFormField(
                            controller: dayCtrl,
                            labelText: 'Day Tag (e.g. Day 1)',
                            prefixIcon: const Icon(Icons.tag_rounded),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descCtrl,
                    labelText: 'Description',
                    hintText: 'Optional album description',
                    minLines: 2,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Name Required', description: 'Please enter album title.');
                  return;
                }

                if (album == null) {
                  widget.store.addAlbum(AdminAlbum(
                    id: 'alb-${DateTime.now().millisecondsSinceEpoch}',
                    name: name,
                    year: yearCtrl.text.trim().isEmpty ? '2025' : yearCtrl.text.trim(),
                    dayTag: dayCtrl.text.trim().isEmpty ? 'Day 1' : dayCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    coverImageUrl: coverUrl,
                  ));
                  MyAppToastMessage.success(context, title: 'Album Created', description: 'Album "$name" created.');
                } else {
                  widget.store.updateAlbum(album.copyWith(
                    name: name,
                    year: yearCtrl.text.trim(),
                    dayTag: dayCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    coverImageUrl: coverUrl,
                  ));
                  MyAppToastMessage.success(context, title: 'Album Updated', description: 'Album "$name" saved.');
                }
                Navigator.pop(ctx);
              },
              label: album == null ? 'Create Album' : 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAlbum(AdminAlbum album) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Album?'),
        content: Text('Delete "${album.name}"? Photos linked to this album will remain.'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteAlbum(album.id);
              if (_selectedAlbumId == album.id) {
                setState(() => _selectedAlbumId = null);
              }
              Navigator.pop(ctx);
              MyAppToastMessage.warning(context, title: 'Album Deleted', description: 'Album "${album.name}" deleted.');
            },
            label: 'Delete',
          ),
        ],
      ),
    );
  }

  void _openPhotoDialog([AdminPhoto? photo]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final titleEnCtrl = TextEditingController(text: photo?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: photo?.titleGu ?? '');
    final yearCtrl = TextEditingController(text: photo?.year ?? (_selectedYear ?? '2025'));
    final dayCtrl = TextEditingController(text: photo?.day ?? 'Day 1');
    final captionCtrl = TextEditingController(text: photo?.caption ?? '');
    String selectedAlbumId = photo?.albumId ?? _selectedAlbumId ?? (widget.store.albums.isNotEmpty ? widget.store.albums.first.id : '');
    String imgUrl = photo?.imageUrl ?? 'assets/images/pavan_putra_logo.jpg';

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: Text(
            photo == null ? 'Upload Gallery Photo' : 'Edit Photo Details',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyAppImagePicker(
                    label: 'Photograph File / Image Link',
                    initialImageUrl: imgUrl,
                    height: 150,
                    onImageChanged: (url) => setDlgState(() => imgUrl = url),
                  ),
                  const SizedBox(height: 14),
                  if (widget.store.albums.isNotEmpty)
                    MyAppDropdown<String>(
                      labelText: 'Belongs to Album (Event)',
                      value: widget.store.albums.any((a) => a.id == selectedAlbumId)
                          ? selectedAlbumId
                          : widget.store.albums.first.id,
                      items: widget.store.albums
                          .map((a) => MyAppDropdownItem<String>(
                                value: a.id,
                                label: '${a.name} (${a.year})',
                              ))
                          .toList(),
                      onChanged: (val) => setDlgState(() => selectedAlbumId = val),
                    ),
                  const SizedBox(height: 12),
                  if (MediaQuery.sizeOf(context).width < 450) ...[
                    MyAppTextFormField(
                      controller: yearCtrl,
                      labelText: 'Festival Year',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: dayCtrl,
                      labelText: 'Occasion / Day',
                      prefixIcon: const Icon(Icons.event_note_rounded),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: MyAppTextFormField(
                            controller: yearCtrl,
                            labelText: 'Festival Year',
                            prefixIcon: const Icon(Icons.calendar_today_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyAppTextFormField(
                            controller: dayCtrl,
                            labelText: 'Occasion / Day',
                            prefixIcon: const Icon(Icons.event_note_rounded),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    labelText: 'Photo Title / Caption (English)',
                    showTranslateIcon: true,
                    targetLanguageController: titleGuCtrl,
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Photo Title / Caption (Gujarati)',
                    prefixIcon: const Icon(Icons.subtitles_outlined),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: captionCtrl,
                    labelText: 'Short Cultural Description',
                    hintText: 'Brief context or cultural significance',
                    minLines: 2,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              onPressed: () {
                final titleEn = titleEnCtrl.text.trim();
                if (titleEn.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Title Required', description: 'Please enter photo title.');
                  return;
                }

                if (photo == null) {
                  widget.store.addPhoto(AdminPhoto(
                    id: 'p-${DateTime.now().millisecondsSinceEpoch}',
                    year: yearCtrl.text.trim().isEmpty ? '2025' : yearCtrl.text.trim(),
                    albumId: selectedAlbumId,
                    day: dayCtrl.text.trim().isEmpty ? 'Day 1' : dayCtrl.text.trim(),
                    titleEn: titleEn,
                    titleGu: titleGuCtrl.text.trim(),
                    imageUrl: imgUrl,
                    caption: captionCtrl.text.trim(),
                  ));
                  MyAppToastMessage.success(context, title: 'Photo Added', description: 'Photo "$titleEn" added to gallery.');
                } else {
                  widget.store.updatePhoto(photo.copyWith(
                    year: yearCtrl.text.trim(),
                    albumId: selectedAlbumId,
                    day: dayCtrl.text.trim(),
                    titleEn: titleEn,
                    titleGu: titleGuCtrl.text.trim(),
                    imageUrl: imgUrl,
                    caption: captionCtrl.text.trim(),
                  ));
                  MyAppToastMessage.success(context, title: 'Photo Updated', description: 'Photo "$titleEn" saved.');
                }
                Navigator.pop(ctx);
              },
              label: photo == null ? 'Upload Photo' : 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePhoto(AdminPhoto photo) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: Text('Are you sure you want to delete "${photo.titleEn}"?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deletePhoto(photo.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(context, title: 'Photo Deleted', description: 'Photo "${photo.titleEn}" deleted.');
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminWebsiteContextBanner(
          websitePageTitle: 'Photo Gallery',
          websiteRoute: '/gallery',
          explanation: 'Controls albums and photographs shown on the public Gallery page. Photos can be uploaded or linked via direct link.',
        ),
        
        // -------------------------------------------------------------
        // TITLE & BREADCRUMBS HEADER
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
                const HeritageBadge(label: 'WEBSITE CONTENT / GALLERY & ALBUMS'),
                const SizedBox(height: 6),
                Text(
                  'Gallery Hierarchy Explorer',
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Navigate Year > Event/Album > Upload Photos.',
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                if (_selectedYear != null && _selectedAlbumId == null)
                  MyAppOutlineButton.icon(
                    onPressed: () => _openAlbumDialog(),
                    icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                    label: 'Create Album for $_selectedYear',
                  ),
                if (_selectedAlbumId != null)
                  MyAppFillButton.icon(
                    onPressed: () => _openPhotoDialog(),
                    icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: 'Upload Photo Here',
                  ),
                if (_selectedYear == null)
                  MyAppOutlineButton.icon(
                    onPressed: () => _openAlbumDialog(),
                    icon: const Icon(Icons.create_new_folder_outlined, size: 18),
                    label: 'Create New Album',
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Interactive Breadcrumbs Bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colors.getCardBackgroundColor(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.getBorderColor(context)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: Row(
              children: [
                _buildCrumb('All Years', isActive: _selectedYear == null, onTap: () {
                  setState(() {
                    _selectedYear = null;
                    _selectedAlbumId = null;
                  });
                }, colors: colors, styles: styles),
                if (_selectedYear != null) ...[
                  _buildCrumbSeparator(colors),
                  _buildCrumb(_selectedYear!, isActive: _selectedAlbumId == null, onTap: () {
                    setState(() => _selectedAlbumId = null);
                  }, colors: colors, styles: styles),
                ],
                if (_selectedAlbumId != null) ...[
                  _buildCrumbSeparator(colors),
                  _buildCrumb(widget.store.albums.firstWhere((a) => a.id == _selectedAlbumId, orElse: () => AdminAlbum(id: '', name: 'Unknown', year: '', dayTag: '', description: '', coverImageUrl: '')).name, isActive: true, onTap: () {}, colors: colors, styles: styles),
                ]
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // -------------------------------------------------------------
        // HIERARCHY CONTENT
        // -------------------------------------------------------------
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
    } else if (_selectedAlbumId == null) {
      return _buildAlbumsGrid(context, colors, styles);
    } else {
      return _buildPhotosGrid(context, colors, styles);
    }
  }

  // LEVEL 1: YEARS
  Widget _buildYearsGrid(BuildContext context, MyAppColors colors, MyAppTextStyles styles) {
    final uniqueYears = widget.store.albums.map((a) => a.year).toSet().toList()..sort((a, b) => b.compareTo(a));

    if (uniqueYears.isEmpty) {
      return const CulturalFrameCard(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No galleries yet. Create an album to get started.')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: uniqueYears.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final year = uniqueYears[index];
        final albumCount = widget.store.albums.where((a) => a.year == year).length;
        final photoCount = widget.store.photos.where((p) => p.year == year).length;

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
                Icon(Icons.folder_open_rounded, size: 40, color: colors.heritageGold),
                const SizedBox(height: 12),
                Text(
                  year,
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$albumCount Events • $photoCount Photos',
                  style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // LEVEL 2: ALBUMS IN SELECTED YEAR
  Widget _buildAlbumsGrid(BuildContext context, MyAppColors colors, MyAppTextStyles styles) {
    final yearAlbums = widget.store.albums.where((a) => a.year == _selectedYear).toList();

    if (yearAlbums.isEmpty) {
      return const CulturalFrameCard(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No albums in this year. Create one above.')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: yearAlbums.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final album = yearAlbums[index];
        final photoCount = widget.store.photos.where((p) => p.albumId == album.id).length;

        return InkWell(
          onTap: () => setState(() => _selectedAlbumId = album.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: colors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.getBorderColor(context), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: album.coverImageUrl.startsWith('http')
                        ? Image.network(album.coverImageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.broken_image))
                        : Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          HeritageBadge(label: album.dayTag),
                          Row(
                            children: [
                              MyAppIconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                tooltip: 'Edit details',
                                color: colors.heritageGold,
                                onPressed: () => _openAlbumDialog(album),
                              ),
                              const SizedBox(width: 4),
                              MyAppIconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                tooltip: 'Delete',
                                color: Colors.redAccent,
                                onPressed: () => _confirmDeleteAlbum(album),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        album.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '$photoCount Photos',
                        style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
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
  }

  // LEVEL 3: PHOTOS IN SELECTED ALBUM
  Widget _buildPhotosGrid(BuildContext context, MyAppColors colors, MyAppTextStyles styles) {
    final albumPhotos = widget.store.photos.where((p) => p.albumId == _selectedAlbumId).toList();

    if (albumPhotos.isEmpty) {
      return const CulturalFrameCard(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No photos in this album yet. Click "Upload Photo Here".')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width > 1100 ? 4 : (width > 750 ? 3 : (width > 480 ? 2 : 1));

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: albumPhotos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final photo = albumPhotos[index];
            return Container(
              decoration: BoxDecoration(
                color: colors.getCardBackgroundColor(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                      child: photo.imageUrl.startsWith('http')
                          ? Image.network(
                              photo.imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                            )
                          : Image.asset(
                              'assets/images/pavan_putra_logo.jpg',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HeritageBadge(label: photo.day),
                            Row(
                              children: [
                                MyAppIconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 17),
                                  tooltip: 'Edit details',
                                  color: colors.heritageGold,
                                  onPressed: () => _openPhotoDialog(photo),
                                ),
                                const SizedBox(width: 4),
                                MyAppIconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 17),
                                  tooltip: 'Delete',
                                  color: Colors.redAccent,
                                  onPressed: () => _confirmDeletePhoto(photo),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          photo.titleEn,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700),
                        ),
                        if (photo.titleGu.isNotEmpty)
                          Text(
                            photo.titleGu,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: styles.devotionalMotto(context, size: 11.5, color: colors.heritageGold),
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
