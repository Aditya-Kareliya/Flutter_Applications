import '../../domain/entities/expense.dart';

import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_firebase_data_source.dart';
import '../models/category_model.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDataSource dataSource;

  ExpenseRepositoryImpl({required this.dataSource});

  @override
  Future<List<Expense>> getExpenses() async {
    return await dataSource.getExpenses();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await dataSource.addExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<void> deleteExpense(String id) async {
    await dataSource.deleteExpense(id);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await dataSource.updateExpense(ExpenseModel.fromEntity(expense));
  }

  @override
  Future<List<Category>> getCategories() async {
    return await dataSource.getCategories();
  }

  @override
  Future<void> addCategory(Category category) async {
    await dataSource.addCategory(CategoryModel.fromEntity(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await dataSource.deleteCategory(id);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await dataSource.updateCategory(CategoryModel.fromEntity(category));
  }
}
