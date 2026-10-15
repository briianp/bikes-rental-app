/// Errores de negocio que la capa de dominio expone a la presentación.
///
/// Los repositorios convierten cualquier error técnico (red, Supabase,
/// parseo, etc.) en una [Failure], así la UI solo necesita conocer este tipo.
sealed class Failure implements Exception {
  const Failure(this.message);

  /// Mensaje listo para mostrar al usuario.
  final String message;

  @override
  String toString() => message;
}

/// Credenciales inválidas o sesión expirada.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// El usuario no tiene permiso para la acción (rol o sucursal).
final class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// El recurso solicitado no existe.
final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

/// Una regla de negocio o validación no se cumple.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// El servidor respondió con un error.
final class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Cualquier error no contemplado.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}

/// Devuelve un mensaje amigable para cualquier error.
String errorMessageOf(Object? error) {
  if (error is Failure) return error.message;
  return 'Ocurrió un error inesperado. Intenta de nuevo.';
}
