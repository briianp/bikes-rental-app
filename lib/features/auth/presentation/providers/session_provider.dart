import 'package:bikes_app/features/auth/auth_dependencies.dart';
import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Usuario con sesión activa (`null` = sin sesión).
///
/// · El router lo escucha para redirigir al login o al inicio.
/// · Los providers de datos lo observan para recargarse al cambiar de
///   usuario (cada empleado ve solo su sucursal).
final sessionProvider = NotifierProvider<SessionNotifier, AppUser?>(
  SessionNotifier.new,
);

class SessionNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;

  /// Recupera la sesión guardada. Se llama una vez en `main.dart`.
  Future<void> restore() async {
    try {
      state = await ref.read(getCurrentUserUseCaseProvider).call();
    } catch (_) {
      state = null;
    }
  }

  void signedIn(AppUser user) => state = user;

  Future<void> signOut() async {
    try {
      await ref.read(signOutUseCaseProvider).call();
    } catch (_) {
      // Aunque falle la red, cerramos la sesión dentro de la app.
    }
    state = null;
  }
}

/// Id del usuario actual. Los providers de datos lo observan con `watch`
/// para descartar la caché cuando cambia el usuario.
String? watchSessionUserId(Ref ref) =>
    ref.watch(sessionProvider.select((user) => user?.id));
