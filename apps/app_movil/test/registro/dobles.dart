import 'dart:async';

import 'package:app_movil/app.dart';
import 'package:app_movil/src/features/registro/domain/cuentas_repositorio.dart';
import 'package:app_movil/src/features/registro/domain/datos_registro.dart';
import 'package:app_movil/src/features/registro/domain/invitaciones_repositorio.dart';
import 'package:app_movil/src/features/registro/domain/registro_pendiente.dart';
import 'package:app_movil/src/features/registro/presentation/registro_providers.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:app_movil/src/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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
Future<GoRouter> montarApp(
  WidgetTester tester, {
  required ControlAcceso control,
  InvitacionesRepositorio? repositorio,
  CuentasRepositorio? cuentas,
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
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const AppMovil()),
  );
  await tester.pumpAndSettle();
  return container.read(appRouterProvider);
}
