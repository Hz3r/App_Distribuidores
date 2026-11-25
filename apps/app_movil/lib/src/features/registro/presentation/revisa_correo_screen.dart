import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../../shared/tema_app.dart';

/// Se muestra tras crear la cuenta si Supabase exige confirmar el correo. El
/// código queda guardado en la cuenta: se canjea al ingresar.
class RevisaCorreoScreen extends StatelessWidget {
  const RevisaCorreoScreen({required this.correo, super.key});

  /// Correo al que se envió el enlace; `null` si se llegó sin él.
  final String? correo;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ColoresApp.azulSuave,
                        borderRadius: BorderRadius.circular(radioApp),
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_outlined,
                        color: ColoresApp.azul,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Revisa tu correo', style: textos.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Te enviamos un enlace a ${correo ?? 'tu correo'}. '
                      'Ábrelo para confirmar tu cuenta y luego ingresa.',
                      style: textos.bodyLarge?.copyWith(
                        color: ColoresApp.textoSuave,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => context.go(AppRutas.auth),
                      child: const Text('Ir a ingresar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
