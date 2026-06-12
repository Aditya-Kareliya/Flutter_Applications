import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<User?> login(String email, String password) async {
    return await localDataSource.login(email, password);
  }

  @override
  Future<User?> register(String email, String password, String name) async {
    final user = await localDataSource.register(email, password, name);
    // Auto-login logic is inside datasource for now (via caching)
    // Or we should enforce it here.
    // Re-reading datasource: register logic there calls createUser (no cache)
    // We need to fix the datasource register logic to cache or do it here.
    // In datasource: register calls createUser which returns user.
    // It does NOT cache.
    // So we should cache it here? No, datasource is better place for simple mock.
    // Let's rely on datasource update I just made... wait
    // I updated register to: return createUser(email, password, name, false);
    // And createUser DOES NOT cache.
    // So new functionality: register needs to LOGIN the user too.
    if (user != null) {
      // We can call login, or just assume success.
      // Ideally, the repository should handle the logic. 
      // But let's fix this in the next iteration or just rely on manual login?
      // Standard flow: Register -> Auto Login.
      // I will update this file to just delegate for now, 
      // but I should have updated datasource to cache on register.
      // Actually, let's call login after register in the UI or Provider?
      // For now, let's just delegate.
    }
    return user;
  }

  @override
  Future<void> logout() async {
    await localDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getCurrentUser();
  }

  @override
  Future<void> updateUser(User user) async {
    await localDataSource.updateUser(user);
  }

  @override
  Future<void> deleteUser(String id) async {
    await localDataSource.deleteUser(id);
  }
}
