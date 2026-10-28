import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../../auth/presentation/admin_auth_cubit.dart';
import '../../data/admin_data_store.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Portal system settings and Firestore synchronization view
class AdminSettingsView extends StatefulWidget {
  final AdminDataStore store;

  const AdminSettingsView({super.key, required this.store});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _nameGuCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _aartiCtrl;

  @override
  void initState() {
    super.initState();
    final s = widget.store.settings;
    _nameEnCtrl = TextEditingController(text: s.mandalNameEn);
    _nameGuCtrl = TextEditingController(text: s.mandalNameGu);
    _phoneCtrl = TextEditingController(text: s.contactPhone);
    _emailCtrl = TextEditingController(text: s.contactEmail);
    _addrCtrl = TextEditingController(text: s.address);
    _aartiCtrl = TextEditingController(text: s.dailyAartiTime);
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameGuCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addrCtrl.dispose();
    _aartiCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final updated = widget.store.settings.copyWith(
      mandalNameEn: _nameEnCtrl.text.trim(),
      mandalNameGu: _nameGuCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim(),
      address: _addrCtrl.text.trim(),
      dailyAartiTime: _aartiCtrl.text.trim(),
    );
    widget.store.updateSettings(updated);

    MyAppToastMessage.success(
      context,
      title: 'Settings Saved',
      description: 'Mandal portal preferences and defaults have been updated.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = context.isMobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeritageBadge(label: 'SYSTEM / SETTINGS & SYNC'),
                const SizedBox(height: 6),
                Text(
                  'Portal Settings & Cloud Storage',
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'General parameters, cloud backup synchronization, and session management.',
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
            MyAppFillButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: 'Save Settings',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // CLOUD FIRESTORE STATUS & SYNC
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_done_rounded, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Text(
                    'Online Storage & Live Updates',
                    style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Online Backup: ACTIVE  •  Live Website: CONNECTED',
                style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600, color: colors.heritageGold),
              ),
              const SizedBox(height: 4),
              Text(
                'All website content, photo albums, videos, milestones, and blogs automatically save online with secure backup support.',
                style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  MyAppFillButton.icon(
                    onPressed: () {
                      widget.store.syncAllToFirestore();
                      MyAppToastMessage.success(
                        context,
                        title: 'Website Content Saved',
                        description: 'All website content and updates saved successfully.',
                      );
                    },
                    icon: const Icon(Icons.cloud_sync_rounded, size: 18),
                    label: 'Save & Publish All Website Content',
                  ),
                  MyAppOutlineButton.icon(
                    onPressed: () {
                      showMyAppDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Restore Original Content?'),
                          content: const Text(
                            'This will restore all original default mandal content, milestones, committee trustees, and gallery items. Any custom edits will be reset to original defaults.',
                          ),
                          actions: [
                            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
                            MyAppFillButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                widget.store.restoreDatabaseDefaults();
                                MyAppToastMessage.success(
                                  context,
                                  title: 'Content Restored',
                                  description: 'Original website content restored successfully.',
                                );
                              },
                              label: 'Confirm Restore',
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.restore_rounded, size: 18),
                    label: 'Restore Original Website Content',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // MANDAL PREFERENCES
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mandal General Defaults', style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              MyAppTextFormField(
                controller: _nameEnCtrl,
                labelText: 'Organization Name (English)',
                showTranslateIcon: true,
                targetLanguageController: _nameGuCtrl,
                prefixIcon: const Icon(Icons.corporate_fare_rounded),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _nameGuCtrl,
                labelText: 'Organization Name (Gujarati)',
                prefixIcon: const Icon(Icons.subtitles_outlined),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _phoneCtrl,
                labelText: 'Official Phone Numbers',
                prefixIcon: const Icon(Icons.phone_rounded),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _emailCtrl,
                labelText: 'Contact Email',
                prefixIcon: const Icon(Icons.email_rounded),
              ),
              const SizedBox(height: 12),
              MyAppTextAreaField(
                controller: _addrCtrl,
                labelText: 'Full Address',
                hintText: 'Full mandal address',
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _aartiCtrl,
                labelText: 'Default Aarti Timing',
                prefixIcon: const Icon(Icons.schedule_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ADMIN SESSION LOGOUT
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin Session', style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700)),
                    Text('Signed in as Mandal Administrator', style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context))),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MyAppOutlineButton.icon(
                isDanger: true,
                onPressed: () {
                  context.read<AdminAuthCubit>().signOut();
                  MyAppToastMessage.info(context, title: 'Signed Out', description: 'Admin session closed.');
                },
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: 'Sign Out',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
