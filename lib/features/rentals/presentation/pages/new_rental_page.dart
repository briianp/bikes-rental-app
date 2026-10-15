import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/formatters.dart';
import 'package:bikes_app/core/widgets/primary_button.dart';
import 'package:bikes_app/core/widgets/status_badge.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/presentation/widgets/bike_status_ui.dart';
import 'package:bikes_app/features/customers/domain/entities/customer.dart';
import 'package:bikes_app/features/customers/presentation/widgets/customer_picker.dart';
import 'package:bikes_app/features/rentals/presentation/providers/rental_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Formulario para iniciar la renta de una bicicleta disponible:
/// elegir o registrar al cliente y confirmar.
///
/// Se muestra dentro de `BikeActionPage` cuando la bici escaneada está libre.
class NewRentalForm extends ConsumerStatefulWidget {
  const NewRentalForm({super.key, required this.bike});

  final Bike bike;

  @override
  ConsumerState<NewRentalForm> createState() => _NewRentalFormState();
}

class _NewRentalFormState extends ConsumerState<NewRentalForm> {
  Customer? _customer;

  Future<void> _start() async {
    final rental = await ref
        .read(startRentalControllerProvider.notifier)
        .start(bikeCode: widget.bike.code, customer: _customer);
    if (rental == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Renta iniciada: ${rental.bikeCode} para ${rental.customerName}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    // `go` reemplaza la pila: cierra esta pantalla y abre el detalle
    // dentro de la pestaña "Rentas".
    context.go(AppRoutes.rentalDetail(rental.id));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(startRentalControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessageOf(error)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    final isLoading = ref.watch(startRentalControllerProvider).isLoading;
    final bike = widget.bike;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.pedal_bike_rounded, color: Colors.white),
              ),
              title: Text(
                bike.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${bike.code} · ${Formatters.currency(bike.hourlyRate)} por hora',
              ),
              trailing: StatusBadge(
                label: bike.status.label,
                color: bike.status.color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cliente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          CustomerPicker(
            selected: _customer,
            onChanged: (customer) => setState(() => _customer = customer),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            key: const Key('start_rental_button'),
            label: 'Iniciar renta',
            icon: Icons.play_arrow_rounded,
            isLoading: isLoading,
            onPressed: _customer == null ? null : _start,
          ),
          const SizedBox(height: 8),
          const Text(
            'Se cobra por hora iniciada (mínimo 1 hora).',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
