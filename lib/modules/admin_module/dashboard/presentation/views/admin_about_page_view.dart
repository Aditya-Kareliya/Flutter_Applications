import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../core/my_app_colors/my_app_colors.dart';
import '../../../../../core/my_app_text_style/my_app_text_styles.dart';
import '../../../../../core/widgets/admin/admin_website_context_banner.dart';
import '../../../../../core/widgets/cultural_frame_card.dart';
import '../../../../../core/widgets/heritage_badge.dart';
import '../../../../../core/widgets/image_picker/my_app_image_picker.dart';
import '../../../../../core/widgets/toast/my_app_toast_message.dart';
import '../../../../../core/widgets/my_app_ui_components.dart';
import '../../data/admin_data_store.dart';

/// Admin view for About Us page content:
/// Page Header & Story Introduction, Heritage & Foundation Story, Cultural Values,
/// Organizing Committee & Trustees, and History Link Card.
class AdminAboutPageView extends StatefulWidget {
  final AdminDataStore store;

  const AdminAboutPageView({super.key, required this.store});

  @override
  State<AdminAboutPageView> createState() => _AdminAboutPageViewState();
}

class _AdminAboutPageViewState extends State<AdminAboutPageView> {
  // Section 1: Page Header & Story Introduction
  late final TextEditingController _tagBadgeEnCtrl;
  late final TextEditingController _tagBadgeGuCtrl;
  late final TextEditingController _titleEnCtrl;
  late final TextEditingController _titleGuCtrl;
  late final TextEditingController _descEnCtrl;
  late final TextEditingController _descGuCtrl;

  // Section 2: Heritage Foundation Card
  late final TextEditingController _historyTitleEnCtrl;
  late final TextEditingController _historyTitleGuCtrl;
  late final TextEditingController _historyBodyEnCtrl;
  late final TextEditingController _historyBodyGuCtrl;
  late final TextEditingController _historyMottoEnCtrl;
  late final TextEditingController _historyMottoGuCtrl;
  String _foundationImageUrl = 'assets/images/pavan_putra_logo.png';

  // Section 3: Principles Header
  late final TextEditingController _principlesTagEnCtrl;
  late final TextEditingController _principlesTagGuCtrl;
  late final TextEditingController _principlesTitleEnCtrl;
  late final TextEditingController _principlesTitleGuCtrl;

  // Section 4: Committee Header
  late final TextEditingController _committeeBadgeEnCtrl;
  late final TextEditingController _committeeBadgeGuCtrl;
  late final TextEditingController _committeeTitleEnCtrl;
  late final TextEditingController _committeeTitleGuCtrl;
  late final TextEditingController _committeeDescEnCtrl;
  late final TextEditingController _committeeDescGuCtrl;

  // Section 5: History Callout
  late final TextEditingController _ctaTitleEnCtrl;
  late final TextEditingController _ctaTitleGuCtrl;
  late final TextEditingController _ctaDescEnCtrl;
  late final TextEditingController _ctaDescGuCtrl;
  late final TextEditingController _ctaBtnTextEnCtrl;
  late final TextEditingController _ctaBtnTextGuCtrl;
  late final TextEditingController _ctaRouteCtrl;

  // Search filter for committee members
  final TextEditingController _memberSearchCtrl = TextEditingController();
  String _memberSearchQuery = '';

  String _previewLang = 'gu';

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreUpdated);
    widget.store.ensureAboutPageLoaded();
    _reloadAllControllersFromStore();
    _memberSearchCtrl.addListener(() {
      setState(() {
        _memberSearchQuery = _memberSearchCtrl.text.trim().toLowerCase();
      });
    });
  }

  void _onStoreUpdated() {
    if (mounted) setState(() {});
  }

  void _reloadAllControllersFromStore() {
    final about = widget.store.aboutPageData;

    _tagBadgeEnCtrl = TextEditingController(text: about.tagBadgeEn);
    _tagBadgeGuCtrl = TextEditingController(text: about.tagBadgeGu);
    _titleEnCtrl = TextEditingController(text: about.titleEn);
    _titleGuCtrl = TextEditingController(text: about.titleGu);
    _descEnCtrl = TextEditingController(text: about.descEn);
    _descGuCtrl = TextEditingController(text: about.descGu);

    _historyTitleEnCtrl = TextEditingController(text: about.foundationTitleEn);
    _historyTitleGuCtrl = TextEditingController(text: about.foundationTitleGu);
    _historyBodyEnCtrl = TextEditingController(text: about.foundationDescEn);
    _historyBodyGuCtrl = TextEditingController(text: about.foundationDescGu);
    _historyMottoEnCtrl = TextEditingController(text: about.foundationMottoEn);
    _historyMottoGuCtrl = TextEditingController(text: about.foundationMottoGu);
    _foundationImageUrl = about.foundationImageUrl;

    _principlesTagEnCtrl = TextEditingController(text: about.valuesTagEn);
    _principlesTagGuCtrl = TextEditingController(text: about.valuesTagGu);
    _principlesTitleEnCtrl = TextEditingController(text: about.valuesTitleEn);
    _principlesTitleGuCtrl = TextEditingController(text: about.valuesTitleGu);

    _committeeBadgeEnCtrl = TextEditingController(text: about.committeeBadgeEn);
    _committeeBadgeGuCtrl = TextEditingController(text: about.committeeBadgeGu);
    _committeeTitleEnCtrl = TextEditingController(text: about.committeeTitleEn);
    _committeeTitleGuCtrl = TextEditingController(text: about.committeeTitleGu);
    _committeeDescEnCtrl = TextEditingController(text: about.committeeDescEn);
    _committeeDescGuCtrl = TextEditingController(text: about.committeeDescGu);

    _ctaTitleEnCtrl = TextEditingController(text: about.ctaTitleEn);
    _ctaTitleGuCtrl = TextEditingController(text: about.ctaTitleGu);
    _ctaDescEnCtrl = TextEditingController(text: about.ctaDescEn);
    _ctaDescGuCtrl = TextEditingController(text: about.ctaDescGu);
    _ctaBtnTextEnCtrl = TextEditingController(text: about.ctaBtnTextEn);
    _ctaBtnTextGuCtrl = TextEditingController(text: about.ctaBtnTextGu);
    _ctaRouteCtrl = TextEditingController(text: about.ctaRoute);

    _attachLivePreviewListeners();
  }

  void _attachLivePreviewListeners() {
    final controllers = [
      _tagBadgeEnCtrl, _tagBadgeGuCtrl, _titleEnCtrl, _titleGuCtrl, _descEnCtrl, _descGuCtrl,
      _historyTitleEnCtrl, _historyTitleGuCtrl, _historyBodyEnCtrl, _historyBodyGuCtrl,
      _historyMottoEnCtrl, _historyMottoGuCtrl, _principlesTagEnCtrl, _principlesTagGuCtrl,
      _principlesTitleEnCtrl, _principlesTitleGuCtrl, _committeeBadgeEnCtrl, _committeeBadgeGuCtrl,
      _committeeTitleEnCtrl, _committeeTitleGuCtrl, _committeeDescEnCtrl, _committeeDescGuCtrl,
      _ctaTitleEnCtrl, _ctaTitleGuCtrl, _ctaDescEnCtrl, _ctaDescGuCtrl,
      _ctaBtnTextEnCtrl, _ctaBtnTextGuCtrl, _ctaRouteCtrl,
    ];
    for (final c in controllers) {
      c.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreUpdated);
    _tagBadgeEnCtrl.dispose();
    _tagBadgeGuCtrl.dispose();
    _titleEnCtrl.dispose();
    _titleGuCtrl.dispose();
    _descEnCtrl.dispose();
    _descGuCtrl.dispose();

    _historyTitleEnCtrl.dispose();
    _historyTitleGuCtrl.dispose();
    _historyBodyEnCtrl.dispose();
    _historyBodyGuCtrl.dispose();
    _historyMottoEnCtrl.dispose();
    _historyMottoGuCtrl.dispose();

    _principlesTagEnCtrl.dispose();
    _principlesTagGuCtrl.dispose();
    _principlesTitleEnCtrl.dispose();
    _principlesTitleGuCtrl.dispose();

    _committeeBadgeEnCtrl.dispose();
    _committeeBadgeGuCtrl.dispose();
    _committeeTitleEnCtrl.dispose();
    _committeeTitleGuCtrl.dispose();
    _committeeDescEnCtrl.dispose();
    _committeeDescGuCtrl.dispose();

    _ctaTitleEnCtrl.dispose();
    _ctaTitleGuCtrl.dispose();
    _ctaDescEnCtrl.dispose();
    _ctaDescGuCtrl.dispose();
    _ctaBtnTextEnCtrl.dispose();
    _ctaBtnTextGuCtrl.dispose();
    _ctaRouteCtrl.dispose();
    _memberSearchCtrl.dispose();

    super.dispose();
  }

  Future<void> _saveAllAboutPage() async {
    final updated = AdminAboutPageData(
      tagBadgeEn: _tagBadgeEnCtrl.text.trim(),
      tagBadgeGu: _tagBadgeGuCtrl.text.trim(),
      titleEn: _titleEnCtrl.text.trim(),
      titleGu: _titleGuCtrl.text.trim(),
      descEn: _descEnCtrl.text.trim(),
      descGu: _descGuCtrl.text.trim(),
      foundationTitleEn: _historyTitleEnCtrl.text.trim(),
      foundationTitleGu: _historyTitleGuCtrl.text.trim(),
      foundationDescEn: _historyBodyEnCtrl.text.trim(),
      foundationDescGu: _historyBodyGuCtrl.text.trim(),
      foundationMottoEn: _historyMottoEnCtrl.text.trim(),
      foundationMottoGu: _historyMottoGuCtrl.text.trim(),
      foundationImageUrl: _foundationImageUrl,
      valuesTagEn: _principlesTagEnCtrl.text.trim(),
      valuesTagGu: _principlesTagGuCtrl.text.trim(),
      valuesTitleEn: _principlesTitleEnCtrl.text.trim(),
      valuesTitleGu: _principlesTitleGuCtrl.text.trim(),
      committeeBadgeEn: _committeeBadgeEnCtrl.text.trim(),
      committeeBadgeGu: _committeeBadgeGuCtrl.text.trim(),
      committeeTitleEn: _committeeTitleEnCtrl.text.trim(),
      committeeTitleGu: _committeeTitleGuCtrl.text.trim(),
      committeeDescEn: _committeeDescEnCtrl.text.trim(),
      committeeDescGu: _committeeDescGuCtrl.text.trim(),
      ctaTitleEn: _ctaTitleEnCtrl.text.trim(),
      ctaTitleGu: _ctaTitleGuCtrl.text.trim(),
      ctaDescEn: _ctaDescGuCtrl.text.trim(),
      ctaDescGu: _ctaDescGuCtrl.text.trim(),
      ctaBtnTextEn: _ctaBtnTextEnCtrl.text.trim(),
      ctaBtnTextGu: _ctaBtnTextGuCtrl.text.trim(),
      ctaRoute: _ctaRouteCtrl.text.trim().isEmpty ? '/history' : _ctaRouteCtrl.text.trim(),
    );

    await widget.store.saveAboutPageContent(updated);

    if (mounted) {
      MyAppToastMessage.success(
        context,
        title: 'About Page Saved',
        description: 'About page content has been saved successfully.',
      );
    }
  }



  /// Helper to render responsive input fields without horizontal RenderFlex overflow
  Widget _buildResponsiveFields({
    required BuildContext context,
    required Widget first,
    required Widget second,
    Widget? third,
  }) {
    final isMobile = MediaQuery.sizeOf(context).width < 768;
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          first,
          const SizedBox(height: 12),
          second,
          if (third != null) ...[
            const SizedBox(height: 12),
            third,
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        const SizedBox(width: 12),
        Expanded(child: second),
        if (third != null) ...[
          const SizedBox(width: 12),
          Expanded(child: third),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
    Widget? action,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.heritageGold, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: styles.editorialSerif(
                    context,
                    size: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 8),
            action,
          ],
        ],
      );
    }

    return Row(
      children: [
        Icon(icon, color: colors.heritageGold, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: styles.editorialSerif(
              context,
              size: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: 12),
          action,
        ],
      ],
    );
  }

  // --- CULTURAL PRINCIPLES DIALOG ---
  void _openPrincipleDialog([AdminAboutPrinciple? principle]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final numberCtrl = TextEditingController(text: principle?.number ?? '૦${widget.store.aboutPrinciples.length + 1}');
    final titleEnCtrl = TextEditingController(text: principle?.titleEn ?? '');
    final titleGuCtrl = TextEditingController(text: principle?.titleGu ?? '');
    final descEnCtrl = TextEditingController(text: principle?.descEn ?? '');
    final descGuCtrl = TextEditingController(text: principle?.descGu ?? '');
    final maxOrder = widget.store.aboutPrinciples.isEmpty
        ? 0
        : widget.store.aboutPrinciples.map((p) => p.order).reduce((a, b) => a > b ? a : b);
    final assignedOrder = principle?.order ?? (maxOrder + 1);
    final orderCtrl = TextEditingController(text: '#$assignedOrder (Auto-assigned)');
    String iconKey = principle?.iconKey ?? 'verified';

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: colors.heritageGold, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  principle == null ? 'Add Cultural Principle' : 'Edit Cultural Principle',
                  style: styles.editorialSerif(context, size: 19, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: numberCtrl,
                          labelText: 'Number Badge (e.g. ૦૧, ૦૨)',
                          showClearIcon: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyAppTextFormField(
                          controller: orderCtrl,
                          labelText: 'Display Order',
                          readOnly: true,
                          enabled: false,
                          prefixIcon: const Icon(Icons.drag_indicator_rounded, size: 18),
                          showClearIcon: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleEnCtrl,
                    targetLanguageController: titleGuCtrl,
                    labelText: 'Title (English)',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: titleGuCtrl,
                    labelText: 'Title (Gujarati)',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descEnCtrl,
                    targetLanguageController: descGuCtrl,
                    labelText: 'Description (English)',
                    minLines: 2,
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextAreaField(
                    controller: descGuCtrl,
                    labelText: 'Description (Gujarati)',
                    minLines: 2,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 14),

                  const SizedBox(height: 8),
                  Text('Select Icon Style:', style: styles.cleanSans(context, size: 12.5, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildIconChoice(context, 'verified', Icons.verified_rounded, 'Verified', iconKey, (k) => setDlgState(() => iconKey = k)),
                      _buildIconChoice(context, 'favorite', Icons.favorite_rounded, 'Devotion', iconKey, (k) => setDlgState(() => iconKey = k)),
                      _buildIconChoice(context, 'book', Icons.auto_stories_rounded, 'Sahitya', iconKey, (k) => setDlgState(() => iconKey = k)),
                      _buildIconChoice(context, 'history', Icons.history_edu_rounded, 'Heritage', iconKey, (k) => setDlgState(() => iconKey = k)),
                      _buildIconChoice(context, 'music', Icons.music_note_rounded, 'Acoustic', iconKey, (k) => setDlgState(() => iconKey = k)),
                      _buildIconChoice(context, 'shield', Icons.shield_outlined, 'Purity', iconKey, (k) => setDlgState(() => iconKey = k)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              label: principle == null ? 'Add Principle' : 'Save Changes',
              onPressed: () {
                final titleEn = titleEnCtrl.text.trim();
                final titleGu = titleGuCtrl.text.trim();
                if (titleEn.isEmpty && titleGu.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Title Required', description: 'Please enter a principle title.');
                  return;
                }

                final order = assignedOrder;
                final item = AdminAboutPrinciple(
                  id: principle?.id ?? 'principle-${DateTime.now().millisecondsSinceEpoch}',
                  number: numberCtrl.text.trim().isEmpty ? '૦૧' : numberCtrl.text.trim(),
                  titleEn: titleEn,
                  titleGu: titleGu,
                  descEn: descEnCtrl.text.trim(),
                  descGu: descGuCtrl.text.trim(),
                  iconKey: iconKey,
                  order: order,
                );

                Navigator.pop(ctx);
                if (principle == null) {
                  widget.store.addAboutPrinciple(item);
                  MyAppToastMessage.success(context, title: 'Principle Added', description: 'New cultural principle added successfully.');
                } else {
                  widget.store.updateAboutPrinciple(item);
                  MyAppToastMessage.success(context, title: 'Principle Updated', description: 'Cultural principle updated successfully.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconChoice(
    BuildContext context,
    String key,
    IconData icon,
    String label,
    String currentKey,
    ValueChanged<String> onSelect,
  ) {
    return MyAppIconButtonWithName(
      icon: icon,
      name: label,
      isSelected: currentKey == key,
      onPressed: () => onSelect(key),
    );
  }

  void _confirmDeletePrinciple(AdminAboutPrinciple principle) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Principle?'),
        content: Text('Are you sure you want to delete "${principle.titleEn.isNotEmpty ? principle.titleEn : principle.titleGu}"?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () {
              Navigator.pop(ctx);
              widget.store.deleteAboutPrinciple(principle.id);
              MyAppToastMessage.success(context, title: 'Deleted', description: 'Principle removed successfully.');
            },
          ),
        ],
      ),
    );
  }

  // --- COMMITTEE MEMBERS DIALOG ---
  void _openMemberDialog([AdminCommitteeMember? member]) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();

    final nameEnCtrl = TextEditingController(text: member?.nameEn ?? '');
    final nameGuCtrl = TextEditingController(text: member?.nameGu ?? '');
    final desigEnCtrl = TextEditingController(text: member?.designationEn ?? '');
    final desigGuCtrl = TextEditingController(text: member?.designationGu ?? '');
    final phoneCtrl = TextEditingController(text: member?.phone ?? '');
    final maxMemberOrder = widget.store.committeeMembers.isEmpty
        ? 0
        : widget.store.committeeMembers.map((m) => m.order).reduce((a, b) => a > b ? a : b);
    final assignedMemberOrder = member?.order ?? (maxMemberOrder + 1);
    final orderCtrl = TextEditingController(text: '#$assignedMemberOrder');
    String photoUrl = member?.photoUrl ?? 'assets/images/pavan_putra_logo.png';
    bool isActive = member?.isActive ?? true;

    showMyAppDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: colors.getCardBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
          ),
          title: Row(
            children: [
              Icon(Icons.groups_rounded, color: colors.heritageGold, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  member == null ? 'Add Committee Member' : 'Edit Member Details',
                  style: styles.editorialSerif(context, size: 19, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width < 540 ? double.infinity : 520,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyAppImagePicker(
                    label: 'Member Photograph',
                    isCircle: true,
                    height: 130,
                    initialImageUrl: photoUrl,
                    onImageChanged: (url) => setDlgState(() => photoUrl = url),
                  ),
                  const SizedBox(height: 14),
                  MyAppTextFormField(
                    controller: nameEnCtrl,
                    targetLanguageController: nameGuCtrl,
                    labelText: 'Full Name (English)',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: nameGuCtrl,
                    labelText: 'Full Name (Gujarati)',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: desigEnCtrl,
                    targetLanguageController: desigGuCtrl,
                    labelText: 'Role / Designation (English)',
                    showTranslateIcon: true,
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  MyAppTextFormField(
                    controller: desigGuCtrl,
                    labelText: 'Role / Designation (Gujarati)',
                    showClearIcon: true,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MyAppTextFormField(
                          controller: phoneCtrl,
                          labelText: 'Contact Phone (Optional)',
                          showClearIcon: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: MyAppTextFormField(
                          controller: orderCtrl,
                          labelText: 'Display Order',
                          readOnly: true,
                          enabled: false,
                          prefixIcon: const Icon(Icons.drag_indicator_rounded, size: 18),
                          showClearIcon: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Checkbox(value: isActive, onChanged: (v) => setDlgState(() => isActive = v ?? true)),
                      const Text('Active Member'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
            MyAppFillButton(
              label: member == null ? 'Add Member' : 'Save Changes',
              onPressed: () {
                final nameEn = nameEnCtrl.text.trim();
                if (nameEn.isEmpty) {
                  MyAppToastMessage.warning(context, title: 'Name Required', description: 'Please enter member full name.');
                  return;
                }

                final order = assignedMemberOrder;
                final item = AdminCommitteeMember(
                  id: member?.id ?? 'cm-${DateTime.now().millisecondsSinceEpoch}',
                  nameEn: nameEn,
                  nameGu: nameGuCtrl.text.trim(),
                  designationEn: desigEnCtrl.text.trim(),
                  designationGu: desigGuCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  photoUrl: photoUrl,
                  order: order,
                  isActive: isActive,
                );

                Navigator.pop(ctx);
                if (member == null) {
                  widget.store.addCommitteeMember(item);
                  MyAppToastMessage.success(context, title: 'Member Added', description: 'Committee member added successfully.');
                } else {
                  widget.store.updateCommitteeMember(item);
                  MyAppToastMessage.success(context, title: 'Member Updated', description: 'Committee member updated successfully.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMember(AdminCommitteeMember member) {
    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Committee Member?'),
        content: Text('Are you sure you want to remove "${member.nameEn}" from the committee list?'),
        actions: [
          MyAppTextButton(onPressed: () => Navigator.pop(ctx), label: 'Cancel'),
          MyAppFillButton(
            isDanger: true,
            label: 'Delete',
            onPressed: () {
              Navigator.pop(ctx);
              widget.store.deleteCommitteeMember(member.id);
              MyAppToastMessage.success(context, title: 'Deleted', description: 'Member removed from committee list.');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminWebsiteContextBanner(
          websitePageTitle: 'About Us Page',
          websiteRoute: '/about',
          explanation: 'Controls what visitors and devotees see on the About Us page: foundation story, cultural values, and committee members.',
        ),
        const SizedBox(height: 12),

        // TOP BAR: ACTIONS & PREVIEW TOGGLE
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 18),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 14,
            spacing: 12,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HeritageBadge(label: 'ABOUT US'),
                    const SizedBox(height: 6),
                    Text(
                      'About Page Content',
                      style: styles.editorialSerif(context, size: isMobile ? 20 : 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage the Mandal history, sacred values, emblem photo, organizing committee, and page links.',
                      style: styles.cleanSans(context, size: 12.5, color: colors.getSecondaryTextColor(context)),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Real-time preview language toggle
                  MyAppSegmentView.language(
                    selectedLanguage: _previewLang,
                    onLanguageChanged: (lang) => setState(() => _previewLang = lang),
                  ),

                  // Save Button
                  MyAppFillButton.icon(
                    onPressed: _saveAllAboutPage,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: 'Save About Page',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 1: HEADER & STORY INTRODUCTION
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context: context,
                icon: Icons.title_rounded,
                title: '1. Page Header & Story Introduction',
              ),
              const SizedBox(height: 16),

              // Live Preview Box for Header (First in Section)
              _buildHeaderPreviewBox(context),
              const SizedBox(height: 20),

              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _tagBadgeEnCtrl,
                  targetLanguageController: _tagBadgeGuCtrl,
                  labelText: 'Top Badge (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _tagBadgeGuCtrl,
                  labelText: 'Top Badge (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _titleEnCtrl,
                  targetLanguageController: _titleGuCtrl,
                  labelText: 'Main Title (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _titleGuCtrl,
                  labelText: 'Main Title (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextAreaField(
                  controller: _descEnCtrl,
                  targetLanguageController: _descGuCtrl,
                  minLines: 3,
                  labelText: 'Introductory Story (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextAreaField(
                  controller: _descGuCtrl,
                  minLines: 3,
                  labelText: 'Introductory Story (Gujarati)',
                  showClearIcon: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 2: HERITAGE & FOUNDATION STORY
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context: context,
                icon: Icons.history_edu_rounded,
                title: '2. Heritage & Foundation Story',
              ),
              const SizedBox(height: 16),

              // Live Preview Box for Foundation Card (First in Section)
              _buildFoundationPreviewBox(context),
              const SizedBox(height: 20),

              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _historyTitleEnCtrl,
                  targetLanguageController: _historyTitleGuCtrl,
                  labelText: 'Card Title (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _historyTitleGuCtrl,
                  labelText: 'Card Title (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextAreaField(
                  controller: _historyBodyEnCtrl,
                  targetLanguageController: _historyBodyGuCtrl,
                  minLines: 3,
                  labelText: 'Heritage Story (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextAreaField(
                  controller: _historyBodyGuCtrl,
                  minLines: 3,
                  labelText: 'Heritage Story (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _historyMottoEnCtrl,
                  targetLanguageController: _historyMottoGuCtrl,
                  labelText: 'Sacred Motto (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _historyMottoGuCtrl,
                  labelText: 'Sacred Motto (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 16),
              MyAppImagePicker(
                label: 'Mandal Emblem / Photo',
                initialImageUrl: _foundationImageUrl,
                isCircle: true,
                height: 130,
                onImageChanged: (url) => setState(() => _foundationImageUrl = url),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 3: CULTURAL VALUES & PRINCIPLES
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context: context,
                icon: Icons.auto_stories_rounded,
                title: '3. Cultural Values & Principles',
                action: MyAppFillButton.icon(
                  onPressed: () => _openPrincipleDialog(),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: 'Add Principle',
                ),
              ),
              const SizedBox(height: 14),

              // Live Preview Box for Principles (First in Section)
              _buildPrinciplesPreviewBox(context),
              const SizedBox(height: 20),

              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _principlesTagEnCtrl,
                  targetLanguageController: _principlesTagGuCtrl,
                  labelText: 'Section Badge (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _principlesTagGuCtrl,
                  labelText: 'Section Badge (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _principlesTitleEnCtrl,
                  targetLanguageController: _principlesTitleGuCtrl,
                  labelText: 'Section Title (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _principlesTitleGuCtrl,
                  labelText: 'Section Title (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 18),

              // Principles list
              if (widget.store.aboutPrinciples.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.getSurfaceColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 36, color: colors.heritageGold),
                      const SizedBox(height: 8),
                      Text('No principles added yet.', style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Click "Add Principle" above to add cultural principles.', style: styles.cleanSans(context, size: 12.5)),
                    ],
                  ),
                )
              else
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: widget.store.aboutPrinciples.length,
                    onReorderItem: (oldIndex, newIndex) {
                      widget.store.reorderAboutPrinciples(oldIndex, newIndex);
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      final principle = widget.store.aboutPrinciples[index];
                      return Container(
                        key: ValueKey(principle.id),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.25)),
                        ),
                        child: isMobile
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Tooltip(
                                          message: 'Drag to reorder',
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 22),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: colors.heritageGold.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          principle.number,
                                          style: styles.devotionalMotto(context, size: 16, color: colors.heritageGold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(principle.iconData, color: colors.heritageGold, size: 20),
                                      const Spacer(),
                                      MyAppIconButton(
                                        tooltip: 'Edit Principle',
                                        icon: const Icon(Icons.edit_outlined, size: 18),
                                        color: colors.heritageGold,
                                        onPressed: () => _openPrincipleDialog(principle),
                                      ),
                                      MyAppIconButton(
                                        tooltip: 'Delete Principle',
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                        color: Colors.redAccent,
                                        onPressed: () => _confirmDeletePrinciple(principle),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    principle.titleEn,
                                    style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                                  ),
                                  if (principle.titleGu.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      principle.titleGu,
                                      style: styles.devotionalMotto(context, size: 13, color: colors.heritageGold),
                                    ),
                                  ],
                                  if (principle.descEn.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      principle.descEn,
                                      style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                                    ),
                                  ],
                                ],
                              )
                            : Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: Tooltip(
                                      message: 'Drag to reorder',
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 22),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: colors.heritageGold.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      principle.number,
                                      style: styles.devotionalMotto(context, size: 16, color: colors.heritageGold),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(principle.iconData, color: colors.heritageGold, size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          principle.titleEn,
                                          style: styles.editorialSerif(context, size: 14.5, fontWeight: FontWeight.w700),
                                        ),
                                        if (principle.titleGu.isNotEmpty)
                                          Text(
                                            principle.titleGu,
                                            style: styles.devotionalMotto(context, size: 12.5, color: colors.heritageGold),
                                          ),
                                        if (principle.descEn.isNotEmpty)
                                          Text(
                                            principle.descEn,
                                            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                  MyAppIconButton(
                                    tooltip: 'Edit Principle',
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    color: colors.heritageGold,
                                    onPressed: () => _openPrincipleDialog(principle),
                                  ),
                                  MyAppIconButton(
                                    tooltip: 'Delete Principle',
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    color: Colors.redAccent,
                                    onPressed: () => _confirmDeletePrinciple(principle),
                                  ),
                                ],
                              ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 4: ORGANIZING COMMITTEE & TRUSTEES
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context: context,
                icon: Icons.groups_rounded,
                title: '4. Organizing Committee & Trustees',
                action: MyAppFillButton.icon(
                  onPressed: () => _openMemberDialog(),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: 'Add Member',
                ),
              ),
              const SizedBox(height: 14),

              // Live Preview Box for Committee Members (First in Section)
              _buildCommitteePreviewBox(context),
              const SizedBox(height: 20),

              // Section Header Controls
              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _committeeBadgeEnCtrl,
                  targetLanguageController: _committeeBadgeGuCtrl,
                  labelText: 'Section Badge (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _committeeBadgeGuCtrl,
                  labelText: 'Section Badge (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _committeeTitleEnCtrl,
                  targetLanguageController: _committeeTitleGuCtrl,
                  labelText: 'Section Title (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _committeeTitleGuCtrl,
                  labelText: 'Section Title (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _committeeDescEnCtrl,
                  targetLanguageController: _committeeDescGuCtrl,
                  labelText: 'Section Subtitle (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _committeeDescGuCtrl,
                  labelText: 'Section Subtitle (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 18),

              // Member Search Bar
              MyAppTextFormField(
                controller: _memberSearchCtrl,
                hintText: 'Search member by name, role, or phone...',
                prefixIcon: const Icon(Icons.search_rounded),
                showClearIcon: true,
                onChanged: (val) => setState(() => _memberSearchQuery = val.trim()),
              ),
              const SizedBox(height: 14),

              // Members List
              _buildMembersList(context),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // SECTION 5: HISTORY LINK CARD
        CulturalFrameCard(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                context: context,
                icon: Icons.call_made_rounded,
                title: '5. History Link Card',
              ),
              const SizedBox(height: 16),

              // Live Preview Box for Callout Card (First in Section)
              _buildCtaPreviewBox(context),
              const SizedBox(height: 20),

              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _ctaTitleEnCtrl,
                  targetLanguageController: _ctaTitleGuCtrl,
                  labelText: 'Card Title (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _ctaTitleGuCtrl,
                  labelText: 'Card Title (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _ctaDescEnCtrl,
                  targetLanguageController: _ctaDescGuCtrl,
                  labelText: 'Card Subtitle (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _ctaDescGuCtrl,
                  labelText: 'Card Subtitle (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              _buildResponsiveFields(
                context: context,
                first: MyAppTextFormField(
                  controller: _ctaBtnTextEnCtrl,
                  targetLanguageController: _ctaBtnTextGuCtrl,
                  labelText: 'Button Text (English)',
                  showTranslateIcon: true,
                  showClearIcon: true,
                ),
                second: MyAppTextFormField(
                  controller: _ctaBtnTextGuCtrl,
                  labelText: 'Button Text (Gujarati)',
                  showClearIcon: true,
                ),
              ),
              const SizedBox(height: 12),
              MyAppDropdown.pageDestination(
                controller: _ctaRouteCtrl,
                labelText: 'Button Destination Page (કયા પેજ પર જવું)',
                defaultRoute: '/history',
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMembersList(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    final allMembers = widget.store.committeeMembers;
    final isFiltering = _memberSearchQuery.isNotEmpty;
    final filtered = !isFiltering
        ? allMembers
        : allMembers.where((m) {
            return m.nameEn.toLowerCase().contains(_memberSearchQuery) ||
                m.nameGu.toLowerCase().contains(_memberSearchQuery) ||
                m.designationEn.toLowerCase().contains(_memberSearchQuery) ||
                m.designationGu.toLowerCase().contains(_memberSearchQuery) ||
                m.phone.toLowerCase().contains(_memberSearchQuery);
          }).toList();

    if (allMembers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.group_off_rounded, size: 36, color: colors.heritageGold),
            const SizedBox(height: 8),
            Text('No committee members currently added.', style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Click "Add Member" above to add committee members.', style: styles.cleanSans(context, size: 12.5)),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: Text('No members match "$_memberSearchQuery".')),
      );
    }

    Widget buildMemberItem(AdminCommitteeMember member, int index, {bool canDrag = false}) {
      return Container(
        key: ValueKey(member.id),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.heritageGold.withValues(alpha: 0.25)),
        ),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (canDrag)
                        ReorderableDragStartListener(
                          index: index,
                          child: Tooltip(
                            message: 'Drag to reorder',
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 22),
                            ),
                          ),
                        ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.heritageGold, width: 1.5),
                        ),
                        child: ClipOval(
                          child: member.photoUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: member.photoUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                                  errorWidget: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.png', fit: BoxFit.cover),
                                )
                              : Image.asset(
                                  member.photoUrl.isNotEmpty ? member.photoUrl : 'assets/images/pavan_putra_logo.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.nameEn,
                              style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                            ),
                            if (member.nameGu.isNotEmpty)
                              Text(
                                member.nameGu,
                                style: styles.devotionalMotto(context, size: 13, color: colors.heritageGold),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.heritageGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${index + 1}',
                          style: styles.cleanSans(context, size: 11, fontWeight: FontWeight.bold, color: colors.heritageGold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${member.designationEn}${member.designationGu.isNotEmpty ? " • ${member.designationGu}" : ""}',
                    style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600, color: colors.heritageGold),
                  ),
                  if (member.phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: colors.getSecondaryTextColor(context)),
                        const SizedBox(width: 6),
                        Text(
                          member.phone,
                          style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyAppTextButton.icon(
                        color: colors.heritageGold,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: 'Edit',
                        onPressed: () => _openMemberDialog(member),
                      ),
                      const SizedBox(width: 8),
                      MyAppTextButton.icon(
                        isDanger: true,
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: 'Delete',
                        onPressed: () => _confirmDeleteMember(member),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  if (canDrag)
                    ReorderableDragStartListener(
                      index: index,
                      child: Tooltip(
                        message: 'Drag to reorder',
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.drag_indicator_rounded, color: colors.heritageGold, size: 22),
                        ),
                      ),
                    ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.heritageGold, width: 1.5),
                    ),
                    child: ClipOval(
                      child: member.photoUrl.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: member.photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                              errorWidget: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.png', fit: BoxFit.cover),
                            )
                          : Image.asset(
                              member.photoUrl.isNotEmpty ? member.photoUrl : 'assets/images/pavan_putra_logo.png',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              member.nameEn,
                              style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                            ),
                            if (member.nameGu.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                '(${member.nameGu})',
                                style: styles.devotionalMotto(context, size: 12.5, color: colors.heritageGold),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${member.designationEn} • ${member.designationGu}${member.phone.isNotEmpty ? " • ${member.phone}" : ""}',
                          style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '#${index + 1}',
                    style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.bold, color: colors.heritageGold),
                  ),
                  const SizedBox(width: 6),
                  MyAppIconButton(
                    tooltip: 'Edit Member',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    color: colors.heritageGold,
                    onPressed: () => _openMemberDialog(member),
                  ),
                  MyAppIconButton(
                    tooltip: 'Delete Member',
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    color: Colors.redAccent,
                    onPressed: () => _confirmDeleteMember(member),
                  ),
                ],
              ),
      );
    }

    if (!isFiltering) {
      return Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: allMembers.length,
          onReorderItem: (oldIndex, newIndex) {
            widget.store.reorderCommitteeMembers(oldIndex, newIndex);
            setState(() {});
          },
          itemBuilder: (context, index) => buildMemberItem(allMembers[index], index, canDrag: true),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Filtering by "$_memberSearchQuery". Clear search to drag and reorder members.',
            style: styles.cleanSans(context, size: 12, color: colors.heritageGold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, index) => buildMemberItem(filtered[index], index, canDrag: false),
        ),
      ],
    );
  }

  // --- LIVE PREVIEW BOXES ---
  Widget _buildHeaderPreviewBox(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isGu = _previewLang == 'gu';

    final tag = isGu && _tagBadgeGuCtrl.text.trim().isNotEmpty ? _tagBadgeGuCtrl.text.trim() : _tagBadgeEnCtrl.text.trim();
    final title = isGu && _titleGuCtrl.text.trim().isNotEmpty ? _titleGuCtrl.text.trim() : _titleEnCtrl.text.trim();
    final desc = isGu && _descGuCtrl.text.trim().isNotEmpty ? _descGuCtrl.text.trim() : _descEnCtrl.text.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, size: 14, color: colors.heritageGold),
              const SizedBox(width: 6),
              Text(
                'Preview (${isGu ? "Gujarati" : "English"})',
                style: styles.cleanSans(context, size: 11, fontWeight: FontWeight.bold, color: colors.heritageGold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tag.isNotEmpty) HeritageBadge(label: tag),
          const SizedBox(height: 8),
          Text(title.isNotEmpty ? title : 'Page Title', style: styles.h2(context)),
          const SizedBox(height: 6),
          Text(
            desc.isNotEmpty ? desc : 'Introductory description will appear here...',
            style: styles.bodyText(context).copyWith(fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundationPreviewBox(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isGu = _previewLang == 'gu';

    final title = isGu && _historyTitleGuCtrl.text.trim().isNotEmpty ? _historyTitleGuCtrl.text.trim() : _historyTitleEnCtrl.text.trim();
    final body = isGu && _historyBodyGuCtrl.text.trim().isNotEmpty ? _historyBodyGuCtrl.text.trim() : _historyBodyEnCtrl.text.trim();
    final motto = isGu && _historyMottoGuCtrl.text.trim().isNotEmpty ? _historyMottoGuCtrl.text.trim() : _historyMottoEnCtrl.text.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: colors.deepMaroon,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.heritageGold, width: 1.5),
                  ),
                  child: ClipOval(
                    child: _foundationImageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: _foundationImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                            errorWidget: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.png', fit: BoxFit.cover),
                          )
                        : Image.asset(
                            _foundationImageUrl.isNotEmpty ? _foundationImageUrl : 'assets/images/pavan_putra_logo.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title.isNotEmpty ? title : 'Foundation Title',
                  textAlign: TextAlign.center,
                  style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700, color: colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  body.isNotEmpty ? body : 'Foundation story will appear here...',
                  textAlign: TextAlign.center,
                  style: styles.bodyText(context).copyWith(color: const Color(0xFFE2DDD1), fontSize: 13, height: 1.5),
                ),
                if (motto.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    motto,
                    textAlign: TextAlign.center,
                    style: styles.devotionalMotto(context, size: 16, color: colors.lightGold),
                  ),
                ],
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.heritageGold, width: 1.5),
                  ),
                  child: ClipOval(
                    child: _foundationImageUrl.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: _foundationImageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
                            errorWidget: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.png', fit: BoxFit.cover),
                          )
                        : Image.asset(
                            _foundationImageUrl.isNotEmpty ? _foundationImageUrl : 'assets/images/pavan_putra_logo.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isNotEmpty ? title : 'Foundation Title',
                        style: styles.editorialSerif(context, size: 17, fontWeight: FontWeight.w700, color: colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body.isNotEmpty ? body : 'Foundation story will appear here...',
                        style: styles.bodyText(context).copyWith(color: const Color(0xFFE2DDD1), fontSize: 13, height: 1.5),
                      ),
                      if (motto.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          motto,
                          style: styles.devotionalMotto(context, size: 16, color: colors.lightGold),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPrinciplesPreviewBox(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isGu = _previewLang == 'gu';

    final tag = isGu && _principlesTagGuCtrl.text.trim().isNotEmpty ? _principlesTagGuCtrl.text.trim() : _principlesTagEnCtrl.text.trim();
    final title = isGu && _principlesTitleGuCtrl.text.trim().isNotEmpty ? _principlesTitleGuCtrl.text.trim() : _principlesTitleEnCtrl.text.trim();
    final principles = widget.store.aboutPrinciples.take(2).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, size: 14, color: colors.heritageGold),
              const SizedBox(width: 6),
              Text(
                'Preview (${isGu ? "Gujarati" : "English"})',
                style: styles.cleanSans(context, size: 11, fontWeight: FontWeight.bold, color: colors.heritageGold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (tag.isNotEmpty) HeritageBadge(label: tag),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(title, style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.bold)),
          ],
          const SizedBox(height: 12),
          if (principles.isEmpty)
            const Text('No principles to preview.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: principles.map((p) {
                final text = p.getDisplayText(isGu ? 'gu' : 'en');
                return Container(
                  width: isMobile ? double.infinity : 320,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.getCardBackgroundColor(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.heritageGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.number,
                          style: styles.devotionalMotto(context, size: 14, color: colors.heritageGold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          text,
                          style: styles.bodyText(context).copyWith(fontSize: 12.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCommitteePreviewBox(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isGu = _previewLang == 'gu';

    final badge = isGu && _committeeBadgeGuCtrl.text.trim().isNotEmpty ? _committeeBadgeGuCtrl.text.trim() : _committeeBadgeEnCtrl.text.trim();
    final title = isGu && _committeeTitleGuCtrl.text.trim().isNotEmpty ? _committeeTitleGuCtrl.text.trim() : _committeeTitleEnCtrl.text.trim();
    final desc = isGu && _committeeDescGuCtrl.text.trim().isNotEmpty ? _committeeDescGuCtrl.text.trim() : _committeeDescEnCtrl.text.trim();
    final members = widget.store.committeeMembers.take(2).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.remove_red_eye_outlined, size: 14, color: colors.heritageGold),
              const SizedBox(width: 6),
              Text(
                'Preview (First 2 cards in ${isGu ? "Gujarati" : "English"})',
                style: styles.cleanSans(context, size: 11, fontWeight: FontWeight.bold, color: colors.heritageGold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (badge.isNotEmpty) HeritageBadge(label: badge),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(title, style: styles.editorialSerif(context, size: 16, fontWeight: FontWeight.bold)),
          ],
          if (desc.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(desc, style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context))),
          ],
          const SizedBox(height: 12),
          if (members.isEmpty)
            const Text('No committee members to preview.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: members.map((m) {
                final name = isGu && m.nameGu.isNotEmpty ? m.nameGu : m.nameEn;
                final desig = isGu && m.designationGu.isNotEmpty ? m.designationGu : m.designationEn;
                return Container(
                  width: isMobile ? (screenWidth < 480 ? double.infinity : 170) : 190,
                  decoration: BoxDecoration(
                    color: colors.getCardBackgroundColor(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.heritageGold.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        child: Container(
                          height: 110,
                          width: double.infinity,
                          color: colors.heritageGold.withValues(alpha: 0.05),
                          child: m.photoUrl.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: m.photoUrl,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => Image.asset('assets/images/pavan_putra_logo.png', fit: BoxFit.cover),
                                )
                              : Image.asset(m.photoUrl, fit: BoxFit.cover),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: styles.editorialSerif(context, size: 13, fontWeight: FontWeight.bold), maxLines: 1),
                            const SizedBox(height: 2),
                            Text(desig, style: styles.cleanSans(context, size: 11, color: colors.heritageGold), maxLines: 1),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCtaPreviewBox(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isGu = _previewLang == 'gu';

    final title = isGu && _ctaTitleGuCtrl.text.trim().isNotEmpty ? _ctaTitleGuCtrl.text.trim() : _ctaTitleEnCtrl.text.trim();
    final desc = isGu && _ctaDescGuCtrl.text.trim().isNotEmpty ? _ctaDescGuCtrl.text.trim() : _ctaDescEnCtrl.text.trim();
    final btn = isGu && _ctaBtnTextGuCtrl.text.trim().isNotEmpty ? _ctaBtnTextGuCtrl.text.trim() : _ctaBtnTextEnCtrl.text.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: colors.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.3)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.heritageGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.history_edu_rounded, color: colors.heritageGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : 'History Card Title',
                            style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            desc.isNotEmpty ? desc : 'History card description will appear here...',
                            style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MyAppFillButton(
                  isFullWidth: true,
                  onPressed: () {},
                  label: btn.isNotEmpty ? btn : 'View History',
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.heritageGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.history_edu_rounded, color: colors.heritageGold, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isNotEmpty ? title : 'History Card Title',
                        style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc.isNotEmpty ? desc : 'History card description will appear here...',
                        style: styles.cleanSans(context, size: 12, color: colors.getSecondaryTextColor(context)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                MyAppFillButton(
                  onPressed: () {},
                  label: btn.isNotEmpty ? btn : 'View History',
                ),
              ],
            ),
    );
  }
}
