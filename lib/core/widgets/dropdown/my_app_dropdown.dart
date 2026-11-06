import 'dart:ui';
import 'package:flutter/material.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';
import '../bottom_sheet/my_app_bottom_sheet.dart';

/// --------------------------------------------------------------------------
/// PREDEFINED PUBLIC PAGE DESTINATIONS
/// --------------------------------------------------------------------------
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

/// Item definition for MyAppDropdown
class MyAppDropdownItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const MyAppDropdownItem({required this.value, required this.label, this.subtitle, this.icon});
}

/// --------------------------------------------------------------------------
/// MY APP DROPDOWN
/// Sophisticated, clean, and polished dropdown component:
/// - Completely removes confusing custom URL inputs.
/// - Mobile (<650px): Opens a luxurious Heritage Bottom Sheet with drag handle,
///   icons, bilingual labels, and checkmarks on active item.
/// - Desktop (>=650px): Opens an anchored Dropdown Popup Overlay directly beneath
///   the trigger box.
/// - Backdrop Blur (sigma: 5) in both Light & Dark modes.
/// - Dedicated MyAppDropdown.pageDestination factory for route navigation selectors.
/// --------------------------------------------------------------------------
class MyAppDropdown<T> extends StatefulWidget {
  final String labelText;
  final String? hintText;
  final T? value;
  final List<MyAppDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final Widget? prefixIcon;
  final bool enabled;

  const MyAppDropdown({super.key, required this.labelText, this.hintText, required this.value, required this.items, required this.onChanged, this.prefixIcon, this.enabled = true});

  /// Factory constructor specifically for choosing destination pages across all admin screens
  static Widget pageDestination({
    Key? key,
    required TextEditingController controller,
    String labelText = 'Destination Page to Open',
    String hintText = 'Select destination page',
    String defaultRoute = '/archive',
    ValueChanged<String>? onChanged,
  }) {
    final currentRoute = controller.text.trim();
    final effectiveRoute = currentRoute.isEmpty ? defaultRoute : currentRoute;

    final items = kAdminPublicPages.map((page) {
      return MyAppDropdownItem<String>(value: page.path, label: page.labelEn, subtitle: page.labelGu, icon: page.icon);
    }).toList();

    return MyAppDropdown<String>(
      key: key,
      labelText: labelText,
      hintText: hintText,
      value: effectiveRoute,
      prefixIcon: const Icon(Icons.touch_app_rounded, size: 20),
      items: items,
      onChanged: (selectedPath) {
        controller.text = selectedPath;
        onChanged?.call(selectedPath);
      },
    );
  }

  @override
  State<MyAppDropdown<T>> createState() => _MyAppDropdownState<T>();
}

class _MyAppDropdownState<T> extends State<MyAppDropdown<T>> {
  final GlobalKey _triggerKey = GlobalKey();

  MyAppDropdownItem<T>? get _selectedItem {
    try {
      return widget.items.firstWhere((item) => item.value == widget.value);
    } catch (_) {
      return widget.items.isNotEmpty ? widget.items.first : null;
    }
  }

  void _handleOpenPicker(BuildContext context) {
    if (!widget.enabled || widget.items.isEmpty) return;

    final isMobile = MediaQuery.sizeOf(context).width < 650;
    if (isMobile) {
      _openMobileBottomSheet(context);
    } else {
      _openDesktopDropdownOverlay(context);
    }
  }

  void _openMobileBottomSheet(BuildContext context) async {
    final title = widget.labelText.isNotEmpty ? widget.labelText : (widget.hintText ?? 'Select Option');

    final selected = await showMyAppBottomSheet<T>(
      context: context,
      title: title,
      selectedValue: widget.value,
      items: widget.items.map((item) {
        return MyAppBottomSheetItem<T>(value: item.value, label: item.label, subtitle: item.subtitle, icon: item.icon);
      }).toList(),
    );

    if (selected != null) {
      widget.onChanged(selected);
    }
  }

  void _openDesktopDropdownOverlay(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final renderBox = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final triggerOffset = renderBox.localToGlobal(Offset.zero);
    final triggerSize = renderBox.size;
    final screenSize = MediaQuery.sizeOf(context);

    final exactWidth = triggerSize.width;
    final double spaceBelow = screenSize.height - (triggerOffset.dy + triggerSize.height) - 16;
    final double spaceAbove = triggerOffset.dy - 16;
    final bool showAbove = spaceBelow < 220 && spaceAbove > spaceBelow;
    final double maxMenuHeight = (showAbove ? spaceAbove : spaceBelow).clamp(160.0, 340.0);

    final double bottomDistance = screenSize.height - (triggerOffset.dy + triggerSize.height);

    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Dropdown',
      barrierColor: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.20),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Stack(
            children: [
              // Tap outside to dismiss
              Positioned.fill(
                child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => Navigator.of(dialogContext).pop(), child: const SizedBox.expand()),
              ),

              // Positioned Active Trigger Field + Dropdown Menu
              Positioned(
                top: showAbove ? null : triggerOffset.dy,
                bottom: showAbove ? bottomDistance : null,
                left: triggerOffset.dx,
                width: exactWidth,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showAbove) ...[
                        FadeTransition(
                          opacity: curve,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.20), // slides smoothly up from bottom to top
                              end: Offset.zero,
                            ).animate(curve),
                            child: ScaleTransition(
                              alignment: Alignment.bottomCenter,
                              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curve),
                              child: _buildMenuCard(dialogContext, colors, styles, isDark, maxMenuHeight),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FadeTransition(
                          opacity: curve,
                          child: _buildTriggerWidget(isOpen: true, onTap: () => Navigator.of(dialogContext).pop()),
                        ),
                      ] else ...[
                        FadeTransition(
                          opacity: curve,
                          child: _buildTriggerWidget(isOpen: true, onTap: () => Navigator.of(dialogContext).pop()),
                        ),
                        const SizedBox(height: 6),
                        FadeTransition(
                          opacity: curve,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, -0.20), // slides smoothly down from top to bottom
                              end: Offset.zero,
                            ).animate(curve),
                            child: ScaleTransition(
                              alignment: Alignment.topCenter,
                              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curve),
                              child: _buildMenuCard(dialogContext, colors, styles, isDark, maxMenuHeight),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext dialogContext, MyAppColors colors, MyAppTextStyles styles, bool isDark, double maxMenuHeight) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxMenuHeight),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: widget.items.length,
          separatorBuilder: (context, index) => Divider(height: 1, indent: 48, endIndent: 12, color: colors.getBorderColor(context).withValues(alpha: 0.4)),
          itemBuilder: (context, index) {
            final item = widget.items[index];
            final isSelected = item.value == widget.value;

            return InkWell(
              onTap: () {
                Navigator.pop(dialogContext);
                widget.onChanged(item.value);
              },
              child: Container(
                color: isSelected ? (isDark ? colors.heritageMaroon.withValues(alpha: 0.4) : colors.heritageGold.withValues(alpha: 0.12)) : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Icon(item.icon, size: 18, color: isSelected ? (isDark ? colors.lightGold : colors.heritageMaroon) : colors.getAccentColor(context)),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.label,
                            style: styles.cleanSans(
                              context,
                              size: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? (isDark ? colors.lightGold : colors.heritageMaroon) : colors.getPrimaryTextColor(context),
                            ),
                          ),
                          if (item.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(item.subtitle!, style: styles.cleanSans(context, size: 11, color: colors.getMutedTextColor(context))),
                          ],
                        ],
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_rounded, size: 18, color: isDark ? colors.lightGold : colors.heritageMaroon),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTriggerWidget({Key? key, bool isOpen = false, VoidCallback? onTap}) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);
    final selected = _selectedItem;

    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isDark ? (isOpen ? const Color(0xFF262222) : const Color(0xFF1E1B1B)) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isOpen ? colors.heritageGold : colors.getBorderColor(context), width: isOpen ? 1.4 : 1.0),
          boxShadow: isOpen ? [BoxShadow(color: colors.heritageGold.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 2))] : null,
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              IconTheme(
                data: IconThemeData(size: 18, color: isOpen ? colors.heritageGold : colors.getAccentColor(context)),
                child: widget.prefixIcon!,
              ),
              const SizedBox(width: 10),
            ] else if (selected?.icon != null) ...[
              Icon(selected!.icon, size: 18, color: isOpen ? colors.heritageGold : colors.getAccentColor(context)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.labelText,
                    style: styles.cleanSans(context, size: 10.5, fontWeight: FontWeight.w600, color: isOpen ? colors.heritageGold : colors.getSecondaryTextColor(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selected != null ? '${selected.label}${selected.subtitle != null ? " (${selected.subtitle})" : ""}' : (widget.hintText ?? 'Select...'),
                    style: styles.cleanSans(
                      context,
                      size: 13,
                      fontWeight: FontWeight.w600,
                      color: selected != null ? colors.getPrimaryTextColor(context) : colors.getMutedTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 20, color: isOpen ? colors.heritageGold : colors.getAccentColor(context)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTriggerWidget(key: _triggerKey, isOpen: false, onTap: widget.enabled ? () => _handleOpenPicker(context) : null);
  }
}
