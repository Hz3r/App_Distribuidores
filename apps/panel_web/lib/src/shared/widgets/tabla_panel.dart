import 'package:material_ui/material_ui.dart';

import '../../config/tema_panel.dart';

/// Columna de una [TablaPanel]. Con [ancho] es fija; si no, reparte el
/// espacio que queda según [flex].
class ColumnaTabla {
  const ColumnaTabla(
    this.titulo, {
    this.flex = 1,
    this.ancho,
    this.aLaDerecha = false,
  });

  final String titulo;
  final int flex;
  final double? ancho;
  final bool aLaDerecha;
}

/// Tabla del panel: encabezado fijo y filas con desplazamiento, dentro de
/// una tarjeta. Las celdas de cada fila van en el mismo orden que [columnas].
class TablaPanel extends StatelessWidget {
  const TablaPanel({
    required this.columnas,
    required this.cantidadFilas,
    required this.celdasDeFila,
    this.alTocarFila,
    this.filaSeleccionada,
    super.key,
  });

  final List<ColumnaTabla> columnas;
  final int cantidadFilas;
  final List<Widget> Function(BuildContext context, int indice) celdasDeFila;

  /// Si viene, cada fila se puede tocar (por ejemplo, para ver su detalle).
  final void Function(int indice)? alTocarFila;

  /// Índice de la fila resaltada, o null.
  final int? filaSeleccionada;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresPanel.blanco,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColoresPanel.neutro200),
      ),
      child: Column(
        children: [
          Container(
            color: ColoresPanel.neutro50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _fila([
              for (final columna in columnas)
                Text(
                  columna.titulo.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                    color: ColoresPanel.neutro500,
                  ),
                ),
            ]),
          ),
          const Divider(),
          Expanded(
            child: ListView.separated(
              itemCount: cantidadFilas,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, indice) {
                final fila = Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: _fila(celdasDeFila(context, indice)),
                );
                final alTocar = alTocarFila;
                final seleccionada = indice == filaSeleccionada;
                if (alTocar == null) return fila;
                return Semantics(
                  selected: seleccionada,
                  child: Material(
                    color: seleccionada
                        ? ColoresPanel.primario50
                        : Colors.transparent,
                    child: InkWell(onTap: () => alTocar(indice), child: fila),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(List<Widget> celdas) {
    assert(celdas.length == columnas.length, 'Una celda por columna.');
    return Row(
      children: [
        for (final (i, celda) in celdas.indexed) ...[
          if (i > 0) const SizedBox(width: 16),
          _celda(columnas[i], celda),
        ],
      ],
    );
  }

  Widget _celda(ColumnaTabla columna, Widget contenido) {
    final alineada = Align(
      alignment: columna.aLaDerecha
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: contenido,
    );
    final ancho = columna.ancho;
    return ancho != null
        ? SizedBox(width: ancho, child: alineada)
        : Expanded(flex: columna.flex, child: alineada);
  }
}
