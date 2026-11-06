import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../localization/google_translation_service.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';
import '../buttons/my_app_buttons.dart';
import '../toast/my_app_toast_message.dart';

/// --------------------------------------------------------------------------
/// MY APP TEXT FORM FIELD
/// Standardized, elegant text form field matching Heritage Design System:
/// - Floating notch label with rounded outline border (10px).
/// - Dynamic 'x' clear suffix button (auto-detects text presence).
/// - Auto-translate action icon button (translates to Gujarati via GoogleTranslationService).
/// - Purely validator-driven error border (turns red, zero vertical layout shift,
///   and announces error message via MyAppToastMessage.warning).
/// - Theme-adaptive for Light & Dark modes.
/// - Scrollable inner text with generous scrollPadding (24px).
/// --------------------------------------------------------------------------
class MyAppTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearIcon;
  final bool showTranslateIcon;
  final TextEditingController? targetLanguageController;
  final Future<void> Function()? onTranslate;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final bool showToastOnError;
  final int? maxLines;
  final int minLines;
  final TextInputType keyboardType;
  final EdgeInsets scrollPadding;
  final bool readOnly;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const MyAppTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearIcon = true,
    this.showTranslateIcon = false,
    this.targetLanguageController,
    this.onTranslate,
    this.onClear,
    this.onChanged,
    this.onFieldSubmitted,
    this.validator,
    this.showToastOnError = true,
    this.maxLines = 1,
    this.minLines = 1,
    this.keyboardType = TextInputType.text,
    this.scrollPadding = const EdgeInsets.all(24),
    this.readOnly = false,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.inputFormatters,
  });

  @override
  State<MyAppTextFormField> createState() => _MyAppTextFormFieldState();
}

class _MyAppTextFormFieldState extends State<MyAppTextFormField> {
  TextEditingController? _internalController;

  TextEditingController get _effectiveController => widget.controller ?? (_internalController ??= TextEditingController(text: widget.initialValue));

  bool _isTranslating = false;
  String? _lastErrorAnnounced;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _effectiveController.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(MyAppTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.obscureText != oldWidget.obscureText) {
      _obscureText = widget.obscureText;
    }
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isMobileOrTablet = isMobile || isTablet;

    // Auto-height resolution for mobile and tablet views
    final int? effectiveMaxLines;
    if (widget.obscureText) {
      effectiveMaxLines = 1;
    } else if (isMobileOrTablet &&
        widget.maxLines == 1 &&
        widget.onFieldSubmitted == null &&
        widget.keyboardType != TextInputType.emailAddress &&
        widget.keyboardType != TextInputType.phone &&
        widget.keyboardType != TextInputType.number &&
        widget.keyboardType != TextInputType.datetime &&
        widget.keyboardType != TextInputType.url) {
      effectiveMaxLines = null;
    } else {
      effectiveMaxLines = widget.maxLines;
    }

    final hasText = _effectiveController.text.isNotEmpty;
    final canTranslate = widget.showTranslateIcon && (widget.targetLanguageController != null || widget.onTranslate != null);
    final canToggleVisibility = widget.obscureText;
    final canClear = widget.showClearIcon && hasText && !widget.readOnly && widget.enabled && !widget.obscureText;

    Widget? builtSuffix;
    if (canTranslate || canClear || canToggleVisibility || widget.suffixIcon != null) {
      builtSuffix = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (widget.suffixIcon != null) widget.suffixIcon!,
          if (canTranslate) ...[
            if (_isTranslating)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else
              MyAppIconButton.translate(onPressed: _handleAutoTranslate, tooltip: 'Auto-translate to Gujarati'),
          ],
          if (canClear) MyAppIconButton.clear(onPressed: _handleClear, tooltip: 'Clear text'),
          if (canToggleVisibility)
            IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: colors.getSecondaryTextColor(context)),
              splashRadius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: _obscureText ? 'Show password' : 'Hide password',
              onPressed: () {
                setState(() => _obscureText = !_obscureText);
              },
            ),
          const SizedBox(width: 4),
        ],
      );
    }

    return TextFormField(
      controller: _effectiveController,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType,
      maxLines: effectiveMaxLines,
      minLines: widget.minLines,
      scrollPadding: widget.scrollPadding,
      readOnly: widget.readOnly,
      obscureText: _obscureText,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      style: styles.cleanSans(context, size: isMobile ? 15 : 14, fontWeight: FontWeight.w500, color: colors.getPrimaryTextColor(context)),
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
        isDense: !isMobileOrTablet,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1B1B) : Colors.white,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: styles.cleanSans(context, size: 13, fontWeight: FontWeight.w500, color: colors.getSecondaryTextColor(context)),
        hintStyle: styles.cleanSans(context, size: 13, color: colors.getMutedTextColor(context)),
        prefixIcon: widget.prefixIcon != null ? Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: widget.prefixIcon) : null,
        prefixIconConstraints: isMobileOrTablet ? const BoxConstraints(minWidth: 42, minHeight: 42) : const BoxConstraints(minWidth: 38, minHeight: 38),
        suffixIcon: builtSuffix,
        suffixIconConstraints: isMobileOrTablet ? const BoxConstraints(minWidth: 42, minHeight: 42) : const BoxConstraints(minHeight: 38),
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: isMobileOrTablet ? 14 : 12),
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
