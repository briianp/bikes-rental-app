import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/config/app_config.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/widgets/info_row.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirm_sign_out_button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Al quedar la sesión en `null`, el router redirige al login.
    await ref.read(sessionProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider);
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ResponsiveCenter(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.accent,
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Card(
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.work_outline_rounded,
                    label: 'Rol',
                    value: user.isAdmin ? 'Administrador' : 'Empleado',
                  ),
                  InfoRow(
                    icon: Icons.store_mall_directory_outlined,
                    label: 'Sucursal',
                    value:
                        user.branchName ??
                        (user.isAdmin ? 'Todas' : 'Sin asignar'),
                  ),
                ],
              ),
            ),
            if (user.isAdmin) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  key: const Key('open_admin_button'),
                  leading: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.accent,
                  ),
                  title: const Text('Panel de administración'),
                  subtitle: const Text('Bicicletas, sucursales y empleados'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push(AppRoutes.admin),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  const InfoRow(
                    icon: Icons.info_outline_rounded,
                    label: 'Versión',
                    value: '2.0.0',
                  ),
                  InfoRow(
                    icon: Icons.storage_outlined,
                    label: 'Datos',
                    value: AppConfig.useSupabase
                        ? 'Supabase'
                        : 'Demo en memoria',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              key: const Key('sign_out_button'),
              onPressed: () => _confirmSignOut(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Cerrar sesión'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
