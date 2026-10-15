import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/domain/repositories/rentals_repository.dart';

/// Caso de uso: finalizar una renta. El servidor calcula el total.
class FinishRental {
  const FinishRental(this._repository);

  final RentalsRepository _repository;

  Future<Rental> call(String rentalId) async {
    final rental = await _repository.getRentalById(rentalId);
    if (rental == null) throw const NotFoundFailure('La renta no existe.');
    if (!rental.isActive) {
      throw const ValidationFailure('Esta renta ya fue finalizada.');
    }
    return _repository.finishRental(rentalId);
  }
}
