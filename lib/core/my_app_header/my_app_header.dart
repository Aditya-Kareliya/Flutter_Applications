import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import '../dependency_injection/dependency_injection.dart';
import '../localization/my_app_translations.dart';
import '../my_app_bloc/my_app_bloc.dart';
import '../my_app_bloc/my_app_event.dart';
import '../my_app_bloc/my_app_state.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_manager.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';
import '../widgets/brand_logo/brand_logo_widget.dart';
import '../widgets/my_app_ui_components.dart';

class MyAppHeader extends StatelessWidget {
  const MyAppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 980;
    final isMobile = screenWidth < 600;

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) => BlocBuilder<MyAppBloc, MyAppState>(
        buildWhen: (prev, curr) =>
            prev.locale != curr.locale ||
            prev.themeMode != curr.themeMode ||
            prev.isBlurredLoading != curr.isBlurredLoading,
        builder: (context, state) {
        final isGujarati = state.locale.languageCode == 'gu';

        return RepaintBoundary(
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 72,
                      maxHeight: isMobile ? 120 : 88,
                    ),
                    width: 100.w,
                    color: colors.getBackgroundColor(context).withValues(alpha: 0.85),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 28,
                      vertical: 10,
                    ),
          child: Row(
            children: [
              // Mandal Brand Emblem & Title
              Expanded(
                child: InkWell(
                  onTap: () =>
                      serviceLocator<NavigationManager>().goToHome(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BrandLogoWidget(
                          size: isMobile ? 42 : 48,
                          isCircular: true,
                          border: Border.all(
                            color: colors.heritageGold,
                            width: 1.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.getAccentColor(context).withValues(
                                alpha: 0.18,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr('app_title'),
                                maxLines: isMobile ? 2 : 1,
                                overflow: TextOverflow.visible,
                                style: isGujarati
                                    ? styles.gujaratiSerif(
                                        context,
                                        size: isMobile ? 15 : 17,
                                        fontWeight: FontWeight.w700,
                                      )
                                    : styles.editorialSerif(
                                        context,
                                        size: isMobile ? 15 : 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr('app_subtitle'),
                                maxLines: isMobile ? 2 : 1,
                                overflow: TextOverflow.visible,
                                style: styles.cleanSans(
                                  context,
                                  size: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: colors.getAccentColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Desktop Navigation Links
              if (!isCompact)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final nav in NavigationManager.mainNavItems)
                      _NavItem(
                        label: context.tr(nav.labelKey),
                        onTap: () => context.go(nav.route),
                      ),
                    _NavItem(
                      label: context.tr('nav_admin'),
                      onTap: () => serviceLocator<NavigationManager>()
                          .goToAdminLogin(context),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),

              // Theme Mode Selector
              _ThemeModeMenu(currentMode: state.themeMode),
              const SizedBox(width: 8),

              // Language Switcher Button (English <-> Gujarati)
              Tooltip(
                message: isGujarati
                    ? 'Switch to English'
                    : 'ગુજરાતી ભાષા પસંદ કરો',
                child: InkWell(
                  onTap: state.isBlurredLoading
                      ? null
                      : () {
                          final nextLocale = isGujarati
                              ? const Locale('en')
                              : const Locale('gu');
                          context.read<MyAppBloc>().add(
                            MyAppChangeLanguageEvent(nextLocale),
                          );
                        },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.getAccentColor(context).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.heritageGold.withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 15,
                          color: colors.getAccentColor(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isGujarati ? 'EN' : 'ગુ',
                          style: isGujarati
                              ? styles.cleanSans(
                                  context,
                                  size: 13,
                                  fontWeight: FontWeight.w800,
                                  color: colors.getAccentColor(context),
                                )
                              : styles.gujaratiSerif(
                                  context,
                                  size: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colors.getAccentColor(context),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Mobile / Tablet Hamburger Menu
              if (isCompact) ...[
                const SizedBox(width: 6),
                IconButton(
                  tooltip: 'Menu',
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  icon: Icon(
                    Icons.menu_rounded,
                    size: 26,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (AdminDataStore.instance.isBusy)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 2.5,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(colors.heritageGold),
              ),
            ),
          ),
      ],
    ),
  ),
),
);
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final styles = serviceLocator<MyAppTextStyles>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(label, style: styles.navText(context)),
      ),
    );
  }
}



class _ThemeModeMenu extends StatelessWidget {
  final ThemeMode currentMode;

  const _ThemeModeMenu({required this.currentMode});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();

    IconData icon;
    String tooltip;
    switch (currentMode) {
      case ThemeMode.light:
        icon = Icons.light_mode_rounded;
        tooltip = 'Theme: Light';
        break;
      case ThemeMode.dark:
        icon = Icons.dark_mode_rounded;
        tooltip = 'Theme: Dark';
        break;
      case ThemeMode.system:
        icon = Icons.brightness_auto_rounded;
        tooltip = 'Theme: Device / System';
        break;
    }

    return MyAppPopupMenuButton<ThemeMode>(
      tooltip: tooltip,
      initialValue: currentMode,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, anim) => RotationTransition(
          turns: anim.drive(Tween(begin: 0.75, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic))),
          child: ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
        ),
        child: Icon(icon, key: ValueKey(currentMode), size: 20, color: colors.getPrimaryTextColor(context)),
      ),
      onSelected: (mode) {
        context.read<MyAppBloc>().add(MyAppChangeThemeModeEvent(mode));
      },
      itemBuilder: (context) => [
        MyAppPopupMenuItem(
          value: ThemeMode.light,
          icon: Icon(
            Icons.light_mode_rounded,
            size: 18,
            color: colors.getAccentColor(context),
          ),
          label: context.tr('theme_light'),
        ),
        MyAppPopupMenuItem(
          value: ThemeMode.dark,
          icon: Icon(
            Icons.dark_mode_rounded,
            size: 18,
            color: colors.getAccentColor(context),
          ),
          label: context.tr('theme_dark'),
        ),
        MyAppPopupMenuItem(
          value: ThemeMode.system,
          icon: Icon(
            Icons.brightness_auto_rounded,
            size: 18,
            color: colors.getAccentColor(context),
          ),
          label: context.tr('theme_system'),
        ),
      ],
    );
  }
}
