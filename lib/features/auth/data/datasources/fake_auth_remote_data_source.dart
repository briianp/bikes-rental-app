import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bikes_app/features/auth/data/models/user_model.dart';

/// Autenticación del modo demo.
class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  const FakeAuthRemoteDataSource(this._database);

  final InMemoryDatabase _database;

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await _database.simulateNetwork();

    final user = _database.users
        .where((u) => u['email'] == email && u['password'] == password)
        .firstOrNull;
    if (user == null) {
      throw const ApiException(401, 'Correo o contraseña incorrectos.');
    }

    _database.currentUserId = user['id'] as String;
    return UserModel.fromJson(_database.userJson(user));
  }

  @override
  Future<UserModel?> currentUser() async {
    final user = _database.currentUser;
    return user == null ? null : UserModel.fromJson(_database.userJson(user));
  }

  @override
  Future<void> signOut() async {
    await _database.simulateNetwork();
    _database.currentUserId = null;
  }
}
