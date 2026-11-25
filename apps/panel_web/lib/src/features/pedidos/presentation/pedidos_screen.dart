import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/textos.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/etiqueta.dart';
import '../../../shared/widgets/pagina_panel.dart';
import '../../../shared/widgets/tabla_panel.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../domain/flujo_pedido.dart';
import 'nuevo_pedido_dialogo.dart';
import 'pedido_detalle.dart';
import 'pedidos_providers.dart';

/// Pedidos del distribuidor, por etapa: confirmar, despachar, entregar y
/// cobrar.
class PedidosScreen extends ConsumerStatefulWidget {
  const PedidosScreen({super.key});

  @override
  ConsumerState<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends ConsumerState<PedidosScreen> {
  /// Desde este ancho el detalle va al lado de la lista; por debajo, en un
  /// diálogo.
  static const _anchoConDetalle = 940.0;

  final _busqueda = TextEditingController();
  GrupoPedidos _grupo = GrupoPedidos.porConfirmar;
  String? _seleccionadoId;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _nuevoPedido() async {
    final avisos = ScaffoldMessenger.maybeOf(context);
    final id = await NuevoPedidoDialogo.mostrar(context);
    if (id == null || !mounted) return;
    setState(() {
      _grupo = GrupoPedidos.porConfirmar;
      _seleccionadoId = id;
    });
    avisos?.showSnackBar(const SnackBar(content: Text('Pedido registrado.')));
  }

  void _abrir(Pedido pedido, {required bool alLado}) {
    setState(() => _seleccionadoId = pedido.id);
    if (alLado) return;
    showDialog<void>(
      context: context,
      builder: (contexto) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
          child: PedidoDetalle(
            pedidoId: pedido.id,
            alCerrar: () => Navigator.of(contexto).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consulta = ref.watch(pedidosProvider);
    final clientes =
        ref.watch(clientesProvider).value ?? const <ClienteNegocio>[];
    final pedidos = consulta.value;

    final Widget cuerpo;
    if (pedidos == null) {
      cuerpo = consulta.hasError
          ? EstadoAviso.error(
              alReintentar: () => ref.invalidate(pedidosProvider),
            )
          : const EstadoCarga();
    } else if (pedidos.isEmpty) {
      cuerpo = EstadoAviso(
        icono: Icons.receipt_long_outlined,
        titulo: 'Aún no tienes pedidos',
        mensaje:
            'Aquí aparecen los pedidos que hacen tus clientes desde la app. '
            'También puedes registrar uno que te pidan por teléfono.',
        accion: FilledButton.icon(
          onPressed: _nuevoPedido,
          icon: const Icon(Icons.add),
          label: const Text('Nuevo pedido'),
        ),
      );
    } else {
      cuerpo = _contenido(pedidos, {
        for (final c in clientes) c.id: c.nombreNegocio,
      });
    }

    return PaginaPanel(
      titulo: 'Pedidos',
      descripcion: 'Confirma, despacha y cobra los pedidos de tus clientes.',
      acciones: [
        IconButton(
          tooltip: 'Actualizar la lista de pedidos',
          onPressed: () => ref.invalidate(pedidosProvider),
          icon: const Icon(Icons.refresh_rounded),
        ),
        if (pedidos != null && pedidos.isNotEmpty)
          FilledButton.icon(
            onPressed: _nuevoPedido,
            icon: const Icon(Icons.add),
            label: const Text('Nuevo pedido'),
          ),
      ],
      child: cuerpo,
    );
  }

  Widget _contenido(List<Pedido> pedidos, Map<String, String> nombreCliente) {
    int contar(GrupoPedidos grupo) =>
        pedidos.where((p) => grupoDe(p.estado) == grupo).length;
    final filtrados = filtrarPedidos(
      [
        for (final p in pedidos)
          if (grupoDe(p.estado) == _grupo) p,
      ],
      _busqueda.text,
      nombreCliente,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Buscar por n.º o cliente',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            for (final grupo in GrupoPedidos.values)
              ChoiceChip(
                label: Text('${_nombreGrupo(grupo)} (${contar(grupo)})'),
                selected: _grupo == grupo,
                onSelected: (_) => setState(() => _grupo = grupo),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(
            builder: (context, limites) {
              final alLado = limites.maxWidth >= _anchoConDetalle;
              final lista = filtrados.isEmpty
                  ? _vacio()
                  : _tabla(filtrados, nombreCliente, alLado: alLado);
              if (!alLado) return lista;

              final seleccionadoId = _seleccionadoId;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: lista),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 400,
                    child: Material(
                      color: ColoresPanel.blanco,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: ColoresPanel.neutro200),
                      ),
                      child: seleccionadoId == null
                          ? const EstadoAviso(
                              icono: Icons.touch_app_outlined,
                              titulo: 'Elige un pedido',
                              mensaje:
                                  'Toca un pedido de la lista para ver sus '
                                  'productos y atenderlo.',
                            )
                          : PedidoDetalle(
                              key: ValueKey(seleccionadoId),
                              pedidoId: seleccionadoId,
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _vacio() {
    final buscando = _busqueda.text.trim().isNotEmpty;
    return EstadoAviso(
      icono: buscando ? Icons.search_off_rounded : Icons.inbox_outlined,
      titulo: buscando
          ? 'Ningún pedido coincide'
          : 'No hay pedidos ${_nombreGrupo(_grupo).toLowerCase()}',
      mensaje: buscando
          ? 'Prueba con otro número o nombre, o mira en otra etapa.'
          : 'Cuando haya alguno en esta etapa, aparece aquí.',
      accion: buscando
          ? OutlinedButton(
              onPressed: () => setState(_busqueda.clear),
              child: const Text('Quitar búsqueda'),
            )
          : null,
    );
  }

  Widget _tabla(
    List<Pedido> pedidos,
    Map<String, String> nombreCliente, {
    required bool alLado,
  }) {
    final seleccion = pedidos.indexWhere((p) => p.id == _seleccionadoId);
    return TablaPanel(
      columnas: const [
        ColumnaTabla('Pedido', ancho: 110),
        ColumnaTabla('Cliente', flex: 3),
        ColumnaTabla('Total', ancho: 96, aLaDerecha: true),
        ColumnaTabla('Cobro', ancho: 104),
      ],
      cantidadFilas: pedidos.length,
      filaSeleccionada: seleccion < 0 ? null : seleccion,
      alTocarFila: (indice) => _abrir(pedidos[indice], alLado: alLado),
      celdasDeFila: (context, indice) {
        final pedido = pedidos[indice];
        final lineas = pedido.items.length;
        return [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#${pedido.numero}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ColoresPanel.primario500,
                ),
              ),
              Text(
                fechaHoraCorta(pedido.creadoEn),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresPanel.neutro500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nombreCliente[pedido.clienteId] ?? 'Cliente',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColoresPanel.neutro900,
                ),
              ),
              Text(
                '${lineas == 1 ? '1 producto' : '$lineas productos'} · '
                '${estadoPedidoLegible(pedido.estado)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresPanel.neutro500,
                ),
              ),
            ],
          ),
          Text(
            pedido.totalCentimos.formatoSoles,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (pedido.estado == EstadoPedido.cancelado)
            const Text('—', style: TextStyle(color: ColoresPanel.neutro500))
          else
            Etiqueta(
              estadoPagoLegible(pedido.estadoPago),
              tono: tonoDePago(pedido.estadoPago),
            ),
        ];
      },
    );
  }
}

String _nombreGrupo(GrupoPedidos grupo) => switch (grupo) {
  GrupoPedidos.porConfirmar => 'Por confirmar',
  GrupoPedidos.confirmados => 'Confirmados',
  GrupoPedidos.enCamino => 'En camino',
  GrupoPedidos.entregados => 'Entregados',
  GrupoPedidos.cancelados => 'Cancelados',
};
