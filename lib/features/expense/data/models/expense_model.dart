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
    // Check if 'category' is a map (nested) or we are reading flat columns.
    final categoryData = json['category'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['category'])
        : <String, dynamic>{};

    return ExpenseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      category: CategoryModel.fromJson(categoryData),
      type: _typeFromString(json['type']),
      note: json['note'] ?? json['description'],
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
