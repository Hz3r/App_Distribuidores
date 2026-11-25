import 'package:material_ui/material_ui.dart';

import '../../config/tema_panel.dart';

/// Tono de una [Etiqueta]: fija el color de fondo y de texto.
enum TonoEtiqueta {
  exito(ColoresPanel.exito100, ColoresPanel.exito500),
  aviso(ColoresPanel.aviso100, ColoresPanel.aviso500),
  peligro(ColoresPanel.peligro100, ColoresPanel.peligro500),
  info(ColoresPanel.primario100, ColoresPanel.primario700),
  neutro(ColoresPanel.neutro100, ColoresPanel.neutro500);

  const TonoEtiqueta(this.fondo, this.texto);

  final Color fondo;
  final Color texto;
}

/// Píldora de estado (Activo, Invitado, Vencida…). El texto siempre dice el
/// estado: el color solo acompaña.
class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {required this.tono, super.key});

  final String texto;
  final TonoEtiqueta tono;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tono.fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(
        texto,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tono.texto,
        ),
      ),
    );
  }
}
