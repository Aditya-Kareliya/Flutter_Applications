import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Full CRUD management view for Contact info and Devotee Enquiries Inbox
class AdminContactPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminContactPageView({super.key, required this.store});

  @override
  State<AdminContactPageView> createState() => _AdminContactPageViewState();
}

class _AdminContactPageViewState extends State<AdminContactPageView> {
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _aartiTimeCtrl;

  // QR Payment & Offerings Controllers
  late final TextEditingController _upiIdCtrl;
  late final TextEditingController _recipientNameCtrl;
  late final TextEditingController _paymentNotesCtrl;
  late bool _isPaymentEnabled;
  late String _paymentQrImageUrl;

  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    final s = widget.store.settings;
    _addressCtrl = TextEditingController(text: s.address);
    _phoneCtrl = TextEditingController(text: s.contactPhone);
    _whatsappCtrl = TextEditingController(text: s.whatsappNumber);
    _emailCtrl = TextEditingController(text: s.contactEmail);
    _aartiTimeCtrl = TextEditingController(text: s.dailyAartiTime);

    _upiIdCtrl = TextEditingController(text: s.paymentUpiId);
    _recipientNameCtrl = TextEditingController(text: s.paymentRecipientName);
    _paymentNotesCtrl = TextEditingController(text: s.paymentNotes);
    _isPaymentEnabled = s.isPaymentEnabled;
    _paymentQrImageUrl = s.paymentQrImageUrl;
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _aartiTimeCtrl.dispose();
    _upiIdCtrl.dispose();
    _recipientNameCtrl.dispose();
    _paymentNotesCtrl.dispose();
    super.dispose();
  }

  void _saveContactInfo() {
    final updated = widget.store.settings.copyWith(
      address: _addressCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim(),
      dailyAartiTime: _aartiTimeCtrl.text.trim(),
      paymentQrImageUrl: _paymentQrImageUrl.trim(),
      paymentUpiId: _upiIdCtrl.text.trim(),
      paymentRecipientName: _recipientNameCtrl.text.trim(),
      paymentNotes: _paymentNotesCtrl.text.trim(),
      isPaymentEnabled: _isPaymentEnabled,
    );
    widget.store.updateSettings(updated);

    MyAppToastMessage.success(
      context,
      title: 'Contact Details Saved',
      description: 'Mandal address, phone numbers, and timings updated across website.',
    );
  }

  void _openEnquiryDialog(AdminEnquiry enquiry) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        title: Text(
          'Enquiry from ${enquiry.name}',
          style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${enquiry.date}', style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context))),
              const SizedBox(height: 8),
              Text('Phone: ${enquiry.phone.isEmpty ? "Not provided" : enquiry.phone}', style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600)),
              Text('Email: ${enquiry.email.isEmpty ? "Not provided" : enquiry.email}', style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600)),
              const Divider(height: 20),
              Text('Message / Inquiry:', style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w700, color: colors.heritageGold)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(enquiry.message, style: styles.bodyText(context)),
              ),
            ],
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Close'),
          if (enquiry.status == 'New')
            MyAppFillButton(
              onPressed: () {
                widget.store.updateEnquiryStatus(enquiry.id, 'Responded');
                Navigator.pop(ctx);
                MyAppToastMessage.success(context, title: 'Marked Responded', description: 'Enquiry status changed.');
              },
              label: 'Mark Responded',
            ),
        ],
      ),
    );
  }

  void _confirmDeleteEnquiry(AdminEnquiry enquiry) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Enquiry?'),
        content: Text('Delete message from ${enquiry.name}?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteEnquiry(enquiry.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(context, title: 'Enquiry Deleted', description: 'Message removed.');
            },
            label: 'Delete',
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

    final filteredEnquiries = _statusFilter == 'All'
        ? widget.store.enquiries
        : widget.store.enquiries.where((e) => e.status == _statusFilter).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminWebsiteContextBanner(
          websitePageTitle: 'Contact Us Page',
          websiteRoute: '/contact',
          explanation: 'Controls what visitors see on the public Contact page: mandal address, emergency helpline, email, and receives messages submitted by citizens.',
        ),
        // Header
        const HeritageBadge(label: 'WEBSITE CONTENT / CONTACT & ENQUIRIES'),
        const SizedBox(height: 6),
        Text(
          'Contact Information & Devotee Inbox',
          style: styles.editorialSerif(context, size: 22, fontWeight: FontWeight.w700),
        ),
        Text(
          'Update venue location, phone lines, email addresses, and manage messages sent through the contact form.',
          style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
        ),
        const SizedBox(height: 24),

        // SECTION 1: CONTACT DETAILS
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: colors.heritageGold),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '1. Mandal Official Contact Information',
                            style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: MyAppFillButton.icon(
                        onPressed: _saveContactInfo,
                        icon: const Icon(Icons.save_rounded, size: 16),
                        label: 'Save Contact Info',
                      ),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: colors.heritageGold),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '1. Mandal Official Contact Information',
                              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    MyAppFillButton.icon(
                      onPressed: _saveContactInfo,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Contact Info',
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              MyAppTextAreaField(
                controller: _addressCtrl,
                labelText: 'Venue Address & Chowk',
                hintText: 'Complete venue address and chowk details',
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _phoneCtrl,
                labelText: 'Contact Phone Numbers',
                hintText: 'e.g. +91 98765 43210',
                prefixIcon: const Icon(Icons.phone_rounded),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _whatsappCtrl,
                labelText: 'Official WhatsApp Number',
                hintText: 'e.g. +91 98765 43210',
                prefixIcon: const Icon(Icons.chat_bubble_rounded),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _emailCtrl,
                labelText: 'Official Email Address',
                hintText: 'e.g. contact@pavanputragarbi.org',
                prefixIcon: const Icon(Icons.email_rounded),
              ),
              const SizedBox(height: 12),
              MyAppTextFormField(
                controller: _aartiTimeCtrl,
                labelText: 'Daily Aarti Schedule / Timings',
                hintText: 'e.g. 7:30 PM & 11:45 PM Daily',
                prefixIcon: const Icon(Icons.schedule_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // SECTION 2: DEVOTIONAL OFFERINGS & QR PAYMENTS
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: colors.heritageGold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '2. Devotional Offerings & QR Payments (Seva / Dan)',
                      style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Configure the mandal verified UPI ID and payment QR code displayed to devotees on the Contact page.',
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
                            'Show QR Payment & Seva Section on Website',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'When enabled, the verified QR code and UPI details appear on the public Contact page.',
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
              if (_isPaymentEnabled) ...[
                const SizedBox(height: 14),
                MyAppTextFormField(
                  controller: _upiIdCtrl,
                  labelText: 'Verified Mandal UPI ID',
                  hintText: 'e.g. pavanputra@upi',
                  prefixIcon: const Icon(Icons.payment_rounded),
                ),
                const SizedBox(height: 12),
                MyAppTextFormField(
                  controller: _recipientNameCtrl,
                  labelText: 'Verified Recipient / Account Name',
                  hintText: 'e.g. Shree Pavan Putra Garbi Mandal Trust',
                  prefixIcon: const Icon(Icons.account_balance_rounded),
                ),
                const SizedBox(height: 12),
                MyAppTextFormField(
                  controller: _paymentNotesCtrl,
                  labelText: 'Payment Notes / Instructions',
                  hintText: 'e.g. Direct mandal seva for Navratri Mahotsav',
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),
                const SizedBox(height: 16),
                Text('Verified Bank QR Code Image:', style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                MyAppImagePicker(
                  label: 'Verified UPI QR Code Image',
                  initialImageUrl: _paymentQrImageUrl,
                  height: 180,
                  onImageChanged: (url) => setState(() => _paymentQrImageUrl = url),
                  onImageRemoved: () => setState(() => _paymentQrImageUrl = ''),
                ),
                const SizedBox(height: 16),
                MyAppFillButton.icon(
                  onPressed: _saveContactInfo,
                  icon: const Icon(Icons.save_rounded, size: 16),
                  label: 'Save Payment & Contact Settings',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 28),

        // SECTION 3: ENQUIRIES INBOX
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          spacing: 10,
          children: [
            Text(
              'Devotee Inquiries Inbox (${filteredEnquiries.length})',
              style: styles.editorialSerif(context, size: 18, fontWeight: FontWeight.w700),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 6),
                  _buildFilterChip('New'),
                  const SizedBox(width: 6),
                  _buildFilterChip('Responded'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        filteredEnquiries.isEmpty
            ? const CulturalFrameCard(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('No inquiries in inbox.')),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredEnquiries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final enq = filteredEnquiries[index];
                  if (isMobile) {
                    return CulturalFrameCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: enq.status == 'New'
                                      ? Colors.red.withValues(alpha: 0.15)
                                      : Colors.green.withValues(alpha: 0.15),
                                ),
                                child: Icon(
                                  enq.status == 'New' ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
                                  color: enq.status == 'New' ? Colors.redAccent : Colors.green,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      enq.name,
                                      style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${enq.phone.isNotEmpty ? enq.phone : ''}${enq.phone.isNotEmpty && enq.email.isNotEmpty ? " • " : ""}${enq.email}',
                                      style: styles.cleanSans(context, size: 11.5, color: colors.heritageGold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              HeritageBadge(label: enq.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            enq.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                          ),
                          const SizedBox(height: 6),
                          const Divider(height: 1),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  enq.date,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MyAppIconButton(
                                    icon: const Icon(Icons.visibility_outlined, size: 18),
                                    tooltip: 'Read Inquiry',
                                    color: colors.heritageGold,
                                    onPressed: () => _openEnquiryDialog(enq),
                                  ),
                                  const SizedBox(width: 4),
                                  MyAppIconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    tooltip: 'Delete',
                                    color: Colors.redAccent,
                                    onPressed: () => _confirmDeleteEnquiry(enq),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  return CulturalFrameCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: enq.status == 'New'
                                ? Colors.red.withValues(alpha: 0.15)
                                : Colors.green.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            enq.status == 'New' ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
                            color: enq.status == 'New' ? Colors.redAccent : Colors.green,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(enq.name, style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700)),
                                  HeritageBadge(label: enq.status),
                                  Text(enq.date, style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context))),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${enq.phone} • ${enq.email}',
                                style: styles.cleanSans(context, size: 11.5, color: colors.heritageGold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                enq.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyAppIconButton(
                              icon: const Icon(Icons.visibility_outlined, size: 19),
                              tooltip: 'Read Inquiry',
                              color: colors.heritageGold,
                              onPressed: () => _openEnquiryDialog(enq),
                            ),
                            const SizedBox(width: 4),
                            MyAppIconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 19),
                              tooltip: 'Delete',
                              color: Colors.redAccent,
                              onPressed: () => _confirmDeleteEnquiry(enq),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    final colors = serviceLocator<MyAppColors>();
    final isSelected = _statusFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colors.heritageGold,
      onSelected: (_) => setState(() => _statusFilter = label),
    );
  }
}
