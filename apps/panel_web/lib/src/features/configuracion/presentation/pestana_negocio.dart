import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/textos.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/etiqueta.dart';
import '../../../shared/widgets/tarjeta_seccion.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/configuracion_repositorio.dart';
import '../domain/validaciones.dart';
import 'configuracion_providers.dart';

/// Nombre legal y teléfono (editables) y los datos que solo cambia la
/// plataforma.
class PestanaNegocio extends ConsumerStatefulWidget {
  const PestanaNegocio({super.key});

  @override
  ConsumerState<PestanaNegocio> createState() => _PestanaNegocioState();
}

class _PestanaNegocioState extends ConsumerState<PestanaNegocio>
    with AutomaticKeepAliveClientMixin {
  // Conserva lo escrito al pasar a otra pestaña y volver.
  @override
  bool get wantKeepAlive => true;

  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  bool _revisar = false;
  bool _guardando = false;
  String? _error;

  Distribuidor? get _distribuidor =>
      ref.read(membresiaActivaProvider)?.distribuidor;

  @override
  void initState() {
    super.initState();
    final distribuidor = _distribuidor;
    _nombre = TextEditingController(text: distribuidor?.nombre ?? '')
      ..addListener(_alCambiar);
    _telefono = TextEditingController(text: distribuidor?.telefono ?? '')
      ..addListener(_alCambiar);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    super.dispose();
  }

  void _alCambiar() => setState(() {});

  bool _hayCambios(Distribuidor distribuidor) =>
      _nombre.text.trim() != distribuidor.nombre ||
      _telefono.text.trim() != (distribuidor.telefono ?? '');

  void _descartar(Distribuidor distribuidor) {
    _nombre.text = distribuidor.nombre;
    _telefono.text = distribuidor.telefono ?? '';
    setState(() {
      _revisar = false;
      _error = null;
    });
  }

  Future<void> _guardar() async {
    setState(() => _revisar = true);
    if (!(_formulario.currentState?.validate() ?? false)) return;
    final avisos = ScaffoldMessenger.maybeOf(context);
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(accionesConfiguracionProvider)
          .guardarNegocio(
            DatosNegocio(
              nombre: _nombre.text.trim(),
              telefono: _telefono.text.trim(),
            ),
          );
      if (!mounted) return;
      setState(() => _revisar = false);
      avisos?.showSnackBar(
        const SnackBar(content: Text('Guardamos los datos del negocio.')),
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
    final cambios = _hayCambios(distribuidor);
    final error = _error;

    return ContenidoAjustes(
      children: [
        TarjetaSeccion(
          titulo: 'Datos del negocio',
          descripcion:
              'El nombre legal sale en las guías de pedido. El nombre que ven '
              'tus clientes se cambia en Marca.',
          child: Form(
            key: _formulario,
            autovalidateMode: _revisar
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nombre,
                  enabled: !_guardando,
                  textCapitalization: TextCapitalization.words,
                  maxLength: largoMaximoNombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre legal o razón social',
                    hintText: 'Licores del Norte S.A.C.',
                    counterText: '',
                  ),
                  validator: (v) =>
                      validarNombre(v ?? '', que: 'el nombre del negocio'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telefono,
                  enabled: !_guardando,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono (opcional)',
                    hintText: '044 123456 o 987 654 321',
                    helperText: 'Sale en las guías de pedido.',
                  ),
                  validator: (v) => validarTelefono(v ?? ''),
                ),
                if (error != null) ...[
                  const SizedBox(height: 16),
                  CajaError(error),
                ],
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
                        onPressed: () => _descartar(distribuidor),
                        child: const Text('Descartar'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        TarjetaSeccion(
          titulo: 'Datos de la plataforma',
          descripcion: 'Para cambiar estos datos, escríbenos.',
          child: _DatosFijos(distribuidor: distribuidor),
        ),
      ],
    );
  }
}

class _DatosFijos extends StatelessWidget {
  const _DatosFijos({required this.distribuidor});

  final Distribuidor distribuidor;

  @override
  Widget build(BuildContext context) {
    final datos = <DatoFijo>[
      DatoFijo(etiqueta: 'RUC', valor: distribuidor.documento ?? 'Sin RUC'),
      DatoFijo(etiqueta: 'Rubro', valor: distribuidor.rubro ?? 'Sin rubro'),
      DatoFijo(etiqueta: 'Identificador', valor: distribuidor.slug),
      DatoFijo(etiqueta: 'Moneda', valor: monedaLegible(distribuidor.moneda)),
      DatoFijo(
        etiqueta: 'Zona horaria',
        valor: zonaHorariaLegible(distribuidor.zonaHoraria),
      ),
      DatoFijo(
        etiqueta: 'Estado de la cuenta',
        valor: Etiqueta(
          estadoDistribuidorLegible(distribuidor.estado),
          tono: switch (distribuidor.estado) {
            EstadoDistribuidor.activo => TonoEtiqueta.exito,
            EstadoDistribuidor.prueba => TonoEtiqueta.info,
            EstadoDistribuidor.suspendido => TonoEtiqueta.aviso,
            EstadoDistribuidor.cancelado => TonoEtiqueta.peligro,
          },
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, limites) {
        final columnas = limites.maxWidth >= 520 ? 3 : 1;
        const hueco = 20.0;
        final ancho = (limites.maxWidth - hueco * (columnas - 1)) / columnas;
        return Wrap(
          spacing: hueco,
          runSpacing: 20,
          children: [
            for (final dato in datos) SizedBox(width: ancho, child: dato),
          ],
        );
      },
    );
  }
}

/// `Soles (PEN)` para la moneda del Perú; el código para las demás.
String monedaLegible(String codigo) => codigo == 'PEN' ? 'Soles (PEN)' : codigo;

/// `Lima (America/Lima)` para la de Perú; el nombre IANA para las demás.
String zonaHorariaLegible(String zona) =>
    zona == 'America/Lima' ? 'Lima (America/Lima)' : zona.replaceAll('_', ' ');
