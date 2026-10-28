import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';

class MyAppShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final ShapeBorder shapeBorder;

  const MyAppShimmer.rectangular({super.key, this.width, required this.height})
    : shapeBorder = const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      );

  const MyAppShimmer.circular({
    super.key,
    required this.width,
    required this.height,
  }) : shapeBorder = const CircleBorder();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width ?? 100.w,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}
