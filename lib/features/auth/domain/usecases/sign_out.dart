import 'package:bikes_app/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: cerrar sesión.
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
