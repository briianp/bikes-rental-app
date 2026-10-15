import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/formatters.dart';
import 'package:bikes_app/core/widgets/status_badge.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:bikes_app/features/bikes/presentation/widgets/bike_status_ui.dart';
import 'package:flutter/material.dart';

class BikeTile extends StatelessWidget {
  const BikeTile({
    super.key,
    required this.bike,
    this.onTap,
    this.showBranch = false,
  });

  final Bike bike;
  final VoidCallback? onTap;

  /// En el panel de admin se muestra la sucursal de cada bici.
  final bool showBranch;

  @override
  Widget build(BuildContext context) {
    final color = bike.isActive ? bike.status.color : AppColors.textSecondary;
    final details = [
      bike.code,
      '${Formatters.currency(bike.hourlyRate)}/h',
      if (showBranch && bike.branchName != null) bike.branchName!,
    ].join(' · ');

    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(Icons.pedal_bike_rounded, color: color),
        ),
        title: Text(
          bike.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          details,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: StatusBadge(
          label: bike.isActive ? bike.status.label : 'De baja',
          color: color,
        ),
      ),
    );
  }
}
