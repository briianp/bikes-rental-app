import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/bikes/presentation/providers/bikes_providers.dart';
import 'package:bikes_app/features/bikes/presentation/widgets/bike_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Catálogo de bicicletas de todas las sucursales (solo admin).
class AdminBikesPage extends ConsumerWidget {
  const AdminBikesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikes = ref.watch(adminBikesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de bicicletas')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_bike_button'),
        onPressed: () => context.push(AppRoutes.adminNewBike),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva'),
      ),
      body: ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(adminBikesProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              AsyncValueView(
                value: bikes,
                onRetry: () => ref.invalidate(adminBikesProvider),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyView(
                      icon: Icons.pedal_bike_outlined,
                      message: 'Todavía no hay bicicletas registradas.',
                    );
                  }
                  return Column(
                    children: [
                      for (final bike in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BikeTile(
                            bike: bike,
                            showBranch: true,
                            onTap: () =>
                                context.push(AppRoutes.adminBike(bike.id)),
                          ),
                        ),
                    ],
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
