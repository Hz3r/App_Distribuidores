import 'dart:math' as math;
import 'dart:typed_data';

/// Largo máximo de un nombre (legal, comercial o de persona).
const largoMaximoNombre = 80;

/// Peso máximo del logo. El bucket acepta hasta 5 MB, pero el logo se
/// descarga en cada celular: se pide algo más liviano.
const pesoMaximoLogo = 2 * 1024 * 1024;

/// Null si [nombre] sirve; si no, el motivo para mostrar en el campo.
String? validarNombre(String nombre, {String que = 'el nombre'}) {
  final limpio = nombre.trim();
  if (limpio.isEmpty) return 'Escribe $que.';
  if (limpio.length > largoMaximoNombre) {
    return 'Usa como máximo $largoMaximoNombre caracteres.';
  }
  return null;
}

/// Teléfono opcional: vacío vale. Acepta espacios, guiones, paréntesis y un
/// `+` inicial, y pide entre 6 y 15 dígitos (fijos con código de ciudad y
/// celulares con código de país).
String? validarTelefono(String telefono) {
  final limpio = telefono.trim();
  if (limpio.isEmpty) return null;
  if (!RegExp(r'^\+?[0-9 ()-]+$').hasMatch(limpio)) {
    return 'Usa solo números, espacios o guiones.';
  }
  final digitos = limpio.replaceAll(RegExp('[^0-9]'), '').length;
  if (digitos < 6 || digitos > 15) {
    return 'Revisa el número: debe tener entre 6 y 15 dígitos.';
  }
  return null;
}

/// `#RRGGBB` en mayúsculas si [texto] es un color válido (con o sin `#`),
/// o null. Es el formato que exige el contrato (`config_tema`).
String? normalizarColor(String texto) {
  final limpio = texto.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(limpio)) return null;
  return '#${limpio.toUpperCase()}';
}

String? validarColor(String texto) => normalizarColor(texto) == null
    ? 'Usa un color como #1F3A5F (seis caracteres de 0-9 y A-F).'
    : null;

/// `0xAARRGGBB` del color `#RRGGBB`, o null si no es válido.
int? argbDe(String hex) {
  final normal = normalizarColor(hex);
  if (normal == null) return null;
  return 0xFF000000 | int.parse(normal.substring(1), radix: 16);
}

/// Luminancia relativa (WCAG 2.x) de un color `0xAARRGGBB`.
double luminancia(int argb) {
  double canal(int valor) {
    final c = valor / 255;
    return c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4) * 1.0;
  }

  return 0.2126 * canal((argb >> 16) & 0xFF) +
      0.7152 * canal((argb >> 8) & 0xFF) +
      0.0722 * canal(argb & 0xFF);
}

/// Contraste WCAG entre dos colores, de 1 a 21.
double contraste(int a, int b) {
  final la = luminancia(a);
  final lb = luminancia(b);
  final (claro, oscuro) = la > lb ? (la, lb) : (lb, la);
  return (claro + 0.05) / (oscuro + 0.05);
}

const _blanco = 0xFFFFFFFF;

/// Contraste mínimo para texto normal (WCAG AA).
const contrasteMinimo = 4.5;

/// `true` si el texto blanco se lee bien sobre [argb]. La app del cliente
/// pone texto blanco sobre el color principal (barra superior, botones).
bool textoBlancoLegible(int argb) =>
    contraste(argb, _blanco) >= contrasteMinimo;

/// Color de texto que mejor se lee sobre [argb]: blanco o casi negro.
int textoSobre(int argb) =>
    contraste(argb, _blanco) >= contraste(argb, 0xFF0F172A)
    ? _blanco
    : 0xFF0F172A;

/// Colores sugeridos para la marca, con nombre para leerlos en voz alta.
const coloresSugeridos = <(String, String)>[
  ('Azul marino', '#1F3A5F'),
  ('Azul', '#1D4ED8'),
  ('Turquesa', '#0F766E'),
  ('Verde', '#15803D'),
  ('Vino', '#7F1D1D'),
  ('Rojo', '#B91C1C'),
  ('Naranja', '#C2410C'),
  ('Ámbar', '#F2A900'),
  ('Morado', '#5B21B6'),
  ('Carbón', '#334155'),
];

/// Tipos de imagen que acepta el bucket `catalogo`.
enum TipoImagen {
  png('image/png', 'png'),
  jpeg('image/jpeg', 'jpg'),
  webp('image/webp', 'webp');

  const TipoImagen(this.mime, this.extension);

  final String mime;
  final String extension;
}

/// Tipo de imagen según sus primeros bytes (no por el nombre del archivo,
/// que puede mentir), o null si no es PNG, JPEG ni WebP.
TipoImagen? tipoDeImagen(Uint8List bytes) {
  bool empieza(List<int> firma, [int desde = 0]) {
    if (bytes.length < desde + firma.length) return false;
    for (var i = 0; i < firma.length; i++) {
      if (bytes[desde + i] != firma[i]) return false;
    }
    return true;
  }

  if (empieza(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return TipoImagen.png;
  }
  if (empieza(const [0xFF, 0xD8, 0xFF])) return TipoImagen.jpeg;
  // RIFF....WEBP
  if (empieza(const [0x52, 0x49, 0x46, 0x46]) &&
      empieza(const [0x57, 0x45, 0x42, 0x50], 8)) {
    return TipoImagen.webp;
  }
  return null;
}

/// Null si [bytes] sirve como logo; si no, el motivo para mostrar.
String? validarLogo(Uint8List bytes) {
  if (tipoDeImagen(bytes) == null) {
    return 'El logo debe ser una imagen PNG, JPG o WebP.';
  }
  if (bytes.length > pesoMaximoLogo) {
    return 'El logo pesa más de 2 MB. Usa una imagen más liviana.';
  }
  return null;
}

/// Carpeta del bucket `catalogo` donde va el logo de un distribuidor.
String carpetaLogo(String distribuidorId) => '$distribuidorId/marca/';

/// Ruta dentro del bucket `catalogo` del logo publicado en [url], si es un
/// logo de [distribuidorId] subido por el panel; si no (otra carpeta, otro
/// sitio), null: esos archivos no se tocan.
String? rutaDeLogo(String url, String distribuidorId) {
  const marcador = '/storage/v1/object/public/catalogo/';
  final indice = url.indexOf(marcador);
  if (indice < 0) return null;
  final ruta = Uri.decodeComponent(
    url.substring(indice + marcador.length).split('?').first,
  );
  return ruta.startsWith(carpetaLogo(distribuidorId)) && !ruta.contains('..')
      ? ruta
      : null;
}
