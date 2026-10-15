import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/features/bikes/domain/repositories/bikes_repository.dart';
import 'package:bikes_app/features/bikes/domain/usecases/get_bike_by_code.dart';
import 'package:bikes_app/features/customers/domain/entities/customer.dart';
import 'package:bikes_app/features/rentals/domain/entities/new_rental.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/domain/repositories/rentals_repository.dart';

/// Caso de uso: iniciar una renta para un cliente.
///
/// Valida antes de llamar al servidor para dar mensajes claros. El servidor
/// vuelve a validar dentro de una transacción (función SQL `start_rental`),
/// así dos empleados no pueden rentar la misma bicicleta a la vez.
class StartRental {
  const StartRental({
    required RentalsRepository rentalsRepository,
    required BikesRepository bikesRepository,
  }) : _rentalsRepository = rentalsRepository,
       _bikesRepository = bikesRepository;

  final RentalsRepository _rentalsRepository;
  final BikesRepository _bikesRepository;

  Future<Rental> call({
    required String bikeCode,
    required Customer? customer,
  }) async {
    if (customer == null) {
      throw const ValidationFailure('Selecciona o registra un cliente.');
    }

    final code = normalizeBikeCode(bikeCode);
    final bike = await _bikesRepository.getBikeByCode(code);
    if (bike == null) {
      throw NotFoundFailure('No existe una bicicleta con el código $code.');
    }
    if (!bike.isAvailable) {
      throw ValidationFailure('La bicicleta $code no está disponible.');
    }

    return _rentalsRepository.startRental(
      NewRental(bikeCode: code, customerId: customer.id),
    );
  }
}
