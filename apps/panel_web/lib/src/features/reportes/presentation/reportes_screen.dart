import 'dart:developer' as developer;

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../../../shared/widgets/estados.dart';
import '../../../shared/widgets/pagina_panel.dart';
import '../../../shared/widgets/tabla_panel.dart';
import '../../../shared/widgets/tarjeta_indicador.dart';
import '../../clientes/presentation/clientes_providers.dart';
import '../../productos/presentation/catalogo_providers.dart';
import '../domain/periodo.dart';
import '../domain/reporte_ventas.dart';
import 'reportes_providers.dart';

/// Desgloses del reporte.
enum _Desglose { producto, cliente, categoria }

/// Ventas de un periodo: indicadores, desglose por producto, cliente o
/// categoría, y exportación de los pedidos a Excel.
class ReportesScreen extends ConsumerStatefulWidget {
  const ReportesScreen({super.key});

  @override
  ConsumerState<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends ConsumerState<ReportesScreen> {
  /// Null hasta el primer `build`, que lo fija en "este mes".
  Periodo? _periodo;
  _Desglose _desglose = _Desglose.producto;
  bool _exportando = false;

  Future<void> _elegirFechas(Periodo actual, DateTime ahora) async {
    final hoy = ahora.toLocal();
    final elegido = await showDateRangePicker(
      context: context,
      firstDate: DateTime(hoy.year - 3),
      lastDate: DateTime(hoy.year, hoy.month, hoy.day),
      initialDateRange: DateTimeRange(
        start: actual.desde,
        end: actual.ultimoDia,
      ),
      helpText: 'Elige el periodo del reporte',
      saveText: 'Aplicar',
    );
    if (elegido == null || !mounted) return;
    setState(() => _periodo = periodoEntre(elegido.start, elegido.end));
  }

  Future<void> _exportar(
    Periodo periodo,
    List<Pedido> pedidos,
    Map<String, String> nombreCliente,
  ) async {
    if (_exportando) return;
    final avisos = ScaffoldMessenger.maybeOf(context);
    setState(() => _exportando = true);
    try {
      await ref
          .read(exportadorProvider)
          .exportarPedidos(
            pedidos: pedidos,
            nombreCliente: nombreCliente,
            periodo: periodo,
          );
      avisos?.showSnackBar(
        SnackBar(
          content: Text(
            pedidos.length == 1
                ? 'Se descargó el Excel con 1 pedido.'
                : 'Se descargó el Excel con ${pedidos.length} pedidos.',
          ),
        ),
      );
    } catch (e, st) {
      developer.log(
        'No se pudo exportar a Excel.',
        name: 'reportes',
        error: e,
        stackTrace: st,
      );
      avisos?.showSnackBar(
        const SnackBar(
          content: Text('No pudimos generar el Excel. Inténtalo de nuevo.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ahora = ref.watch(relojProvider)();
    final periodo = _periodo ??= periodoRapido(PeriodoRapido.esteMes, ahora);
    final consulta = ref.watch(pedidosDelPeriodoProvider(periodo));
    final clientes =
        ref.watch(clientesProvider).value ?? const <ClienteNegocio>[];
    final productos = ref.watch(productosProvider).value ?? const <Producto>[];
    final categorias =
        ref.watch(categoriasProvider).value ?? const <Categoria>[];
    final nombreCliente = {for (final c in clientes) c.id: c.nombreNegocio};
    final pedidos = consulta.value;

    final Widget cuerpo;
    if (pedidos == null) {
      cuerpo = consulta.hasError
          ? EstadoAviso.error(
              alReintentar: () =>
                  ref.invalidate(pedidosDelPeriodoProvider(periodo)),
            )
          : const EstadoCarga();
    } else {
      cuerpo = _Reporte(
        reporte: armarReporte(
          pedidos,
          nombreCliente: nombreCliente,
          categoriaDeProducto: {for (final p in productos) p.id: p.categoriaId},
          nombreCategoria: {for (final c in categorias) c.id: c.nombre},
        ),
        unidadDeProducto: {for (final p in productos) p.id: p.unidadBase},
        desglose: _desglose,
        alCambiarDesglose: (d) => setState(() => _desglose = d),
      );
    }

    return PaginaPanel(
      titulo: 'Reportes',
      descripcion: 'Ventas del ${periodo.descripcion}.',
      acciones: [
        FilledButton.icon(
          onPressed: pedidos == null || pedidos.isEmpty || _exportando
              ? null
              : () => _exportar(periodo, pedidos, nombreCliente),
          icon: _exportando
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded),
          label: const Text('Exportar a Excel'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final rapido in PeriodoRapido.values)
                ChoiceChip(
                  label: Text(_nombrePeriodo(rapido)),
                  selected: periodo.rapido == rapido,
                  onSelected: (_) =>
                      setState(() => _periodo = periodoRapido(rapido, ahora)),
                ),
              ChoiceChip(
                avatar: const Icon(Icons.date_range_rounded, size: 18),
                label: Text(
                  periodo.rapido == null
                      ? periodo.descripcion
                      : 'Elegir fechas',
                ),
                selected: periodo.rapido == null,
                onSelected: (_) => _elegirFechas(periodo, ahora),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: cuerpo),
        ],
      ),
    );
  }
}

String _nombrePeriodo(PeriodoRapido rapido) => switch (rapido) {
  PeriodoRapido.esteMes => 'Este mes',
  PeriodoRapido.mesPasado => 'Mes pasado',
  PeriodoRapido.ultimos7Dias => 'Últimos 7 días',
  PeriodoRapido.ultimos30Dias => 'Últimos 30 días',
};

class _Reporte extends StatelessWidget {
  const _Reporte({
    required this.reporte,
    required this.unidadDeProducto,
    required this.desglose,
    required this.alCambiarDesglose,
  });

  final ReporteVentas reporte;
  final Map<String, String> unidadDeProducto;
  final _Desglose desglose;
  final ValueChanged<_Desglose> alCambiarDesglose;

  @override
  Widget build(BuildContext context) {
    final filas = switch (desglose) {
      _Desglose.producto => reporte.porProducto,
      _Desglose.cliente => reporte.porCliente,
      _Desglose.categoria => reporte.porCategoria,
    };

    final indicadores = [
      TarjetaIndicador(
        etiqueta: 'Ventas',
        valor: reporte.ventasCentimos.formatoSoles,
        icono: Icons.trending_up_rounded,
        detalle: Text(
          reporte.porCobrarCentimos == 0
              ? 'Todo cobrado.'
              : 'Falta cobrar ${reporte.porCobrarCentimos.formatoSoles}.',
        ),
      ),
      TarjetaIndicador(
        etiqueta: 'Pedidos',
        valor: '${reporte.pedidos}',
        icono: Icons.receipt_long_outlined,
        detalle: Text(
          reporte.cancelados == 0
              ? 'Ninguno cancelado.'
              : reporte.cancelados == 1
              ? '1 cancelado, que no cuenta.'
              : '${reporte.cancelados} cancelados, que no cuentan.',
        ),
      ),
      TarjetaIndicador(
        etiqueta: 'Ticket promedio',
        valor: reporte.ticketPromedioCentimos.formatoSoles,
        icono: Icons.sell_outlined,
        detalle: const Text('Venta promedio por pedido.'),
      ),
      TarjetaIndicador(
        etiqueta: 'Clientes que compraron',
        valor: '${reporte.clientes}',
        icono: Icons.storefront_outlined,
        detalle: const Text('Con al menos un pedido.'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, limites) {
        final ancho = limites.maxWidth;
        final columnas = ancho >= 960
            ? 4
            : ancho >= 520
            ? 2
            : 1;
        const hueco = 16.0;
        final anchoTarjeta = (ancho - hueco * (columnas - 1)) / columnas;

        // En pantallas bajas todo se desplaza junto; la tabla conserva un
        // alto mínimo cómodo.
        final altoTabla = (limites.maxHeight - 250).clamp(320.0, 2000.0);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: hueco,
                runSpacing: hueco,
                children: [
                  for (final indicador in indicadores)
                    SizedBox(width: anchoTarjeta, child: indicador),
                ],
              ),
              const SizedBox(height: hueco),
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<_Desglose>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _Desglose.producto,
                      label: Text('Por producto'),
                    ),
                    ButtonSegment(
                      value: _Desglose.cliente,
                      label: Text('Por cliente'),
                    ),
                    ButtonSegment(
                      value: _Desglose.categoria,
                      label: Text('Por categoría'),
                    ),
                  ],
                  selected: {desglose},
                  onSelectionChanged: (s) => alCambiarDesglose(s.first),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: altoTabla,
                child: filas.isEmpty
                    ? const EstadoAviso(
                        icono: Icons.insights_outlined,
                        titulo: 'Sin ventas en este periodo',
                        mensaje:
                            'Prueba con otro periodo. Los pedidos cancelados '
                            'no cuentan como venta.',
                      )
                    : _tabla(filas, ancho >= 620),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabla(List<FilaReporte> filas, bool amplia) {
    final esCliente = desglose == _Desglose.cliente;
    return TablaPanel(
      columnas: [
        ColumnaTabla(switch (desglose) {
          _Desglose.producto => 'Producto',
          _Desglose.cliente => 'Cliente',
          _Desglose.categoria => 'Categoría',
        }, flex: 3),
        ColumnaTabla(
          esCliente ? 'Pedidos' : 'Unidades',
          ancho: 130,
          aLaDerecha: true,
        ),
        const ColumnaTabla('Ventas', ancho: 120, aLaDerecha: true),
        if (amplia) const ColumnaTabla('Parte del total', ancho: 170),
      ],
      cantidadFilas: filas.length,
      celdasDeFila: (context, indice) {
        final fila = filas[indice];
        final parte = porcentajeDe(fila.centimos, reporte.ventasCentimos);
        final unidad = unidadDeProducto[fila.clave];
        return [
          Text(
            fila.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: ColoresPanel.neutro900,
            ),
          ),
          Text(
            desglose == _Desglose.producto && unidad != null
                ? cantidadConUnidad(fila.cantidad, unidad)
                : '${fila.cantidad}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            fila.centimos.formatoSoles,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (amplia)
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: parte / 100,
                      minHeight: 6,
                      color: ColoresPanel.primario500,
                      backgroundColor: ColoresPanel.neutro100,
                      semanticsLabel: 'Parte del total de ${fila.nombre}',
                    ),
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: Text(
                    '$parte%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ColoresPanel.neutro700,
                    ),
                  ),
                ),
              ],
            ),
        ];
      },
    );
  }
}
