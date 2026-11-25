import 'package:material_ui/material_ui.dart';

/// Marco de una sección del panel: título, descripción, acciones a la derecha
/// y el contenido debajo. Va dentro de `PanelShell`.
class PaginaPanel extends StatelessWidget {
  const PaginaPanel({
    required this.titulo,
    required this.child,
    this.descripcion,
    this.acciones = const [],
    super.key,
  });

  final String titulo;
  final String? descripcion;

  /// Botones de la cabecera (por ejemplo, "Nuevo producto").
  final List<Widget> acciones;

  /// Contenido; ocupa el alto que queda.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final descripcion = this.descripcion;

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: tema.textTheme.headlineMedium),
                    if (descripcion != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        descripcion,
                        style: tema.textTheme.bodyMedium?.copyWith(
                          color: tema.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              for (final accion in acciones) ...[
                const SizedBox(width: 12),
                accion,
              ],
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}
