import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class MyAppState extends Equatable {
  final ThemeMode themeMode;
  final Locale locale;
  final bool isBlurredLoading;
  final String? loadingMessage;
  final bool isInitialized;
  final String? errorMessage;

  const MyAppState({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.isBlurredLoading = false,
    this.loadingMessage,
    this.isInitialized = false,
    this.errorMessage,
  });

  MyAppState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool? isBlurredLoading,
    String? loadingMessage,
    bool? isInitialized,
    String? errorMessage,
  }) {
    return MyAppState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      isBlurredLoading: isBlurredLoading ?? this.isBlurredLoading,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    locale,
    isBlurredLoading,
    loadingMessage,
    isInitialized,
    errorMessage,
  ];
}
