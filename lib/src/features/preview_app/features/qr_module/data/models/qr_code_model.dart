import 'dart:typed_data';
import 'package:flutter/material.dart';

enum QRType { url, text, pdf, image, video, appDownload, menu, linkList, landingPage, contact, business, email }

enum QRStatus { active, inactive, expired, locked }

class QRCodeModel {
  final String id;
  final String name;
  final QRType type;
  final String contentData;
  final String? shortUrl;
  final DateTime createdDate;
  final DateTime? updatedDate;
  final QRStatus status;
  final QRCodeDesign design;
  final QRSecurity? security;
  final String? userId;

  QRCodeModel({
    required this.id,
    required this.name,
    required this.type,
    required this.contentData,
    this.shortUrl,
    required this.createdDate,
    this.updatedDate,
    this.status = QRStatus.active,
    required this.design,
    this.security,
    this.userId,
  });

  QRCodeModel copyWith({
    String? id,
    String? name,
    QRType? type,
    String? contentData,
    String? shortUrl,
    DateTime? createdDate,
    DateTime? updatedDate,
    QRStatus? status,
    QRCodeDesign? design,
    QRSecurity? security,
    String? userId,
  }) {
    return QRCodeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      contentData: contentData ?? this.contentData,
      shortUrl: shortUrl ?? this.shortUrl,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      status: status ?? this.status,
      design: design ?? this.design,
      security: security ?? this.security,
      userId: userId ?? this.userId,
    );
  }
}

class QRCodeDesign {
  final Color foregroundColor;
  final Color backgroundColor;
  final String? logoPath;
  final Uint8List? logoBytes;
  final double logoSize;
  final String eyeShape; // 'square', 'circle',
  final String dataShape; // 'square', 'circle',
  final QRFrame? frame;

  const QRCodeDesign({
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.logoPath,
    this.logoBytes,
    this.logoSize = 0.2,
    this.eyeShape = 'square',
    this.dataShape = 'square',
    this.frame,
  });

  QRCodeDesign copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    String? logoPath,
    Uint8List? logoBytes,
    double? logoSize,
    String? eyeShape,
    String? dataShape,
    QRFrame? frame,
  }) {
    return QRCodeDesign(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      logoPath: logoPath ?? this.logoPath,
      logoBytes: logoBytes ?? this.logoBytes,
      logoSize: logoSize ?? this.logoSize,
      eyeShape: eyeShape ?? this.eyeShape,
      dataShape: dataShape ?? this.dataShape,
      frame: frame ?? this.frame,
    );
  }
}

class QRFrame {
  final bool enabled;
  final String? imagePath;

  const QRFrame({
    this.enabled = false,
    this.imagePath,
  });

  QRFrame copyWith({
    bool? enabled,
    String? imagePath,
  }) {
    return QRFrame(
      enabled: enabled ?? this.enabled,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class QRSecurity {
  final String? password;
  final DateTime? expiryDate;
  final bool isProtected;

  const QRSecurity({this.password, this.expiryDate, required this.isProtected});
}
