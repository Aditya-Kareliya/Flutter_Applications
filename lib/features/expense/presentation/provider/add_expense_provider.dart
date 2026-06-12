import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/expense.dart';
import 'expense_provider.dart';

class AddExpenseProvider extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController(); 

  Category? _selectedCategory;
  Category? get selectedCategory => _selectedCategory;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  TransactionType _selectedType = TransactionType.expense;
  TransactionType get selectedType => _selectedType;

  // Form Key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void setCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setType(TransactionType type) {
    _selectedType = type;
    notifyListeners();
  }

  void initializeForEdit(Expense expense) {
    titleController.text = expense.title;
    amountController.text = expense.amount.toString();
    noteController.text = expense.note ?? '';
    _selectedCategory = expense.category;
    _selectedDate = expense.date;
    _selectedType = expense.type;
    notifyListeners();
  }

  void reset() {
    clearForm();
  }

  void clearForm() {
    titleController.clear();
    amountController.clear();
    noteController.clear();
    _selectedCategory = null; // Reset to null, UI should handle selection
    _selectedDate = DateTime.now();
    _selectedType = TransactionType.expense;
    notifyListeners();
  }

  bool validateAndAddExpense(ExpenseProvider expenseProvider) {
    if (formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
         // Should handle validation manually or ensure UI forces selection
         return false; 
      }
      
      final title = titleController.text;
      final amount = double.tryParse(amountController.text) ?? 0.0;
      final note = noteController.text;

      final expense = Expense(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory!,
        type: _selectedType,
        note: note.isNotEmpty ? note : null,
      );

      expenseProvider.addExpense(expense);
      clearForm();
      return true;
    }
    return false;
  }
  
  bool validateAndUpdateExpense(ExpenseProvider expenseProvider, String id) {
    if (formKey.currentState!.validate()) {
      if (_selectedCategory == null) return false;

      final title = titleController.text;
      final amount = double.tryParse(amountController.text) ?? 0.0;
      final note = noteController.text;

      final expense = Expense(
        id: id,
        title: title,
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory!,
        type: _selectedType,
        note: note.isNotEmpty ? note : null,
      );

      expenseProvider.updateExpense(expense);
      clearForm();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }
}

