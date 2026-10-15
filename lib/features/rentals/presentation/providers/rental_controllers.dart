import 'dart:async';

import 'package:bikes_app/features/bikes/presentation/providers/bikes_providers.dart';
import 'package:bikes_app/features/customers/domain/entities/customer.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/presentation/providers/rentals_providers.dart';
import 'package:bikes_app/features/rentals/rentals_dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controla la acción "Iniciar renta".
///
/// Su estado indica si se está enviando (`isLoading`) o si falló (`AsyncError`).
final startRentalControllerProvider =
    AsyncNotifierProvider.autoDispose<StartRentalController, void>(
      StartRentalController.new,
    );

class StartRentalController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Devuelve la renta creada o `null` si hubo un error.
  Future<Rental?> start({
    required String bikeCode,
    required Customer? customer,
  }) async {
    state = const AsyncLoading();
    try {
      final rental = await ref
          .read(startRentalUseCaseProvider)
          .call(bikeCode: bikeCode, customer: customer);

      // Si la pantalla se cerró mientras esperábamos, ya no usamos `ref`.
      if (!ref.mounted) return rental;

      // Los datos cambiaron: invalidamos para que las pantallas recarguen.
      ref
        ..invalidate(activeRentalsProvider)
        ..invalidate(bikesProvider)
        ..invalidate(adminBikesProvider)
        ..invalidate(bikeScanProvider);
      state = const AsyncData(null);
      return rental;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return null;
    }
  }
}

/// Controla la acción "Finalizar renta".
final finishRentalControllerProvider =
    AsyncNotifierProvider.autoDispose<FinishRentalController, void>(
      FinishRentalController.new,
    );

class FinishRentalController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Devuelve la renta finalizada (con el total que calculó el servidor)
  /// o `null` si hubo un error.
  Future<Rental?> finish(String rentalId) async {
    state = const AsyncLoading();
    try {
      final rental = await ref.read(finishRentalUseCaseProvider).call(rentalId);

      if (!ref.mounted) return rental;

      ref
        ..invalidate(activeRentalsProvider)
        ..invalidate(rentalHistoryProvider)
        ..invalidate(rentalByIdProvider(rentalId))
        ..invalidate(bikesProvider)
        ..invalidate(adminBikesProvider)
        ..invalidate(bikeScanProvider);
      state = const AsyncData(null);
      return rental;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return null;
    }
  }
}
