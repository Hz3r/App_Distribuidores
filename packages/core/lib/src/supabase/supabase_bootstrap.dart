import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_env.dart';

/// Inicializa el cliente de Supabase con la publishable key del entorno.
///
/// Lanza [StateError] si el entorno no está configurado, para fallar con un
/// mensaje claro en vez de un error críptico de red.
Future<void> inicializarSupabase() async {
  if (!AppEnv.estaConfigurado) {
    throw StateError(
      'Falta configuración de Supabase. Compila con '
      '--dart-define-from-file=env/dev.json (ver README).',
    );
  }
  await Supabase.initialize(
    url: AppEnv.supabaseUrl,
    publishableKey: AppEnv.supabasePublishableKey,
  );
}

/// Atajo al cliente ya inicializado.
SupabaseClient get supabase => Supabase.instance.client;
