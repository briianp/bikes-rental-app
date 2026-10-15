import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/error/api_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fuente de datos de sucursales. Devuelve JSON con la forma de la tabla
/// `branches`.
abstract interface class BranchesRemoteDataSource {
  Future<List<Map<String, dynamic>>> getBranches();

  Future<Map<String, dynamic>> createBranch(Map<String, dynamic> body);

  Future<Map<String, dynamic>> updateBranch(
    String id,
    Map<String, dynamic> body,
  );
}

class SupabaseBranchesRemoteDataSource implements BranchesRemoteDataSource {
  const SupabaseBranchesRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> getBranches() =>
      _client.from('branches').select().order('name');

  @override
  Future<Map<String, dynamic>> createBranch(Map<String, dynamic> body) =>
      _client.from('branches').insert(body).select().single();

  @override
  Future<Map<String, dynamic>> updateBranch(
    String id,
    Map<String, dynamic> body,
  ) => _client.from('branches').update(body).eq('id', id).select().single();
}

class FakeBranchesRemoteDataSource implements BranchesRemoteDataSource {
  const FakeBranchesRemoteDataSource(this._database);

  final InMemoryDatabase _database;

  @override
  Future<List<Map<String, dynamic>>> getBranches() async {
    await _database.simulateNetwork();
    _database.requireUser();
    final branches = _database.branches.map(Map<String, dynamic>.of).toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return branches;
  }

  @override
  Future<Map<String, dynamic>> createBranch(Map<String, dynamic> body) async {
    await _database.simulateNetwork();
    _database.requireAdmin();
    _checkUniqueName(body['name'], exceptId: null);
    final branch = {'id': _database.generateId('branch'), ...body};
    _database.branches.add(branch);
    return Map.of(branch);
  }

  @override
  Future<Map<String, dynamic>> updateBranch(
    String id,
    Map<String, dynamic> body,
  ) async {
    await _database.simulateNetwork();
    _database.requireAdmin();
    final branch = _database.findById(_database.branches, id);
    if (branch == null) {
      throw const ApiException(404, 'La sucursal no existe.');
    }
    _checkUniqueName(body['name'], exceptId: id);
    branch.addAll(body);
    return Map.of(branch);
  }

  void _checkUniqueName(Object? name, {required String? exceptId}) {
    final duplicated = _database.branches.any(
      (b) => b['name'] == name && b['id'] != exceptId,
    );
    if (duplicated) {
      throw const ApiException(409, 'Ya existe una sucursal con ese nombre.');
    }
  }
}
