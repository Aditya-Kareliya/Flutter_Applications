import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/google_translation_service.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';
import 'my_app_event.dart';
import 'my_app_state.dart';

class MyAppBloc extends Bloc<MyAppEvent, MyAppState> {
  MyAppBloc() : super(const MyAppState()) {
    on<MyAppInitEvent>((event, emit) async {
      unawaited(MyAppTextStyles.preloadAllFonts());

      // Render website immediately from frame 0 with preloaded local defaults & assets.
      // Never wait for network images or database queries during initial load.
      emit(state.copyWith(isInitialized: true, isBlurredLoading: false));

      // Asynchronously restore local cache and sync cloud data in background (unawaited)
      unawaited(() async {
        try {
          final localResults = await Future.wait([
            AdminDataStore.instance.loadFromLocalStorage(),
            GoogleTranslationService.instance.loadFromLocalStorage(),
          ]);
          final hasLocalCache = localResults[0] == true;

          await Future.wait([
            AdminDataStore.instance.initializeEssentialFirstViewport(forceRefresh: !hasLocalCache),
            GoogleTranslationService.instance.initFromFirestore(),
          ]);
          await AdminDataStore.instance.startGentleBackgroundLoading(forceRefresh: !hasLocalCache);
        } catch (e) {
          debugPrint('Background init notice: $e');
        }
      }());
    });

    on<MyAppChangeThemeModeEvent>((event, emit) {
      emit(state.copyWith(themeMode: event.themeMode));
    });

    on<MyAppChangeLanguageEvent>((event, emit) async {
      final isGu = event.locale.languageCode == 'gu';
      emit(
        state.copyWith(
          isBlurredLoading: true,
          loadingMessage: isGu
              ? 'ગુજરાતી ભાષા લોડ થઈ રહી છે...'
              : 'Switching language to English...',
        ),
      );
      final stopwatch = Stopwatch()..start();
      try {
        unawaited(MyAppTextStyles.preloadAllFonts());
        if (isGu) {
          await GoogleTranslationService.instance.prewarmAll();
        }
      } catch (e) {
        debugPrint('Language prewarm notice: $e');
      }
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 500) {
        await Future.delayed(Duration(milliseconds: 500 - elapsed));
      }
      emit(state.copyWith(locale: event.locale, isBlurredLoading: false));
    });

    on<MyAppSetBlurredLoadingEvent>((event, emit) {
      emit(
        state.copyWith(
          isBlurredLoading: event.isLoading,
          loadingMessage: event.message,
        ),
      );
    });
  }
}
