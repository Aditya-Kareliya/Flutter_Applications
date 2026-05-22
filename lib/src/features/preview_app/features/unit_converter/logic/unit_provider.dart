import 'package:flutter/material.dart';

enum UnitCategory { length, weight, temperature }

class UnitProvider extends ChangeNotifier {
  UnitCategory _category = UnitCategory.length;
  UnitCategory get category => _category;

  double _input = 0;
  double get input => _input;

  String _fromUnit = 'Meters';
  String get fromUnit => _fromUnit;

  String _toUnit = 'Kilometers';
  String get toUnit => _toUnit;

  double _result = 0;
  double get result => _result;

  final Map<UnitCategory, Map<String, double>> _data = {
    UnitCategory.length: {
      'Centimeters': 1,
      'Inches': 2.54,
      'Meters': 100,
      'Feet': 30.48,
      'Kilometers': 100000,
      'Miles': 160934.4,
    },
    UnitCategory.weight: {
      'Grams': 1,
      'Kilograms': 1000,
      'Pounds': 453.592,
      'Ounces': 28.3495,
    },
    UnitCategory.temperature: {
      'Celsius': 0,
      'Fahrenheit': 0,
      'Kelvin': 0,
    }
  };

  List<String> get units => _data[_category]!.keys.toList();

  void updateCategory(UnitCategory cat) {
    _category = cat;
    _fromUnit = units[0];
    _toUnit = units[1];
    _calculate();
  }

  void updateInput(String value) {
    _input = double.tryParse(value) ?? 0;
    _calculate();
  }

  void updateFromUnit(String unit) {
    _fromUnit = unit;
    _calculate();
  }

  void updateToUnit(String unit) {
    _toUnit = unit;
    _calculate();
  }

  void _calculate() {
    if (_category == UnitCategory.temperature) {
      _result = _convertTemperature(_input, _fromUnit, _toUnit);
    } else {
      double inBase = _input * _data[_category]![_fromUnit]!;
      _result = inBase / _data[_category]![_toUnit]!;
    }
    notifyListeners();
  }

  double _convertTemperature(double val, String from, String to) {
    double celsius;
    if (from == 'Celsius') {
      celsius = val;
    } else if (from == 'Fahrenheit') {
      celsius = (val - 32) * 5 / 9;
    } else {
      celsius = val - 273.15;
    }

    if (to == 'Celsius') return celsius;
    if (to == 'Fahrenheit') return (celsius * 9 / 5) + 32;
    return celsius + 273.15;
  }

  void swap() {
    final temp = _fromUnit;
    _fromUnit = _toUnit;
    _toUnit = temp;
    _calculate();
  }
}
