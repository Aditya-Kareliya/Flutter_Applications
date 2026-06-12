import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_strings.dart';
import 'core/settings/settings_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/expense/domain/usecases/add_expense.dart';
import 'features/expense/domain/usecases/delete_expense.dart';
import 'features/expense/domain/usecases/get_categories.dart';
import 'features/expense/domain/usecases/get_expenses.dart';
import 'features/expense/domain/usecases/update_expense.dart';
import 'features/expense/domain/usecases/add_category.dart';
import 'features/expense/domain/usecases/delete_category.dart';
import 'features/expense/domain/usecases/update_category.dart';
import 'features/expense/presentation/pages/home_page.dart';
import 'features/expense/presentation/provider/add_expense_provider.dart';
import 'features/expense/presentation/provider/expense_provider.dart';
import 'features/expense/presentation/provider/navigation_provider.dart';
import 'features/expense/presentation/provider/search_provider.dart';


class ExpenseTrackerApp extends StatelessWidget {
  final GetExpenses getExpenses;
  final GetCategories getCategories;
  final AddExpense addExpense;
  final DeleteExpense deleteExpense;
  final UpdateExpense updateExpense;
  final AddCategory addCategory;
  final DeleteCategory deleteCategory;
  final UpdateCategory updateCategory;
  final SharedPreferences sharedPreferences;
  final AuthRepository authRepository;

  const ExpenseTrackerApp({
    super.key,
    required this.getExpenses,
    required this.getCategories,
    required this.addExpense,
    required this.deleteExpense,
    required this.updateExpense,
    required this.addCategory,
    required this.deleteCategory,
    required this.updateCategory,
    required this.sharedPreferences,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(sharedPreferences: sharedPreferences)),
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository: authRepository)),
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(
            getCategoriesUsecase: getCategories,
            getExpensesUsecase: getExpenses,
            addExpenseUsecase: addExpense,
            deleteExpenseUsecase: deleteExpense,
            updateExpenseUsecase: updateExpense,
            addCategoryUsecase: addCategory,
            deleteCategoryUsecase: deleteCategory,
            updateCategoryUsecase: updateCategory,
          ),
        ),
        ChangeNotifierProvider(create: (_) => AddExpenseProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(sharedPreferences: sharedPreferences)),
      ],
      child: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
          return Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return MaterialApp(
                title: AppStrings.appName,
                theme: AppTheme.lightTheme(settings.primaryColor),
                darkTheme: AppTheme.darkTheme(settings.primaryColor),
                themeMode: themeProvider.themeMode,
                debugShowCheckedModeBanner: false,
                scrollBehavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', 'US'),
                ],
                home: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.status == AuthStatus.authenticated) {
                      return const HomePage();
                    }
                    return const LoginPage();
                  },
                ),
              );
            },
          );
            },
          );
        },
      ),
    );
  }
}
