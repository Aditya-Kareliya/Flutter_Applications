import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../../domain/entities/user.dart';

abstract class AuthDataSource {
  Future<User?> login(String email, String password);
  Future<User?> register(String email, String password, String name);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> updateUser(User user);
  Future<void> deleteUser(String id);
}

class AuthFirebaseDataSourceImpl implements AuthDataSource {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> login(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final userId = userCredential.user!.uid;
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists && doc.data() != null) {
      return _userFromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (doc.exists && doc.data() != null) {
      return _userFromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<User?> register(String email, String password, String name) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final userId = userCredential.user!.uid;

    final user = User(
      id: userId,
      email: email,
      name: name,
      currency: '₹', // Default
      themeMode: 'system', // Default
      themeColor: '0xFF2196F3', // Default Blue
    );

    await _firestore.collection('users').doc(userId).set({
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'currency': user.currency,
      'theme_mode': user.themeMode,
      'theme_color': user.themeColor,
    });

    await _createDefaultCategories(userId);

    return user;
  }

  @override
  Future<void> deleteUser(String id) async {
    await _firestore.collection('users').doc(id).delete();
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null && currentUser.uid == id) {
      await currentUser.delete();
    }
  }

  @override
  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).update({
      'name': user.name,
      'currency': user.currency,
      'theme_mode': user.themeMode,
      'theme_color': user.themeColor,
    });
  }

  User _userFromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      currency: map['currency'] ?? '₹',
      themeMode: map['theme_mode'] ?? 'system',
      themeColor: map['theme_color'] ?? '0xFF2196F3',
    );
  }

  Future<void> _createDefaultCategories(String userId) async {
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

    final batch = _firestore.batch();
    for (var cat in defaultCategories) {
      final docRef = _firestore.collection('categories').doc(); // Auto-generated ID
      batch.set(docRef, {
        'id': docRef.id,
        'user_id': userId,
        ...cat
      });
    }
    await batch.commit();
  }
}
