import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/auth/domain/repositories/auth_repository.dart';

/// Implementación del contrato del dominio.
///
/// Convierte modelos en entidades y errores técnicos en `Failure`.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return guardApiCall(() async {
      final model = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return model.toEntity();
    });
  }

  @override
  Future<AppUser?> currentUser() {
    return guardApiCall(() async {
      final model = await _remoteDataSource.currentUser();
      return model?.toEntity();
    });
  }

  @override
  Future<void> signOut() => guardApiCall(_remoteDataSource.signOut);
}
