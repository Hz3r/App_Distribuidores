import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Se muestra si la persona inició sesión pero no tiene ninguna membresía
/// útil en la app móvil.
class SinRolScreen extends StatelessWidget {
  const SinRolScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sin distribuidor')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tu cuenta todavía no está vinculada a ningún distribuidor. '
                'Pídele a tu distribuidor un código de invitación.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Supabase.instance.client.auth.signOut(),
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
