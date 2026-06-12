import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

abstract class ExpenseDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
  Future<void> updateExpense(ExpenseModel expense);
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<void> updateCategory(CategoryModel category);
}
class ExpenseFirebaseDataSourceImpl implements ExpenseDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  List<CategoryModel>? _cachedCategories;
  String? _cachedUserId;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return [];

    if (_cachedCategories != null && _cachedUserId == userId) {
      return _cachedCategories!;
    }

    final snapshot = await _firestore
        .collection('categories')
        .where('user_id', isEqualTo: userId)
        .get();

    _cachedCategories = snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data(), fallbackId: doc.id))
        .toList();
    _cachedUserId = userId;

    return _cachedCategories!;
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final catMap = category.toJson();
    catMap['user_id'] = userId;

    await _firestore.collection('categories').doc(category.id).set(catMap);

    if (_cachedCategories != null && _cachedUserId == userId) {
      _cachedCategories!.removeWhere((c) => c.id == category.id);
      _cachedCategories!.add(category);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _firestore.collection('categories').doc(id).delete();

    if (_cachedCategories != null) {
      _cachedCategories!.removeWhere((c) => c.id == id);
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final catMap = category.toJson();
    catMap['user_id'] = userId;

    await _firestore.collection('categories').doc(category.id).update(catMap);

    if (_cachedCategories != null && _cachedUserId == userId) {
      final index = _cachedCategories!.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _cachedCategories![index] = category;
      } else {
        _cachedCategories!.add(category);
      }
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) return [];

    final expenseSnapshot = await _firestore
        .collection('expenses')
        .where('user_id', isEqualTo: userId)
        .get();

    final categories = await getCategories();
    final categoriesMap = {
      for (var cat in categories) cat.id: cat
    };

    final expenses = expenseSnapshot.docs.map((doc) {
      final data = doc.data();
      final categoryId = data['category_id'];

      final category = categoriesMap[categoryId] ?? CategoryModel(
        id: categoryId ?? '',
        name: 'Unknown',
        icon: 'help',
        color: '0xFF9E9E9E',
        type: data['type'] ?? 'expense',
      );

      final expenseMap = {
        'id': doc.id,
        'title': data['description'] ?? '',
        'amount': data['amount'],
        'date': data['date'],
        'category': category.toJson(),
        'type': data['type'],
        'note': data['note'] ?? data['description'],
      };

      return ExpenseModel.fromJson(expenseMap);
    }).toList();

    expenses.sort((a, b) => b.date.compareTo(a.date));
    return expenses;
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final expenseMap = expense.toJson();
    expenseMap['user_id'] = userId;

    await _firestore.collection('expenses').doc(expense.id).set(expenseMap);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final userId = _firebaseAuth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    final expenseMap = expense.toJson();
    expenseMap['user_id'] = userId;

    await _firestore.collection('expenses').doc(expense.id).update({
      'amount': expenseMap['amount'],
      'date': expenseMap['date'],
      'category_id': expenseMap['category_id'],
      'description': expenseMap['description'],
      'type': expenseMap['type'],
      'note': expenseMap['note'],
    });
  }
}
