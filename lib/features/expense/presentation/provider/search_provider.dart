import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';

class SearchProvider extends ChangeNotifier {
  String _query = '';
  String get query => _query;

  void setQuery(String query) {
    _query = query;
    notifyListeners();
  }

  List<Expense> filterExpenses(List<Expense> allExpenses) {
    if (_query.isEmpty) {
      return [];
    }
    return allExpenses.where((expense) {
      final titleMatch = expense.title.toLowerCase().contains(_query.toLowerCase());
      final categoryMatch = expense.category.displayName.toLowerCase().contains(_query.toLowerCase());
      return titleMatch || categoryMatch;
    }).toList();
  }

  void clearSearch() {
    _query = '';
    notifyListeners();
  }
}
