import 'dart:async';

import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:bikes_app/features/employees/domain/entities/employee_drafts.dart';
import 'package:bikes_app/features/employees/employees_dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Empleados y administradores (solo para el admin).
final employeesProvider = FutureProvider<List<AppUser>>((ref) {
  watchSessionUserId(ref);
  return ref.watch(getEmployeesUseCaseProvider).call();
});

/// Crea o edita empleados.
final saveEmployeeControllerProvider =
    AsyncNotifierProvider.autoDispose<SaveEmployeeController, void>(
      SaveEmployeeController.new,
    );

class SaveEmployeeController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Devuelve `true` si se creó la cuenta.
  Future<bool> create(NewEmployee employee) => _run(
    () => ref.read(createEmployeeUseCaseProvider).call(employee),
  );

  /// Devuelve `true` si se guardaron los cambios.
  Future<bool> updateEmployee(String employeeId, EmployeeUpdate update) =>
      _run(() async {
        final currentUser = ref.read(sessionProvider);
        final updated = await ref
            .read(updateEmployeeUseCaseProvider)
            .call(
              employeeId: employeeId,
              update: update,
              currentUserId: currentUser?.id ?? '',
            );
        // Si el admin se editó a sí mismo, actualizamos su sesión.
        if (updated.id == currentUser?.id) {
          ref.read(sessionProvider.notifier).signedIn(updated);
        }
      });

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    try {
      await action();
      if (!ref.mounted) return true;
      ref.invalidate(employeesProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
