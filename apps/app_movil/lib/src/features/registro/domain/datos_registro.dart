/// Datos del formulario de registro y sus validaciones. Lógica pura: sin
/// Flutter ni Supabase.
library;

/// Lo que la persona escribió en el formulario de registro, ya limpio
/// (`trim`). Los opcionales vacíos llegan como `null`.
///
/// [contrasena] solo viaja a `auth.signUp`: no se guarda en ningún otro lado.
final class DatosRegistro {
  const DatosRegistro({
    required this.nombreEncargado,
    required this.correo,
    required this.contrasena,
    this.documento,
    this.telefono,
    this.direccion,
    this.referencia,
  });

  final String nombreEncargado;
  final String correo;
  final String contrasena;
  final String? documento;
  final String? telefono;
  final String? direccion;
  final String? referencia;
}

final _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _documento = RegExp(r'^(\d{8}|\d{11})$');
final _celular = RegExp(r'^9\d{8}$');
final _espacios = RegExp(r'\s');

/// Obligatorio, de 2 a 80 caracteres.
String? validarNombre(String v) {
  final largo = v.trim().length;
  return largo < 2 || largo > 80 ? 'Escribe tu nombre.' : null;
}

/// Obligatorio, con forma `a@b.c`.
String? validarCorreo(String v) =>
    _correo.hasMatch(v.trim()) ? null : 'Escribe un correo válido.';

/// Mínimo 8 caracteres. No se limpia: los espacios cuentan.
String? validarContrasena(String v) =>
    v.length < 8 ? 'La contraseña debe tener al menos 8 caracteres.' : null;

/// Vacío, DNI (8 dígitos) o RUC (11 dígitos).
String? validarDocumento(String v) {
  final limpio = v.trim();
  if (limpio.isEmpty || _documento.hasMatch(limpio)) return null;
  return 'Debe ser un DNI (8 dígitos) o un RUC (11 dígitos).';
}

/// Vacío, o un celular peruano de 9 dígitos que empieza en 9. Se aceptan
/// espacios y el prefijo `+51`.
String? validarTelefono(String v) {
  var limpio = v.replaceAll(_espacios, '');
  if (limpio.isEmpty) return null;
  if (limpio.startsWith('+51')) limpio = limpio.substring(3);
  return _celular.hasMatch(limpio) ? null : 'Escribe un celular de 9 dígitos.';
}

/// Vacía o de hasta 200 caracteres (el límite de `completar_datos_negocio`).
String? validarDireccion(String v) =>
    v.trim().length > 200 ? 'La dirección es demasiado larga.' : null;
