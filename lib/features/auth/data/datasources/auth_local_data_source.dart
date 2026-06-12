import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../../../core/database/database_helper.dart';
import 'package:uuid/uuid.dart';

abstract class AuthLocalDataSource {
  Future<User?> login(String email, String password);
  Future<User?> register(String email, String password, String name);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final DatabaseHelper databaseHelper;
  static const String currentUserIdKey = 'CURRENT_USER_ID';

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    // dependencies usually injected, but defaulting here for simplicity if DI container not fully set up for it yet
    DatabaseHelper? dbHelper, 
  }) : databaseHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<User?> login(String email, String password) async {
    final db = await databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      final user = _userFromMap(maps.first);
      await _cacheUserId(user.id);
      return user;
    } else {
      throw Exception('Invalid Credentials');
    }
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(currentUserIdKey);
  }

  @override
  Future<User?> getCurrentUser() async {
    final userId = sharedPreferences.getString(currentUserIdKey);
    if (userId == null) return null;

    final db = await databaseHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return _userFromMap(maps.first);
    }
    return null;
  }

  @override
  Future<User?> register(String email, String password, String name) async {
    final db = await databaseHelper.database;
    final exists = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (exists.isNotEmpty) {
      throw Exception('Email already exists'); // Changed message
    }

    final id = const Uuid().v4();
    final user = User(
      id: id,
      email: email,
      name: name,
      currency: '₹', // Default
      themeMode: 'system', // Default
      themeColor: '0xFF2196F3', // Default Blue
    );

    await db.insert('users', {
      'id': user.id,
      'email': user.email,
      'password': password, // In production, hash this!
      'name': user.name,
      'currency': user.currency,
      'theme_mode': user.themeMode,
      'theme_color': user.themeColor,
    });

    await _createDefaultCategories(id);
    await _cacheUserId(id);
    
    return user;
  }

  @override
  Future<void> deleteUser(String id) async {
    final db = await databaseHelper.database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    final currentId = await _getUserId(); // Use new helper
    if (currentId == id) {
      await logout();
    }
  }

  // Helper to map DB row to User
  User _userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      name: map['name'],
      currency: map['currency'],
      themeMode: map['theme_mode'],
      themeColor: map['theme_color'],
    );
  }

  @override
  Future<void> updateUser(User user) async {
    final db = await databaseHelper.database;
    await db.update(
      'users',
      {
        'name': user.name,
        'currency': user.currency,
        'theme_mode': user.themeMode,
        'theme_color': user.themeColor,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> _cacheUserId(String userId) async {
    await sharedPreferences.setString(currentUserIdKey, userId);
  }

  Future<String?> _getUserId() async {
    return sharedPreferences.getString(currentUserIdKey);
  }

  Future<void> _createDefaultCategories(String userId) async {
    final db = await databaseHelper.database;
    final defaultCategories = [
      {'name': 'Food', 'icon': 'fastfood', 'color': '0xFFFF6B6B', 'type': 'expense'},
      {'name': 'Transport', 'icon': 'directions_car', 'color': '0xFF4ECDC4', 'type': 'expense'},
      {'name': 'Shopping', 'icon': 'shopping_bag', 'color': '0xFFFFD93D', 'type': 'expense'},
      {'name': 'Entertainment', 'icon': 'movie', 'color': '0xFF6C5CE7', 'type': 'expense'},
      {'name': 'Health', 'icon': 'medical_services', 'color': '0xFFFC5C65', 'type': 'expense'},
      {'name': 'Bills', 'icon': 'receipt', 'color': '0xFFA55EEA', 'type': 'expense'},
      {'name': 'Salary', 'icon': 'attach_money', 'color': '0xFF26DE81', 'type': 'income'},
      {'name': 'Investment', 'icon': 'trending_up', 'color': '0xFF2D98DA', 'type': 'income'},
    ];

    final batch = db.batch();
    for (var cat in defaultCategories) {
      batch.insert('categories', {
        'id': const Uuid().v4(),
        'user_id': userId,
        ...cat
      });
    }
    await batch.commit(noResult: true);
  }
}
