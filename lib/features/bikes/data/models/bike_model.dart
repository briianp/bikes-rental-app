import 'package:bikes_app/features/bikes/domain/entities/bike.dart';

/// Conversión entre el JSON de la tabla `bikes` y la entidad [Bike].
abstract final class BikeModel {
  /// Columnas que se piden a Supabase, incluyendo el nombre de la sucursal.
  static const String columns =
      'id, code, brand, model, status, hourly_rate, branch_id, is_active, '
      'branches(name)';

  static Bike fromJson(Map<String, dynamic> json) {
    final branch = json['branches'] as Map<String, dynamic>?;
    return Bike(
      id: json['id'] as String,
      code: json['code'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      // 'available' → BikeStatus.available
      status: BikeStatus.values.byName(json['status'] as String),
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      branchId: json['branch_id'] as String,
      branchName: branch?['name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toJson(BikeDraft draft) => {
    'code': draft.code,
    'brand': draft.brand,
    'model': draft.model,
    'hourly_rate': draft.hourlyRate,
    'branch_id': draft.branchId,
    'status': draft.status.name,
    'is_active': draft.isActive,
  };
}
