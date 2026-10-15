import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/domain/repositories/bikes_repository.dart';

class GetBikes {
  const GetBikes(this._repository);

  final BikesRepository _repository;

  Future<List<Bike>> call({bool includeInactive = false}) =>
      _repository.getBikes(includeInactive: includeInactive);
}

class GetBikeById {
  const GetBikeById(this._repository);

  final BikesRepository _repository;

  Future<Bike?> call(String id) => _repository.getBikeById(id);
}
