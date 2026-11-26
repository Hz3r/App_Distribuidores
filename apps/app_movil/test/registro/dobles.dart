import 'dart:async';

import 'package:app_movil/app.dart';
import 'package:app_movil/src/features/catalogo/domain/catalogo.dart';
import 'package:app_movil/src/features/catalogo/presentation/catalogo_providers.dart';
import 'package:app_movil/src/features/inicio/presentation/inicio_providers.dart';
import 'package:app_movil/src/features/registro/domain/cuentas_repositorio.dart';
import 'package:app_movil/src/features/registro/domain/datos_registro.dart';
import 'package:app_movil/src/features/registro/domain/invitaciones_repositorio.dart';
import 'package:app_movil/src/features/registro/domain/registro_pendiente.dart';
import 'package:app_movil/src/features/registro/presentation/registro_providers.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/domain/membresias_repositorio.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:app_movil/src/router/app_router.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../catalogo/montar_cliente.dart' show CatalogoRepositorioFijo;
import '../inicio/fabricas_pedidos.dart';

/// Doble de [InvitacionesRepositorio]: registra las llamadas. Por defecto
/// responde al instante; con [pendientes] o [canjePendiente] la respuesta
/// espera a que la prueba la complete.
class InvitacionesRepositorioDoble implements InvitacionesRepositorio {
  InvitacionesRepositorioDoble({this.bitacora});

  /// Si no es null, cada canje se anota aquí, para comprobar el orden de las
  /// llamadas entre varios dobles.
  final List<String>? bitacora;

  final consultas = <String>[];
  final canjes = <String>[];

  /// Respuesta de `consultar` para los códigos sin respuesta pendiente.
  ResultadoConsulta respuesta = const CodigoNoValido();

  /// Consultas que quedan esperando, por código.
  final pendientes = <String, Completer<ResultadoConsulta>>{};

  /// Respuesta de `canjear`.
  bool canjeOk = true;

  /// Si no es null, `canjear` espera a que la prueba lo complete.
  Completer<bool>? canjePendiente;

  /// Si no es null, `canjear` lo lanza.
  Object? errorCanje;

  @override
  Future<ResultadoConsulta> consultar(String codigo) async {
    consultas.add(codigo);
    final pendiente = pendientes[codigo];
    if (pendiente != null) return pendiente.future;
    return respuesta;
  }

  @override
  Future<bool> canjear(String codigo) async {
    canjes.add(codigo);
    bitacora?.add('canjear $codigo');
    final error = errorCanje;
    if (error != null) throw error;
    final pendiente = canjePendiente;
    if (pendiente != null) return pendiente.future;
    return canjeOk;
  }
}

/// Doble de [CuentasRepositorio]: registra las llamadas. Por defecto
/// responde al instante; con [crearPendiente] o [ingresoPendiente] la
/// respuesta espera a que la prueba la complete.
class CuentasRepositorioDoble implements CuentasRepositorio {
  CuentasRepositorioDoble({this.pendiente, this.bitacora});

  /// Registro pendiente de la cuenta con sesión.
  RegistroPendiente? pendiente;

  /// Si no es null, `completarDatosNegocio` y `limpiarPendiente` se anotan
  /// aquí, para comprobar el orden de las llamadas.
  final List<String>? bitacora;

  final creaciones = <(DatosRegistro, RegistroPendiente)>[];
  ResultadoCrearCuenta resultadoCrear = ResultadoCrearCuenta.conSesion;
  Completer<ResultadoCrearCuenta>? crearPendiente;

  /// Correo y contraseña de cada ingreso.
  final ingresos = <(String, String)>[];
  ResultadoIngreso resultadoIngreso = ResultadoIngreso.ok;
  Completer<ResultadoIngreso>? ingresoPendiente;

  final completados = <(String, RegistroPendiente)>[];
  Object? errorCompletar;

  int limpiezas = 0;
  Object? errorLimpiar;

  @override
  Future<ResultadoCrearCuenta> crearCuenta(
    DatosRegistro datos,
    RegistroPendiente pendiente,
  ) async {
    creaciones.add((datos, pendiente));
    final espera = crearPendiente;
    if (espera != null) return espera.future;
    return resultadoCrear;
  }

  @override
  Future<ResultadoIngreso> ingresar(String correo, String contrasena) async {
    ingresos.add((correo, contrasena));
    final espera = ingresoPendiente;
    if (espera != null) return espera.future;
    return resultadoIngreso;
  }

  @override
  RegistroPendiente? pendienteActual() => pendiente;

  @override
  Future<void> limpiarPendiente() async {
    limpiezas++;
    bitacora?.add('limpiar');
    final error = errorLimpiar;
    if (error != null) throw error;
    pendiente = null;
  }

  @override
  Future<void> completarDatosNegocio(
    String distribuidorId,
    RegistroPendiente pendiente,
  ) async {
    completados.add((distribuidorId, pendiente));
    bitacora?.add('completar $distribuidorId');
    final error = errorCompletar;
    if (error != null) throw error;
  }
}

/// Constructor auxiliar: membresía activa con su distribuidor embebido.
Membresia membresia(
  String distribuidorId, {
  RolMembresia rol = RolMembresia.cliente,
}) {
  return Membresia(
    id: 'm-$distribuidorId-${rol.name}',
    perfilId: 'p1',
    distribuidorId: distribuidorId,
    rol: rol,
    estado: EstadoMembresia.activa,
    creadoEn: DateTime.utc(2026),
    distribuidor: Distribuidor(
      id: distribuidorId,
      nombre: 'Distribuidor $distribuidorId',
      slug: distribuidorId,
      estado: EstadoDistribuidor.activo,
      moneda: 'PEN',
      zonaHoraria: 'America/Lima',
      configTema: const ConfigTema(),
      creadoEn: DateTime.utc(2026),
    ),
  );
}

/// Doble de [MembresiasRepositorio]. Si [respuesta] es un `Completer`, la
/// lectura queda pendiente hasta que la prueba lo complete.
class MembresiasRepositorioDoble implements MembresiasRepositorio {
  List<Membresia> membresias = [];
  String? preferido;
  Object? error;
  Completer<List<Membresia>>? respuesta;
  final guardados = <String>[];
  int lecturas = 0;

  /// Si no es null, cada lectura se anota aquí.
  List<String>? bitacora;

  @override
  Future<List<Membresia>> listarMias() async {
    lecturas++;
    bitacora?.add('listar');
    final pendiente = respuesta;
    if (pendiente != null) return pendiente.future;
    final fallo = error;
    if (fallo != null) throw fallo;
    return membresias;
  }

  @override
  String? distribuidorPreferido() => preferido;

  @override
  Future<void> guardarDistribuidorPreferido(String distribuidorId) async {
    guardados.add(distribuidorId);
    preferido = distribuidorId;
  }
}

/// Controlador de acceso falso: parte de un acceso fijo y cuenta las
/// recargas. No toca `Supabase.instance`.
class ControlAccesoFalso extends ControlAcceso {
  ControlAccesoFalso(this.inicial);

  final Acceso inicial;
  int recargas = 0;

  @override
  Acceso build() => inicial;

  @override
  Future<void> recargar() async => recargas++;
}

/// Monta la app completa (router y tema reales) con los dobles, en un
/// tamaño de teléfono. Devuelve el router para navegar desde la prueba.
/// [overrides] agrega otros reemplazos (por ejemplo, la sesión y las
/// membresías para usar el control de acceso real). El catálogo y los
/// pedidos del inicio salen vacíos de dobles, para no tocar Supabase.
Future<GoRouter> montarApp(
  WidgetTester tester, {
  required ControlAcceso control,
  InvitacionesRepositorio? repositorio,
  CuentasRepositorio? cuentas,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      controlAccesoProvider.overrideWith(() => control),
      invitacionesRepositorioProvider.overrideWithValue(
        repositorio ?? InvitacionesRepositorioDoble(),
      ),
      cuentasRepositorioProvider.overrideWithValue(
        cuentas ?? CuentasRepositorioDoble(),
      ),
      catalogoRepositorioProvider.overrideWithValue(
        CatalogoRepositorioFijo(
          const Catalogo(categorias: [], productos: [], preciosLista: {}),
        ),
      ),
      pedidosResumenRepositorioProvider.overrideWithValue(
        PedidosResumenRepositorioFijo(),
      ),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const AppMovil()),
  );
  await tester.pumpAndSettle();
  return container.read(appRouterProvider);
}
