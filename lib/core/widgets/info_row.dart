import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Fila "etiqueta — valor" usada en pantallas de detalle.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
          ],
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.bold : FontWeight.w500,
                fontSize: emphasize ? 18 : 15,
                color: emphasize ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
