import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependency_injection/dependency_injection.dart';
import '../localization/my_app_translations.dart';
import '../my_app_bloc/my_app_bloc.dart';
import '../my_app_bloc/my_app_state.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_manager.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';
import '../widgets/brand_logo/brand_logo_widget.dart';

class MyAppDrawer extends StatelessWidget {
  const MyAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) => BlocBuilder<MyAppBloc, MyAppState>(
        builder: (context, state) {
          return Drawer(
            backgroundColor: colors.getBackgroundColor(context),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Area
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        BrandLogoWidget(
                          size: 48,
                          isCircular: true,
                          border: Border.all(color: colors.getAccentColor(context), width: 1.5),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('app_title'),
                                maxLines: 2,
                                style: styles.editorialSerif(
                                  context,
                                  size: 16,
                                  fontWeight: FontWeight.w700,
                                  color: colors.getPrimaryTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr('app_subtitle'),
                                style: styles.cleanSans(
                                  context,
                                  size: 10,
                                  fontWeight: FontWeight.w700,
                                  color: colors.getAccentColor(context),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: colors.getAccentColor(context).withValues(alpha: 0.2),
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  
                  // Navigation Items (Dynamic from AdminDataStore)
                  Expanded(
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        for (final nav in NavigationManager.mainNavItems)
                          _DrawerItem(
                            label: context.tr(nav.labelKey),
                            icon: nav.icon,
                            onTap: () {
                              Navigator.pop(context);
                              context.go(nav.route);
                            },
                          ),
                        _DrawerItem(
                          label: context.tr('nav_admin'),
                          icon: Icons.admin_panel_settings_rounded,
                          onTap: () {
                            Navigator.pop(context);
                            serviceLocator<NavigationManager>().goToAdminLogin(context);
                          },
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
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final styles = serviceLocator<MyAppTextStyles>();
    final colors = serviceLocator<MyAppColors>();

    return ListTile(
      leading: Icon(icon, color: colors.getAccentColor(context), size: 24),
      title: Text(
        label,
        style: styles.cleanSans(
          context,
          size: 15,
          fontWeight: FontWeight.w600,
          color: colors.getPrimaryTextColor(context),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      onTap: onTap,
      hoverColor: colors.getAccentColor(context).withValues(alpha: 0.1),
    );
  }
}


