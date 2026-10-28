import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'app_translation_engine.dart';

class WebGoogleTranslationEngine implements AppTranslationEngine {
  @override
  Future<String> translateToGujarati(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=gu&dt=t&q=${Uri.encodeComponent(trimmed)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final buffer = StringBuffer();
          for (final segment in decoded[0]) {
            if (segment is List && segment.isNotEmpty && segment[0] != null) {
              buffer.write(segment[0].toString());
            }
          }
          final result = buffer.toString().trim();
          if (result.isNotEmpty) return result;
        }
      }
    } catch (e) {
      debugPrint('WebGoogleTranslationEngine error: $e');
    }
    return text;
  }

  @override
  Future<String> translateToEnglish(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=gu&tl=en&dt=t&q=${Uri.encodeComponent(trimmed)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty && decoded[0] is List) {
          final buffer = StringBuffer();
          for (final segment in decoded[0]) {
            if (segment is List && segment.isNotEmpty && segment[0] != null) {
              buffer.write(segment[0].toString());
            }
          }
          final result = buffer.toString().trim();
          if (result.isNotEmpty) return result;
        }
      }
    } catch (e) {
      debugPrint('WebGoogleTranslationEngine reverse error: $e');
    }
    return text;
  }

  @override
  void dispose() {}
}

AppTranslationEngine getPlatformTranslationEngine() => WebGoogleTranslationEngine();
