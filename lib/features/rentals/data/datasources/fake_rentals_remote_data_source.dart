import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/rentals/data/datasources/rentals_remote_data_source.dart';

/// Rentas del modo demo. Reproduce la lógica de las funciones SQL
/// `start_rental` y `finish_rental` y los permisos por sucursal.
class FakeRentalsRemoteDataSource implements RentalsRemoteDataSource {
  const FakeRentalsRemoteDataSource(this._database);

  final InMemoryDatabase _database;

  @override
  Future<List<Map<String, dynamic>>> getRentals({required String status}) async {
    await _database.simulateNetwork();
    _database.requireUser();
    final orderKey = status == 'active' ? 'started_at' : 'ended_at';
    final rentals = _visibleRentals()
        .where((rental) => rental['status'] == status)
        .toList()
      ..sort((a, b) => (b[orderKey] as String).compareTo(a[orderKey] as String));
    return rentals.map(_database.rentalDetailsJson).toList();
  }

  @override
  Future<Map<String, dynamic>?> getRentalById(String id) async {
    await _database.simulateNetwork();
    _database.requireUser();
    final rental = _visibleRentals().where((r) => r['id'] == id).firstOrNull;
    return rental == null ? null : _database.rentalDetailsJson(rental);
  }

  @override
  Future<Map<String, dynamic>?> getActiveRentalByBikeId(String bikeId) async {
    await _database.simulateNetwork();
    _database.requireUser();
    final rental = _visibleRentals()
        .where((r) => r['bike_id'] == bikeId && r['status'] == 'active')
        .firstOrNull;
    return rental == null ? null : _database.rentalDetailsJson(rental);
  }

  @override
  Future<Map<String, dynamic>> startRental({
    required String bikeCode,
    required String customerId,
  }) async {
    await _database.simulateNetwork();
    final user = _database.requireUser();

    final bike = _database.bikes
        .where((b) => b['code'] == bikeCode && b['is_active'] == true)
        .firstOrNull;
    if (bike == null) {
      throw ApiException(404, 'No existe una bicicleta con el código $bikeCode.');
    }
    if (!_database.canAccessBranch(bike['branch_id'])) {
      throw ApiException(403, 'La bicicleta $bikeCode pertenece a otra sucursal.');
    }
    if (bike['status'] != 'available') {
      throw ApiException(409, 'La bicicleta $bikeCode no está disponible.');
    }
    if (_database.findById(_database.customers, customerId) == null) {
      throw const ApiException(404, 'El cliente no existe.');
    }

    final rental = <String, dynamic>{
      'id': _database.generateId('rent'),
      'bike_id': bike['id'],
      'customer_id': customerId,
      'branch_id': bike['branch_id'],
      'started_by': user['id'],
      'finished_by': null,
      'hourly_rate': bike['hourly_rate'],
      'started_at': _database.clock().toIso8601String(),
      'ended_at': null,
      'total_price': null,
      'status': 'active',
    };
    _database.rentals.add(rental);
    bike['status'] = 'rented';
    return _database.rentalDetailsJson(rental);
  }

  @override
  Future<Map<String, dynamic>> finishRental(String rentalId) async {
    await _database.simulateNetwork();
    final user = _database.requireUser();

    final rental = _database.findById(_database.rentals, rentalId);
    if (rental == null) throw const ApiException(404, 'La renta no existe.');
    if (!_database.canAccessBranch(rental['branch_id'])) {
      throw const ApiException(403, 'La renta pertenece a otra sucursal.');
    }
    if (rental['status'] != 'active') {
      throw const ApiException(409, 'Esta renta ya fue finalizada.');
    }

    // Misma regla que la función SQL: por hora iniciada, mínimo 1 hora.
    final now = _database.clock();
    final startedAt = DateTime.parse(rental['started_at'] as String);
    final seconds = now.difference(startedAt).inSeconds;
    final hours = seconds <= 0 ? 1 : (seconds / Duration.secondsPerHour).ceil();

    rental
      ..['status'] = 'finished'
      ..['ended_at'] = now.toIso8601String()
      ..['total_price'] = hours * (rental['hourly_rate'] as num)
      ..['finished_by'] = user['id'];
    _database.findById(_database.bikes, rental['bike_id'])?['status'] =
        'available';
    return _database.rentalDetailsJson(rental);
  }

  /// Rentas que el usuario actual puede ver (su sucursal o todas si es admin).
  Iterable<Map<String, dynamic>> _visibleRentals() => _database.rentals.where(
    (rental) => _database.canAccessBranch(rental['branch_id']),
  );
}
