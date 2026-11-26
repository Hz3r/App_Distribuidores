import 'package:material_ui/material_ui.dart';

/// Texto que nunca se recorta, para cifras como un precio: en una línea si
/// cabe; si no, se achica hasta [tamanoMinimo] (en puntos lógicos ya con la
/// escala del sistema), y si aun así no cabe, pasa a más líneas con ese
/// tamaño en vez de seguir encogiendo.
class TextoAjustable extends StatelessWidget {
  const TextoAjustable(
    this.texto, {
    this.style,
    this.tamanoMinimo = 11,
    super.key,
  });

  final String texto;
  final TextStyle? style;
  final double tamanoMinimo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, restricciones) {
        final estilo = DefaultTextStyle.of(context).style.merge(style);
        final escala = MediaQuery.textScalerOf(context);
        final medida = TextPainter(
          text: TextSpan(text: texto, style: estilo),
          textDirection: Directionality.of(context),
          textScaler: escala,
          maxLines: 1,
        )..layout();
        final ancho = medida.width;
        medida.dispose();

        if (!restricciones.hasBoundedWidth || ancho <= restricciones.maxWidth) {
          return Text(texto, style: style, maxLines: 1);
        }
        final tamano = escala.scale(estilo.fontSize ?? 14);
        // Un poco menos que la proporción exacta, por el redondeo.
        final achicado = tamano * restricciones.maxWidth / ancho * 0.98;
        final cabeAchicado = achicado >= tamanoMinimo;
        return Text(
          texto,
          style:
              style?.copyWith(
                fontSize: cabeAchicado ? achicado : tamanoMinimo,
              ) ??
              TextStyle(fontSize: cabeAchicado ? achicado : tamanoMinimo),
          // El tamaño ya incluye la escala del sistema.
          textScaler: TextScaler.noScaling,
          maxLines: cabeAchicado ? 1 : null,
        );
      },
    );
  }
}
