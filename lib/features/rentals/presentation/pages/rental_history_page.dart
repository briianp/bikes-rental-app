import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/rentals/presentation/providers/rentals_providers.dart';
import 'package:bikes_app/features/rentals/presentation/widgets/rental_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RentalHistoryPage extends ConsumerWidget {
  const RentalHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(rentalHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      body: ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(rentalHistoryProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              AsyncValueView(
                value: history,
                onRetry: () => ref.invalidate(rentalHistoryProvider),
                data: (rentals) {
                  if (rentals.isEmpty) {
                    return const EmptyView(
                      icon: Icons.history_rounded,
                      message: 'Todavía no hay rentas finalizadas.',
                    );
                  }
                  return RentalsCard(
                    rentals: rentals,
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
