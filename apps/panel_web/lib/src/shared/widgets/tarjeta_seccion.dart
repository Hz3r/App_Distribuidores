import 'package:material_ui/material_ui.dart';

import '../../config/tema_panel.dart';

/// Bloque blanco con borde y título, para agrupar campos de una página de
/// ajustes (Configuración, Mi cuenta).
class TarjetaSeccion extends StatelessWidget {
  const TarjetaSeccion({
    required this.titulo,
    required this.child,
    this.descripcion,
    super.key,
  });

  final String titulo;
  final String? descripcion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final descripcion = this.descripcion;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ColoresPanel.blanco,
        border: Border.all(color: ColoresPanel.neutro200),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              titulo,
              style: tema.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColoresPanel.neutro900,
              ),
            ),
          ),
          if (descripcion != null) ...[
            const SizedBox(height: 4),
            Text(
              descripcion,
              style: tema.textTheme.bodyMedium?.copyWith(
                color: ColoresPanel.neutro500,
              ),
            ),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

/// Dato de solo lectura: etiqueta arriba y valor debajo.
class DatoFijo extends StatelessWidget {
  const DatoFijo({required this.etiqueta, required this.valor, super.key});

  final String etiqueta;

  /// Texto o widget (por ejemplo, una etiqueta de estado).
  final Object valor;

  @override
  Widget build(BuildContext context) {
    final valor = this.valor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 12, color: ColoresPanel.neutro500),
        ),
        const SizedBox(height: 4),
        if (valor is Widget)
          valor
        else
          SelectableText(
            '$valor',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: ColoresPanel.neutro900,
            ),
          ),
      ],
    );
  }
}

/// Contenido desplazable de una página de ajustes, con ancho máximo.
class ContenidoAjustes extends StatelessWidget {
  const ContenidoAjustes({
    required this.children,
    this.anchoMaximo = 760,
    super.key,
  });

  final List<Widget> children;
  final double anchoMaximo;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: anchoMaximo),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, hijo) in children.indexed) ...[
                if (i > 0) const SizedBox(height: 16),
                hijo,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
