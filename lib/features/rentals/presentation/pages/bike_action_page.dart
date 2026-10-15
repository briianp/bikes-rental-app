import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/bikes/presentation/widgets/bike_status_ui.dart';
import 'package:bikes_app/features/rentals/domain/entities/bike_scan_result.dart';
import 'package:bikes_app/features/rentals/presentation/pages/new_rental_page.dart';
import 'package:bikes_app/features/rentals/presentation/providers/rentals_providers.dart';
import 'package:bikes_app/features/rentals/presentation/widgets/finish_rental_button.dart';
import 'package:bikes_app/features/rentals/presentation/widgets/rental_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla que se abre al escanear (o escribir) el código de una bici.
///
/// Según su estado muestra:
/// · Disponible     → formulario para iniciar la renta.
/// · En renta       → la renta activa con el botón "Finalizar".
/// · No disponible  → el motivo.
class BikeActionPage extends ConsumerWidget {
  const BikeActionPage({super.key, required this.bikeCode});

  /// Viene de la URL: `/bike/:bikeCode`.
  final String bikeCode;

  /// Si se abrió con `push` regresa; si se abrió con un enlace directo
  /// (no hay pantalla anterior) va al escáner.
  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.scanner);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scan = ref.watch(bikeScanProvider(bikeCode));
    final title = switch (scan) {
      AsyncData(value: BikeReadyToRent()) => 'Nueva renta',
      AsyncData(value: BikeCurrentlyRented()) => 'Finalizar renta',
      _ => 'Bicicleta $bikeCode',
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ResponsiveCenter(
        child: AsyncValueView(
          value: scan,
          onRetry: () => ref.invalidate(bikeScanProvider(bikeCode)),
          data: (result) => switch (result) {
            BikeReadyToRent(:final bike) => NewRentalForm(bike: bike),
            BikeCurrentlyRented(:final rental) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RentalInfo(rental: rental),
                  const SizedBox(height: 24),
                  FinishRentalButton(
                    rental: rental,
                    // Mostramos el resultado final (con el total cobrado).
                    onFinished: (finished) =>
                        context.go(AppRoutes.rentalDetail(finished.id)),
                  ),
                ],
              ),
            ),
            BikeUnavailable(:final bike) => EmptyView(
              icon: Icons.build_circle_outlined,
              message: bike.isActive
                  ? 'La bicicleta ${bike.code} no se puede rentar '
                        '(${bike.status.label}).'
                  : 'La bicicleta ${bike.code} está dada de baja.',
              action: TextButton(
                onPressed: () => _goBack(context),
                child: const Text('Volver'),
              ),
            ),
            BikeNotFound(:final code) => EmptyView(
              icon: Icons.search_off_rounded,
              message:
                  'No encontramos la bicicleta "$code" en tu sucursal.',
              action: TextButton(
                onPressed: () => _goBack(context),
                child: const Text('Volver'),
              ),
            ),
          },
        ),
      ),
    );
  }
}
