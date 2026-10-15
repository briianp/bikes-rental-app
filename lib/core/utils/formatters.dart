/// Funciones de formato para mostrar datos en pantalla.
abstract final class Formatters {
  /// `25` → `Q25.00`
  static String currency(double amount) => 'Q${amount.toStringAsFixed(2)}';

  /// `14:05`
  static String time(DateTime date) =>
      '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

  /// `05/10/2026`
  static String date(DateTime date) =>
      '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';

  /// `05/10/2026 14:05`
  static String dateTime(DateTime date) => '${Formatters.date(date)} ${time(date)}';

  /// `45 min` o `1 h 05 min`
  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '$minutes min';
    return '$hours h ${_twoDigits(minutes)} min';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
