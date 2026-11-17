import 'package:material_ui/material_ui.dart';

/// Pantalla de error cuando no se compiló con las claves de Supabase.
/// Evita un crash silencioso: indica exactamente qué falta.
class PantallaConfigFaltante extends StatelessWidget {
  const PantallaConfigFaltante({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Falta la configuración de Supabase.\n\n'
              'Ejecuta la app con:\n'
              '--dart-define-from-file=env/dev.json\n\n'
              'Crea env/dev.json a partir de env/dev.example.json (ver README).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
