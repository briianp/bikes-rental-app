import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/bikes/data/datasources/bikes_remote_data_source.dart';

/// Bicicletas del modo demo. Aplica las mismas reglas que Supabase:
/// cada empleado ve solo su sucursal y solo el admin puede editar.
class FakeBikesRemoteDataSource implements BikesRemoteDataSource {
  const FakeBikesRemoteDataSource(this._database);

  final InMemoryDatabase _database;

  @override
  Future<List<Map<String, dynamic>>> getBikes({
    required bool includeInactive,
  }) async {
    await _database.simulateNetwork();
    _database.requireUser();
    final bikes =
        _database.bikes
            .where((bike) => _database.canAccessBranch(bike['branch_id']))
            .where((bike) => includeInactive || bike['is_active'] == true)
            .map(_database.bikeJson)
            .toList()
          ..sort((a, b) => (a['code'] as String).compareTo(b['code'] as String));
    return bikes;
  }

  @override
  Future<Map<String, dynamic>?> getBikeByCode(String code) async {
    await _database.simulateNetwork();
    _database.requireUser();
    final bike = _database.bikes
        .where((b) => b['code'] == code)
        .where((b) => _database.canAccessBranch(b['branch_id']))
        .firstOrNull;
    return bike == null ? null : _database.bikeJson(bike);
  }

  @override
  Future<Map<String, dynamic>?> getBikeById(String id) async {
    await _database.simulateNetwork();
    _database.requireUser();
    final bike = _database.findById(_database.bikes, id);
    if (bike == null || !_database.canAccessBranch(bike['branch_id'])) {
      return null;
    }
    return _database.bikeJson(bike);
  }

  @override
  Future<Map<String, dynamic>> createBike(Map<String, dynamic> body) async {
    await _database.simulateNetwork();
    _database.requireAdmin();
    _checkUniqueCode(body['code'], exceptId: null);
    final bike = {'id': _database.generateId('bike'), ...body};
    _database.bikes.add(bike);
    return _database.bikeJson(bike);
  }

  @override
  Future<Map<String, dynamic>> updateBike(
    String id,
    Map<String, dynamic> body,
  ) async {
    await _database.simulateNetwork();
    _database.requireAdmin();
    final bike = _database.findById(_database.bikes, id);
    if (bike == null) throw const ApiException(404, 'La bicicleta no existe.');
    _checkUniqueCode(body['code'], exceptId: id);
    bike.addAll(body);
    return _database.bikeJson(bike);
  }

  void _checkUniqueCode(Object? code, {required String? exceptId}) {
    if (_database.bikes.any((b) => b['code'] == code && b['id'] != exceptId)) {
      throw const ApiException(409, 'Ya existe una bicicleta con ese código.');
    }
  }
}
