import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

class AdminDashboardOverviewView extends StatelessWidget {
  final AdminDataStore store;
  final ValueChanged<String> onNavigateTab;

  const AdminDashboardOverviewView({super.key, required this.store, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = context.isMobile;
    final newEnquiriesCount = store.enquiries.where((e) => e.status == 'New').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Banner
        CulturalFrameCard(
          backgroundColor: colors.deepMaroon,
          borderColor: colors.heritageGold,
          padding: EdgeInsets.all(isMobile ? 18 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: isMobile ? 48 : 58,
                    height: isMobile ? 48 : 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.heritageGold, width: 2),
                    ),
                    child: ClipOval(child: Image.asset('assets/images/pavan_putra_logo.jpg', fit: BoxFit.cover)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeritageBadge(
                          label: 'ADMINISTRATION PORTAL',
                          backgroundColor: colors.heritageGold.withValues(alpha: 0.18),
                          textColor: colors.lightGold,
                          borderColor: colors.heritageGold.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          store.settings.mandalNameEn,
                          style: styles.editorialSerif(context, size: isMobile ? 18 : 24, fontWeight: FontWeight.w700, color: colors.white),
                        ),
                        Text(
                          store.settings.mandalNameGu,
                          style: styles.devotionalMotto(context, size: isMobile ? 13 : 15, color: colors.lightGold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // Live Status & Key Indicators
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _HeaderStatusChip(
                    icon: store.liveStreamSettings.isLive ? Icons.fiber_manual_record_rounded : Icons.radio_button_unchecked_rounded,
                    iconColor: store.liveStreamSettings.isLive ? const Color(0xFFFF5252) : colors.lightGold.withValues(alpha: 0.7),
                    label: store.liveStreamSettings.isLive ? 'Live Stream: Active' : 'Live Stream: Offline',
                    backgroundColor: store.liveStreamSettings.isLive ? const Color(0xFFFF5252).withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.08),
                    borderColor: store.liveStreamSettings.isLive ? const Color(0xFFFF5252).withValues(alpha: 0.4) : colors.heritageGold.withValues(alpha: 0.25),
                    onTap: () => onNavigateTab('Videos & Live Stream'),
                  ),
                  _HeaderStatusChip(
                    icon: newEnquiriesCount > 0 ? Icons.mark_email_unread_rounded : Icons.check_circle_outline_rounded,
                    iconColor: newEnquiriesCount > 0 ? const Color(0xFFFFB74D) : const Color(0xFF81C784),
                    label: newEnquiriesCount > 0 ? '$newEnquiriesCount New Inquiries' : 'Inquiries: Up to date',
                    backgroundColor: newEnquiriesCount > 0 ? const Color(0xFFFFB74D).withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.08),
                    borderColor: newEnquiriesCount > 0 ? const Color(0xFFFFB74D).withValues(alpha: 0.4) : colors.heritageGold.withValues(alpha: 0.25),
                    onTap: () => onNavigateTab('Contact & Enquiries'),
                  ),
                  _HeaderStatusChip(
                    icon: Icons.cloud_done_rounded,
                    iconColor: const Color(0xFF64B5F6),
                    label: 'Website: Live & Online',
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    borderColor: colors.heritageGold.withValues(alpha: 0.25),
                    onTap: () {
                      store.syncAllToFirestore();
                      MyAppToastMessage.success(context, title: 'Website Content Saved', description: 'All website content and updates saved successfully.');
                    },
                  ),
                  _HeaderStatusChip(
                    icon: Icons.photo_library_outlined,
                    iconColor: colors.lightGold,
                    label: '${store.photos.length} Gallery Photos',
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    borderColor: colors.heritageGold.withValues(alpha: 0.25),
                    onTap: () => onNavigateTab('Gallery & Albums'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  MyAppFillButton.icon(
                    onPressed: () {
                      store.syncAllToFirestore();
                      MyAppToastMessage.success(context, title: 'Website Content Saved', description: 'All website content and updates saved successfully.');
                    },
                    icon: const Icon(Icons.cloud_sync_rounded, size: 18),
                    label: 'Save & Publish Website',
                  ),
                  MyAppOutlineButton.icon(
                    onPressed: () => onNavigateTab('Home Page'),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: 'Manage Home Screen',
                    color: colors.lightGold,
                  ),
                  MyAppOutlineButton.icon(
                    onPressed: () => onNavigateTab('Live Streaming'),
                    icon: const Icon(Icons.live_tv_rounded, size: 18),
                    label: store.liveStreamSettings.isLive ? 'Live Active' : 'Configure Live Stream',
                    color: colors.lightGold,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Metrics Grid (Responsive)
        Text('Website Overview & Content Metrics', style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final int columns;
            final double cardExtent;
            final double spacing;

            if (width >= 1200) {
              columns = 4;
              cardExtent = 92.0;
              spacing = 16.0;
            } else if (width >= 860) {
              columns = 3;
              cardExtent = 90.0;
              spacing = 14.0;
            } else if (width >= 560) {
              columns = 2;
              cardExtent = 90.0;
              spacing = 12.0;
            } else {
              columns = 1;
              cardExtent = 90.0;
              spacing = 10.0;
            }

            final cards = [
              _MetricCard(
                title: 'Sacred Pillars',
                value: '${store.pillars.length}',
                subtitle: 'Heritage foundations',
                icon: Icons.temple_hindu_outlined,
                color: const Color(0xFFC5A059),
                onTap: () => onNavigateTab('Home Page'),
              ),
              _MetricCard(
                title: 'Garbi Years',
                value: '${store.years.length}',
                subtitle: 'Festival archives',
                icon: Icons.calendar_month_outlined,
                color: const Color(0xFF2E7D32),
                onTap: () => onNavigateTab('Archive (Years)'),
              ),
              _MetricCard(
                title: 'Photo Gallery',
                value: '${store.photos.length}',
                subtitle: '${store.albums.length} photo albums',
                icon: Icons.photo_library_outlined,
                color: const Color(0xFF1976D2),
                onTap: () => onNavigateTab('Gallery & Albums'),
              ),
              _MetricCard(
                title: 'Videos & Live',
                value: '${store.videos.length}',
                subtitle: store.liveStreamSettings.isLive ? '🔴 LIVE STREAMING' : 'Offline',
                icon: Icons.video_collection_outlined,
                color: store.liveStreamSettings.isLive ? Colors.redAccent : const Color(0xFFD32F2F),
                onTap: () => onNavigateTab('Videos & Live Stream'),
              ),
              _MetricCard(
                title: 'Committee Members',
                value: '${store.committeeMembers.length}',
                subtitle: 'Mandal leadership',
                icon: Icons.groups_outlined,
                color: const Color(0xFF8E24AA),
                onTap: () => onNavigateTab('About Page'),
              ),
              _MetricCard(
                title: 'History Milestones',
                value: '${store.historyMilestones.length}',
                subtitle: 'Timeline milestones',
                icon: Icons.history_edu_rounded,
                color: const Color(0xFFE65100),
                onTap: () => onNavigateTab('History & Heritage'),
              ),
              _MetricCard(
                title: 'Published Blogs',
                value: '${store.blogs.length}',
                subtitle: 'Articles & stories',
                icon: Icons.article_outlined,
                color: const Color(0xFF00796B),
                onTap: () => onNavigateTab('Blog & Articles'),
              ),
              _MetricCard(
                title: 'Devotee Inquiries',
                value: '${store.enquiries.length}',
                subtitle: '${store.enquiries.where((e) => e.status == "New").length} new messages',
                icon: Icons.mail_outline_rounded,
                color: const Color(0xFFC2185B),
                onTap: () => onNavigateTab('Contact & Enquiries'),
              ),
            ];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                mainAxisExtent: cardExtent,
              ),
              itemBuilder: (context, index) => cards[index],
            );
          },
        ),
        const SizedBox(height: 32),

        // Recent Audit Activity Log
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Recent Admin Activity Log', style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            MyAppTextButton(onPressed: () => onNavigateTab('Activity Logs'), label: 'View All Logs'),
          ],
        ),
        const SizedBox(height: 10),
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: store.activityLogs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No activity records yet.')),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: store.activityLogs.take(5).length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final log = store.activityLogs[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: log.action == 'CREATE'
                                ? Colors.green.withValues(alpha: 0.15)
                                : (log.action == 'DELETE' ? Colors.red.withValues(alpha: 0.15) : colors.heritageGold.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            log.action,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: log.action == 'CREATE' ? Colors.green : (log.action == 'DELETE' ? Colors.red : colors.heritageGold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.details, style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600)),
                              Text(
                                '${log.module} • ${log.timestamp.toString().substring(0, 16)}',
                                style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MetricCard({required this.title, required this.value, required this.subtitle, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.isDarkMode(context)
                ? colors.heritageGold.withValues(alpha: 0.3)
                : colors.heritageGold.withValues(alpha: 0.35),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: colors.isDarkMode(context) ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Center(
                child: Icon(icon, color: color, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: styles.cleanSans(context, size: 19, fontWeight: FontWeight.w800, color: colors.getPrimaryTextColor(context)),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: styles.cleanSans(context, size: 10.5, color: colors.isDarkMode(context) ? colors.heritageGold : const Color(0xFF7A5812), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _HeaderStatusChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const _HeaderStatusChip({required this.icon, required this.iconColor, required this.label, this.onTap, this.backgroundColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFFF5EFE0), letterSpacing: 0.2),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), hoverColor: Colors.white.withValues(alpha: 0.08), child: chip),
      );
    }
    return chip;
  }
}
