import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/tarjeta_seccion.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/validaciones.dart';
import 'configuracion_providers.dart';
import 'vista_previa_app.dart';

/// Nombre comercial, logo y colores que ven los clientes en la app, con una
/// vista previa.
class PestanaMarca extends ConsumerStatefulWidget {
  const PestanaMarca({super.key});

  @override
  ConsumerState<PestanaMarca> createState() => _PestanaMarcaState();
}

class _PestanaMarcaState extends ConsumerState<PestanaMarca>
    with AutomaticKeepAliveClientMixin {
  // Conserva lo elegido al pasar a otra pestaña y volver.
  @override
  bool get wantKeepAlive => true;

  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _primario;
  late final TextEditingController _secundario;
  CambioLogo _logo = const MantenerLogo();
  String? _errorLogo;
  bool _revisar = false;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final tema =
        ref.read(membresiaActivaProvider)?.distribuidor?.configTema ??
        const ConfigTema();
    _nombre = TextEditingController(text: tema.nombre)..addListener(_alCambiar);
    _primario = TextEditingController(
      text: normalizarColor(tema.colorPrimario) ?? tema.colorPrimario,
    )..addListener(_alCambiar);
    _secundario = TextEditingController(
      text: normalizarColor(tema.colorSecundario) ?? tema.colorSecundario,
    )..addListener(_alCambiar);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _primario.dispose();
    _secundario.dispose();
    super.dispose();
  }

  void _alCambiar() => setState(() {});

  bool _hayCambios(ConfigTema tema) =>
      _nombre.text.trim() != tema.nombre ||
      normalizarColor(_primario.text) != normalizarColor(tema.colorPrimario) ||
      normalizarColor(_secundario.text) !=
          normalizarColor(tema.colorSecundario) ||
      _logo is! MantenerLogo;

  void _descartar(ConfigTema tema) {
    _nombre.text = tema.nombre;
    _primario.text = normalizarColor(tema.colorPrimario) ?? tema.colorPrimario;
    _secundario.text =
        normalizarColor(tema.colorSecundario) ?? tema.colorSecundario;
    setState(() {
      _logo = const MantenerLogo();
      _errorLogo = null;
      _revisar = false;
      _error = null;
    });
  }

  Future<void> _elegirLogo() async {
    try {
      final imagen = await ref.read(selectorImagenProvider).elegir();
      if (imagen == null || !mounted) return;
      final motivo = validarLogo(imagen.bytes);
      setState(() {
        _errorLogo = motivo;
        if (motivo == null) _logo = NuevoLogo(imagen.bytes);
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorLogo = 'No pudimos abrir el archivo. Inténtalo de nuevo.',
        );
      }
    }
  }

  Future<void> _guardar() async {
    setState(() => _revisar = true);
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final primario = normalizarColor(_primario.text)!;
    final secundario = normalizarColor(_secundario.text)!;
    final avisos = ScaffoldMessenger.maybeOf(context);
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(accionesConfiguracionProvider)
          .guardarMarca(
            nombreComercial: _nombre.text,
            colorPrimario: primario,
            colorSecundario: secundario,
            logo: _logo,
          );
      if (!mounted) return;
      _nombre.text = _nombre.text.trim();
      _primario.text = primario;
      _secundario.text = secundario;
      setState(() {
        _logo = const MantenerLogo();
        _revisar = false;
      });
      avisos?.showSnackBar(
        const SnackBar(
          content: Text('Guardamos tu marca. Tus clientes la verán en la app.'),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _error = mensajeDeConfiguracion(e));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final distribuidor = ref.watch(
      membresiaActivaProvider.select((m) => m?.distribuidor),
    );
    if (distribuidor == null) return const EstadoCarga();
    final tema = distribuidor.configTema;
    final cambios = _hayCambios(tema);
    final error = _error;

    // Lo que se ve en la vista previa: lo escrito si es válido; si no, lo
    // guardado.
    final primario =
        argbDe(_primario.text) ?? argbDe(tema.colorPrimario) ?? 0xFF1F3A5F;
    final secundario =
        argbDe(_secundario.text) ?? argbDe(tema.colorSecundario) ?? 0xFFF2A900;
    final nombreVisible = _nombre.text.trim().isEmpty
        ? distribuidor.nombre
        : _nombre.text.trim();
    final logo = switch (_logo) {
      NuevoLogo(:final bytes) => Image.memory(bytes, fit: BoxFit.contain),
      QuitarLogo() => null,
      MantenerLogo() => switch (tema.logoUrl) {
        final url? => Image.network(
          url,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.broken_image_outlined,
            color: ColoresPanel.neutro500,
          ),
        ),
        null => null,
      },
    };

    final formulario = Form(
      key: _formulario,
      autovalidateMode: _revisar
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TarjetaSeccion(
            titulo: 'Nombre comercial',
            descripcion: 'Es el nombre que ven tus clientes en la app.',
            child: TextFormField(
              controller: _nombre,
              enabled: !_guardando,
              textCapitalization: TextCapitalization.words,
              maxLength: largoMaximoNombre,
              decoration: InputDecoration(
                labelText: 'Nombre comercial (opcional)',
                hintText: distribuidor.nombre,
                helperText:
                    'Si lo dejas vacío, usamos "${distribuidor.nombre}".',
                counterText: '',
              ),
              validator: (v) => (v ?? '').trim().isEmpty
                  ? null
                  : validarNombre(v ?? '', que: 'el nombre comercial'),
            ),
          ),
          const SizedBox(height: 16),
          TarjetaSeccion(
            titulo: 'Logo',
            descripcion:
                'PNG, JPG o WebP de hasta 2 MB. Se ve mejor si es cuadrado '
                'y con fondo transparente o blanco.',
            child: _Logo(
              logo: logo,
              deshabilitado: _guardando,
              error: _errorLogo,
              alElegir: _elegirLogo,
              alQuitar: logo == null
                  ? null
                  : () => setState(() {
                      _errorLogo = null;
                      // Quitar un logo recién elegido vuelve al guardado.
                      _logo = _logo is NuevoLogo && tema.logoUrl == null
                          ? const MantenerLogo()
                          : const QuitarLogo();
                    }),
            ),
          ),
          const SizedBox(height: 16),
          TarjetaSeccion(
            titulo: 'Colores',
            descripcion: 'Elige uno de la lista o escribe su código.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SelectorColor(
                  etiqueta: 'Color principal',
                  ayuda: 'Barra superior y botones de la app.',
                  controller: _primario,
                  deshabilitado: _guardando,
                  avisarContraste: true,
                ),
                const SizedBox(height: 24),
                _SelectorColor(
                  etiqueta: 'Color secundario',
                  ayuda: 'Ofertas y detalles que destacan.',
                  controller: _secundario,
                  deshabilitado: _guardando,
                  avisarContraste: false,
                ),
              ],
            ),
          ),
          if (error != null) ...[const SizedBox(height: 16), CajaError(error)],
          const SizedBox(height: 20),
          Row(
            children: [
              FilledButton(
                onPressed: cambios && !_guardando ? _guardar : null,
                child: _guardando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambios'),
              ),
              if (cambios && !_guardando) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _descartar(tema),
                  child: const Text('Descartar'),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    final vista = VistaPreviaApp(
      nombre: nombreVisible,
      logo: logo,
      colorPrimario: Color(primario),
      colorSecundario: Color(secundario),
    );

    return LayoutBuilder(
      builder: (context, limites) {
        final amplia = limites.maxWidth >= 1000;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 20, bottom: 24),
          child: amplia
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 680),
                        child: formulario,
                      ),
                    ),
                    const SizedBox(width: 32),
                    vista,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [formulario, const SizedBox(height: 24), vista],
                ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({
    required this.logo,
    required this.deshabilitado,
    required this.error,
    required this.alElegir,
    required this.alQuitar,
  });

  final Widget? logo;
  final bool deshabilitado;
  final String? error;
  final VoidCallback alElegir;
  final VoidCallback? alQuitar;

  @override
  Widget build(BuildContext context) {
    final logo = this.logo;
    final error = this.error;
    final alQuitar = this.alQuitar;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Semantics(
              label: logo == null ? 'Sin logo' : 'Logo actual',
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: ColoresPanel.neutro50,
                  border: Border.all(color: ColoresPanel.neutro200),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(8),
                child:
                    logo ??
                    const Icon(
                      Icons.image_outlined,
                      size: 32,
                      color: ColoresPanel.neutro300,
                    ),
              ),
            ),
            const SizedBox(width: 20),
            Flexible(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: deshabilitado ? null : alElegir,
                    icon: const Icon(Icons.upload_rounded, size: 18),
                    label: Text(logo == null ? 'Subir logo' : 'Cambiar logo'),
                  ),
                  if (alQuitar != null)
                    TextButton(
                      onPressed: deshabilitado ? null : alQuitar,
                      child: const Text('Quitar logo'),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: const TextStyle(
                fontSize: 13,
                color: ColoresPanel.peligro500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SelectorColor extends StatelessWidget {
  const _SelectorColor({
    required this.etiqueta,
    required this.ayuda,
    required this.controller,
    required this.deshabilitado,
    required this.avisarContraste,
  });

  final String etiqueta;
  final String ayuda;
  final TextEditingController controller;
  final bool deshabilitado;

  /// Avisa si el texto blanco no se lee bien sobre el color elegido.
  final bool avisarContraste;

  @override
  Widget build(BuildContext context) {
    final elegido = normalizarColor(controller.text);
    final argb = argbDe(controller.text);
    final poco = avisarContraste && argb != null && !textoBlancoLegible(argb);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColoresPanel.neutro900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          ayuda,
          style: const TextStyle(fontSize: 13, color: ColoresPanel.neutro500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (nombre, hex) in coloresSugeridos)
              _Muestra(
                nombre: nombre,
                color: Color(argbDe(hex)!),
                elegida: elegido == hex,
                alTocar: deshabilitado ? null : () => controller.text = hex,
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 220,
          child: TextFormField(
            controller: controller,
            enabled: !deshabilitado,
            maxLength: 7,
            decoration: InputDecoration(
              labelText: 'Código del ${etiqueta.toLowerCase()}',
              hintText: '#1F3A5F',
              counterText: '',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: argb == null ? null : Color(argb),
                    border: Border.all(color: ColoresPanel.neutro300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            validator: (v) => validarColor(v ?? ''),
          ),
        ),
        if (poco) ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: ColoresPanel.aviso500,
              ),
              SizedBox(width: 6),
              Flexible(
                child: Text(
                  'El texto blanco no se lee bien sobre este color. Elige uno '
                  'más oscuro.',
                  style: TextStyle(fontSize: 13, color: ColoresPanel.neutro700),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Muestra extends StatelessWidget {
  const _Muestra({
    required this.nombre,
    required this.color,
    required this.elegida,
    required this.alTocar,
  });

  final String nombre;
  final Color color;
  final bool elegida;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: nombre,
      child: Semantics(
        button: true,
        selected: elegida,
        label: nombre,
        excludeSemantics: true,
        child: InkWell(
          onTap: alTocar,
          customBorder: const CircleBorder(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: elegida
                    ? ColoresPanel.neutro900
                    : ColoresPanel.neutro200,
                width: elegida ? 2.5 : 1,
              ),
            ),
            child: elegida
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Color(textoSobre(color.toARGB32())),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
