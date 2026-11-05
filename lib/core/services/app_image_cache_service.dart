import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';
import '../widgets/image/app_cached_image.dart';

/// Service dedicated to pre-warming and managing the Flutter memory image cache
/// for all Cloud Firestore database images.
abstract final class AppImageCacheService {
  static final Set<String> _prewarmedUrls = <String>{};

  /// Pre-warms a list of image URLs in the background.
  /// Deduplicates calls to prevent unnecessary work.
  static void precacheUrls(
    Iterable<String?> urls, {
    int? maxWidth,
    int? maxHeight,
  }) {
    for (final rawUrl in urls) {
      final url = rawUrl?.trim();
      if (url == null || url.isEmpty || _prewarmedUrls.contains(url)) {
        continue;
      }
      _prewarmedUrls.add(url);
      AppCachedImage.prewarm(url, maxWidth: maxWidth, maxHeight: maxHeight);
    }
  }

  /// Extracts and warms essential first-viewport database images
  /// as soon as Firestore or local storage provides them.
  static void precacheEssentialDatabaseImages(AdminDataStore store) {
    unawaited(
      Future.microtask(() {
        try {
          final logo = store.settings.logoImageUrl.trim();
          final qr = store.settings.paymentQrImageUrl.trim();

          // Warm banners and logos at high priority (first viewport)
          precacheUrls([logo, qr], maxWidth: 600, maxHeight: 600);

          final bannerUrls = store.homeBanners.map((b) => b.imageUrl);
          precacheUrls(bannerUrls, maxWidth: 1200, maxHeight: 800);

          final singerUrls = store.homeSingers.map((s) => s.imageUrl);
          precacheUrls(singerUrls, maxWidth: 400, maxHeight: 400);

          final blessingUrls = store.blessings.map((b) => b.photoUrl);
          precacheUrls(blessingUrls, maxWidth: 400, maxHeight: 400);

          final memberUrls = store.committeeMembers.take(8).map((m) => m.photoUrl);
          precacheUrls(memberUrls, maxWidth: 400, maxHeight: 400);

          final albumCovers = store.albums.take(6).map((a) => a.coverImageUrl);
          precacheUrls(albumCovers, maxWidth: 800, maxHeight: 600);
        } catch (e) {
          debugPrint('Notice during image pre-warming: $e');
        }
      }),
    );
  }
}
