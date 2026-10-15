import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/domain/repositories/rentals_repository.dart';

class GetRentalById {
  const GetRentalById(this._repository);

  final RentalsRepository _repository;

  Future<Rental?> call(String id) => _repository.getRentalById(id);
}
