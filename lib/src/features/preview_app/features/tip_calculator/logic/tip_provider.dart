import 'package:flutter/material.dart';

// ================= CURRENCY =================
enum Currency { inr, usd, eur, gbp }

extension CurrencyExt on Currency {
  String get symbol {
    switch (this) {
      case Currency.inr:
        return '₹';
      case Currency.usd:
        return '\$';
      case Currency.eur:
        return '€';
      case Currency.gbp:
        return '£';
    }
  }

  String get code {
    switch (this) {
      case Currency.inr:
        return 'INR';
      case Currency.usd:
        return 'USD';
      case Currency.eur:
        return 'EUR';
      case Currency.gbp:
        return 'GBP';
    }
  }
}

// ================= BILL MODEL =================
class TipBill {
  final double bill;
  final double total;
  final double perPerson;
  final int people;
  final double tip;
  final double tax;
  final Currency currency;
  final DateTime date;

  TipBill({required this.bill, required this.total, required this.perPerson, required this.people, required this.tip, required this.tax, required this.currency, required this.date});
}

// ================= PROVIDER =================
class TipProvider extends ChangeNotifier {
  // ---------------- STATE ----------------
  double _bill = 0;
  double _tipPercent = 15;
  double _taxPercent = 0;
  int _people = 1;
  bool _roundUp = false;
  Currency _currency = Currency.inr;

  // ---------------- HISTORY ----------------
  final List<TipBill> _history = [];

  List<TipBill> get history => _history;

  // ---------------- GETTERS ----------------
  double get bill => _bill;

  double get tipPercent => _tipPercent;

  double get taxPercent => _taxPercent;

  int get people => _people;

  bool get roundUp => _roundUp;

  Currency get currency => _currency;

  double get subtotal => _bill;

  double get totalTip => (_bill * _tipPercent) / 100;

  double get totalTax => (_bill * _taxPercent) / 100;

  double get rawTotal => _bill + totalTip + totalTax;

  double get total => _roundUp ? rawTotal.ceilToDouble() : rawTotal;

  double get perPerson => total / (_people > 0 ? _people : 1);

  // ---------------- UPDATE METHODS ----------------
  void updateBill(String value) {
    _bill = double.tryParse(value) ?? 0;
    notifyListeners();
  }

  void updateTip(double value) {
    _tipPercent = value;
    notifyListeners();
  }

  void updateTax(String value) {
    _taxPercent = double.tryParse(value) ?? 0;
    notifyListeners();
  }

  void updatePeople(double value) {
    _people = value.toInt();
    notifyListeners();
  }

  void toggleRoundUp(bool value) {
    _roundUp = value;
    notifyListeners();
  }

  void updateCurrency(Currency c) {
    _currency = c;
    notifyListeners();
  }

  // ---------------- SAVE BILL ----------------
  void saveBill() {
    if (_bill <= 0) return;

    _history.insert(0, TipBill(bill: _bill, total: total, perPerson: perPerson, people: _people, tip: _tipPercent, tax: _taxPercent, currency: _currency, date: DateTime.now()));

    // Reset everything
    _bill = 0;
    _tipPercent = 15;
    _taxPercent = 0;
    _people = 1;
    _roundUp = false;
    _currency = Currency.inr;
    notifyListeners();
  }

  // ---------------- LOAD FROM HISTORY ----------------
  void loadFromHistory(TipBill bill) {
    _bill = bill.bill;
    _tipPercent = bill.tip;
    _taxPercent = bill.tax;
    _people = bill.people;
    _currency = bill.currency;

    notifyListeners();
  }

  // ---------------- CLEAR HISTORY (OPTIONAL) ----------------
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
