/// Configuración de entorno, inyectada en compilación con
/// `--dart-define-from-file=env/dev.json` (o prod.json).
///
/// Nunca usar aquí la secret key (sb_secret_...): solo la publishable key.
abstract final class AppEnv {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// `true` si el entorno trae URL y clave. Sin esto no se puede iniciar Supabase.
  static bool get estaConfigurado =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
