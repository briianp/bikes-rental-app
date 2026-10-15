/// Fuente de datos de bicicletas. Devuelve JSON con la forma de la tabla
/// `bikes` + `branches(name)`.
///
/// Implementaciones: `SupabaseBikesRemoteDataSource` y
/// `FakeBikesRemoteDataSource` (modo demo y tests).
abstract interface class BikesRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBikes({required bool includeInactive});

  Future<Map<String, dynamic>?> getBikeByCode(String code);

  Future<Map<String, dynamic>?> getBikeById(String id);

  Future<Map<String, dynamic>> createBike(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateBike(String id, Map<String, dynamic> body);
}
