import 'package:flutter/material.dart';

import '../dependency_injection/dependency_injection.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import 'heritage_badge.dart';
import 'dialogs/my_app_dialog.dart';

/// Opens a modal dialog displaying the full cultural story / article
void showArticleDetailModal(
  BuildContext context, {
  required String title,
  required String category,
  required String content,
  String snippet = '',
  String date = '',
  String readTime = '',
  String imageUrl = '',
}) {
  final colors = serviceLocator<MyAppColors>();
  final styles = serviceLocator<MyAppTextStyles>();
  final isGu = Localizations.maybeLocaleOf(context)?.languageCode == 'gu';

  final effectiveContent = content.trim().isNotEmpty ? content.trim() : (snippet.trim().isNotEmpty ? snippet.trim() : title);

  showMyAppDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: colors.getCardBackgroundColor(context),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.4)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  HeritageBadge(label: category.isNotEmpty ? category.toUpperCase() : (isGu ? 'સાંસ્કૃતિક વાતો' : 'HERITAGE ARTICLE')),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (readTime.isNotEmpty) ...[
                        Icon(Icons.access_time_rounded, size: 14, color: colors.getSecondaryTextColor(context)),
                        const SizedBox(width: 4),
                        Text(readTime, style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context))),
                        const SizedBox(width: 12),
                      ],
                      IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(dialogContext), icon: const Icon(Icons.close_rounded, size: 22)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(title, style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700)),
              if (date.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  date,
                  style: styles.cleanSans(context, size: 12, color: colors.heritageGold, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 14),
              Divider(color: colors.heritageGold.withValues(alpha: 0.2), height: 1),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (snippet.trim().isNotEmpty && snippet.trim() != effectiveContent) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.heritageGold.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.heritageGold.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            snippet.trim(),
                            style: styles.bodyText(context).copyWith(fontSize: 13.5, fontStyle: FontStyle.italic, color: colors.getPrimaryTextColor(context), height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(effectiveContent, style: styles.editorialSerif(context, size: 15.5, height: 1.8, color: colors.getPrimaryTextColor(context))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.heritageMaroon,
                    foregroundColor: colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close Article'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
