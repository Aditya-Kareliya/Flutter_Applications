import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Get the documents directory for the app
    // We use getDatabasesPath() for Android/iOS default, but since we might want encryption or specific backups later, 
    // relying on default is usually fine.
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const realType = 'REAL NOT NULL';

    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        email $textType UNIQUE,
        password $textType,
        name $textType,
        currency $textTypeNullable,
        theme_mode $textTypeNullable,
        theme_color $textTypeNullable
      )
    ''');

    // 2. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id $idType,
        user_id $textType,
        name $textType,
        icon $textTypeNullable,
        color $textTypeNullable,
        type $textType, 
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    // type: 'expense' or 'income'

    // 3. Expenses Table (Transactions)
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        user_id $textType,
        amount $realType,
        date $textType,
        category_id $textType,
        description $textTypeNullable,
        type $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )
    ''');

    // 4. Budgets Table (Optional start)
    await db.execute('''
      CREATE TABLE budgets (
        id $idType,
        user_id $textType,
        amount $realType,
        category_id $textTypeNullable,
        start_date $textType,
        end_date $textType,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
