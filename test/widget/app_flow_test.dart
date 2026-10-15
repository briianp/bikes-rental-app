import 'package:bikes_app/app/app.dart';
import 'package:bikes_app/core/constants/demo_credentials.dart';
import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests de widgets que recorren la app completa en modo demo: login,
/// pestañas, iniciar y finalizar rentas, clientes, panel de admin y logout.
void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    // Tamaño de un teléfono (360 x 800 lógicos).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inMemoryDatabaseProvider.overrideWithValue(
            InMemoryDatabase(latency: Duration.zero),
          ),
        ],
        retry: (_, _) => null,
        child: const BikesApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> signInAsEmployee(WidgetTester tester) =>
      tapAndSettle(tester, find.byKey(const Key('demo_employee_button')));

  Future<void> signInAsAdmin(WidgetTester tester) =>
      tapAndSettle(tester, find.byKey(const Key('demo_admin_button')));

  Finder navItem(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Future<void> openBikeByCode(WidgetTester tester, String code) async {
    await tester.tap(navItem('Escanear'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('manual_code_field')), code);
    await tapAndSettle(
      tester,
      find.byKey(const Key('manual_code_submit_button')),
    );
  }

  /// Espera a que se cierren los SnackBars para que no tapen botones.
  Future<void> waitForSnackBars(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  group('Login', () {
    testWidgets('sin sesión muestra el login y valida los campos', (
      tester,
    ) async {
      await pumpApp(tester);

      expect(find.text('Iniciar sesión'), findsOneWidget);

      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pump();

      expect(find.text('Ingresa un correo'), findsOneWidget);
      expect(find.text('Ingresa la contraseña'), findsOneWidget);
    });

    testWidgets('credenciales incorrectas muestran un error', (tester) async {
      await pumpApp(tester);

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        DemoCredentials.employeeEmail,
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        'incorrecta',
      );
      await tapAndSettle(tester, find.byKey(const Key('login_submit_button')));

      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
    });

    testWidgets('el empleado ve solo su sucursal y no ve el panel admin', (
      tester,
    ) async {
      await pumpApp(tester);
      await signInAsEmployee(tester);

      expect(find.text('Sucursal Centro'), findsOneWidget);
      expect(find.text('En renta'), findsOneWidget);
      expect(find.text('BK-002'), findsOneWidget);

      await tester.tap(navItem('Bicicletas'));
      await tester.pumpAndSettle();
      expect(find.text('Trek Marlin 5'), findsOneWidget);
      // Merida Big Nine es de Sucursal Norte.
      expect(find.text('Merida Big Nine'), findsNothing);

      await tester.tap(navItem('Perfil'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('open_admin_button')), findsNothing);
    });

    testWidgets('cerrar sesión regresa al login', (tester) async {
      await pumpApp(tester);
      await signInAsEmployee(tester);

      await tester.tap(navItem('Perfil'));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byKey(const Key('sign_out_button')));
      await tester.tap(find.byKey(const Key('confirm_sign_out_button')));
      await tester.pumpAndSettle();

      expect(find.text('Iniciar sesión'), findsOneWidget);
    });
  });

  group('Rentas', () {
    testWidgets('iniciar renta con un cliente existente', (tester) async {
      await pumpApp(tester);
      await signInAsEmployee(tester);

      await tester.tap(navItem('Bicicletas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trek Marlin 5'));
      await tester.pumpAndSettle();
      expect(find.text('Nueva renta'), findsOneWidget);

      // Buscar al cliente y seleccionarlo.
      await tester.enterText(
        find.byKey(const Key('customer_search_field')),
        'Ana',
      );
      await tapAndSettle(
        tester,
        find.byKey(const Key('customer_search_button')),
      );
      await tapAndSettle(tester, find.text('Ana López'));

      await tapAndSettle(tester, find.byKey(const Key('start_rental_button')));

      expect(find.text('Detalle de renta'), findsOneWidget);
      expect(find.text('Activa'), findsOneWidget);
      expect(find.text('Ana López'), findsOneWidget);
    });

    testWidgets('iniciar renta registrando un cliente nuevo', (tester) async {
      await pumpApp(tester);
      await signInAsEmployee(tester);

      await openBikeByCode(tester, 'bk-003');
      expect(find.text('Specialized Rockhopper'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const Key('new_customer_button')));
      await tester.enterText(
        find.byKey(const Key('customer_name_field')),
        'Cliente Nuevo',
      );
      await tester.enterText(
        find.byKey(const Key('customer_phone_field')),
        '55667788',
      );
      await tapAndSettle(tester, find.byKey(const Key('save_customer_button')));
      expect(find.text('Cliente Nuevo'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const Key('start_rental_button')));

      expect(find.text('Detalle de renta'), findsOneWidget);
      expect(find.text('Cliente Nuevo'), findsOneWidget);
    });

    testWidgets('escanear una bici rentada permite finalizar su renta', (
      tester,
    ) async {
      await pumpApp(tester);
      await signInAsEmployee(tester);

      await openBikeByCode(tester, 'BK-002');

      // Muestra la renta activa de Ana con el botón para finalizar.
      expect(find.text('Ana López'), findsOneWidget);
      expect(find.text('Activa'), findsOneWidget);

      await tapAndSettle(
        tester,
        find.byKey(const Key('finish_rental_button')),
      );
      await tester.tap(find.byKey(const Key('confirm_finish_rental_button')));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de renta'), findsOneWidget);
      expect(find.text('Finalizada'), findsOneWidget);
      expect(find.text('Total cobrado'), findsOneWidget);
    });

    testWidgets('una bici de otra sucursal no se encuentra', (tester) async {
      await pumpApp(tester);
      await signInAsEmployee(tester);

      await openBikeByCode(tester, 'BK-008');

      expect(find.textContaining('No encontramos la bicicleta'), findsOneWidget);
    });
  });

  group('Administración', () {
    testWidgets('el admin crea una bicicleta', (tester) async {
      await pumpApp(tester);
      await signInAsAdmin(tester);

      expect(find.text('Todas las sucursales'), findsOneWidget);

      await tester.tap(navItem('Perfil'));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byKey(const Key('open_admin_button')));
      await tapAndSettle(tester, find.byKey(const Key('admin_bikes_tile')));

      // El admin ve las bicis de todas las sucursales.
      expect(find.text('Merida Big Nine'), findsOneWidget);

      await tapAndSettle(tester, find.byKey(const Key('add_bike_button')));
      await tester.enterText(
        find.byKey(const Key('bike_code_field')),
        'bk-009',
      );
      await tester.enterText(find.byKey(const Key('bike_brand_field')), 'Trek');
      await tester.enterText(find.byKey(const Key('bike_model_field')), 'FX 2');
      await tester.enterText(find.byKey(const Key('bike_rate_field')), '35');

      await tapAndSettle(tester, find.byKey(const Key('bike_branch_field')));
      await tester.tap(find.text('Sucursal Norte').last);
      await tester.pumpAndSettle();

      await tapAndSettle(tester, find.byKey(const Key('save_bike_button')));

      expect(find.text('Catálogo de bicicletas'), findsOneWidget);
      expect(find.text('Trek FX 2'), findsOneWidget);
    });

    testWidgets('el admin abre el QR de una bicicleta', (tester) async {
      await pumpApp(tester);
      await signInAsAdmin(tester);

      await tester.tap(navItem('Perfil'));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byKey(const Key('open_admin_button')));
      await tapAndSettle(tester, find.byKey(const Key('admin_bikes_tile')));
      await tapAndSettle(tester, find.text('Trek Marlin 5'));
      await tapAndSettle(tester, find.byKey(const Key('show_qr_button')));

      expect(find.byKey(const Key('bike_qr_image')), findsOneWidget);
    });

    testWidgets('el admin crea un empleado', (tester) async {
      await pumpApp(tester);
      await signInAsAdmin(tester);

      await tester.tap(navItem('Perfil'));
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.byKey(const Key('open_admin_button')));
      await tapAndSettle(tester, find.byKey(const Key('admin_employees_tile')));
      await tapAndSettle(tester, find.byKey(const Key('add_employee_button')));

      await tester.enterText(
        find.byKey(const Key('employee_name_field')),
        'Pedro Pruebas',
      );
      await tester.enterText(
        find.byKey(const Key('employee_email_field')),
        'pedro@bikes.com',
      );
      await tester.enterText(
        find.byKey(const Key('employee_password_field')),
        'secreto1',
      );
      await tapAndSettle(tester, find.byKey(const Key('employee_branch_field')));
      await tester.tap(find.text('Sucursal Centro').last);
      await tester.pumpAndSettle();

      await tapAndSettle(
        tester,
        find.byKey(const Key('save_employee_button')),
      );
      await waitForSnackBars(tester);

      expect(find.text('Empleados'), findsOneWidget);
      expect(find.text('Pedro Pruebas'), findsOneWidget);
    });
  });
}
