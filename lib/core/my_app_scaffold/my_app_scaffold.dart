import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependency_injection/dependency_injection.dart';
import '../localization/my_app_translations.dart';
import '../my_app_bloc/my_app_bloc.dart';
import '../my_app_bloc/my_app_state.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_footer/my_app_footer.dart';
import '../my_app_header/my_app_header.dart';
import '../widgets/my_app_blurred_loader.dart';
import '../my_app_scaffold/my_app_drawer.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';

class MyAppScaffold extends StatefulWidget {
  const MyAppScaffold({required this.body, this.onRefresh, super.key});

  final Widget body;
  final Future<void> Function()? onRefresh;

  @override
  State<MyAppScaffold> createState() => _MyAppScaffoldState();
}

class _MyAppScaffoldState extends State<MyAppScaffold> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    final stopwatch = Stopwatch()..start();
    try {
      if (widget.onRefresh != null) {
        await widget.onRefresh!();
      } else {
        await AdminDataStore.instance.refreshAllData(forceRefresh: true);
      }
    } finally {
      // Ensure smooth visual continuity for the blurred loader
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 800) {
        await Future.delayed(Duration(milliseconds: 800 - elapsed));
      }
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = serviceLocator<MyAppColors>();

    return Scaffold(
      backgroundColor: colors.getBackgroundColor(context),
      endDrawer: const MyAppDrawer(),
      body: Stack(
        children: [
          ScrollConfiguration(
            behavior: const _DesktopScrollBehavior(),
            child: RefreshIndicator(
              color: Colors.transparent,
              backgroundColor: Colors.transparent,
              elevation: 0,
              strokeWidth: 0,
              edgeOffset: 88,
              displacement: 20,
              onRefresh: _handleRefresh,
              child: CustomScrollView(
                physics: const TopBouncingBottomClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 88)),
                  SliverToBoxAdapter(child: widget.body),
                  const SliverToBoxAdapter(child: MyAppFooter()),
                ],
              ),
            ),
          ),
          const Positioned(top: 0, left: 0, right: 0, child: MyAppHeader()),
          if (_isRefreshing) Positioned.fill(child: MyAppBlurredLoader(message: context.tr('refresh_loading'), isFullScreen: true)),
          BlocBuilder<MyAppBloc, MyAppState>(
            buildWhen: (prev, curr) => prev.isBlurredLoading != curr.isBlurredLoading || prev.loadingMessage != curr.loadingMessage,
            builder: (context, state) {
              if (!state.isBlurredLoading || _isRefreshing) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(child: MyAppBlurredLoader(message: state.loadingMessage, isFullScreen: true));
            },
          ),
        ],
      ),
    );
  }
}

class _DesktopScrollBehavior extends MaterialScrollBehavior {
  const _DesktopScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const TopBouncingBottomClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus, PointerDeviceKind.unknown};
}

/// Custom scroll physics that provides bouncing overscroll behavior at the top
/// (for smooth pull-to-refresh) while strictly clamping at the bottom
/// (so the footer stays anchored without any overscroll or bouncing).
class TopBouncingBottomClampingScrollPhysics extends ScrollPhysics {
  const TopBouncingBottomClampingScrollPhysics({super.parent});

  @override
  TopBouncingBottomClampingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TopBouncingBottomClampingScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    assert(offset != 0.0);
    assert(position.minScrollExtent <= position.maxScrollExtent);

    // If at or past the bottom footer and trying to drag past it, clamp immediately.
    if (position.pixels >= position.maxScrollExtent && offset < 0.0) {
      return 0.0;
    }

    // If pulling down at the top, apply smooth bouncing spring resistance.
    if (position.pixels < position.minScrollExtent) {
      final double overscrollPastStart = position.minScrollExtent - position.pixels;
      final double fraction = (overscrollPastStart / position.viewportDimension).clamp(0.0, 1.0);
      final double friction = math.pow(1 - fraction, 2) * 0.52;
      return offset * friction;
    }

    return offset;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Bottom: strictly clamp like ClampingScrollPhysics so footer never overscrolls.
    if (position.maxScrollExtent <= position.pixels && position.pixels < value) {
      return value - position.pixels;
    }
    if (position.pixels < position.maxScrollExtent && position.maxScrollExtent < value) {
      return value - position.maxScrollExtent;
    }

    // Top: allow overscroll (returns 0.0 like BouncingScrollPhysics).
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final Tolerance tolerance = toleranceFor(position);

    // Top overscroll: spring back to minScrollExtent
    if (position.pixels < position.minScrollExtent) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }

    // Bottom out of range: clamp back immediately
    if (position.pixels > position.maxScrollExtent) {
      return ScrollSpringSimulation(spring, position.pixels, position.maxScrollExtent, math.min(0.0, velocity), tolerance: tolerance);
    }

    if (velocity.abs() < tolerance.velocity) {
      return null;
    }

    if (velocity > 0.0 && position.pixels >= position.maxScrollExtent) {
      return null;
    }

    // When flinging towards the footer, use clamping simulation so it stops dead on the footer.
    if (velocity > 0.0) {
      return ClampingScrollSimulation(position: position.pixels, velocity: velocity, tolerance: tolerance);
    }

    // When flinging towards the top, allow bouncing simulation.
    return BouncingScrollSimulation(
      spring: spring,
      position: position.pixels,
      velocity: velocity,
      leadingExtent: position.minScrollExtent,
      trailingExtent: position.maxScrollExtent,
      tolerance: tolerance,
    );
  }
}
