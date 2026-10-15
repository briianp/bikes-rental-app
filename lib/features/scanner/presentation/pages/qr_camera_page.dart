import 'dart:async';

import 'package:bikes_app/app/router/app_routes.dart';
import 'package:bikes_app/core/theme/app_colors.dart';
import 'package:bikes_app/features/bikes/domain/usecases/get_bike_by_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

/// Cámara a pantalla completa. Al leer un QR abre el formulario de renta.
class QrCameraPage extends StatefulWidget {
  const QrCameraPage({super.key});

  @override
  State<QrCameraPage> createState() => _QrCameraPageState();
}

class _QrCameraPageState extends State<QrCameraPage> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  StreamSubscription<Barcode>? _subscription;

  /// Evita abrir el formulario varias veces: la cámara emite el mismo
  /// código muchas veces por segundo.
  bool _handled = false;

  // Recomendación del paquete: reiniciar la cámara tras un hot reload.
  @override
  void reassemble() {
    super.reassemble();
    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  void _onQrViewCreated(QRViewController controller) {
    _controller = controller;
    _subscription = controller.scannedDataStream.listen((barcode) {
      final rawCode = barcode.code;
      if (_handled || !mounted || rawCode == null) return;

      final code = normalizeBikeCode(rawCode);
      if (code.isEmpty) return;

      _handled = true;
      controller.pauseCamera();
      // Reemplaza la cámara por el formulario: al volver atrás no se
      // regresa a la cámara, sino a la pestaña "Escanear".
      context.pushReplacement(AppRoutes.bikeAction(code));
    });
  }

  @override
  void dispose() {
    // El QRViewController se libera solo cuando QRView se desmonta;
    // solo cancelamos nuestra suscripción al stream.
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cutOutSize = MediaQuery.sizeOf(context).shortestSide * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear QR'),
        actions: [
          IconButton(
            tooltip: 'Linterna',
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _controller?.toggleFlash(),
          ),
        ],
      ),
      body: Stack(
        children: [
          QRView(
            key: _qrKey,
            onQRViewCreated: _onQrViewCreated,
            overlay: QrScannerOverlayShape(
              overlayColor: Colors.black.withValues(alpha: 0.6),
              borderColor: AppColors.primary,
              borderRadius: 12,
              borderLength: 32,
              borderWidth: 8,
              cutOutSize: cutOutSize,
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Text(
              'Apunta al código QR de la bicicleta',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
