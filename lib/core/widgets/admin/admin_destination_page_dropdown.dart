import 'package:flutter/material.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';
import '../dialogs/my_app_dialog.dart';

class AdminPageDestination {
  final String path;
  final String labelEn;
  final String labelGu;
  final IconData icon;

  const AdminPageDestination({required this.path, required this.labelEn, required this.labelGu, required this.icon});
}

const List<AdminPageDestination> kAdminPublicPages = [
  AdminPageDestination(path: '/archive', labelEn: 'Archive Records & Photos', labelGu: 'આર્કાઇવ અને ફોટો સંગ્રહ', icon: Icons.calendar_month_rounded),
  AdminPageDestination(path: '/about', labelEn: 'About Mandal & Traditions', labelGu: 'મંડળ પરિચય અને પરંપરા', icon: Icons.info_outline_rounded),
  AdminPageDestination(path: '/history', labelEn: 'History & Heritage Timeline', labelGu: 'ઇતિહાસ અને સીમાચિહ્નો', icon: Icons.history_edu_rounded),
  AdminPageDestination(path: '/gallery', labelEn: 'Photo Gallery', labelGu: 'ફોટો ગેલેરી', icon: Icons.photo_library_rounded),
  AdminPageDestination(path: '/videos', labelEn: 'Sacred Garba Videos', labelGu: 'ગરબી વિડિયો દર્શન', icon: Icons.play_circle_outline_rounded),
  AdminPageDestination(path: '/blog', labelEn: 'Cultural Articles & Stories', labelGu: 'સાંસ્કૃતિક લેખો અને વાતો', icon: Icons.article_outlined),
  AdminPageDestination(path: '/contact', labelEn: 'Contact & Location Map', labelGu: 'સંપર્ક અને સ્થળ માહિતી', icon: Icons.location_on_outlined),
  AdminPageDestination(path: '/', labelEn: 'Home Page', labelGu: 'મુખ્ય હોમ પેજ', icon: Icons.home_rounded),
];

/// Reusable, responsive destination page selector dropdown for all Admin panels.
/// Replaces manual route path typing (like `/archive` or `/about`) with an intuitive
/// bilingual dropdown list with icons, badges, and optional custom link support.
class AdminDestinationPageDropdown extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? helperText;
  final String defaultRoute;
  final bool showInfoBadge;
  final ValueChanged<String>? onChanged;

  const AdminDestinationPageDropdown({
    super.key,
    required this.controller,
    this.labelText = 'Destination Page to Open (કયા પેજ પર જવું)',
    this.hintText = 'Select which website page opens when clicked',
    this.helperText = 'Select which website page visitors explore when clicking this button',
    this.defaultRoute = '/archive',
    this.showInfoBadge = true,
    this.onChanged,
  });

  @override
  State<AdminDestinationPageDropdown> createState() => _AdminDestinationPageDropdownState();
}

class _AdminDestinationPageDropdownState extends State<AdminDestinationPageDropdown> {
  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final currentText = widget.controller.text.trim();
    final effectiveRoute = currentText.isEmpty ? widget.defaultRoute : currentText;
    final matchingPage = kAdminPublicPages.where((p) => p.path == effectiveRoute).firstOrNull;
    final isCustom = matchingPage == null && effectiveRoute.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey(effectiveRoute),
          initialValue: effectiveRoute,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.touch_app_rounded, size: 20, color: colors.heritageGold),
            ),
            helperText: widget.helperText,
            helperMaxLines: 2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.getBorderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.heritageGold, width: 1.5),
            ),
          ),
          dropdownColor: colors.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          icon: Icon(Icons.arrow_drop_down_circle_outlined, size: 20, color: colors.heritageGold),
          selectedItemBuilder: (BuildContext context) {
            final allValues = [...kAdminPublicPages.map((p) => p.path), if (isCustom) effectiveRoute, '__custom__'];
            return allValues.map((val) {
              final page = kAdminPublicPages.where((p) => p.path == val).firstOrNull;
              if (page != null) {
                return Row(
                  children: [
                    Icon(page.icon, size: 17, color: colors.heritageGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${page.labelEn} (${page.labelGu})',
                        style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              }
              if (val == '__custom__') {
                return Row(
                  children: [
                    const Icon(Icons.edit_note_rounded, size: 17, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Custom URL / Link...',
                        style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  const Icon(Icons.link_rounded, size: 17, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Custom: $val',
                      style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              );
            }).toList();
          },
          items: [
            for (final page in kAdminPublicPages)
              DropdownMenuItem<String>(
                value: page.path,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: effectiveRoute == page.path ? colors.heritageGold.withValues(alpha: 0.2) : colors.heritageGold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(page.icon, size: 16, color: colors.heritageGold),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${page.labelEn} (${page.labelGu})',
                        style: styles.cleanSans(context, size: 13, fontWeight: effectiveRoute == page.path ? FontWeight.w700 : FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.heritageGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.25), width: 0.8),
                      ),
                      child: Text(
                        page.path,
                        style: styles.cleanSans(context, size: 10, fontWeight: FontWeight.w600, color: colors.heritageGold),
                      ),
                    ),
                    if (effectiveRoute == page.path) ...[const SizedBox(width: 6), Icon(Icons.check_circle_rounded, size: 16, color: colors.heritageGold)],
                  ],
                ),
              ),
            if (isCustom)
              DropdownMenuItem<String>(
                value: effectiveRoute,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.link_rounded, size: 16, color: Colors.blue),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Custom: $effectiveRoute',
                        style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.check_circle_rounded, size: 16, color: colors.heritageGold),
                  ],
                ),
              ),
            DropdownMenuItem<String>(
              value: '__custom__',
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.edit_note_rounded, size: 16, color: Colors.blue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Other Custom URL / Link...',
                      style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600, color: Colors.blue.shade700),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (val) async {
            if (val == null) return;
            if (val == '__custom__') {
              final customUrlCtrl = TextEditingController(text: isCustom ? effectiveRoute : '');
              final result = await showMyAppDialog<String>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: colors.getCardBackgroundColor(dialogCtx),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      Icon(Icons.link_rounded, color: colors.heritageGold, size: 22),
                      const SizedBox(width: 10),
                      Text('Enter Custom Page or Link', style: styles.cleanSans(dialogCtx, size: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter an internal route path (e.g. /archive/2024) or full external URL (e.g. https://...):',
                        style: styles.cleanSans(dialogCtx, size: 13, color: colors.getMutedTextColor(dialogCtx)),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: customUrlCtrl,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'e.g. /archive/2024 or https://...',
                          prefixIcon: const Icon(Icons.link_rounded, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.heritageGold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.pop(dialogCtx, customUrlCtrl.text.trim()),
                      child: const Text('Save Link'),
                    ),
                  ],
                ),
              );
              if (result != null && result.isNotEmpty) {
                widget.controller.text = result;
                widget.onChanged?.call(result);
                setState(() {});
              } else {
                setState(() {});
              }
            } else {
              widget.controller.text = val;
              widget.onChanged?.call(val);
              setState(() {});
            }
          },
        ),
        if (widget.showInfoBadge) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: colors.heritageGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 13, color: colors.heritageGold),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    'Button opens: ${matchingPage != null ? "${matchingPage.labelEn} (${matchingPage.path})" : effectiveRoute}',
                    style: styles.cleanSans(context, size: 11, fontWeight: FontWeight.w600, color: colors.getPrimaryTextColor(context)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
