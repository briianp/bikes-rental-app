import 'dart:async';

import 'package:bikes_app/features/auth/auth_dependencies.dart';
import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Estado del formulario de login: `AsyncData` (en reposo),
/// `AsyncLoading` (enviando) o `AsyncError` (credenciales inválidas, etc.).
final loginControllerProvider =
    AsyncNotifierProvider.autoDispose<LoginController, void>(
      LoginController.new,
    );

class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final user = await ref
          .read(signInUseCaseProvider)
          .call(email: email, password: password);
      ref.read(sessionProvider.notifier).signedIn(user);
    });
    // Si el usuario salió de la pantalla mientras esperábamos, no hacemos nada.
    if (ref.mounted) state = result;
  }
}
