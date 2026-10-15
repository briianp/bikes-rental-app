enum UserRole { admin, employee }

/// Usuario de la app: empleado de una sucursal o administrador.
///
/// Las entidades son clases Dart puras: no saben de JSON, Flutter ni de
/// dónde vienen los datos.
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.branchId,
    this.branchName,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isActive;

  /// Sucursal asignada. Un administrador puede no tener.
  final String? branchId;
  final String? branchName;

  bool get isAdmin => role == UserRole.admin;

  String get firstName => name.trim().split(' ').first;

  /// "Usuario Demo" → "UD"
  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
}
