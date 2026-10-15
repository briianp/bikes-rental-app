import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/rentals/presentation/providers/rentals_providers.dart';
import 'package:bikes_app/features/rentals/presentation/widgets/finish_rental_button.dart';
import 'package:bikes_app/features/rentals/presentation/widgets/rental_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RentalDetailPage extends ConsumerWidget {
  const RentalDetailPage({super.key, required this.rentalId});

  /// Viene de la URL: `/rentals/:rentalId`.
  final String rentalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rentalAsync = ref.watch(rentalByIdProvider(rentalId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de renta')),
      body: ResponsiveCenter(
        child: AsyncValueView(
          value: rentalAsync,
          onRetry: () => ref.invalidate(rentalByIdProvider(rentalId)),
          data: (rental) {
            if (rental == null) {
              return const EmptyView(
                icon: Icons.search_off_rounded,
                message: 'No encontramos esta renta.',
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RentalInfo(rental: rental),
                  if (rental.isActive) ...[
                    const SizedBox(height: 24),
                    // Al finalizar, el provider se invalida y esta misma
                    // pantalla se actualiza con el total cobrado.
                    FinishRentalButton(rental: rental),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
