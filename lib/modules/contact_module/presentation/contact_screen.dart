import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/localization/my_app_translations.dart';
import '../../../core/my_app_colors/my_app_colors.dart';
import '../../../core/my_app_scaffold/my_app_scaffold.dart';
import '../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../core/widgets/brand_logo/brand_logo_widget.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/heritage_badge.dart';
import '../../../core/widgets/text_fields/my_app_text_area_field.dart';
import '../../../core/widgets/text_fields/my_app_text_form_field.dart';
import '../../../core/widgets/toast/my_app_toast_message.dart';
import '../../admin_module/dashboard/data/admin_data_store.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitted = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      try {
        final now = DateTime.now();
        final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final enquiry = AdminEnquiry(
          id: 'enq-${now.millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          message: _messageController.text.trim(),
          date: dateStr,
          status: 'New',
        );

        AdminDataStore.instance.addEnquiry(enquiry);

        _nameController.clear();
        _phoneController.clear();
        _emailController.clear();
        _messageController.clear();

        if (mounted) {
          setState(() {
            _isSubmitted = true;
            _isSubmitting = false;
          });
          MyAppToastMessage.success(
            context,
            title: 'Pranam! Message Received',
            description: context.tr('form_success'),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          MyAppToastMessage.error(
            context,
            title: 'Submission Failed',
            description: 'Could not send message. Please try again or call our helpline.',
          );
        }
      }
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Launch URL error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final colors = serviceLocator<MyAppColors>();
        final styles = serviceLocator<MyAppTextStyles>();
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isMobile = screenWidth < 880;
        final settings = AdminDataStore.instance.settings;

        return MyAppScaffold(
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
                    HeritageBadge(label: context.tr('contact_tag')),
                    const SizedBox(height: 16),
                    Text(context.tr('contact_title'), style: styles.h1(context)),
                    const SizedBox(height: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Text(
                        context.tr('contact_desc'),
                        style: styles.bodyText(context).copyWith(fontSize: isMobile ? 14 : 16),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Main Content (2-Column or Stack on Mobile)
                    if (isMobile) ...[
                      _buildMandalInfoCard(colors, styles, settings),
                      if (settings.isPaymentEnabled) ...[
                        const SizedBox(height: 24),
                        _buildPaymentQrCard(colors, styles, settings, isMobile),
                      ],
                      const SizedBox(height: 24),
                      _buildInquiryForm(colors, styles),
                    ] else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _buildMandalInfoCard(colors, styles, settings),
                                if (settings.isPaymentEnabled) ...[
                                  const SizedBox(height: 28),
                                  _buildPaymentQrCard(colors, styles, settings, isMobile),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 6,
                            child: _buildInquiryForm(colors, styles),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMandalInfoCard(MyAppColors colors, MyAppTextStyles styles, AdminSettings settings) {
    final address = settings.address.isNotEmpty ? settings.address : context.tr('contact_address');
    final phone = settings.contactPhone.isNotEmpty ? settings.contactPhone : context.tr('contact_phone');
    final email = settings.contactEmail.isNotEmpty ? settings.contactEmail : context.tr('contact_email');
    final aarti = settings.dailyAartiTime.isNotEmpty ? settings.dailyAartiTime : context.tr('contact_hours');
    final whatsapp = settings.whatsappNumber;

    return CulturalFrameCard(
      padding: const EdgeInsets.all(28),
      backgroundColor: colors.deepMaroon,
      borderColor: colors.heritageGold.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              BrandLogoWidget(
                size: 52,
                isCircular: true,
                border: Border.all(color: colors.heritageGold, width: 1.5),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.mandalNameEn.isNotEmpty ? settings.mandalNameEn : context.tr('app_title'),
                      style: styles.editorialSerif(
                        context,
                        size: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.white,
                      ),
                    ),
                    Text(
                      settings.mandalNameGu.isNotEmpty ? settings.mandalNameGu : context.tr('app_subtitle'),
                      style: styles.cleanSans(
                        context,
                        size: 12.5,
                        fontWeight: FontWeight.w700,
                        color: colors.lightGold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _ContactDetailRow(
            icon: Icons.location_on_rounded,
            label: context.tr('contact_address_label'),
            value: address,
            colors: colors,
            styles: styles,
            onTap: () => _launchExternalUrl('https://maps.google.com/?q=${Uri.encodeComponent(address)}'),
            actionTooltip: 'Open in Google Maps',
          ),
          const SizedBox(height: 18),
          _ContactDetailRow(
            icon: Icons.phone_rounded,
            label: context.tr('contact_phone_label'),
            value: phone,
            colors: colors,
            styles: styles,
            onTap: () => _launchExternalUrl('tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}'),
            actionTooltip: 'Call Helpline',
          ),
          if (whatsapp.isNotEmpty) ...[
            const SizedBox(height: 18),
            _ContactDetailRow(
              icon: Icons.chat_bubble_rounded,
              label: 'WhatsApp Helpline',
              value: whatsapp,
              colors: colors,
              styles: styles,
              onTap: () => _launchExternalUrl('https://wa.me/${whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}'),
              actionTooltip: 'Chat on WhatsApp',
            ),
          ],
          const SizedBox(height: 18),
          _ContactDetailRow(
            icon: Icons.email_rounded,
            label: context.tr('contact_email_label'),
            value: email,
            colors: colors,
            styles: styles,
            onTap: () => _launchExternalUrl('mailto:$email'),
            actionTooltip: 'Send Email',
          ),
          const SizedBox(height: 18),
          _ContactDetailRow(
            icon: Icons.access_time_rounded,
            label: context.tr('contact_hours_label'),
            value: aarti,
            colors: colors,
            styles: styles,
          ),
          const SizedBox(height: 24),
          Text(
            '|| જાગતી જોગમાયા || || જય માતાજી ||',
            style: styles.devotionalMotto(
              context,
              size: 18,
              color: colors.lightGold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentQrCard(MyAppColors colors, MyAppTextStyles styles, AdminSettings settings, bool isMobile) {
    final upiId = settings.paymentUpiId;
    final recipient = settings.paymentRecipientName.isNotEmpty ? settings.paymentRecipientName : 'Shree Pavan Putra Garbi Mandal Trust';
    final notes = settings.paymentNotes.isNotEmpty ? settings.paymentNotes : 'Direct Mandir Seva & Navratri Mahotsav Offerings';
    final hasQrImage = settings.paymentQrImageUrl.isNotEmpty;

    return CulturalFrameCard(
      padding: const EdgeInsets.all(24),
      backgroundColor: colors.getCardBackgroundColor(context),
      borderColor: colors.heritageGold.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.heritageGold.withValues(alpha: 0.15),
                ),
                child: Icon(Icons.qr_code_scanner_rounded, color: colors.heritageGold, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Devotional Offerings / Garbi Seva & Dan',
                      style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Scan with Google Pay, PhonePe, Paytm, or BHIM UPI',
                      style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          if (hasQrImage)
            Center(
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: settings.paymentQrImageUrl,
                              width: 320,
                              fit: BoxFit.contain,
                              placeholder: (_, _) => const SizedBox(
                                width: 200,
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (_, _, _) => const Icon(Icons.error_outline, size: 60),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: colors.heritageMaroon),
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: settings.paymentQrImageUrl,
                        width: isMobile ? 180 : 200,
                        height: isMobile ? 180 : 200,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => SizedBox(
                          width: isMobile ? 180 : 200,
                          height: isMobile ? 180 : 200,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        errorWidget: (_, _, _) => Container(
                          width: 180,
                          height: 180,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.qr_code, size: 64, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap to enlarge QR code',
                        style: styles.cleanSans(context, size: 10.5, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.getBorderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Beneficiary: $recipient',
                  style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700),
                ),
                if (upiId.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'UPI ID: $upiId',
                          style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w600, color: colors.heritageGold),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Copy UPI ID',
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: upiId));
                          MyAppToastMessage.info(context, title: 'UPI ID Copied', description: '$upiId copied to clipboard.');
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  notes,
                  style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Important: All contributions directly support Shree Pavan Putra Garbi Mandal activities. No middle party involved.',
            style: styles.cleanSans(context, size: 11, color: colors.getMutedTextColor(context)).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryForm(MyAppColors colors, MyAppTextStyles styles) {
    return CulturalFrameCard(
      padding: const EdgeInsets.all(28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('contact_form_title'),
              style: styles.editorialSerif(
                context,
                size: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            MyAppTextFormField(
              controller: _nameController,
              labelText: context.tr('form_name'),
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              validator: (val) {
                if (val == null || val.trim().length < 2) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            MyAppTextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              labelText: context.tr('form_phone'),
              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter your mobile phone number';
                }
                final cleaned = val.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleaned.length < 10) {
                  return 'Please enter a valid 10-digit mobile number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            MyAppTextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              labelText: context.tr('form_email'),
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              validator: (val) {
                if (val != null && val.trim().isNotEmpty && !val.contains('@')) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            MyAppTextAreaField(
              controller: _messageController,
              labelText: context.tr('form_message'),
              hintText: 'Write your message, blessings, or seva inquiry...',
              minLines: 3,
              validator: (val) {
                if (val == null || val.trim().length < 4) {
                  return 'Please write your message or enquiry';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.heritageMaroon,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isSubmitted ? '✓ MESSAGE RECEIVED' : context.tr('form_submit'),
                        style: styles.cleanSans(
                          context,
                          color: colors.white,
                          size: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final MyAppColors colors;
  final MyAppTextStyles styles;
  final VoidCallback? onTap;
  final String? actionTooltip;

  const _ContactDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.styles,
    this.onTap,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.lightGold, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: styles.cleanSans(
                  context,
                  size: 11,
                  fontWeight: FontWeight.w700,
                  color: colors.lightGold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: styles.bodyText(context).copyWith(
                      color: const Color(0xFFE2DDD1),
                      fontSize: 13.5,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(Icons.arrow_outward_rounded, size: 16, color: colors.lightGold.withValues(alpha: 0.8)),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }

    return content;
  }
}
