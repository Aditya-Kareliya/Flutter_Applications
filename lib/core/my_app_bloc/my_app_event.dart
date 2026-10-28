import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class MyAppEvent extends Equatable {
  const MyAppEvent();

  @override
  List<Object?> get props => [];
}

class MyAppInitEvent extends MyAppEvent {}

class MyAppChangeThemeModeEvent extends MyAppEvent {
  final ThemeMode themeMode;

  const MyAppChangeThemeModeEvent(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class MyAppChangeLanguageEvent extends MyAppEvent {
  final Locale locale;

  const MyAppChangeLanguageEvent(this.locale);

  @override
  List<Object?> get props => [locale];
}

class MyAppSetBlurredLoadingEvent extends MyAppEvent {
  final bool isLoading;
  final String? message;

  const MyAppSetBlurredLoadingEvent(this.isLoading, {this.message});

  @override
  List<Object?> get props => [isLoading, message];
}
