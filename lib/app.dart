import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';

import 'package:toastification/toastification.dart';

import 'core/dependency_injection/dependency_injection.dart';
import 'core/my_app_bloc/my_app_bloc.dart';
import 'core/my_app_bloc/my_app_event.dart';
import 'core/my_app_bloc/my_app_state.dart';
import 'core/routing/app_router.dart';
import 'core/seo/app_seo_manager.dart';
import 'core/theme/app_theme.dart';
import 'modules/admin_module/dashboard/data/admin_data_store.dart';

class PavanPutraApp extends StatelessWidget {
  const PavanPutraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyAppBloc>.value(
      value: serviceLocator<MyAppBloc>()..add(MyAppInitEvent()),
      child: BlocBuilder<MyAppBloc, MyAppState>(
        buildWhen: (prev, curr) => prev.themeMode != curr.themeMode || prev.locale != curr.locale,
        builder: (context, state) {
          AppSeoManager.instance.updateLanguage(state.locale.languageCode);
          return Sizer(
            builder: (context, orientation, deviceType) {
              return ListenableBuilder(
                listenable: AdminDataStore.instance,
                builder: (context, _) {
                  final lang = state.locale.languageCode;
                  final dynamicTitle = AdminDataStore.instance.getTextOverride(lang, 'app_title') ??
                      AdminDataStore.instance.settings.getMandalName(lang);
                  return MaterialApp.router(
                    title: dynamicTitle,
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.light(),
                    darkTheme: AppTheme.dark(),
                    themeMode: state.themeMode,
                    themeAnimationDuration: AppTheme.animationDuration,
                    themeAnimationCurve: AppTheme.animationCurve,
                    routerConfig: appRouter,
                    scrollBehavior: const MyAppGlobalScrollBehavior(),
                    locale: state.locale,
                    supportedLocales: const [Locale('en'), Locale('gu')],
                    localizationsDelegates: const [
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    builder: (context, child) => ToastificationWrapper(child: child ?? const SizedBox.shrink()),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MyAppGlobalScrollBehavior extends MaterialScrollBehavior {
  const MyAppGlobalScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.stylus, PointerDeviceKind.trackpad, PointerDeviceKind.unknown};
}
