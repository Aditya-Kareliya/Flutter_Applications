import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image/app_cached_image.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../data/admin_data_store.dart';

/// Full CRUD and site content management view for Blog & Cultural Articles.
/// Designed pixel-perfect to match the Admin Home, Gallery, and Video Vault screens.
class AdminBlogPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminBlogPageView({super.key, required this.store});

  @override
  State<AdminBlogPageView> createState() => _AdminBlogPageViewState();
}

class _AdminBlogPageViewState extends State<AdminBlogPageView> {
  // ---------------------------------------------------------------------------
  // SECTION 1: HEADER TEXT CONTROLLERS
  // ---------------------------------------------------------------------------
  late final TextEditingController _tagEnCtrl;
  late final TextEditingController _tagGuCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleGuCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descGuCtrl;

  String _headerPreviewLang = 'en';

  // ---------------------------------------------------------------------------
  // SECTION 2: ARTICLES SEARCH & FILTER STATE
  // ---------------------------------------------------------------------------
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategoryFilter = 'ALL';
  String _selectedStatusFilter = 'ALL';

  // Predefined Categories
  static const List<String> _categories = [
    'Heritage',
    'Tradition',
    'Music',
    'Aarti',
    'Garbi',
    'Announcements',
  ];

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdated);
    widget.store.ensureBlogsLoaded();

    _tagEnCtrl = TextEditingController();
    _tagGuCtrl = TextEditingController();
    _titleEnCtrl = TextEditingController();
    _titleGuCtrl = TextEditingController();
    _descEnCtrl = TextEditingController();
    _descGuCtrl = TextEditingController();

    _reloadAllControllersFromStore();

    _searchCtrl.addListener(() {
      if (mounted) {
        setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
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
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _reloadAllControllersFromStore() {
    final s = widget.store;
    _tagEnCtrl.text =
        s.getTextOverride('en', 'blog_tag') ??
        s.getTextOverride('en', 'sec_blog_tag') ??
        '';
    _tagGuCtrl.text =
        s.getTextOverride('gu', 'blog_tag') ??
        s.getTextOverride('gu', 'sec_blog_tag') ??
        '';
    _titleEnCtrl.text =
        s.getTextOverride('en', 'blog_title') ??
        s.getTextOverride('en', 'sec_blog_title') ??
        '';
    _titleGuCtrl.text =
        s.getTextOverride('gu', 'blog_title') ??
        s.getTextOverride('gu', 'sec_blog_title') ??
        '';
    _descEnCtrl.text = s.getTextOverride('en', 'blog_desc') ?? '';
    _descGuCtrl.text = s.getTextOverride('gu', 'blog_desc') ?? '';

  }

  // ---------------------------------------------------------------------------
  // PERSISTENCE ACTIONS
  // ---------------------------------------------------------------------------
  void _saveHeader() {
    final s = widget.store;
    s.updateSiteContentField(
      'blog_tag',
      valueEn: _tagEnCtrl.text.trim(),
      valueGu: _tagGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'sec_blog_tag',
      valueEn: _tagEnCtrl.text.trim(),
      valueGu: _tagGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'blog_title',
      valueEn: _titleEnCtrl.text.trim(),
      valueGu: _titleGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'sec_blog_title',
      valueEn: _titleEnCtrl.text.trim(),
      valueGu: _titleGuCtrl.text.trim(),
    );
    s.updateSiteContentField(
      'blog_desc',
      valueEn: _descEnCtrl.text.trim(),
      valueGu: _descGuCtrl.text.trim(),
    );

    MyAppToastMessage.success(
      context,
      title: 'Header Saved',
      description: 'Blog header published successfully.',
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

  void _saveAllSections() {
    _saveHeader();
    MyAppToastMessage.success(
      context,
      title: 'All Changes Saved',
      description: 'Blog & Articles header successfully published.',
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
  // ARTICLE CRUD DIALOGS & READER
  // ---------------------------------------------------------------------------
  void _openBlogDialog([AdminBlog? blog]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final titleCtrl = TextEditingController(text: blog?.title ?? '');
    final titleGuCtrl = TextEditingController(text: blog?.titleGu ?? '');
    String selectedCategory = blog?.category ?? 'Heritage';
    final categoryCtrl = TextEditingController(text: selectedCategory);
    final dateCtrl = TextEditingController(text: blog?.date ?? 'October 2025');
    final readTimeCtrl = TextEditingController(text: blog?.readTime ?? '5 min');
    final snippetCtrl = TextEditingController(text: blog?.snippet ?? '');
    final snippetGuCtrl = TextEditingController(text: blog?.snippetGu ?? '');
    final contentCtrl = TextEditingController(text: blog?.content ?? '');
    final contentGuCtrl = TextEditingController(text: blog?.contentGu ?? '');
    String imgUrl = blog?.imageUrl ?? 'assets/images/pavan_putra_logo.jpg';
    bool isPublished = blog?.isPublished ?? true;

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
              Icon(
                blog == null ? Icons.post_add_rounded : Icons.edit_note_rounded,
                color: colors.heritageGold,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  blog == null ? 'Write New Article' : 'Edit Article Details',
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
                  ? (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 580.0)
                  : 580,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppImagePicker(
                    label: 'Article Cover Image',
                    initialImageUrl: imgUrl,
                    height: 140,
                    onImageChanged: (url) => setDlgState(() => imgUrl = url),
                  ),
                  const SizedBox(height: 14),
                  MyAppTextFormField(
                    controller: titleCtrl,
                    labelText: 'Article Title (English) *',
                    showTranslateIcon: true,
                    targetLanguageController: titleGuCtrl,
                    prefixIcon: const Icon(Icons.title_rounded),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Article Title (Gujarati)',
                    hintText:
                        'દા.ત. પ્રાચીન ગરબી અને અર્વાચીન ગરબા વચ્ચેનો આધ્યાત્મિક ભેદ',
                    prefixIcon: const Icon(Icons.subtitles_outlined),
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 14),

                  // Category Selector Chips
                  Text(
                    'Article Category',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: colors.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: colors.heritageGold,
                        backgroundColor: colors.getSurfaceColor(context),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? colors.deepMaroon
                              : colors.getPrimaryTextColor(context),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? colors.heritageGold
                              : colors.heritageGold.withValues(alpha: 0.3),
                          width: 1,
                        ),
                        onSelected: (val) {
                          if (val) {
                            setDlgState(() {
                              selectedCategory = cat;
                              categoryCtrl.text = cat;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Date and Read Time
                  if (isMobile) ...[
                    MyAppTextFormField(
                      controller: dateCtrl,
                      labelText: 'Publication Date',
                      hintText: 'e.g. October 2025',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                      showClearIcon: true,
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: readTimeCtrl,
                      labelText: 'Estimated Read Time',
                      hintText: 'e.g. 5 min',
                      prefixIcon: const Icon(Icons.access_time_rounded),
                      showClearIcon: true,
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: MyAppTextFormField(
                            controller: dateCtrl,
                            labelText: 'Publication Date',
                            hintText: 'e.g. October 2025',
                            prefixIcon: const Icon(
                              Icons.calendar_today_rounded,
                            ),
                            showClearIcon: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyAppTextFormField(
                            controller: readTimeCtrl,
                            labelText: 'Estimated Read Time',
                            hintText: 'e.g. 5 min',
                            prefixIcon: const Icon(Icons.access_time_rounded),
                            showClearIcon: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Dual-Language Snippets
                  MyAppTextAreaField(
                    controller: snippetCtrl,
                    labelText: 'Summary Snippet (English) *',
                    hintText:
                        'A brief summary of the article displayed on preview cards...',
                    showTranslateIcon: true,
                    targetLanguageController: snippetGuCtrl,
                    minLines: 2,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: snippetGuCtrl,
                    labelText: 'Summary Snippet (Gujarati)',
                    hintText:
                        'લેખનો સંક્ષિપ્ત સારાંશ જે પ્રીવ્યૂ કાર્ડ પર દર્શાવવામાં આવશે...',
                    minLines: 2,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),

                  // Full Content
                  MyAppTextAreaField(
                    controller: contentCtrl,
                    labelText: 'Full Article Content (English) *',
                    hintText:
                        'Write the complete article content, cultural analysis, hymns, and narrative here...',
                    showTranslateIcon: true,
                    targetLanguageController: contentGuCtrl,
                    minLines: 5,
                    maxLines: 12,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: contentGuCtrl,
                    labelText: 'Full Article Content (Gujarati - optional)',
                    hintText:
                        'સંપૂર્ણ લેખ, આધ્યાત્મિક વિશ્લેષણ અને ગરબીની સ્તુતિઓ અહીં લખો...',
                    minLines: 5,
                    maxLines: 12,
                  ),
                  const SizedBox(height: 14),

                  // Published Switch
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
                                'Publish Article on Website',
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
                final title = titleCtrl.text.trim();
                if (title.isEmpty) {
                  MyAppToastMessage.warning(
                    context,
                    title: 'Title Required',
                    description: 'Please enter article title.',
                  );
                  return;
                }

                final slug = title
                    .toLowerCase()
                    .replaceAll(' ', '-')
                    .replaceAll(RegExp(r'[^a-z0-9\-]'), '');

                if (blog == null) {
                  widget.store.addBlog(
                    AdminBlog(
                      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
                      slug: slug.isEmpty
                          ? 'article-${DateTime.now().millisecondsSinceEpoch}'
                          : slug,
                      title: title,
                      titleGu: titleGuCtrl.text.trim(),
                      category: selectedCategory,
                      date: dateCtrl.text.trim().isEmpty
                          ? 'October 2025'
                          : dateCtrl.text.trim(),
                      readTime: readTimeCtrl.text.trim().isEmpty
                          ? '5 min'
                          : readTimeCtrl.text.trim(),
                      snippet: snippetCtrl.text.trim(),
                      snippetGu: snippetGuCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      contentGu: contentGuCtrl.text.trim(),
                      imageUrl: imgUrl,
                      isPublished: isPublished,
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Article Published',
                    description: 'Article "$title" published.',
                  );
                } else {
                  widget.store.updateBlog(
                    blog.copyWith(
                      title: title,
                      titleGu: titleGuCtrl.text.trim(),
                      category: selectedCategory,
                      date: dateCtrl.text.trim(),
                      readTime: readTimeCtrl.text.trim(),
                      snippet: snippetCtrl.text.trim(),
                      snippetGu: snippetGuCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      contentGu: contentGuCtrl.text.trim(),
                      imageUrl: imgUrl,
                      isPublished: isPublished,
                    ),
                  );
                  MyAppToastMessage.success(
                    context,
                    title: 'Article Updated',
                    description: 'Article "$title" saved.',
                  );
                }
                Navigator.pop(ctx);
                setState(() {});
              },
              label: blog == null ? 'Publish Article' : 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleViewer(AdminBlog blog) {
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
              ? (MediaQuery.sizeOf(context).width - 28).clamp(280.0, 640.0)
              : 640,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner Image
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
                          imageUrl: blog.imageUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 800,
                          memCacheHeight: 450,
                          fallbackWidget: Container(
                            color: colors.deepMaroon,
                            child: const Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
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
                          blog.readTime.isNotEmpty
                              ? blog.readTime
                              : '5 MIN READ',
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
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          HeritageBadge(label: blog.category),
                          HeritageBadge(
                            label: blog.isPublished
                                ? 'PUBLISHED'
                                : 'DRAFT / HIDDEN',
                            backgroundColor: blog.isPublished
                                ? colors.heritageGold.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                            textColor: blog.isPublished
                                ? colors.getAccentColor(context)
                                : Colors.grey,
                          ),
                          Text(
                            '•  ${blog.date}',
                            style: styles.cleanSans(
                              context,
                              size: 11.5,
                              color: colors.getMutedTextColor(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        blog.title,
                        style: styles.editorialSerif(
                          context,
                          size: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (blog.titleGu.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          blog.titleGu,
                          style: styles.devotionalMotto(
                            context,
                            size: 14,
                            color: colors.heritageGold,
                          ),
                        ),
                      ],
                      if (blog.snippet.isNotEmpty ||
                          blog.snippetGu.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.getSurfaceColor(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: colors.heritageGold,
                                width: 3,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (blog.snippet.isNotEmpty)
                                Text(
                                  blog.snippet,
                                  style: styles
                                      .cleanSans(context, size: 12.5)
                                      .copyWith(fontStyle: FontStyle.italic),
                                ),
                              if (blog.snippetGu.isNotEmpty) ...[
                                if (blog.snippet.isNotEmpty)
                                  const SizedBox(height: 4),
                                Text(
                                  blog.snippetGu,
                                  style: styles
                                      .cleanSans(
                                        context,
                                        size: 12,
                                        color: colors.heritageGold,
                                      )
                                      .copyWith(fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Divider(height: 1, color: colors.getBorderColor(context)),
                      const SizedBox(height: 14),
                      Text(
                        blog.content.isNotEmpty
                            ? blog.content
                            : '(No article body content written yet.)',
                        style: styles.cleanSans(
                          context,
                          size: 13.5,
                          height: 1.6,
                          color: colors.getPrimaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyAppOutlineButton.icon(
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: 'Edit Article',
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openBlogDialog(blog);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(AdminBlog blog) {
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
            const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Article?',
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
          'Are you sure you want to permanently delete "${blog.title}"? This cannot be undone.',
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
              widget.store.deleteBlog(blog.id);
              Navigator.pop(ctx);
              setState(() {});
              MyAppToastMessage.warning(
                context,
                title: 'Article Deleted',
                description: 'Article "${blog.title}" removed.',
              );
            },
            label: 'Delete Article',
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
    final isMobile = context.isMobile;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Public Context Banner
          const AdminWebsiteContextBanner(
            websitePageTitle: 'Blog & Articles Page',
            websiteRoute: '/blog',
            explanation:
                'Controls articles, folklore essays, and cultural publications displayed on the public Blog page.',
          ),

          // Master Header Action Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            spacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HeritageBadge(
                    label: 'WEBSITE CONTENT / BLOG & ARTICLES',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cultural Articles & Stories',
                    style: styles.editorialSerif(
                      context,
                      size: isMobile ? 20 : 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Publish editorial articles, history essays, and cultural publications with cover photos.',
                    style: styles.cleanSans(
                      context,
                      size: 12.5,
                      color: colors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MyAppOutlineButton.icon(
                    isDanger: true,
                    onPressed: _confirmResetAll,
                    icon: const Icon(Icons.restore_rounded, size: 16),
                    label: 'Reset All',
                  ),
                  MyAppFillButton.icon(
                    onPressed: _saveAllSections,
                    icon: const Icon(Icons.save_rounded, size: 16),
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
                      'Controls the grand title, eyebrow badge, and historical overview paragraph on the public Blog & Articles page.',
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
                  hintText: 'e.g. ESSAYS & ARTICLES',
                ),
                _buildDualLanguageField(
                  title: '1.2 Blog Page Grand Title (મુખ્ય શીર્ષક)',
                  enLabel: 'Blog Title (English)',
                  enCtrl: _titleEnCtrl,
                  guLabel: 'Blog Title (Gujarati)',
                  guCtrl: _titleGuCtrl,
                  hintText: 'e.g. Sacred Stories, Folklore & Updates',
                ),
                _buildDualLanguageField(
                  title: '1.3 Editorial Narrative Overview (પરિચય વિગત)',
                  enLabel: 'Overview (English)',
                  enCtrl: _descEnCtrl,
                  guLabel: 'Overview (Gujarati)',
                  guCtrl: _descGuCtrl,
                  maxLines: 3,
                  hintText:
                      'Essays, historical reflections, and divine insights into the classical Garbi tradition...',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // SECTION 2: CULTURAL ARTICLES & STORIES EXPLORER
          // ===================================================================
          _buildArticlesExplorer(context, isMobile),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTION 2: ARTICLES EXPLORER BUILDER
  // ---------------------------------------------------------------------------
  Widget _buildArticlesExplorer(BuildContext context, bool isMobile) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final allBlogs = widget.store.blogs;

    final filteredBlogs = allBlogs.where((blog) {
      if (_selectedCategoryFilter != 'ALL' &&
          blog.category != _selectedCategoryFilter) {
        return false;
      }
      if (_selectedStatusFilter == 'PUBLISHED' && !blog.isPublished) {
        return false;
      }
      if (_selectedStatusFilter == 'DRAFT' && blog.isPublished) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery;
        final mEn = blog.title.toLowerCase().contains(q);
        final mGu = blog.titleGu.toLowerCase().contains(q);
        final mCat = blog.category.toLowerCase().contains(q);
        final mSnippet = blog.snippet.toLowerCase().contains(q);
        final mSnippetGu = blog.snippetGu.toLowerCase().contains(q);
        final mContent = blog.content.toLowerCase().contains(q);
        if (!mEn && !mGu && !mCat && !mSnippet && !mSnippetGu && !mContent) {
          return false;
        }
      }
      return true;
    }).toList();

    return CulturalFrameCard(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeaderCard(
            context: context,
            icon: Icons.article_rounded,
            title: '2. Cultural Articles & Stories Explorer',
            subtitle:
                'Create, edit, organize and publish heritage articles, essays, and sacred folklore.',
            actions: [
              HeritageBadge(
                label: '${filteredBlogs.length} / ${allBlogs.length} Articles',
              ),
              MyAppFillButton.icon(
                onPressed: () => _openBlogDialog(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: 'Write New Article',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Bar
          MyAppTextFormField(
            controller: _searchCtrl,
            hintText:
                'Search articles by title, snippet, category, or content...',
            prefixIcon: const Icon(Icons.search_rounded),
            showClearIcon: true,
          ),
          const SizedBox(height: 12),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'All Categories (${allBlogs.length})',
                  _selectedCategoryFilter == 'ALL',
                  () {
                    setState(() => _selectedCategoryFilter = 'ALL');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                for (final cat in _categories) ...[
                  _buildFilterChip(cat, _selectedCategoryFilter == cat, () {
                    setState(() => _selectedCategoryFilter = cat);
                  }, colors),
                  const SizedBox(width: 8),
                ],
                Container(
                  width: 1,
                  height: 20,
                  color: colors.heritageGold.withValues(alpha: 0.3),
                ),
                const SizedBox(width: 12),
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
                  'Published (${allBlogs.where((b) => b.isPublished).length})',
                  _selectedStatusFilter == 'PUBLISHED',
                  () {
                    setState(() => _selectedStatusFilter = 'PUBLISHED');
                  },
                  colors,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Draft (${allBlogs.where((b) => !b.isPublished).length})',
                  _selectedStatusFilter == 'DRAFT',
                  () {
                    setState(() => _selectedStatusFilter = 'DRAFT');
                  },
                  colors,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content List
          if (filteredBlogs.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: colors.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.heritageGold.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 48,
                    color: colors.heritageGold.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    allBlogs.isEmpty
                        ? 'No articles published yet.'
                        : 'No articles match your search or filter.',
                    style: styles.cleanSans(
                      context,
                      size: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    allBlogs.isEmpty
                        ? 'Click "Write New Article" to craft the first cultural publication.'
                        : 'Try clearing the search query or selecting "All Categories".',
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      color: colors.getSecondaryTextColor(context),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (allBlogs.isEmpty) ...[
                    const SizedBox(height: 16),
                    MyAppFillButton.icon(
                      onPressed: () => _openBlogDialog(),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: 'Write First Article',
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredBlogs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final blog = filteredBlogs[index];
                return _buildArticleCard(
                  context,
                  blog,
                  isMobile,
                  colors,
                  styles,
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ARTICLE CARD (RESPONSIVE)
  // ---------------------------------------------------------------------------
  Widget _buildArticleCard(
    BuildContext context,
    AdminBlog blog,
    bool isMobile,
    MyAppColors colors,
    MyAppTextStyles styles,
  ) {
    if (isMobile) {
      return CulturalFrameCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverThumbnail(
                  blog.imageUrl,
                  colors,
                  width: 60,
                  height: 60,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          HeritageBadge(label: blog.category),
                          HeritageBadge(
                            label: blog.isPublished ? 'PUBLISHED' : 'DRAFT',
                            backgroundColor: blog.isPublished
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.grey.withValues(alpha: 0.12),
                            textColor: blog.isPublished
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        blog.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: styles.editorialSerif(
                          context,
                          size: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (blog.titleGu.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          blog.titleGu,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.devotionalMotto(
                            context,
                            size: 12,
                            color: colors.heritageGold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (blog.snippet.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                blog.snippet,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: styles.cleanSans(
                  context,
                  size: 12,
                  color: colors.getSecondaryTextColor(context),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Divider(height: 1, color: colors.getBorderColor(context)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${blog.date} • ${blog.readTime}',
                  style: styles.cleanSans(
                    context,
                    size: 11,
                    color: colors.getMutedTextColor(context),
                  ),
                ),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    MyAppOutlineButton.icon(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      icon: const Icon(Icons.remove_red_eye_outlined, size: 14),
                      label: 'Read',
                      onPressed: () => _showArticleViewer(blog),
                    ),
                    MyAppIconButton(
                      icon: Icon(
                        blog.isPublished
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        size: 18,
                      ),
                      tooltip: blog.isPublished
                          ? 'Unpublish (Mark as Draft)'
                          : 'Publish to Website',
                      color: blog.isPublished ? Colors.green : Colors.grey,
                      onPressed: () {
                        widget.store.updateBlog(
                          blog.copyWith(isPublished: !blog.isPublished),
                        );
                        setState(() {});
                      },
                    ),
                    MyAppIconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Edit Article',
                      color: colors.heritageGold,
                      onPressed: () => _openBlogDialog(blog),
                    ),
                    MyAppIconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      tooltip: 'Delete Article',
                      color: Colors.redAccent,
                      onPressed: () => _confirmDelete(blog),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Tablet / Desktop Card
    return CulturalFrameCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverThumbnail(blog.imageUrl, colors, width: 72, height: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    HeritageBadge(label: blog.category),
                    HeritageBadge(
                      label: blog.isPublished ? 'PUBLISHED' : 'DRAFT',
                      backgroundColor: blog.isPublished
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.grey.withValues(alpha: 0.12),
                      textColor: blog.isPublished ? Colors.green : Colors.grey,
                    ),
                    Text(
                      '${blog.date}  •  ${blog.readTime}',
                      style: styles.cleanSans(
                        context,
                        size: 11.5,
                        color: colors.getMutedTextColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  blog.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.editorialSerif(
                    context,
                    size: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (blog.titleGu.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    blog.titleGu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.devotionalMotto(
                      context,
                      size: 12.5,
                      color: colors.heritageGold,
                    ),
                  ),
                ],
                if (blog.snippet.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    blog.snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: styles.cleanSans(
                      context,
                      size: 12.5,
                      color: colors.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyAppOutlineButton.icon(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                icon: const Icon(Icons.remove_red_eye_outlined, size: 15),
                label: 'Read',
                onPressed: () => _showArticleViewer(blog),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: blog.isPublished
                    ? 'Unpublish (Mark as Draft)'
                    : 'Publish to Website',
                child: MyAppIconButton(
                  icon: Icon(
                    blog.isPublished
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                    size: 18,
                  ),
                  color: blog.isPublished ? Colors.green : Colors.grey,
                  onPressed: () {
                    widget.store.updateBlog(
                      blog.copyWith(isPublished: !blog.isPublished),
                    );
                    setState(() {});
                  },
                ),
              ),
              MyAppIconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                tooltip: 'Edit Article',
                color: colors.heritageGold,
                onPressed: () => _openBlogDialog(blog),
              ),
              MyAppIconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                tooltip: 'Delete Article',
                color: Colors.redAccent,
                onPressed: () => _confirmDelete(blog),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LIVE WEBSITE PREVIEW (SECTION 1: HEADER)
  // ---------------------------------------------------------------------------
  Widget _buildLiveHeaderPreview(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final s = widget.store;
    final fallbackTag = _headerPreviewLang == 'gu'
        ? 'લેખો અને કથાઓ'
        : 'ESSAYS & ARTICLES';
    final fallbackTitle = _headerPreviewLang == 'gu'
        ? 'સાંસ્કૃતિક કથાઓ અને લેખો'
        : 'Sacred Stories, Folklore & Updates';
    final fallbackDesc = _headerPreviewLang == 'gu'
        ? 'શ્રી પવનપુત્ર વ્યાયામ પ્રચારક મંડળની પ્રાચીન ગરબી પરંપરા, ઇતિહાસ અને આધ્યાત્મિક વાર્તાઓનું સંકલન.'
        : 'Essays, historical reflections, and divine insights into the classical Garbi tradition of Shree Pavanputra Vyayam Pracharak Mandal.';

    final rawTag = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _tagEnCtrl.text,
      gu: _tagGuCtrl.text,
    );
    final displayTag = rawTag.isNotEmpty
        ? rawTag
        : (s.getTextOverride(_headerPreviewLang, 'blog_tag') ?? fallbackTag);

    final rawTitle = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _titleEnCtrl.text,
      gu: _titleGuCtrl.text,
    );
    final displayTitle = rawTitle.isNotEmpty
        ? rawTitle
        : (s.getTextOverride(_headerPreviewLang, 'blog_title') ??
              fallbackTitle);

    final rawDesc = _resolvePreviewText(
      lang: _headerPreviewLang,
      en: _descEnCtrl.text,
      gu: _descGuCtrl.text,
    );
    final displayDesc = rawDesc.isNotEmpty
        ? rawDesc
        : (s.getTextOverride(_headerPreviewLang, 'blog_desc') ?? fallbackDesc);

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
  // HELPER WIDGETS
  // ---------------------------------------------------------------------------
  Widget _buildCoverThumbnail(
    String imageUrl,
    MyAppColors colors, {
    double width = 56,
    double height = 56,
    double radius = 10,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colors.heritageGold.withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: AppCachedImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          memCacheWidth: 200,
          memCacheHeight: 200,
        ),
      ),
    );
  }

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

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    MyAppColors colors,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colors.heritageGold,
      backgroundColor: colors.getSurfaceColor(context),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isSelected
            ? colors.deepMaroon
            : colors.getPrimaryTextColor(context),
      ),
      side: BorderSide(
        color: isSelected
            ? colors.heritageGold
            : colors.heritageGold.withValues(alpha: 0.3),
        width: 1,
      ),
      onSelected: (_) => onTap(),
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

  String _resolvePreviewText({
    required String lang,
    required String en,
    required String gu,
  }) {
    if (lang == 'gu') {
      return gu.trim().isNotEmpty ? gu.trim() : en.trim();
    }
    return en.trim().isNotEmpty ? en.trim() : gu.trim();
  }
}
