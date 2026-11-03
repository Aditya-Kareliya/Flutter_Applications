import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

/// Admin Settings & Account Security Screen
/// Exclusively dedicated to Administrator Authentication & Account Security via Firebase Authentication.
class AdminSettingsView extends StatelessWidget {
  final AdminDataStore? store;

  const AdminSettingsView({super.key, this.store});

  void _showChangePasswordDialog(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: colors.heritageGold.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.password_rounded, color: colors.heritageGold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Change Admin Password',
                style: styles.editorialSerif(
                  context,
                  size: 20,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify current authentication credentials to update administrator password securely.',
                  style: styles.cleanSans(
                    context,
                    size: 12.5,
                    color: colors.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                MyAppTextFormField(
                  controller: currentPassCtrl,
                  labelText: 'Current Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_clock_outlined),
                ),
                const SizedBox(height: 12),
                MyAppTextFormField(
                  controller: newPassCtrl,
                  labelText: 'New Password (min 6 chars)',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                ),
                const SizedBox(height: 12),
                MyAppTextFormField(
                  controller: confirmPassCtrl,
                  labelText: 'Confirm New Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                ),
              ],
            ),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            onPressed: () async {
              final currentPass = currentPassCtrl.text;
              final newPass = newPassCtrl.text;
              final confirmPass = confirmPassCtrl.text;

              if (currentPass.isEmpty || newPass.isEmpty) {
                MyAppToastMessage.warning(
                  context,
                  title: 'Incomplete',
                  description: 'Please fill in all password fields.',
                );
                return;
              }
              if (newPass != confirmPass) {
                MyAppToastMessage.error(
                  context,
                  title: 'Mismatch',
                  description: 'New password and confirmation do not match.',
                );
                return;
              }
              if (newPass.length < 6) {
                MyAppToastMessage.warning(
                  context,
                  title: 'Weak Password',
                  description: 'Password must contain at least 6 characters.',
                );
                return;
              }

              try {
                final authCubit = context.read<AdminAuthCubit>();
                await authCubit.changePassword(
                  currentPassword: currentPass,
                  newPassword: newPass,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  MyAppToastMessage.success(
                    context,
                    title: 'Password Updated',
                    description:
                        'Administrator password has been changed successfully.',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  MyAppToastMessage.error(
                    context,
                    title: 'Password Change Failed',
                    description: '$e',
                  );
                }
              }
            },
            label: 'Update Password',
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final currentPassCtrl = TextEditingController();
    final newEmailCtrl = TextEditingController();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: colors.heritageGold.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.mark_email_read_rounded, color: colors.heritageGold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Change Admin Email',
                style: styles.editorialSerif(
                  context,
                  size: 20,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter current administrator password and your new email address. Your administrator email will be updated immediately without requiring OTP verification.',
                  style: styles.cleanSans(
                    context,
                    size: 12.5,
                    color: colors.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 16),
                MyAppTextFormField(
                  controller: currentPassCtrl,
                  labelText: 'Current Administrator Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                const SizedBox(height: 12),
                MyAppTextFormField(
                  controller: newEmailCtrl,
                  labelText: 'New Administrator Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                ),
              ],
            ),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            onPressed: () async {
              final currentPass = currentPassCtrl.text;
              final newEmail = newEmailCtrl.text.trim();

              if (currentPass.isEmpty ||
                  newEmail.isEmpty ||
                  !newEmail.contains('@')) {
                MyAppToastMessage.warning(
                  context,
                  title: 'Invalid Input',
                  description:
                      'Please enter current password and a valid email address.',
                );
                return;
              }

              try {
                final authCubit = context.read<AdminAuthCubit>();
                await authCubit.changeEmail(
                  currentPassword: currentPass,
                  newEmail: newEmail,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  MyAppToastMessage.success(
                    context,
                    title: 'Email Updated',
                    description:
                        'Administrator account email updated to $newEmail.',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  final msg = e.toString().replaceFirst('Exception: ', '');
                  MyAppToastMessage.error(
                    context,
                    title: 'Email Update Failed',
                    description: msg,
                  );
                }
              }
            },
            label: 'Change Email',
          ),
        ],
      ),
    );
  }

  void _sendPasswordResetForCurrentAdmin(BuildContext context) async {
    final email = context.read<AdminAuthCubit>().currentAdminEmail;
    try {
      await context.read<AdminAuthCubit>().sendPasswordReset(email);
      if (context.mounted) {
        MyAppToastMessage.success(
          context,
          title: 'Reset Link Dispatched',
          description: 'A password recovery link has been sent to $email.',
        );
      }
    } catch (e) {
      if (context.mounted) {
        MyAppToastMessage.error(
          context,
          title: 'Reset Failed',
          description: '$e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = context.isMobile;
    final adminEmail = context.watch<AdminAuthCubit>().currentAdminEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeritageBadge(label: 'ADMINISTRATOR / ACCOUNT SECURITY'),
            const SizedBox(height: 6),
            Text(
              'Admin Settings',
              style: styles.editorialSerif(
                context,
                size: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Manage administrator authentication credentials, password updates, and account security.',
              style: styles.cleanSans(
                context,
                size: 12.5,
                color: colors.getSecondaryTextColor(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // -------------------------------------------------------------
        // ADMIN ACCOUNT SECURITY CARD
        // -------------------------------------------------------------
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shield_rounded,
                    color: colors.heritageGold,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Admin Account Security',
                    style: styles.editorialSerif(
                      context,
                      size: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Signed in as: $adminEmail',
                style: styles.cleanSans(
                  context,
                  size: 13,
                  fontWeight: FontWeight.w700,
                  color: colors.heritageGold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage administrator authentication credentials, password updates, and email recovery securely via Firebase Authentication.',
                style: styles.cleanSans(
                  context,
                  size: 12.5,
                  color: colors.getSecondaryTextColor(context),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  MyAppOutlineButton.icon(
                    onPressed: () => _showChangePasswordDialog(context),
                    icon: const Icon(Icons.history_rounded, size: 16),
                    label: 'Change Password',
                  ),
                  MyAppOutlineButton.icon(
                    onPressed: () => _showChangeEmailDialog(context),
                    icon: const Icon(Icons.email_outlined, size: 16),
                    label: 'Change Admin Email',
                  ),
                  MyAppOutlineButton.icon(
                    onPressed: () => _sendPasswordResetForCurrentAdmin(context),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: 'Send Reset Link to Email',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
