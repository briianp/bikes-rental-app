import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/error/api_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fuente de datos de empleados (tabla `profiles`).
abstract interface class EmployeesRemoteDataSource {
  Future<List<Map<String, dynamic>>> getEmployees();

  Future<void> createEmployee(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateEmployee(
    String id,
    Map<String, dynamic> body,
  );
}

class SupabaseEmployeesRemoteDataSource implements EmployeesRemoteDataSource {
  const SupabaseEmployeesRemoteDataSource(this._client);

  final SupabaseClient _client;

  static const _columns =
      'id, full_name, email, role, branch_id, is_active, branches(name)';

  @override
  Future<List<Map<String, dynamic>>> getEmployees() =>
      _client.from('profiles').select(_columns).order('full_name');

  /// Crear cuentas requiere la clave secreta, por eso lo hace la Edge
  /// Function `create-employee` (ver `supabase/functions`).
  @override
  Future<void> createEmployee(Map<String, dynamic> body) async {
    await _client.functions.invoke('create-employee', body: body);
  }

  @override
  Future<Map<String, dynamic>> updateEmployee(
    String id,
    Map<String, dynamic> body,
  ) => _client
      .from('profiles')
      .update(body)
      .eq('id', id)
      .select(_columns)
      .single();
}

class FakeEmployeesRemoteDataSource implements EmployeesRemoteDataSource {
  const FakeEmployeesRemoteDataSource(this._database);

  final InMemoryDatabase _database;

  @override
  Future<List<Map<String, dynamic>>> getEmployees() async {
    await _database.simulateNetwork();
    _database.requireAdmin();
    final employees = _database.users.map(_database.userJson).toList()
      ..sort(
        (a, b) =>
            (a['full_name'] as String).compareTo(b['full_name'] as String),
      );
    return employees;
  }

  @override
  Future<void> createEmployee(Map<String, dynamic> body) async {
    await _database.simulateNetwork();
    _database.requireAdmin();
    if (_database.users.any((u) => u['email'] == body['email'])) {
      throw const ApiException(409, 'Ya existe un usuario con ese correo.');
    }
    _database.users.add({
      'id': _database.generateId('user'),
      'full_name': body['full_name'],
      'email': body['email'],
      'password': body['password'],
      'role': body['role'],
      'branch_id': body['branch_id'],
      'is_active': true,
    });
  }

  @override
  Future<Map<String, dynamic>> updateEmployee(
    String id,
    Map<String, dynamic> body,
  ) async {
    await _database.simulateNetwork();
    _database.requireAdmin();
    final user = _database.findById(_database.users, id);
    if (user == null) throw const ApiException(404, 'El empleado no existe.');
    user.addAll(body);
    return _database.userJson(user);
  }
}
