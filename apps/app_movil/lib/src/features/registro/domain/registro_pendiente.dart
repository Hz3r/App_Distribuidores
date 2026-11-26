/// Lo que queda guardado en la cuenta al crearla, para canjear el código y
/// completar los datos de la bodega en cuanto haya sesión (ver
/// `docs/contrato.md`, sección 7). Lógica pura: sin Flutter ni Supabase.
///
/// Vive en `user_metadata`, bajo la clave [clave]. Así el registro funciona
/// igual si Supabase exige confirmar el correo (la sesión llega al ingresar)
/// o no, y un corte a mitad se retoma en el siguiente ingreso.
final class RegistroPendiente {
  const RegistroPendiente({
    required this.codigo,
    required this.distribuidorId,
    this.documento,
    this.direccion,
    this.referencia,
    this.telefono,
  });

  /// Clave en `user_metadata`.
  static const clave = 'registro_pendiente';

  /// Código de invitación ya validado con `consultar_invitacion`.
  final String codigo;

  /// Distribuidor de la invitación, tal como lo devolvió
  /// `consultar_invitacion`. Es el de la membresía que crea el canje: se usa
  /// para `completar_datos_negocio`.
  final String distribuidorId;

  final String? documento;
  final String? direccion;
  final String? referencia;
  final String? telefono;

  /// Hay algo que pasar a `completar_datos_negocio`. Las invitaciones de
  /// personal nunca lo tienen.
  bool get tieneDatosNegocio =>
      documento != null ||
      direccion != null ||
      referencia != null ||
      telefono != null;

  /// Lo que se agrega a `user_metadata`: `{registro_pendiente: {...}}`.
  Map<String, dynamic> toMetadata() => {
    clave: {
      'codigo': codigo,
      'distribuidor_id': distribuidorId,
      'documento': documento,
      'direccion': direccion,
      'referencia': referencia,
      'telefono': telefono,
    },
  };

  /// Lee el pendiente de todo el `user_metadata`. `null` si no hay, si se
  /// limpió (la clave vale `null`) o si los datos están mal formados.
  static RegistroPendiente? desdeMetadata(Map<String, dynamic>? userMetadata) {
    final datos = userMetadata?[clave];
    if (datos is! Map) return null;
    final codigo = datos['codigo'];
    final distribuidorId = datos['distribuidor_id'];
    if (codigo is! String || distribuidorId is! String) return null;

    final opcionales = <String?>[];
    for (final nombre in const [
      'documento',
      'direccion',
      'referencia',
      'telefono',
    ]) {
      final valor = datos[nombre];
      if (valor != null && valor is! String) return null;
      opcionales.add(valor as String?);
    }
    return RegistroPendiente(
      codigo: codigo,
      distribuidorId: distribuidorId,
      documento: opcionales[0],
      direccion: opcionales[1],
      referencia: opcionales[2],
      telefono: opcionales[3],
    );
  }
}
