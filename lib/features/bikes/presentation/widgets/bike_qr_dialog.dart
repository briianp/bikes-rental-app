import 'package:bikes_app/features/bikes/domain/entities/bike.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Muestra el código QR de una bicicleta para imprimirlo o pegarlo en ella.
///
/// El QR contiene solo el código (`BK-001`), que es lo que lee el escáner.
Future<void> showBikeQrDialog(BuildContext context, Bike bike) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(bike.code, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              key: const Key('bike_qr_image'),
              data: bike.code,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(bike.name, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text(
            'Haz una captura de pantalla para imprimirlo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    ),
  );
}
