/// Sucursal del negocio.
class Branch {
  const Branch({
    required this.id,
    required this.name,
    required this.isActive,
    this.address,
  });

  final String id;
  final String name;
  final String? address;
  final bool isActive;
}

/// Datos para crear o editar una sucursal.
class BranchDraft {
  const BranchDraft({required this.name, this.address, this.isActive = true});

  final String name;
  final String? address;
  final bool isActive;
}
