import 'package:bikes_app/app/app.dart';
import 'package:bikes_app/core/config/app_config.dart';
import 'package:bikes_app/features/auth/presentation/providers/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Con `--dart-define-from-file=env.json` se usa Supabase;
  // sin credenciales la app arranca en modo demo.
  if (AppConfig.useSupabase) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabasePublishableKey,
    );
  }

  // El contenedor guarda el estado de todos los providers. Lo creamos aquí
  // para recuperar la sesión guardada antes de mostrar la primera pantalla.
  final container = ProviderContainer(retry: noRetry);
  await container.read(sessionProvider.notifier).restore();

  runApp(
    UncontrolledProviderScope(container: container, child: const BikesApp()),
  );
}

/// Riverpod 3 reintenta automáticamente los providers que fallan.
/// Aquí lo desactivamos: los errores se muestran con un botón "Reintentar".
Duration? noRetry(int retryCount, Object error) => null;
