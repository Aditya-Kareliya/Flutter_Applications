import '../../domain/entities/expense.dart';

import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_data_source.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Expense>> getExpenses() async {
    return await localDataSource.getExpenses();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await localDataSource.addExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> deleteExpense(String id) async {
    await localDataSource.deleteExpense(id);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await localDataSource.updateExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<List<Category>> getCategories() async {
    return await localDataSource.getCategories();
  }

  @override
  Future<void> addCategory(Category category) async {
    await localDataSource.addCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localDataSource.deleteCategory(id);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await localDataSource.updateCategory(CategoryModel.fromEntity(category));
  }
}
