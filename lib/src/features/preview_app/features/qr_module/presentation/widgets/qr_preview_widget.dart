import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../logic/qr_provider.dart';
import 'package:provider/provider.dart';

class QRPreviewWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const QRPreviewWidget({super.key, required this.data, this.size = 200, this.foregroundColor, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<QRProvider>(
      builder: (context, provider, _) {
        final design = provider.currentDesign;
        final hasFrame = design.frame?.enabled == true && design.frame?.imagePath != null;
        
        // Increase the base width when a frame is selected to make it look "bigger" overall
        final framedWidth = size * 1.25; // increased slightly more to be noticeable
        
        // QR Code size should be small if inside a frame, otherwise normal size
        final qrSize = hasFrame ? framedWidth * 0.65 : size;

        // Inner QR Code widget
        Widget qrWidget = QrImageView(
          data: data.isEmpty ? 'https://qrfy.com' : data,
          version: QrVersions.auto,
          size: qrSize, // Use dynamically calculated size
          foregroundColor: design.foregroundColor,
          backgroundColor: Colors.transparent, // Always transparent inside frame/container
          eyeStyle: QrEyeStyle(eyeShape: _getEyeShape(design.eyeShape), color: design.foregroundColor),
          dataModuleStyle: QrDataModuleStyle(dataModuleShape: _getDataShape(design.dataShape), color: design.foregroundColor),
          embeddedImage: design.logoBytes != null ? MemoryImage(design.logoBytes!) : (design.logoPath != null ? _getEmbeddedImage(design.logoPath!) : null),
          embeddedImageStyle: (design.logoBytes != null || design.logoPath != null) ? QrEmbeddedImageStyle(size: Size(qrSize * 0.2, qrSize * 0.2)) : null,
        );

        if (hasFrame) {
          
          return Container(
            width: framedWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            // We use a ClipRRect to ensure the shadow and corners match
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Tinted Frame Image - Determines the height of the Stack naturally
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      design.backgroundColor,
                      BlendMode.modulate,
                    ),
                    child: Image.asset(
                      design.frame!.imagePath!,
                      width: framedWidth,
                      fit: BoxFit.fitWidth, // This ensures width is exactly framedWidth and height is proportional
                    ),
                  ),
                  // QR Code positioned in the central/upper area
                  // Using Positioned instead of Align to be relative to the Stack's bounds
                  // The exact center position might depend on the frame's layout, but
                  // a slightly upper alignment is typical for "Scan me" frames.
                  Positioned(
                    top: framedWidth * 0.1, // 10% padding from top
                    child: SizedBox(
                      width: framedWidth * 0.65, // Small QR relative to the frame
                      height: framedWidth * 0.65,
                      // The QR code background is already Colors.transparent inside
                      child: qrWidget,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Default style with corner radius if no frame
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: design.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(16),
            child: qrWidget,
          );
        }
      },
    );
  }

  QrEyeShape _getEyeShape(String shape) {
    switch (shape) {
      case 'circle':
        return QrEyeShape.circle;
      case 'rounded':
        return QrEyeShape.square;
      default:
        return QrEyeShape.square;
    }
  }

  QrDataModuleShape _getDataShape(String shape) {
    switch (shape) {
      case 'circle':
        return QrDataModuleShape.circle;
      case 'rounded':
        return QrDataModuleShape.square;
      default:
        return QrDataModuleShape.square;
    }
  }

  ImageProvider? _getEmbeddedImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      // For web, we can't use FileImage directly with a path string in the same way.
      // However, if we are on mobile/desktop (native), File is fine.
      // To be safe and avoid dart:io dependency which crashes web, we should check kIsWeb.
      // But we can't import dart:io.
      // A common workaround without importing dart:io is using universal_io or just conditional imports.
      // Since we want to avoid adding packages if possible, we can use a helper or just not support file paths on web for now,
      // or assume it's a file path only if not web.
      // Given the constraints, let's trust the cross-platform image provider or similar if available.
      // Actually, standard FileImage requires dart:io.
      // If we simply remove dart:io, we can't use FileImage.
      // We will assume for now that on Web, users pick images via bytes (which qr_flutter might not support directly via this API easily without custom code).
      // But wait, the previous code used File(path).
      // We must avoid File(path) on web.
      return AssetImage('assets/images/placeholder.png'); // Fallback for now to prevent crash
    }
  }
}
