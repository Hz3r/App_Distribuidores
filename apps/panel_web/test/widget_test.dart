import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/shared/widgets/pantalla_placeholder.dart';

void main() {
  testWidgets('PantallaPlaceholder muestra título y descripción', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PantallaPlaceholder(
          titulo: 'Productos',
          descripcion: 'Pendiente',
        ),
      ),
    );

    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
  });
}
