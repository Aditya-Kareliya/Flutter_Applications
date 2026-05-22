import 'package:flutter/material.dart';

enum Gender { male, female }

class BmiProvider extends ChangeNotifier {
  double _weight = 70;
  double get weight => _weight;

  double _height = 170;
  double get height => _height;

  int _age = 25;
  int get age => _age;

  Gender _gender = Gender.male;
  Gender get gender => _gender;

  double get bmi {
    if (_height == 0) return 0;
    double hMeters = _height / 100;
    return _weight / (hMeters * hMeters);
  }

  String get category {
    double val = bmi;
    if (val < 18.5) return 'Underweight';
    if (val < 25) return 'Normal';
    if (val < 30) return 'Overweight';
    return 'Obese';
  }

  Color get categoryColor {
    double val = bmi;
    if (val < 18.5) return Colors.lightBlue;
    if (val < 25) return const Color(0xFF10B981);
    if (val < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  double get idealWeight {
    double hInInches = _height / 2.54;
    double base = hInInches - 60;
    if (base < 0) base = 0;
    if (_gender == Gender.male) {
      return 52 + (1.9 * base);
    } else {
      return 49 + (1.7 * base);
    }
  }

  void updateWeight(double value) {
    _weight = value;
    notifyListeners();
  }

  void updateHeight(double value) {
    _height = value;
    notifyListeners();
  }

  void updateAge(double value) {
    _age = value.toInt();
    notifyListeners();
  }

  void updateGender(Gender g) {
    _gender = g;
    notifyListeners();
  }
}
