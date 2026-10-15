import 'package:bikes_app/features/bikes/data/datasources/bikes_remote_data_source.dart';
import 'package:bikes_app/features/bikes/data/models/bike_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Las políticas RLS ya filtran por sucursal: un empleado solo recibe las
/// bicicletas de la suya, y un administrador recibe todas.
class SupabaseBikesRemoteDataSource implements BikesRemoteDataSource {
  const SupabaseBikesRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> getBikes({
    required bool includeInactive,
  }) {
    final query = _client.from('bikes').select(BikeModel.columns);
    final filtered = includeInactive ? query : query.eq('is_active', true);
    return filtered.order('code');
  }

  @override
  Future<Map<String, dynamic>?> getBikeByCode(String code) => _client
      .from('bikes')
      .select(BikeModel.columns)
      .eq('code', code)
      .maybeSingle();

  @override
  Future<Map<String, dynamic>?> getBikeById(String id) => _client
      .from('bikes')
      .select(BikeModel.columns)
      .eq('id', id)
      .maybeSingle();

  @override
  Future<Map<String, dynamic>> createBike(Map<String, dynamic> body) =>
      _client.from('bikes').insert(body).select(BikeModel.columns).single();

  @override
  Future<Map<String, dynamic>> updateBike(
    String id,
    Map<String, dynamic> body,
  ) => _client
      .from('bikes')
      .update(body)
      .eq('id', id)
      .select(BikeModel.columns)
      .single();
}
