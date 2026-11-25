import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../../shared/tema_app.dart';
import '../../../shared/widgets/campo_etiquetado.dart';
import '../../registro/domain/cuentas_repositorio.dart';
import '../../registro/domain/datos_registro.dart';
import '../../registro/presentation/registro_providers.dart';

/// Ingreso con correo y contraseña de una cuenta existente. Con sesión, el
/// control de acceso (que canjea un registro pendiente si lo hay) y el
/// router se encargan de entrar.
class IngresoScreen extends ConsumerStatefulWidget {
  const IngresoScreen({super.key});

  @override
  ConsumerState<IngresoScreen> createState() => _IngresoScreenState();
}

class _IngresoScreenState extends ConsumerState<IngresoScreen> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();

  /// La contraseña solo vive en este campo y en la llamada a `ingresar`.
  final _contrasena = TextEditingController();

  var _validarAlEscribir = AutovalidateMode.disabled;
  var _verContrasena = false;

  /// Hay un ingreso en curso, o ya entró y el router está por cambiar de
  /// pantalla: el botón queda deshabilitado.
  var _enviando = false;

  /// Por qué falló el último intento; `null` si no falló.
  ResultadoIngreso? _fallo;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;
    final mensaje = switch (_fallo) {
      null || ResultadoIngreso.ok => null,
      ResultadoIngreso.credencialesIncorrectas =>
        'Correo o contraseña incorrectos.',
      ResultadoIngreso.correoSinConfirmar =>
        'Confirma tu correo antes de ingresar.',
      ResultadoIngreso.sinConexion =>
        'Revisa tu conexión e inténtalo de nuevo.',
      ResultadoIngreso.error => 'No pudimos ingresar. Inténtalo de nuevo.',
    };

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formulario,
          autovalidateMode: _validarAlEscribir,
          child: AutofillGroup(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton.outlined(
                      tooltip: 'Volver',
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: ColoresApp.borde),
                      ),
                      onPressed: () => _volver(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: ColoresApp.azulSuave,
                        borderRadius: BorderRadius.circular(radioApp),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: ColoresApp.azul,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Ingresa a tu cuenta', style: textos.headlineMedium),
                  const SizedBox(height: 24),
                  CampoEtiquetado(
                    etiqueta: 'Correo',
                    controller: _correo,
                    pista: 'nombre@correo.com',
                    teclado: TextInputType.emailAddress,
                    autocompletar: const [AutofillHints.email],
                    validator: (v) => validarCorreo(v ?? ''),
                  ),
                  const SizedBox(height: 16),
                  CampoEtiquetado(
                    etiqueta: 'Contraseña',
                    controller: _contrasena,
                    ocultarTexto: !_verContrasena,
                    teclado: TextInputType.visiblePassword,
                    accion: TextInputAction.done,
                    autocompletar: const [AutofillHints.password],
                    onSubmitted: (_) => _ingresar(),
                    // Solo que no esté vacía: las cuentas creadas en el panel
                    // pueden tener otras reglas de contraseña.
                    validator: (v) =>
                        (v ?? '').isEmpty ? 'Escribe tu contraseña.' : null,
                    sufijo: IconButton(
                      tooltip: _verContrasena
                          ? 'Ocultar contraseña'
                          : 'Mostrar contraseña',
                      onPressed: () =>
                          setState(() => _verContrasena = !_verContrasena),
                      icon: Icon(
                        _verContrasena
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // `liveRegion`: el lector de pantalla anuncia el mensaje.
                  Semantics(
                    liveRegion: true,
                    child: mensaje == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              mensaje,
                              style: textos.bodyMedium?.copyWith(
                                color: ColoresApp.error,
                              ),
                            ),
                          ),
                  ),
                  FilledButton(
                    onPressed: _enviando ? null : _ingresar,
                    child: const Text('Ingresar'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.push(AppRutas.codigo),
                    child: const Text('Tengo un código de invitación'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Vuelve a la pantalla anterior; si se llegó directo, a la bienvenida.
  void _volver(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRutas.bienvenida);
    }
  }

  Future<void> _ingresar() async {
    if (_enviando) return;
    final valido = _formulario.currentState!.validate();
    setState(() {
      _validarAlEscribir = AutovalidateMode.onUserInteraction;
      _fallo = null;
    });
    if (!valido) return;

    setState(() => _enviando = true);
    final resultado = await ref
        .read(cuentasRepositorioProvider)
        .ingresar(_correo.text.trim(), _contrasena.text);
    if (!mounted) return;

    // Con sesión el router sale de esta pantalla: el botón sigue
    // deshabilitado mientras tanto.
    if (resultado == ResultadoIngreso.ok) return;
    setState(() {
      _enviando = false;
      _fallo = resultado;
    });
  }
}
