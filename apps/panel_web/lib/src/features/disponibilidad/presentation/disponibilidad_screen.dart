import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/pagina_panel.dart';
import '../../../shared/widgets/tabla_panel.dart';
import '../../productos/domain/filtro_productos.dart';
import '../../productos/presentation/catalogo_providers.dart';
import '../../sesion/presentation/control_acceso.dart';
import '../domain/disponibilidad.dart';
import 'actualizar_disponibilidad_dialogo.dart';

/// Cuánto ofrece el distribuidor de cada producto, cuánto está reservado en
/// pedidos y cuánto queda para pedir. No es un inventario: el distribuidor
/// declara la cantidad y los pedidos la van descontando.
class DisponibilidadScreen extends ConsumerStatefulWidget {
  const DisponibilidadScreen({super.key});

  @override
  ConsumerState<DisponibilidadScreen> createState() =>
      _DisponibilidadScreenState();
}

class _DisponibilidadScreenState extends ConsumerState<DisponibilidadScreen> {
  final _busqueda = TextEditingController();

  /// Null = todos los niveles.
  NivelDisponibilidad? _nivel;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _actualizar(Producto producto) async {
    final guardado = await ActualizarDisponibilidadDialogo.mostrar(
      context,
      producto,
    );
    if (guardado == true && mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Disponibilidad de ${producto.nombre} actualizada.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final consulta = ref.watch(productosProvider);
    final esAdmin =
        ref.watch(membresiaActivaProvider)?.rol == RolMembresia.admin;
    final productos = consulta.value;

    final Widget cuerpo;
    if (productos == null) {
      cuerpo = consulta.hasError
          ? EstadoAviso.error(
              alReintentar: () => ref.invalidate(productosProvider),
            )
          : const EstadoCarga();
    } else if (productos.isEmpty) {
      cuerpo = const EstadoAviso(
        icono: Icons.inventory_2_outlined,
        titulo: 'Aún no tienes productos',
        mensaje:
            'Crea tus productos en la sección Productos y aquí indicas cuánto '
            'puedes ofrecer de cada uno.',
      );
    } else {
      cuerpo = _contenido(productos, esAdmin);
    }

    return PaginaPanel(
      titulo: 'Disponibilidad',
      descripcion:
          'Indicas cuánto puedes ofrecer y cada pedido lo descuenta. Si un '
          'pedido se cancela, la cantidad vuelve sola.',
      child: cuerpo,
    );
  }

  Widget _contenido(List<Producto> productos, bool esAdmin) {
    int contar(NivelDisponibilidad nivel) =>
        productos.where((p) => nivelDe(p) == nivel).length;
    final agotados = contar(NivelDisponibilidad.agotado);
    final bajos = contar(NivelDisponibilidad.bajo);
    final conReserva = productos.where((p) => p.stockComprometido > 0).length;

    final nivel = _nivel;
    final filtrados = [
      for (final p in filtrarProductos(productos, busqueda: _busqueda.text))
        if (nivel == null || nivelDe(p) == nivel) p,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            _Indicador(
              etiqueta: 'Con reservas en pedidos',
              valor: '$conReserva',
              icono: Icons.schedule_rounded,
              color: ColoresPanel.primario500,
              fondo: ColoresPanel.primario100,
            ),
            _Indicador(
              etiqueta: 'Con poca disponibilidad',
              valor: '$bajos',
              icono: Icons.trending_down_rounded,
              color: ColoresPanel.aviso500,
              fondo: ColoresPanel.aviso100,
            ),
            _Indicador(
              etiqueta: 'Agotados',
              valor: '$agotados',
              icono: Icons.block_rounded,
              color: ColoresPanel.peligro500,
              fondo: ColoresPanel.peligro100,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Buscar producto',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            ChoiceChip(
              label: Text('Todos (${productos.length})'),
              selected: nivel == null,
              onSelected: (_) => setState(() => _nivel = null),
            ),
            ChoiceChip(
              label: Text('Poca disponibilidad ($bajos)'),
              selected: nivel == NivelDisponibilidad.bajo,
              onSelected: (_) =>
                  setState(() => _nivel = NivelDisponibilidad.bajo),
            ),
            ChoiceChip(
              label: Text('Agotados ($agotados)'),
              selected: nivel == NivelDisponibilidad.agotado,
              onSelected: (_) =>
                  setState(() => _nivel = NivelDisponibilidad.agotado),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: filtrados.isEmpty
              ? EstadoAviso(
                  icono: Icons.search_off_rounded,
                  titulo: 'Ningún producto coincide',
                  mensaje: 'Prueba con otra palabra o quita los filtros.',
                  accion: OutlinedButton(
                    onPressed: () => setState(() {
                      _busqueda.clear();
                      _nivel = null;
                    }),
                    child: const Text('Quitar filtros'),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, limites) => _tabla(
                    filtrados,
                    esAdmin: esAdmin,
                    amplia: limites.maxWidth >= 820,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _tabla(
    List<Producto> productos, {
    required bool esAdmin,
    required bool amplia,
  }) {
    return TablaPanel(
      columnas: [
        const ColumnaTabla('Producto', flex: 3),
        const ColumnaTabla('Ofreces', ancho: 110, aLaDerecha: true),
        const ColumnaTabla('Reservado', ancho: 90, aLaDerecha: true),
        const ColumnaTabla('Disponible', ancho: 90, aLaDerecha: true),
        if (amplia) const ColumnaTabla('Nivel', ancho: 150),
        if (esAdmin) const ColumnaTabla('', ancho: 116, aLaDerecha: true),
      ],
      cantidadFilas: productos.length,
      celdasDeFila: (context, indice) {
        final producto = productos[indice];
        final color = switch (nivelDe(producto)) {
          NivelDisponibilidad.agotado => ColoresPanel.peligro500,
          NivelDisponibilidad.bajo => ColoresPanel.aviso500,
          NivelDisponibilidad.normal => ColoresPanel.acento500,
        };
        return [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColoresPanel.neutro900,
                ),
              ),
              Text(
                producto.activo
                    ? 'En ${pluralDe(producto.unidadBase)}'
                    : 'En ${pluralDe(producto.unidadBase)} · oculto a clientes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresPanel.neutro500,
                ),
              ),
            ],
          ),
          Text('${producto.stockFisico}'),
          Text('${producto.stockComprometido}'),
          Text(
            '${producto.stockDisponible}',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
          if (amplia)
            producto.stockDisponible <= 0
                ? const Text(
                    'Agotado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ColoresPanel.peligro500,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: proporcionDisponible(producto),
                      minHeight: 6,
                      color: color,
                      backgroundColor: ColoresPanel.neutro100,
                      semanticsLabel: 'Disponible de ${producto.nombre}',
                    ),
                  ),
          if (esAdmin)
            TextButton(
              onPressed: () => _actualizar(producto),
              child: const Text('Actualizar'),
            ),
        ];
      },
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.etiqueta,
    required this.valor,
    required this.icono,
    required this.color,
    required this.fondo,
  });

  final String etiqueta;
  final String valor;
  final IconData icono;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: ColoresPanel.blanco,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresPanel.neutro200),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icono, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 28 / 22,
                    fontWeight: FontWeight.w700,
                    color: ColoresPanel.neutro900,
                  ),
                ),
                Text(
                  etiqueta,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColoresPanel.neutro500,
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
