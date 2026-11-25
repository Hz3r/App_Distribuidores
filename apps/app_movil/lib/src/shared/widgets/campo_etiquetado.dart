import 'package:material_ui/material_ui.dart';

import '../tema_app.dart';

/// Campo de formulario con su etiqueta encima, como en las maquetas: texto
/// corto en negrita y una caja redondeada de [altoBoton] de alto.
///
/// La etiqueta y el campo forman un solo nodo para el lector de pantalla.
class CampoEtiquetado extends StatelessWidget {
  const CampoEtiquetado({
    required this.etiqueta,
    required this.controller,
    this.pista,
    this.validator,
    this.soloLectura = false,
    this.ocultarTexto = false,
    this.sufijo,
    this.teclado,
    this.accion = TextInputAction.next,
    this.autocompletar,
    this.mayusculas = TextCapitalization.none,
    this.onSubmitted,
    super.key,
  });

  final String etiqueta;
  final TextEditingController controller;

  /// Ejemplo que se ve mientras el campo está vacío.
  final String? pista;

  final FormFieldValidator<String>? validator;

  /// Se ve con fondo gris y no se puede cambiar (sí seleccionar y copiar).
  final bool soloLectura;

  final bool ocultarTexto;

  /// Botón o icono al final de la caja (por ejemplo, mostrar la contraseña).
  final Widget? sufijo;

  final TextInputType? teclado;
  final TextInputAction accion;
  final Iterable<String>? autocompletar;
  final TextCapitalization mayusculas;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radioApp),
      borderSide: const BorderSide(color: ColoresApp.borde),
    );

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            etiqueta,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            validator: validator,
            readOnly: soloLectura,
            obscureText: ocultarTexto,
            enableSuggestions: !ocultarTexto,
            autocorrect: !ocultarTexto,
            keyboardType: teclado,
            textInputAction: accion,
            textCapitalization: mayusculas,
            autofillHints: soloLectura ? null : autocompletar,
            onFieldSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: pista,
              hintStyle: const TextStyle(color: ColoresApp.textoSuave),
              filled: true,
              fillColor: soloLectura
                  ? ColoresApp.fondoSoloLectura
                  : Colors.white,
              constraints: const BoxConstraints(minHeight: altoBoton),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: sufijo,
              border: borde,
              enabledBorder: borde,
              focusedBorder: borde.copyWith(
                borderSide: const BorderSide(color: ColoresApp.azul, width: 2),
              ),
              errorBorder: borde.copyWith(
                borderSide: const BorderSide(color: ColoresApp.error),
              ),
              focusedErrorBorder: borde.copyWith(
                borderSide: const BorderSide(color: ColoresApp.error, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
