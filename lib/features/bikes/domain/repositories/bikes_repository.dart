import 'package:bikes_app/features/bikes/domain/entities/bike.dart';

abstract interface class BikesRepository {
  /// Bicicletas visibles para el usuario (su sucursal, o todas si es admin).
  Future<List<Bike>> getBikes({bool includeInactive = false});

  /// Devuelve `null` si no existe una bicicleta con ese código.
  Future<Bike?> getBikeByCode(String code);

  Future<Bike?> getBikeById(String id);

  Future<Bike> createBike(BikeDraft draft);

  Future<Bike> updateBike(String id, BikeDraft draft);
}
