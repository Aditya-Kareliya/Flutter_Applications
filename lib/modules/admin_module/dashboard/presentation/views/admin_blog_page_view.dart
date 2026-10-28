import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Full CRUD management view for Blog & Articles
class AdminBlogPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminBlogPageView({super.key, required this.store});

  @override
  State<AdminBlogPageView> createState() => _AdminBlogPageViewState();
}

class _AdminBlogPageViewState extends State<AdminBlogPageView> {
  void _openBlogDialog([AdminBlog? blog]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final titleCtrl = TextEditingController(text: blog?.title ?? '');
    final titleGuCtrl = TextEditingController(text: blog?.titleGu ?? '');
    final categoryCtrl = TextEditingController(text: blog?.category ?? 'Heritage');
    final dateCtrl = TextEditingController(text: blog?.date ?? 'October 2025');
    final readTimeCtrl = TextEditingController(text: blog?.readTime ?? '5 min');
    final snippetCtrl = TextEditingController(text: blog?.snippet ?? '');
    final contentCtrl = TextEditingController(text: blog?.content ?? '');
    String imgUrl = blog?.imageUrl ?? 'assets/images/pavan_putra_logo.jpg';
    bool isPublished = blog?.isPublished ?? true;

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
            blog == null ? 'Write New Article' : 'Edit Article Details',
            style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 560 ? double.infinity : 540,
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Article Title (Gujarati)',
                    prefixIcon: const Icon(Icons.subtitles_outlined),
                  ),
                  const SizedBox(height: 12),
                  if (MediaQuery.sizeOf(context).width < 550) ...[
                    MyAppTextFormField(
                      controller: categoryCtrl,
                      labelText: 'Category (Heritage, Music, Tradition)',
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: dateCtrl,
                      labelText: 'Publication Date',
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    const SizedBox(height: 12),
                    MyAppTextFormField(
                      controller: readTimeCtrl,
                      labelText: 'Read Time',
                      prefixIcon: const Icon(Icons.access_time_rounded),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: MyAppTextFormField(
                            controller: categoryCtrl,
                            labelText: 'Category (Heritage, Music, Tradition)',
                            prefixIcon: const Icon(Icons.category_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyAppTextFormField(
                            controller: dateCtrl,
                            labelText: 'Publication Date',
                            prefixIcon: const Icon(Icons.calendar_today_rounded),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MyAppTextFormField(
                            controller: readTimeCtrl,
                            labelText: 'Read Time',
                            prefixIcon: const Icon(Icons.access_time_rounded),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: snippetCtrl,
                    labelText: 'Short Summary Snippet',
                    hintText: 'A brief summary of the article',
                    minLines: 2,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: contentCtrl,
                    labelText: 'Full Article Content (Markdown or Text)',
                    hintText: 'Write the complete article content here...',
                    minLines: 5,
                    maxLines: 12,
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Published on Website', style: TextStyle(fontWeight: FontWeight.w600)),
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
                final title = titleCtrl.text.trim();
                if (title.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Title Required', description: 'Please enter article title.');
                  return;
                }

                final slug = title.toLowerCase().replaceAll(' ', '-').replaceAll(RegExp(r'[^a-z0-9\-]'), '');

                if (blog == null) {
                  widget.store.addBlog(AdminBlog(
                    id: 'b-${DateTime.now().millisecondsSinceEpoch}',
                    slug: slug,
                    title: title,
                    titleGu: titleGuCtrl.text.trim(),
                    category: categoryCtrl.text.trim().isEmpty ? 'Heritage' : categoryCtrl.text.trim(),
                    date: dateCtrl.text.trim().isEmpty ? 'Today' : dateCtrl.text.trim(),
                    readTime: readTimeCtrl.text.trim().isEmpty ? '5 min' : readTimeCtrl.text.trim(),
                    snippet: snippetCtrl.text.trim(),
                    content: contentCtrl.text.trim(),
                    imageUrl: imgUrl,
                    isPublished: isPublished,
                  ));
                  MyAppToastMessage.success(context, title: 'Article Published', description: 'Article "$title" published.');
                } else {
                  widget.store.updateBlog(blog.copyWith(
                    title: title,
                    titleGu: titleGuCtrl.text.trim(),
                    category: categoryCtrl.text.trim(),
                    date: dateCtrl.text.trim(),
                    readTime: readTimeCtrl.text.trim(),
                    snippet: snippetCtrl.text.trim(),
                    content: contentCtrl.text.trim(),
                    imageUrl: imgUrl,
                    isPublished: isPublished,
                  ));
                  MyAppToastMessage.success(context, title: 'Article Updated', description: 'Article "$title" saved.');
                }
                Navigator.pop(ctx);
              },
              label: blog == null ? 'Publish' : 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(AdminBlog blog) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Article?'),
        content: Text('Are you sure you want to delete "${blog.title}"?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteBlog(blog.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(context, title: 'Article Deleted', description: 'Article "${blog.title}" removed.');
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
          websitePageTitle: 'Blog & Articles Page',
          websiteRoute: '/blog',
          explanation: 'Controls articles, announcements, and cultural write-ups published on the public Blog page.',
        ),
        // Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeritageBadge(label: 'WEBSITE CONTENT / BLOG & ARTICLES'),
                const SizedBox(height: 6),
                Text(
                  'Cultural Articles & Stories',
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Publish editorial articles, history essays, and cultural publications with cover photos.',
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
            MyAppFillButton.icon(
              onPressed: () => _openBlogDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: 'Write Article',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ARTICLES LIST
        widget.store.blogs.isEmpty
            ? const CulturalFrameCard(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No articles written yet. Click "Write Article" above.')),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.store.blogs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final blog = widget.store.blogs[index];
                  if (isMobile) {
                    return CulturalFrameCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: colors.heritageGold, width: 1.2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: blog.imageUrl.startsWith('http')
                                      ? Image.network(blog.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg'))
                                      : Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                                ),
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
                                          backgroundColor: blog.isPublished ? Colors.green.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.12),
                                          textColor: blog.isPublished ? Colors.green : Colors.grey,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      blog.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            blog.snippet,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${blog.date} • ${blog.readTime}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MyAppIconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    tooltip: 'Edit Article',
                                    color: colors.heritageGold,
                                    onPressed: () => _openBlogDialog(blog),
                                  ),
                                  const SizedBox(width: 4),
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

                  return CulturalFrameCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.heritageGold, width: 1.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: blog.imageUrl.startsWith('http')
                                ? Image.network(blog.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.jpg'))
                                : Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 14),
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
                                  Text(
                                    '${blog.date} • ${blog.readTime}',
                                    style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                                  ),
                                  HeritageBadge(label: blog.isPublished ? 'PUBLISHED' : 'DRAFT'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                blog.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.editorialSerif(context, size: 15.5, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                blog.snippet,
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
                            MyAppIconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Article',
                              color: colors.heritageGold,
                              onPressed: () => _openBlogDialog(blog),
                            ),
                            const SizedBox(width: 4),
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
                },
              ),
      ],
    );
  }
}
