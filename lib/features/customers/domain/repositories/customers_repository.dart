import 'package:bikes_app/features/customers/domain/entities/customer.dart';

abstract interface class CustomersRepository {
  /// Busca por teléfono, DPI o nombre.
  Future<List<Customer>> searchCustomers(String query);

  Future<Customer> createCustomer(NewCustomer customer);
}
