import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/theme_provider.dart';
import '../../../../logic/preview_provider.dart';
import '../../data/models/qr_code_model.dart';
import '../../logic/qr_export_service.dart';
import '../../logic/qr_provider.dart';
import '../widgets/adaptive_widgets.dart';
import '../widgets/qr_color_picker.dart';
import '../widgets/qr_preview_widget.dart';
import '../widgets/qr_shape_picker.dart';

class QRGeneratorScreen extends StatelessWidget {
  final String? qrId;

  const QRGeneratorScreen({super.key, this.qrId});

  bool _isTablet(BuildContext c) => MediaQuery.of(c).size.shortestSide >= 600;

  @override
  Widget build(BuildContext context) {
    final useCupertino = context.watch<PlatformProvider>().useCupertinoStyle;
    return useCupertino 
        ? _CupertinoQRGenerator(isTablet: _isTablet(context), qrId: qrId) 
        : _MaterialQRGenerator(isTablet: _isTablet(context), qrId: qrId);
  }
}

Future<void> _downloadQR(BuildContext context, QRProvider provider) async {
  if (!provider.validate()) {
    showAdaptiveFeedback(context, 'Please fill in all required fields correctly.', isError: true);
    return;
  }
  await QRExportService.downloadQRImage(
    provider.contentController.text,
    512,
    provider.currentDesign.foregroundColor,
    provider.currentDesign.backgroundColor,
    design: provider.currentDesign,
    fileName: 'qr_code.png',
  );
  if (context.mounted) {
    showAdaptiveFeedback(context, 'QR Code downloaded');
  }
}

Future<void> _handleSave(BuildContext context, QRProvider provider, String? qrId) async {
  if (!provider.validate()) {
    showAdaptiveFeedback(context, 'Please fill in all required fields correctly.', isError: true);
    return;
  }
  if (qrId == null) {
    await provider.createQR(provider.nameController.text, provider.selectedType, provider.contentController.text);
  } else {
    await provider.updateQR(provider.activeQR!.copyWith(name: provider.nameController.text, type: provider.selectedType, contentData: provider.contentController.text));
  }
  if (context.mounted) {
    context.go('/qr');
  }
}

// --------------------- Cupertino Implementation ---------------------

class _CupertinoQRGenerator extends StatelessWidget {
  final bool isTablet;
  final String? qrId;

  const _CupertinoQRGenerator({required this.isTablet, this.qrId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QRProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        border: const Border(bottom: BorderSide(color: CupertinoColors.transparent)),
        leading: CupertinoNavigationBarBackButton(onPressed: () => context.go('/qr'), color: themeProvider.seedColor),
        middle: Text(qrId == null ? 'Create QR Code' : 'Edit QR Code'),
        trailing: CupertinoButton(padding: EdgeInsets.zero, onPressed: () => _downloadQR(context, provider), child: const Icon(CupertinoIcons.arrow_down_circle)),
      ),
      child: SafeArea(
        bottom: false,
        child: isTablet
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: _CupertinoInputs(provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: CupertinoColors.separator),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: CupertinoColors.systemBackground.resolveFrom(context),
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _QRPreviewArea(provider: provider, size: 300),
                              const SizedBox(height: 48),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: _CupertinoActions(provider: provider, themeProvider: themeProvider, qrId: qrId),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  const SizedBox(height: 24),
                  _QRPreviewArea(provider: provider, size: 250),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 100),
                      children: [
                        _CupertinoInputs(provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _CupertinoActions(provider: provider, themeProvider: themeProvider, qrId: qrId),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CupertinoInputs extends StatelessWidget {
  final QRProvider provider;
  final ThemeProvider themeProvider;
  final bool isDarkMode;

  const _CupertinoInputs({required this.provider, required this.themeProvider, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text('QR PROFILE', style: TextStyle(letterSpacing: 1.2, fontSize: 13, color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel.resolveFrom(context))),
          ),
          children: [
            CupertinoTextField(
              controller: provider.nameController,
              placeholder: 'e.g. My Website Link',
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefix: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Icon(CupertinoIcons.profile_circled, color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey, size: 20),
              ),
              style: TextStyle(color: isDarkMode ? CupertinoColors.white : CupertinoColors.black, fontSize: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.transparent,
                border: !provider.isNameValid ? Border.all(color: CupertinoColors.destructiveRed, width: 1.5) : null,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text('QR TYPE', style: TextStyle(letterSpacing: 1.2, fontSize: 13, color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel.resolveFrom(context))),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _TypeSelector(isIOS: true, provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text('CONTENT', style: TextStyle(letterSpacing: 1.2, fontSize: 13, color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel.resolveFrom(context))),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: _ContentInput(isIOS: true, provider: provider, isDarkMode: isDarkMode, themeProvider: themeProvider),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text('DESIGN & COLORS', style: TextStyle(letterSpacing: 1.2, fontSize: 13, color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel.resolveFrom(context))),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  QRColorPicker(
                    label: 'Foreground Color',
                    selectedColor: provider.currentDesign.foregroundColor,
                    onColorChanged: (c) => provider.updateDesign(provider.currentDesign.copyWith(foregroundColor: c)),
                  ),
                  const SizedBox(height: 20),
                  QRColorPicker(
                    label: 'Background Color',
                    selectedColor: provider.currentDesign.backgroundColor,
                    onColorChanged: (c) => provider.updateDesign(provider.currentDesign.copyWith(backgroundColor: c)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(height: 1, color: CupertinoColors.separator),
                  ),
                  QRShapePicker(
                    label: 'Eye Shape',
                    selectedShape: provider.currentDesign.eyeShape,
                    onShapeChanged: (v) => provider.updateDesign(provider.currentDesign.copyWith(eyeShape: v)),
                    options: const [
                      ShapeOption(value: 'square', label: 'Square', icon: CupertinoIcons.square),
                      ShapeOption(value: 'circle', label: 'Circle', icon: CupertinoIcons.circle),
                    ],
                  ),
                  const SizedBox(height: 20),
                  QRShapePicker(
                    label: 'Data Shape',
                    selectedShape: provider.currentDesign.dataShape,
                    onShapeChanged: (v) => provider.updateDesign(provider.currentDesign.copyWith(dataShape: v)),
                    options: const [
                      ShapeOption(value: 'square', label: 'Square', icon: CupertinoIcons.square),
                      ShapeOption(value: 'circle', label: 'Circle', icon: CupertinoIcons.circle),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CupertinoListSection.insetGrouped(
          header: Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text('LOGO & FRAME', style: TextStyle(letterSpacing: 1.2, fontSize: 13, color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.secondaryLabel.resolveFrom(context))),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _LogoSection(isIOS: true, provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
                  const SizedBox(height: 20),
                  _FrameSection(isIOS: true, provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CupertinoActions extends StatelessWidget {
  final QRProvider provider;
  final ThemeProvider themeProvider;
  final String? qrId;

  const _CupertinoActions({required this.provider, required this.themeProvider, this.qrId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (qrId != null && provider.activeQR != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: CupertinoColors.systemBackground, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Text('Created: ${provider.activeQR!.createdDate.toString().substring(0, 16)}', style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        SizedBox(
          width: double.infinity,
          child: CupertinoButton.filled(
            onPressed: () => _handleSave(context, provider, qrId),
            child: Text(qrId == null ? 'Create QR Code' : 'Update QR Code', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

// --------------------- Material Implementation ---------------------

class _MaterialQRGenerator extends StatelessWidget {
  final bool isTablet;
  final String? qrId;

  const _MaterialQRGenerator({required this.isTablet, this.qrId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QRProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/qr')),
        title: Text(qrId == null ? 'Create QR Code' : 'Edit QR Code'),
        actions: [IconButton(icon: const Icon(Icons.download), onPressed: () => _downloadQR(context, provider))],
      ),
      body: isTablet
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _MaterialInputs(provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
                  ),
                ),
                VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _QRPreviewArea(provider: provider, size: 300),
                            const SizedBox(height: 48),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: _MaterialActions(provider: provider, themeProvider: themeProvider, qrId: qrId),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _QRPreviewArea(provider: provider, size: 250),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _MaterialInputs(provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
                        const SizedBox(height: 32),
                        _MaterialActions(provider: provider, themeProvider: themeProvider, qrId: qrId),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MaterialInputs extends StatelessWidget {
  final QRProvider provider;
  final ThemeProvider themeProvider;
  final bool isDarkMode;

  const _MaterialInputs({required this.provider, required this.themeProvider, required this.isDarkMode});

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(context, 'Profile Details'),
        TextField(
          controller: provider.nameController,
          decoration: InputDecoration(
            labelText: 'QR Code Name',
            hintText: 'e.g. My Website Link',
            filled: true,
            fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: !provider.isNameValid ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: !provider.isNameValid ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: !provider.isNameValid ? const BorderSide(color: Colors.red, width: 2) : BorderSide(color: themeProvider.seedColor, width: 2),
            ),
            prefixIcon: Icon(Icons.badge_outlined, color: !provider.isNameValid ? Colors.red : null),
          ),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
        ),
        const SizedBox(height: 10),
        _sectionTitle(context, 'Content Type'),
        _TypeSelector(isIOS: false, provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
        const SizedBox(height: 10),
        _sectionTitle(context, 'Content Data'),
        _ContentInput(isIOS: false, provider: provider, isDarkMode: isDarkMode, themeProvider: themeProvider),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QRColorPicker(
              label: 'Foreground Color',
              selectedColor: provider.currentDesign.foregroundColor,
              onColorChanged: (c) => provider.updateDesign(provider.currentDesign.copyWith(foregroundColor: c)),
            ),
            const SizedBox(height: 10),
            QRColorPicker(
              label: 'Background Color',
              selectedColor: provider.currentDesign.backgroundColor,
              onColorChanged: (c) => provider.updateDesign(provider.currentDesign.copyWith(backgroundColor: c)),
            ),
            const SizedBox(height: 10),
            QRShapePicker(
              label: 'Eye Shape',
              selectedShape: provider.currentDesign.eyeShape,
              onShapeChanged: (v) => provider.updateDesign(provider.currentDesign.copyWith(eyeShape: v)),
              options: const [
                ShapeOption(value: 'square', label: 'Square', icon: Icons.crop_square),
                ShapeOption(value: 'circle', label: 'Circle', icon: Icons.radio_button_unchecked),
              ],
            ),
            const SizedBox(height: 10),
            QRShapePicker(
              label: 'Data Shape',
              selectedShape: provider.currentDesign.dataShape,
              onShapeChanged: (v) => provider.updateDesign(provider.currentDesign.copyWith(dataShape: v)),
              options: const [
                ShapeOption(value: 'square', label: 'Square', icon: Icons.crop_square),
                ShapeOption(value: 'circle', label: 'Circle', icon: Icons.radio_button_unchecked),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            _LogoSection(isIOS: false, provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
            const SizedBox(height: 10),
            _FrameSection(isIOS: false, provider: provider, themeProvider: themeProvider, isDarkMode: isDarkMode),
          ],
        ),
      ],
    );
  }
}

class _MaterialActions extends StatelessWidget {
  final QRProvider provider;
  final ThemeProvider themeProvider;
  final String? qrId;

  const _MaterialActions({required this.provider, required this.themeProvider, this.qrId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (qrId != null && provider.activeQR != null) ...[
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Created: ${provider.activeQR!.createdDate.toString().substring(0, 16)}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        FilledButton(
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () => _handleSave(context, provider, qrId),
          child: Text(qrId == null ? 'Create QR Code' : 'Update QR Code', style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

// --------------------- Shared Components ---------------------

class _QRPreviewArea extends StatelessWidget {
  final QRProvider provider;
  final double size;

  const _QRPreviewArea({required this.provider, required this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: QRPreviewWidget(data: provider.contentController.text, size: size, foregroundColor: provider.currentDesign.foregroundColor, backgroundColor: provider.currentDesign.backgroundColor),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  final bool isIOS;
  final QRProvider provider;
  final ThemeProvider themeProvider;
  final bool isDarkMode;

  const _TypeSelector({required this.isIOS, required this.provider, required this.themeProvider, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final types = [QRType.url, QRType.text, QRType.pdf, QRType.image, QRType.video];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types.map<Widget>((type) {
        final selected = provider.selectedType == type;

        if (isIOS) {
          return GestureDetector(
            onTap: () => provider.setSelectedType(type),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? themeProvider.seedColor : (isDarkMode ? CupertinoColors.secondaryLabel : CupertinoColors.systemGrey5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                type.name.toUpperCase(),
                style: TextStyle(
                  color: selected ? CupertinoColors.white : (isDarkMode ? CupertinoColors.white : CupertinoColors.black),
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        } else {
          return ChoiceChip(
            label: Text(type.name.toUpperCase()),
            selected: selected,
            showCheckmark: false,
            elevation: selected ? 2 : 0,
            pressElevation: 0,
            backgroundColor: isDarkMode ? Colors.black12 : Colors.grey[200],
            selectedColor: themeProvider.seedColor,
            labelStyle: TextStyle(color: selected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87), fontWeight: selected ? FontWeight.bold : FontWeight.w500, fontSize: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: selected ? themeProvider.seedColor : Colors.transparent),
            ),
            onSelected: (val) {
              if (val) provider.setSelectedType(type);
            },
          );
        }
      }).toList(),
    );
  }
}

class _ContentInput extends StatelessWidget {
  final bool isIOS;
  final QRProvider provider;
  final bool isDarkMode;
  final ThemeProvider themeProvider;

  const _ContentInput({required this.isIOS, required this.provider, required this.isDarkMode, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    if (provider.selectedType == QRType.pdf || provider.selectedType == QRType.image || provider.selectedType == QRType.video) {
      final label = provider.selectedType == QRType.pdf ? 'PDF File' : (provider.selectedType == QRType.image ? 'Image' : 'Video');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected $label:', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: !provider.isContentValid ? Colors.red : (isDarkMode ? Colors.white12 : Colors.black12)),
                  ),
                  child: Text(
                    provider.contentController.text.isEmpty ? 'No file selected' : provider.contentController.text,
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              isIOS
                  ? CupertinoButton(
                      color: themeProvider.seedColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      minSize: 0,
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(provider.selectedType == QRType.pdf ? CupertinoIcons.doc_fill : CupertinoIcons.camera_fill, color: Colors.white, size: 20),
                      onPressed: () {
                        if (provider.selectedType == QRType.pdf) {
                          provider.pickFileForType(provider.selectedType);
                        } else {
                          _showSourceActionSheet(context, provider, isIOS);
                        }
                      },
                    )
                  : IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: Theme.of(context).primaryColor),
                      icon: Icon(provider.selectedType == QRType.pdf ? Icons.upload_file : Icons.camera_alt, color: Colors.white, size: 20),
                      onPressed: () {
                        if (provider.selectedType == QRType.pdf) {
                          provider.pickFileForType(provider.selectedType);
                        } else {
                          _showSourceActionSheet(context, provider, isIOS);
                        }
                      },
                    ),
            ],
          ),
        ],
      );
    }

    if (isIOS) {
      return CupertinoTextField(
        controller: provider.contentController,
        placeholder: provider.selectedType == QRType.url ? 'https://example.com' : 'Enter text',
        keyboardType: provider.selectedType == QRType.url ? TextInputType.url : TextInputType.multiline,
        maxLines: provider.selectedType == QRType.text ? null : 1,
        minLines: provider.selectedType == QRType.text ? 4 : 1,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.systemGrey6.color,
          border: !provider.isContentValid ? Border.all(color: CupertinoColors.destructiveRed, width: 1.5) : null,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      return TextField(
        controller: provider.contentController,
        keyboardType: provider.selectedType == QRType.url ? TextInputType.url : TextInputType.multiline,
        maxLines: provider.selectedType == QRType.text ? null : 1,
        minLines: provider.selectedType == QRType.text ? 4 : 1,
        decoration: InputDecoration(
          hintText: provider.selectedType == QRType.url ? 'https://example.com' : 'Enter text',
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: !provider.isContentValid ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: !provider.isContentValid ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: !provider.isContentValid ? const BorderSide(color: Colors.red, width: 2) : BorderSide(color: themeProvider.seedColor, width: 2),
          ),
        ),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
      );
    }
  }

  Future<void> _showSourceActionSheet(BuildContext context, QRProvider provider, bool isIOS) async {
    if (isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: const Text('Select Source'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                provider.pickFileForType(provider.selectedType, source: ImageSource.camera);
              },
              child: const Text('Camera'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                provider.pickFileForType(provider.selectedType, source: ImageSource.gallery);
              },
              child: const Text('Gallery'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(isDestructiveAction: true, onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  provider.pickFileForType(provider.selectedType, source: ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  provider.pickFileForType(provider.selectedType, source: ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _LogoSection extends StatelessWidget {
  final bool isIOS;
  final QRProvider provider;
  final ThemeProvider themeProvider;
  final bool isDarkMode;

  const _LogoSection({required this.isIOS, required this.provider, required this.themeProvider, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final picker = ImagePicker();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (provider.currentDesign.logoBytes != null)
              Image.memory(provider.currentDesign.logoBytes!, height: 60)
            else if (provider.currentDesign.logoPath != null && provider.currentDesign.logoPath!.startsWith('assets/'))
              Image.asset(provider.currentDesign.logoPath!, height: 60),
            const SizedBox(width: 12),
            isIOS
                ? CupertinoButton(
                    color: themeProvider.seedColor,
                    borderRadius: BorderRadius.circular(8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minSize: 36,
                    child: const Text('Change Logo', style: TextStyle(fontSize: 14, color: CupertinoColors.white)),
                    onPressed: () async {
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) {
                        final bytes = await img.readAsBytes();
                        provider.updateDesign(provider.currentDesign.copyWith(logoPath: img.path, logoBytes: bytes));
                      }
                    },
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: themeProvider.seedColor),
                        borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                      ),
                    ),
                    onPressed: () async {
                      final img = await picker.pickImage(source: ImageSource.gallery);
                      if (img != null) {
                        final bytes = await img.readAsBytes();
                        provider.updateDesign(provider.currentDesign.copyWith(logoPath: img.path, logoBytes: bytes));
                      }
                    },
                    child: const Text('Change Logo', style: TextStyle(fontSize: 14)),
                  ),
          ],
        ),
      ],
    );
  }
}

class _FrameSection extends StatelessWidget {
  final bool isIOS;
  final QRProvider provider;
  final ThemeProvider themeProvider;
  final bool isDarkMode;

  const _FrameSection({required this.isIOS, required this.provider, required this.themeProvider, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final frames = [
      {'name': 'None', 'path': null},
      {'name': 'Frame 1', 'path': 'assets/images/qr_code_frame_1.png'},
      {'name': 'Frame 2', 'path': 'assets/images/qr_code_frame_2.png'},
      {'name': 'Frame 3', 'path': 'assets/images/qr_code_frame_3.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Frame',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: frames.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final frameData = frames[index];
              final path = frameData['path'];
              
              // Handle "None" selection separately
              final bool actuallySelected = (path == null) 
                  ? !(provider.currentDesign.frame?.enabled ?? false)
                  : (provider.currentDesign.frame?.enabled ?? false) && provider.currentDesign.frame?.imagePath == path;

              return GestureDetector(
                onTap: () {
                  if (path == null) {
                    provider.updateDesign(provider.currentDesign.copyWith(frame: const QRFrame(enabled: false, imagePath: null)));
                  } else {
                    provider.updateDesign(provider.currentDesign.copyWith(frame: QRFrame(enabled: true, imagePath: path)));
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: actuallySelected ? themeProvider.seedColor : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: path == null
                            ? Center(child: Icon(isIOS ? CupertinoIcons.nosign : Icons.do_not_disturb, size: 30, color: Colors.grey))
                            : ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  provider.currentDesign.backgroundColor,
                                  BlendMode.modulate,
                                ),
                                child: Image.asset(path, fit: BoxFit.contain),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      frameData['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: actuallySelected ? FontWeight.bold : FontWeight.normal,
                        color: actuallySelected ? themeProvider.seedColor : (isDarkMode ? Colors.white70 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
