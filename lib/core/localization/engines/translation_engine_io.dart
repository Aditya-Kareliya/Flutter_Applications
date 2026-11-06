import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'app_translation_engine.dart';
import 'translation_engine_web.dart';

class MLKitTranslationEngine implements AppTranslationEngine {
  OnDeviceTranslator? _enToGuTranslator;
  OnDeviceTranslator? _guToEnTranslator;
  final WebGoogleTranslationEngine _fallbackEngine = WebGoogleTranslationEngine();

  MLKitTranslationEngine() {
    _initTranslators();
  }

  void _initTranslators() {
    try {
      _enToGuTranslator = OnDeviceTranslator(sourceLanguage: TranslateLanguage.english, targetLanguage: TranslateLanguage.gujarati);
      _guToEnTranslator = OnDeviceTranslator(sourceLanguage: TranslateLanguage.gujarati, targetLanguage: TranslateLanguage.english);
    } catch (e) {
      debugPrint('MLKitTranslationEngine init note: $e');
    }
  }

  @override
  Future<String> translateToGujarati(String text) async {
    final trimmed = text.trim();

    if (trimmed.isEmpty) return text;

    try {
      if (_enToGuTranslator != null) {
        final result = await _enToGuTranslator!.translateText(trimmed);
        if (result.trim().isNotEmpty) return result.trim();
      }
    } catch (e) {
      debugPrint('MLKit translation note, falling back to Google Cloud endpoint: $e');
    }

    return _fallbackEngine.translateToGujarati(text);
  }

  @override
  Future<String> translateToEnglish(String text) async {
    final trimmed = text.trim();

    if (trimmed.isEmpty) return text;

    try {
      if (_guToEnTranslator != null) {
        final result = await _guToEnTranslator!.translateText(trimmed);
        if (result.trim().isNotEmpty) return result.trim();
      }
    } catch (e) {
      debugPrint('MLKit reverse translation note: $e');
    }

    return _fallbackEngine.translateToEnglish(text);
  }

  @override
  void dispose() {
    _enToGuTranslator?.close();
    _guToEnTranslator?.close();
  }
}

AppTranslationEngine getPlatformTranslationEngine() => MLKitTranslationEngine();
