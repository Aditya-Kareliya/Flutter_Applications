import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/expense/data/datasources/expense_local_data_source.dart';
import 'features/expense/data/repositories/expense_repository_impl.dart';
import 'features/expense/domain/usecases/add_expense.dart';
import 'features/expense/domain/usecases/delete_expense.dart';
import 'features/expense/domain/usecases/get_expenses.dart';

import 'features/expense/domain/usecases/update_expense.dart';
import 'features/expense/domain/usecases/get_categories.dart';
import 'features/expense/domain/usecases/add_category.dart';
import 'features/expense/domain/usecases/delete_category.dart';
import 'features/expense/domain/usecases/update_category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize External
  final sharedPreferences = await SharedPreferences.getInstance();

  // 2. Initialize Data Source
  final expenseLocalDataSource = ExpenseLocalDataSourceImpl(sharedPreferences: sharedPreferences);

  // 3. Initialize Repository
  final expenseRepository = ExpenseRepositoryImpl(localDataSource: expenseLocalDataSource);

  // Auth Dependency Injection
  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  final authRepository = AuthRepositoryImpl(localDataSource: authLocalDataSource);

  // 4. Initialize Usecases
  final getCategories = GetCategories(expenseRepository);
  final getExpenses = GetExpenses(expenseRepository);
  final addExpense = AddExpense(expenseRepository);
  final deleteExpense = DeleteExpense(expenseRepository);
  final updateExpense = UpdateExpense(expenseRepository);
  final addCategory = AddCategory(expenseRepository);
  final deleteCategory = DeleteCategory(expenseRepository);
  final updateCategory = UpdateCategory(expenseRepository);

  runApp(ExpenseTrackerApp(
    getCategories: getCategories,
    getExpenses: getExpenses,
    addExpense: addExpense,
    deleteExpense: deleteExpense,
    updateExpense: updateExpense,
    addCategory: addCategory,
    deleteCategory: deleteCategory,
    updateCategory: updateCategory,
    sharedPreferences: sharedPreferences,
    authRepository: authRepository,
  ));
}
