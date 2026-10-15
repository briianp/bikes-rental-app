/// Configuración que llega al compilar con `--dart-define-from-file=env.json`.
///
/// Si no se define nada, la app arranca en **modo demo** con datos en
/// memoria. Así cualquiera puede clonar el repositorio y probarla sin
/// credenciales.
abstract final class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// `true` cuando hay credenciales de Supabase.
  static bool get useSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
