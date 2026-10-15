import 'package:bikes_app/core/error/api_exception.dart';
import 'package:bikes_app/features/customers/data/datasources/customers_data_sources.dart';
import 'package:bikes_app/features/customers/data/models/customer_model.dart';
import 'package:bikes_app/features/customers/domain/entities/customer.dart';
import 'package:bikes_app/features/customers/domain/repositories/customers_repository.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  const CustomersRepositoryImpl(this._remoteDataSource);

  final CustomersRemoteDataSource _remoteDataSource;

  @override
  Future<List<Customer>> searchCustomers(String query) =>
      guardApiCall(() async {
        final rows = await _remoteDataSource.searchCustomers(query);
        return rows.map(CustomerModel.fromJson).toList();
      });

  @override
  Future<Customer> createCustomer(NewCustomer customer) =>
      guardApiCall(() async {
        final row = await _remoteDataSource.createCustomer(
          CustomerModel.toJson(customer),
        );
        return CustomerModel.fromJson(row);
      });
}
