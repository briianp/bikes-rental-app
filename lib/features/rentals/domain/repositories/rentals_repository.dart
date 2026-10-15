import 'package:bikes_app/features/rentals/domain/entities/new_rental.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';

abstract interface class RentalsRepository {
  Future<List<Rental>> getActiveRentals();

  Future<List<Rental>> getRentalHistory();

  /// Devuelve `null` si la renta no existe.
  Future<Rental?> getRentalById(String id);

  /// Renta activa de una bicicleta, o `null` si no tiene.
  Future<Rental?> getActiveRentalByBikeId(String bikeId);

  /// El servidor valida disponibilidad y crea la renta en una transacción.
  Future<Rental> startRental(NewRental rental);

  /// El servidor calcula el total y libera la bicicleta.
  Future<Rental> finishRental(String rentalId);
}
