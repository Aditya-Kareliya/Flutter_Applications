import 'dart:async';

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/models/qr_code_model.dart';

class QRExportService {
  static Future<void> shareQRImage(String data, double size, Color foreground, Color background, {QRCodeDesign? design}) async {
    try {
      final qrImage = await _generateQRImage(data, size, foreground, background, design: design);

      final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final XFile xFile = XFile.fromData(buffer, mimeType: 'image/png', name: 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png');

      await Share.shareXFiles([xFile], text: 'Check out this QR Code!');
    } catch (e) {
      debugPrint('Error sharing QR: $e');
      rethrow;
    }
  }

  static Future<void> downloadQRImage(String data, double size, Color foreground, Color background, {QRCodeDesign? design, String? fileName}) async {
    try {
      final qrImage = await _generateQRImage(data, size, foreground, background, design: design);

      final byteData = await qrImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      // On web and native, we can try sharing/saving via XFile
      final name = fileName ?? 'qr_code.png';
      final xFile = XFile.fromData(buffer, mimeType: 'image/png', name: name);
      await Share.shareXFiles([xFile], text: 'QR Code saved');
    } catch (e) {
      debugPrint('Error downloading QR: $e');
      rethrow;
    }
  }

  static Future<ui.Image> _generateQRImage(String data, double size, Color foreground, Color background, {QRCodeDesign? design}) async {
    final hasFrame = design?.frame?.enabled == true && design?.frame?.imagePath != null;
    
    // Base QR code size (internal)
    // If there is a frame, the QR code itself should be smaller
    final qrSize = hasFrame ? size * 0.70 : size;

    // Load embedded image if logo path is provided
    ui.Image? embeddedImage;
    if (design?.logoBytes != null) {
      embeddedImage = await _loadImageFromBytes(design!.logoBytes!);
    } else if (design?.logoPath != null) {
      embeddedImage = await _loadEmbeddedImage(design!.logoPath!);
    }

    // Generate QR code painter
    final qrPainter = QrPainter(
      data: data.isEmpty ? 'https://qrfy.com' : data,
      version: QrVersions.auto,
      gapless: false,
      color: foreground,
      emptyColor: Colors.transparent, // Background will be handled by canvas or frame
      eyeStyle: QrEyeStyle(eyeShape: _getEyeShape(design?.eyeShape ?? 'square'), color: foreground),
      dataModuleStyle: QrDataModuleStyle(dataModuleShape: _getDataShape(design?.dataShape ?? 'square'), color: foreground),
      embeddedImage: embeddedImage,
      embeddedImageStyle: (design?.logoBytes != null || design?.logoPath != null) && embeddedImage != null
          ? QrEmbeddedImageStyle(size: Size(qrSize * 0.2, qrSize * 0.2))
          : null,
    );

    final qrImage = await qrPainter.toImage(qrSize);

    if (hasFrame) {
      return await _addFrameToImage(qrImage, design!.frame!, design.backgroundColor, size);
    }

    // Default: draw background color and then QR
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = background;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size, size), const Radius.circular(32)), paint);
    
    // Draw QR centered with padding
    final padding = size * 0.08;
    canvas.drawImageRect(
      qrImage, 
      Rect.fromLTWH(0, 0, qrImage.width.toDouble(), qrImage.height.toDouble()),
      Rect.fromLTWH(padding, padding, size - padding * 2, size - padding * 2),
      Paint()
    );

    final picture = recorder.endRecording();
    return await picture.toImage(size.toInt(), size.toInt());
  }

  static Future<ui.Image> _addFrameToImage(ui.Image qrImage, QRFrame frame, Color bgColor, double totalSize) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // 1. Load and Draw Tinted Frame Image
    final frameImg = await _loadEmbeddedImage(frame.imagePath!);
    if (frameImg != null) {
      // Create a tint paint
      final tintPaint = Paint()
        ..colorFilter = ColorFilter.mode(bgColor, BlendMode.modulate);
      
      canvas.drawImageRect(
        frameImg,
        Rect.fromLTWH(0, 0, frameImg.width.toDouble(), frameImg.height.toDouble()),
        Rect.fromLTWH(0, 0, totalSize, totalSize),
        tintPaint,
      );
    } else {
      // Fallback to simple background if frame fails to load
      paint.color = bgColor;
      canvas.drawRect(Rect.fromLTWH(0, 0, totalSize, totalSize), paint);
    }

    // 2. Draw QR code in center
    // Matching the padding of 0.15 used in preview (size * 0.15)
    final padding = totalSize * 0.15;
    final qrRect = Rect.fromLTWH(
      padding,
      padding,
      totalSize - padding * 2,
      totalSize - padding * 2,
    );
    canvas.drawImageRect(qrImage, Rect.fromLTWH(0, 0, qrImage.width.toDouble(), qrImage.height.toDouble()), qrRect, paint);

    final picture = recorder.endRecording();
    return await picture.toImage(totalSize.toInt(), totalSize.toInt());
  }

  static Future<ui.Image?> _loadEmbeddedImage(String path) async {
    try {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        // Load network image
        final imageProvider = NetworkImage(path);
        return await _loadImageFromProvider(imageProvider);
      } else if (path.startsWith('assets/')) {
        // Load asset image
        final imageProvider = AssetImage(path);
        return await _loadImageFromProvider(imageProvider);
      } else {
        // For local files, we can't use File on web.
        if (kIsWeb) {
          // For now, if it's a blob url or internal path, NetworkImage might work?
          // Or just fail gracefully.
          return null;
        }
        // If native, we can't use File class because we removed dart:io.
        // We can use Asset as fallback or just return null.
        // To properly support this without dart:io, we need a different architecture.
        // We will return null for now to prevent crash.
        return null;
      }
    } catch (e) {
      debugPrint('Error loading embedded image: $e');
      return null;
    }
  }

  static Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, (img) {
      completer.complete(img);
    });
    return completer.future;
  }

  static Future<ui.Image> _loadImageFromProvider(ImageProvider provider) async {
    final completer = Completer<ui.Image>();
    final imageStream = provider.resolve(const ImageConfiguration());

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        completer.complete(imageInfo.image);
        imageStream.removeListener(listener);
      },
      onError: (exception, stackTrace) {
        completer.completeError(exception);
        imageStream.removeListener(listener);
      },
    );

    imageStream.addListener(listener);
    return completer.future;
  }

  static QrEyeShape _getEyeShape(String shape) {
    switch (shape) {
      case 'circle':
        return QrEyeShape.circle;
      case 'rounded':
        return QrEyeShape.square;
      default:
        return QrEyeShape.square;
    }
  }

  static QrDataModuleShape _getDataShape(String shape) {
    switch (shape) {
      case 'circle':
        return QrDataModuleShape.circle;
      case 'rounded':
        return QrDataModuleShape.square;
      default:
        return QrDataModuleShape.square;
    }
  }

  // Placeholder for PDF export which would require a PDF package
  static Future<void> exportToPdf(String data) async {
    // Implementation would go here using 'pdf' package
    debugPrint('PDF export not fully implemented (requires pdf package)');
  }
}
