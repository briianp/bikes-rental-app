import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/rentals/data/datasources/rentals_remote_data_source.dart';
import 'package:bikes_app/features/rentals/data/models/rental_model.dart';
import 'package:bikes_app/features/rentals/domain/entities/new_rental.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/domain/repositories/rentals_repository.dart';

class RentalsRepositoryImpl implements RentalsRepository {
  const RentalsRepositoryImpl(this._remoteDataSource);

  final RentalsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Rental>> getActiveRentals() => _getRentals('active');

  @override
  Future<List<Rental>> getRentalHistory() => _getRentals('finished');

  Future<List<Rental>> _getRentals(String status) => guardApiCall(() async {
    final rows = await _remoteDataSource.getRentals(status: status);
    return rows.map(RentalModel.fromJson).toList();
  });

  @override
  Future<Rental?> getRentalById(String id) => guardApiCall(() async {
    final row = await _remoteDataSource.getRentalById(id);
    return row == null ? null : RentalModel.fromJson(row);
  });

  @override
  Future<Rental?> getActiveRentalByBikeId(String bikeId) =>
      guardApiCall(() async {
        final row = await _remoteDataSource.getActiveRentalByBikeId(bikeId);
        return row == null ? null : RentalModel.fromJson(row);
      });

  @override
  Future<Rental> startRental(NewRental rental) => guardApiCall(() async {
    final row = await _remoteDataSource.startRental(
      bikeCode: rental.bikeCode,
      customerId: rental.customerId,
    );
    return RentalModel.fromJson(row);
  });

  @override
  Future<Rental> finishRental(String rentalId) => guardApiCall(() async {
    final row = await _remoteDataSource.finishRental(rentalId);
    return RentalModel.fromJson(row);
  });
}
