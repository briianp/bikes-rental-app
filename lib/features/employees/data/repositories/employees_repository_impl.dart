import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/auth/data/models/user_model.dart';
import 'package:bikes_app/features/auth/domain/entities/app_user.dart';
import 'package:bikes_app/features/employees/data/datasources/employees_data_sources.dart';
import 'package:bikes_app/features/employees/domain/entities/employee_drafts.dart';
import 'package:bikes_app/features/employees/domain/repositories/employees_repository.dart';

class EmployeesRepositoryImpl implements EmployeesRepository {
  const EmployeesRepositoryImpl(this._remoteDataSource);

  final EmployeesRemoteDataSource _remoteDataSource;

  @override
  Future<List<AppUser>> getEmployees() => guardApiCall(() async {
    final rows = await _remoteDataSource.getEmployees();
    return rows.map((row) => UserModel.fromJson(row).toEntity()).toList();
  });

  @override
  Future<void> createEmployee(NewEmployee employee) => guardApiCall(
    () => _remoteDataSource.createEmployee({
      'full_name': employee.fullName,
      'email': employee.email,
      'password': employee.password,
      'role': employee.role.name,
      'branch_id': employee.branchId,
    }),
  );

  @override
  Future<AppUser> updateEmployee(String id, EmployeeUpdate update) =>
      guardApiCall(() async {
        final row = await _remoteDataSource.updateEmployee(id, {
          'full_name': update.fullName,
          'role': update.role.name,
          'branch_id': update.branchId,
          'is_active': update.isActive,
        });
        return UserModel.fromJson(row).toEntity();
      });
}
