import 'package:bikes_app/features/rentals/data/datasources/rentals_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Rentas con Supabase.
///
/// · Lecturas: vista `rental_details` (ya trae bici, cliente y empleado).
/// · Escrituras: funciones SQL `start_rental` / `finish_rental` vía `rpc`,
///   que validan y guardan en una sola transacción.
class SupabaseRentalsRemoteDataSource implements RentalsRemoteDataSource {
  const SupabaseRentalsRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> getRentals({required String status}) {
    final orderColumn = status == 'active' ? 'started_at' : 'ended_at';
    return _client
        .from('rental_details')
        .select()
        .eq('status', status)
        .order(orderColumn, ascending: false)
        .limit(100);
  }

  @override
  Future<Map<String, dynamic>?> getRentalById(String id) =>
      _client.from('rental_details').select().eq('id', id).maybeSingle();

  @override
  Future<Map<String, dynamic>?> getActiveRentalByBikeId(String bikeId) => _client
      .from('rental_details')
      .select()
      .eq('bike_id', bikeId)
      .eq('status', 'active')
      .maybeSingle();

  @override
  Future<Map<String, dynamic>> startRental({
    required String bikeCode,
    required String customerId,
  }) async {
    final row = await _client.rpc<Map<String, dynamic>>(
      'start_rental',
      params: {'p_bike_code': bikeCode, 'p_customer_id': customerId},
    );
    return _details(row['id'] as String);
  }

  @override
  Future<Map<String, dynamic>> finishRental(String rentalId) async {
    await _client.rpc<Map<String, dynamic>>(
      'finish_rental',
      params: {'p_rental_id': rentalId},
    );
    return _details(rentalId);
  }

  Future<Map<String, dynamic>> _details(String rentalId) =>
      _client.from('rental_details').select().eq('id', rentalId).single();
}
