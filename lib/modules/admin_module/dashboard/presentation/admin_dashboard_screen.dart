import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/localization/my_app_translations.dart';
import '../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/widgets/heritage_badge.dart';
import '../../../../core/widgets/my_app_blurred_loader.dart';
import '../../../../core/widgets/my_app_ui_components.dart';
import '../../../../utils/navigation_manager.dart';
import '../../auth/presentation/admin_auth_cubit.dart';
import '../data/admin_data_store.dart';

import 'views/admin_dashboard_overview_view.dart';
import 'views/admin_home_page_view.dart';
import 'views/admin_about_page_view.dart';
import 'views/admin_history_page_view.dart';
import 'views/admin_archive_page_view.dart';
import 'views/admin_gallery_page_view.dart';
import 'views/admin_videos_page_view.dart';
import 'views/admin_blog_page_view.dart';
import 'views/admin_contact_page_view.dart';
import 'views/admin_footer_view.dart';
import 'views/admin_activity_logs_view.dart';
import 'views/admin_settings_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedTab = 'Dashboard';
  final AdminDataStore _store = AdminDataStore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _store.ensureAdminDataLoaded();
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _selectTab(String tab) {
    setState(() => _selectedTab = tab);
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final isMobile = context.isMobile;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: colors.getBackgroundColor(context),
      drawer: isMobile
          ? Drawer(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                color: colors.getSidebarBackgroundColor(context),
                child: SafeArea(
                  child: _AdminSidebarContent(
                    selectedTab: _selectedTab,
                    onSelectTab: _selectTab,
                  ),
                ),
              ),
            )
          : null,
      body: !_store.isInitialized
          ? const MyAppBlurredLoader(
              message: 'Loading Admin Portal...',
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isMobile)
                  _AdminSidebar(
                    selectedTab: _selectedTab,
                    onSelectTab: _selectTab,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _AdminTopNavBar(
                        selectedTab: _selectedTab,
                        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            isMobile ? 14 : 28,
                            20,
                            isMobile ? 14 : 28,
                            isMobile ? 16 : 24,
                          ),
                          child: _buildCurrentTabContent(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCurrentTabContent(BuildContext context) {
    switch (_selectedTab) {
      // Pages & Navigation
      case 'Home Page':
        return AdminHomePageView(store: _store);
      case 'About Page':
        return AdminAboutPageView(store: _store);
      case 'History & Heritage':
        return AdminHistoryPageView(store: _store);
      case 'Archive (Years)':
        return AdminArchivePageView(store: _store);
      case 'Gallery & Albums':
        return AdminGalleryPageView(store: _store);
      case 'Videos & Live Stream':
      case 'Live Streaming':
        return AdminVideosPageView(store: _store);
      case 'Blog & Articles':
      case 'Blogs':
        return AdminBlogPageView(store: _store);
      case 'Contact & Enquiries':
      case 'Enquiries':
        return AdminContactPageView(store: _store);
      case 'Footer & Social Links':
      case 'Footer Module':
        return AdminFooterView(store: _store);
      case 'Activity Logs':
        return AdminActivityLogsView(store: _store);
      case 'Settings':
        return AdminSettingsView(store: _store);
      case 'Dashboard':
      default:
        return AdminDashboardOverviewView(
          store: _store,
          onNavigateTab: _selectTab,
        );
    }
  }
}

// -------------------------------------------------------------
// TOP NAVIGATION BAR
// -------------------------------------------------------------
class _AdminTopNavBar extends StatelessWidget {
  final String selectedTab;
  final VoidCallback onOpenDrawer;

  const _AdminTopNavBar({
    required this.selectedTab,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final isMobile = context.isMobile;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        border: Border(
          bottom: BorderSide(
            color: colors.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            MyAppIconButton(
              icon: Icon(
                Icons.menu_rounded,
                color: colors.getPrimaryTextColor(context),
              ),
              tooltip: 'Menu',
              onPressed: onOpenDrawer,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: HeritageBadge(
                label: 'ADMIN / ${selectedTab.toUpperCase()}',
                backgroundColor: colors.getAccentColor(context).withValues(alpha: 0.1),
                textColor: colors.getAccentColor(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isMobile)
            MyAppIconButton(
              tooltip: context.tr('nav_home'),
              onPressed: () => serviceLocator<NavigationManager>().goToHome(context),
              icon: const Icon(Icons.public_rounded, size: 20),
              color: colors.getPrimaryTextColor(context),
            )
          else
            MyAppOutlineButton.icon(
              onPressed: () => serviceLocator<NavigationManager>().goToHome(context),
              icon: const Icon(Icons.public_rounded, size: 16),
              label: context.tr('nav_home'),
            ),
          const SizedBox(width: 10),
          MyAppIconButton(
            tooltip: 'Logout Admin',
            icon: const Icon(Icons.logout_rounded, size: 18),
            color: colors.getAccentColor(context),
            onPressed: () => context.read<AdminAuthCubit>().signOut(),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// SIDEBAR DESKTOP CONTAINER
// -------------------------------------------------------------
class _AdminSidebar extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onSelectTab;

  const _AdminSidebar({
    required this.selectedTab,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: colors.getSidebarBackgroundColor(context),
        border: Border(
          right: BorderSide(
            color: colors.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: _AdminSidebarContent(
        selectedTab: selectedTab,
        onSelectTab: onSelectTab,
      ),
    );
  }
}

// -------------------------------------------------------------
// CATEGORIZED SIDEBAR CONTENT
// -------------------------------------------------------------
class _AdminSidebarContent extends StatelessWidget {
  final String selectedTab;
  final ValueChanged<String> onSelectTab;

  const _AdminSidebarContent({
    required this.selectedTab,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);

    final overviewItems = [
      ('Dashboard', Icons.dashboard_outlined),
    ];

    final pageItems = [
      ('Home Page', Icons.home_outlined),
      ('About Page', Icons.info_outline_rounded),
      ('History & Heritage', Icons.history_edu_rounded),
      ('Archive (Years)', Icons.calendar_month_outlined),
      ('Gallery & Albums', Icons.photo_library_outlined),
      ('Videos & Live Stream', Icons.play_circle_outline_rounded),
      ('Blog & Articles', Icons.article_outlined),
      ('Contact & Enquiries', Icons.mail_outline_rounded),
    ];

    final layoutItems = [
      ('Footer & Social Links', Icons.space_dashboard_outlined),
    ];

    final systemItems = [
      ('Activity Logs', Icons.history_toggle_off_rounded),
      ('Settings', Icons.settings_outlined),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mandal Emblem Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.heritageGold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: colors.heritageGold.withValues(alpha: isDark ? 0.25 : 0.15),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/pavan_putra_logo.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'PAVAN PUTRA',
                        style: styles.editorialSerif(
                          context,
                          size: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? colors.white : colors.heritageMaroon,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'ADMINISTRATION PORTAL',
                        style: styles.cleanSans(
                          context,
                          size: 9.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? colors.heritageGold : const Color(0xFF8C6D23),
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Group 1: Overview
                _buildGroupHeader('OVERVIEW', colors, styles, context, isDark),
                ...overviewItems.map((item) => _buildMenuItem(item.$1, item.$2, colors, styles, context, isDark)),
                const SizedBox(height: 16),

                // Group 2: Website Pages
                _buildGroupHeader('WEBSITE CONTENT', colors, styles, context, isDark),
                ...pageItems.map((item) => _buildMenuItem(item.$1, item.$2, colors, styles, context, isDark)),
                const SizedBox(height: 16),

                // Group 3: Layout & Branding
                _buildGroupHeader('LAYOUT & BRANDING', colors, styles, context, isDark),
                ...layoutItems.map((item) => _buildMenuItem(item.$1, item.$2, colors, styles, context, isDark)),
                const SizedBox(height: 16),

                // Group 4: System
                _buildGroupHeader('SYSTEM & AUDIT', colors, styles, context, isDark),
                ...systemItems.map((item) => _buildMenuItem(item.$1, item.$2, colors, styles, context, isDark)),
              ],
            ),
          ),
        ),

        // Bottom User Status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.35) : colors.getCardBackgroundColor(context),
            border: Border(top: BorderSide(color: colors.getBorderColor(context))),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? colors.heritageGold : colors.heritageMaroon,
                child: Text(
                  'PP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? colors.deepMaroon : colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Master',
                      style: styles.cleanSans(
                        context,
                        size: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.getPrimaryTextColor(context),
                      ),
                    ),
                    Text(
                      'Full Access',
                      style: styles.cleanSans(
                        context,
                        size: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? colors.heritageGold : const Color(0xFF8C6D23),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(String title, MyAppColors colors, MyAppTextStyles styles, BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: styles.cleanSans(
          context,
          size: 9.5,
          fontWeight: FontWeight.w800,
          color: isDark ? colors.heritageGold.withValues(alpha: 0.85) : const Color(0xFF7A5812),
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    MyAppColors colors,
    MyAppTextStyles styles,
    BuildContext context,
    bool isDark,
  ) {
    final isSelected = selectedTab == title;

    final selectedBg = isDark ? colors.heritageGold : colors.heritageMaroon;
    final selectedFg = isDark ? colors.deepMaroon : colors.white;
    final unselectedFg = isDark ? colors.white.withValues(alpha: 0.88) : colors.getPrimaryTextColor(context);
    final unselectedIcon = isDark ? colors.heritageGold.withValues(alpha: 0.8) : const Color(0xFF5A524A);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => onSelectTab(title),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected && !isDark
                ? [
                    BoxShadow(
                      color: colors.heritageMaroon.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? selectedFg : unselectedIcon,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: styles.cleanSans(
                    context,
                    size: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? selectedFg : unselectedFg,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: selectedFg,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
