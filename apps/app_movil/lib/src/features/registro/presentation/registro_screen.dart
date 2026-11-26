import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/rutas.dart';
import '../../../shared/tema_app.dart';
import '../../../shared/widgets/campo_etiquetado.dart';
import '../domain/argumentos_registro.dart';
import '../domain/codigo_por_canjear.dart';
import '../domain/cuentas_repositorio.dart';
import '../domain/datos_registro.dart';
import '../domain/registro_pendiente.dart';
import 'registro_providers.dart';

/// Registro de la cuenta con el código ya validado. Los datos de la bodega
/// llegan como los cargó el distribuidor: el nombre no se cambia y el RUC o
/// DNI solo se completa si venía vacío.
///
/// Al crear la cuenta, el código y los datos quedan guardados en ella como
/// registro pendiente; el control de acceso los usa en cuanto hay sesión.
class RegistroScreen extends ConsumerStatefulWidget {
  const RegistroScreen({required this.argumentos, super.key});

  final ArgumentosRegistro argumentos;

  @override
  ConsumerState<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends ConsumerState<RegistroScreen> {
  final _formulario = GlobalKey<FormState>();
  final _negocio = TextEditingController();
  final _documento = TextEditingController();
  final _encargado = TextEditingController();
  final _celular = TextEditingController();
  final _direccion = TextEditingController();
  final _correo = TextEditingController();

  /// La contraseña solo vive en este campo y en la llamada a `crearCuenta`.
  final _contrasena = TextEditingController();

  late final bool _documentoEditable;
  var _validarAlEscribir = AutovalidateMode.disabled;
  var _aceptaTerminos = false;
  var _faltaAceptar = false;
  var _verContrasena = false;

  /// Hay una creación en curso, o ya terminó con sesión y el router está
  /// por cambiar de pantalla: el botón queda deshabilitado.
  var _enviando = false;

  /// Por qué falló el último intento; `null` si no falló.
  ResultadoCrearCuenta? _fallo;

  @override
  void initState() {
    super.initState();
    final negocio = widget.argumentos.invitacion.negocio;
    _negocio.text = negocio?.nombreNegocio ?? '';
    _documento.text = negocio?.documento?.trim() ?? '';
    _documentoEditable = _documento.text.isEmpty;
    // Un teléfono que no es celular (un fijo, por ejemplo) llega vacío: la
    // persona no tiene que corregir un dato que no escribió para registrarse.
    final telefono = negocio?.telefono ?? '';
    _celular.text = normalizarTelefono(telefono) != null ? telefono : '';
    _direccion.text = negocio?.direccion ?? '';
  }

  @override
  void dispose() {
    for (final c in [
      _negocio,
      _documento,
      _encargado,
      _celular,
      _direccion,
      _correo,
      _contrasena,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invitacion = widget.argumentos.invitacion;
    final esBodega = invitacion.negocio != null;
    final textos = Theme.of(context).textTheme;

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
                  _Encabezado(onVolver: () => _volver(context)),
                  const SizedBox(height: 20),
                  _TarjetaDistribuidor(nombre: invitacion.distribuidorNombre),
                  const SizedBox(height: 24),
                  if (esBodega) ...[
                    CampoEtiquetado(
                      etiqueta: 'Nombre del negocio',
                      controller: _negocio,
                      soloLectura: true,
                    ),
                    const SizedBox(height: 16),
                    CampoEtiquetado(
                      etiqueta: 'RUC o DNI',
                      controller: _documento,
                      soloLectura: !_documentoEditable,
                      pista: '20601234567',
                      teclado: TextInputType.number,
                      validator: _documentoEditable
                          ? (v) => validarDocumento(v ?? '')
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],
                  CampoEtiquetado(
                    etiqueta: esBodega ? 'Nombre del encargado' : 'Tu nombre',
                    controller: _encargado,
                    pista: 'José Ramírez',
                    teclado: TextInputType.name,
                    mayusculas: TextCapitalization.words,
                    autocompletar: const [AutofillHints.name],
                    validator: (v) => validarNombre(v ?? ''),
                  ),
                  if (esBodega) ...[
                    const SizedBox(height: 16),
                    CampoEtiquetado(
                      etiqueta: 'Celular',
                      controller: _celular,
                      pista: '+51 987 654 321',
                      teclado: TextInputType.phone,
                      autocompletar: const [AutofillHints.telephoneNumber],
                      validator: (v) => validarTelefono(v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    CampoEtiquetado(
                      etiqueta: 'Dirección de entrega',
                      controller: _direccion,
                      pista: 'Av. Los Olivos 123, Comas',
                      teclado: TextInputType.streetAddress,
                      mayusculas: TextCapitalization.sentences,
                      autocompletar: const [AutofillHints.fullStreetAddress],
                      validator: (v) => validarDireccion(v ?? ''),
                    ),
                  ],
                  const SizedBox(height: 16),
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
                    pista: 'Al menos 8 caracteres',
                    ocultarTexto: !_verContrasena,
                    teclado: TextInputType.visiblePassword,
                    accion: TextInputAction.done,
                    autocompletar: const [AutofillHints.newPassword],
                    validator: (v) => validarContrasena(v ?? ''),
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
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _aceptaTerminos,
                    onChanged: (v) => setState(() {
                      _aceptaTerminos = v ?? false;
                      if (_aceptaTerminos) _faltaAceptar = false;
                    }),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Acepto términos y política de privacidad',
                      style: textos.bodyMedium,
                    ),
                  ),
                  if (_faltaAceptar)
                    Text(
                      'Acepta los términos y la política de privacidad.',
                      style: textos.bodySmall?.copyWith(
                        color: ColoresApp.error,
                      ),
                    ),
                  const SizedBox(height: 16),
                  _Fallo(
                    fallo: _fallo,
                    // El código viaja al ingreso para canjearlo en cuanto
                    // haya sesión. La contraseña no.
                    onIngresar: () => context.push(
                      AppRutas.auth,
                      extra: CodigoPorCanjear(
                        codigo: widget.argumentos.codigo,
                        distribuidorId:
                            widget.argumentos.invitacion.distribuidorId,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _enviando ? null : _crear,
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Vuelve a la pantalla de código; si se llegó directo, a la bienvenida.
  void _volver(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRutas.bienvenida);
    }
  }

  Future<void> _crear() async {
    if (_enviando) return;
    final valido = _formulario.currentState!.validate();
    setState(() {
      _validarAlEscribir = AutovalidateMode.onUserInteraction;
      _faltaAceptar = !_aceptaTerminos;
      _fallo = null;
    });
    if (!valido || !_aceptaTerminos) return;

    setState(() => _enviando = true);
    final invitacion = widget.argumentos.invitacion;
    final negocio = invitacion.negocio;
    final datos = DatosRegistro(
      nombreEncargado: _encargado.text.trim(),
      correo: _correo.text.trim(),
      contrasena: _contrasena.text,
      // Sin bodega (personal) no hay datos que completar.
      documento: negocio != null && _documentoEditable
          ? _opcional(_documento.text)
          : null,
      // Ya validado: 9 dígitos, sin prefijo ni separadores.
      telefono: negocio != null ? normalizarTelefono(_celular.text) : null,
      direccion: negocio != null ? _opcional(_direccion.text) : null,
      // No está en el formulario: `null` deja la del distribuidor sin
      // cambios. Reenviarla haría fallar todo el guardado si pasa del límite.
      referencia: null,
    );
    final pendiente = RegistroPendiente(
      codigo: widget.argumentos.codigo,
      distribuidorId: invitacion.distribuidorId,
      documento: datos.documento,
      direccion: datos.direccion,
      referencia: datos.referencia,
      telefono: datos.telefono,
    );

    final resultado = await ref
        .read(cuentasRepositorioProvider)
        .crearCuenta(datos, pendiente);
    if (!mounted) return;

    switch (resultado) {
      case ResultadoCrearCuenta.conSesion:
        // El control de acceso canjea el pendiente y el router sale de esta
        // pantalla. El botón sigue deshabilitado mientras tanto.
        return;
      case ResultadoCrearCuenta.requiereConfirmarCorreo:
        context.go(AppRutas.revisaCorreo, extra: datos.correo);
      case ResultadoCrearCuenta.correoYaRegistrado:
      case ResultadoCrearCuenta.contrasenaDebil:
      case ResultadoCrearCuenta.sinConexion:
      case ResultadoCrearCuenta.error:
        setState(() {
          _enviando = false;
          _fallo = resultado;
        });
    }
  }

  static String? _opcional(String texto) {
    final limpio = texto.trim();
    return limpio.isEmpty ? null : limpio;
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.onVolver});

  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.outlined(
          tooltip: 'Volver',
          style: IconButton.styleFrom(
            side: const BorderSide(color: ColoresApp.borde),
          ),
          onPressed: onVolver,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Crea tu cuenta',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

/// "Te unes a" y el nombre del distribuidor.
class _TarjetaDistribuidor extends StatelessWidget {
  const _TarjetaDistribuidor({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    final textos = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.azulSuave,
        borderRadius: BorderRadius.circular(radioApp),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ColoresApp.turquesa,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.storefront_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Te unes a',
                  style: textos.bodySmall?.copyWith(
                    color: ColoresApp.textoSuave,
                  ),
                ),
                Text(
                  nombre,
                  style: textos.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mensaje del último intento fallido. Con el correo ya registrado ofrece
/// ir a ingresar.
class _Fallo extends StatelessWidget {
  const _Fallo({required this.fallo, required this.onIngresar});

  final ResultadoCrearCuenta? fallo;
  final VoidCallback onIngresar;

  @override
  Widget build(BuildContext context) {
    final mensaje = switch (fallo) {
      null ||
      ResultadoCrearCuenta.conSesion ||
      ResultadoCrearCuenta.requiereConfirmarCorreo => null,
      ResultadoCrearCuenta.correoYaRegistrado =>
        'Ya existe una cuenta con este correo.',
      ResultadoCrearCuenta.contrasenaDebil =>
        'Elige una contraseña más segura.',
      ResultadoCrearCuenta.sinConexion =>
        'Revisa tu conexión e inténtalo de nuevo.',
      ResultadoCrearCuenta.error =>
        'No pudimos crear tu cuenta. Inténtalo de nuevo.',
    };

    // `liveRegion`: el lector de pantalla anuncia el mensaje al llegar.
    return Semantics(
      liveRegion: true,
      child: mensaje == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      mensaje,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: ColoresApp.error),
                    ),
                  ),
                  if (fallo == ResultadoCrearCuenta.correoYaRegistrado)
                    TextButton(
                      onPressed: onIngresar,
                      child: const Text('Ingresar'),
                    ),
                ],
              ),
            ),
    );
  }
}
