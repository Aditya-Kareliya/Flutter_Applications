import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../modules/admin_module/dashboard/data/admin_data_store.dart';

/// Clean, robust Brand Logo Widget
/// Loads from local assets immediately on frame 0.
/// When a cloud API logo URL is available, seamlessly displays it.
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

  static const String defaultAssetPng = 'assets/images/pavan_putra_logo.png';
  static const String defaultAssetJpg = 'assets/images/pavan_putra_logo.jpg';

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = size ?? width;
    final effectiveHeight = size ?? height;

    final defaultAssetWidget = Image.asset(
      defaultAssetPng,
      width: effectiveWidth,
      height: effectiveHeight,
      fit: fit,
      errorBuilder: (_, _, _) => Image.asset(
        defaultAssetJpg,
        width: effectiveWidth,
        height: effectiveHeight,
        fit: fit,
      ),
    );

    return ListenableBuilder(
      listenable: AdminDataStore.instance,
      builder: (context, _) {
        final logoUrl = AdminDataStore.instance.settings.logoImageUrl.trim();

        Widget content;
        if (logoUrl.startsWith('http://') || logoUrl.startsWith('https://')) {
          content = Stack(
            fit: StackFit.passthrough,
            alignment: Alignment.center,
            children: [
              fallbackWidget ?? defaultAssetWidget,
              CachedNetworkImage(
                imageUrl: logoUrl,
                width: effectiveWidth,
                height: effectiveHeight,
                fit: fit,
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ],
          );
        } else if (logoUrl.isNotEmpty &&
            logoUrl.startsWith('assets/') &&
            logoUrl != defaultAssetPng &&
            logoUrl != defaultAssetJpg) {
          content = Image.asset(
            logoUrl,
            width: effectiveWidth,
            height: effectiveHeight,
            fit: fit,
            errorBuilder: (_, _, _) => fallbackWidget ?? defaultAssetWidget,
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

        return SizedBox(
          width: effectiveWidth,
          height: effectiveHeight,
          child: clipped,
        );
      },
    );
  }
}