import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependency_injection/dependency_injection.dart';
import '../my_app_bloc/my_app_bloc.dart';
import '../my_app_bloc/my_app_state.dart';
import '../my_app_colors/my_app_colors.dart';
import '../my_app_footer/my_app_footer.dart';
import '../my_app_header/my_app_header.dart';
import '../widgets/my_app_blurred_loader.dart';
import '../my_app_scaffold/my_app_drawer.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';

class MyAppScaffold extends StatelessWidget {
  const MyAppScaffold({required this.body, super.key});

  final Widget body;

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
              color: colors.heritageGold,
              backgroundColor: colors.getCardBackgroundColor(context),
              displacement: 100,
              onRefresh: () async {
                await AdminDataStore.instance.refreshAllData();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 88)),
                  SliverToBoxAdapter(child: body),
                  const SliverToBoxAdapter(child: MyAppFooter()),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MyAppHeader(),
          ),
          BlocBuilder<MyAppBloc, MyAppState>(
            buildWhen: (prev, curr) =>
                prev.isBlurredLoading != curr.isBlurredLoading ||
                prev.loadingMessage != curr.loadingMessage,
            builder: (context, state) {
              if (!state.isBlurredLoading) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: MyAppBlurredLoader(
                  message: state.loadingMessage,
                  isFullScreen: true,
                ),
              );
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
    return const ClampingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
