import 'package:flutter/material.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../localization/google_translation_service.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';
import '../buttons/my_app_buttons.dart';
import '../toast/my_app_toast_message.dart';

/// --------------------------------------------------------------------------
/// MY APP TEXT AREA FIELD
/// Dedicated multiline text area with auto-height dynamic expansion.
/// Shares identical aesthetics with MyAppTextFormField:
/// - Floating notch label with rounded outline border (10px).
/// - Dynamic auto-height (minLines: 3-4, maxLines: null for dynamic expansion).
/// - Top-right aligned action suffix (Auto-translate + 'x' Clear).
/// - Purely validator-driven error border (red border, zero vertical layout shift,
///   and announces error message via MyAppToastMessage.warning).
/// - Theme-adaptive for Light & Dark modes.
/// - Scrollable inner text with generous scrollPadding (24px).
/// --------------------------------------------------------------------------
class MyAppTextAreaField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final bool showClearIcon;
  final bool showTranslateIcon;
  final TextEditingController? targetLanguageController;
  final Future<void> Function()? onTranslate;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool showToastOnError;
  final int minLines;
  final int? maxLines;
  final EdgeInsets scrollPadding;
  final bool readOnly;
  final bool enabled;
  final FocusNode? focusNode;

  const MyAppTextAreaField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.showClearIcon = true,
    this.showTranslateIcon = false,
    this.targetLanguageController,
    this.onTranslate,
    this.onClear,
    this.onChanged,
    this.validator,
    this.showToastOnError = true,
    this.minLines = 3,
    this.maxLines, // null by default for auto-height expansion!
    this.scrollPadding = const EdgeInsets.all(24),
    this.readOnly = false,
    this.enabled = true,
    this.focusNode,
  });

  @override
  State<MyAppTextAreaField> createState() => _MyAppTextAreaFieldState();
}

class _MyAppTextAreaFieldState extends State<MyAppTextAreaField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController => widget.controller ?? (_internalController ??= TextEditingController(text: widget.initialValue));

  bool _isTranslating = false;
  String? _lastErrorAnnounced;

  @override
  void initState() {
    super.initState();
    _effectiveController.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(MyAppTextAreaField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextChange);
      widget.controller?.addListener(_handleTextChange);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChange);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  Future<void> _handleAutoTranslate() async {
    if (_isTranslating) return;

    if (widget.onTranslate != null) {
      setState(() => _isTranslating = true);
      try {
        await widget.onTranslate!();
      } finally {
        if (mounted) setState(() => _isTranslating = false);
      }
      return;
    }

    final targetCtrl = widget.targetLanguageController;
    if (targetCtrl == null) return;

    final sourceText = _effectiveController.text.trim();
    if (sourceText.isEmpty) {
      MyAppToastMessage.warning(context, title: 'Translation Empty', description: 'Please type some text to translate.');
      return;
    }

    setState(() => _isTranslating = true);
    try {
      final translated = await GoogleTranslationService.instance.translateToGujarati(sourceText);
      targetCtrl.text = translated;
      if (mounted) {
        MyAppToastMessage.success(context, title: 'Auto-Translated', description: translated);
      }
    } catch (e) {
      if (mounted) {
        MyAppToastMessage.error(context, title: 'Translation Failed', description: 'Could not connect to translation service: $e');
      }
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isDark = colors.isDarkMode(context);
    final isMobile = MediaQuery.sizeOf(context).width < 768;

    final hasText = _effectiveController.text.isNotEmpty;
    final canTranslate = widget.showTranslateIcon && (widget.targetLanguageController != null || widget.onTranslate != null);
    final canClear = widget.showClearIcon && hasText && !widget.readOnly && widget.enabled;

    Widget? builtSuffix;
    if (canTranslate || canClear) {
      builtSuffix = Container(
        margin: const EdgeInsets.only(top: 8, right: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canTranslate) ...[
              if (_isTranslating)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else
                MyAppIconButton.translate(onPressed: _handleAutoTranslate, tooltip: 'Auto-translate to Gujarati'),
            ],
            if (canClear) MyAppIconButton.clear(onPressed: _handleClear, tooltip: 'Clear text'),
          ],
        ),
      );
    }

    return TextFormField(
      controller: _effectiveController,
      focusNode: widget.focusNode,
      keyboardType: TextInputType.multiline,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      // Dynamic auto-height
      scrollPadding: widget.scrollPadding,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      style: styles.cleanSans(context, size: isMobile ? 16 : 14, fontWeight: FontWeight.w500, color: colors.getPrimaryTextColor(context)),
      validator: (val) {
        if (widget.validator == null) return null;
        final error = widget.validator!(val);
        if (error != null && error.isNotEmpty) {
          if (widget.showToastOnError && _lastErrorAnnounced != error) {
            _lastErrorAnnounced = error;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                MyAppToastMessage.warning(context, title: widget.labelText ?? 'Validation Required', description: error);
              }
            });
          }
          // Return non-null string to activate errorBorder without expanding layout height:
          return ' ';
        }
        _lastErrorAnnounced = null;
        return null;
      },
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        isDense: true,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1B1B) : Colors.white,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        alignLabelWithHint: true,
        labelStyle: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w500, color: colors.getSecondaryTextColor(context)),
        hintStyle: styles.cleanSans(context, size: 13, color: colors.getMutedTextColor(context)),
        prefixIcon: widget.prefixIcon != null ? Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12), child: widget.prefixIcon) : null,
        suffixIcon: builtSuffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        // Error text style is 0 height to prevent vertical layout shift
        errorStyle: const TextStyle(fontSize: 0, height: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.getBorderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.getBorderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: isDark ? colors.lightGold : colors.heritageMaroon, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.sacredRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.sacredRed, width: 2.0),
        ),
      ),
    );
  }
}
