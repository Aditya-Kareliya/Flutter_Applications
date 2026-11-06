import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/admin_module/dashboard/data/admin_data_store.dart';
import 'engines/app_translation_engine.dart';
import 'engines/translation_engine_platform.dart';
import 'my_app_translations.dart';

class GoogleTranslationService extends ChangeNotifier {
  static final GoogleTranslationService instance = GoogleTranslationService._internal();

  GoogleTranslationService._internal() {
    _engine = createPlatformTranslationEngine();
  }

  late final AppTranslationEngine _engine;
  final Map<String, String> _cache = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  FirebaseFirestore? get _firestore {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseFirestore.instance;
      }
    } catch (_) {}
    return null;
  }

  /// Restore translations from device local storage (SharedPreferences) in <1ms
  Future<bool> loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString('ppg_cache_translations');

      if (cachedJson != null && cachedJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(cachedJson);

        for (final entry in decoded.entries) {
          if (entry.value is String) {
            _cache[entry.key] = entry.value as String;
          }
        }

        if (_cache.isNotEmpty) {
          _isInitialized = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Translations local storage restore notice: $e');
    }
    return false;
  }

  /// Save current translation cache to device local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ppg_cache_translations', jsonEncode(_cache));
    } catch (e) {
      debugPrint('Translations local storage save notice: $e');
    }
  }

  /// Initialize translations from Cloud Firestore collection `translations_cache`
  Future<void> initFromFirestore() async {
    final db = _firestore;
    if (db == null) {
      _isInitialized = true;
      return;
    }

    try {
      final snap = await db.collection('translations_cache').get();

      for (final doc in snap.docs) {
        final data = doc.data();

        final orig = data['original'] as String? ?? '';
        final trans = data['translated'] as String? ?? '';

        if (orig.isNotEmpty && trans.isNotEmpty) {
          _cache[orig] = trans;
        }
      }

      _saveToLocalStorage();

      // Attach real-time Firestore listener
      db.collection('translations_cache').snapshots().listen((snap) {
        for (final doc in snap.docs) {
          final data = doc.data();

          final orig = data['original'] as String? ?? '';
          final trans = data['translated'] as String? ?? '';

          if (orig.isNotEmpty && trans.isNotEmpty) {
            _cache[orig] = trans;
          }
        }

        _saveToLocalStorage();
        notifyListeners();
      }, onError: (e) => debugPrint('Translations cache stream notice: $e'));
    } catch (e) {
      debugPrint('Translations cache initialization notice: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Synchronously get cached Gujarati translation if available
  String? getCached(String englishText) {
    final key = englishText.trim();
    return _cache[key];
  }

  /// Translate English text to Gujarati with Cloud Firestore caching
  Future<String> translateToGujarati(String englishText) async {
    final trimmed = englishText.trim();
    if (trimmed.isEmpty) return englishText;

    // 1. Check in-memory cache
    if (_cache.containsKey(trimmed)) {
      return _cache[trimmed]!;
    }

    // 2. Translate using engine (google_mlkit_translation on mobile, Google Translation on Web)
    final translated = await _engine.translateToGujarati(trimmed);
    _cache[trimmed] = translated;

    // 3. Persist to Cloud Firestore translations_cache & local storage
    _saveToFirestore(trimmed, translated);
    _saveToLocalStorage();

    notifyListeners();
    return translated;
  }

  /// Prewarm a list of texts into Gujarati cache concurrently in batches of 10
  Future<void> prewarmBatch(List<String> texts) async {
    final unCached = texts.map((t) => t.trim()).where((t) => t.isNotEmpty && !_cache.containsKey(t)).toSet().toList();
    if (unCached.isEmpty) return;

    for (var i = 0; i < unCached.length; i += 10) {
      final end = (i + 10 < unCached.length) ? i + 10 : unCached.length;
      final batch = unCached.sublist(i, end);
      await Future.wait(batch.map((text) => translateToGujarati(text)));
    }
  }

  /// Prewarm all application texts, CMS content, and dynamic items
  Future<void> prewarmAll([List<String>? additionalTexts]) async {
    final list = <String>[];
    list.addAll(MyAppTranslations.getAllEnglishTexts());
    if (additionalTexts != null) {
      list.addAll(additionalTexts);
    }
    for (final f in AdminDataStore.instance.siteContentFields) {
      if (f.valueEn.trim().isNotEmpty && f.valueGu.trim().isEmpty) {
        list.add(f.valueEn);
      }
    }
    for (final y in AdminDataStore.instance.years) {
      if (y.titleEn.trim().isNotEmpty && y.titleGu.trim().isEmpty) {
        list.add(y.titleEn);
      }
    }
    for (final p in AdminDataStore.instance.photos) {
      if (p.titleEn.trim().isNotEmpty && p.titleGu.trim().isEmpty) {
        list.add(p.titleEn);
      }
    }
    for (final a in AdminDataStore.instance.albums) {
      if (a.name.trim().isNotEmpty) {
        list.add(a.name);
      }
    }
    for (final v in AdminDataStore.instance.videos) {
      if (v.title.trim().isNotEmpty) {
        list.add(v.title);
      }
    }
    for (final b in AdminDataStore.instance.blogs) {
      if (b.title.trim().isNotEmpty) {
        list.add(b.title);
      }
    }
    await prewarmBatch(list);
  }

  void _saveToFirestore(String original, String translated) {
    final db = _firestore;
    if (db == null) return;
    try {
      final docId = _generateDocId(original);
      db.collection('translations_cache').doc(docId).set({
        'original': original,
        'translated': translated,
        'source': 'en',
        'target': 'gu',
        'engine': kIsWeb ? 'google_translate_web' : 'google_mlkit_translation',
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore save translation notice: $e');
    }
  }

  String _generateDocId(String input) {
    // Generate safe alphanumeric Firestore document ID
    final clean = input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

    if (clean.length > 40) {
      final hash = base64Url.encode(utf8.encode(input)).replaceAll('=', '');
      return '${clean.substring(0, 30)}_$hash'.substring(0, 48);
    }

    return clean.isEmpty ? 'item_${DateTime.now().millisecondsSinceEpoch}' : clean;
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }
}
