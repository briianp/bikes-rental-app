import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';

/// Resultado de escanear el QR de una bicicleta.
///
/// Es una clase `sealed`: el compilador obliga a la UI a manejar
/// todos los casos en un `switch`.
sealed class BikeScanResult {
  const BikeScanResult();
}

/// No hay bicicleta con ese código (o es de otra sucursal).
final class BikeNotFound extends BikeScanResult {
  const BikeNotFound(this.code);

  final String code;
}

/// Disponible → iniciar una renta.
final class BikeReadyToRent extends BikeScanResult {
  const BikeReadyToRent(this.bike);

  final Bike bike;
}

/// Rentada → finalizar su renta activa.
final class BikeCurrentlyRented extends BikeScanResult {
  const BikeCurrentlyRented(this.bike, this.rental);

  final Bike bike;
  final Rental rental;
}

/// En mantenimiento o dada de baja.
final class BikeUnavailable extends BikeScanResult {
  const BikeUnavailable(this.bike);

  final Bike bike;
}
