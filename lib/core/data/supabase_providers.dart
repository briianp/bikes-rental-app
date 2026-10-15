import 'package:bikes_app/core/config/app_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// `true` si la app usa Supabase; `false` en modo demo.
///
/// Los `*_dependencies.dart` de cada feature lo leen para elegir qué
/// data source usar. En los tests se queda en `false`.
final useSupabaseProvider = Provider<bool>((ref) => AppConfig.useSupabase);

/// Cliente de Supabase ya inicializado en `main.dart`.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
