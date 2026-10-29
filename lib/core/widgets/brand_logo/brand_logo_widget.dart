import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../modules/admin_module/dashboard/data/admin_data_store.dart';

/// Standardized Brand Logo Widget
/// Consumes the configured logo from AdminDataStore.instance.settings.logoImageUrl
/// with automatic caching, minimal placeholder, and local asset fallback.
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

  static const String defaultAsset = 'assets/images/pavan_putra_logo.png';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final logoUrl = AdminDataStore.instance.settings.logoImageUrl.trim();
        final effectiveWidth = size ?? width;
        final effectiveHeight = size ?? height;

        final baseAsset = Image.asset(
          defaultAsset,
          width: effectiveWidth,
          height: effectiveHeight,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/pavan_putra_logo.jpg',
            width: effectiveWidth,
            height: effectiveHeight,
            fit: fit,
          ),
        );

        Widget imageWidget;
        if (logoUrl.startsWith('http://') || logoUrl.startsWith('https://')) {
          imageWidget = Stack(
            fit: StackFit.passthrough,
            alignment: Alignment.center,
            children: [
              fallbackWidget ?? baseAsset,
              CachedNetworkImage(
                imageUrl: logoUrl,
                width: effectiveWidth,
                height: effectiveHeight,
                fit: fit,
                fadeInDuration: const Duration(milliseconds: 300),
                fadeOutDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ],
          );
        } else if (logoUrl.isNotEmpty && logoUrl.startsWith('assets/') && logoUrl != defaultAsset) {
          imageWidget = Image.asset(
            logoUrl,
            width: effectiveWidth,
            height: effectiveHeight,
            fit: fit,
            errorBuilder: (context, error, stackTrace) => fallbackWidget ?? baseAsset,
          );
        } else {
          imageWidget = fallbackWidget ?? baseAsset;
        }

        Widget clippedWidget;
        if (isCircular) {
          clippedWidget = ClipOval(child: imageWidget);
        } else if (borderRadius != null) {
          clippedWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
        } else {
          clippedWidget = imageWidget;
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
            child: clippedWidget,
          );
        }

        return SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
          child: clippedWidget,
        );
      },
    );
  }
}

