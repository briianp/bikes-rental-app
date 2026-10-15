import 'package:bikes_app/core/utils/formatters.dart';
import 'package:bikes_app/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('email acepta correos válidos y rechaza inválidos', () {
      expect(Validators.email('demo@bikes.com'), isNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('demo@'), isNotNull);
      expect(Validators.email('sin-arroba.com'), isNotNull);
    });

    test('optionalEmail permite el campo vacío', () {
      expect(Validators.optionalEmail(''), isNull);
      expect(Validators.optionalEmail(null), isNull);
      expect(Validators.optionalEmail('malo'), isNotNull);
    });

    test('phone exige entre 8 y 15 dígitos', () {
      expect(Validators.phone('5512-3456'), isNull);
      expect(Validators.phone('+502 5512 3456'), isNull);
      expect(Validators.phone('1234'), isNotNull);
      expect(Validators.phone(''), isNotNull);
    });

    test('optionalDpi acepta vacío o 13 dígitos', () {
      expect(Validators.optionalDpi(''), isNull);
      expect(Validators.optionalDpi('2456 78901 0101'), isNull);
      expect(Validators.optionalDpi('12345'), isNotNull);
    });

    test('positiveNumber acepta tarifas válidas', () {
      expect(Validators.positiveNumber('25'), isNull);
      expect(Validators.positiveNumber('25,50'), isNull);
      expect(Validators.positiveNumber('0'), isNotNull);
      expect(Validators.positiveNumber('abc'), isNotNull);
    });

    test('password exige mínimo 6 caracteres', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('123'), isNotNull);
    });
  });

  group('Formatters', () {
    test('currency usa quetzales con dos decimales', () {
      expect(Formatters.currency(25), 'Q25.00');
      expect(Formatters.currency(7.5), 'Q7.50');
    });

    test('duration muestra minutos u horas', () {
      expect(Formatters.duration(const Duration(minutes: 45)), '45 min');
      expect(
        Formatters.duration(const Duration(hours: 1, minutes: 5)),
        '1 h 05 min',
      );
    });
  });
}
