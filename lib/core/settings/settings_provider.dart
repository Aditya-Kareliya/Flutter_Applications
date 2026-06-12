import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/entities/user.dart';
class SettingsProvider extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  static const String currencyKey = 'APP_CURRENCY';
  static const String colorKey = 'APP_PRIMARY_COLOR';

  SettingsProvider({required this.sharedPreferences}) {
    _loadSettings();
  }

  String _currency = '₹';
  String get currency => _currency;

  Color _primaryColor = Colors.blue;
  Color get primaryColor => _primaryColor;
  
  static const String hiddenCategoriesKey = 'HIDDEN_CATEGORIES';
  List<String> _hiddenCategories = [];
  List<String> get hiddenCategories => _hiddenCategories;

  void _loadSettings() {
    _currency = sharedPreferences.getString(currencyKey) ?? '₹';
    final colorValue = sharedPreferences.getInt(colorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    } else {
      _primaryColor = Colors.blue;
    }
    _hiddenCategories = sharedPreferences.getStringList(hiddenCategoriesKey) ?? [];
  }

  String? _currentUserId;

  void syncWithUser(User user) {
    _currentUserId = user.id;
    if (user.currency != null) _currency = user.currency!;
    if (user.themeColor != null) {
      try {
        _primaryColor = Color(int.parse(user.themeColor!));
      } catch (_) {}
    }
    _loadHiddenCategories();
    notifyListeners();
  }
  
  void reset() {
    _currentUserId = null;
    _currency = '₹';
    _primaryColor = Colors.blue;
    _hiddenCategories = [];
    _loadSettings(); // Reload global defaults or just reset variables
  }
  
  String get _hiddenCategoriesKey => _currentUserId != null 
      ? '${hiddenCategoriesKey}_$_currentUserId' 
      : hiddenCategoriesKey;

  void _loadHiddenCategories() {
    _hiddenCategories = sharedPreferences.getStringList(_hiddenCategoriesKey) ?? [];
  }

  Future<void> updateCurrency(String newCurrency) async {
    _currency = newCurrency;
    await sharedPreferences.setString(currencyKey, newCurrency);
    notifyListeners();
  }

  Future<void> updatePrimaryColor(Color newColor) async {
    _primaryColor = newColor;
    await sharedPreferences.setInt(colorKey, newColor.toARGB32());
    notifyListeners();
  }
  
  Future<void> toggleCategoryVisibility(String categoryName) async {
    if (_hiddenCategories.contains(categoryName)) {
      _hiddenCategories.remove(categoryName);
    } else {
      _hiddenCategories.add(categoryName);
    }
    await sharedPreferences.setStringList(_hiddenCategoriesKey, _hiddenCategories);
    notifyListeners();
  }
}
