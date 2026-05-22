import 'package:flutter/material.dart';
import '../services/storage_service.dart';

enum AppThemeType { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  final List<Color> colors = [
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.orange,
    Colors.red,
    Colors.green,
  ];
  final StorageService _storageService = StorageService();

  AppThemeType _themeType = AppThemeType.system;
  Color _seedColor = Colors.blue;
  double _blurSigma = 12.0;
  int _nextGeneratedIndex = 0;

  AppThemeType get themeType => _themeType;

  Color get seedColor => _seedColor;

  double get blurSigma => _blurSigma;

  ThemeMode get themeMode {
    switch (_themeType) {
      case AppThemeType.light:
        return ThemeMode.light;
      case AppThemeType.dark:
        return ThemeMode.dark;
      case AppThemeType.system:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    final savedTheme = await _storageService.getThemeMode();
    final savedColor = await _storageService.getThemeColor();
    final savedColors = await _storageService.getThemeColors();
    final savedBlur = await _storageService.getBlurSigma();

    if (savedTheme != null) {
      _themeType = AppThemeType.values.firstWhere((e) => e.name == savedTheme);
    }

    if (savedColor != null) {
      _seedColor = Color(savedColor);
    }

    if (savedColors != null && savedColors.isNotEmpty) {
      colors
        ..clear()
        ..addAll(savedColors.map((v) => Color(v)));
    }

    final systemIsDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;

    _blurSigma =
        savedBlur ??
        ((_themeType == AppThemeType.dark ||
                (_themeType == AppThemeType.system && systemIsDark))
            ? 18
            : 10);

    notifyListeners();
  }

  Future<void> setTheme(AppThemeType type) async {
    _themeType = type;

    final isDark =
        type == AppThemeType.dark ||
        (type == AppThemeType.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);

    _blurSigma = isDark ? 18 : 10;

    await _storageService.saveThemeMode(type.name);
    await _storageService.saveBlurSigma(_blurSigma);

    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    await _storageService.saveThemeColor(color.value);
    notifyListeners();
  }

  /// Register a newly generated palette color into the fixed theme color slots.
  /// It replaces one of the six boxes in a round‑robin fashion.
  void registerGeneratedThemeColor(Color color) {
    if (colors.isEmpty) return;
    final index = _nextGeneratedIndex % colors.length;
    colors[index] = color;
    _nextGeneratedIndex = (index + 1) % colors.length;
    _storageService.saveThemeColors(colors.map((c) => c.value).toList());
    notifyListeners();
  }
}
