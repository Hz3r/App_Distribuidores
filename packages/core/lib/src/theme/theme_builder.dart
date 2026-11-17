import 'package:material_ui/material_ui.dart';

import '../models/config_tema.dart';

/// Construye un [ThemeData] a partir de la personalización del distribuidor.
abstract final class ThemeBuilder {
  /// Convierte `#RRGGBB` a [Color]. Lanza [FormatException] si el formato no es válido.
  static Color colorDesdeHex(String hex) {
    final limpio = hex.replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(limpio)) {
      throw FormatException('Color inválido: $hex', hex);
    }
    return Color(int.parse('FF$limpio', radix: 16));
  }

  static ThemeData desde(ConfigTema config) {
    final primario = colorDesdeHex(config.colorPrimario);
    final secundario = colorDesdeHex(config.colorSecundario);

    final esquema = ColorScheme.fromSeed(
      seedColor: primario,
      primary: primario,
      secondary: secundario,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      appBarTheme: AppBarTheme(
        backgroundColor: primario,
        foregroundColor: esquema.onPrimary,
        centerTitle: false,
      ),
    );
  }
}
