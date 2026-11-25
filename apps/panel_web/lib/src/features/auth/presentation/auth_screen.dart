import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/widgets/tarjeta_centrada.dart';
import '../../sesion/domain/autenticacion.dart';
import '../../sesion/presentation/control_acceso.dart';

/// Ingreso al panel con correo y contraseña. Al iniciar sesión, el router
/// lleva a la sección que corresponda.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();

  bool _enviando = false;
  bool _verContrasena = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (_enviando) return;
    if (!(_formulario.currentState?.validate() ?? false)) return;

    setState(() {
      _enviando = true;
      _error = null;
    });
    final resultado = await ref
        .read(autenticacionProvider)
        .iniciarSesion(
          correo: _correo.text.trim(),
          contrasena: _contrasena.text,
        );
    if (!mounted) return;

    setState(() {
      _enviando = false;
      _error = switch (resultado) {
        ResultadoIngreso.ok => null,
        ResultadoIngreso.credencialesInvalidas =>
          'Correo o contraseña incorrectos.',
        ResultadoIngreso.fallo =>
          'No pudimos iniciar sesión. Revisa tu conexión e inténtalo de nuevo.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final error = _error;

    return TarjetaCentrada(
      child: Form(
        key: _formulario,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColoresPanel.acento500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: ColoresPanel.blanco,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Panel del distribuidor',
                style: tema.textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Ingresa con el correo y la contraseña de tu negocio.',
                style: tema.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              const _Etiqueta('Correo'),
              TextFormField(
                controller: _correo,
                enabled: !_enviando,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                decoration: const InputDecoration(
                  hintText: 'nombre@tunegocio.com',
                ),
                validator: (valor) {
                  final texto = valor?.trim() ?? '';
                  if (texto.isEmpty) return 'Escribe tu correo.';
                  if (!texto.contains('@')) {
                    return 'Revisa el correo: le falta la @.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const _Etiqueta('Contraseña'),
              TextFormField(
                controller: _contrasena,
                enabled: !_enviando,
                obscureText: !_verContrasena,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _ingresar(),
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    tooltip: _verContrasena
                        ? 'Ocultar contraseña'
                        : 'Mostrar contraseña',
                    icon: Icon(
                      _verContrasena
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _verContrasena = !_verContrasena),
                  ),
                ),
                validator: (valor) => (valor == null || valor.isEmpty)
                    ? 'Escribe tu contraseña.'
                    : null,
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColoresPanel.peligro100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      error,
                      style: tema.textTheme.bodyMedium?.copyWith(
                        color: ColoresPanel.peligro500,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _enviando ? null : _ingresar,
                child: _enviando
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Ingresar'),
              ),
              const SizedBox(height: 16),
              Text(
                'El acceso lo crea el equipo de la plataforma al activar tu '
                'plan.',
                textAlign: TextAlign.center,
                style: tema.textTheme.bodySmall?.copyWith(
                  color: ColoresPanel.neutro500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: ColoresPanel.neutro700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
