import 'dart:async';

import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:bikes_app/features/bikes/bikes_dependencies.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/rentals/presentation/providers/rentals_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Nota: estos providers solo dependen de casos de uso y de la sesión.
// Evitamos providers "derivados" de otros que se invalidan (por ejemplo,
// un contador calculado a partir de `bikesProvider`), porque en Riverpod
// 3.3 eso provoca un error al volver a una pestaña oculta. Los cálculos
// simples se hacen en la pantalla.

/// Bicicletas activas visibles para el usuario (su sucursal o todas si es
/// admin). Se recarga sola al cambiar de usuario.
final bikesProvider = FutureProvider<List<Bike>>((ref) {
  watchSessionUserId(ref);
  return ref.watch(getBikesUseCaseProvider).call();
});

/// Catálogo completo para el administrador (incluye bicis dadas de baja).
final adminBikesProvider = FutureProvider<List<Bike>>((ref) {
  watchSessionUserId(ref);
  return ref.watch(getBikesUseCaseProvider).call(includeInactive: true);
});

/// Una bicicleta por id (formulario de edición).
final bikeByIdProvider = FutureProvider.autoDispose.family<Bike?, String>(
  (ref, id) => ref.watch(getBikeByIdUseCaseProvider).call(id),
);

/// Filtro seleccionado en la pantalla de bicicletas (`null` = todas).
final bikeFilterProvider = NotifierProvider<BikeFilterNotifier, BikeStatus?>(
  BikeFilterNotifier.new,
);

class BikeFilterNotifier extends Notifier<BikeStatus?> {
  @override
  BikeStatus? build() => null;

  void select(BikeStatus? status) => state = status;
}

/// Guarda (crea o edita) una bicicleta desde el panel de administración.
final saveBikeControllerProvider =
    AsyncNotifierProvider.autoDispose<SaveBikeController, void>(
      SaveBikeController.new,
    );

class SaveBikeController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Devuelve la bicicleta guardada o `null` si hubo un error.
  Future<Bike?> save(BikeDraft draft, {Bike? existing}) async {
    state = const AsyncLoading();
    try {
      final bike = await ref
          .read(saveBikeUseCaseProvider)
          .call(draft, existing: existing);
      if (!ref.mounted) return bike;
      ref
        ..invalidate(bikesProvider)
        ..invalidate(adminBikesProvider)
        ..invalidate(bikeByIdProvider)
        ..invalidate(bikeScanProvider);
      state = const AsyncData(null);
      return bike;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return null;
    }
  }
}
