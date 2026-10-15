import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/config/app_config.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/core/widgets/primary_button.dart';
import 'package:bikes_app/core/widgets/responsive_center.dart';
import 'package:bikes_app/features/scanner/presentation/widgets/manual_code_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pestaña "Escanear": abre la cámara o permite escribir el código.
///
/// La cámara vive en otra ruta (`/scan/camera`) para que solo esté encendida
/// mientras esa pantalla está abierta, y no en segundo plano al cambiar de
/// pestaña.
class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  /// El paquete de QR solo tiene soporte completo en Android e iOS.
  static bool get isCameraSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear')),
      body: ResponsiveCenter(
        maxWidth: 480,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Icon(
              Icons.qr_code_scanner_rounded,
              size: 96,
              color: AppColors.accent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Escanea el QR de la bicicleta: si está libre inicias la renta y si está rentada la finalizas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Abrir cámara',
              icon: Icons.photo_camera_outlined,
              onPressed: isCameraSupported
                  ? () => context.push(AppRoutes.scannerCamera)
                  : null,
            ),
            if (!isCameraSupported) ...[
              const SizedBox(height: 8),
              const Text(
                'La cámara solo está disponible en Android e iOS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
            const SizedBox(height: 32),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'o escribe el código',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            ManualCodeForm(
              onSubmit: (code) => context.push(AppRoutes.bikeAction(code)),
            ),
            if (!AppConfig.useSupabase) ...[
              const SizedBox(height: 16),
              const Text(
                'Demo: BK-001 y BK-003 están libres; BK-002 está en renta.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
