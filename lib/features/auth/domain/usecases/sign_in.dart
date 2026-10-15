import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: iniciar sesión.
///
/// Además de validar las credenciales, aplica las reglas de acceso:
/// el usuario debe estar activo y, si es empleado, tener sucursal.
class SignIn {
  const SignIn(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.isEmpty) {
      throw const ValidationFailure('Ingresa tu correo y contraseña.');
    }

    final user = await _repository.signIn(
      email: normalizedEmail,
      password: password,
    );

    final accessError = accessErrorFor(user);
    if (accessError != null) {
      await _repository.signOut();
      throw AuthFailure(accessError);
    }
    return user;
  }

  /// `null` si el usuario puede usar la app; si no, el motivo.
  static String? accessErrorFor(AppUser user) {
    if (!user.isActive) {
      return 'Tu usuario está desactivado. Contacta a un administrador.';
    }
    if (!user.isAdmin && user.branchId == null) {
      return 'Tu usuario no tiene sucursal asignada. Contacta a un administrador.';
    }
    return null;
  }
}
