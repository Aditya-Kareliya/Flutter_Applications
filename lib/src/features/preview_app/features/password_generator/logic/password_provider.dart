import 'dart:math';
import 'package:flutter/material.dart';
import '../data_model/password_history_model.dart';

class PasswordProvider extends ChangeNotifier {
  final _secureRandom = Random.secure();

  String _password = '';

  String get password => _password;

  bool _showPassword = true;

  bool get showPassword => _showPassword;

  double _length = 12;

  double get length => _length;

  bool _uppercase = true;
  bool _numbers = true;
  bool _symbols = true;
  bool _excludeSimilar = true;
  bool _requireAllSets = true;
  bool _avoidPatterns = true;

  bool get uppercase => _uppercase;

  bool get numbers => _numbers;

  bool get symbols => _symbols;

  bool get excludeSimilar => _excludeSimilar;

  bool get requireAllSets => _requireAllSets;

  bool get avoidPatterns => _avoidPatterns;

  String _customChars = '';

  String get customChars => _customChars;

  final List<PasswordHistory> _history = [];

  List<PasswordHistory> get history => _history;

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void updateLength(double v) {
    _length = v;
    notifyListeners();
  }

  void toggleUppercase(bool v) {
    _uppercase = v;
    notifyListeners();
  }

  void toggleNumbers(bool v) {
    _numbers = v;
    notifyListeners();
  }

  void toggleSymbols(bool v) {
    _symbols = v;
    notifyListeners();
  }

  void toggleExcludeSimilar(bool v) {
    _excludeSimilar = v;
    notifyListeners();
  }

  void toggleRequireAllSets(bool v) {
    _requireAllSets = v;
    notifyListeners();
  }

  void toggleAvoidPatterns(bool v) {
    _avoidPatterns = v;
    notifyListeners();
  }

  void updateCustomChars(String v) {
    _customChars = v;
    notifyListeners();
  }

  void generate() {
    String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    String numberChars = '0123456789';
    String symbolChars = '!@#\$%^&*()_+=-{}[]|:;"<>,.?/';

    if (_excludeSimilar) {
      lowercase = lowercase.replaceAll(RegExp(r'[ilo]'), '');
      uppercaseChars = uppercaseChars.replaceAll(RegExp(r'[IO]'), '');
      numberChars = numberChars.replaceAll(RegExp(r'[10]'), '');
    }

    String chars = lowercase;

    if (_uppercase) chars += uppercaseChars;
    if (_numbers) chars += numberChars;
    if (_symbols) chars += symbolChars;

    chars += _customChars;

    if (chars.isEmpty) return;

    String candidate;

    bool containsFrom(String source, String text) =>
        source.split('').any(text.contains);

    bool hasSequential(String text) {
      for (var i = 0; i < text.length - 2; i++) {
        final c1 = text.codeUnitAt(i);
        final c2 = text.codeUnitAt(i + 1);
        final c3 = text.codeUnitAt(i + 2);
        if ((c2 == c1 + 1 && c3 == c2 + 1) ||
            (c2 == c1 - 1 && c3 == c2 - 1)) {
          return true;
        }
      }
      return false;
    }

    bool hasHeavyRepeats(String text) {
      final counts = <String, int>{};
      for (final ch in text.split('')) {
        counts[ch] = (counts[ch] ?? 0) + 1;
        if (counts[ch]! > 3) return true;
      }
      return false;
    }

    bool meetsAllRules(String text) {
      if (_requireAllSets) {
        if (_uppercase && !containsFrom(uppercaseChars, text)) return false;
        if (_numbers && !containsFrom(numberChars, text)) return false;
        if (_symbols && !containsFrom(symbolChars, text)) return false;
      }

      if (_avoidPatterns) {
        if (hasSequential(text)) return false;
        if (hasHeavyRepeats(text)) return false;
      }

      return true;
    }

    int attempts = 0;
    final maxAttempts = 500;
    do {
      candidate = List.generate(_length.toInt(), (index) {
        final idx = _secureRandom.nextInt(chars.length);
        return chars[idx];
      }).join();
      attempts++;
    } while (!meetsAllRules(candidate) && attempts < maxAttempts);

    _password = candidate;

    _history.insert(0, PasswordHistory(password: _password, createdAt: DateTime.now()));

    if (_history.length > 10) {
      _history.removeLast();
    }

    notifyListeners();
  }

  double get entropy {
    int charset = 26;

    if (_uppercase) charset += 26;
    if (_numbers) charset += 10;
    if (_symbols) charset += 20;
    charset += _customChars.length;

    return _length * (log(charset) / log(2));
  }

  double get strength {
    double e = entropy;

    if (e < 40) return 0.25;
    if (e < 60) return 0.5;
    if (e < 80) return 0.75;
    return 1;
  }

  String get strengthText {
    double e = entropy;

    if (e < 40) return "WEAK";
    if (e < 60) return "FAIR";
    if (e < 80) return "STRONG";
    return "VERY STRONG";
  }

  Color get strengthColor {
    double e = entropy;

    if (e < 40) return Colors.red;
    if (e < 60) return Colors.orange;
    if (e < 80) return Colors.green;
    return Colors.teal;
  }

  void toggleFavorite(PasswordHistory item) {
    item.favorite = !item.favorite;
    notifyListeners();
  }

  void removeHistory(PasswordHistory item) {
    _history.remove(item);
    notifyListeners();
  }
}
