import 'package:core/core.dart';
import 'package:material_ui/material_ui.dart';

import '../../../config/tema_panel.dart';
import '../../../shared/formato.dart';
import '../domain/resumen_ventas.dart';

/// Barras de ventas por día. Una sola serie y un solo color: el título de
/// la tarjeta ya dice qué se mide, así que no lleva leyenda. Solo se rotula
/// el día de más venta; el resto se lee al pasar el cursor (y un lector de
/// pantalla recibe el valor de cada día).
class GraficoVentas extends StatelessWidget {
  const GraficoVentas({required this.dias, required this.hoy, super.key});

  final List<VentaDia> dias;

  /// Para resaltar la etiqueta del día actual.
  final DateTime hoy;

  static const double _altoBarras = 132;
  static const double _anchoBarra = 24;

  @override
  Widget build(BuildContext context) {
    final maximo = dias.fold(0, (m, d) => d.centimos > m ? d.centimos : m);
    final indiceMaximo = dias.indexWhere((d) => d.centimos == maximo);

    return Column(
      children: [
        SizedBox(
          // Deja sitio arriba para el rótulo del día de más venta.
          height: _altoBarras + 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final (i, dia) in dias.indexed)
                Expanded(
                  child: _Barra(
                    dia: dia,
                    alto: maximo <= 0 ? 0 : _altoBarras * dia.centimos / maximo,
                    rotulada: maximo > 0 && i == indiceMaximo,
                  ),
                ),
            ],
          ),
        ),
        // Línea base: fina y discreta.
        const Divider(),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final dia in dias)
              Expanded(
                child: Text(
                  diaCorto(dia.dia),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _esHoy(dia.dia)
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: _esHoy(dia.dia)
                        ? ColoresPanel.neutro900
                        : ColoresPanel.neutro500,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  bool _esHoy(DateTime dia) =>
      dia.year == hoy.year && dia.month == hoy.month && dia.day == hoy.day;
}

class _Barra extends StatelessWidget {
  const _Barra({required this.dia, required this.alto, required this.rotulada});

  final VentaDia dia;
  final double alto;
  final bool rotulada;

  @override
  Widget build(BuildContext context) {
    final pedidos = dia.pedidos == 1 ? '1 pedido' : '${dia.pedidos} pedidos';
    final descripcion =
        '${diaCorto(dia.dia)} ${dia.dia.day}: '
        '${dia.centimos.formatoSoles} · $pedidos';

    return Semantics(
      label: descripcion,
      child: Tooltip(
        message: descripcion,
        // Toda la columna responde al cursor, no solo la barra.
        child: ColoredBox(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (rotulada)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    dia.centimos.formatoSoles,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ColoresPanel.neutro700,
                    ),
                  ),
                ),
              Container(
                width: GraficoVentas._anchoBarra,
                height: alto,
                decoration: const BoxDecoration(
                  color: ColoresPanel.primario500,
                  // Redondeada arriba, recta en la línea base.
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
