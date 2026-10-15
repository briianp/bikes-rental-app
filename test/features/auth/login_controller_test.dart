import 'package:bikes_app/core/constants/demo_credentials.dart';
import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/features/auth/presentation/providers/login_controller.dart';
import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  Future<AsyncValue<void>> signIn(
    ProviderContainer container, {
    String email = DemoCredentials.employeeEmail,
    String password = DemoCredentials.employeePassword,
  }) async {
    // Mantiene vivo el provider autoDispose durante el test.
    final subscription = container.listen(loginControllerProvider, (_, _) {});
    await container
        .read(loginControllerProvider.notifier)
        .signIn(email: email, password: password);
    return subscription.read();
  }

  test('login correcto guarda el usuario en la sesión', () async {
    final container = createTestContainer();

    final state = await signIn(container);

    expect(state, isA<AsyncData<void>>());
    final user = container.read(sessionProvider);
    expect(user?.email, DemoCredentials.employeeEmail);
    expect(user?.isAdmin, isFalse);
    expect(user?.branchName, 'Sucursal Centro');
  });

  test('el admin entra con su rol', () async {
    final container = createTestContainer();

    await signIn(container, email: DemoCredentials.adminEmail);

    expect(container.read(sessionProvider)?.isAdmin, isTrue);
  });

  test('contraseña incorrecta expone un AuthFailure', () async {
    final container = createTestContainer();

    final state = await signIn(container, password: 'incorrecta');

    expect(state.error, isA<AuthFailure>());
    expect(container.read(sessionProvider), isNull);
  });

  test('un usuario desactivado no puede entrar', () async {
    final database = createTestDatabase();
    database.findById(database.users, employeeCentroId)!['is_active'] = false;
    final container = createTestContainer(database: database);

    final state = await signIn(container);

    expect(state.error, isA<AuthFailure>());
    expect(container.read(sessionProvider), isNull);
  });

  test('un empleado sin sucursal no puede entrar', () async {
    final database = createTestDatabase();
    database.findById(database.users, employeeCentroId)!['branch_id'] = null;
    final container = createTestContainer(database: database);

    final state = await signIn(container);

    expect(state.error, isA<AuthFailure>());
  });

  test('cerrar sesión deja la sesión vacía', () async {
    final container = createTestContainer();
    await signIn(container);

    await container.read(sessionProvider.notifier).signOut();

    expect(container.read(sessionProvider), isNull);
  });

  test('restore recupera la sesión guardada', () async {
    final database = createTestDatabase(loggedInAs: adminId);
    final container = createTestContainer(database: database);

    await container.read(sessionProvider.notifier).restore();

    expect(container.read(sessionProvider)?.name, 'Admin Demo');
  });
}
