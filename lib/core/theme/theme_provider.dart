import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/user.dart';
class ThemeProvider extends ChangeNotifier {
  final SharedPreferences sharedPreferences;

  ThemeProvider({required this.sharedPreferences}) {
    _loadTheme();
  }

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final themeString = sharedPreferences.getString('theme_mode');
    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }



  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    sharedPreferences.setString('theme_mode', mode.toString().split('.').last);
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  void syncWithUser(User user) {
    if (user.themeMode != null) {
      if (user.themeMode == 'light') {
        _themeMode = ThemeMode.light;
      } else if (user.themeMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }
}
