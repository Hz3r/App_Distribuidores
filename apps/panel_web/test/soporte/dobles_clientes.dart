import 'package:core/core.dart';
import 'package:panel_web/src/features/clientes/domain/clientes_repositorio.dart';

/// Momento fijo de las pruebas de clientes e invitaciones.
final ahoraDePrueba = DateTime.utc(2026, 11, 25, 15);

/// Cliente de prueba del distribuidor `d1`.
ClienteNegocio cliente(
  String id, {
  String? nombre,
  String? documento,
  String? telefono,
  String? direccion,
  bool activo = true,
  int? limiteCentimos,
  int? plazoDias,
}) {
  return ClienteNegocio(
    id: id,
    distribuidorId: 'd1',
    nombreNegocio: nombre ?? 'Negocio $id',
    documento: documento,
    telefono: telefono,
    direccion: direccion,
    activo: activo,
    creadoEn: DateTime.utc(2026),
    creditoHabilitado: limiteCentimos != null,
    limiteCreditoCentimos: limiteCentimos,
    plazoCreditoDias: plazoDias,
  );
}

PersonaCliente persona(
  String clienteId, {
  String? nombre,
  EstadoMembresia estado = EstadoMembresia.activa,
}) {
  return PersonaCliente(
    membresiaId: 'm-$clienteId',
    clienteNegocioId: clienteId,
    estado: estado,
    nombre: nombre,
  );
}

/// Invitación de rol cliente. Por defecto vence 7 días después de
/// [ahoraDePrueba] y no está usada ni anulada.
Invitacion invitacion(
  String id, {
  required String clienteId,
  String? codigo,
  DateTime? venceEn,
  bool usada = false,
  bool revocada = false,
}) {
  return Invitacion(
    id: id,
    distribuidorId: 'd1',
    codigo: codigo ?? 'COD${id.toUpperCase()}',
    rol: RolMembresia.cliente,
    clienteNegocioId: clienteId,
    venceEn: venceEn ?? ahoraDePrueba.add(const Duration(days: 7)),
    usadaEn: usada ? ahoraDePrueba.subtract(const Duration(days: 1)) : null,
    revocadaEn: revocada
        ? ahoraDePrueba.subtract(const Duration(days: 1))
        : null,
    creadoEn: ahoraDePrueba.subtract(const Duration(days: 2)),
  );
}

/// Doble de [ClientesRepositorio]: devuelve listas fijas y anota cada
/// escritura en [llamadas], en orden. [fallarEn] hace fallar la operación
/// con ese nombre.
class ClientesDoble implements ClientesRepositorio {
  ClientesDoble({
    List<ClienteNegocio>? clientes,
    List<PersonaCliente>? personas,
    List<Invitacion>? invitaciones,
  }) : clientes = clientes ?? [],
       personas = personas ?? [],
       invitaciones = invitaciones ?? [];

  List<ClienteNegocio> clientes;
  List<PersonaCliente> personas;
  List<Invitacion> invitaciones;
  final llamadas = <String>[];
  String? fallarEn;
  MotivoErrorClientes motivo = MotivoErrorClientes.desconocido;
  int lecturasClientes = 0;
  int lecturasInvitaciones = 0;

  void _anotar(String operacion, String detalle) {
    if (fallarEn == operacion) throw ErrorClientes(motivo);
    llamadas.add('$operacion $detalle');
  }

  String _describir(DatosCliente d) {
    final credito = d.credito;
    final textoCredito = credito == null
        ? 'credito=no-tocar'
        : credito.habilitado
        ? 'credito=${credito.limiteCentimos}/${credito.plazoDias}d'
        : 'credito=no';
    return '${d.nombreNegocio} doc=${d.documento} activo=${d.activo} '
        '$textoCredito';
  }

  @override
  Future<List<ClienteNegocio>> listarClientes(String distribuidorId) async {
    lecturasClientes++;
    if (fallarEn == 'listarClientes') throw ErrorClientes(motivo);
    return clientes;
  }

  @override
  Future<List<PersonaCliente>> listarPersonas(String distribuidorId) async =>
      personas;

  @override
  Future<List<Invitacion>> listarInvitaciones(String distribuidorId) async {
    lecturasInvitaciones++;
    if (fallarEn == 'listarInvitaciones') throw ErrorClientes(motivo);
    return invitaciones;
  }

  @override
  Future<String> crearCliente(String distribuidorId, DatosCliente datos) async {
    _anotar('crearCliente', '$distribuidorId ${_describir(datos)}');
    return 'c-nuevo';
  }

  @override
  Future<void> actualizarCliente(String clienteId, DatosCliente datos) async {
    _anotar('actualizarCliente', '$clienteId ${_describir(datos)}');
  }

  @override
  Future<Invitacion> crearInvitacion({
    required String distribuidorId,
    required String clienteId,
    required int diasVigencia,
  }) async {
    _anotar('crearInvitacion', '$distribuidorId $clienteId ${diasVigencia}d');
    final nueva = invitacion(
      'nueva',
      clienteId: clienteId,
      codigo: 'ABCD2345',
      venceEn: ahoraDePrueba.add(Duration(days: diasVigencia)),
    );
    invitaciones = [nueva, ...invitaciones];
    return nueva;
  }

  @override
  Future<void> revocarInvitacion(String invitacionId) async {
    _anotar('revocarInvitacion', invitacionId);
  }
}
