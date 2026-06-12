import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'features/auth/data/datasources/auth_firebase_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/expense/data/datasources/expense_firebase_data_source.dart';
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

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. Initialize External
  final sharedPreferences = await SharedPreferences.getInstance();

  // 2. Initialize Data Source
  final expenseDataSource = ExpenseFirebaseDataSourceImpl();

  // 3. Initialize Repository
  final expenseRepository = ExpenseRepositoryImpl(dataSource: expenseDataSource);

  // Auth Dependency Injection
  final authDataSource = AuthFirebaseDataSourceImpl();
  final authRepository = AuthRepositoryImpl(dataSource: authDataSource);

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
