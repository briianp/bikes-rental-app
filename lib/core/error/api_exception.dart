import 'package:bikes_app/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Error técnico lanzado por los data sources falsos (modo demo), con un
/// código HTTP igual al que devolvería una API real.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  /// Traduce el código HTTP a un error de dominio.
  Failure toFailure() => switch (statusCode) {
    400 || 409 || 422 => ValidationFailure(message),
    401 => AuthFailure(message),
    403 => PermissionFailure(message),
    404 => NotFoundFailure(message),
    _ => ServerFailure(message),
  };

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Ejecuta una llamada a un data source y convierte cualquier error técnico
/// (modo demo o Supabase) en una [Failure].
///
/// Los repositorios la usan para que ninguna excepción técnica llegue a la UI.
Future<T> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on Failure {
    rethrow;
  } on ApiException catch (exception) {
    throw exception.toFailure();
  } on PostgrestException catch (exception) {
    throw _fromPostgrest(exception);
  } on AuthException catch (exception) {
    throw _fromAuth(exception);
  } on FunctionException catch (exception) {
    throw _fromFunction(exception);
  } catch (error) {
    throw UnexpectedFailure(
      'No se pudo completar la operación. Revisa tu conexión. ($error)',
    );
  }
}

/// Errores de la base de datos. Los códigos `P0001`, `P0002` y `42501` los
/// lanzan nuestras funciones SQL con mensajes ya escritos en español.
Failure _fromPostgrest(PostgrestException exception) {
  final message = exception.message;
  return switch (exception.code) {
    'P0001' => ValidationFailure(message),
    'P0002' => NotFoundFailure(message),
    'PGRST116' => const NotFoundFailure('No se encontró el registro.'),
    '42501' when message.startsWith('new row violates') =>
      const PermissionFailure('No tienes permiso para realizar esta acción.'),
    '42501' => PermissionFailure(message),
    '23505' => ValidationFailure(_duplicateMessage(exception)),
    '23514' => const ValidationFailure('Hay datos con un formato no válido.'),
    _ => ServerFailure('Error del servidor: $message'),
  };
}

String _duplicateMessage(PostgrestException exception) {
  final text = '${exception.message} ${exception.details}';
  if (text.contains('phone')) return 'Ya existe un cliente con ese teléfono.';
  if (text.contains('document_id')) return 'Ya existe un cliente con ese DPI.';
  if (text.contains('code')) return 'Ya existe una bicicleta con ese código.';
  if (text.contains('name')) return 'Ya existe una sucursal con ese nombre.';
  return 'Ya existe un registro con esos datos.';
}

Failure _fromAuth(AuthException exception) {
  final message = exception.message.toLowerCase();
  if (message.contains('invalid login credentials')) {
    return const AuthFailure('Correo o contraseña incorrectos.');
  }
  if (message.contains('email not confirmed')) {
    return const AuthFailure('Debes confirmar tu correo antes de ingresar.');
  }
  return AuthFailure(exception.message);
}

/// Errores de la Edge Function `create-employee`, que responde `{ "error": "..." }`.
Failure _fromFunction(FunctionException exception) {
  final details = exception.details;
  final message = details is Map && details['error'] != null
      ? details['error'].toString()
      : 'Error al llamar al servidor (${exception.status}).';
  return switch (exception.status) {
    400 || 409 => ValidationFailure(message),
    401 => AuthFailure(message),
    403 => PermissionFailure(message),
    _ => ServerFailure(message),
  };
}
