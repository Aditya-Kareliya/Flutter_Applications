import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../localization/google_translation_service.dart';
import '../my_app_text_style/my_app_text_styles.dart';
import '../services/app_image_cache_service.dart';
import '../../modules/admin_module/dashboard/data/admin_data_store.dart';
import 'my_app_event.dart';
import 'my_app_state.dart';

class MyAppBloc extends Bloc<MyAppEvent, MyAppState> {
  MyAppBloc() : super(const MyAppState()) {
    on<MyAppInitEvent>((event, emit) async {
      // 1. Rapidly check if all essential home data is already cached in local storage (<5ms)
      final localResults = await Future.wait([AdminDataStore.instance.loadFromLocalStorage(), GoogleTranslationService.instance.loadFromLocalStorage()]);
      final hasLocalCache = localResults[0] == true;
      final hasEssentialData = AdminDataStore.instance.hasEssentialHomeData;

      if (hasLocalCache && hasEssentialData) {
        // Fast path: Returning user with complete local cache.
        // Render website immediately without network delay.
        emit(state.copyWith(isInitialized: true, isBlurredLoading: false));

        AppImageCacheService.precacheEssentialDatabaseImages(AdminDataStore.instance);

        // Check for incremental remote updates in the background
        unawaited(() async {
          try {
            await Future.wait([AdminDataStore.instance.initializeEssentialFirstViewport(forceRefresh: false), GoogleTranslationService.instance.initFromFirestore()]);
            await AdminDataStore.instance.startGentleBackgroundLoading(forceRefresh: false);
          } catch (e) {
            debugPrint('Background sync notice: $e');
          }
        }());
      } else {
        // Cold start / First-time visit:
        // Immediately start the loader so the user never sees empty cards or unpopulated sections
        emit(state.copyWith(isInitialized: true, isBlurredLoading: true, loadingMessage: 'શ્રી પવનપુત્ર ગરબી મંડળ\nમાહિતી લોડ થઈ રહી છે...'));

        try {
          await Future.wait([AdminDataStore.instance.initializeEssentialFirstViewport(forceRefresh: true), GoogleTranslationService.instance.initFromFirestore()]);

          AppImageCacheService.precacheEssentialDatabaseImages(AdminDataStore.instance);

          await AdminDataStore.instance.startGentleBackgroundLoading(forceRefresh: true);
        } catch (e) {
          debugPrint('Essential cold-start fetch error: $e');
        } finally {
          // All Firestore collections loaded and saved into local cache. Dismiss loader cleanly.
          emit(state.copyWith(isBlurredLoading: false));
        }
      }
    });

    on<MyAppChangeThemeModeEvent>((event, emit) {
      emit(state.copyWith(themeMode: event.themeMode));
    });

    on<MyAppChangeLanguageEvent>((event, emit) async {
      final isGu = event.locale.languageCode == 'gu';
      emit(state.copyWith(isBlurredLoading: true, loadingMessage: isGu ? 'ગુજરાતી ભાષા લોડ થઈ રહી છે...' : 'Switching language to English...'));
      final stopwatch = Stopwatch()..start();

      try {
        await MyAppTextStyles.preloadAllFonts();
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
      emit(state.copyWith(isBlurredLoading: event.isLoading, loadingMessage: event.message));
    });
  }
}
