import 'dart:async';

import 'package:app_movil/app.dart';
import 'package:app_movil/src/features/registro/domain/invitaciones_repositorio.dart';
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
    final pendiente = canjePendiente;
    if (pendiente != null) return pendiente.future;
    return canjeOk;
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
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const AppMovil()),
  );
  await tester.pumpAndSettle();
  return container.read(appRouterProvider);
}
