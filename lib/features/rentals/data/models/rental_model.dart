import 'package:bikes_app/features/rentals/domain/entities/rental.dart';

/// Conversión de una fila de la vista `rental_details` a [Rental].
abstract final class RentalModel {
  static Rental fromJson(Map<String, dynamic> json) {
    final endedAt = json['ended_at'] as String?;
    return Rental(
      id: json['id'] as String,
      status: RentalStatus.values.byName(json['status'] as String),
      // Supabase envía las fechas en UTC; las mostramos en hora local.
      startedAt: DateTime.parse(json['started_at'] as String).toLocal(),
      endedAt: endedAt == null ? null : DateTime.parse(endedAt).toLocal(),
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      branchId: json['branch_id'] as String,
      branchName: json['branch_name'] as String,
      bikeId: json['bike_id'] as String,
      bikeCode: json['bike_code'] as String,
      bikeName: json['bike_name'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      customerEmail: json['customer_email'] as String?,
      customerDocumentId: json['customer_document_id'] as String?,
      employeeName: json['employee_name'] as String,
    );
  }
}
