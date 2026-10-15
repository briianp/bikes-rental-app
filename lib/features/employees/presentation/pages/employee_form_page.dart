import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/utils/validators.dart';
import 'package:bikes_app/core/widgets/async_value_view.dart';
import 'package:bikes_app/core/widgets/primary_button.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/core/widgets/state_views.dart';
import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/branches/domain/entities/branch.dart';
import 'package:bikes_app/features/branches/presentation/providers/branches_providers.dart';
import 'package:bikes_app/features/employees/domain/entities/employee_drafts.dart';
import 'package:bikes_app/features/employees/presentation/providers/employees_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Crear (sin [employeeId]) o editar un empleado. Solo admin.
class EmployeeFormPage extends ConsumerWidget {
  const EmployeeFormPage({super.key, this.employeeId});

  final String? employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = employeeId;
    final branches = ref.watch(branchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Nuevo empleado' : 'Editar empleado'),
      ),
      body: ResponsiveCenter(
        child: AsyncValueView(
          value: branches,
          onRetry: () => ref.invalidate(branchesProvider),
          data: (branchList) {
            if (id == null) return _EmployeeForm(branches: branchList);
            return AsyncValueView(
              value: ref.watch(employeesProvider),
              onRetry: () => ref.invalidate(employeesProvider),
              data: (employees) {
                final employee = employees
                    .where((e) => e.id == id)
                    .firstOrNull;
                return employee == null
                    ? const EmptyView(message: 'El empleado no existe.')
                    : _EmployeeForm(branches: branchList, employee: employee);
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmployeeForm extends ConsumerStatefulWidget {
  const _EmployeeForm({required this.branches, this.employee});

  final List<Branch> branches;
  final AppUser? employee;

  @override
  ConsumerState<_EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends ConsumerState<_EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late UserRole _role;
  String? _branchId;
  late bool _isActive;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    _nameController = TextEditingController(text: employee?.name);
    _emailController.text = employee?.email ?? '';
    _role = employee?.role ?? UserRole.employee;
    _branchId = employee?.branchId;
    _isActive = employee?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = ref.read(saveEmployeeControllerProvider.notifier);
    final employee = widget.employee;
    final saved = employee == null
        ? await controller.create(
            NewEmployee(
              fullName: _nameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              role: _role,
              branchId: _branchId,
            ),
          )
        : await controller.updateEmployee(
            employee.id,
            EmployeeUpdate(
              fullName: _nameController.text,
              role: _role,
              isActive: _isActive,
              branchId: _branchId,
            ),
          );
    if (!saved || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Empleado guardado'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(saveEmployeeControllerProvider, (previous, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessageOf(error)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
    final isLoading = ref.watch(saveEmployeeControllerProvider).isLoading;
    final branchOptions = widget.branches
        .where((b) => b.isActive || b.id == _branchId)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('employee_name_field'),
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  Validators.requiredText(value, field: 'El nombre'),
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('employee_email_field'),
              controller: _emailController,
              readOnly: _isEditing,
              keyboardType: TextInputType.emailAddress,
              validator: _isEditing ? null : Validators.email,
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            if (!_isEditing) ...[
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('employee_password_field'),
                controller: _passwordController,
                obscureText: true,
                validator: Validators.password,
                decoration: const InputDecoration(
                  labelText: 'Contraseña temporal',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              key: const Key('employee_role_field'),
              initialValue: _role,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: UserRole.employee,
                  child: Text('Empleado'),
                ),
                DropdownMenuItem(
                  value: UserRole.admin,
                  child: Text('Administrador'),
                ),
              ],
              onChanged: (value) =>
                  setState(() => _role = value ?? UserRole.employee),
              decoration: const InputDecoration(
                labelText: 'Rol',
                prefixIcon: Icon(Icons.admin_panel_settings_outlined),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: const Key('employee_branch_field'),
              initialValue: _branchId,
              isExpanded: true,
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Sin sucursal'),
                ),
                for (final branch in branchOptions)
                  DropdownMenuItem<String?>(
                    value: branch.id,
                    child: Text(branch.name),
                  ),
              ],
              onChanged: (value) => setState(() => _branchId = value),
              validator: (value) => _role == UserRole.employee && value == null
                  ? 'Un empleado debe tener sucursal'
                  : null,
              decoration: const InputDecoration(
                labelText: 'Sucursal',
                prefixIcon: Icon(Icons.store_mall_directory_outlined),
              ),
            ),
            if (_isEditing)
              SwitchListTile(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                title: const Text('Cuenta activa'),
                subtitle: const Text(
                  'Un usuario inactivo no puede entrar a la app.',
                ),
              ),
            const SizedBox(height: 24),
            PrimaryButton(
              key: const Key('save_employee_button'),
              label: _isEditing ? 'Guardar cambios' : 'Crear cuenta',
              icon: Icons.save_outlined,
              isLoading: isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
