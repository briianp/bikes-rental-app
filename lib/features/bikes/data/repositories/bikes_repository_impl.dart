import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/bikes/data/datasources/bikes_remote_data_source.dart';
import 'package:bikes_app/features/bikes/data/models/bike_model.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/domain/repositories/bikes_repository.dart';

class BikesRepositoryImpl implements BikesRepository {
  const BikesRepositoryImpl(this._remoteDataSource);

  final BikesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Bike>> getBikes({bool includeInactive = false}) =>
      guardApiCall(() async {
        final rows = await _remoteDataSource.getBikes(
          includeInactive: includeInactive,
        );
        return rows.map(BikeModel.fromJson).toList();
      });

  @override
  Future<Bike?> getBikeByCode(String code) => guardApiCall(() async {
    final row = await _remoteDataSource.getBikeByCode(code);
    return row == null ? null : BikeModel.fromJson(row);
  });

  @override
  Future<Bike?> getBikeById(String id) => guardApiCall(() async {
    final row = await _remoteDataSource.getBikeById(id);
    return row == null ? null : BikeModel.fromJson(row);
  });

  @override
  Future<Bike> createBike(BikeDraft draft) => guardApiCall(() async {
    final row = await _remoteDataSource.createBike(BikeModel.toJson(draft));
    return BikeModel.fromJson(row);
  });

  @override
  Future<Bike> updateBike(String id, BikeDraft draft) => guardApiCall(() async {
    final row = await _remoteDataSource.updateBike(id, BikeModel.toJson(draft));
    return BikeModel.fromJson(row);
  });
}
