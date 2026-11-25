import 'package:material_ui/material_ui.dart';

import '../../config/tema_panel.dart';
import 'pagina_panel.dart';

/// Sección del panel que todavía no está construida.
class PantallaPlaceholder extends StatelessWidget {
  const PantallaPlaceholder({
    required this.titulo,
    required this.descripcion,
    super.key,
  });

  final String titulo;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return PaginaPanel(
      titulo: titulo,
      descripcion: descripcion,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColoresPanel.blanco,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresPanel.neutro200),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.construction_rounded,
              size: 40,
              color: ColoresPanel.neutro300,
            ),
            const SizedBox(height: 12),
            Text(
              'Esta sección está en construcción.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
