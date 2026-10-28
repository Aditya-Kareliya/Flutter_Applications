import 'package:flutter/material.dart';

abstract final class AppBreakpoints {
  static const mobile = 600.0;
  static const tablet = 900.0;
  static const desktop = 1200.0;
  static const wide = 1600.0;
}

extension ResponsiveContext on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;

  bool get isMobile => width < AppBreakpoints.mobile;

  bool get isTablet => width >= AppBreakpoints.mobile && width < AppBreakpoints.desktop;

  bool get isDesktop => width >= AppBreakpoints.desktop;
}

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({required this.child, super.key, this.maxWidth = 1296, this.padding = const EdgeInsets.symmetric(horizontal: 24)});

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
