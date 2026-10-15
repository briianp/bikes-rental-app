import 'dart:async';

import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:bikes_app/features/bikes/presentation/providers/bikes_providers.dart';
import 'package:bikes_app/features/branches/branches_dependencies.dart';
import 'package:bikes_app/features/branches/domain/entities/branch.dart';
import 'package:bikes_app/features/employees/presentation/providers/employees_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Todas las sucursales (activas e inactivas).
final branchesProvider = FutureProvider<List<Branch>>((ref) {
  watchSessionUserId(ref);
  return ref.watch(getBranchesUseCaseProvider).call();
});

/// Guarda (crea o edita) una sucursal.
final saveBranchControllerProvider =
    AsyncNotifierProvider.autoDispose<SaveBranchController, void>(
      SaveBranchController.new,
    );

class SaveBranchController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Devuelve `true` si se guardó.
  Future<bool> save(BranchDraft draft, {String? id}) async {
    state = const AsyncLoading();
    try {
      await ref.read(saveBranchUseCaseProvider).call(draft, id: id);
      if (!ref.mounted) return true;
      // El nombre de la sucursal también aparece en bicis y empleados.
      ref
        ..invalidate(branchesProvider)
        ..invalidate(bikesProvider)
        ..invalidate(adminBikesProvider)
        ..invalidate(employeesProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return false;
    }
  }
}
