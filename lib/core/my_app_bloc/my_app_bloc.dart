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
      final isGu = state.locale.languageCode == 'gu';
      unawaited(MyAppTextStyles.preloadAllFonts());

      // 1. FAST LOCAL STORAGE CHECK: Restore from device local storage in <5ms
      final localResults = await Future.wait([
        AdminDataStore.instance.loadFromLocalStorage(),
        GoogleTranslationService.instance.loadFromLocalStorage(),
      ]);
      final hasLocalCache = localResults[0] == true;

      if (hasLocalCache) {
        // SECOND-TIME / RETURNING USER:
        // Everything is already restored from device local storage.
        // Render Home Screen immediately with 0 delay (no waiting for Firebase)!
        emit(state.copyWith(isInitialized: true, isBlurredLoading: false));

        // Intelligent background sync:
        // Uses single-doc change detection. If remote data is unchanged, 0 extra queries are executed!
        // If an admin updated anything in Firebase, it fetches only the fresh changes silently.
        unawaited(() async {
          try {
            await Future.wait([
              AdminDataStore.instance.initializeEssentialFirstViewport(forceRefresh: false),
              GoogleTranslationService.instance.initFromFirestore(),
            ]);
            await AdminDataStore.instance.startGentleBackgroundLoading(forceRefresh: false);
          } catch (e) {
            debugPrint('Background sync notice: $e');
          }
        }());
        return;
      }

      // FIRST-TIME USER (cold launch, no local storage yet):
      emit(
        state.copyWith(
          isBlurredLoading: true,
          loadingMessage: isGu
              ? 'સ્વાગત છે...\nશ્રી પવનપુત્ર ગરબી મંડળ માહિતી લોડ થઈ રહી છે...'
              : 'Welcome...\nPlease wait a moment...',
        ),
      );

      try {
        await Future.wait([
          AdminDataStore.instance.initializeEssentialFirstViewport(forceRefresh: true),
          GoogleTranslationService.instance.initFromFirestore(),
        ]);
      } catch (e) {
        debugPrint('App initialization notice: $e');
      }

      // Render Home Screen as soon as first-viewport data is fetched & saved
      emit(state.copyWith(isInitialized: true, isBlurredLoading: false));

      // Continue gentle background loading for first-time launch
      unawaited(AdminDataStore.instance.startGentleBackgroundLoading(forceRefresh: true));
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
