import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class StorageService {
  // ---------------- THEME MODE ----------------
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.themeModeKey, mode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.themeModeKey);
  }

  // ---------------- THEME COLOR ----------------
  Future<void> saveThemeColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.themeColorKey, colorValue);
  }

  Future<int?> getThemeColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.themeColorKey);
  }

  // ---------------- THEME COLOR PALETTE ----------------
  Future<void> saveThemeColors(List<int> colorValues) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      AppConstants.themeColorsKey,
      colorValues.map((e) => e.toString()).toList(),
    );
  }

  Future<List<int>?> getThemeColors() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(AppConstants.themeColorsKey);
    if (list == null) return null;
    return list.map(int.parse).toList();
  }

  // ---------------- BLUR SIGMA ----------------
  Future<void> saveBlurSigma(double sigma) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.blurSigmaKey, sigma);
  }

  Future<double?> getBlurSigma() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(AppConstants.blurSigmaKey);
  }
}
