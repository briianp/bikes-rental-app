import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/data/supabase_providers.dart';
import 'package:bikes_app/features/employees/data/datasources/employees_data_sources.dart';
import 'package:bikes_app/features/employees/data/repositories/employees_repository_impl.dart';
import 'package:bikes_app/features/employees/domain/repositories/employees_repository.dart';
import 'package:bikes_app/features/employees/domain/usecases/employee_use_cases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final employeesRemoteDataSourceProvider = Provider<EmployeesRemoteDataSource>((
  ref,
) {
  if (ref.watch(useSupabaseProvider)) {
    return SupabaseEmployeesRemoteDataSource(ref.watch(supabaseClientProvider));
  }
  return FakeEmployeesRemoteDataSource(ref.watch(inMemoryDatabaseProvider));
});

final employeesRepositoryProvider = Provider<EmployeesRepository>(
  (ref) =>
      EmployeesRepositoryImpl(ref.watch(employeesRemoteDataSourceProvider)),
);

final getEmployeesUseCaseProvider = Provider<GetEmployees>(
  (ref) => GetEmployees(ref.watch(employeesRepositoryProvider)),
);

final createEmployeeUseCaseProvider = Provider<CreateEmployee>(
  (ref) => CreateEmployee(ref.watch(employeesRepositoryProvider)),
);

final updateEmployeeUseCaseProvider = Provider<UpdateEmployee>(
  (ref) => UpdateEmployee(ref.watch(employeesRepositoryProvider)),
);
