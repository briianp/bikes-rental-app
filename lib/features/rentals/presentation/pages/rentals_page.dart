import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/section_title.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:bikes_app/features/bikes/presentation/providers/bikes_providers.dart';
import 'package:bikes_app/features/rentals/presentation/providers/rentals_providers.dart';
import 'package:bikes_app/features/rentals/presentation/widgets/quick_action_card.dart';
import 'package:bikes_app/features/rentals/presentation/widgets/rental_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de inicio: accesos rápidos y rentas en curso.
class RentalsPage extends ConsumerWidget {
  const RentalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    final activeRentals = ref.watch(activeRentalsProvider);
    final bikes = ref.watch(bikesProvider);

    Future<void> refresh() {
      ref.invalidate(bikesProvider);
      // Devolvemos el Future para que el RefreshIndicator espere la recarga.
      return ref.refresh(activeRentalsProvider.future);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hola, ${user?.firstName ?? 'bienvenido'}'),
            Text(
              user?.branchName ?? 'Todas las sucursales',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: refresh,
          ),
        ],
      ),
      body: ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.pedal_bike_rounded,
                      label: 'Disponibles',
                      value: bikes.when(
                        data: (items) =>
                            '${items.where((bike) => bike.isAvailable).length}',
                        loading: () => '…',
                        error: (_, _) => '-',
                      ),
                      // `go` cambia de pestaña.
                      onTap: () => context.go(AppRoutes.bikes),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.history_rounded,
                      label: 'Historial',
                      // Ruta hija de /rentals: se apila dentro de esta pestaña.
                      onTap: () => context.go(AppRoutes.rentalHistory),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'En renta'),
              AsyncValueView(
                value: activeRentals,
                onRetry: () => ref.invalidate(activeRentalsProvider),
                data: (rentals) {
                  if (rentals.isEmpty) {
                    return const EmptyView(
                      icon: Icons.directions_bike_outlined,
                      message:
                          'No hay rentas activas.\nEscanea una bicicleta para iniciar una.',
                    );
                  }
                  return RentalsCard(
                    rentals: rentals,
                    // `push` apila el detalle encima de esta pantalla.
                    onTap: (rental) =>
                        context.push(AppRoutes.rentalDetail(rental.id)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
