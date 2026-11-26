import 'package:material_ui/material_ui.dart';

/// Colores de la app móvil, tomados de las maquetas. Algunos tonos se
/// oscurecieron para que el texto blanco encima tenga contraste suficiente.
abstract final class ColoresApp {
  /// Fondo de la bienvenida.
  static const marino = Color(0xFF0B2A5B);

  /// Tarjeta sobre el fondo [marino].
  static const marinoClaro = Color(0xFF143D7A);

  /// Acento y botón "Tengo un código". Lleva texto blanco encima.
  static const turquesa = Color(0xFF0F766E);

  /// Iconos de acento sobre [marino].
  static const turquesaClaro = Color(0xFF2DD4BF);

  /// Botón principal.
  static const azul = Color(0xFF2563EB);

  /// Fondos suaves: casillas del código, botón secundario, iconos.
  static const azulSuave = Color(0xFFE8F0FE);

  /// Texto secundario sobre [marino].
  static const textoSobreMarino = Color(0xFFBFD3F2);

  static const texto = Color(0xFF0F172A);
  static const textoSuave = Color(0xFF64748B);
  static const borde = Color(0xFFE2E8F0);

  /// Fondo de los campos de solo lectura.
  static const fondoSoloLectura = Color(0xFFF1F5F9);
  static const exito = Color(0xFF0F766E);
  static const fondoExito = Color(0xFFD7F5EE);
  static const error = Color(0xFFB91C1C);
}

/// Radio de esquinas de botones, tarjetas y casillas.
const radioApp = 12.0;

/// Alto de los botones de ancho completo.
const altoBoton = 52.0;

/// Tema de la app móvil. Se reemplazará con el `ConfigTema` del
/// distribuidor una vez elegido.
ThemeData temaApp() {
  final esquema = ColorScheme.fromSeed(
    seedColor: ColoresApp.azul,
    primary: ColoresApp.azul,
    secondary: ColoresApp.turquesa,
    error: ColoresApp.error,
    surface: Colors.white,
    onSurface: ColoresApp.texto,
  );
  final forma = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radioApp),
  );
  const textoBoton = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: ColoresApp.texto,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(altoBoton),
        shape: forma,
        textStyle: textoBoton,
        disabledBackgroundColor: ColoresApp.borde,
        disabledForegroundColor: ColoresApp.textoSuave,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: ColoresApp.texto,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: ColoresApp.texto),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: ColoresApp.texto),
    ),
  );
}
