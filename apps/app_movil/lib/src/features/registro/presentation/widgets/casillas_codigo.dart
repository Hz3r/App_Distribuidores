import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../shared/tema_app.dart';
import '../../domain/codigo_invitacion.dart';

/// Casillas del código de invitación. Por debajo hay un solo campo de texto
/// invisible: así se puede pegar el código entero y el teclado funciona
/// igual que en cualquier campo. Lo que se escribe se normaliza al vuelo.
class CasillasCodigo extends StatefulWidget {
  const CasillasCodigo({
    required this.onChanged,
    this.habilitado = true,
    super.key,
  });

  /// Recibe el código ya normalizado.
  final ValueChanged<String> onChanged;

  final bool habilitado;

  @override
  State<CasillasCodigo> createState() => _CasillasCodigoState();
}

class _CasillasCodigoState extends State<CasillasCodigo> {
  final _controlador = TextEditingController();
  final _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    // Repinta las casillas con cada cambio de texto o de foco.
    _controlador.addListener(_repintar);
    _foco.addListener(_repintar);
  }

  @override
  void dispose() {
    _controlador.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _repintar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final codigo = _controlador.text;

    return Stack(
      children: [
        ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 0; i < largoCodigo; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _Casilla(
                    caracter: i < codigo.length ? codigo[i] : '',
                    esperando: _foco.hasFocus && i == codigo.length,
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned.fill(
          child: TextField(
            controller: _controlador,
            focusNode: _foco,
            enabled: widget.habilitado,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: const [_FormatoCodigo()],
            onChanged: widget.onChanged,
            // El texto y el cursor no se ven: se dibujan las casillas.
            showCursor: false,
            style: const TextStyle(color: Colors.transparent),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              labelText: 'Código de invitación',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelStyle: TextStyle(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }
}

class _Casilla extends StatelessWidget {
  const _Casilla({required this.caracter, required this.esperando});

  final String caracter;

  /// Es la casilla que recibe el próximo carácter.
  final bool esperando;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ColoresApp.azulSuave,
          borderRadius: BorderRadius.circular(radioApp),
          border: Border.all(
            color: esperando ? ColoresApp.azul : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          caracter,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ColoresApp.texto,
          ),
        ),
      ),
    );
  }
}

/// Deja en el campo el código normalizado, con el cursor al final.
class _FormatoCodigo extends TextInputFormatter {
  const _FormatoCodigo();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final codigo = normalizarCodigo(newValue.text);
    return TextEditingValue(
      text: codigo,
      selection: TextSelection.collapsed(offset: codigo.length),
    );
  }
}
