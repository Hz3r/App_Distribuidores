import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/config/tema_panel.dart';
import 'package:panel_web/src/features/clientes/presentation/clientes_providers.dart';
import 'package:panel_web/src/features/configuracion/presentation/configuracion_providers.dart';
import 'package:panel_web/src/features/cuenta/presentation/cuenta_providers.dart';
import 'package:panel_web/src/features/pedidos/presentation/pedidos_providers.dart';
import 'package:panel_web/src/features/productos/presentation/catalogo_providers.dart';
import 'package:panel_web/src/features/reportes/presentation/reportes_providers.dart';
import 'package:panel_web/src/features/sesion/presentation/control_acceso.dart';

import 'dobles.dart';
import 'dobles_clientes.dart';
import 'dobles_configuracion.dart';
import 'dobles_pedidos.dart';
import 'dobles_reportes.dart';

/// Monta una sección del panel en una pantalla de escritorio, con la sesión
/// de un admin (o del [rol] dado) del distribuidor `d1`, los repositorios
/// dobles que se pasen y el reloj fijo en [ahoraDePrueba]. Con
/// [distribuidor], la membresía lleva ese distribuidor.
Future<void> montarSeccion(
  WidgetTester tester,
  Widget seccion, {
  CatalogoDoble? catalogo,
  ClientesDoble? clientes,
  PedidosDoble? pedidos,
  ExportadorDoble? exportador,
  ConfiguracionDoble? configuracion,
  SelectorImagenDoble? selector,
  CuentaDoble? cuenta,
  AutenticacionDoble? autenticacion,
  Distribuidor? distribuidor,
  RolMembresia rol = RolMembresia.admin,
  Size tamano = const Size(1280, 900),
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        controlAccesoProvider.overrideWith(
          () => ControlAccesoFalso(
            accesoCon(
              distribuidor == null
                  ? membresia('d1', rol: rol)
                  : membresia(
                      'd1',
                      rol: rol,
                    ).copyWith(distribuidor: distribuidor),
            ),
          ),
        ),
        autenticacionProvider.overrideWithValue(
          autenticacion ?? AutenticacionDoble(),
        ),
        configuracionRepositorioProvider.overrideWithValue(
          configuracion ?? ConfiguracionDoble(),
        ),
        selectorImagenProvider.overrideWithValue(
          selector ?? SelectorImagenDoble(),
        ),
        cuentaRepositorioProvider.overrideWithValue(cuenta ?? CuentaDoble()),
        catalogoRepositorioProvider.overrideWithValue(
          catalogo ?? CatalogoDoble(),
        ),
        clientesRepositorioProvider.overrideWithValue(
          clientes ?? ClientesDoble(),
        ),
        pedidosRepositorioProvider.overrideWithValue(pedidos ?? PedidosDoble()),
        exportadorProvider.overrideWithValue(exportador ?? ExportadorDoble()),
        relojProvider.overrideWithValue(() => ahoraDePrueba),
      ],
      child: MaterialApp(
        theme: temaPanel(),
        // Igual que la app: textos de los componentes en español.
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(body: seccion),
      ),
    ),
  );
  // Deja terminar la primera lectura.
  await tester.pumpAndSettle();
}
