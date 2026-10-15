import 'package:bikes_app/core/data/in_memory_database.dart';
import 'package:bikes_app/core/data/supabase_providers.dart';
import 'package:bikes_app/features/customers/data/datasources/customers_data_sources.dart';
import 'package:bikes_app/features/customers/data/repositories/customers_repository_impl.dart';
import 'package:bikes_app/features/customers/domain/repositories/customers_repository.dart';
import 'package:bikes_app/features/customers/domain/usecases/customer_use_cases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customersRemoteDataSourceProvider = Provider<CustomersRemoteDataSource>((
  ref,
) {
  if (ref.watch(useSupabaseProvider)) {
    return SupabaseCustomersRemoteDataSource(ref.watch(supabaseClientProvider));
  }
  return FakeCustomersRemoteDataSource(ref.watch(inMemoryDatabaseProvider));
});

final customersRepositoryProvider = Provider<CustomersRepository>(
  (ref) =>
      CustomersRepositoryImpl(ref.watch(customersRemoteDataSourceProvider)),
);

final searchCustomersUseCaseProvider = Provider<SearchCustomers>(
  (ref) => SearchCustomers(ref.watch(customersRepositoryProvider)),
);

final createCustomerUseCaseProvider = Provider<CreateCustomer>(
  (ref) => CreateCustomer(ref.watch(customersRepositoryProvider)),
);
