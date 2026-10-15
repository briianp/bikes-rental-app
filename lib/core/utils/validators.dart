/// Validaciones reutilizables. Devuelven `null` si el valor es válido o el
/// mensaje de error en caso contrario, que es el formato que espera
/// `TextFormField.validator`.
abstract final class Validators {
  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');
  static final RegExp _nonDigits = RegExp(r'\D');

  /// `"+502 5512-3456"` → `"50255123456"`
  static String digitsOnly(String? value) =>
      (value ?? '').replaceAll(_nonDigits, '');

  static String? requiredText(String? value, {String field = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$field es obligatorio';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa un correo';
    if (!_emailRegExp.hasMatch(value.trim())) return 'Correo no válido';
    return null;
  }

  /// Igual que [email], pero acepta el campo vacío.
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return email(value);
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa la contraseña';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  /// Acepta de 8 a 15 dígitos; ignora espacios, guiones y el signo `+`.
  static String? phone(String? value) {
    final digits = digitsOnly(value);
    if (digits.isEmpty) return 'Ingresa un teléfono';
    if (digits.length < 8 || digits.length > 15) return 'Teléfono no válido';
    return null;
  }

  /// DPI de Guatemala: 13 dígitos. El campo es opcional.
  static String? optionalDpi(String? value) {
    final digits = digitsOnly(value);
    if (digits.isEmpty) return null;
    if (digits.length != 13) return 'El DPI debe tener 13 dígitos';
    return null;
  }

  /// Número mayor que cero, por ejemplo una tarifa: `"25"`, `"25.50"`.
  static String? positiveNumber(String? value, {String field = 'El valor'}) {
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (number == null) return '$field debe ser un número';
    if (number <= 0) return '$field debe ser mayor que cero';
    return null;
  }
}
