import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class AdminAuthState {
  const AdminAuthState();
}

final class AdminLoggedOut extends AdminAuthState {
  const AdminLoggedOut();
}

final class AdminAuthenticating extends AdminAuthState {
  const AdminAuthenticating();
}

final class AdminLoggedIn extends AdminAuthState {
  const AdminLoggedIn();
}

final class AdminAuthFailure extends AdminAuthState {
  const AdminAuthFailure(this.message);
  final String message;
}

class AdminAuthCubit extends Cubit<AdminAuthState> {
  static const _authKey = 'admin_is_logged_in';

  AdminAuthCubit() : super(const AdminAuthenticating()) {
    restoreSession();
  }

  Future<void> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_authKey) ?? false;
      if (isLoggedIn) {
        emit(const AdminLoggedIn());
      } else {
        emit(const AdminLoggedOut());
      }
    } catch (e) {
      emit(const AdminLoggedOut());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(const AdminAuthenticating());
    
    // Simulate network request for effect
    await Future.delayed(const Duration(milliseconds: 600));
    
    if (email.trim() == 'admin' && password == 'Pavan@1212') {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_authKey, true);
      } catch (_) {}
      emit(const AdminLoggedIn());
    } else {
      emit(const AdminAuthFailure('Incorrect username or password. Please try again.'));
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authKey, false);
    } catch (_) {}
    emit(const AdminLoggedOut());
  }
}


