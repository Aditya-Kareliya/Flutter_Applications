import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image/app_cached_image.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../data/admin_data_store.dart';

/// Comprehensive Admin view for Photo Gallery & Media Collections:
/// - Section 1: Page Header & Introduction (eyebrow tag, grand title, official media tag, narrative overview)
///   with real-time English/Gujarati live website preview.
/// - Section 2: Unified Photo Albums & Media Management:
///   * In Albums View: Search, filter by year, live preview carousel, create album, album cards with
///     instant "View Photos", "+ Add Photo", Edit, and Delete actions.
///   * In Album Photos View: Seamless drill-down with "← Back to All Albums", album summary header,
///     "+ Upload Photo to Album", photo search & occasion filters, and photos grid with Set as Cover,
///     Edit Photo, and Delete Photo.
/// - Full mobile responsiveness: No squished breadcrumbs, no separate disconnected sections,
///   and single-column dialog fields on mobile.
class AdminGalleryPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminGalleryPageView({super.key, required this.store});

  @override
  State<AdminGalleryPageView> createState() => _AdminGalleryPageViewState();
}

class _AdminGalleryPageViewState extends State<AdminGalleryPageView> {
  // ---------------------------------------------------------------------------
  // SECTION 1: PAGE HEADER & INTRODUCTION CONTROLLERS
  // ---------------------------------------------------------------------------
  late final TextEditingController _tagEnCtrl;
  late final TextEditingController _tagGuCtrl;
  late final TextEditingController _officialMediaEnCtrl;
  late final TextEditingController _officialMediaGuCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleGuCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descGuCtrl;

  // Real-time Preview Language for Section 1 & Section 2 ('en' or 'gu')
  String _headerPreviewLang = 'en';
  String _albumsPreviewLang = 'en';

  // ---------------------------------------------------------------------------
  // SECTION 2: ALBUMS SEARCH & FILTER
  // ---------------------------------------------------------------------------
  final TextEditingController _albumSearchCtrl = TextEditingController();
  String _albumSearchQuery = '';
  String _selectedYearFilter = 'ALL';

  // ---------------------------------------------------------------------------
  // ALBUM PHOTO VIEW / DRILL-DOWN STATE
  // ---------------------------------------------------------------------------
  String? _selectedAlbumId;
  final TextEditingController _photoSearchCtrl = TextEditingController();
  String _photoSearchQuery = '';
  String _selectedPhotoOccasionFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdated);
    widget.store.ensureGalleryLoaded();

    _tagEnCtrl = TextEditingController();
    _tagGuCtrl = TextEditingController();
    _officialMediaEnCtrl = TextEditingController();
    _officialMediaGuCtrl = TextEditingController();
    _titleEnCtrl = TextEditingController();
    _titleGuCtrl = TextEditingController();
    _descEnCtrl = TextEditingController();
    _descGuCtrl = TextEditingController();

    _reloadAllControllersFromStore();

    _albumSearchCtrl.addListener(() {
      if (mounted) {
        setState(
          () => _albumSearchQuery = _albumSearchCtrl.text.trim().toLowerCase(),
        );
      }
    });

    _photoSearchCtrl.addListener(() {
      if (mounted) {
        setState(
          () => _photoSearchQuery = _photoSearchCtrl.text.trim().toLowerCase(),
        );
      }
    });
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreUpdated);
    _tagEnCtrl.dispose();
    _tagGuCtrl.dispose();
    _officialMediaEnCtrl.dispose();
    _officialMediaGuCtrl.dispose();
    _titleEnCtrl.dispose();
    _titleGuCtrl.dispose();
    _descEnCtrl.dispose();
    _descGuCtrl.dispose();
    _albumSearchCtrl.dispose();
    _photoSearchCtrl.dispose();
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _reloadAllControllersFromStore() {
    final s = widget.store;
    _tagEnCtrl.text = s.getTextOverride('en', 'archive_tag') ?? '';
    _tagGuCtrl.text = s.getTextOverride('gu', 'archive_tag') ?? '';
    _officialMediaEnCtrl.text = s.getTextOverride('en', 'official_media') ?? '';
    _officialMediaGuCtrl.text = s.getTextOverride('gu', 'official_media') ?? '';
    _titleEnCtrl.text = s.getTextOverride('en', 'gallery_title') ?? '';
    _titleGuCtrl.text = s.getTextOverride('gu', 'gallery_title') ?? '';
    _descEnCtrl.text = s.getTextOverride('en', 'gallery_desc') ?? '';
    _descGuCtrl.text = s.getTextOverride('gu', 'gallery_desc') ?? '';
  }

  // ---------------------------------------------------------------------------
  // HEADER PERSISTENCE
  // ---------------------------------------------------------------------------
  void _saveGalleryHeader() {
    final s = widget.store;
    s.updateSiteContentField(
      'archive_tag',
      valueEn: _tagEnCtrl.text.trim(),
      valueGu: _tagGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'official_media',
      valueEn: _officialMediaEnCtrl.text.trim(),
      valueGu: _officialMediaGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'gallery_title',
      valueEn: _titleEnCtrl.text.trim(),
      valueGu: _titleGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'gallery_desc',
      valueEn: _descEnCtrl.text.trim(),
      valueGu: _descGuCtrl.text.trim(),
    );

    MyAppToastMessage.success(
      context,
      title: 'Header Saved',
      description: 'Photo Gallery page header configuration published.',
    );
  }

  void _saveAllSections() {
    _saveGalleryHeader();
    MyAppToastMessage.success(
      context,
      title: 'All Changes Saved',
      description:
          'Entire Gallery page content and headline settings published.',
    );
  }

  void _clearHeader() {
    setState(() {
      _tagEnCtrl.clear();
      _tagGuCtrl.clear();
      _officialMediaEnCtrl.clear();
      _officialMediaGuCtrl.clear();
      _titleEnCtrl.clear();
      _titleGuCtrl.clear();
      _descEnCtrl.clear();
      _descGuCtrl.clear();
    });
    MyAppToastMessage.info(
      context,
      title: 'Header Cleared',
      description:
          'Header text inputs have been cleared. Click "Save Header" to apply.',
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
          MyAppFillButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _reloadAllControllersFromStore();
              setState(() {});
              MyAppToastMessage.info(
                context,
                title: 'Fields Reloaded',
                description: 'Content reset to stored database values.',
              );
            },
            icon: const Icon(Icons.restore_rounded, size: 16),
            label: 'Revert',
          ),
        ],
      ),
    );
  }

  // Helper to resolve localized preview values
  String _resolvePreviewText({
    required String lang,
    required String en,
    required String gu,
  }) {
    if (lang == 'gu') return gu.isNotEmpty ? gu : en;
    return en.isNotEmpty ? en : gu;
  }

  // ---------------------------------------------------------------------------
  // ALBUM CRUD DIALOGS
  // ---------------------------------------------------------------------------
  void _openAlbumDialog([AdminAlbum? album]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final nameCtrl = TextEditingController(text: album?.name ?? '');
    final nameGuCtrl = TextEditingController(text: album?.nameGu ?? '');
    final yearCtrl = TextEditingController(text: album?.year ?? '2026');
    final dayCtrl = TextEditingController(text: album?.dayTag ?? 'Day 1');
    final dayGuCtrl = TextEditingController(text: album?.dayTagGu ?? '');
    final descCtrl = TextEditingController(text: album?.description ?? '');
    final descGuCtrl = TextEditingController(text: album?.descriptionGu ?? '');
    String coverUrl =
        album?.coverImageUrl ?? 'assets/images/pavan_putra_logo.jpg';

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
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
              Icon(Icons.photo_library_rounded, color: colors.heritageGold),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  album == null ? 'Create Photo Album' : 'Edit Album Details',
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
                  MyAppImagePicker(
                    label: 'Album Cover Image',
                    initialImageUrl: coverUrl,
                    height: 145,
                    onImageChanged: (url) => setDlgState(() => coverUrl = url),
                  ),
                  const SizedBox(height: 14),
                  MyAppTextFormField(
                    controller: nameCtrl,
                    labelText: 'Album Title (English, e.g. Maha Aarti Deepotsav)',
                    prefixIcon: const Icon(Icons.title_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: nameGuCtrl,
                    labelText: 'Album Title (Gujarati - optional, auto-translates)',
                    hintText: 'e.g. મહા આરતી દીપોત્સવ',
                    prefixIcon: const Icon(Icons.translate_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  if (isMobile) ...[
                    MyAppTextFormField(
                      controller: yearCtrl,
                      labelText: 'Festival Year',
                      hintText: 'e.g. 2026',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      showClearIcon: true,
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: dayCtrl,
                      labelText: 'Occasion / Day Tag (English)',
                      hintText: 'e.g. Day 1',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      showClearIcon: true,
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: dayGuCtrl,
                      labelText: 'Occasion / Day Tag (Gujarati)',
                      hintText: 'e.g. દિવસ ૧',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      showClearIcon: true,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: MyAppTextFormField(
                            controller: yearCtrl,
                            labelText: 'Festival Year',
                            hintText: 'e.g. 2026',
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                            ),
                            showClearIcon: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: MyAppTextFormField(
                            controller: dayCtrl,
                            labelText: 'Day Tag (EN)',
                            hintText: 'e.g. Day 1',
                            prefixIcon: const Icon(Icons.tag_rounded),
                            showClearIcon: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: MyAppTextFormField(
                            controller: dayGuCtrl,
                            labelText: 'Day Tag (GU)',
                            hintText: 'e.g. દિવસ ૧',
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
                    labelText: 'Album Description (English)',
                    hintText:
                        'Brief context about the celebrations in this album...',
                    minLines: 2,
                    maxLines: 3,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descGuCtrl,
                    labelText: 'Album Description (Gujarati - optional)',
                    hintText: 'આલ્બમ અથવા ઉજવણીનું વર્ણન...',
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
                  final newAlbumId =
                      'alb-${DateTime.now().millisecondsSinceEpoch}';
                  widget.store.addAlbum(
                    AdminAlbum(
                      id: newAlbumId,
                      name: name,
                      nameGu: nameGuCtrl.text.trim(),
                      year: yearCtrl.text.trim(),
                      dayTag: dayCtrl.text.trim(),
                      dayTagGu: dayGuCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      descriptionGu: descGuCtrl.text.trim(),
                      coverImageUrl: coverUrl,
                    ),
                  );
                  setState(() {});
                  MyAppToastMessage.success(
                    context,
                    title: 'Album Created',
                    description: 'Album "$name" has been added.',
                  );
                } else {
                  widget.store.updateAlbum(
                    album.copyWith(
                      name: name,
                      nameGu: nameGuCtrl.text.trim(),
                      year: yearCtrl.text.trim(),
                      dayTag: dayCtrl.text.trim(),
                      dayTagGu: dayGuCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      descriptionGu: descGuCtrl.text.trim(),
                      coverImageUrl: coverUrl,
                    ),
                  );
                  setState(() {});
                  MyAppToastMessage.success(
                    context,
                    title: 'Album Updated',
                    description: 'Album "$name" saved.',
                  );
                }
                Navigator.pop(ctx);
              },
              label: album == null ? 'Create Album' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAlbum(AdminAlbum album) {
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
          'Are you sure you want to delete album "${album.name}"? Photos linked to this album will remain in storage.',
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
              if (_selectedAlbumId == album.id) {
                setState(() => _selectedAlbumId = null);
              }
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Album Deleted',
                description: 'Album "${album.name}" deleted.',
              );
            },
            label: 'Delete Album',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PHOTO CRUD DIALOGS
  // ---------------------------------------------------------------------------
  void _openPhotoDialog({AdminPhoto? photo, AdminAlbum? defaultAlbum}) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final targetAlbum =
        defaultAlbum ??
        (photo != null
            ? widget.store.albums.firstWhere(
                (a) => a.id == photo.albumId,
                orElse: () => widget.store.albums.first,
              )
            : (_selectedAlbumId != null
                  ? widget.store.albums.firstWhere(
                      (a) => a.id == _selectedAlbumId,
                      orElse: () => widget.store.albums.first,
                    )
                  : (widget.store.albums.isNotEmpty
                        ? widget.store.albums.first
                        : null)));

    final titleEnCtrl = TextEditingController(text: photo?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: photo?.titleGu ?? '');
    final yearCtrl = TextEditingController(
      text: photo?.year ?? targetAlbum?.year ?? '2026',
    );
    final dayCtrl = TextEditingController(
      text: photo?.day ?? targetAlbum?.dayTag ?? 'Day 1',
    );
    final captionCtrl = TextEditingController(text: photo?.caption ?? '');
    String selectedAlbumId =
        photo?.albumId ??
        targetAlbum?.id ??
        (widget.store.albums.isNotEmpty ? widget.store.albums.first.id : '');
    String imgUrl = photo?.imageUrl ?? 'assets/images/pavan_putra_logo.jpg';

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
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
              Icon(Icons.add_a_photo_rounded, color: colors.heritageGold),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  photo == null ? 'Upload Gallery Photo' : 'Edit Photo Details',
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
                  MyAppImagePicker(
                    label: 'Photograph File / Direct Link',
                    initialImageUrl: imgUrl,
                    height: 155,
                    onImageChanged: (url) => setDlgState(() => imgUrl = url),
                  ),
                  const SizedBox(height: 14),
                  if (widget.store.albums.isNotEmpty) ...[
                    MyAppDropdown<String>(
                      labelText: 'Belongs to Album (Event)',
                      value:
                          widget.store.albums.any(
                            (a) => a.id == selectedAlbumId,
                          )
                          ? selectedAlbumId
                          : widget.store.albums.first.id,
                      items: widget.store.albums
                          .map(
                            (a) => MyAppDropdownItem<String>(
                              value: a.id,
                              label: '${a.name} (${a.year} • ${a.dayTag})',
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setDlgState(() {
                          selectedAlbumId = val;
                          final alb = widget.store.albums.firstWhere(
                            (a) => a.id == val,
                            orElse: () => widget.store.albums.first,
                          );
                          yearCtrl.text = alb.year;
                          dayCtrl.text = alb.dayTag;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
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
                      labelText: 'Occasion / Day',
                      prefixIcon: const Icon(Icons.event_note_rounded),
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
                            labelText: 'Occasion / Day',
                            prefixIcon: const Icon(Icons.event_note_rounded),
                            showClearIcon: true,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                  MyAppTextAreaField(
                    controller: captionCtrl,
                    labelText: 'Cultural Context / Notes',
                    hintText: 'Brief notes about this photograph...',
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
                final titleEn = titleEnCtrl.text.trim();
                if (titleEn.isEmpty) {
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
                      year: yearCtrl.text.trim().isEmpty
                          ? '2026'
                          : yearCtrl.text.trim(),
                      albumId: selectedAlbumId,
                      day: dayCtrl.text.trim().isEmpty
                          ? 'Day 1'
                          : dayCtrl.text.trim(),
                      titleEn: titleEn,
                      titleGu: titleGuCtrl.text.trim(),
                      imageUrl: imgUrl,
                      caption: captionCtrl.text.trim(),
                    ),
                  );
                  setState(() {});
                  MyAppToastMessage.success(
                    context,
                    title: 'Photo Added',
                    description: 'Photo "$titleEn" added to album.',
                  );
                } else {
                  widget.store.updatePhoto(
                    photo.copyWith(
                      year: yearCtrl.text.trim(),
                      albumId: selectedAlbumId,
                      day: dayCtrl.text.trim(),
                      titleEn: titleEn,
                      titleGu: titleGuCtrl.text.trim(),
                      imageUrl: imgUrl,
                      caption: captionCtrl.text.trim(),
                    ),
                  );
                  setState(() {});
                  MyAppToastMessage.success(
                    context,
                    title: 'Photo Updated',
                    description: 'Photo "$titleEn" saved.',
                  );
                }
                Navigator.pop(ctx);
              },
              label: photo == null ? 'Upload Photo' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePhoto(AdminPhoto photo) {
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
          'Are you sure you want to delete photo "${photo.titleEn}"? This action cannot be undone.',
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
              setState(() {});
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Photo Deleted',
                description: 'Photo "${photo.titleEn}" removed.',
              );
            },
            label: 'Delete Photo',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // FULL-SCREEN PHOTO PREVIEW LIGHTBOX (PARTICULAR IMAGE VIEW)
  // ---------------------------------------------------------------------------
  void _showPhotoViewer(AdminPhoto photo, AdminAlbum album) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final isCover = album.coverImageUrl == photo.imageUrl;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setViewerState) => AlertDialog(
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
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: isMobile ? double.infinity : 560,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Full Image Preview
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(17),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: isMobile ? 240 : 340,
                          child: AppCachedImage(
                            imageUrl: photo.imageUrl,
                            fit: BoxFit.cover,
                            memCacheWidth: 800,
                            memCacheHeight: 600,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                      ),
                      if (isCover)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.deepMaroon,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: colors.heritageGold,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: colors.heritageGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ALBUM COVER',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: colors.heritageGold,
                                  ),
                                ),
                              ],
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
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            HeritageBadge(
                              label: photo.day.isNotEmpty
                                  ? photo.day
                                  : album.dayTag,
                            ),
                            Text(
                              '${photo.year} • ${album.name}',
                              style: styles.cleanSans(
                                context,
                                size: 12,
                                color: colors.heritageGold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          photo.titleEn,
                          style: styles.editorialSerif(
                            context,
                            size: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (photo.titleGu.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            photo.titleGu,
                            style: styles.devotionalMotto(
                              context,
                              size: 14,
                              color: colors.heritageGold,
                            ),
                          ),
                        ],
                        if (photo.caption.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            photo.caption,
                            style: styles.cleanSans(
                              context,
                              size: 12.5,
                              color: colors.getSecondaryTextColor(context),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppOutlineButton.icon(
              icon: Icon(
                isCover ? Icons.star_rounded : Icons.star_border_rounded,
                size: 16,
              ),
              label: isCover ? 'Cover Image' : 'Set as Cover',
              onPressed: isCover
                  ? null
                  : () {
                      widget.store.updateAlbum(
                        album.copyWith(coverImageUrl: photo.imageUrl),
                      );
                      setState(() {});
                      setViewerState(() {});
                      MyAppToastMessage.success(
                        context,
                        title: 'Cover Updated',
                        description: 'Photo set as album cover.',
                      );
                    },
            ),
            MyAppIconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: 'Edit Photo',
              color: colors.heritageGold,
              onPressed: () {
                Navigator.pop(ctx);
                _openPhotoDialog(photo: photo, defaultAlbum: album);
              },
            ),
            MyAppIconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              tooltip: 'Delete Photo',
              color: Colors.redAccent,
              onPressed: () {
                Navigator.pop(ctx);
                _confirmDeletePhoto(photo);
              },
            ),
            MyAppFillButton(
              onPressed: () => Navigator.pop(ctx),
              label: 'Close',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Public Website Context Banner
          const AdminWebsiteContextBanner(
            websitePageTitle: 'Photo Gallery',
            websiteRoute: '/gallery',
            explanation:
                'Controls albums and photographs shown on the public Gallery page. Photos can be uploaded or linked via direct image links.',
          ),
          const SizedBox(height: 16),

          // Portal Top Actions Bar (Reset All & Save All Changes)
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const HeritageBadge(label: 'WEBSITE CONTENT / GALLERY & ALBUMS'),
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
                      'Controls the grand title, eyebrow badge, official media label, and historical overview paragraph on the public Photo Gallery page.',
                  actions: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _clearHeader,
                      icon: const Icon(Icons.clear_all_rounded, size: 16),
                      label: 'Clear Section',
                    ),
                    MyAppFillButton.icon(
                      onPressed: _saveGalleryHeader,
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
                  hintText: 'e.g. Photo Archive',
                ),
                _buildDualLanguageField(
                  title: '1.2 Official Media Badge Label (સત્તાવાર મીડિયા)',
                  enLabel: 'Media Badge (English)',
                  enCtrl: _officialMediaEnCtrl,
                  guLabel: 'Media Badge (Gujarati)',
                  guCtrl: _officialMediaGuCtrl,
                  hintText: 'e.g. OFFICIAL MANDAL MEDIA',
                ),
                _buildDualLanguageField(
                  title: '1.3 Gallery Page Grand Title (મુખ્ય શીર્ષક)',
                  enLabel: 'Gallery Title (English)',
                  enCtrl: _titleEnCtrl,
                  guLabel: 'Gallery Title (Gujarati)',
                  guCtrl: _titleGuCtrl,
                  hintText: 'e.g. Sacred Navratri Mahotsav Gallery',
                ),
                _buildDualLanguageField(
                  title: '1.4 Gallery Narrative Overview (પરિચય વિગત)',
                  enLabel: 'Overview (English)',
                  enCtrl: _descEnCtrl,
                  guLabel: 'Overview (Gujarati)',
                  guCtrl: _descGuCtrl,
                  maxLines: 3,
                  hintText:
                      'Capturing sacred moments and cultural devotion across Navratri...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 2: PHOTO ALBUMS & MEDIA MANAGEMENT
          // ===================================================================
          CulturalFrameCard(
            padding: EdgeInsets.all(isMobile ? 14 : 20),
            child: _selectedAlbumId == null
                ? _buildAlbumsOverview(context, isMobile)
                : _buildAlbumPhotosManager(context, isMobile),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 2A: ALBUMS OVERVIEW
  // ---------------------------------------------------------------------------
  Widget _buildAlbumsOverview(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeaderCard(
          context: context,
          icon: Icons.photo_library_outlined,
          title:
              '2. Photo Albums & Festival Events (${widget.store.albums.length})',
          subtitle:
              'Organize festival photograph collections by year and Navratri day/occasion. Click on any album to view and manage its photographs.',
          actions: [
            MyAppFillButton.icon(
              onPressed: () => _openAlbumDialog(),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: 'Create New Album',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Live Preview for Section 2
        _buildLiveAlbumsPreview(context),
        const SizedBox(height: 18),

        // Search Bar & Year Filter Tabs
        _buildSearchAndFilterBar(context),
        const SizedBox(height: 16),

        // Albums Grid
        _buildAlbumsList(context),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 2B: ALBUM PHOTOS MANAGER (FOCUSED DRILL-DOWN)
  // ---------------------------------------------------------------------------
  Widget _buildAlbumPhotosManager(BuildContext context, bool isMobile) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final album = widget.store.albums.firstWhere(
      (a) => a.id == _selectedAlbumId,
      orElse: () => AdminAlbum(
        id: '',
        name: 'Selected Album',
        year: '',
        dayTag: '',
        description: '',
      ),
    );

    final albumPhotos = widget.store.photos
        .where((p) => p.albumId == album.id)
        .toList();

    // Filter by search & occasion
    final filtered = albumPhotos.where((p) {
      if (_selectedPhotoOccasionFilter != 'ALL' &&
          p.day != _selectedPhotoOccasionFilter) {
        return false;
      }
      if (_photoSearchQuery.isNotEmpty) {
        final q = _photoSearchQuery;
        final matchTitleEn = p.titleEn.toLowerCase().contains(q);
        final matchTitleGu = p.titleGu.toLowerCase().contains(q);
        final matchDay = p.day.toLowerCase().contains(q);
        final matchCaption = p.caption.toLowerCase().contains(q);
        if (!matchTitleEn && !matchTitleGu && !matchDay && !matchCaption) {
          return false;
        }
      }
      return true;
    }).toList();

    // Occasion chips list
    final occasions = {
      'ALL',
      ...albumPhotos.map((p) => p.day).where((d) => d.isNotEmpty),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP NAVIGATION HEADER (Back Button + Album Title + Upload Button)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MyAppOutlineButton.icon(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: isMobile ? 'Albums' : 'All Albums',
              onPressed: () {
                setState(() {
                  _selectedAlbumId = null;
                  _photoSearchQuery = '';
                  _selectedPhotoOccasionFilter = 'ALL';
                });
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.editorialSerif(
                      context,
                      size: isMobile ? 16 : 19,
                      fontWeight: FontWeight.w700,
                      color: colors.getPrimaryTextColor(context),
                    ),
                  ),
                  Wrap(
                    spacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${album.year} • ${album.dayTag}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: colors.heritageGold,
                        ),
                      ),
                      Text(
                        '• ${albumPhotos.length} Photos',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.getSecondaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            MyAppFillButton.icon(
              onPressed: () => _openPhotoDialog(defaultAlbum: album),
              icon: const Icon(Icons.add_a_photo_rounded, size: 16),
              label: isMobile ? 'Upload' : 'Upload Photo',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ALBUM SUMMARY CARD
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.heritageGold.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: AppCachedImage(
                    imageUrl: album.coverImageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 150,
                    memCacheHeight: 150,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Album Cover & Information',
                      style: styles.cleanSans(
                        context,
                        size: 12.5,
                        fontWeight: FontWeight.bold,
                        color: colors.heritageGold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      album.description.isNotEmpty
                          ? album.description
                          : 'No cultural description entered. Click Edit to add details.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: styles.cleanSans(
                        context,
                        size: 11.5,
                        color: colors.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyAppIconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'Edit Album Details',
                    color: colors.heritageGold,
                    onPressed: () => _openAlbumDialog(album),
                  ),
                  const SizedBox(width: 4),
                  MyAppIconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    tooltip: 'Delete Album',
                    color: Colors.redAccent,
                    onPressed: () => _confirmDeleteAlbum(album),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SEARCH PHOTOS IN THIS ALBUM
        MyAppTextFormField(
          controller: _photoSearchCtrl,
          hintText: 'Search photographs by title or day tag...',
          prefixIcon: const Icon(Icons.search_rounded),
          showClearIcon: true,
        ),
        const SizedBox(height: 10),

        // OCCASION FILTER CHIPS
        if (occasions.length > 2) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: occasions.map((occ) {
                final isSelected = _selectedPhotoOccasionFilter == occ;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(occ == 'ALL' ? 'All Occasions' : occ),
                    selected: isSelected,
                    selectedColor: colors.deepMaroon,
                    backgroundColor: colors.getSurfaceColor(context),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
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
                    onSelected: (_) =>
                        setState(() => _selectedPhotoOccasionFilter = occ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // PHOTOS GRID
        if (filtered.isEmpty)
          Container(
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
                  Icons.photo_library_outlined,
                  size: 36,
                  color: colors.heritageGold.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 10),
                Text(
                  albumPhotos.isEmpty
                      ? 'No photographs in "${album.name}" yet.'
                      : 'No photos match your search filter.',
                  style: styles.editorialSerif(
                    context,
                    size: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  albumPhotos.isEmpty
                      ? 'Click "+ Upload Photo" above to add the first photograph to this album.'
                      : 'Try clearing your search query.',
                  style: styles.cleanSans(
                    context,
                    size: 12,
                    color: colors.getSecondaryTextColor(context),
                  ),
                ),
                if (albumPhotos.isEmpty) ...[
                  const SizedBox(height: 14),
                  MyAppFillButton.icon(
                    onPressed: () => _openPhotoDialog(defaultAlbum: album),
                    icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                    label: 'Upload First Photo',
                  ),
                ],
              ],
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width < 480
                  ? 2
                  : width < 780
                  ? 3
                  : 4;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: width < 480 ? 0.78 : 0.82,
                ),
                itemBuilder: (context, idx) {
                  final photo = filtered[idx];
                  final isCover = album.coverImageUrl == photo.imageUrl;

                  return Container(
                    decoration: BoxDecoration(
                      color: colors.getSurfaceColor(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCover
                            ? colors.heritageGold
                            : colors.getBorderColor(context),
                        width: isCover ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Photo Image with Cover Badge (Tap to View)
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(11),
                            ),
                            onTap: () => _showPhotoViewer(photo, album),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(11),
                                  ),
                                  child: AppCachedImage(
                                    imageUrl: photo.imageUrl,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 400,
                                    memCacheHeight: 400,
                                  ),
                                ),
                                if (isCover)
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.deepMaroon,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: colors.heritageGold,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 11,
                                            color: colors.heritageGold,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            'COVER',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: colors.heritageGold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.65,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      photo.day.isNotEmpty
                                          ? photo.day
                                          : album.dayTag,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Title & Actions
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                photo.titleEn,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.cleanSans(
                                  context,
                                  size: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (photo.titleGu.isNotEmpty)
                                Text(
                                  photo.titleGu,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.devotionalMotto(
                                    context,
                                    size: 11,
                                    color: colors.heritageGold,
                                  ),
                                ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Tooltip(
                                    message: isCover
                                        ? 'Current Cover Image'
                                        : 'Set as Album Cover Image',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(4),
                                      onTap: isCover
                                          ? null
                                          : () {
                                              widget.store.updateAlbum(
                                                album.copyWith(
                                                  coverImageUrl: photo.imageUrl,
                                                ),
                                              );
                                              setState(() {});
                                              MyAppToastMessage.success(
                                                context,
                                                title: 'Cover Updated',
                                                description:
                                                    'Cover image updated for "${album.name}".',
                                              );
                                            },
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          isCover
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          size: 18,
                                          color: isCover
                                              ? colors.heritageGold
                                              : colors.getSecondaryTextColor(
                                                  context,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MyAppIconButton(
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 16,
                                        ),
                                        tooltip: 'View Photo Details',
                                        color: colors.heritageGold,
                                        onPressed: () =>
                                            _showPhotoViewer(photo, album),
                                      ),
                                      MyAppIconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                        ),
                                        tooltip: 'Edit Photo',
                                        color: colors.heritageGold,
                                        onPressed: () => _openPhotoDialog(
                                          photo: photo,
                                          defaultAlbum: album,
                                        ),
                                      ),
                                      MyAppIconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
                                        ),
                                        tooltip: 'Delete Photo',
                                        color: Colors.redAccent,
                                        onPressed: () =>
                                            _confirmDeletePhoto(photo),
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
              );
            },
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION HEADER CARD (Standardized with Home & Archive)
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
  // LIVE WEBSITE PREVIEW (SECTION 1)
  // ---------------------------------------------------------------------------
  Widget _buildLiveHeaderPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final s = widget.store;
    final fallbackTag = _headerPreviewLang == 'gu'
        ? 'ફોટો સંગ્રહ'
        : 'Photo Archive';
    final fallbackMedia = _headerPreviewLang == 'gu'
        ? 'સત્તાવાર મંડળ મીડિયા'
        : 'OFFICIAL MANDAL MEDIA';
    final fallbackTitle = _headerPreviewLang == 'gu'
        ? 'પાવન પુત્ર ગરબી મહોત્સવ ગેલેરી'
        : 'Sacred Navratri Mahotsav Gallery';
    final fallbackDesc = _headerPreviewLang == 'gu'
        ? 'નવરાત્રિના પવિત્ર ક્ષણો અને સાંસ્કૃતિક ભક્તિની ઝાંખી.'
        : 'Capturing sacred moments, traditional garbi rituals, and cultural devotion across the grand Navratri Mahotsav.';

    final rawTag = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _tagEnCtrl.text,
      gu: _tagGuCtrl.text,
    );
    final displayTag = rawTag.isNotEmpty
        ? rawTag
        : (s.getTextOverride(_headerPreviewLang, 'archive_tag') ?? fallbackTag);

    final rawMedia = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _officialMediaEnCtrl.text,
      gu: _officialMediaGuCtrl.text,
    );
    final displayMedia = rawMedia.isNotEmpty
        ? rawMedia
        : (s.getTextOverride(_headerPreviewLang, 'official_media') ??
              fallbackMedia);

    final rawTitle = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _titleEnCtrl.text,
      gu: _titleGuCtrl.text,
    );
    final displayTitle = rawTitle.isNotEmpty
        ? rawTitle
        : (s.getTextOverride(_headerPreviewLang, 'gallery_title') ??
              fallbackTitle);

    final rawDesc = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _descEnCtrl.text,
      gu: _descGuCtrl.text,
    );
    final displayDesc = rawDesc.isNotEmpty
        ? rawDesc
        : (s.getTextOverride(_headerPreviewLang, 'gallery_desc') ??
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
                Wrap(
                  spacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    HeritageBadge(label: displayTag),
                    HeritageBadge(
                      label: displayMedia,
                      backgroundColor: colors.heritageGold.withValues(
                        alpha: 0.15,
                      ),
                      textColor: colors.heritageGold,
                    ),
                  ],
                ),
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
  // LIVE ALBUMS PREVIEW (SECTION 2)
  // ---------------------------------------------------------------------------
  Widget _buildLiveAlbumsPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final albums = widget.store.albums;

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
                    'Live Album Collections Preview (${albums.length} Active)',
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.heritageGold,
                    ),
                  ),
                ),
                _buildLanguageTogglePill(
                  activeLang: _albumsPreviewLang,
                  onChanged: (lang) =>
                      setState(() => _albumsPreviewLang = lang),
                  colors: colors,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: albums.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No photo albums found. Click "Create New Album" to add your first festival event.',
                        style: styles.cleanSans(
                          context,
                          size: 12,
                          color: colors.getSecondaryTextColor(context),
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 155,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: albums.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, idx) {
                        final album = albums[idx];
                        final photoCount = widget.store.photos
                            .where((p) => p.albumId == album.id)
                            .length;
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () =>
                              setState(() => _selectedAlbumId = album.id),
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                              color: colors.getSurfaceColor(context),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: colors.heritageGold.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(9),
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 85,
                                    child: AppCachedImage(
                                      imageUrl: album.coverImageUrl,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 400,
                                      memCacheHeight: 300,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${album.year} • ${album.dayTag}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: colors.heritageGold,
                                            ),
                                          ),
                                          Text(
                                            '$photoCount Photos',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              color: colors
                                                  .getSecondaryTextColor(
                                                    context,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        album.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: styles.editorialSerif(
                                          context,
                                          size: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
  // LANGUAGE TOGGLE PILL
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
  // DUAL-LANGUAGE FORM FIELD COMPONENT
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
  // SECTION 2: SEARCH & FILTER BAR FOR ALBUMS
  // ---------------------------------------------------------------------------
  Widget _buildSearchAndFilterBar(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();

    // Collect all unique years in descending order
    final availableYears =
        widget.store.albums.map((a) => a.year).toSet().toList()
          ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyAppTextFormField(
          controller: _albumSearchCtrl,
          hintText:
              'Search albums by event title, year, or cultural occasion...',
          prefixIcon: const Icon(Icons.search_rounded),
          showClearIcon: true,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: Text('All Years (${widget.store.albums.length})'),
                selected: _selectedYearFilter == 'ALL',
                selectedColor: colors.deepMaroon,
                backgroundColor: colors.getSurfaceColor(context),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: _selectedYearFilter == 'ALL'
                      ? FontWeight.w800
                      : FontWeight.w500,
                  color: _selectedYearFilter == 'ALL'
                      ? colors.heritageGold
                      : colors.getPrimaryTextColor(context),
                ),
                side: BorderSide(
                  color: _selectedYearFilter == 'ALL'
                      ? colors.heritageGold
                      : colors.getBorderColor(context),
                  width: 1,
                ),
                onSelected: (_) => setState(() => _selectedYearFilter = 'ALL'),
              ),
              for (final yr in availableYears) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(
                    '$yr (${widget.store.albums.where((a) => a.year == yr).length})',
                  ),
                  selected: _selectedYearFilter == yr,
                  selectedColor: colors.deepMaroon,
                  backgroundColor: colors.getSurfaceColor(context),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: _selectedYearFilter == yr
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: _selectedYearFilter == yr
                        ? colors.heritageGold
                        : colors.getPrimaryTextColor(context),
                  ),
                  side: BorderSide(
                    color: _selectedYearFilter == yr
                        ? colors.heritageGold
                        : colors.getBorderColor(context),
                    width: 1,
                  ),
                  onSelected: (_) => setState(() => _selectedYearFilter = yr),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 2: ALBUMS LIST / GRID
  // ---------------------------------------------------------------------------
  Widget _buildAlbumsList(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final allAlbums = widget.store.albums;
    final filtered = allAlbums.where((album) {
      if (_selectedYearFilter != 'ALL' && album.year != _selectedYearFilter) {
        return false;
      }
      if (_albumSearchQuery.isNotEmpty) {
        final q = _albumSearchQuery;
        final matchName = album.name.toLowerCase().contains(q);
        final matchYear = album.year.toLowerCase().contains(q);
        final matchDay = album.dayTag.toLowerCase().contains(q);
        final matchDesc = album.description.toLowerCase().contains(q);
        if (!matchName && !matchYear && !matchDay && !matchDesc) {
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
              Icons.photo_library_outlined,
              size: 36,
              color: colors.heritageGold,
            ),
            const SizedBox(height: 10),
            Text(
              'No albums match your filter criteria.',
              style: styles.editorialSerif(
                context,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try adjusting search terms or click "Create New Album" to add one.',
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isMobile = width < 600;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: isMobile ? 600 : 360,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: isMobile ? 1.05 : 0.86,
          ),
          itemBuilder: (context, idx) {
            final album = filtered[idx];
            return _buildAlbumAdminCard(album, colors, styles);
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ALBUM ADMIN CARD
  // ---------------------------------------------------------------------------
  Widget _buildAlbumAdminCard(
    AdminAlbum album,
    MyAppColors colors,
    MyAppTextStyles styles,
  ) {
    final photoCount = widget.store.photos
        .where((p) => p.albumId == album.id)
        .length;
    final isDark = colors.isDarkMode(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _selectedAlbumId = album.id;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? colors.heritageGold.withValues(alpha: 0.3)
                : colors.getBorderColor(context),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover Image with Badges
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(13),
                    ),
                    child: AppCachedImage(
                      imageUrl: album.coverImageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 600,
                      memCacheHeight: 400,
                    ),
                  ),
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
                        '${album.year} • ${album.dayTag}',
                        style: styles.cleanSans(
                          context,
                          size: 11,
                          fontWeight: FontWeight.w800,
                          color: colors.heritageGold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo_library_outlined,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$photoCount',
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
                ],
              ),
            ),

            // Content Details & Actions
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          album.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.editorialSerif(
                            context,
                            size: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (album.description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            album.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: styles.cleanSans(
                              context,
                              size: 11.5,
                              color: colors.getSecondaryTextColor(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Divider(height: 1, color: colors.getBorderColor(context)),
                    const SizedBox(height: 6),

                    // Action Buttons (View Photos, + Photo, Edit, Delete)
                    Row(
                      children: [
                        Expanded(
                          child: MyAppOutlineButton.icon(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              size: 14,
                            ),
                            label: 'Photos ($photoCount)',
                            onPressed: () {
                              setState(() {
                                _selectedAlbumId = album.id;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        MyAppOutlineButton.icon(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          icon: const Icon(
                            Icons.add_a_photo_outlined,
                            size: 14,
                          ),
                          label: '+ Photo',
                          onPressed: () =>
                              _openPhotoDialog(defaultAlbum: album),
                        ),
                        const SizedBox(width: 4),
                        MyAppIconButton(
                          icon: const Icon(Icons.edit_outlined, size: 17),
                          tooltip: 'Edit Album',
                          color: colors.heritageGold,
                          onPressed: () => _openAlbumDialog(album),
                        ),
                        MyAppIconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 17,
                          ),
                          tooltip: 'Delete Album',
                          color: Colors.redAccent,
                          onPressed: () => _confirmDeleteAlbum(album),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
