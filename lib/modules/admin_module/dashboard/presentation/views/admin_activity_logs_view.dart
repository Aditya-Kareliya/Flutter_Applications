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

/// Activity audit log view for tracking changes made by admins
class AdminActivityLogsView extends StatefulWidget {
  final AdminDataStore store;

  const AdminActivityLogsView({super.key, required this.store});

  @override
  State<AdminActivityLogsView> createState() => _AdminActivityLogsViewState();
}

class _AdminActivityLogsViewState extends State<AdminActivityLogsView> {
  String _actionFilter = 'All';

  void _confirmClearLogs() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Activity History?'),
        content: const Text('This will clear recent change history records. Are you sure?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.clearActivityLogs();
              Navigator.pop(ctx);
              MyAppToastMessage.info(context, title: 'History Cleared', description: 'Activity history cleared successfully.');
            },
            label: 'Clear All',
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

    final logs = _actionFilter == 'All'
        ? widget.store.activityLogs
        : widget.store.activityLogs.where((l) => l.action == _actionFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeritageBadge(label: 'SYSTEM / AUDIT LOGS'),
                const SizedBox(height: 6),
                Text(
                  'Portal Activity & Audit Trail',
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Chronological history of all modifications, updates, deletions, and publishing events.',
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
            if (widget.store.activityLogs.isNotEmpty)
              MyAppOutlineButton.icon(
                isDanger: true,
                onPressed: _confirmClearLogs,
                icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                label: 'Clear History',
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Action Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            children: [
              _buildChip('All'),
              const SizedBox(width: 8),
              _buildChip('CREATE'),
              const SizedBox(width: 8),
              _buildChip('UPDATE'),
              const SizedBox(width: 8),
              _buildChip('DELETE'),
              const SizedBox(width: 8),
              _buildChip('CONFIG'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Logs List
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 12 : 18),
          child: logs.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No activity records found.')),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final color = log.action == 'CREATE'
                        ? Colors.green
                        : (log.action == 'DELETE'
                            ? Colors.red
                            : (log.action == 'CONFIG' ? Colors.blue : colors.heritageGold));

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            log.action,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(log.details, style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600)),
                              Text(
                                '${log.module} • By ${log.user} • ${log.timestamp.toString().substring(0, 19)}',
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

  Widget _buildChip(String label) {
    final colors = serviceLocator<MyAppColors>();
    final isSelected = _actionFilter == label;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      selected: isSelected,
      selectedColor: colors.heritageGold,
      onSelected: (_) => setState(() => _actionFilter = label),
    );
  }
}
