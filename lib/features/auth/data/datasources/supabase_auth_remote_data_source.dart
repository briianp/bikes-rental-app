import 'package:bikes_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bikes_app/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Autenticación con Supabase Auth + tabla `profiles`.
///
/// Supabase guarda la sesión en el dispositivo, así que al reabrir la app
/// `currentUser()` la recupera sin pedir la contraseña.
class SupabaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const SupabaseAuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _profileColumns =
      'id, full_name, email, role, branch_id, is_active, branches(name)';

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _fetchProfile(response.user!.id);
  }

  @override
  Future<UserModel?> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  Future<UserModel> _fetchProfile(String userId) async {
    final json = await _client
        .from('profiles')
        .select(_profileColumns)
        .eq('id', userId)
        .single();
    return UserModel.fromJson(json);
  }
}
