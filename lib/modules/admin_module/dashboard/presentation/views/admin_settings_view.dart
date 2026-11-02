import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/brand_logo/brand_logo_widget.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../../auth/presentation/admin_auth_cubit.dart';
import '../../data/admin_data_store.dart';

/// Portal system settings, Global Brand Identity, QR Payments, and Account Security
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
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addrCtrl;
  late final TextEditingController _aartiCtrl;
  late final TextEditingController _youtubeCtrl;
  late final TextEditingController _instagramCtrl;
  late final TextEditingController _facebookCtrl;

  // QR Payment & Offerings Controllers
  late final TextEditingController _upiIdCtrl;
  late final TextEditingController _recipientNameCtrl;
  late final TextEditingController _paymentNotesCtrl;
  late bool _isPaymentEnabled;
  late String _paymentQrImageUrl;
  late String _logoImageUrl;

  @override
  void initState() {
    super.initState();
    final s = widget.store.settings;
    _nameEnCtrl = TextEditingController(text: s.mandalNameEn);
    _nameGuCtrl = TextEditingController(text: s.mandalNameGu);
    _phoneCtrl = TextEditingController(text: s.contactPhone);
    _whatsappCtrl = TextEditingController(text: s.whatsappNumber);
    _emailCtrl = TextEditingController(text: s.contactEmail);
    _addrCtrl = TextEditingController(text: s.address);
    _aartiCtrl = TextEditingController(text: s.dailyAartiTime);
    _youtubeCtrl = TextEditingController(text: s.youtubeChannel);
    _instagramCtrl = TextEditingController(text: s.instagramHandle);
    _facebookCtrl = TextEditingController(text: s.facebookUrl);
    _upiIdCtrl = TextEditingController(text: s.paymentUpiId);
    _recipientNameCtrl = TextEditingController(text: s.paymentRecipientName);
    _paymentNotesCtrl = TextEditingController(text: s.paymentNotes);
    _isPaymentEnabled = s.isPaymentEnabled;
    _paymentQrImageUrl = s.paymentQrImageUrl;
    _logoImageUrl = s.logoImageUrl;
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameGuCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _addrCtrl.dispose();
    _aartiCtrl.dispose();
    _youtubeCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _upiIdCtrl.dispose();
    _recipientNameCtrl.dispose();
    _paymentNotesCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final updated = widget.store.settings.copyWith(
      mandalNameEn: _nameEnCtrl.text.trim(),
      mandalNameGu: _nameGuCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim(),
      address: _addrCtrl.text.trim(),
      dailyAartiTime: _aartiCtrl.text.trim(),
      youtubeChannel: _youtubeCtrl.text.trim(),
      instagramHandle: _instagramCtrl.text.trim(),
      facebookUrl: _facebookCtrl.text.trim(),
      logoImageUrl: _logoImageUrl.trim(),
      paymentQrImageUrl: _paymentQrImageUrl.trim(),
      paymentUpiId: _upiIdCtrl.text.trim(),
      paymentRecipientName: _recipientNameCtrl.text.trim(),
      paymentNotes: _paymentNotesCtrl.text.trim(),
      isPaymentEnabled: _isPaymentEnabled,
    );
    widget.store.updateSettings(updated);

    MyAppToastMessage.success(
      context,
      title: 'Settings Saved',
      description: 'Mandal preferences, brand logo, and payment settings have been saved.',
    );
  }

  void _showChangePasswordDialog() {
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
          side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.password_rounded, color: colors.heritageGold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Change Admin Password',
                style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
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
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
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
                MyAppToastMessage.warning(context, title: 'Incomplete', description: 'Please fill in all password fields.');
                return;
              }
              if (newPass != confirmPass) {
                MyAppToastMessage.error(context, title: 'Mismatch', description: 'New password and confirmation do not match.');
                return;
              }
              if (newPass.length < 6) {
                MyAppToastMessage.warning(context, title: 'Weak Password', description: 'Password must contain at least 6 characters.');
                return;
              }

              try {
                final authCubit = context.read<AdminAuthCubit>();
                await authCubit.changePassword(
                  currentPassword: currentPass,
                  newPassword: newPass,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  MyAppToastMessage.success(
                    context,
                    title: 'Password Updated',
                    description: 'Administrator password has been changed successfully.',
                  );
                }
              } catch (e) {
                if (mounted) {
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

  void _showChangeEmailDialog() {
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
          side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
        ),
        title: Row(
          children: [
            Icon(Icons.mark_email_read_rounded, color: colors.heritageGold),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Change Admin Email',
                style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
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
                  style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
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

              if (currentPass.isEmpty || newEmail.isEmpty || !newEmail.contains('@')) {
                MyAppToastMessage.warning(context, title: 'Invalid Input', description: 'Please enter current password and a valid email address.');
                return;
              }

              try {
                final authCubit = context.read<AdminAuthCubit>();
                await authCubit.changeEmail(
                  currentPassword: currentPass,
                  newEmail: newEmail,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  MyAppToastMessage.success(
                    context,
                    title: 'Email Updated',
                    description: 'Administrator account email updated to $newEmail.',
                  );
                }
              } catch (e) {
                if (mounted) {
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

  void _sendPasswordResetForCurrentAdmin() async {
    final email = context.read<AdminAuthCubit>().currentAdminEmail;
    try {
      await context.read<AdminAuthCubit>().sendPasswordReset(email);
      if (mounted) {
        MyAppToastMessage.success(
          context,
          title: 'Reset Link Dispatched',
          description: 'A password recovery link has been sent to $email.',
        );
      }
    } catch (e) {
      if (mounted) {
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
        const AdminWebsiteContextBanner(
          websitePageTitle: 'Portal Settings & Global Configuration',
          websiteRoute: '/admin',
          explanation: 'Controls brand logo, temple contact info, social channels, verified QR payments, and administrator account security.',
        ),

        // Header Action Bar
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 12,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeritageBadge(label: 'SYSTEM / SETTINGS & CONFIGURATION'),
                const SizedBox(height: 6),
                Text(
                  'Portal Settings & Global Identity',
                  style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Manage organization defaults, brand logo, QR payments, and security credentials.',
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

        // -------------------------------------------------------------
        // SECTION 1: BRAND LOGO & VISUAL IDENTITY
        // -------------------------------------------------------------
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.palette_rounded, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Text('Brand Logo & Visual Identity', style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Updates the official mandal logo everywhere: Header, Footer, Mobile Drawer, Login Screen, and Admin Portal.',
                style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BrandLogoWidget(
                    size: 72,
                    isCircular: true,
                    border: Border.all(color: colors.heritageGold, width: 2),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyAppImagePicker(
                          label: 'Configured Brand Logo (PNG/JPG)',
                          initialImageUrl: _logoImageUrl,
                          isCircle: true,
                          height: 120,
                          onImageChanged: (url) {
                            setState(() => _logoImageUrl = url);
                          },
                          onImageRemoved: () {
                            setState(() => _logoImageUrl = 'assets/images/pavan_putra_logo.png');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -------------------------------------------------------------
        // SECTION 2: DEVOTIONAL OFFERINGS & QR PAYMENTS (SEVA / DAN)
        // -------------------------------------------------------------
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Text('Devotional Offerings & QR Payments (Seva / Dan)', style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Enables devotees and visitors to scan and offer seva to the mandal via verified UPI bank details.',
                style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.getSurfaceColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.getBorderColor(context)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable QR Payment & Seva Section on Website',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'When enabled, the verified QR code and UPI details appear on the Contact page.',
                            style: TextStyle(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.85,
                      child: Switch(
                        value: _isPaymentEnabled,
                        activeThumbColor: colors.heritageGold,
                        activeTrackColor: colors.deepMaroon,
                        onChanged: (val) => setState(() => _isPaymentEnabled = val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (_isPaymentEnabled) ...[
                if (isMobile) ...[
                  MyAppTextFormField(
                    controller: _upiIdCtrl,
                    labelText: 'Verified Mandal UPI ID (e.g. pavanputra@upi)',
                    prefixIcon: const Icon(Icons.payment_rounded),
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: _recipientNameCtrl,
                    labelText: 'Verified Recipient / Account Name (e.g. Shree Pavan Putra Garbi Mandal Trust)',
                    prefixIcon: const Icon(Icons.account_balance_rounded),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _upiIdCtrl,
                          labelText: 'Verified Mandal UPI ID (e.g. pavanputra@upi)',
                          prefixIcon: const Icon(Icons.payment_rounded),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: _recipientNameCtrl,
                          labelText: 'Verified Recipient / Account Name',
                          prefixIcon: const Icon(Icons.account_balance_rounded),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                MyAppTextFormField(
                  controller: _paymentNotesCtrl,
                  labelText: 'Payment Note / Instructions (e.g. For Navratri Garbi Mahotsav Seva)',
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
                const SizedBox(height: 16),
                Text('Upload Verified Mandal Payment QR Code:', style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                MyAppImagePicker(
                  label: 'Verified Bank / UPI QR Code Image',
                  initialImageUrl: _paymentQrImageUrl,
                  height: 180,
                  onImageChanged: (url) => setState(() => _paymentQrImageUrl = url),
                  onImageRemoved: () => setState(() => _paymentQrImageUrl = ''),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -------------------------------------------------------------
        // SECTION 3: MANDAL GENERAL DEFAULTS & CONTACTS
        // -------------------------------------------------------------
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mandal General Defaults & Contact Info', style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              if (isMobile) ...[
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
                  controller: _whatsappCtrl,
                  labelText: 'Official WhatsApp Number (with country code)',
                  prefixIcon: const Icon(Icons.chat_bubble_rounded),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _nameEnCtrl,
                        labelText: 'Organization Name (English)',
                        showTranslateIcon: true,
                        targetLanguageController: _nameGuCtrl,
                        prefixIcon: const Icon(Icons.corporate_fare_rounded),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _nameGuCtrl,
                        labelText: 'Organization Name (Gujarati)',
                        prefixIcon: const Icon(Icons.subtitles_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _phoneCtrl,
                        labelText: 'Official Phone Numbers',
                        prefixIcon: const Icon(Icons.phone_rounded),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: MyAppTextFormField(
                        controller: _whatsappCtrl,
                        labelText: 'Official WhatsApp Number (with country code)',
                        prefixIcon: const Icon(Icons.chat_bubble_rounded),
                      ),
                    ),
                  ],
                ),
              ],
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
              const SizedBox(height: 16),
              Text('Social Media Links', style: styles.cleanSans(context, size: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _youtubeCtrl,
                labelText: 'YouTube Channel URL',
                prefixIcon: const Icon(Icons.play_circle_fill_rounded),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _instagramCtrl,
                labelText: 'Instagram Handle or URL',
                prefixIcon: const Icon(Icons.camera_alt_rounded),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _facebookCtrl,
                labelText: 'Facebook Page URL',
                prefixIcon: const Icon(Icons.facebook_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -------------------------------------------------------------
        // SECTION 4: ADMIN ACCOUNT SECURITY
        // -------------------------------------------------------------
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security_rounded, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Text('Admin Account Security', style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Signed in as: $adminEmail',
                style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700, color: colors.heritageGold),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage administrator authentication credentials, password updates, and email recovery securely via Firebase Authentication.',
                style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  MyAppOutlineButton.icon(
                    onPressed: _showChangePasswordDialog,
                    icon: const Icon(Icons.lock_reset_rounded, size: 16),
                    label: 'Change Password',
                  ),
                  MyAppOutlineButton.icon(
                    onPressed: _showChangeEmailDialog,
                    icon: const Icon(Icons.email_outlined, size: 16),
                    label: 'Change Admin Email',
                  ),
                  MyAppOutlineButton.icon(
                    onPressed: _sendPasswordResetForCurrentAdmin,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: 'Send Reset Link to Email',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -------------------------------------------------------------
        // SECTION 5: CLOUD FIRESTORE STATUS & CONTENT SYNC
        // -------------------------------------------------------------
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud_done_rounded, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Text('Cloud Firestore & Live Content Sync', style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700)),
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

        // -------------------------------------------------------------
        // SECTION 6: ADMIN SESSION LOGOUT
        // -------------------------------------------------------------
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
                    Text('Signed in as $adminEmail', style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context))),
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
