import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/utils/validators.dart';
import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/employees/domain/entities/employee_drafts.dart';
import 'package:bikes_app/features/employees/domain/repositories/employees_repository.dart';

class GetEmployees {
  const GetEmployees(this._repository);

  final EmployeesRepository _repository;

  Future<List<AppUser>> call() => _repository.getEmployees();
}

class CreateEmployee {
  const CreateEmployee(this._repository);

  final EmployeesRepository _repository;

  Future<void> call(NewEmployee employee) async {
    final name = employee.fullName.trim();
    if (name.isEmpty) throw const ValidationFailure('El nombre es obligatorio.');

    final emailError = Validators.email(employee.email);
    if (emailError != null) throw ValidationFailure(emailError);

    final passwordError = Validators.password(employee.password);
    if (passwordError != null) throw ValidationFailure(passwordError);

    if (employee.role == UserRole.employee && employee.branchId == null) {
      throw const ValidationFailure('Un empleado debe tener una sucursal.');
    }

    await _repository.createEmployee(
      NewEmployee(
        fullName: name,
        email: employee.email.trim().toLowerCase(),
        password: employee.password,
        role: employee.role,
        branchId: employee.branchId,
      ),
    );
  }
}

/// Actualiza un empleado. Un administrador no puede quitarse a sí mismo
/// el rol de admin ni desactivar su propia cuenta (se quedaría fuera).
class UpdateEmployee {
  const UpdateEmployee(this._repository);

  final EmployeesRepository _repository;

  Future<AppUser> call({
    required String employeeId,
    required EmployeeUpdate update,
    required String currentUserId,
  }) async {
    final name = update.fullName.trim();
    if (name.isEmpty) throw const ValidationFailure('El nombre es obligatorio.');

    if (employeeId == currentUserId &&
        (update.role != UserRole.admin || !update.isActive)) {
      throw const ValidationFailure(
        'No puedes quitarte el rol de administrador ni desactivar tu cuenta.',
      );
    }
    if (update.role == UserRole.employee && update.branchId == null) {
      throw const ValidationFailure('Un empleado debe tener una sucursal.');
    }

    return _repository.updateEmployee(
      employeeId,
      EmployeeUpdate(
        fullName: name,
        role: update.role,
        isActive: update.isActive,
        branchId: update.branchId,
      ),
    );
  }
}
