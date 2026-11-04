import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

abstract final class FirebaseBootstrap {
  static bool _isConfigured = false;
  static bool get isConfigured => _isConfigured;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (e) {
        debugPrint('Firestore settings notice: $e');
      }
      _isConfigured = true;
      debugPrint('Firebase successfully initialized for project: ${DefaultFirebaseOptions.web.projectId}');
    } catch (e) {
      debugPrint('Firebase initialization notice: $e');
      // If already initialized in another pass, mark as configured
      if (Firebase.apps.isNotEmpty) {
        _isConfigured = true;
      }
    }
  }
}
