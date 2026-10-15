import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/features/bikes/data/datasources/fake_bikes_remote_data_source.dart';
import 'package:bikes_app/features/bikes/data/repositories/bikes_repository_impl.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/customers/domain/entities/customer.dart';
import 'package:bikes_app/features/rentals/data/datasources/fake_rentals_remote_data_source.dart';
import 'package:bikes_app/features/rentals/data/repositories/rentals_repository_impl.dart';
import 'package:bikes_app/features/rentals/domain/entities/bike_scan_result.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:bikes_app/features/rentals/domain/usecases/finish_rental.dart';
import 'package:bikes_app/features/rentals/domain/usecases/scan_bike.dart';
import 'package:bikes_app/features/rentals/domain/usecases/start_rental.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late DateTime now;
  late InMemoryDatabase database;
  late BikesRepositoryImpl bikesRepository;
  late RentalsRepositoryImpl rentalsRepository;
  late StartRental startRental;
  late FinishRental finishRental;
  late ScanBike scanBike;

  const ana = Customer(id: 'cust-1', fullName: 'Ana López', phone: '55123456');

  setUp(() {
    now = testNow;
    database = createTestDatabase(
      clock: () => now,
      loggedInAs: employeeCentroId,
    );
    bikesRepository = BikesRepositoryImpl(FakeBikesRemoteDataSource(database));
    rentalsRepository = RentalsRepositoryImpl(
      FakeRentalsRemoteDataSource(database),
    );
    startRental = StartRental(
      rentalsRepository: rentalsRepository,
      bikesRepository: bikesRepository,
    );
    finishRental = FinishRental(rentalsRepository);
    scanBike = ScanBike(
      bikesRepository: bikesRepository,
      rentalsRepository: rentalsRepository,
    );
  });

  group('StartRental', () {
    test('crea la renta y marca la bicicleta como rentada', () async {
      final rental = await startRental(bikeCode: ' bk-001 ', customer: ana);

      expect(rental.bikeCode, 'BK-001');
      expect(rental.status, RentalStatus.active);
      expect(rental.customerName, 'Ana López');
      expect(rental.employeeName, 'Usuario Demo');
      expect(rental.startedAt, testNow);

      final bike = await bikesRepository.getBikeByCode('BK-001');
      expect(bike?.status, BikeStatus.rented);
    });

    test('exige un cliente', () async {
      await expectLater(
        startRental(bikeCode: 'BK-001', customer: null),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('falla si la bicicleta ya está rentada', () async {
      await expectLater(
        startRental(bikeCode: 'BK-002', customer: ana),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('falla si la bicicleta está en mantenimiento', () async {
      await expectLater(
        startRental(bikeCode: 'BK-005', customer: ana),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('un empleado no ve bicicletas de otra sucursal', () async {
      // BK-006 pertenece a Sucursal Norte.
      await expectLater(
        startRental(bikeCode: 'BK-006', customer: ana),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('FinishRental', () {
    test('calcula el total por hora iniciada y libera la bici', () async {
      final rental = await startRental(bikeCode: 'BK-001', customer: ana);

      // 1 h 30 min después → 2 horas × Q25 = Q50
      now = testNow.add(const Duration(hours: 1, minutes: 30));
      final finished = await finishRental(rental.id);

      expect(finished.status, RentalStatus.finished);
      expect(finished.totalPrice, 50);

      final bike = await bikesRepository.getBikeByCode('BK-001');
      expect(bike?.status, BikeStatus.available);
    });

    test('no permite finalizar dos veces la misma renta', () async {
      final rental = await startRental(bikeCode: 'BK-001', customer: ana);
      await finishRental(rental.id);

      await expectLater(
        finishRental(rental.id),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });

  group('ScanBike', () {
    test('bici disponible → lista para rentar', () async {
      expect(await scanBike('BK-001'), isA<BikeReadyToRent>());
    });

    test('bici rentada → devuelve su renta activa para finalizarla', () async {
      final result = await scanBike('bk-002');

      expect(result, isA<BikeCurrentlyRented>());
      expect((result as BikeCurrentlyRented).rental.customerName, 'Ana López');
    });

    test('bici en mantenimiento → no disponible', () async {
      expect(await scanBike('BK-005'), isA<BikeUnavailable>());
    });

    test('código inexistente u otra sucursal → no encontrada', () async {
      expect(await scanBike('BK-999'), isA<BikeNotFound>());
      expect(await scanBike('BK-008'), isA<BikeNotFound>());
    });
  });
}
