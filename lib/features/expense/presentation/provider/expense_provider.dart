import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/add_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/update_category.dart';

class ExpenseProvider extends ChangeNotifier {
  final GetCategories getCategoriesUsecase;
  final GetExpenses getExpensesUsecase;
  final AddExpense addExpenseUsecase;
  final DeleteExpense deleteExpenseUsecase;
  final UpdateExpense updateExpenseUsecase;
  final AddCategory addCategoryUsecase;
  final DeleteCategory deleteCategoryUsecase;
  final UpdateCategory updateCategoryUsecase;

  ExpenseProvider({
    required this.getCategoriesUsecase,
    required this.getExpensesUsecase,
    required this.addExpenseUsecase,
    required this.deleteExpenseUsecase,
    required this.updateExpenseUsecase,
    required this.addCategoryUsecase,
    required this.deleteCategoryUsecase,
    required this.updateCategoryUsecase,
  });

  List<Category> _categories = [];
  List<Category> get categories => _categories;


  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  double get totalBalance {
    return _expenses.fold(0, (sum, item) {
      if (item.type == TransactionType.income) {
        return sum + item.amount;
      } else {
        return sum - item.amount;
      }
    });
  }

  double get totalIncome {
    return _expenses
        .where((e) => e.type == TransactionType.income)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get totalExpense {
    return _expenses
        .where((e) => e.type == TransactionType.expense)
        .fold(0, (sum, item) => sum + item.amount);
  }

  Map<Category, double> getCategoryTotals(TransactionType type) {
    final Map<Category, double> totals = {};
    for (var expense in _expenses) {
      if (expense.type == type) {
        totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
      }
    }
    return totals;
  }
  
  // Deprecated: use getCategoryTotals(TransactionType.expense) instead if needed strictly for expense
  Map<Category, double> get categoryTotals => getCategoryTotals(TransactionType.expense);

  Map<DateTime, double> getMonthlyTotals(TransactionType type) {
    final Map<DateTime, double> totals = {};
    final now = DateTime.now();
    // Initialize last 6 months with 0
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      totals[date] = 0.0;
    }

    for (var expense in _expenses) {
      if (expense.type == type) {
        // Only count if within last 6 months window approx
        final monthStart = DateTime(expense.date.year, expense.date.month, 1);
        if (totals.containsKey(monthStart)) {
          totals[monthStart] = (totals[monthStart] ?? 0) + expense.amount;
        }
      }
    }
    return totals;
  }

  Future<void> loadCategories() async {
    try {
      _categories = await getCategoriesUsecase();
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load categories first so we have them available (though expense has category object nested)
      await loadCategories(); 
      _expenses = await getExpensesUsecase();
      // Sort by date descending
      _expenses.sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      _error = "Failed to load expenses";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await addExpenseUsecase(expense);
      _expenses.insert(0, expense); // Optimistic update
      notifyListeners();
    } catch (e) {
      _error = "Failed to add expense";
      notifyListeners();
      await loadExpenses(); // Re-fetch on error to ensure consistency
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final index = _expenses.indexWhere((e) => e.id == id);
      if (index != -1) {
        final removed = _expenses.removeAt(index);
        notifyListeners();
        
        try {
          await deleteExpenseUsecase(id);
        } catch (e) {
          // Rollback
          _expenses.insert(index, removed);
          _error = "Failed to delete expense";
          notifyListeners();
        }
      }
    } catch (e) {
      _error = "Failed to delete expense";
      notifyListeners();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      // Optimistic update
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
        // Sort again in case date changed
        _expenses.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
        
        try {
          await updateExpenseUsecase(expense);
        } catch (e) {
             // Rollback if needed, but for local storage it's rare.
             // Re-load to be safe.
             await loadExpenses();
             _error = "Failed to save update";
             notifyListeners();
        }
      }
    } catch (e) {
      _error = "Failed to update expense";
      notifyListeners();
      await loadExpenses();
    }
  }
  Future<void> addCategory(Category category) async {
    try {
      await addCategoryUsecase(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = "Failed to add category";
      notifyListeners();
      await loadCategories();
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await updateCategoryUsecase(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to update category";
      notifyListeners();
      await loadCategories();
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await deleteCategoryUsecase(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = "Failed to delete category";
      notifyListeners();
      await loadCategories();
    }
  }
}
