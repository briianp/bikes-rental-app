import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/domain/repositories/rentals_repository.dart';

class GetRentalHistory {
  const GetRentalHistory(this._repository);

  final RentalsRepository _repository;

  Future<List<Rental>> call() => _repository.getRentalHistory();
}
