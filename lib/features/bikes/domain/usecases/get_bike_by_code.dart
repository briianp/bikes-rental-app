import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/domain/repositories/bikes_repository.dart';

/// Busca una bicicleta por el código leído del QR o escrito a mano.
class GetBikeByCode {
  const GetBikeByCode(this._repository);

  final BikesRepository _repository;

  Future<Bike?> call(String rawCode) async {
    final code = normalizeBikeCode(rawCode);
    if (code.isEmpty) {
      throw const ValidationFailure('Ingresa el código de la bicicleta.');
    }
    return _repository.getBikeByCode(code);
  }
}

/// Limpia el texto de un QR: `" bikes://bk-003 "` → `"BK-003"`.
String normalizeBikeCode(String rawCode) {
  final trimmed = rawCode.trim();
  final lastSegment = trimmed.split('/').last;
  return lastSegment.trim().toUpperCase();
}
