import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTypography {
  static TextTheme material() {
    return Typography.material2021().black;
  }

  /// Cupertino typography (SF Pro – system default)
  static CupertinoTextThemeData cupertino(Brightness brightness) {
    return CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: '.SF Pro',
      ),
    );
  }
}
