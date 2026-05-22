// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import '../models/qr_code_model.dart';
import 'package:uuid/uuid.dart';

class QRRepository {
  final List<QRCodeModel> _qrCodes = [];
  final _uuid = const Uuid();

  QRRepository() {
    // Initialize with some mock data
    _qrCodes.addAll([
        QRCodeModel(
            id: '1',
            name: 'My Portfolio',
            type: QRType.url,
            contentData: 'https://mysite.com',
            createdDate: DateTime.now().subtract(const Duration(days: 2)),
            design: const QRCodeDesign(foregroundColor: Color(0xFF000000)),
        ),
        QRCodeModel(
            id: '2',
            name: 'WiFi Access',
            type: QRType.text,
            contentData: 'WIFI:S:MyNetwork;T:WPA;P:password;;',
            createdDate: DateTime.now().subtract(const Duration(days: 5)),
            design: const QRCodeDesign(foregroundColor: Color(0xFF1E88E5)),
        )
    ]);
  }

  Future<List<QRCodeModel>> getAllQRCodes() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    return List.from(_qrCodes);
  }

  Future<QRCodeModel> getQRCode(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _qrCodes.firstWhere((element) => element.id == id);
  }

  Future<QRCodeModel> createQRCode(QRCodeModel qrCode) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newQR = qrCode.copyWith(
        id: _uuid.v4(),
        createdDate: DateTime.now(),
        shortUrl: 'https://qr.fy/${_uuid.v4().substring(0,6)}' // Mock short URL
    );
    _qrCodes.add(newQR);
    return newQR;
  }

  Future<QRCodeModel> updateQRCode(QRCodeModel qrCode) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _qrCodes.indexWhere((element) => element.id == qrCode.id);
    if (index != -1) {
      final updated = qrCode.copyWith(updatedDate: DateTime.now());
      _qrCodes[index] = updated;
      return updated;
    }
    throw Exception('QR Code not found');
  }

  Future<void> deleteQRCode(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _qrCodes.removeWhere((element) => element.id == id);
  }
}
