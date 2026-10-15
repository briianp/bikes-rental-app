import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/employees/domain/entities/employee_drafts.dart';

abstract interface class EmployeesRepository {
  Future<List<AppUser>> getEmployees();

  Future<void> createEmployee(NewEmployee employee);

  Future<AppUser> updateEmployee(String id, EmployeeUpdate update);
}
