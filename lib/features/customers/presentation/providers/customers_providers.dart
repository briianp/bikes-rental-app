import 'dart:async';

import 'package:bikes_app/features/customers/customers_dependencies.dart';
import 'package:bikes_app/features/customers/domain/entities/customer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resultados de búsqueda de clientes por texto (teléfono, DPI o nombre).
final customerSearchProvider = FutureProvider.autoDispose
    .family<List<Customer>, String>(
      (ref, query) => ref.watch(searchCustomersUseCaseProvider).call(query),
    );

/// Controla el registro de un cliente nuevo.
final createCustomerControllerProvider =
    AsyncNotifierProvider.autoDispose<CreateCustomerController, void>(
      CreateCustomerController.new,
    );

class CreateCustomerController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Devuelve el cliente creado o `null` si hubo un error.
  Future<Customer?> create(NewCustomer customer) async {
    state = const AsyncLoading();
    try {
      final created = await ref
          .read(createCustomerUseCaseProvider)
          .call(customer);
      if (!ref.mounted) return created;
      ref.invalidate(customerSearchProvider);
      state = const AsyncData(null);
      return created;
    } catch (error, stackTrace) {
      if (ref.mounted) state = AsyncError(error, stackTrace);
      return null;
    }
  }
}
