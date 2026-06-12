import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(ExpenseModel expense);
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> updateCategory(CategoryModel category);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final SharedPreferences sharedPreferences;
  final DatabaseHelper databaseHelper;
  static const String currentUserIdKey = 'CURRENT_USER_ID';

  ExpenseLocalDataSourceImpl({
    required this.sharedPreferences,
    DatabaseHelper? dbHelper,
  }) : databaseHelper = dbHelper ?? DatabaseHelper.instance;

  Future<String?> _getCurrentUserId() async {
    return sharedPreferences.getString(currentUserIdKey);
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return [];

    final db = await databaseHelper.database;
    
    // We join expenses with categories to get full details
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        e.id, 
        e.description as title, 
        e.amount, 
        e.date, 
        e.type, 
        e.description as note,
        c.id as cat_id,
        c.name as cat_name,
        c.icon as cat_icon,
        c.color as cat_color,
        c.type as cat_type
      FROM expenses e
      LEFT JOIN categories c ON e.category_id = c.id
      WHERE e.user_id = ?
      ORDER BY e.date DESC
    ''', [userId]);

    return result.map((row) {
      // Construct nested category map
      final categoryMap = {
        'id': row['cat_id'],
        'name': row['cat_name'],
        'icon': row['cat_icon'],
        'color': row['cat_color'],
        'type': row['cat_type'],
      };

      // Construct expense map suitable for ExpenseModel.fromJson
      final expenseMap = {
        'id': row['id'],
        'title': row['title'],
        'amount': row['amount'],
        'date': row['date'],
        'category': categoryMap,
        'type': row['type'],
        'note': row['note'],
      };
      
      return ExpenseModel.fromJson(expenseMap);
    }).toList();
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    final db = await databaseHelper.database;
    
    // Convert to JSON and add user_id
    final expenseMap = expense.toJson();
    expenseMap['user_id'] = userId;
    
    // Remove fields not in table if toJson includes extra (like 'category' object, we need 'category_id')
    // expense.toJson() returns 'category_id', but might map 'description' from 'title'.
    // Ensure keys match DB columns: id, user_id, amount, date, category_id, description, type
    
    final dbMap = {
      'id': expenseMap['id'],
      'user_id': userId,
      'amount': expenseMap['amount'],
      'date': expenseMap['date'],
      'category_id': expenseMap['category_id'],
      'description': expenseMap['description'], // mapped from title in model
      'type': expenseMap['type'],
    };

    await db.insert('expenses', dbMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final db = await databaseHelper.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');
    
    final db = await databaseHelper.database;
    final expenseMap = expense.toJson();
    
    final dbMap = {
      'amount': expenseMap['amount'],
      'date': expenseMap['date'],
      'category_id': expenseMap['category_id'],
      'description': expenseMap['description'],
      'type': expenseMap['type'],
    };

    await db.update(
      'expenses',
      dbMap,
      where: 'id = ? AND user_id = ?',
      whereArgs: [expense.id, userId],
    );
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return [];

    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return maps.map((e) => CategoryModel.fromJson(e)).toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    final db = await databaseHelper.database;
    final catMap = category.toJson();
    catMap['user_id'] = userId;
    
    await db.insert('categories', catMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteCategory(String id) async {
    final db = await databaseHelper.database;
    // Note: deleting a category might affect expenses. 
    // Usually we might want to set category_id to 'uncategorized' or similar for expenses using this category.
    // For now, strict delete.
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final userId = await _getCurrentUserId();
    if (userId == null) throw Exception('User not logged in');

    final db = await databaseHelper.database;
    final catMap = category.toJson();

    await db.update(
      'categories',
      catMap,
      where: 'id = ? AND user_id = ?',
      whereArgs: [category.id, userId],
    );
  }
}
