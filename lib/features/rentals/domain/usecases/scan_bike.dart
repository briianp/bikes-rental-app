import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/domain/repositories/bikes_repository.dart';
import 'package:bikes_app/features/bikes/domain/usecases/get_bike_by_code.dart';
import 'package:bikes_app/features/rentals/domain/entities/bike_scan_result.dart';
import 'package:bikes_app/features/rentals/domain/repositories/rentals_repository.dart';

/// Caso de uso: decidir qué hacer al escanear el QR de una bicicleta.
///
/// · Disponible     → iniciar renta.
/// · En renta       → mostrar su renta activa para finalizarla.
/// · Mantenimiento  → avisar que no se puede rentar.
class ScanBike {
  const ScanBike({
    required BikesRepository bikesRepository,
    required RentalsRepository rentalsRepository,
  }) : _bikesRepository = bikesRepository,
       _rentalsRepository = rentalsRepository;

  final BikesRepository _bikesRepository;
  final RentalsRepository _rentalsRepository;

  Future<BikeScanResult> call(String rawCode) async {
    final code = normalizeBikeCode(rawCode);
    final bike = code.isEmpty ? null : await _bikesRepository.getBikeByCode(code);

    if (bike == null) return BikeNotFound(code);
    if (!bike.isActive) return BikeUnavailable(bike);

    switch (bike.status) {
      case BikeStatus.available:
        return BikeReadyToRent(bike);
      case BikeStatus.maintenance:
        return BikeUnavailable(bike);
      case BikeStatus.rented:
        final rental = await _rentalsRepository.getActiveRentalByBikeId(bike.id);
        return rental == null
            ? BikeUnavailable(bike)
            : BikeCurrentlyRented(bike, rental);
    }
  }
}
