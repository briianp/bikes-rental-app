import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fecha fija para que los tests no dependan del reloj real.
final testNow = DateTime(2026, 1, 15, 10);

/// Ids de los usuarios del modo demo.
const employeeCentroId = 'user-centro';
const employeeNorteId = 'user-norte';
const adminId = 'user-admin';

/// Base de datos sin latencia para que los tests sean instantáneos.
///
/// [loggedInAs] simula una sesión iniciada (equivale a `auth.uid()`).
InMemoryDatabase createTestDatabase({
  DateTime Function()? clock,
  String? loggedInAs,
}) {
  return InMemoryDatabase(latency: Duration.zero, clock: clock ?? () => testNow)
    ..currentUserId = loggedInAs;
}

/// Contenedor de Riverpod para tests unitarios de providers.
ProviderContainer createTestContainer({InMemoryDatabase? database}) {
  return ProviderContainer.test(
    overrides: [
      inMemoryDatabaseProvider.overrideWithValue(
        database ?? createTestDatabase(),
      ),
    ],
    retry: (_, _) => null,
  );
}
