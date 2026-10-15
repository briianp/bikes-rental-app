import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:flutter/material.dart';

/// Textos y colores de cada estado. Viven en presentación porque el
/// dominio no debe saber cómo se muestra la información.
extension BikeStatusUi on BikeStatus {
  String get label => switch (this) {
    BikeStatus.available => 'Disponible',
    BikeStatus.rented => 'En renta',
    BikeStatus.maintenance => 'Mantenimiento',
  };

  Color get color => switch (this) {
    BikeStatus.available => AppColors.primary,
    BikeStatus.rented => AppColors.accent,
    BikeStatus.maintenance => AppColors.warning,
  };
}
