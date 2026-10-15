/// Rutas de la app en un solo lugar, para no escribir strings sueltos.
///
/// Uso: `context.go(AppRoutes.bikes)` o
/// `context.push(AppRoutes.rentalDetail(rental.id))`.
abstract final class AppRoutes {
  static const String login = '/login';

  // Pestaña "Rentas"
  static const String rentals = '/rentals';
  static const String rentalHistory = '/rentals/history';
  static String rentalDetail(String rentalId) => '/rentals/$rentalId';

  // Pestaña "Bicicletas"
  static const String bikes = '/bikes';

  // Pestaña "Escanear"
  static const String scanner = '/scan';
  static const String scannerCamera = '/scan/camera';

  // Pestaña "Perfil"
  static const String profile = '/profile';

  // Resultado de escanear una bici: iniciar o finalizar su renta.
  // Pantalla completa (sin barra de navegación inferior).
  static const String bikeActionPattern = '/bike/:bikeCode';
  static String bikeAction(String bikeCode) =>
      '/bike/${Uri.encodeComponent(bikeCode)}';

  // Administración (solo rol admin)
  static const String admin = '/admin';
  static const String adminBikes = '/admin/bikes';
  static const String adminNewBike = '/admin/bikes/new';
  static String adminBike(String bikeId) => '/admin/bikes/$bikeId';
  static const String adminBranches = '/admin/branches';
  static const String adminEmployees = '/admin/employees';
  static const String adminNewEmployee = '/admin/employees/new';
  static String adminEmployee(String employeeId) =>
      '/admin/employees/$employeeId';
}
