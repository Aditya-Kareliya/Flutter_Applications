import 'package:flutter/material.dart';

import '../../../core/dependency_injection/dependency_injection.dart';
import '../../../core/localization/my_app_translations.dart';
import '../../../core/my_app_colors/my_app_colors.dart';
import '../../../core/my_app_scaffold/my_app_scaffold.dart';
import '../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../core/widgets/cultural_frame_card.dart';
import '../../../core/widgets/heritage_badge.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
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

      setState(() => _isSubmitted = true);
      MyAppToastMessage.success(
        context,
        title: 'Pranam! Message Received',
        description: context.tr('form_success'),
      );
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
                    style: styles
                        .bodyText(context)
                        .copyWith(fontSize: isMobile ? 14 : 16),
                  ),
                ),
                const SizedBox(height: 36),

                // Responsive 2-Column Content
                if (isMobile) ...[
                  _buildMandalInfoCard(colors, styles),
                  const SizedBox(height: 24),
                  _buildInquiryForm(colors, styles),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildMandalInfoCard(colors, styles),
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

  Widget _buildMandalInfoCard(MyAppColors colors, MyAppTextStyles styles) {
    return CulturalFrameCard(
      padding: const EdgeInsets.all(28),
      backgroundColor: colors.deepMaroon,
      borderColor: colors.heritageGold.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.heritageGold, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/images/pavan_putra_logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('app_title'),
                      style: styles.editorialSerif(
                        context,
                        size: 20,
                        fontWeight: FontWeight.w700,
                        color: colors.white,
                      ),
                    ),
                    Text(
                      context.tr('app_subtitle'),
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
            value: context.tr('contact_address'),
            colors: colors,
            styles: styles,
          ),
          const SizedBox(height: 18),
          _ContactDetailRow(
            icon: Icons.phone_rounded,
            label: context.tr('contact_phone_label'),
            value: context.tr('contact_phone'),
            colors: colors,
            styles: styles,
          ),
          const SizedBox(height: 18),
          _ContactDetailRow(
            icon: Icons.email_rounded,
            label: context.tr('contact_email_label'),
            value: context.tr('contact_email'),
            colors: colors,
            styles: styles,
          ),
          const SizedBox(height: 18),
          _ContactDetailRow(
            icon: Icons.access_time_rounded,
            label: context.tr('contact_hours_label'),
            value: context.tr('contact_hours'),
            colors: colors,
            styles: styles,
          ),
          const SizedBox(height: 24),
          Text(
            '|| જાગતી જોગમાયા|| || જય માતાજી ||',
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
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.tr('form_name'),
                prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter your full name'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: context.tr('form_phone'),
                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please enter your mobile number'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.tr('form_email'),
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr('form_message'),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Icon(Icons.edit_note_rounded, size: 22),
                ),
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Please write your message or enquiry'
                  : null,
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
                onPressed: _handleSubmit,
                child: Text(
                  _isSubmitted
                      ? '✓ MESSAGE RECEIVED'
                      : context.tr('form_submit'),
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

  const _ContactDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                  size: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.lightGold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: styles
                    .bodyText(context)
                    .copyWith(
                      color: const Color(0xFFE2DDD1),
                      fontSize: 13.5,
                      height: 1.45,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
