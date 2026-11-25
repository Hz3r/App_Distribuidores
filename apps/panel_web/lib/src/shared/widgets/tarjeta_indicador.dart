import 'package:material_ui/material_ui.dart';

import '../../config/tema_panel.dart';
import 'etiqueta.dart';

/// Tarjeta con un número grande. Si se puede tocar, lleva a la sección
/// donde se atiende ese número.
class TarjetaIndicador extends StatelessWidget {
  const TarjetaIndicador({
    required this.etiqueta,
    required this.valor,
    required this.icono,
    required this.detalle,
    this.tono = TonoEtiqueta.info,
    this.alTocar,
    super.key,
  });

  final String etiqueta;
  final String valor;
  final IconData icono;
  final Widget detalle;
  final TonoEtiqueta tono;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresPanel.blanco,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColoresPanel.neutro200),
      ),
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: tono.fondo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(icono, size: 20, color: tono.texto),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      etiqueta,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: ColoresPanel.neutro500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 30 / 24,
                    fontWeight: FontWeight.w700,
                    color: ColoresPanel.neutro900,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 12,
                  color: ColoresPanel.neutro500,
                ),
                child: detalle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
