import 'package:flutter/material.dart';

import '../../../../modules/admin_module/dashboard/data/admin_data_store.dart';
import '../image/app_cached_image.dart';

/// Clean, robust Brand Logo Widget
/// Always displays the preloaded local heritage logo on Frame 0 immediately.
/// When an updated cloud logo URL is retrieved from Firebase, seamlessly overlays and updates it.
class BrandLogoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isCircular;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Widget? fallbackWidget;

  const BrandLogoWidget({
    super.key,
    this.width,
    this.height,
    this.size,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircular = true,
    this.border,
    this.boxShadow,
    this.fallbackWidget,
  });

  static const String defaultAssetPng = AppCachedImage.defaultLogoAssetPng;

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = size ?? width;
    final effectiveHeight = size ?? height;

    final defaultAssetWidget = Image.asset(
      defaultAssetPng,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      errorBuilder: (_, _, _) => fallbackWidget ?? const SizedBox.shrink(),
    );

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final logoUrl = AdminDataStore.instance.settings.logoImageUrl.trim();
        final isCustomRemote = logoUrl.isNotEmpty && logoUrl != defaultAssetPng && !logoUrl.contains('pavan_putra_logo');

        Widget content;
        if (isCustomRemote) {
          content = Stack(
            fit: StackFit.passthrough,
            alignment: Alignment.center,
            children: [
              // 1. Instant local asset on frame 0 (never flashes empty)
              fallbackWidget ?? defaultAssetWidget,
              // 2. Updated cloud logo seamlessly overlays once loaded from Firebase
              AppCachedImage(
                imageUrl: logoUrl,
                width: effectiveWidth,
                height: effectiveHeight,
                fit: fit,
                placeholder: (_, _) => const SizedBox.shrink(),
                fallbackWidget: const SizedBox.shrink(),
                memCacheWidth: effectiveWidth != null ? (effectiveWidth * 2).toInt() : 400,
                memCacheHeight: effectiveHeight != null ? (effectiveHeight * 2).toInt() : 400,
              ),
            ],
          );
        } else {
          content = fallbackWidget ?? defaultAssetWidget;
        }

        Widget clipped;
        if (isCircular) {
          clipped = ClipOval(child: content);
        } else if (borderRadius != null) {
          clipped = ClipRRect(borderRadius: borderRadius!, child: content);
        } else {
          clipped = content;
        }

        if (border != null || boxShadow != null) {
          return Container(
            width: effectiveWidth,
            height: effectiveHeight,
            decoration: BoxDecoration(
              shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircular ? null : borderRadius,
              border: border,
              boxShadow: boxShadow,
            ),
            child: clipped,
          );
        }

        return clipped;
      },
    );
  }
}
