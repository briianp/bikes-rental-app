import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bikes_app/features/auth/domain/usecases/sign_in.dart';

/// Caso de uso: recuperar la sesión guardada al abrir la app.
///
/// Si el usuario fue desactivado mientras tanto, cierra la sesión.
class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<AppUser?> call() async {
    final user = await _repository.currentUser();
    if (user == null) return null;
    if (SignIn.accessErrorFor(user) != null) {
      await _repository.signOut();
      return null;
    }
    return user;
  }
}
