import 'package:equatable/equatable.dart';
import 'category.dart';
import 'transaction_type.dart';

export 'transaction_type.dart';
export 'category.dart';

class Expense extends Equatable {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final TransactionType type;
  final String? note;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.type = TransactionType.expense,
    this.note,
  });

  @override
  List<Object?> get props => [id, title, amount, date, category, type, note];
}
