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
import '../../../core/widgets/buttons/my_app_buttons.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/dialogs/my_app_dialog.dart';
import '../../../core/widgets/heritage_badge.dart';
import '../../../core/widgets/text_fields/my_app_text_area_field.dart';
import '../../../core/widgets/text_fields/my_app_text_form_field.dart';
import '../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../core/services/email_notification_service.dart';
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

        // Send real email notification to all configured admin recipients
        EmailNotificationService.instance.sendEnquiryNotification(
          enquiry: enquiry,
          recipients: AdminDataStore.instance.notificationEmails,
          fallbackEmail: AdminDataStore.instance.settings.contactEmail,
        );

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
          onRefresh: () async {
            await AdminDataStore.instance.reloadContactPage();
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
                      const SizedBox(height: 24),
                      _buildInquiryForm(colors, styles),
                      if (settings.isPaymentEnabled) ...[
                        const SizedBox(height: 24),
                        _buildPaymentQrCard(colors, styles, settings, isMobile),
                      ],
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildMandalInfoCard(colors, styles, settings),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 6,
                            child: _buildInquiryForm(colors, styles),
                          ),
                        ],
                      ),
                      if (settings.isPaymentEnabled) ...[
                        const SizedBox(height: 36),
                        _buildPaymentQrCard(colors, styles, settings, isMobile),
                      ],
                    ],
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
    final isGu = (Localizations.maybeLocaleOf(context)?.languageCode ?? 'en') == 'gu';
    final address = isGu && settings.addressGu.trim().isNotEmpty
        ? settings.addressGu.trim()
        : (settings.address.isNotEmpty ? settings.address : context.tr('contact_address'));
    final phone = settings.contactPhone.isNotEmpty ? settings.contactPhone : context.tr('contact_phone');
    final email = settings.contactEmail.isNotEmpty ? settings.contactEmail : context.tr('contact_email');
    final aarti = isGu && settings.dailyAartiTimeGu.trim().isNotEmpty
        ? settings.dailyAartiTimeGu.trim()
        : (settings.dailyAartiTime.isNotEmpty ? settings.dailyAartiTime : context.tr('contact_hours'));
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
            actionTooltip: context.tr('tooltip_maps'),
          ),
          const SizedBox(height: 18),
          _ContactDetailRow(
            icon: Icons.phone_rounded,
            label: context.tr('contact_phone_label'),
            value: phone,
            colors: colors,
            styles: styles,
            onTap: () => _launchExternalUrl('tel:${phone.replaceAll(RegExp(r'[^0-9+]'), '')}'),
            actionTooltip: context.tr('tooltip_call'),
          ),
          if (whatsapp.isNotEmpty) ...[
            const SizedBox(height: 18),
            _ContactDetailRow(
              icon: Icons.chat_bubble_rounded,
              label: context.tr('contact_whatsapp_label'),
              value: whatsapp,
              colors: colors,
              styles: styles,
              onTap: () => _launchExternalUrl('https://wa.me/${whatsapp.replaceAll(RegExp(r'[^0-9]'), '')}'),
              actionTooltip: context.tr('tooltip_whatsapp'),
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
            actionTooltip: context.tr('tooltip_email'),
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

  Widget _buildPaymentQrCard(
    MyAppColors colors,
    MyAppTextStyles styles,
    AdminSettings settings,
    bool isMobile,
  ) {
    final isGu = (Localizations.maybeLocaleOf(context)?.languageCode ?? 'en') == 'gu';
    final upiId = settings.paymentUpiId.isNotEmpty ? settings.paymentUpiId : 'pavanputragarbi@upi';
    final recipient = isGu && settings.paymentRecipientNameGu.trim().isNotEmpty
        ? settings.paymentRecipientNameGu.trim()
        : (settings.paymentRecipientName.trim().isNotEmpty
            ? settings.paymentRecipientName.trim()
            : (isGu ? 'શ્રી પવનપુત્ર ગરબી મંડળ ટ્રસ્ટ' : 'Shree Pavan Putra Garbi Mandal Trust'));
    final notes = isGu && settings.paymentNotesGu.trim().isNotEmpty
        ? settings.paymentNotesGu.trim()
        : (settings.paymentNotes.trim().isNotEmpty
            ? settings.paymentNotes.trim()
            : (isGu ? 'નવરાત્રિ મહોત્સવ અને માતાજીની દૈનિક સેવા-પૂજા માટે' : 'Direct Mandir Seva & Navratri Mahotsav Offerings'));

    return CulturalFrameCard(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      backgroundColor: colors.getCardBackgroundColor(context),
      borderColor: colors.heritageGold.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar (Responsive Layout to prevent any right overflow)
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isWide = headerConstraints.maxWidth > 580;

              final titleContent = Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.heritageGold.withValues(alpha: 0.15),
                    ),
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: colors.heritageGold,
                      size: isMobile ? 22 : 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('payment_title'),
                          style: styles.editorialSerif(
                            context,
                            size: isMobile ? 15.5 : 18.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('payment_subtitle'),
                          style: styles.cleanSans(
                            context,
                            size: 11,
                            color: colors.getSecondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final badge = HeritageBadge(
                label: context.tr('payment_badge'),
                backgroundColor: colors.heritageGold.withValues(alpha: 0.15),
                textColor: colors.lightGold,
                borderColor: colors.heritageGold.withValues(alpha: 0.4),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: titleContent),
                    const SizedBox(width: 12),
                    badge,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleContent,
                  const SizedBox(height: 10),
                  badge,
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: colors.heritageGold.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 22),

          // Responsive Content Body: 2-column on desktop, centered column on mobile
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildQrImageBox(settings, colors, styles, isMobile: true),
                const SizedBox(height: 20),
                _buildPaymentDetailsContent(
                  settings,
                  recipient,
                  upiId,
                  notes,
                  colors,
                  styles,
                  isMobile: true,
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQrImageBox(settings, colors, styles, isMobile: false),
                const SizedBox(width: 32),
                Expanded(
                  child: _buildPaymentDetailsContent(
                    settings,
                    recipient,
                    upiId,
                    notes,
                    colors,
                    styles,
                    isMobile: false,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQrImageBox(
    AdminSettings settings,
    MyAppColors colors,
    MyAppTextStyles styles, {
    required bool isMobile,
  }) {
    final isGu = (Localizations.maybeLocaleOf(context)?.languageCode ?? 'en') == 'gu';
    final hasQrImage = settings.paymentQrImageUrl.trim().isNotEmpty;
    final imageSize = isMobile ? 170.0 : 195.0;

    return Center(
      child: InkWell(
        onTap: () => _openEnlargedQrDialog(settings, colors, styles),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.heritageGold.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasQrImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: settings.paymentQrImageUrl,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: imageSize,
                      height: imageSize,
                      color: Colors.grey.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2_rounded,
                            size: 52,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isGu ? 'UPI એપ દ્વારા સ્કેન' : 'Scan with UPI App',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: imageSize,
                  height: imageSize,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 56,
                        color: colors.heritageMaroon,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isGu ? 'સીધી UPI સેવા' : 'Direct UPI Seva',
                        style: styles.cleanSans(
                          context,
                          size: 12,
                          fontWeight: FontWeight.w700,
                          color: colors.heritageMaroon,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.zoom_in_rounded,
                    size: 15,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.tr('payment_tap_enlarge'),
                    style: styles.cleanSans(
                      context,
                      size: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEnlargedQrDialog(
    AdminSettings settings,
    MyAppColors colors,
    MyAppTextStyles styles,
  ) {
    final isGu = (Localizations.maybeLocaleOf(context)?.languageCode ?? 'en') == 'gu';
    final upiId = settings.paymentUpiId.isNotEmpty ? settings.paymentUpiId : 'pavanputragarbi@upi';
    final recipient = isGu && settings.paymentRecipientNameGu.trim().isNotEmpty
        ? settings.paymentRecipientNameGu.trim()
        : (settings.paymentRecipientName.isNotEmpty
            ? settings.paymentRecipientName
            : (isGu ? 'શ્રી પવનપુત્ર ગરબી મંડળ ટ્રસ્ટ' : 'Shree Pavan Putra Garbi Mandal Trust'));
    final isMobile = MediaQuery.sizeOf(context).width < 500;

    showMyAppDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 24,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: colors.getCardBackgroundColor(context),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colors.heritageGold.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      color: colors.heritageGold,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('payment_modal_title'),
                        style: styles.editorialSerif(
                          context,
                          size: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.heritageGold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: settings.paymentQrImageUrl,
                    width: isMobile ? 240 : 280,
                    height: isMobile ? 240 : 280,
                    fit: BoxFit.contain,
                    placeholder: (_, _) => SizedBox(
                      width: isMobile ? 240 : 280,
                      height: isMobile ? 240 : 280,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, _, _) => SizedBox(
                      width: isMobile ? 240 : 280,
                      height: isMobile ? 240 : 280,
                      child: const Center(
                        child: Icon(Icons.qr_code, size: 80, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  recipient,
                  textAlign: TextAlign.center,
                  style: styles.cleanSans(
                    context,
                    size: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (upiId.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SelectableText(
                    'UPI ID: $upiId',
                    textAlign: TextAlign.center,
                    style: styles.cleanSans(
                      context,
                      size: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.heritageGold,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (upiId.isNotEmpty)
                      MyAppOutlineButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: context.tr('payment_copy_btn'),
                        color: colors.heritageGold,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: upiId));
                          MyAppToastMessage.success(
                            context,
                            title: context.tr('payment_copied_toast'),
                            description: '$upiId ${context.tr("payment_copied_desc")}',
                          );
                        },
                      ),
                    MyAppFillButton.icon(
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: context.tr('payment_done_btn'),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsContent(
    AdminSettings settings,
    String recipient,
    String upiId,
    String notes,
    MyAppColors colors,
    MyAppTextStyles styles, {
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Beneficiary Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colors.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.getBorderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    size: 18,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('payment_beneficiary_label'),
                      style: styles.cleanSans(
                        context,
                        size: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4CAF50),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SelectableText(
                recipient,
                style: styles.editorialSerif(
                  context,
                  size: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.getPrimaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Direct UPI ID Row with Copy button (Responsive layout)
        if (upiId.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.heritageGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.heritageGold.withValues(alpha: 0.4),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, upiConstraints) {
                final isTight = upiConstraints.maxWidth < 380;

                final upiInfo = Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 18,
                      color: colors.heritageGold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('payment_upi_label'),
                            style: styles.cleanSans(
                              context,
                              size: 10,
                              fontWeight: FontWeight.w700,
                              color: colors.heritageGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SelectableText(
                            upiId,
                            style: styles.cleanSans(
                              context,
                              size: 13.5,
                              fontWeight: FontWeight.w700,
                              color: colors.getPrimaryTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                final copyBtn = MyAppOutlineButton.icon(
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: context.tr('payment_copy_btn'),
                  color: colors.heritageGold,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: upiId));
                    MyAppToastMessage.success(
                      context,
                      title: context.tr('payment_copied_toast'),
                      description: '$upiId ${context.tr("payment_copied_desc")}',
                    );
                  },
                );

                if (isTight) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      upiInfo,
                      const SizedBox(height: 8),
                      copyBtn,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: upiInfo),
                    const SizedBox(width: 10),
                    copyBtn,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Accepted UPI Apps Chips
        Text(
          context.tr('payment_accepted_apps'),
          style: styles.cleanSans(
            context,
            size: 10.5,
            fontWeight: FontWeight.w700,
            color: colors.getSecondaryTextColor(context),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _buildAppChip('Google Pay', const Color(0xFF4285F4), colors, styles),
            _buildAppChip('PhonePe', const Color(0xFF5F259F), colors, styles),
            _buildAppChip('Paytm', const Color(0xFF00BAF2), colors, styles),
            _buildAppChip('BHIM UPI', const Color(0xFF00897B), colors, styles),
          ],
        ),
        const SizedBox(height: 14),

        // Purpose / Seva Note Box
        if (notes.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.isDarkMode(context)
                  ? const Color(0xFF1E0E12)
                  : const Color(0xFFF7F2E9),
              borderRadius: BorderRadius.circular(10),
              border: Border(
                left: BorderSide(color: colors.heritageGold, width: 3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.volunteer_activism_rounded,
                  size: 16,
                  color: colors.heritageGold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notes,
                    style: styles.cleanSans(
                      context,
                      size: 12,
                      height: 1.4,
                      color: colors.getPrimaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // Transparency Devotional Pledge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.shield_outlined,
              size: 14,
              color: colors.getMutedTextColor(context),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                context.tr('payment_pledge'),
                style: styles.cleanSans(
                  context,
                  size: 11,
                  color: colors.getMutedTextColor(context),
                ).copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAppChip(
    String name,
    Color dotColor,
    MyAppColors colors,
    MyAppTextStyles styles,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.heritageGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: styles.cleanSans(
              context,
              size: 11,
              fontWeight: FontWeight.w600,
              color: colors.getPrimaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryForm(MyAppColors colors, MyAppTextStyles styles) {
    final isGu = (Localizations.maybeLocaleOf(context)?.languageCode ?? 'en') == 'gu';

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
                  return isGu ? 'કૃપા કરી તમારું પૂરું નામ લખો' : 'Please enter your full name';
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
                  return isGu ? 'કૃપા કરી તમારો મોબાઇલ નંબર લખો' : 'Please enter your mobile phone number';
                }
                final cleaned = val.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleaned.length < 10) {
                  return isGu ? 'કૃપા કરી માન્ય ૧૦ આંકડાનો મોબાઇલ નંબર લખો' : 'Please enter a valid 10-digit mobile number';
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
                  return isGu ? 'કૃપા કરી માન્ય ઈમેઇલ એડ્રેસ લખો' : 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            MyAppTextAreaField(
              controller: _messageController,
              labelText: context.tr('form_message'),
              hintText: context.tr('form_message_hint'),
              minLines: 3,
              validator: (val) {
                if (val == null || val.trim().length < 4) {
                  return isGu ? 'કૃપા કરી તમારો સંદેશ અથવા વિગત લખો' : 'Please write your message or enquiry';
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
