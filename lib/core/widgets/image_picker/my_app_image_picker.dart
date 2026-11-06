import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../dependency_injection/dependency_injection.dart';
import '../../my_app_colors/my_app_colors.dart';
import '../../my_app_text_style/my_app_text_styles.dart';
import '../toast/my_app_toast_message.dart';
import '../dialogs/my_app_dialog.dart';
import '../image/app_cached_image.dart';

/// Cultural Heritage Image Picker & CRUD Widget.
/// Supports cross-platform picking via `image_picker: ^1.2.4`, direct URL entry,
/// live preview, removal, and full-screen lightbox viewing.
class MyAppImagePicker extends StatefulWidget {
  final String? initialImageUrl;
  final ValueChanged<String> onImageChanged;
  final VoidCallback? onImageRemoved;
  final String label;
  final String helperText;
  final double height;
  final double width;
  final bool isCircle;
  final String defaultFallbackAsset;

  const MyAppImagePicker({
    super.key,
    this.initialImageUrl,
    required this.onImageChanged,
    this.onImageRemoved,
    this.label = 'Image Asset',
    this.helperText = 'Pick image from device or paste image URL',
    this.height = 180,
    this.width = double.infinity,
    this.isCircle = false,
    this.defaultFallbackAsset = 'assets/images/pavan_putra_logo.png',
  });

  @override
  State<MyAppImagePicker> createState() => _MyAppImagePickerState();
}

class _MyAppImagePickerState extends State<MyAppImagePicker> {
  late String _currentUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialImageUrl?.trim() ?? '';
  }

  @override
  void didUpdateWidget(covariant MyAppImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageUrl != oldWidget.initialImageUrl) {
      _currentUrl = widget.initialImageUrl?.trim() ?? '';
    }
  }

  Future<void> _pickFromDevice() async {
    try {
      setState(() => _isLoading = true);
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1920, maxHeight: 1080, imageQuality: 85);

      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      String resolvedUrl;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        resolvedUrl = 'data:image/jpeg;base64,$base64String';
      } else {
        resolvedUrl = image.path;
      }

      setState(() {
        _currentUrl = resolvedUrl;
        _isLoading = false;
      });
      widget.onImageChanged(resolvedUrl);

      if (mounted) {
        MyAppToastMessage.success(context, title: 'Image Selected', description: 'Image loaded successfully.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        MyAppToastMessage.error(context, title: 'Image Selection Failed', description: 'Could not process the selected image. Please try again with a JPG or PNG image.');
      }
    }
  }

  void _openUrlInputDialog() {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final controller = TextEditingController(text: _currentUrl.startsWith('data:') ? '' : _currentUrl);

    showMyAppDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.getCardBackgroundColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.6), width: 1.2),
        ),
        title: Text('Enter Image URL', style: styles.editorialSerif(context, size: 20, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste a valid HTTPS image link (Unsplash, Cloudinary, Imgur, CDN, etc.):',
              style: styles.cleanSans(context, size: 13, color: colors.getSecondaryTextColor(context)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Image Link (URL)',
                hintText: 'https://images.unsplash.com/...',
                prefixIcon: Icon(Icons.link_rounded, color: colors.heritageGold),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: colors.heritageMaroon, foregroundColor: colors.white),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Apply Image'),
            onPressed: () {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                setState(() => _currentUrl = newUrl);
                widget.onImageChanged(newUrl);
                Navigator.pop(ctx);
                MyAppToastMessage.success(context, title: 'Image URL Updated', description: 'New image link applied successfully.');
              } else {
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _clearImage() {
    setState(() => _currentUrl = '');
    widget.onImageRemoved?.call();
    widget.onImageChanged('');
    MyAppToastMessage.warning(context, title: 'Image Removed', description: 'Default placeholder will be displayed.');
  }

  void _previewFullScreen() {
    if (_currentUrl.isEmpty) return;
    final colors = serviceLocator<MyAppColors>();

    showMyAppDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.heritageGold, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 10))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildImageWidget(fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: colors.deepMaroon,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget({BoxFit fit = BoxFit.cover}) {
    return AppCachedImage(imageUrl: _currentUrl, fit: fit, fallbackAsset: widget.defaultFallbackAsset, memCacheWidth: 600, memCacheHeight: 600);
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();
    final styles = serviceLocator<MyAppTextStyles>();
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      width: widget.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.getCardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.heritageGold.withValues(alpha: 0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Icon(Icons.photo_library_rounded, size: 18, color: colors.heritageGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.label, style: styles.editorialSerif(context, size: 15, fontWeight: FontWeight.w700)),
              ),
              if (_currentUrl.isNotEmpty)
                IconButton(tooltip: 'View Full Screen', icon: const Icon(Icons.zoom_in_rounded, size: 20), color: colors.heritageGold, onPressed: _previewFullScreen),
            ],
          ),
          const SizedBox(height: 4),
          Text(widget.helperText, style: styles.cleanSans(context, size: 11.5, color: colors.getSecondaryTextColor(context))),
          const SizedBox(height: 14),

          // Preview Area
          Center(
            child: GestureDetector(
              onTap: _currentUrl.isNotEmpty ? _previewFullScreen : _pickFromDevice,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: widget.height,
                    width: widget.isCircle ? widget.height : widget.width,
                    decoration: BoxDecoration(
                      shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: widget.isCircle ? null : BorderRadius.circular(14),
                      border: Border.all(color: colors.heritageGold.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: widget.isCircle ? BorderRadius.circular(widget.height / 2) : BorderRadius.circular(12),
                      child: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildImageWidget(),
                    ),
                  ),
                  if (_currentUrl.isEmpty)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
                          borderRadius: widget.isCircle ? null : BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: colors.white, size: 36),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to Add Image',
                              style: styles.cleanSans(context, size: 12, color: colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons Row (Responsive Wrap)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _pickFromDevice,
                icon: const Icon(Icons.file_upload_outlined, size: 16),
                label: Text('Pick from Device', style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.heritageGold.withValues(alpha: 0.7)),
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 8),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _openUrlInputDialog,
                icon: const Icon(Icons.link_rounded, size: 16),
                label: Text('Enter URL', style: styles.cleanSans(context, size: 12, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.getBorderColor(context)),
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: 8),
                ),
              ),
              if (_currentUrl.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearImage,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                  label: Text(
                    'Remove',
                    style: styles.cleanSans(context, size: 12, color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
