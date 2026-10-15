import 'package:bikes_app/features/auth/domain/entities/app_user.dart';

// Los empleados se representan con `AppUser` (mismo perfil que la sesión).

/// Datos para crear la cuenta de un empleado.
class NewEmployee {
  const NewEmployee({
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.branchId,
  });

  final String fullName;
  final String email;
  final String password;
  final UserRole role;
  final String? branchId;
}

/// Cambios que un administrador puede hacer sobre un empleado.
class EmployeeUpdate {
  const EmployeeUpdate({
    required this.fullName,
    required this.role,
    required this.isActive,
    this.branchId,
  });

  final String fullName;
  final UserRole role;
  final bool isActive;
  final String? branchId;
}
