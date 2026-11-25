/// Formato del código de invitación. Lógica pura: sin Flutter ni Supabase.
library;

/// Largo de un código de invitación (lo genera `crear_invitacion`).
const largoCodigo = 8;

/// Espacios y guiones: se aceptan al pegar o escribir, pero no son parte
/// del código.
final _separadores = RegExp(r'[\s-]');

/// Quita espacios y guiones, pasa a mayúsculas y corta a [largoCodigo].
String normalizarCodigo(String entrada) {
  final limpio = entrada.replaceAll(_separadores, '').toUpperCase();
  return limpio.length > largoCodigo
      ? limpio.substring(0, largoCodigo)
      : limpio;
}

/// `true` si [codigo] ya tiene los [largoCodigo] caracteres.
bool codigoCompleto(String codigo) => codigo.length == largoCodigo;
