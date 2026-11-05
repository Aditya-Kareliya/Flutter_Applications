import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/localization/my_app_translations.dart';
import '../../../core/my_app_bloc/my_app_bloc.dart';
import '../../../core/my_app_bloc/my_app_state.dart';
import '../../../core/my_app_colors/my_app_colors.dart';
import '../../../core/my_app_scaffold/my_app_scaffold.dart';
import '../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/heritage_badge.dart';
import '../../../core/widgets/heritage_divider.dart';
import '../../../utils/navigation_manager.dart';
import '../../admin_module/dashboard/data/admin_data_store.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    AdminDataStore.instance.ensureHistoryLoaded();
  }

  IconData _iconForMilestone(String iconName) {
    switch (iconName) {
      case 'local_fire_department_rounded':
        return Icons.local_fire_department_rounded;
      case 'music_note_rounded':
        return Icons.music_note_rounded;
      case 'military_tech_rounded':
        return Icons.military_tech_rounded;
      case 'auto_stories_rounded':
        return Icons.auto_stories_rounded;
      case 'cloud_done_rounded':
        return Icons.cloud_done_rounded;
      case 'temple_hindu_rounded':
        return Icons.temple_hindu_rounded;
      case 'stars_rounded':
        return Icons.stars_rounded;
      case 'groups_rounded':
        return Icons.groups_rounded;
      case 'volunteer_activism_rounded':
        return Icons.volunteer_activism_rounded;
      default:
        return Icons.history_edu_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) => BlocBuilder<MyAppBloc, MyAppState>(
        builder: (context, state) {
          final isGujarati = state.locale.languageCode == 'gu';
          final store = AdminDataStore.instance;

          final activeMilestones = store.historyMilestones.where((m) => m.isActive).toList();
          final List<_MilestoneItem> milestones = activeMilestones.isNotEmpty
              ? activeMilestones.map((m) {
                  final badge = isGujarati && m.badgeGu.isNotEmpty ? m.badgeGu : m.badgeEn;
                  final title = isGujarati && m.titleGu.isNotEmpty ? m.titleGu : m.titleEn;
                  final desc = isGujarati && m.descGu.isNotEmpty ? m.descGu : m.descEn;
                  return _MilestoneItem(
                    year: m.year,
                    badge: badge,
                    title: title,
                    desc: desc,
                    icon: _iconForMilestone(m.iconName),
                  );
                }).toList()
              : [
                  _MilestoneItem(
                    year: '૧૯૭૭ / 1977',
                    badge: isGujarati ? 'સ્થાપના' : 'FOUNDATION',
                    title: context.tr('history_milestone_1977_title'),
                    desc: context.tr('history_milestone_1977_desc'),
                    icon: Icons.local_fire_department_rounded,
                  ),
                  _MilestoneItem(
                    year: '૧૯૯૦ / 1990',
                    badge: isGujarati ? 'જીવંત વાદ્ય સંગીત' : 'ACOUSTIC ORCHESTRA',
                    title: context.tr('history_milestone_1990_title'),
                    desc: context.tr('history_milestone_1990_desc'),
                    icon: Icons.music_note_rounded,
                  ),
                  _MilestoneItem(
                    year: '૨૦૦૫ / 2005',
                    badge: isGujarati ? 'પ્રાદેશિક ખ્યાતિ' : 'REGIONAL ACCLAIM',
                    title: context.tr('history_milestone_2005_title'),
                    desc: context.tr('history_milestone_2005_desc'),
                    icon: Icons.military_tech_rounded,
                  ),
                  _MilestoneItem(
                    year: '૨૦૧૮ / 2018',
                    badge: isGujarati ? 'છંદ અને દુહા' : 'CHHAND & DUHA',
                    title: context.tr('history_milestone_2018_title'),
                    desc: context.tr('history_milestone_2018_desc'),
                    icon: Icons.auto_stories_rounded,
                  ),
                  _MilestoneItem(
                    year: 'વર્તમાન / NOW',
                    badge: isGujarati ? 'ડિજિટલ સંગ્રહ' : 'DIGITAL ARCHIVE',
                    title: context.tr('history_milestone_now_title'),
                    desc: context.tr('history_milestone_now_desc'),
                    icon: Icons.cloud_done_rounded,
                  ),
                ];

          return MyAppScaffold(
            onRefresh: () async {
              await AdminDataStore.instance.reloadHistoryPage();
            },
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
                HeritageBadge(label: context.tr('history_tag')),
                const SizedBox(height: 16),
                Text(context.tr('history_title'), style: styles.h1(context)),
                const SizedBox(height: 10),
                Text(
                  context.tr('history_subtitle'),
                  style: styles
                      .bodyText(context)
                      .copyWith(
                        color: colors.getSecondaryTextColor(context),
                        fontSize: isMobile ? 14 : 16,
                      ),
                ),
                const SizedBox(height: 36),

                // Milestones Vertical Timeline List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: milestones.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final item = milestones[index];
                    if (isMobile) {
                      return CulturalFrameCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.year,
                                  style: styles.editorialSerif(
                                    context,
                                    size: 18,
                                    fontWeight: FontWeight.w700,
                                    color: colors.getAccentColor(context),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: HeritageBadge(
                                    label: item.badge,
                                    backgroundColor: colors.heritageGold
                                        .withValues(alpha: 0.12),
                                    textColor: colors.getAccentColor(context),
                                    borderColor: colors.heritageGold.withValues(
                                      alpha: 0.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  item.icon,
                                  size: 18,
                                  color: colors.heritageGold,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: styles.editorialSerif(
                                      context,
                                      size: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.desc,
                              style: styles.bodyText(context).copyWith(
                                color: colors.getSecondaryTextColor(context),
                                fontSize: 13.5,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return CulturalFrameCard(
                      padding: const EdgeInsets.all(26),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Year Pill Column
                          SizedBox(
                            width: 160,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.year,
                                  style: styles.editorialSerif(
                                    context,
                                    size: 24,
                                    fontWeight: FontWeight.w700,
                                    color: colors.getAccentColor(context),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                HeritageBadge(
                                  label: item.badge,
                                  backgroundColor: colors.heritageGold
                                      .withValues(alpha: 0.12),
                                  textColor: colors.getAccentColor(context),
                                  borderColor: colors.heritageGold.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: colors.getBorderColor(context),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                          ),

                          // Content Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 18,
                                      color: colors.heritageGold,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: styles.editorialSerif(
                                          context,
                                          size: 21,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.desc,
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const HeritageDivider(verticalPadding: 36),

                // CTA to Archive
                Center(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.heritageMaroon,
                      foregroundColor: colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () => serviceLocator<NavigationManager>()
                        .goToArchive(context),
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: Text(
                      context.tr('sec_02_cta'),
                      style: styles.cleanSans(
                        context,
                        color: colors.white,
                        size: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MilestoneItem {
  final String year;
  final String badge;
  final String title;
  final String desc;
  final IconData icon;

  const _MilestoneItem({
    required this.year,
    required this.badge,
    required this.title,
    required this.desc,
    required this.icon,
  });
}
