import 'package:material_ui/material_ui.dart';

import '../../../../shared/tema_app.dart';

/// Imagen de un producto que ocupa todo el espacio que le dan. Sin [url], o
/// si no carga, un recuadro azul suave con el icono de caja.
class ImagenProducto extends StatelessWidget {
  const ImagenProducto({required this.url, this.tamanoIcono = 40, super.key});

  final String? url;
  final double tamanoIcono;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    final marcador = _Marcador(tamanoIcono: tamanoIcono);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radioApp),
      child: SizedBox.expand(
        child: url == null || url.isEmpty
            ? marcador
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => marcador,
                // Mientras carga, el mismo recuadro.
                frameBuilder: (_, imagen, cuadro, sincronica) =>
                    sincronica || cuadro != null ? imagen : marcador,
              ),
      ),
    );
  }
}

class _Marcador extends StatelessWidget {
  const _Marcador({required this.tamanoIcono});

  final double tamanoIcono;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ColoresApp.azulSuave,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: tamanoIcono,
          color: ColoresApp.azul,
        ),
      ),
    );
  }
}
