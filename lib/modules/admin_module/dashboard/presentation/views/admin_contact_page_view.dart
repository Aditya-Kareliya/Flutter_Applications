import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/brand_logo/brand_logo_widget.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../data/admin_data_store.dart';

/// Highly polished CRUD management view for Contact info, UPI/Seva QR Offerings,
/// and Devotee Enquiries Inbox matching Admin Home Page architecture & aesthetics.
class AdminContactPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminContactPageView({super.key, required this.store});

  @override
  State<AdminContactPageView> createState() => _AdminContactPageViewState();
}

class _AdminContactPageViewState extends State<AdminContactPageView> {
  // Section 1: Contact Details Controllers
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _aartiTimeCtrl;

  // Section 2: QR Payment & Offerings Controllers
  late final TextEditingController _upiIdCtrl;
  late final TextEditingController _recipientNameCtrl;
  late final TextEditingController _paymentNotesCtrl;
  late bool _isPaymentEnabled;
  late String _paymentQrImageUrl;

  // Live Preview & Inbox State
  String _previewLang = 'en';
  String _statusFilter = 'All';
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdated);
    _reloadControllersFromStore();

    _searchCtrl.addListener(() {
      if (mounted) {
        setState(() {
          _searchQuery = _searchCtrl.text.trim().toLowerCase();
        });
      }
    });
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _reloadControllersFromStore() {
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
    widget.store.removeListener(_onStoreUpdated);
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _aartiTimeCtrl.dispose();
    _upiIdCtrl.dispose();
    _recipientNameCtrl.dispose();
    _paymentNotesCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- External URL Launcher Helper ---
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

  // --- Save Operations ---
  void _saveContactInfo() {
    final updated = widget.store.settings.copyWith(
      address: _addressCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      whatsappNumber: _whatsappCtrl.text.trim(),
      contactEmail: _emailCtrl.text.trim(),
      dailyAartiTime: _aartiTimeCtrl.text.trim(),
    );
    widget.store.updateSettings(updated);

    MyAppToastMessage.success(
      context,
      title: 'Contact Details Saved',
      description: 'Mandal address, helpline numbers, and timings updated across website.',
    );
  }

  void _savePaymentSettings() {
    final updated = widget.store.settings.copyWith(
      paymentQrImageUrl: _paymentQrImageUrl.trim(),
      paymentUpiId: _upiIdCtrl.text.trim(),
      paymentRecipientName: _recipientNameCtrl.text.trim(),
      paymentNotes: _paymentNotesCtrl.text.trim(),
      isPaymentEnabled: _isPaymentEnabled,
    );
    widget.store.updateSettings(updated);

    MyAppToastMessage.success(
      context,
      title: 'Payment & Seva Settings Saved',
      description: _isPaymentEnabled
          ? 'Verified UPI and QR Code are now active on the public Contact page.'
          : 'Payment & Seva section is currently hidden from public visitors.',
    );
  }

  // --- Clear / Reset Dialogs ---
  void _confirmClearContactSection() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Contact Information?'),
        content: const Text(
          'Are you sure you want to clear venue address, phone lines, and timings in the editor? Changes will not be live until saved.',
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              setState(() {
                _addressCtrl.clear();
                _phoneCtrl.clear();
                _whatsappCtrl.clear();
                _emailCtrl.clear();
                _aartiTimeCtrl.clear();
              });
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Section Cleared',
                description: 'Fields cleared. Click "Save Contact Details" to publish or revert.',
              );
            },
            label: 'Clear All',
          ),
        ],
      ),
    );
  }

  void _confirmClearPaymentSection() {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Payment & Seva Details?'),
        content: const Text(
          'Are you sure you want to clear UPI ID, recipient name, notes, and QR code in the editor?',
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              setState(() {
                _upiIdCtrl.clear();
                _recipientNameCtrl.clear();
                _paymentNotesCtrl.clear();
                _paymentQrImageUrl = '';
              });
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Payment Section Cleared',
                description: 'Payment fields reset in editor.',
              );
            },
            label: 'Clear Payment',
          ),
        ],
      ),
    );
  }

  // --- Enquiry Modal & Dialogs ---
  void _openEnquiryDialog(AdminEnquiry enquiry) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isNew = enquiry.status == 'New';

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNew
                    ? Colors.red.withValues(alpha: 0.15)
                    : Colors.green.withValues(alpha: 0.15),
              ),
              child: Icon(
                isNew ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
                color: isNew ? Colors.redAccent : Colors.green,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enquiry.name,
                    style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      HeritageBadge(
                        label: enquiry.status.toUpperCase(),
                        backgroundColor: isNew
                            ? Colors.red.withValues(alpha: 0.15)
                            : Colors.green.withValues(alpha: 0.15),
                        textColor: isNew ? Colors.redAccent : Colors.green,
                        borderColor: isNew
                            ? Colors.redAccent.withValues(alpha: 0.4)
                            : Colors.green.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        enquiry.date,
                        style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Contact Details Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.getBorderColor(context)),
                  ),
                  child: Column(
                    children: [
                      if (enquiry.phone.isNotEmpty)
                        _buildDialogContactRow(
                          icon: Icons.phone_rounded,
                          label: 'Phone Number',
                          value: enquiry.phone,
                          colors: colors,
                          styles: styles,
                          onAction: () => _launchExternalUrl('tel:${enquiry.phone.replaceAll(RegExp(r'[^0-9+]'), '')}'),
                          actionLabel: 'Call',
                          actionIcon: Icons.call_rounded,
                        ),
                      if (enquiry.phone.isNotEmpty && enquiry.email.isNotEmpty)
                        const Divider(height: 16),
                      if (enquiry.email.isNotEmpty)
                        _buildDialogContactRow(
                          icon: Icons.email_rounded,
                          label: 'Email Address',
                          value: enquiry.email,
                          colors: colors,
                          styles: styles,
                          onAction: () => _launchExternalUrl('mailto:${enquiry.email}'),
                          actionLabel: 'Email',
                          actionIcon: Icons.email_outlined,
                        ),
                      if (enquiry.phone.isEmpty && enquiry.email.isEmpty)
                        Text(
                          'No direct contact phone or email provided.',
                          style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Message Text Section
                Text(
                  'DEVOTEE MESSAGE / PRAYER INQUIRY',
                  style: styles.cleanSans(context, size: 11, fontWeight: FontWeight.w700, color: colors.heritageGold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colors.isDarkMode(context) ? const Color(0xFF160A0D) : const Color(0xFFFAF6EE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
                  ),
                  child: SelectableText(
                    enquiry.message.isNotEmpty ? enquiry.message : '(No message body provided)',
                    style: styles.bodyText(context).copyWith(fontSize: 13.5, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Close'),
          if (enquiry.status == 'New')
            MyAppFillButton.icon(
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: 'Mark Responded',
              onPressed: () {
                widget.store.updateEnquiryStatus(enquiry.id, 'Responded');
                Navigator.pop(ctx);
                MyAppToastMessage.success(
                  context,
                  title: 'Marked Responded',
                  description: 'Enquiry from ${enquiry.name} marked as responded.',
                );
              },
            )
          else
            MyAppOutlineButton.icon(
              icon: const Icon(Icons.mark_email_unread_outlined, size: 16),
              label: 'Mark as New',
              onPressed: () {
                widget.store.updateEnquiryStatus(enquiry.id, 'New');
                Navigator.pop(ctx);
                MyAppToastMessage.info(
                  context,
                  title: 'Marked as New',
                  description: 'Enquiry moved back to unread queue.',
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDialogContactRow({
    required IconData icon,
    required String label,
    required String value,
    required MyAppColors colors,
    required MyAppTextStyles styles,
    required VoidCallback onAction,
    required String actionLabel,
    required IconData actionIcon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.heritageGold),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: styles.cleanSans(context, size: 10.5, color: colors.getSecondaryTextColor(context))),
              SelectableText(
                value,
                style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w600, color: colors.getPrimaryTextColor(context)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        MyAppOutlineButton.icon(
          onPressed: onAction,
          icon: Icon(actionIcon, size: 14),
          label: actionLabel,
          color: colors.heritageGold,
        ),
      ],
    );
  }

  void _confirmDeleteEnquiry(AdminEnquiry enquiry) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Devotee Inquiry?'),
        content: Text('Permanently remove inquiry message from "${enquiry.name}" submitted on ${enquiry.date}?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            onPressed: () {
              widget.store.deleteEnquiry(enquiry.id);
              Navigator.pop(ctx);
              MyAppToastMessage.warning(
                context,
                title: 'Inquiry Deleted',
                description: 'Message removed from inbox.',
              );
            },
            label: 'Delete Permanently',
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

    final allEnquiries = widget.store.enquiries;
    final newCount = allEnquiries.where((e) => e.status == 'New').length;
    final respondedCount = allEnquiries.where((e) => e.status == 'Responded').length;

    // Filter by tab + search query
    final filteredEnquiries = allEnquiries.where((e) {
      final matchesStatus = _statusFilter == 'All' || e.status == _statusFilter;
      if (!matchesStatus) return false;
      if (_searchQuery.isEmpty) return true;

      final name = e.name.toLowerCase();
      final phone = e.phone.toLowerCase();
      final email = e.email.toLowerCase();
      final msg = e.message.toLowerCase();
      return name.contains(_searchQuery) ||
          phone.contains(_searchQuery) ||
          email.contains(_searchQuery) ||
          msg.contains(_searchQuery);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminWebsiteContextBanner(
          websitePageTitle: 'Contact Us Page',
          websiteRoute: '/contact',
          explanation: 'Controls what visitors see on the public Contact page: venue location, phone helpline, WhatsApp, email, daily aarti timings, QR offerings/UPI seva, and receives messages submitted by citizens.',
        ),

        // Header
        const HeritageBadge(label: 'WEBSITE CONTENT / CONTACT & ENQUIRIES'),
        const SizedBox(height: 6),
        Text(
          'Contact Information, Seva Offerings & Devotee Inbox',
          style: styles.editorialSerif(context, size: isMobile ? 20 : 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage mandal helpline numbers, venue location, daily aarti timings, UPI payment QR code, and devotee messages.',
          style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
        ),
        const SizedBox(height: 20),

        // TOP STATS OVERVIEW CARDS (Responsive Grid)
        _buildTopMetricsGrid(colors, styles, allEnquiries.length, newCount, respondedCount),
        const SizedBox(height: 24),

        // SECTION 1: MANDAL CONTACT INFORMATION
        _buildContactDetailsSection(colors, styles, isMobile),
        const SizedBox(height: 28),

        // SECTION 2: DEVOTIONAL OFFERINGS & QR PAYMENTS
        _buildPaymentQrSection(colors, styles, isMobile),
        const SizedBox(height: 28),

        // SECTION 3: DEVOTEE INQUIRIES INBOX
        _buildDevoteeInboxSection(colors, styles, isMobile, filteredEnquiries, allEnquiries.length, newCount, respondedCount),
      ],
    );
  }

  // =========================================================================
  // 📊 TOP METRICS OVERVIEW (4 Stat Cards)
  // =========================================================================
  Widget _buildTopMetricsGrid(
    MyAppColors colors,
    MyAppTextStyles styles,
    int totalCount,
    int newCount,
    int respondedCount,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int columns;
        if (width >= 1100) {
          columns = 4;
        } else if (width >= 600) {
          columns = 2;
        } else {
          columns = 1;
        }

        final cards = [
          _buildStatCard(
            title: 'Total Inquiries',
            value: '$totalCount',
            subtitle: 'Devotee messages received',
            icon: Icons.mail_outline_rounded,
            color: const Color(0xFFC5A059),
            colors: colors,
            styles: styles,
          ),
          _buildStatCard(
            title: 'New / Unread',
            value: '$newCount',
            subtitle: newCount > 0 ? 'Requires attention' : 'All caught up',
            icon: Icons.mark_email_unread_rounded,
            color: newCount > 0 ? Colors.redAccent : const Color(0xFF81C784),
            colors: colors,
            styles: styles,
          ),
          _buildStatCard(
            title: 'Responded',
            value: '$respondedCount',
            subtitle: 'Addressed inquiries',
            icon: Icons.mark_email_read_rounded,
            color: const Color(0xFF4CAF50),
            colors: colors,
            styles: styles,
          ),
          _buildStatCard(
            title: 'Seva & Dan QR',
            value: _isPaymentEnabled ? 'ACTIVE' : 'DISABLED',
            subtitle: _isPaymentEnabled ? 'Visible on website' : 'Hidden from visitors',
            icon: Icons.qr_code_scanner_rounded,
            color: _isPaymentEnabled ? const Color(0xFF2E7D32) : Colors.orangeAccent,
            colors: colors,
            styles: styles,
          ),
        ];

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: columns == 1 ? 3.6 : (columns == 2 ? 2.6 : 2.2),
          children: cards,
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required MyAppColors colors,
    required MyAppTextStyles styles,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.heritageGold.withValues(alpha: 0.3),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDarkMode(context) ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: color, size: 22),
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
                  style: styles.cleanSans(
                    context,
                    size: 11,
                    color: colors.getSecondaryTextColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: styles.cleanSans(
                    context,
                    size: 18,
                    fontWeight: FontWeight.w800,
                    color: colors.getPrimaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: styles.cleanSans(
                    context,
                    size: 10.5,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 🏛️ SECTION 1: MANDAL CONTACT INFORMATION
  // =========================================================================
  Widget _buildContactDetailsSection(MyAppColors colors, MyAppTextStyles styles, bool isMobile) {
    return CulturalFrameCard(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Action Buttons
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _confirmClearContactSection,
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: 'Clear Section',
                    ),
                    MyAppFillButton.icon(
                      onPressed: _saveContactInfo,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Contact Details',
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _confirmClearContactSection,
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: 'Clear Section',
                    ),
                    const SizedBox(width: 8),
                    MyAppFillButton.icon(
                      onPressed: _saveContactInfo,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Contact Details',
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 6),
          Text(
            'Official venue address, helpline numbers, email address, and daily aarti timings shown on the public Contact page.',
            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
          ),
          const SizedBox(height: 20),

          // LIVE INTERACTIVE PREVIEW CARD
          _buildLiveContactPreviewCard(colors, styles),
          const SizedBox(height: 24),

          // FORM FIELDS (Responsive Grid)
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;

              final col1 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1.1 Venue Address & Chowk (સ્થળનું સરનામું)',
                    style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  MyAppTextAreaField(
                    controller: _addressCtrl,
                    labelText: 'Venue Address & Chowk Details',
                    hintText: 'e.g. Near Pavanputra Chowk, 150 Feet Ring Road, Rajkot - 360004',
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1.2 Daily Aarti Schedule & Timings (દૈનિક આરતી સમય)',
                    style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  MyAppTextFormField(
                    controller: _aartiTimeCtrl,
                    labelText: 'Daily Aarti Timings',
                    hintText: 'e.g. 7:30 PM & 11:45 PM Daily',
                    prefixIcon: const Icon(Icons.schedule_rounded),
                  ),
                ],
              );

              final col2 = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1.3 Contact Phone Numbers (સંપર્ક ફોન નંબર)',
                    style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  MyAppTextFormField(
                    controller: _phoneCtrl,
                    labelText: 'Helpline Phone Number',
                    hintText: 'e.g. +91 98765 43210',
                    prefixIcon: const Icon(Icons.phone_rounded),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1.4 Official WhatsApp Helpline (વોટ્સએપ હેલ્પલાઇન)',
                    style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  MyAppTextFormField(
                    controller: _whatsappCtrl,
                    labelText: 'WhatsApp Helpline',
                    hintText: 'e.g. +91 98765 43210',
                    prefixIcon: const Icon(Icons.chat_bubble_rounded),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1.5 Official Contact Email (ઈમેલ સરનામું)',
                    style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  MyAppTextFormField(
                    controller: _emailCtrl,
                    labelText: 'Official Email Address',
                    hintText: 'e.g. contact@pavanputragarbi.org',
                    prefixIcon: const Icon(Icons.email_rounded),
                  ),
                ],
              );

              return isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: col1),
                        const SizedBox(width: 24),
                        Expanded(child: col2),
                      ],
                    )
                  : Column(children: [col1, const SizedBox(height: 16), col2]);
            },
          ),
        ],
      ),
    );
  }

  // --- Live Contact Card Preview ---
  Widget _buildLiveContactPreviewCard(MyAppColors colors, MyAppTextStyles styles) {
    final s = widget.store.settings;
    final address = _addressCtrl.text.trim().isNotEmpty
        ? _addressCtrl.text.trim()
        : 'Near Pavanputra Chowk, 150 Feet Ring Road, Rajkot - 360004';
    final phone = _phoneCtrl.text.trim().isNotEmpty
        ? _phoneCtrl.text.trim()
        : '+91 98765 43210';
    final whatsapp = _whatsappCtrl.text.trim();
    final email = _emailCtrl.text.trim().isNotEmpty
        ? _emailCtrl.text.trim()
        : 'contact@pavanputragarbi.org';
    final aarti = _aartiTimeCtrl.text.trim().isNotEmpty
        ? _aartiTimeCtrl.text.trim()
        : '7:30 PM & 11:45 PM Daily';

    final isGu = _previewLang == 'gu';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B0306),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.4), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Toolbar with Language Switcher
          LayoutBuilder(
            builder: (context, constraints) {
              final isTight = constraints.maxWidth < 420;
              final langToggle = MyAppSegmentView.language(
                selectedLanguage: _previewLang,
                onLanguageChanged: (val) => setState(() => _previewLang = val),
              );

              if (isTight) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.visibility_rounded, color: colors.heritageGold, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Live Public Contact Preview',
                            style: styles.editorialSerif(context, size: 13, fontWeight: FontWeight.w700, color: colors.lightGold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    langToggle,
                  ],
                );
              }

              return Row(
                children: [
                  Icon(Icons.visibility_rounded, color: colors.heritageGold, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Live Public Contact Preview (as seen by devotees)',
                      style: styles.editorialSerif(context, size: 13, fontWeight: FontWeight.w700, color: colors.lightGold),
                    ),
                  ),
                  const SizedBox(width: 8),
                  langToggle,
                ],
              );
            },
          ),
          const Divider(height: 24, color: Colors.white24),

          // Header with Logo
          Row(
            children: [
              BrandLogoWidget(
                size: 46,
                isCircular: true,
                border: Border.all(color: colors.heritageGold, width: 1.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGu && s.mandalNameGu.isNotEmpty ? s.mandalNameGu : (s.mandalNameEn.isNotEmpty ? s.mandalNameEn : 'Shree Pavan Putra Garbi Mandal'),
                      style: styles.editorialSerif(
                        context,
                        size: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isGu ? 'રાજકોટ • સ્થાપના ૧૯૯૭' : 'Rajkot • Established 1997',
                      style: styles.cleanSans(
                        context,
                        size: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colors.lightGold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Venue Address Row
          _buildPreviewDetailRow(
            icon: Icons.location_on_rounded,
            label: isGu ? 'સ્થળનું સરનામું' : 'Official Venue Address',
            value: address,
            colors: colors,
            styles: styles,
          ),
          const SizedBox(height: 12),

          // Phone Row
          _buildPreviewDetailRow(
            icon: Icons.phone_rounded,
            label: isGu ? 'સંપર્ક ફોન' : 'Helpline & Contact',
            value: phone,
            colors: colors,
            styles: styles,
          ),

          // WhatsApp Row (if configured)
          if (whatsapp.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildPreviewDetailRow(
              icon: Icons.chat_bubble_rounded,
              label: isGu ? 'વોટ્સએપ હેલ્પલાઇન' : 'Official WhatsApp Helpline',
              value: whatsapp,
              colors: colors,
              styles: styles,
            ),
          ],

          const SizedBox(height: 12),
          // Email Row
          _buildPreviewDetailRow(
            icon: Icons.email_rounded,
            label: isGu ? 'ઈમેલ સરનામું' : 'Official Email Address',
            value: email,
            colors: colors,
            styles: styles,
          ),

          const SizedBox(height: 12),
          // Aarti Timings Row
          _buildPreviewDetailRow(
            icon: Icons.schedule_rounded,
            label: isGu ? 'દૈનિક આરતી સમય' : 'Daily Aarti Schedule',
            value: aarti,
            colors: colors,
            styles: styles,
          ),

          const SizedBox(height: 18),
          Center(
            child: Text(
              '|| જાગતી જોગમાયા || || જય માતાજી ||',
              style: styles.devotionalMotto(context, size: 15, color: colors.lightGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required MyAppColors colors,
    required MyAppTextStyles styles,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.heritageGold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colors.lightGold, size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: styles.cleanSans(context, size: 10.5, color: colors.lightGold.withValues(alpha: 0.75)),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: styles.cleanSans(context, size: 13, color: colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 💳 SECTION 2: DEVOTIONAL OFFERINGS & QR PAYMENTS
  // =========================================================================
  Widget _buildPaymentQrSection(MyAppColors colors, MyAppTextStyles styles, bool isMobile) {
    return CulturalFrameCard(
      padding: EdgeInsets.all(isMobile ? 14 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Action Buttons
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: colors.heritageGold),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '2. Devotional Offerings & QR Payments (Seva / Dan)',
                        style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _confirmClearPaymentSection,
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: 'Clear Payment',
                    ),
                    MyAppFillButton.icon(
                      onPressed: _savePaymentSettings,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Payment & Seva',
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
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
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyAppOutlineButton.icon(
                      isDanger: true,
                      onPressed: _confirmClearPaymentSection,
                      icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                      label: 'Clear Payment',
                    ),
                    const SizedBox(width: 8),
                    MyAppFillButton.icon(
                      onPressed: _savePaymentSettings,
                      icon: const Icon(Icons.save_rounded, size: 16),
                      label: 'Save Payment & Seva',
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 6),
          Text(
            'Configure the mandal verified UPI ID and payment QR code displayed to devotees on the Contact page.',
            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
          ),
          const SizedBox(height: 16),

          // Master Toggle Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.getSurfaceColor(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isPaymentEnabled
                    ? colors.heritageGold.withValues(alpha: 0.6)
                    : colors.getBorderColor(context),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isPaymentEnabled
                        ? colors.deepMaroon
                        : Colors.grey.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPaymentEnabled ? Icons.payments_rounded : Icons.money_off_rounded,
                    color: _isPaymentEnabled ? colors.heritageGold : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Show QR Payment & Seva Section on Website',
                              style: styles.cleanSans(context, size: 13.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          HeritageBadge(
                            label: _isPaymentEnabled ? 'ACTIVE' : 'HIDDEN',
                            backgroundColor: _isPaymentEnabled
                                ? Colors.green.withValues(alpha: 0.15)
                                : Colors.grey.withValues(alpha: 0.15),
                            textColor: _isPaymentEnabled ? Colors.green : Colors.grey,
                            borderColor: _isPaymentEnabled
                                ? Colors.green.withValues(alpha: 0.4)
                                : Colors.grey.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'When enabled, the verified QR code and UPI details appear on the public Contact page.',
                        style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context)),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isPaymentEnabled,
                  activeThumbColor: colors.heritageGold,
                  activeTrackColor: colors.deepMaroon,
                  onChanged: (val) => setState(() => _isPaymentEnabled = val),
                ),
              ],
            ),
          ),

          if (_isPaymentEnabled) ...[
            const SizedBox(height: 20),

            // LIVE PAYMENT QR PREVIEW CARD (Replicating Public Contact Page)
            _buildLivePaymentQrPreviewCard(colors, styles),
            const SizedBox(height: 24),

            // FORM INPUTS
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;

                final leftImagePicker = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verified Bank / Mandal QR Code Image',
                      style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    MyAppImagePicker(
                      label: 'Verified UPI QR Code Image',
                      helperText: 'Pick from device or paste image URL. Devotees scan this code to contribute seva.',
                      initialImageUrl: _paymentQrImageUrl,
                      height: 220,
                      onImageChanged: (url) => setState(() => _paymentQrImageUrl = url),
                      onImageRemoved: () => setState(() => _paymentQrImageUrl = ''),
                    ),
                  ],
                );

                final rightInputs = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '2.1 Verified Mandal UPI ID (UPI આઈડી)',
                      style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    MyAppTextFormField(
                      controller: _upiIdCtrl,
                      labelText: 'Verified UPI ID',
                      hintText: 'e.g. pavanputragarbi@okhdfcbank or 9876543210@upi',
                      prefixIcon: const Icon(Icons.payment_rounded),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '2.2 Verified Recipient / Account Name (ખાતાધારકનું નામ)',
                      style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    MyAppTextFormField(
                      controller: _recipientNameCtrl,
                      labelText: 'Account / Trust Name',
                      hintText: 'e.g. Shree Pavan Putra Garbi Mandal Trust',
                      prefixIcon: const Icon(Icons.account_balance_rounded),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '2.3 Payment Notes & Seva Instructions (ચુકવણી નોંધ / સૂચના)',
                      style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    MyAppTextFormField(
                      controller: _paymentNotesCtrl,
                      labelText: 'Payment Instructions',
                      hintText: 'e.g. Direct mandal seva for Navratri Mahotsav 2026',
                      prefixIcon: const Icon(Icons.notes_rounded),
                    ),
                  ],
                );

                return isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: leftImagePicker),
                          const SizedBox(width: 24),
                          Expanded(flex: 6, child: rightInputs),
                        ],
                      )
                    : Column(
                        children: [
                          leftImagePicker,
                          const SizedBox(height: 20),
                          rightInputs,
                        ],
                      );
              },
            ),
          ],
        ],
      ),
    );
  }

  // --- Live Payment QR Preview Card ---
  Widget _buildLivePaymentQrPreviewCard(MyAppColors colors, MyAppTextStyles styles) {
    final upiId = _upiIdCtrl.text.trim().isNotEmpty ? _upiIdCtrl.text.trim() : 'pavanputragarbi@upi';
    final recipient = _recipientNameCtrl.text.trim().isNotEmpty
        ? _recipientNameCtrl.text.trim()
        : 'Shree Pavan Putra Garbi Mandal Trust';
    final notes = _paymentNotesCtrl.text.trim().isNotEmpty
        ? _paymentNotesCtrl.text.trim()
        : 'Direct Mandir Seva & Navratri Mahotsav Offerings';
    final hasQrImage = _paymentQrImageUrl.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B0306),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.4), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded, color: colors.heritageGold, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Live Devotional Offering Preview (as seen by public visitors)',
                  style: styles.editorialSerif(context, size: 13, fontWeight: FontWeight.w700, color: colors.lightGold),
                ),
              ),
              HeritageBadge(
                label: 'UPI VERIFIED',
                backgroundColor: colors.heritageGold.withValues(alpha: 0.15),
                textColor: colors.lightGold,
                borderColor: colors.heritageGold.withValues(alpha: 0.4),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white24),

          // Header
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
                      style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700, color: colors.white),
                    ),
                    Text(
                      'Scan with Google Pay, PhonePe, Paytm, or BHIM UPI',
                      style: styles.cleanSans(context, size: 11.5, color: colors.lightGold.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // QR Code Graphic Preview
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5), width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: hasQrImage
                  ? CachedNetworkImage(
                      imageUrl: _paymentQrImageUrl,
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                      placeholder: (_, _) => const SizedBox(
                        width: 160,
                        height: 160,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, _, _) => Container(
                        width: 160,
                        height: 160,
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey)),
                      ),
                    )
                  : Container(
                      width: 160,
                      height: 160,
                      color: Colors.grey.shade100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.grey.shade500),
                          const SizedBox(height: 4),
                          Text('Upload QR Image', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // UPI ID Pill Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_rounded, color: colors.lightGold, size: 16),
                const SizedBox(width: 8),
                Text(
                  'UPI ID: ',
                  style: styles.cleanSans(context, size: 12, color: colors.lightGold.withValues(alpha: 0.8)),
                ),
                Flexible(
                  child: Text(
                    upiId,
                    style: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w700, color: colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.copy_rounded, color: colors.heritageGold, size: 15),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Recipient & Notes
          Center(
            child: Column(
              children: [
                Text(
                  'Account: $recipient',
                  style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600, color: colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  notes,
                  style: styles.cleanSans(context, size: 11.5, color: colors.lightGold.withValues(alpha: 0.75)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 📬 SECTION 3: DEVOTEE INQUIRIES INBOX
  // =========================================================================
  Widget _buildDevoteeInboxSection(
    MyAppColors colors,
    MyAppTextStyles styles,
    bool isMobile,
    List<AdminEnquiry> filteredEnquiries,
    int totalCount,
    int newCount,
    int respondedCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Search & Filter
        Row(
          children: [
            Icon(Icons.mark_email_unread_rounded, color: colors.heritageGold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '3. Devotee Inquiries Inbox & Message Center',
                style: styles.editorialSerif(context, size: isMobile ? 18 : 20, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Messages, prayer requests, and feedback submitted by public visitors through the Contact Us form.',
          style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
        ),
        const SizedBox(height: 14),

        // SEARCH BAR & FILTER TABS TOOLBAR
        CulturalFrameCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;

                  final searchField = MyAppTextFormField(
                    controller: _searchCtrl,
                    labelText: 'Search Inquiries',
                    hintText: 'Search by devotee name, phone, email, or message...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => _searchCtrl.clear(),
                          )
                        : null,
                  );

                  final filterTabs = SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterBadge('All', totalCount, colors),
                        const SizedBox(width: 8),
                        _buildFilterBadge('New', newCount, colors),
                        const SizedBox(width: 8),
                        _buildFilterBadge('Responded', respondedCount, colors),
                      ],
                    ),
                  );

                  return isWide
                      ? Row(
                          children: [
                            Expanded(child: searchField),
                            const SizedBox(width: 16),
                            filterTabs,
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            searchField,
                            const SizedBox(height: 12),
                            filterTabs,
                          ],
                        );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // INBOX LIST OR EMPTY STATE
        if (filteredEnquiries.isEmpty)
          CulturalFrameCard(
            padding: const EdgeInsets.all(36),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.inbox_rounded,
                    size: 48,
                    color: colors.heritageGold.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'No inquiries match "$_searchQuery"'
                        : (_statusFilter == 'All'
                            ? 'No inquiries received yet'
                            : 'No inquiries in $_statusFilter status'),
                    style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'Try searching with a different name, phone, or keyword.'
                        : 'Devotee messages submitted from the public Contact page will appear here.',
                    style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEnquiries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final enq = filteredEnquiries[index];
              final isNew = enq.status == 'New';

              return CulturalFrameCard(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: isMobile
                    ? _buildMobileEnquiryCard(enq, isNew, colors, styles)
                    : _buildDesktopEnquiryCard(enq, isNew, colors, styles),
              );
            },
          ),
      ],
    );
  }

  // --- Filter Chip Widget ---
  Widget _buildFilterBadge(String label, int count, MyAppColors colors) {
    final isSelected = _statusFilter == label;
    final isNewTab = label == 'New';

    return InkWell(
      onTap: () => setState(() => _statusFilter = label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.deepMaroon
              : colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colors.heritageGold
                : colors.getBorderColor(context),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.white : colors.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.heritageGold
                    : (isNewTab && count > 0 ? Colors.redAccent.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? colors.deepMaroon
                      : (isNewTab && count > 0 ? Colors.redAccent : colors.getSecondaryTextColor(context)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Mobile Enquiry Card ---
  Widget _buildMobileEnquiryCard(AdminEnquiry enq, bool isNew, MyAppColors colors, MyAppTextStyles styles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNew
                    ? Colors.red.withValues(alpha: 0.15)
                    : Colors.green.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Icon(
                  isNew ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
                  color: isNew ? Colors.redAccent : Colors.green,
                  size: 18,
                ),
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
                    enq.date,
                    style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                  ),
                ],
              ),
            ),
            HeritageBadge(
              label: enq.status.toUpperCase(),
              backgroundColor: isNew
                  ? Colors.red.withValues(alpha: 0.15)
                  : Colors.green.withValues(alpha: 0.15),
              textColor: isNew ? Colors.redAccent : Colors.green,
              borderColor: isNew
                  ? Colors.redAccent.withValues(alpha: 0.4)
                  : Colors.green.withValues(alpha: 0.4),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Contact info line
        if (enq.phone.isNotEmpty || enq.email.isNotEmpty)
          Text(
            '${enq.phone.isNotEmpty ? enq.phone : ''}${enq.phone.isNotEmpty && enq.email.isNotEmpty ? " • " : ""}${enq.email}',
            style: styles.cleanSans(context, size: 11.5, color: colors.heritageGold, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        const SizedBox(height: 6),

        // Message snippet
        Text(
          enq.message.isNotEmpty ? enq.message : '(No message)',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 6),

        // Action Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyAppTextButton.icon(
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: 'View',
              onPressed: () => _openEnquiryDialog(enq),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (enq.status == 'New')
                  MyAppIconButton(
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                    tooltip: 'Mark Responded',
                    color: Colors.green,
                    onPressed: () {
                      widget.store.updateEnquiryStatus(enq.id, 'Responded');
                      MyAppToastMessage.success(context, title: 'Marked Responded', description: 'Status updated.');
                    },
                  )
                else
                  MyAppIconButton(
                    icon: const Icon(Icons.mark_email_unread_outlined, size: 18),
                    tooltip: 'Mark New',
                    color: Colors.orangeAccent,
                    onPressed: () {
                      widget.store.updateEnquiryStatus(enq.id, 'New');
                      MyAppToastMessage.info(context, title: 'Marked as New', description: 'Moved to unread queue.');
                    },
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
    );
  }

  // --- Desktop / Tablet Enquiry Card ---
  Widget _buildDesktopEnquiryCard(AdminEnquiry enq, bool isNew, MyAppColors colors, MyAppTextStyles styles) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isNew
                ? Colors.red.withValues(alpha: 0.15)
                : Colors.green.withValues(alpha: 0.15),
          ),
          child: Center(
            child: Icon(
              isNew ? Icons.mark_email_unread_rounded : Icons.mark_email_read_rounded,
              color: isNew ? Colors.redAccent : Colors.green,
              size: 20,
            ),
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
                  Text(
                    enq.name,
                    style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.w700),
                  ),
                  HeritageBadge(
                    label: enq.status.toUpperCase(),
                    backgroundColor: isNew
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.green.withValues(alpha: 0.15),
                    textColor: isNew ? Colors.redAccent : Colors.green,
                    borderColor: isNew
                        ? Colors.redAccent.withValues(alpha: 0.4)
                        : Colors.green.withValues(alpha: 0.4),
                  ),
                  Text(
                    enq.date,
                    style: styles.cleanSans(context, size: 11, color: colors.getSecondaryTextColor(context)),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              if (enq.phone.isNotEmpty || enq.email.isNotEmpty)
                Text(
                  '${enq.phone.isNotEmpty ? enq.phone : ''}${enq.phone.isNotEmpty && enq.email.isNotEmpty ? " • " : ""}${enq.email}',
                  style: styles.cleanSans(context, size: 11.5, color: colors.heritageGold, fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 3),
              Text(
                enq.message.isNotEmpty ? enq.message : '(No message)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyAppOutlineButton.icon(
              icon: const Icon(Icons.visibility_outlined, size: 16),
              label: 'View',
              color: colors.heritageGold,
              onPressed: () => _openEnquiryDialog(enq),
            ),
            const SizedBox(width: 6),
            if (enq.status == 'New')
              MyAppIconButton(
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                tooltip: 'Mark Responded',
                color: Colors.green,
                onPressed: () {
                  widget.store.updateEnquiryStatus(enq.id, 'Responded');
                  MyAppToastMessage.success(context, title: 'Marked Responded', description: 'Status updated.');
                },
              )
            else
              MyAppIconButton(
                icon: const Icon(Icons.mark_email_unread_outlined, size: 20),
                tooltip: 'Mark New',
                color: Colors.orangeAccent,
                onPressed: () {
                  widget.store.updateEnquiryStatus(enq.id, 'New');
                  MyAppToastMessage.info(context, title: 'Marked as New', description: 'Moved to unread queue.');
                },
              ),
            const SizedBox(width: 4),
            MyAppIconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              tooltip: 'Delete Inquiry',
              color: Colors.redAccent,
              onPressed: () => _confirmDeleteEnquiry(enq),
            ),
          ],
        ),
      ],
    );
  }
}
