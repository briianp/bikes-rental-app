import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/error/api_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fuente de datos de clientes (tabla `customers`).
abstract interface class CustomersRemoteDataSource {
  Future<List<Map<String, dynamic>>> searchCustomers(String query);

  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> body);
}

class SupabaseCustomersRemoteDataSource implements CustomersRemoteDataSource {
  const SupabaseCustomersRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> searchCustomers(String query) {
    // Quitamos caracteres que tienen significado en los filtros de PostgREST.
    final safe = query.replaceAll(RegExp(r'[,()*%]'), ' ').trim();
    return _client
        .from('customers')
        .select()
        .or(
          'phone.ilike.%$safe%,document_id.ilike.%$safe%,full_name.ilike.%$safe%',
        )
        .order('full_name')
        .limit(20);
  }

  @override
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> body) =>
      _client.from('customers').insert(body).select().single();
}

class FakeCustomersRemoteDataSource implements CustomersRemoteDataSource {
  const FakeCustomersRemoteDataSource(this._database);

  final InMemoryDatabase _database;

  @override
  Future<List<Map<String, dynamic>>> searchCustomers(String query) async {
    await _database.simulateNetwork();
    _database.requireUser();
    final text = query.toLowerCase();
    final results =
        _database.customers
            .where(
              (c) =>
                  (c['full_name'] as String).toLowerCase().contains(text) ||
                  (c['phone'] as String).contains(text) ||
                  ((c['document_id'] as String?) ?? '').contains(text),
            )
            .map(Map<String, dynamic>.of)
            .toList()
          ..sort(
            (a, b) =>
                (a['full_name'] as String).compareTo(b['full_name'] as String),
          );
    return results.take(20).toList();
  }

  @override
  Future<Map<String, dynamic>> createCustomer(Map<String, dynamic> body) async {
    await _database.simulateNetwork();
    _database.requireUser();
    if (_database.customers.any((c) => c['phone'] == body['phone'])) {
      throw const ApiException(409, 'Ya existe un cliente con ese teléfono.');
    }
    final documentId = body['document_id'];
    if (documentId != null &&
        _database.customers.any((c) => c['document_id'] == documentId)) {
      throw const ApiException(409, 'Ya existe un cliente con ese DPI.');
    }
    final customer = {'id': _database.generateId('cust'), ...body};
    _database.customers.add(customer);
    return Map.of(customer);
  }
}
