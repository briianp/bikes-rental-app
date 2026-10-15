/// Cliente que renta bicicletas. Se comparte entre sucursales.
class Customer {
  const Customer({
    required this.id,
    required this.fullName,
    required this.phone,
    this.documentId,
    this.email,
  });

  final String id;
  final String fullName;
  final String phone;

  /// DPI (opcional).
  final String? documentId;
  final String? email;
}

/// Datos para registrar un cliente nuevo.
class NewCustomer {
  const NewCustomer({
    required this.fullName,
    required this.phone,
    this.documentId,
    this.email,
  });

  final String fullName;
  final String phone;
  final String? documentId;
  final String? email;
}
