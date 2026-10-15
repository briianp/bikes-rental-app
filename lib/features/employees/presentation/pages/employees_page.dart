import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/core/widgets/status_badge.dart';
import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/employees/presentation/providers/employees_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Empleados y administradores (solo admin).
class EmployeesPage extends ConsumerWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employees = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_employee_button'),
        onPressed: () => context.push(AppRoutes.adminNewEmployee),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nuevo'),
      ),
      body: ResponsiveCenter(
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(employeesProvider.future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
            children: [
              AsyncValueView(
                value: employees,
                onRetry: () => ref.invalidate(employeesProvider),
                data: (items) {
                  if (items.isEmpty) {
                    return const EmptyView(message: 'No hay empleados.');
                  }
                  return Card(
                    child: Column(
                      children: [
                        for (final employee in items)
                          _EmployeeTile(
                            employee: employee,
                            onTap: () => context.push(
                              AppRoutes.adminEmployee(employee.id),
                            ),
                          ),
                      ],
                    ),
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

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.onTap});

  final AppUser employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (label, color) = !employee.isActive
        ? ('Inactivo', AppColors.textSecondary)
        : employee.isAdmin
        ? ('Admin', AppColors.accent)
        : ('Empleado', AppColors.primary);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Text(employee.initials, style: TextStyle(color: color)),
      ),
      title: Text(employee.name),
      subtitle: Text(
        [employee.email, employee.branchName ?? 'Sin sucursal'].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: StatusBadge(label: label, color: color),
    );
  }
}
