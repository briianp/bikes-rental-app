import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/data/supabase_providers.dart';
import 'package:bikes_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bikes_app/features/auth/data/datasources/fake_auth_remote_data_source.dart';
import 'package:bikes_app/features/auth/data/datasources/supabase_auth_remote_data_source.dart';
import 'package:bikes_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bikes_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bikes_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:bikes_app/features/auth/domain/usecases/sign_in.dart';
import 'package:bikes_app/features/auth/domain/usecases/sign_out.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Inyección de dependencias del feature con Riverpod.
//
// Aquí se decide qué data source usar: Supabase o el modo demo. El resto
// de la app (dominio y pantallas) no se entera de la diferencia.

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  if (ref.watch(useSupabaseProvider)) {
    return SupabaseAuthRemoteDataSource(ref.watch(supabaseClientProvider));
  }
  return FakeAuthRemoteDataSource(ref.watch(inMemoryDatabaseProvider));
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);

final signInUseCaseProvider = Provider<SignIn>(
  (ref) => SignIn(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider<SignOut>(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);

final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>(
  (ref) => GetCurrentUser(ref.watch(authRepositoryProvider)),
);
