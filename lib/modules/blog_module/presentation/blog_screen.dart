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

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key, this.slug});
  final String? slug;

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  @override
  void initState() {
    super.initState();
    AdminDataStore.instance.ensureBlogsLoaded();
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
        final isGujarati = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';

        final storeBlogs = AdminDataStore.instance.blogs;
        final articles = storeBlogs.map((b) => _BlogArticle(
          slug: b.slug,
          title: b.title,
          snippet: b.snippet,
          category: b.category,
          date: b.date,
          readTime: b.readTime,
          content: b.content,
        )).toList();

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
                HeritageBadge(label: context.tr('blog_tag')),
                const SizedBox(height: 16),
                Text(context.tr('blog_title'), style: styles.h1(context)),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Text(
                    context.tr('blog_desc'),
                    style: styles
                        .bodyText(context)
                        .copyWith(fontSize: isMobile ? 14 : 16),
                  ),
                ),
                const SizedBox(height: 36),

                // Articles List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: articles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return CulturalFrameCard(
                      onTap: () => _openArticleModal(context, article),
                      padding: EdgeInsets.all(isMobile ? 20 : 28),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMobile) ...[
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: colors.getAccentColor(context).withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: colors.heritageGold.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: Icon(
                                Icons.auto_stories_rounded,
                                color: colors.getAccentColor(context),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 24),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    HeritageBadge(label: article.category),
                                    const SizedBox(width: 12),
                                    Text(
                                      article.readTime,
                                      style: styles.cleanSans(
                                        context,
                                        size: 11,
                                        color: colors.getMutedTextColor(
                                          context,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isGujarati ? context.trDynamic(article.title) : article.title,
                                  style: isGujarati
                                      ? styles.gujaratiSerif(
                                          context,
                                          size: isMobile ? 18 : 22,
                                          fontWeight: FontWeight.w700,
                                        )
                                      : styles.editorialSerif(
                                          context,
                                          size: isMobile ? 18 : 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isGujarati ? context.trDynamic(article.snippet) : article.snippet,
                                  style: styles
                                      .bodyText(context)
                                      .copyWith(
                                        color: colors.getSecondaryTextColor(
                                          context,
                                        ),
                                        fontSize: 14,
                                        height: 1.6,
                                      ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Text(
                                      context.tr('blog_read_more'),
                                      style: styles.cleanSans(
                                        context,
                                        color: colors.getAccentColor(context),
                                        size: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      article.date,
                                      style: styles.cleanSans(
                                        context,
                                        size: 11,
                                        color: colors.getMutedTextColor(
                                          context,
                                        ),
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

  void _openArticleModal(BuildContext context, _BlogArticle article) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isGu = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';

    showMyAppDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.4)),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeritageBadge(label: article.category),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(Icons.close_rounded, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isGu ? context.trDynamic(article.title) : article.title,
                    style: isGu
                        ? styles.gujaratiSerif(
                            context,
                            size: 24,
                            fontWeight: FontWeight.w700,
                          )
                        : styles.editorialSerif(
                            context,
                            size: 24,
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${article.date} • ${article.readTime}',
                    style: styles.cleanSans(
                      context,
                      size: 11.5,
                      color: colors.getMutedTextColor(context),
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    article.content,
                    style: styles
                        .bodyText(context)
                        .copyWith(fontSize: 15.5, height: 1.8),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '|| શ્રી પવનપુત્ર ગરબી મંડળ સંશોધન ||',
                      style: styles.devotionalMotto(
                        context,
                        size: 14,
                        color: colors.getAccentColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BlogArticle {
  final String slug;
  final String title;
  final String snippet;
  final String category;
  final String date;
  final String readTime;
  final String content;

  const _BlogArticle({
    required this.slug,
    required this.title,
    required this.snippet,
    required this.category,
    required this.date,
    required this.readTime,
    required this.content,
  });
}
