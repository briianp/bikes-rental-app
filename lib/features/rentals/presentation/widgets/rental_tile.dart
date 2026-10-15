import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/formatters.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:flutter/material.dart';

/// Fila de una renta. En rentas activas muestra el tiempo transcurrido;
/// en el historial muestra el total cobrado.
class RentalTile extends StatelessWidget {
  const RentalTile({super.key, required this.rental, this.onTap});

  final Rental rental;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = rental.isActive ? AppColors.primary : AppColors.textSecondary;
    final trailing = rental.isActive
        ? Formatters.duration(rental.elapsed(DateTime.now()))
        : Formatters.currency(rental.totalPrice ?? 0);
    final subtitle = rental.isActive
        ? '${rental.customerName} · desde ${Formatters.time(rental.startedAt)}'
        : '${rental.customerName} · ${Formatters.date(rental.endedAt ?? rental.startedAt)}';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color,
              child: const Icon(
                Icons.directions_bike_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rental.bikeCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trailing,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta con varias rentas separadas por divisores.
class RentalsCard extends StatelessWidget {
  const RentalsCard({super.key, required this.rentals, required this.onTap});

  final List<Rental> rentals;
  final ValueChanged<Rental> onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < rentals.length; i++) ...[
            RentalTile(rental: rentals[i], onTap: () => onTap(rentals[i])),
            if (i < rentals.length - 1)
              const Divider(indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}
