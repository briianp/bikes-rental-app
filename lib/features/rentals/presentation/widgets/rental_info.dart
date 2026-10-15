import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/formatters.dart';
import 'package:bikes_app/core/widgets/info_row.dart';
import 'package:bikes_app/core/widgets/status_badge.dart';
import 'package:bikes_app/features/rentals/domain/entities/rental.dart';
import 'package:flutter/material.dart';

/// Tarjetas con toda la información de una renta. Se usan en el detalle
/// y al escanear una bici rentada.
class RentalInfo extends StatelessWidget {
  const RentalInfo({super.key, required this.rental});

  final Rental rental;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final statusColor = rental.isActive
        ? AppColors.primary
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: statusColor,
              child: const Icon(
                Icons.directions_bike_rounded,
                color: Colors.white,
              ),
            ),
            title: Text(
              rental.bikeCode,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${rental.bikeName} · ${rental.branchName}'),
            trailing: StatusBadge(
              label: rental.isActive ? 'Activa' : 'Finalizada',
              color: statusColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Cliente',
                value: rental.customerName,
              ),
              InfoRow(
                icon: Icons.phone_outlined,
                label: 'Teléfono',
                value: rental.customerPhone,
              ),
              if (rental.customerDocumentId != null)
                InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'DPI',
                  value: rental.customerDocumentId!,
                ),
              if (rental.customerEmail != null)
                InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Correo',
                  value: rental.customerEmail!,
                ),
              InfoRow(
                icon: Icons.support_agent_rounded,
                label: 'Atendió',
                value: rental.employeeName,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              InfoRow(
                icon: Icons.play_circle_outline_rounded,
                label: 'Inicio',
                value: Formatters.dateTime(rental.startedAt),
              ),
              if (rental.endedAt != null)
                InfoRow(
                  icon: Icons.stop_circle_outlined,
                  label: 'Fin',
                  value: Formatters.dateTime(rental.endedAt!),
                ),
              InfoRow(
                icon: Icons.timer_outlined,
                label: 'Duración',
                value: Formatters.duration(rental.elapsed(now)),
              ),
              InfoRow(
                icon: Icons.sell_outlined,
                label: 'Tarifa',
                value: '${Formatters.currency(rental.hourlyRate)} / hora',
              ),
              const Divider(indent: 16, endIndent: 16),
              InfoRow(
                label: rental.isActive ? 'Total estimado' : 'Total cobrado',
                value: Formatters.currency(
                  rental.totalPrice ?? rental.calculateTotal(now),
                ),
                emphasize: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
