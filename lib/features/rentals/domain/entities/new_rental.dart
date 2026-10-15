/// Datos para iniciar una renta: qué bicicleta y para qué cliente.
///
/// El empleado y la sucursal los toma el servidor de la sesión actual.
class NewRental {
  const NewRental({required this.bikeCode, required this.customerId});

  final String bikeCode;
  final String customerId;
}
