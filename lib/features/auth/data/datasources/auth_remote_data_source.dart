import 'package:bikes_app/features/auth/data/models/user_model.dart';

/// Fuente de datos de autenticación.
///
/// Implementaciones: `SupabaseAuthRemoteDataSource` (producción) y
/// `FakeAuthRemoteDataSource` (modo demo y tests).
abstract interface class AuthRemoteDataSource {
  Future<UserModel> signIn({required String email, required String password});

  /// Perfil del usuario con sesión guardada, o `null`.
  Future<UserModel?> currentUser();

  Future<void> signOut();
}
