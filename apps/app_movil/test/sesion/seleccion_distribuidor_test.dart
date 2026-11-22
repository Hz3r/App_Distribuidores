import 'package:app_movil/src/features/seleccion_distribuidor/presentation/seleccion_distribuidor_screen.dart';
import 'package:app_movil/src/features/sesion/domain/acceso.dart';
import 'package:app_movil/src/features/sesion/presentation/control_acceso.dart';
import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Constructor auxiliar: membresía activa con su distribuidor embebido.
Membresia membresia(String distribuidorId, String nombre, RolMembresia rol) {
  return Membresia(
    id: 'm-$distribuidorId',
    perfilId: 'p1',
    distribuidorId: distribuidorId,
    rol: rol,
    estado: EstadoMembresia.activa,
    creadoEn: DateTime.utc(2026),
    distribuidor: Distribuidor(
      id: distribuidorId,
      nombre: nombre,
      slug: distribuidorId,
      estado: EstadoDistribuidor.activo,
      moneda: 'PEN',
      zonaHoraria: 'America/Lima',
      configTema: const ConfigTema(),
      creadoEn: DateTime.utc(2026),
    ),
  );
}

/// Controlador falso: parte de un acceso fijo y registra las elecciones.
class ControlAccesoFalso extends ControlAcceso {
  ControlAccesoFalso(this.inicial);

  final Acceso inicial;
  final elegidos = <String>[];

  @override
  Acceso build() => inicial;

  @override
  Future<void> elegirDistribuidor(String distribuidorId) async {
    elegidos.add(distribuidorId);
  }
}

void main() {
  testWidgets('muestra los distribuidores y al tocar el segundo lo elige', (
    tester,
  ) async {
    final control = ControlAccesoFalso(
      ConAcceso(
        membresias: [
          membresia('d1', 'Licores Norte', RolMembresia.cliente),
          membresia('d2', 'Bebidas Sur', RolMembresia.repartidor),
        ],
        activa: null,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [controlAccesoProvider.overrideWith(() => control)],
        child: const MaterialApp(home: SeleccionDistribuidorScreen()),
      ),
    );

    expect(find.text('Licores Norte'), findsOneWidget);
    expect(find.text('Bebidas Sur'), findsOneWidget);
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Repartidor'), findsOneWidget);

    await tester.tap(find.text('Bebidas Sur'));
    await tester.pump();

    expect(control.elegidos, ['d2']);
  });
}
