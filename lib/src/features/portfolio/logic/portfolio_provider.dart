import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PortfolioProvider extends ChangeNotifier {
  bool _panelOpen = false;
  bool _is24Hour = true;
  String _dateFormat = 'EEE, dd MMM yyyy';

  bool get panelOpen => _panelOpen;
  bool get is24Hour => _is24Hour;
  String get dateFormat => _dateFormat;

  void set24Hour(bool value) {
    if (_is24Hour != value) {
      _is24Hour = value;
      notifyListeners();
    }
  }

  void setDateFormat(String value) {
    if (_dateFormat != value) {
      _dateFormat = value;
      notifyListeners();
    }
  }

  void togglePanel() {
    _panelOpen = !_panelOpen;
    notifyListeners();
  }

  void closePanel() {
    if (_panelOpen) {
      _panelOpen = false;
      notifyListeners();
    }
  }

  bool shouldShowDeviceFrame(BuildContext context) {
    if (kIsWeb) {
      final width = MediaQuery.of(context).size.width;
      return width >= 1100;
    }

    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      return false;
    }

    return true;
  }

  bool shouldForceCupertino(BuildContext context) {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      return true;
    }
    return false;
  }

  bool isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < 1025;
  }
}
