/// Fuente de datos de rentas. Las lecturas devuelven filas de la vista
/// `rental_details`.
///
/// Implementaciones: `SupabaseRentalsRemoteDataSource` y
/// `FakeRentalsRemoteDataSource` (modo demo y tests).
abstract interface class RentalsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getRentals({required String status});

  Future<Map<String, dynamic>?> getRentalById(String id);

  Future<Map<String, dynamic>?> getActiveRentalByBikeId(String bikeId);

  /// Función SQL `start_rental`.
  Future<Map<String, dynamic>> startRental({
    required String bikeCode,
    required String customerId,
  });

  /// Función SQL `finish_rental`.
  Future<Map<String, dynamic>> finishRental(String rentalId);
}
