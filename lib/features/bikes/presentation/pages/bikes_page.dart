import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/presentation/providers/bikes_providers.dart';
import 'package:bikes_app/features/bikes/presentation/widgets/bike_status_ui.dart';
import 'package:bikes_app/features/bikes/presentation/widgets/bike_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bicicletas de la sucursal. Tocar una abre la misma pantalla que el
/// escáner: iniciar renta si está libre o finalizarla si está rentada.
class BikesPage extends ConsumerWidget {
  const BikesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bikes = ref.watch(bikesProvider);
    final selectedFilter = ref.watch(bikeFilterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bicicletas')),
      body: ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(bikesProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _FilterChips(
                selected: selectedFilter,
                onSelected: (status) =>
                    ref.read(bikeFilterProvider.notifier).select(status),
              ),
              const SizedBox(height: 12),
              AsyncValueView(
                value: bikes,
                onRetry: () => ref.invalidate(bikesProvider),
                data: (allBikes) {
                  final items = selectedFilter == null
                      ? allBikes
                      : allBikes
                            .where((bike) => bike.status == selectedFilter)
                            .toList();
                  if (items.isEmpty) {
                    return const EmptyView(
                      icon: Icons.pedal_bike_outlined,
                      message: 'No hay bicicletas con este estado.',
                    );
                  }
                  return Column(
                    children: [
                      for (final bike in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: BikeTile(
                            bike: bike,
                            onTap: () =>
                                context.push(AppRoutes.bikeAction(bike.code)),
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final BikeStatus? selected;
  final ValueChanged<BikeStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip(label: 'Todas', value: null),
          for (final status in BikeStatus.values)
            _chip(label: status.label, value: status),
        ],
      ),
    );
  }

  Widget _chip({required String label, required BikeStatus? value}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == value,
        onSelected: (_) => onSelected(value),
      ),
    );
  }
}
