enum BikeStatus { available, rented, maintenance }

class Bike {
  const Bike({
    required this.id,
    required this.code,
    required this.brand,
    required this.model,
    required this.status,
    required this.hourlyRate,
    required this.branchId,
    required this.isActive,
    this.branchName,
  });

  final String id;

  /// Código impreso en la bicicleta y en su QR, por ejemplo `BK-001`.
  final String code;
  final String brand;
  final String model;
  final BikeStatus status;

  /// Tarifa por hora en quetzales.
  final double hourlyRate;
  final String branchId;
  final String? branchName;

  /// Las bicicletas dadas de baja se desactivan en lugar de borrarse,
  /// para no perder su historial de rentas.
  final bool isActive;

  String get name => '$brand $model';

  bool get isAvailable => isActive && status == BikeStatus.available;
}

/// Datos que un administrador captura para crear o editar una bicicleta.
class BikeDraft {
  const BikeDraft({
    required this.code,
    required this.brand,
    required this.model,
    required this.hourlyRate,
    required this.branchId,
    this.status = BikeStatus.available,
    this.isActive = true,
  });

  final String code;
  final String brand;
  final String model;
  final double hourlyRate;
  final String branchId;
  final BikeStatus status;
  final bool isActive;
}
