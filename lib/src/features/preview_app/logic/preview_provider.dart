import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_frame/device_frame.dart';
import 'package:universal_html/html.dart' as html;

enum Platform { androidPhone, iphone, iPad, androidTablet }

class PlatformProvider extends ChangeNotifier {
  PlatformProvider() {
    _configureInitialPlatform();
  }

  Platform _selectedPlatform = Platform.androidPhone;
  bool _useCupertinoStyle = false;

  Platform get selectedPlatform => _selectedPlatform;

  bool get useCupertinoStyle => _useCupertinoStyle;
  bool get isTabletPlatform =>
      _selectedPlatform == Platform.androidTablet ||
      _selectedPlatform == Platform.iPad;
  bool get isMaterialPlatform =>
      _selectedPlatform == Platform.androidPhone ||
      _selectedPlatform == Platform.androidTablet;
  bool get isAndroidPlatform => isMaterialPlatform;

  bool shouldUseCupertinoUI(BuildContext context) => _useCupertinoStyle;

  void _configureInitialPlatform() {
    kIsWeb ? _configureWebPlatform() : _configureNativePlatform();
  }

  void _configureWebPlatform() {
    final navigator = html.window.navigator;
    final userAgent = navigator.userAgent.toLowerCase();
    final vendor = navigator.vendor.toLowerCase();

    final bool isSafari = vendor.contains('apple') || (userAgent.contains('safari') && !userAgent.contains('chrome') && !userAgent.contains('crios'));

    if (!isSafari) {
      _applyAndroidPhone();
      return;
    }

    _useCupertinoStyle = true;

    final bool isMac = userAgent.contains('macintosh');
    final bool isIpad = userAgent.contains('ipad') || (isMac && (navigator.maxTouchPoints ?? 0) > 0);

    _selectedPlatform = isIpad ? Platform.iPad : Platform.iphone;
  }

  void _configureNativePlatform() {
    final bool isApplePlatform = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS;

    if (!isApplePlatform) {
      _applyAndroidPhone();
      return;
    }

    _useCupertinoStyle = true;
    _selectedPlatform = Platform.iphone;
  }

  void _applyAndroidPhone() {
    _useCupertinoStyle = false;
    _selectedPlatform = Platform.androidPhone;
  }

  void updatePlatform(Platform platform) {
    if (_selectedPlatform == platform) return;

    _selectedPlatform = platform;
    _useCupertinoStyle = _isCupertinoPlatform(platform);

    notifyListeners();
  }

  DeviceInfo get deviceInfo {
    switch (_selectedPlatform) {
      case Platform.androidPhone:
        return Devices.android.samsungGalaxyS25;
      case Platform.iphone:
        return Devices.ios.iPhone16ProMax;
      case Platform.iPad:
        return Devices.ios.iPadPro13InchesM4;
      case Platform.androidTablet:
        return Devices.android.mediumTablet;
    }
  }

  Orientation get orientation {
    switch (_selectedPlatform) {
      case Platform.androidTablet:
      case Platform.iPad:
        return Orientation.landscape;
      default:
        return Orientation.portrait;
    }
  }

  bool _isCupertinoPlatform(Platform platform) {
    return platform == Platform.iphone || platform == Platform.iPad;
  }
}
