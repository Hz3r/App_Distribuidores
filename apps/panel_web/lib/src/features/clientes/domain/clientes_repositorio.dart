import 'package:core/core.dart';

/// Condiciones de crédito de un cliente. Solo el admin las cambia.
class CreditoCliente {
  const CreditoCliente.sinCredito()
    : habilitado = false,
      limiteCentimos = null,
      plazoDias = null;

  /// La BD exige límite y plazo mayores a cero: no existe crédito sin tope.
  const CreditoCliente.con({
    required int this.limiteCentimos,
    required int this.plazoDias,
  }) : habilitado = true;

  final bool habilitado;
  final int? limiteCentimos;
  final int? plazoDias;
}

/// Datos editables de un cliente (lo que el formulario manda a guardar).
class DatosCliente {
  const DatosCliente({
    required this.nombreNegocio,
    this.documento,
    this.telefono,
    this.direccion,
    this.referencia,
    this.activo = true,
    this.credito,
  });

  final String nombreNegocio;
  final String? documento;
  final String? telefono;
  final String? direccion;
  final String? referencia;

  /// Un cliente inactivo no puede pedir ni entrar a la app.
  final bool activo;

  /// Null = no tocar el crédito (lo que manda un vendedor).
  final CreditoCliente? credito;
}

/// Persona con acceso a la app a nombre de un cliente (membresía de rol
/// `cliente`).
class PersonaCliente {
  const PersonaCliente({
    required this.membresiaId,
    required this.clienteNegocioId,
    required this.estado,
    this.nombre,
    this.telefono,
  });

  final String membresiaId;
  final String clienteNegocioId;
  final EstadoMembresia estado;
  final String? nombre;
  final String? telefono;
}

/// Por qué falló una operación de clientes o invitaciones.
enum MotivoErrorClientes {
  /// El rol no puede hacer el cambio (un vendedor tocando el crédito, o un
  /// recurso de otro distribuidor).
  sinPermiso,

  /// La invitación ya fue usada: no se puede revocar.
  invitacionUsada,

  /// Dato que la base de datos rechazó.
  datoInvalido,

  /// Red, servicio caído u otro fallo.
  desconocido,
}

class ErrorClientes implements Exception {
  const ErrorClientes(this.motivo);

  final MotivoErrorClientes motivo;

  @override
  String toString() => 'ErrorClientes(${motivo.name})';
}

/// Clientes (bodegas o tiendas) de un distribuidor y sus invitaciones a la
/// app. Las operaciones que fallan lanzan [ErrorClientes].
abstract interface class ClientesRepositorio {
  /// Clientes del distribuidor, activos o no, por nombre.
  Future<List<ClienteNegocio>> listarClientes(String distribuidorId);

  /// Personas que entran a la app a nombre de algún cliente.
  Future<List<PersonaCliente>> listarPersonas(String distribuidorId);

  /// Invitaciones de rol `cliente`, de la más nueva a la más antigua.
  Future<List<Invitacion>> listarInvitaciones(String distribuidorId);

  /// Devuelve el id del cliente creado.
  Future<String> crearCliente(String distribuidorId, DatosCliente datos);

  Future<void> actualizarCliente(String clienteId, DatosCliente datos);

  /// `crear_invitacion` con rol `cliente`: genera un código de un solo uso.
  Future<Invitacion> crearInvitacion({
    required String distribuidorId,
    required String clienteId,
    required int diasVigencia,
  });

  /// `revocar_invitacion`. Revocar dos veces no hace nada.
  Future<void> revocarInvitacion(String invitacionId);
}
