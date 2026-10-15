import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Menú del panel de administración. El router impide que un empleado
/// llegue aquí (ver `redirect` en `app_router.dart`).
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AdminTile(
              key: const Key('admin_bikes_tile'),
              icon: Icons.pedal_bike_rounded,
              title: 'Bicicletas',
              subtitle: 'Catálogo, tarifas, estados y códigos QR',
              onTap: () => context.push(AppRoutes.adminBikes),
            ),
            _AdminTile(
              key: const Key('admin_branches_tile'),
              icon: Icons.store_mall_directory_rounded,
              title: 'Sucursales',
              subtitle: 'Crear y editar sucursales',
              onTap: () => context.push(AppRoutes.adminBranches),
            ),
            _AdminTile(
              key: const Key('admin_employees_tile'),
              icon: Icons.groups_rounded,
              title: 'Empleados',
              subtitle: 'Cuentas, roles y sucursal asignada',
              onTap: () => context.push(AppRoutes.adminEmployees),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
            child: Icon(icon, color: AppColors.accent),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: onTap,
        ),
      ),
    );
  }
}
