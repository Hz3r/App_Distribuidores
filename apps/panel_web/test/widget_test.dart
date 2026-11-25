import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/config/tema_panel.dart';
import 'package:panel_web/src/shared/widgets/pantalla_placeholder.dart';

void main() {
  testWidgets('PantallaPlaceholder muestra título, descripción y que está '
      'en construcción', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: temaPanel(),
        home: const Scaffold(
          body: PantallaPlaceholder(
            titulo: 'Productos',
            descripcion: 'Catálogo y precios.',
          ),
        ),
      ),
    );

    expect(find.text('Productos'), findsOneWidget);
    expect(find.text('Catálogo y precios.'), findsOneWidget);
    expect(find.text('Esta sección está en construcción.'), findsOneWidget);
  });
}
