import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:bikes_app/features/rentals/domain/entities/bike_scan_result.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/rentals_dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rentas en curso de la sucursal (o de todas si es admin).
final activeRentalsProvider = FutureProvider<List<Rental>>((ref) {
  watchSessionUserId(ref);
  return ref.watch(getActiveRentalsUseCaseProvider).call();
});

/// Rentas finalizadas.
final rentalHistoryProvider = FutureProvider<List<Rental>>((ref) {
  watchSessionUserId(ref);
  return ref.watch(getRentalHistoryUseCaseProvider).call();
});

/// Detalle de una renta por id (`null` si no existe).
final rentalByIdProvider = FutureProvider.autoDispose.family<Rental?, String>(
  (ref, id) => ref.watch(getRentalByIdUseCaseProvider).call(id),
);

/// Qué hacer con la bicicleta escaneada: rentarla, finalizar su renta o
/// avisar que no está disponible.
final bikeScanProvider = FutureProvider.autoDispose
    .family<BikeScanResult, String>(
      (ref, code) => ref.watch(scanBikeUseCaseProvider).call(code),
    );
