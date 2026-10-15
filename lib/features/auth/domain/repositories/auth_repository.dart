import 'package:bikes_app/features/auth/domain/entities/app_user.dart';

/// Contrato que la capa de datos debe cumplir.
///
/// El dominio define *qué* necesita; la capa de datos decide *cómo*
/// (Supabase, datos de demostración, otra API...).
abstract interface class AuthRepository {
  /// Lanza una `AuthFailure` si las credenciales son incorrectas.
  Future<AppUser> signIn({required String email, required String password});

  /// Usuario de la sesión guardada en el dispositivo, o `null`.
  Future<AppUser?> currentUser();

  Future<void> signOut();
}
