import 'package:flutter/material.dart';

/// Paleta de colores de la app. Úsala a través del tema siempre que sea posible.
abstract final class AppColors {
  // Fondos
  static const Color background = Color(0xFF2B2B2B);
  static const Color surface = Color(0xFF383838);
  static const Color surfaceHigh = Color(0xFF444444);

  // Marca
  static const Color primary = Color(0xFF6AA320);
  static const Color accent = Color(0xFF18B0BB);
  static const Color info = Color(0xFF38BDF8);

  // Texto
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Utilidades
  static const Color divider = Color(0xFF5F5F5F);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFACC15);
}
