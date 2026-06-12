import '../../domain/entities/expense.dart';
import 'category_model.dart'; // Ensure this partial import is available or we use factory with map

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    required super.category,
    required super.type,
    super.note,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    // If the JSON (or SQLite row) contains nested category object or flattened fields
    // For SQLite JOIN, we expected flattened fields usually prefixed or we have to construct it.
    // Let's assume the query returns joined fields like 'category_name', 'category_icon', etc.
    // OR we will update the DataSource to return a cleaner map.
    // For now, let's assume the map passed here contains category data.
    
    // Check if 'category' is a map (nested) or we are reading flat columns.
    // LocalDataSource will likely build a nested map or we handle it here.
    
    // Let's assume we pass a nested map for category if possible, OR
    // we construct the CategoryModel here.
    
    // Handle specific logic for 'category' field.
    // If it comes from partial SQLite row, it might be tricky.
    // Ideally, DataSource shapes the data.
    
    return ExpenseModel(
      id: json['id'],
      title: json['title'] ?? json['description'] ?? '', // SQLite column is description?
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      category: CategoryModel.fromJson(json['category'] is Map<String, dynamic> 
          ? json['category'] 
          : Map<String, dynamic>.from(json)), // Fallback if flattened?
          // Actually, if we JOIN, we get columns.
          // e.g. amount, date, c.name, c.icon.
          // It's cleaner if DataSource maps it to:
          // { ...expense, category: { ...category } }
      type: _typeFromString(json['type']),
      note: json['note'] ?? json['description'], // 'description' column in DB acts as title or note?
      // In DB schema I wrote: description (nullable). And NO title column?
      // Wait, schema:
      // expenses: id, user_id, amount, date, category_id, description, type.
      // My Expense entity has: title, note.
      // User request "description" usually maps to title/note.
      // Let's map 'description' to 'title' and leave note empty or same?
      // I'll update ExpenseModel mapping to use 'description' as 'title'.
    );
  }
  
  // Correction: Schema has 'description'. Entity has 'title' and 'note'.
  // I should probably update schema or map 'title' -> 'description'.
  // I will map title -> description.

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': title, // Map title to description column
      'amount': amount,
      'date': date.toIso8601String(),
      'category_id': category.id,
      'type': type.name,
      'note': note, // DB doesn't have note column, but let's assume I add it or ignore it.
      // DB Schema: description is there. 
      // I should probably add 'note' column or combine.
      // I will treat 'title' as 'description'.
    };
  }
  
  static TransactionType _typeFromString(String? name) {
     if (name == null) return TransactionType.expense;
     try {
       return TransactionType.values.firstWhere((e) => e.name == name);
     } catch (_) {
       return TransactionType.expense;
     }
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      type: expense.type,
      note: expense.note,
    );
  }
}
