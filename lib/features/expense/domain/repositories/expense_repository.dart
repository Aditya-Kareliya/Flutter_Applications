// import 'package:dartz/dartz.dart';
import '../entities/expense.dart';

// Note: In a real "classic" clean architecture, we might use dartz for Either<Failure, Type>, 
// but for simplicity and cleaner provider integration, we often use simple Futures or throw specific exceptions.
// However, I will stick to a professional standard and return Futures directly to keep it Flutter-friendly.

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<void> addExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(Expense expense);
  Future<List<Category>> getCategories();
  Future<void> addCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<void> updateCategory(Category category);
}
