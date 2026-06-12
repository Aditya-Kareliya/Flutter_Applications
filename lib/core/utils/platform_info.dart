import 'package:flutter/foundation.dart';
import 'dart:io' as io;

class PlatformInfo {
  static bool get isWeb => kIsWeb;
  static bool get isIOS => !kIsWeb && io.Platform.isIOS;
  static bool get isAndroid => !kIsWeb && io.Platform.isAndroid;
  static bool get isMacOS => !kIsWeb && io.Platform.isMacOS;
  static bool get isWindows => !kIsWeb && io.Platform.isWindows;
  static bool get isLinux => !kIsWeb && io.Platform.isLinux;
}
