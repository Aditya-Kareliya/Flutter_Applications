import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Cultural Heritage High-Performance Image Component
///
/// Features:
/// 1. Unified support for Network (HTTP/HTTPS), Base64 data URIs, and local Assets.
/// 2. Leverages `cached_network_image` with disk and memory caching.
/// 3. Memory cache clamping (`memCacheWidth`, `memCacheHeight`) to prevent memory churn
///    and ensure lightning-fast decodes within Flutter's `imageCache`.
/// 4. Graceful fallback to the Mandal's sacred logo asset on errors or empty URLs.
/// 5. Headless pre-warming support to prime `PaintingBinding.instance.imageCache`.
class AppCachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final BorderRadiusGeometry? borderRadius;
  final bool isCircle;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final String fallbackAsset;
  final Widget? fallbackWidget;
  final Widget Function(BuildContext context, String url)? placeholder;
  final Widget Function(BuildContext context, String url, dynamic error)?
  errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Duration fadeInDuration;
  final Duration? fadeOutDuration;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.isCircle = false,
    this.border,
    this.boxShadow,
    this.fallbackAsset = defaultLogoAssetPng,
    this.fallbackWidget,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeInDuration = const Duration(milliseconds: 200),
    this.fadeOutDuration,
  });

  static const String defaultLogoAssetPng =
      'assets/images/pavan_putra_logo.png';

  /// Resolves an [ImageProvider] for any given URL (Network, Base64, or Asset).
  static ImageProvider provider(
    String? url, {
    int? maxWidth,
    int? maxHeight,
    String fallbackAsset = defaultLogoAssetPng,
  }) {
    final cleanUrl = url?.trim() ?? '';
    if (cleanUrl.isEmpty) {
      return AssetImage(fallbackAsset);
    }

    if (cleanUrl.startsWith('data:image')) {
      try {
        final commaIdx = cleanUrl.indexOf(',');
        final base64Data = commaIdx != -1
            ? cleanUrl.substring(commaIdx + 1)
            : cleanUrl;
        final bytes = base64Decode(base64Data);
        final memImage = MemoryImage(bytes);
        if (maxWidth != null || maxHeight != null) {
          return ResizeImage(memImage, width: maxWidth, height: maxHeight);
        }
        return memImage;
      } catch (_) {
        return AssetImage(fallbackAsset);
      }
    }

    if (cleanUrl.startsWith('assets/')) {
      final assetImage = AssetImage(cleanUrl);
      if (maxWidth != null || maxHeight != null) {
        return ResizeImage(assetImage, width: maxWidth, height: maxHeight);
      }
      return assetImage;
    }

    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return CachedNetworkImageProvider(
        cleanUrl,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    }

    return AssetImage(fallbackAsset);
  }

  /// Headless pre-warming of an image directly into Flutter's `PaintingBinding.instance.imageCache`.
  static void prewarm(String? url, {int? maxWidth, int? maxHeight}) {
    final cleanUrl = url?.trim() ?? '';
    if (cleanUrl.isEmpty) return;
    try {
      final imgProvider = provider(
        cleanUrl,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      final stream = imgProvider.resolve(ImageConfiguration.empty);
      stream.addListener(
        ImageStreamListener(
          (image, synchronousCall) {},
          onError: (err, stack) {
            // Silently handled without throwing
          },
        ),
      );
    } catch (_) {}
  }

  Widget _buildFallback() {
    if (fallbackWidget != null) return fallbackWidget!;
    return Image.asset(
      fallbackAsset,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: const Color(0xFF1B0104),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          color: Color(0xFFD4AF37),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String url) {
    if (placeholder != null) return placeholder!(context, url);
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1B0104).withValues(alpha: 0.6),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl?.trim() ?? '';
    Widget imageContent;

    if (cleanUrl.isEmpty) {
      imageContent = _buildFallback();
    } else if (cleanUrl.startsWith('data:image')) {
      try {
        final commaIdx = cleanUrl.indexOf(',');
        final base64Data = commaIdx != -1
            ? cleanUrl.substring(commaIdx + 1)
            : cleanUrl;
        final bytes = base64Decode(base64Data);
        imageContent = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          cacheWidth: memCacheWidth,
          cacheHeight: memCacheHeight,
          errorBuilder: (_, error, stack) => errorWidget != null
              ? errorWidget!(context, cleanUrl, error)
              : _buildFallback(),
        );
      } catch (e) {
        imageContent = _buildFallback();
      }
    } else if (cleanUrl.startsWith('assets/')) {
      imageContent = Image.asset(
        cleanUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (_, error, stack) => errorWidget != null
            ? errorWidget!(context, cleanUrl, error)
            : _buildFallback(),
      );
    } else if (cleanUrl.startsWith('http://') ||
        cleanUrl.startsWith('https://')) {
      imageContent = CachedNetworkImage(
        imageUrl: cleanUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        fadeInDuration: fadeInDuration,
        fadeOutDuration: fadeOutDuration,
        placeholder: (ctx, url) => _buildPlaceholder(ctx, url),
        errorWidget: (ctx, url, error) => errorWidget != null
            ? errorWidget!(ctx, url, error)
            : _buildFallback(),
      );
    } else {
      imageContent = _buildFallback();
    }

    Widget formattedWidget;
    if (isCircle) {
      formattedWidget = ClipOval(child: imageContent);
    } else if (borderRadius != null) {
      formattedWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageContent,
      );
    } else {
      formattedWidget = imageContent;
    }

    if (border != null || boxShadow != null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : (borderRadius as BorderRadius?),
          border: border,
          boxShadow: boxShadow,
        ),
        child: formattedWidget,
      );
    }

    return formattedWidget;
  }
}
