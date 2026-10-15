import 'package:bikes_app/core/error/failures.dart';
import 'package:bikes_app/core/utils/validators.dart';
import 'package:bikes_app/features/customers/domain/entities/customer.dart';
import 'package:bikes_app/features/customers/domain/repositories/customers_repository.dart';

/// Busca clientes. Se necesitan al menos 2 caracteres.
class SearchCustomers {
  const SearchCustomers(this._repository);

  final CustomersRepository _repository;

  Future<List<Customer>> call(String query) async {
    final clean = query.trim();
    if (clean.length < 2) return const [];
    return _repository.searchCustomers(clean);
  }
}

/// Registra un cliente nuevo validando sus datos.
class CreateCustomer {
  const CreateCustomer(this._repository);

  final CustomersRepository _repository;

  Future<Customer> call(NewCustomer customer) async {
    final name = customer.fullName.trim();
    if (name.isEmpty) {
      throw const ValidationFailure('El nombre del cliente es obligatorio.');
    }

    final phoneError = Validators.phone(customer.phone);
    if (phoneError != null) throw ValidationFailure(phoneError);

    final documentError = Validators.optionalDpi(customer.documentId);
    if (documentError != null) throw ValidationFailure(documentError);

    final emailError = Validators.optionalEmail(customer.email);
    if (emailError != null) throw ValidationFailure(emailError);

    return _repository.createCustomer(
      NewCustomer(
        fullName: name,
        phone: Validators.digitsOnly(customer.phone),
        documentId: _nullIfEmpty(Validators.digitsOnly(customer.documentId)),
        email: _nullIfEmpty(customer.email?.trim().toLowerCase()),
      ),
    );
  }

  static String? _nullIfEmpty(String? value) =>
      (value == null || value.isEmpty) ? null : value;
}
