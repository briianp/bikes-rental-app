import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rental.billableHours', () {
    test('cobra mínimo una hora', () {
      expect(Rental.billableHours(Duration.zero), 1);
      expect(Rental.billableHours(const Duration(minutes: 10)), 1);
    });

    test('cobra por hora iniciada', () {
      expect(Rental.billableHours(const Duration(minutes: 60)), 1);
      expect(Rental.billableHours(const Duration(minutes: 61)), 2);
      expect(Rental.billableHours(const Duration(hours: 2, minutes: 30)), 3);
    });
  });

  test('calculateTotal multiplica horas cobrables por la tarifa', () {
    final rental = Rental(
      id: 'rent-x',
      bikeId: 'bike-1',
      bikeCode: 'BK-001',
      bikeName: 'Trek Marlin 5',
      customerId: 'cust-1',
      customerName: 'Ana',
      customerPhone: '55123456',
      branchId: 'branch-centro',
      branchName: 'Sucursal Centro',
      hourlyRate: 25,
      startedAt: DateTime(2026, 1, 15, 10),
      status: RentalStatus.active,
      employeeName: 'Demo',
    );

    // 1 h 20 min → 2 horas × Q25
    expect(rental.calculateTotal(DateTime(2026, 1, 15, 11, 20)), 50);
  });
}
