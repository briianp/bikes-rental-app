enum RentalStatus { active, finished }

class Rental {
  const Rental({
    required this.id,
    required this.bikeId,
    required this.bikeCode,
    required this.bikeName,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.branchId,
    required this.branchName,
    required this.hourlyRate,
    required this.startedAt,
    required this.status,
    required this.employeeName,
    this.customerEmail,
    this.customerDocumentId,
    this.endedAt,
    this.totalPrice,
  });

  final String id;
  final String bikeId;
  final String bikeCode;
  final String bikeName;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? customerEmail;
  final String? customerDocumentId;
  final String branchId;
  final String branchName;

  /// Tarifa copiada al iniciar la renta.
  final double hourlyRate;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Total cobrado. Lo calcula el servidor al finalizar.
  final double? totalPrice;
  final RentalStatus status;
  final String employeeName;

  bool get isActive => status == RentalStatus.active;

  /// Tiempo transcurrido hasta [now] (o hasta que terminó la renta).
  Duration elapsed(DateTime now) => (endedAt ?? now).difference(startedAt);

  /// Regla de negocio: se cobra por hora iniciada, con un mínimo de 1 hora.
  ///
  /// 10 min → 1 h · 60 min → 1 h · 61 min → 2 h
  ///
  /// La misma regla está en la función SQL `finish_rental`; aquí se usa para
  /// mostrar el total estimado antes de finalizar.
  static int billableHours(Duration duration) {
    if (duration <= Duration.zero) return 1;
    final hours = (duration.inSeconds / Duration.secondsPerHour).ceil();
    return hours < 1 ? 1 : hours;
  }

  /// Total a cobrar si la renta termina en [endTime].
  double calculateTotal(DateTime endTime) =>
      billableHours(endTime.difference(startedAt)) * hourlyRate;
}
