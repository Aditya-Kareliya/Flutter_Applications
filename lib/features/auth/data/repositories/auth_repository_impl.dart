import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<User?> login(String email, String password) async {
    return await dataSource.login(email, password);
  }

  @override
  Future<User?> register(String email, String password, String name) async {
    return await dataSource.register(email, password, name);
  }

  @override
  Future<void> logout() async {
    await dataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await dataSource.getCurrentUser();
  }

  @override
  Future<void> updateUser(User user) async {
    await dataSource.updateUser(user);
  }

  @override
  Future<void> deleteUser(String id) async {
    await dataSource.deleteUser(id);
  }
}
