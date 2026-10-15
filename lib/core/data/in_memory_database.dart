import 'package:bikes_app/core/constants/demo_credentials.dart';
import 'package:bikes_app/core/error/api_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Backend" falso para el **modo demo** y los tests.
///
/// Imita lo que hace Supabase en `supabase/migrations`:
///   · guarda las tablas como JSON (`Map<String, dynamic>`),
///   · aplica las mismas reglas de permisos (RLS) según el usuario actual,
///   · y devuelve los datos con la misma forma que la API real.
///
/// Así los data sources falsos y los de Supabase usan los mismos modelos.
class InMemoryDatabase {
  InMemoryDatabase({
    this.latency = const Duration(milliseconds: 400),
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now {
    _seed(this.clock());
  }

  /// Tiempo de espera simulado en cada petición. En los tests se usa cero.
  final Duration latency;

  /// Reloj del "servidor". Los tests lo fijan para calcular cobros exactos.
  final DateTime Function() clock;

  final List<Map<String, dynamic>> branches = [];
  final List<Map<String, dynamic>> users = [];
  final List<Map<String, dynamic>> bikes = [];
  final List<Map<String, dynamic>> customers = [];
  final List<Map<String, dynamic>> rentals = [];

  /// Usuario con sesión iniciada (equivale a `auth.uid()` en Supabase).
  String? currentUserId;

  int _idCounter = 0;

  // ---------------------------------------------------------------------
  // Utilidades
  // ---------------------------------------------------------------------

  Future<void> simulateNetwork() async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
  }

  String generateId(String prefix) {
    _idCounter++;
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}-$_idCounter';
  }

  Map<String, dynamic>? findById(List<Map<String, dynamic>> table, Object? id) =>
      table.where((row) => row['id'] == id).firstOrNull;

  // ---------------------------------------------------------------------
  // Permisos (equivalente a las políticas RLS)
  // ---------------------------------------------------------------------

  Map<String, dynamic>? get currentUser => findById(users, currentUserId);

  bool get isAdmin => currentUser?['role'] == 'admin';

  String? get currentBranchId => currentUser?['branch_id'] as String?;

  /// ¿El usuario actual puede ver datos de esta sucursal?
  bool canAccessBranch(Object? branchId) =>
      isAdmin || (branchId != null && branchId == currentBranchId);

  /// Lanza 401 si no hay un usuario activo.
  Map<String, dynamic> requireUser() {
    final user = currentUser;
    if (user == null || user['is_active'] != true) {
      throw const ApiException(401, 'Tu sesión expiró. Inicia sesión de nuevo.');
    }
    return user;
  }

  /// Lanza 403 si el usuario actual no es administrador.
  void requireAdmin() {
    requireUser();
    if (!isAdmin) {
      throw const ApiException(
        403,
        'Solo un administrador puede realizar esta acción.',
      );
    }
  }

  // ---------------------------------------------------------------------
  // Respuestas con la misma forma que la API de Supabase
  // ---------------------------------------------------------------------

  /// `profiles` con `branches(name)` embebido.
  Map<String, dynamic> userJson(Map<String, dynamic> user) {
    final branch = findById(branches, user['branch_id']);
    return {
      'id': user['id'],
      'full_name': user['full_name'],
      'email': user['email'],
      'role': user['role'],
      'branch_id': user['branch_id'],
      'is_active': user['is_active'],
      'branches': branch == null ? null : {'name': branch['name']},
    };
  }

  /// `bikes` con `branches(name)` embebido.
  Map<String, dynamic> bikeJson(Map<String, dynamic> bike) {
    final branch = findById(branches, bike['branch_id']);
    return {
      ...bike,
      'branches': branch == null ? null : {'name': branch['name']},
    };
  }

  /// Fila de la vista `rental_details`.
  Map<String, dynamic> rentalDetailsJson(Map<String, dynamic> rental) {
    final bike = findById(bikes, rental['bike_id']);
    final customer = findById(customers, rental['customer_id']);
    final branch = findById(branches, rental['branch_id']);
    final employee = findById(users, rental['started_by']);
    return {
      'id': rental['id'],
      'status': rental['status'],
      'started_at': rental['started_at'],
      'ended_at': rental['ended_at'],
      'hourly_rate': rental['hourly_rate'],
      'total_price': rental['total_price'],
      'branch_id': rental['branch_id'],
      'branch_name': branch?['name'] ?? '—',
      'bike_id': rental['bike_id'],
      'bike_code': bike?['code'] ?? '—',
      'bike_name': bike == null ? '—' : '${bike['brand']} ${bike['model']}',
      'customer_id': rental['customer_id'],
      'customer_name': customer?['full_name'] ?? '—',
      'customer_phone': customer?['phone'] ?? '—',
      'customer_email': customer?['email'],
      'customer_document_id': customer?['document_id'],
      'employee_name': employee?['full_name'] ?? 'Empleado',
    };
  }

  // ---------------------------------------------------------------------
  // Datos iniciales
  // ---------------------------------------------------------------------

  static const String centroId = 'branch-centro';
  static const String norteId = 'branch-norte';

  void _seed(DateTime now) {
    branches.addAll([
      {
        'id': centroId,
        'name': 'Sucursal Centro',
        'address': '6a avenida 10-20, zona 1',
        'is_active': true,
      },
      {
        'id': norteId,
        'name': 'Sucursal Norte',
        'address': 'Calzada Norte 45-10, zona 17',
        'is_active': true,
      },
    ]);

    users.addAll([
      _user(
        'user-admin',
        'Admin Demo',
        DemoCredentials.adminEmail,
        'admin',
        null,
      ),
      _user(
        'user-centro',
        'Usuario Demo',
        DemoCredentials.employeeEmail,
        'employee',
        centroId,
      ),
      _user(
        'user-norte',
        'Laura Norte',
        'norte@bikes.com',
        'employee',
        norteId,
      ),
    ]);

    bikes.addAll([
      _bike('bike-1', 'BK-001', 'Trek', 'Marlin 5', 'available', 25, centroId),
      _bike('bike-2', 'BK-002', 'Giant', 'Talon 3', 'rented', 25, centroId),
      _bike('bike-3', 'BK-003', 'Specialized', 'Rockhopper', 'available', 30, centroId),
      _bike('bike-4', 'BK-004', 'Cannondale', 'Trail 8', 'rented', 25, centroId),
      _bike('bike-5', 'BK-005', 'Scott', 'Aspect 970', 'maintenance', 20, centroId),
      _bike('bike-6', 'BK-006', 'Merida', 'Big Nine', 'available', 20, norteId),
      _bike('bike-7', 'BK-007', 'GW', 'Lynx', 'available', 15, norteId),
      _bike('bike-8', 'BK-008', 'Oxford', 'Orion', 'rented', 15, norteId),
    ]);

    customers.addAll([
      _customer('cust-1', 'Ana López', '55123456', '2456789010101', 'ana.lopez@correo.com'),
      _customer('cust-2', 'Carlos Méndez', '44781234', null, null),
      _customer('cust-3', 'María Fernanda Ruiz', '30567890', '3012456780101', null),
      _customer('cust-4', 'Jorge Castillo', '52348765', null, 'jorge.c@correo.com'),
      _customer('cust-5', 'Lucía Herrera', '47651234', null, null),
      _customer('cust-6', 'Pedro Ramírez', '58904567', null, null),
    ]);

    rentals.addAll([
      _rental('rent-1', 'bike-2', 'cust-1', 'user-centro', now.subtract(const Duration(minutes: 35))),
      _rental('rent-2', 'bike-4', 'cust-2', 'user-centro', now.subtract(const Duration(hours: 1, minutes: 50))),
      _rental('rent-3', 'bike-8', 'cust-3', 'user-norte', now.subtract(const Duration(minutes: 10))),
      _rental(
        'rent-4',
        'bike-1',
        'cust-4',
        'user-centro',
        now.subtract(const Duration(days: 1, hours: 3)),
        duration: const Duration(hours: 2, minutes: 15),
      ),
      _rental(
        'rent-5',
        'bike-3',
        'cust-5',
        'user-centro',
        now.subtract(const Duration(days: 1, hours: 6)),
        duration: const Duration(minutes: 45),
      ),
      _rental(
        'rent-6',
        'bike-6',
        'cust-6',
        'user-norte',
        now.subtract(const Duration(days: 2, hours: 2)),
        duration: const Duration(hours: 1, minutes: 5),
      ),
    ]);
  }

  Map<String, dynamic> _user(
    String id,
    String name,
    String email,
    String role,
    String? branchId,
  ) => {
    'id': id,
    'full_name': name,
    'email': email,
    // Solo para la demo: Supabase Auth nunca expone contraseñas.
    'password': id == 'user-admin'
        ? DemoCredentials.adminPassword
        : DemoCredentials.employeePassword,
    'role': role,
    'branch_id': branchId,
    'is_active': true,
  };

  Map<String, dynamic> _bike(
    String id,
    String code,
    String brand,
    String model,
    String status,
    double hourlyRate,
    String branchId,
  ) => {
    'id': id,
    'code': code,
    'brand': brand,
    'model': model,
    'status': status,
    'hourly_rate': hourlyRate,
    'branch_id': branchId,
    'is_active': true,
  };

  Map<String, dynamic> _customer(
    String id,
    String name,
    String phone,
    String? documentId,
    String? email,
  ) => {
    'id': id,
    'full_name': name,
    'phone': phone,
    'document_id': documentId,
    'email': email,
  };

  /// Si se indica [duration], la renta ya terminó.
  Map<String, dynamic> _rental(
    String id,
    String bikeId,
    String customerId,
    String employeeId,
    DateTime startedAt, {
    Duration? duration,
  }) {
    final bike = findById(bikes, bikeId)!;
    final hourlyRate = bike['hourly_rate'] as double;
    final endedAt = duration == null ? null : startedAt.add(duration);
    final hours = duration == null
        ? null
        : (duration.inSeconds / Duration.secondsPerHour).ceil();

    return {
      'id': id,
      'bike_id': bikeId,
      'customer_id': customerId,
      'branch_id': bike['branch_id'],
      'started_by': employeeId,
      'finished_by': duration == null ? null : employeeId,
      'hourly_rate': hourlyRate,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'total_price': hours == null ? null : hours * hourlyRate,
      'status': duration == null ? 'active' : 'finished',
    };
  }
}

/// Una sola instancia compartida por toda la app (modo demo).
///
/// En los tests se sobrescribe con una base de datos sin latencia:
/// `inMemoryDatabaseProvider.overrideWithValue(InMemoryDatabase(latency: Duration.zero))`.
final inMemoryDatabaseProvider = Provider<InMemoryDatabase>(
  (ref) => InMemoryDatabase(),
);
