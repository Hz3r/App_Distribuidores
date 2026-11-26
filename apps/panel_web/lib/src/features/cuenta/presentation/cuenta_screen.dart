import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/textos.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/pagina_panel.dart';
import '../../../shared/widgets/tarjeta_seccion.dart';
import '../../configuracion/domain/validaciones.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/cuenta_repositorio.dart';
import 'cuenta_providers.dart';

/// Datos de la persona con sesión: su nombre, su correo y su contraseña.
/// Entran el admin y el vendedor.
class CuentaScreen extends StatelessWidget {
  const CuentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PaginaPanel(
      titulo: 'Mi cuenta',
      descripcion: 'Tus datos para entrar al panel.',
      child: ContenidoAjustes(
        anchoMaximo: 640,
        children: [_TusDatos(), _Contrasena()],
      ),
    );
  }
}

class _TusDatos extends ConsumerStatefulWidget {
  const _TusDatos();

  @override
  ConsumerState<_TusDatos> createState() => _TusDatosState();
}

class _TusDatosState extends ConsumerState<_TusDatos> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();

  /// Nombre guardado con el que se llenó el campo; null hasta leerlo.
  String? _cargado;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final avisos = ScaffoldMessenger.maybeOf(context);
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref.read(accionesCuentaProvider).guardarNombre(_nombre.text);
      if (!mounted) return;
      avisos?.showSnackBar(
        const SnackBar(content: Text('Guardamos tu nombre.')),
      );
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeCuenta(e));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final consulta = ref.watch(perfilProvider);
    final membresia = ref.watch(membresiaActivaProvider);
    final correo = ref.watch(autenticacionProvider).correoActual;
    final perfil = consulta.value;

    // Llena el campo la primera vez y cada vez que el nombre guardado
    // cambia (por ejemplo, después de guardar).
    if (perfil != null && perfil.nombre != _cargado) {
      _cargado = perfil.nombre;
      _nombre.text = perfil.nombre;
    }

    final Widget contenido;
    if (perfil == null) {
      contenido = consulta.hasError
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CajaError('No pudimos cargar tus datos.'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(perfilProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            )
          : const SizedBox(height: 120, child: EstadoCarga());
    } else {
      final cambios = _nombre.text.trim() != perfil.nombre;
      final error = _error;
      final telefono = perfil.telefono;
      contenido = Form(
        key: _formulario,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nombre,
              enabled: !_guardando,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              maxLength: largoMaximoNombre,
              autofillHints: const [AutofillHints.name],
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                hintText: 'Ana Torres',
                counterText: '',
              ),
              validator: (v) => validarNombre(v ?? '', que: 'tu nombre'),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              CajaError(error),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: cambios && !_guardando ? _guardar : null,
                child: _guardando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar nombre'),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 40,
              runSpacing: 16,
              children: [
                DatoFijo(etiqueta: 'Correo', valor: correo ?? 'Sin correo'),
                if (telefono != null)
                  DatoFijo(etiqueta: 'Teléfono', valor: telefono),
                if (membresia != null)
                  DatoFijo(
                    etiqueta:
                        'Tu rol en '
                        '${membresia.distribuidor?.nombreVisible ?? 'este distribuidor'}',
                    valor: rolLegible(membresia.rol),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Para cambiar tu correo, escríbenos.',
              style: TextStyle(fontSize: 13, color: ColoresPanel.neutro500),
            ),
          ],
        ),
      );
    }

    return TarjetaSeccion(titulo: 'Tus datos', child: contenido);
  }
}

class _Contrasena extends ConsumerStatefulWidget {
  const _Contrasena();

  @override
  ConsumerState<_Contrasena> createState() => _ContrasenaState();
}

class _ContrasenaState extends ConsumerState<_Contrasena> {
  final _formulario = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _repetida = TextEditingController();
  bool _ver = false;
  bool _revisar = false;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _repetida.dispose();
    super.dispose();
  }

  Future<void> _cambiar() async {
    setState(() => _revisar = true);
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final avisos = ScaffoldMessenger.maybeOf(context);
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(accionesCuentaProvider)
          .cambiarContrasena(actual: _actual.text, nueva: _nueva.text);
      if (!mounted) return;
      _actual.clear();
      _nueva.clear();
      _repetida.clear();
      setState(() => _revisar = false);
      avisos?.showSnackBar(
        const SnackBar(content: Text('Cambiamos tu contraseña.')),
      );
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeCuenta(e));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    Widget campo({
      required TextEditingController controller,
      required String etiqueta,
      required String? Function(String) validar,
      required Iterable<String> pistas,
      String? ayuda,
      bool ultimo = false,
    }) {
      return TextFormField(
        controller: controller,
        enabled: !_guardando,
        obscureText: !_ver,
        enableSuggestions: false,
        autocorrect: false,
        autofillHints: pistas,
        textInputAction: ultimo ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: ultimo ? (_) => _cambiar() : null,
        decoration: InputDecoration(labelText: etiqueta, helperText: ayuda),
        validator: (v) => validar(v ?? ''),
      );
    }

    return TarjetaSeccion(
      titulo: 'Contraseña',
      descripcion: 'Para cambiarla, primero escribe la que usas ahora.',
      child: AutofillGroup(
        child: Form(
          key: _formulario,
          autovalidateMode: _revisar
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              campo(
                controller: _actual,
                etiqueta: 'Contraseña actual',
                pistas: const [AutofillHints.password],
                validar: (v) =>
                    v.isEmpty ? 'Escribe tu contraseña actual.' : null,
              ),
              const SizedBox(height: 16),
              campo(
                controller: _nueva,
                etiqueta: 'Contraseña nueva',
                ayuda:
                    'Al menos $largoMinimoContrasena caracteres, con letras y '
                    'números.',
                pistas: const [AutofillHints.newPassword],
                validar: (v) =>
                    validarContrasenaNueva(v) ??
                    (v == _actual.text
                        ? 'Debe ser distinta de la actual.'
                        : null),
              ),
              const SizedBox(height: 16),
              campo(
                controller: _repetida,
                etiqueta: 'Repite la contraseña nueva',
                pistas: const [AutofillHints.newPassword],
                ultimo: true,
                validar: (v) => v.isEmpty
                    ? 'Repite la contraseña nueva.'
                    : v != _nueva.text
                    ? 'No coincide con la contraseña nueva.'
                    : null,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _ver = !_ver),
                  icon: Icon(
                    _ver
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  label: Text(
                    _ver ? 'Ocultar contraseñas' : 'Mostrar contraseñas',
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                CajaError(error),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: _guardando ? null : _cambiar,
                  child: _guardando
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cambiar contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
