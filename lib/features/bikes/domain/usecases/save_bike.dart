import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/domain/repositories/bikes_repository.dart';
import 'package:bikes_app/features/bikes/domain/usecases/get_bike_by_code.dart';

/// Crea una bicicleta (si [existing] es `null`) o la actualiza.
///
/// Reglas: el estado "en renta" solo lo asignan las rentas, y una bici con
/// renta activa no puede cambiar de estado, sucursal ni desactivarse.
/// (La base de datos aplica las mismas reglas con un trigger.)
class SaveBike {
  const SaveBike(this._repository);

  final BikesRepository _repository;

  Future<Bike> call(BikeDraft draft, {Bike? existing}) async {
    final code = normalizeBikeCode(draft.code);
    if (code.isEmpty) throw const ValidationFailure('El código es obligatorio.');
    if (draft.brand.trim().isEmpty || draft.model.trim().isEmpty) {
      throw const ValidationFailure('La marca y el modelo son obligatorios.');
    }
    if (draft.hourlyRate <= 0) {
      throw const ValidationFailure('La tarifa debe ser mayor que cero.');
    }

    final isRented = existing?.status == BikeStatus.rented;
    if (isRented) {
      final changesLockedFields =
          draft.status != BikeStatus.rented ||
          draft.branchId != existing!.branchId ||
          !draft.isActive;
      if (changesLockedFields) {
        throw const ValidationFailure(
          'Esta bicicleta tiene una renta activa. Finalízala antes de cambiar '
          'su estado, sucursal o desactivarla.',
        );
      }
    } else if (draft.status == BikeStatus.rented) {
      throw const ValidationFailure(
        'El estado "en renta" solo se asigna al iniciar una renta.',
      );
    }

    final clean = BikeDraft(
      code: code,
      brand: draft.brand.trim(),
      model: draft.model.trim(),
      hourlyRate: draft.hourlyRate,
      branchId: draft.branchId,
      status: draft.status,
      isActive: draft.isActive,
    );
    return existing == null
        ? _repository.createBike(clean)
        : _repository.updateBike(existing.id, clean);
  }
}
