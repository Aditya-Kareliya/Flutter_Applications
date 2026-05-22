import 'dart:math';
import 'package:flutter/material.dart';

class ColorPaletteProvider extends ChangeNotifier {
  Color _color = Colors.blue;
  Color get color => _color;

  final List<Color> _history = [];
  List<Color> get history => _history;

  String get hex =>
      '#${_color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';

  void generate() {
    final newColor =
        Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    updateColor(newColor);
  }

  void updateColor(Color newColor) {
    _color = newColor;
    if (!_history.contains(newColor)) {
      _history.insert(0, newColor);
      if (_history.length > 20) _history.removeLast(); // Keep up to 20 for advanced mode
    }
    notifyListeners();
  }

  List<Color> getComplementary() {
    final hsl = HSLColor.fromColor(_color);
    final hue = (hsl.hue + 180) % 360;
    return [hsl.withHue(hue).toColor()];
  }

  Color get bestTextColor {
    final whiteContrast = contrastWith(Colors.white);
    final blackContrast = contrastWith(Colors.black);

    return whiteContrast > blackContrast ? Colors.white : Colors.black;
  }

  List<Color> getAnalogous() {
    final hsl = HSLColor.fromColor(_color);
    return [
      hsl.withHue((hsl.hue + 30) % 360).toColor(),
      hsl.withHue((hsl.hue - 30 + 360) % 360).toColor(),
    ];
  }

  List<Color> getTriadic() {
    final hsl = HSLColor.fromColor(_color);
    return [
      hsl.withHue((hsl.hue + 120) % 360).toColor(),
      hsl.withHue((hsl.hue + 240) % 360).toColor(),
    ];
  }

  List<Color> getTetradic() {
    final hsl = HSLColor.fromColor(_color);
    return [
      hsl.withHue((hsl.hue + 90) % 360).toColor(),
      hsl.withHue((hsl.hue + 180) % 360).toColor(),
      hsl.withHue((hsl.hue + 270) % 360).toColor(),
    ];
  }

  List<Color> getSplitComplementary() {
    final hsl = HSLColor.fromColor(_color);
    return [
      hsl.withHue((hsl.hue + 150) % 360).toColor(),
      hsl.withHue((hsl.hue + 210) % 360).toColor(),
    ];
  }

  List<Color> getMonochromatic() {
    final hsl = HSLColor.fromColor(_color);
    return [
      hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness + 0.4).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness - 0.4).clamp(0.0, 1.0)).toColor(),
    ];
  }

  // --- Advanced Color Codes ---
  
  String get hslString {
    final hsl = HSLColor.fromColor(_color);
    return '${hsl.hue.round()}°, ${(hsl.saturation * 100).round()}%, ${(hsl.lightness * 100).round()}%';
  }

  String get cmykString {
    double r = _color.red / 255.0;
    double g = _color.green / 255.0;
    double b = _color.blue / 255.0;

    double k = 1.0 - max(r, max(g, b));
    if (k == 1.0) return '0%, 0%, 0%, 100%';
    
    double c = (1.0 - r - k) / (1.0 - k);
    double m = (1.0 - g - k) / (1.0 - k);
    double y = (1.0 - b - k) / (1.0 - k);

    return '${(c * 100).round()}%, ${(m * 100).round()}%, ${(y * 100).round()}%, ${(k * 100).round()}%';
  }

  // --- Accessibility / Contrast Checker (WCAG 2.0 Standard formulation) ---
  
  double get relativeLuminance {
    double r = _srgbChannel(_color.red);
    double g = _srgbChannel(_color.green);
    double b = _srgbChannel(_color.blue);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  double _srgbChannel(int colorChannel) {
    double c = colorChannel / 255.0;
    return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  double contrastWith(Color other) {
    double l1 = relativeLuminance;
    
    // We reuse this instance logic to calculate the other luminance
    double otherL = _calculateLuminance(other);
    
    double lightest = max(l1, otherL);
    double darkest = min(l1, otherL);
    
    return (lightest + 0.05) / (darkest + 0.05);
  }

  double _calculateLuminance(Color c) {
    double r = _srgbChannel(c.red);
    double g = _srgbChannel(c.green);
    double b = _srgbChannel(c.blue);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
}

