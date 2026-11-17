import 'package:app_movil/src/shared/widgets/pantalla_placeholder.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PantallaPlaceholder muestra título y descripción', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PantallaPlaceholder(titulo: 'Catálogo', descripcion: 'Pendiente'),
      ),
    );

    expect(find.text('Catálogo'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
  });
}
