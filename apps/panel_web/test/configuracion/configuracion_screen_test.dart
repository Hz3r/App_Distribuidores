import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:panel_web/src/features/configuracion/domain/configuracion_repositorio.dart';
import 'package:panel_web/src/features/configuracion/domain/plan_vigente.dart';
import 'package:panel_web/src/features/configuracion/presentation/configuracion_screen.dart';
import 'package:panel_web/src/features/configuracion/presentation/vista_previa_app.dart';

import '../soporte/dobles_clientes.dart';
import '../soporte/dobles_configuracion.dart';
import '../soporte/montar.dart';

/// Campo de texto por su etiqueta.
Finder campo(String etiqueta) => find.widgetWithText(TextFormField, etiqueta);

String textoDe(WidgetTester tester, String etiqueta) =>
    tester.widget<TextFormField>(campo(etiqueta)).controller!.text;

FilledButton botonGuardar(WidgetTester tester) => tester.widget<FilledButton>(
  find.widgetWithText(FilledButton, 'Guardar cambios'),
);

Future<ConfiguracionDoble> montar(
  WidgetTester tester, {
  ConfigTema tema = const ConfigTema(),
  List<PlanVigente>? planes,
  SelectorImagenDoble? selector,
  String? fallarEn,
  Size tamano = const Size(1440, 1000),
}) async {
  final distribuidor = distribuidorDePrueba(tema: tema);
  final repositorio = ConfiguracionDoble(
    distribuidor: distribuidor,
    planes: planes,
  )..fallarEn = fallarEn;
  await montarSeccion(
    tester,
    const ConfiguracionScreen(),
    configuracion: repositorio,
    selector: selector,
    distribuidor: distribuidor,
    tamano: tamano,
  );
  return repositorio;
}

Future<void> irA(WidgetTester tester, String pestana) async {
  await tester.tap(find.widgetWithText(Tab, pestana));
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder boton) async {
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

void main() {
  group('Negocio', () {
    testWidgets('muestra lo editable y los datos de la plataforma', (
      tester,
    ) async {
      await montar(tester);

      expect(
        textoDe(tester, 'Nombre legal o razón social'),
        'Licores del Norte S.A.C.',
      );
      expect(textoDe(tester, 'Teléfono (opcional)'), '044 123456');
      for (final dato in [
        '20601234567',
        'Licores',
        'licores-del-norte',
        'Soles (PEN)',
        'Lima (America/Lima)',
        'Activo',
      ]) {
        expect(find.text(dato), findsOneWidget, reason: dato);
      }
      // Sin cambios no hay nada que guardar.
      expect(botonGuardar(tester).onPressed, isNull);
      expect(find.text('Descartar'), findsNothing);
    });

    testWidgets('valida, guarda y avisa', (tester) async {
      final repositorio = await montar(tester);

      await tester.enterText(campo('Nombre legal o razón social'), '   ');
      await tester.enterText(campo('Teléfono (opcional)'), '98 ABC');
      await tocar(tester, find.text('Guardar cambios'));
      expect(find.text('Escribe el nombre del negocio.'), findsOneWidget);
      expect(
        find.text('Usa solo números, espacios o guiones.'),
        findsOneWidget,
      );
      expect(repositorio.llamadas, isEmpty);

      await tester.enterText(
        campo('Nombre legal o razón social'),
        ' Licores del Norte E.I.R.L. ',
      );
      await tester.enterText(campo('Teléfono (opcional)'), '');
      await tocar(tester, find.text('Guardar cambios'));

      expect(repositorio.llamadas, [
        'actualizarNegocio d1 nombre=Licores del Norte E.I.R.L. tel=',
      ]);
      expect(find.text('Guardamos los datos del negocio.'), findsOneWidget);
      expect(botonGuardar(tester).onPressed, isNull);
    });

    testWidgets('Descartar vuelve a lo guardado', (tester) async {
      await montar(tester);

      await tester.enterText(campo('Teléfono (opcional)'), '999 888 777');
      await tester.pump();
      await tocar(tester, find.text('Descartar'));

      expect(textoDe(tester, 'Teléfono (opcional)'), '044 123456');
      expect(botonGuardar(tester).onPressed, isNull);
    });

    testWidgets('si no se puede guardar lo explica y conserva lo escrito', (
      tester,
    ) async {
      final repositorio = await montar(tester);
      repositorio
        ..fallarEn = 'actualizarNegocio'
        ..motivo = MotivoErrorConfiguracion.sinPermiso;

      await tester.enterText(campo('Teléfono (opcional)'), '999 888 777');
      await tocar(tester, find.text('Guardar cambios'));

      expect(
        find.text('Solo el administrador puede cambiar la configuración.'),
        findsOneWidget,
      );
      expect(textoDe(tester, 'Teléfono (opcional)'), '999 888 777');
    });
  });

  group('Marca', () {
    testWidgets('la vista previa sigue lo que se elige y el nombre vacío usa '
        'el legal', (tester) async {
      await montar(tester, tema: const ConfigTema(nombre: 'Licores'));
      await irA(tester, 'Marca');

      VistaPreviaApp vista() =>
          tester.widget<VistaPreviaApp>(find.byType(VistaPreviaApp));
      expect(vista().nombre, 'Licores');
      expect(vista().colorPrimario, const Color(0xFF1F3A5F));

      await tocar(tester, find.byTooltip('Turquesa').first);
      expect(textoDe(tester, 'Código del color principal'), '#0F766E');
      expect(vista().colorPrimario, const Color(0xFF0F766E));

      await tester.enterText(campo('Nombre comercial (opcional)'), '');
      await tester.pump();
      expect(vista().nombre, 'Licores del Norte S.A.C.');
    });

    testWidgets('avisa si el texto blanco no se lee sobre el color principal', (
      tester,
    ) async {
      await montar(tester);
      await irA(tester, 'Marca');
      const aviso =
          'El texto blanco no se lee bien sobre este color. Elige uno más '
          'oscuro.';
      expect(find.text(aviso), findsNothing);

      await tester.enterText(campo('Código del color principal'), 'f2a900');
      await tester.pump();
      expect(find.text(aviso), findsOneWidget);
    });

    testWidgets('un código de color inválido no deja guardar', (tester) async {
      final repositorio = await montar(tester);
      await irA(tester, 'Marca');

      await tester.enterText(campo('Código del color secundario'), '#12');
      await tocar(tester, find.text('Guardar cambios'));

      expect(
        find.text('Usa un color como #1F3A5F (seis caracteres de 0-9 y A-F).'),
        findsOneWidget,
      );
      expect(repositorio.llamadas, isEmpty);
    });

    testWidgets('subir un logo y guardar: sube, guarda el tema y avisa', (
      tester,
    ) async {
      final selector = SelectorImagenDoble(
        siguiente: ImagenElegida(nombre: 'logo.png', bytes: pngDePrueba),
      );
      final repositorio = await montar(tester, selector: selector);
      await irA(tester, 'Marca');
      expect(find.text('Subir logo'), findsOneWidget);
      expect(find.text('Quitar logo'), findsNothing);

      await tocar(tester, find.text('Subir logo'));
      expect(find.text('Cambiar logo'), findsOneWidget);
      expect(find.text('Quitar logo'), findsOneWidget);
      await tester.enterText(campo('Código del color principal'), '#0f766e');
      await tocar(tester, find.text('Guardar cambios'));

      expect(repositorio.llamadas, [
        'subirLogo d1 png ${pngDePrueba.length}',
        'guardarTema d1 nombre= logo=https://demo.supabase.co/storage/v1/'
            'object/public/catalogo/d1/marca/logo-nuevo-1.png #0F766E #F2A900',
      ]);
      expect(
        find.text('Guardamos tu marca. Tus clientes la verán en la app.'),
        findsOneWidget,
      );
      expect(textoDe(tester, 'Código del color principal'), '#0F766E');
      expect(botonGuardar(tester).onPressed, isNull);
    });

    testWidgets('un archivo que no es imagen se rechaza antes de subirlo', (
      tester,
    ) async {
      final selector = SelectorImagenDoble(
        siguiente: ImagenElegida(
          nombre: 'logo.png',
          bytes: Uint8List.fromList('%PDF-1.7'.codeUnits),
        ),
      );
      final repositorio = await montar(tester, selector: selector);
      await irA(tester, 'Marca');

      await tocar(tester, find.text('Subir logo'));

      expect(
        find.text('El logo debe ser una imagen PNG, JPG o WebP.'),
        findsOneWidget,
      );
      expect(find.text('Subir logo'), findsOneWidget);
      expect(botonGuardar(tester).onPressed, isNull);
      expect(repositorio.llamadas, isEmpty);
    });

    testWidgets('cancelar el selector no cambia nada', (tester) async {
      final selector = SelectorImagenDoble();
      await montar(tester, selector: selector);
      await irA(tester, 'Marca');

      await tocar(tester, find.text('Subir logo'));

      expect(selector.aperturas, 1);
      expect(botonGuardar(tester).onPressed, isNull);
    });

    testWidgets('quitar el logo guardado lo borra al guardar', (tester) async {
      final repositorio = await montar(
        tester,
        tema: const ConfigTema(logoUrl: urlLogoD1),
      );
      await irA(tester, 'Marca');
      expect(find.text('Cambiar logo'), findsOneWidget);

      await tocar(tester, find.text('Quitar logo'));
      expect(find.text('Subir logo'), findsOneWidget);
      await tocar(tester, find.text('Guardar cambios'));

      expect(repositorio.llamadas, [
        'guardarTema d1 nombre= logo=null #1F3A5F #F2A900',
        'borrarArchivo d1/marca/logo-1.png',
      ]);
    });

    testWidgets('lo elegido se conserva al cambiar de pestaña', (tester) async {
      await montar(tester);
      await irA(tester, 'Marca');
      await tester.enterText(campo('Nombre comercial (opcional)'), 'Licores');
      await irA(tester, 'Negocio');
      await irA(tester, 'Marca');

      expect(textoDe(tester, 'Nombre comercial (opcional)'), 'Licores');
    });

    testWidgets('en pantalla angosta la vista previa va debajo, sin '
        'desbordes', (tester) async {
      await montar(tester, tamano: const Size(700, 1000));
      await irA(tester, 'Marca');

      expect(find.byType(VistaPreviaApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Plan', () {
    // ahoraDePrueba: 25 nov 2026.
    final hoy = DateTime(
      ahoraDePrueba.year,
      ahoraDePrueba.month,
      ahoraDePrueba.day,
    );

    testWidgets('muestra el plan, su estado, el precio, el periodo y lo que '
        'incluye', (tester) async {
      await montar(
        tester,
        planes: [
          suscripcionDePrueba(
            inicio: hoy,
            fin: hoy.add(const Duration(days: 29)),
          ),
        ],
      );
      await irA(tester, 'Plan');

      expect(find.text('Pro'), findsOneWidget);
      expect(find.text('Activa'), findsOneWidget);
      expect(find.text('S/ 199.00 al mes'), findsOneWidget);
      expect(find.text('Del 25 nov 2026 al 24 dic 2026'), findsOneWidget);
      expect(find.text('30 días'), findsOneWidget);
      expect(find.text('Usuarios del panel: hasta 15'), findsOneWidget);
      expect(find.text('Productos: hasta 2,000'), findsOneWidget);
      expect(find.textContaining('Escríbenos para renovarlo'), findsNothing);
    });

    testWidgets('avisa cuando vence pronto y cuando ya venció', (tester) async {
      await montar(
        tester,
        planes: [
          suscripcionDePrueba(
            estado: EstadoSuscripcion.prueba,
            inicio: hoy.subtract(const Duration(days: 25)),
            fin: hoy.add(const Duration(days: 2)),
          ),
        ],
      );
      await irA(tester, 'Plan');

      expect(find.text('En prueba'), findsOneWidget);
      expect(
        find.text('Te quedan 3 días. Escríbenos para renovarlo.'),
        findsOneWidget,
      );
    });

    testWidgets('plan vencido', (tester) async {
      await montar(
        tester,
        planes: [
          suscripcionDePrueba(
            estado: EstadoSuscripcion.vencida,
            inicio: DateTime(2026, 10),
            fin: DateTime(2026, 10, 31),
          ),
        ],
      );
      await irA(tester, 'Plan');

      expect(find.text('Vencida'), findsOneWidget);
      expect(
        find.text('Tu plan venció el 31 oct 2026. Escríbenos para renovarlo.'),
        findsOneWidget,
      );
      expect(find.text('Quedan'), findsNothing);
    });

    testWidgets('sin suscripción lo dice', (tester) async {
      await montar(tester);
      await irA(tester, 'Plan');

      expect(find.text('Sin plan registrado'), findsOneWidget);
    });

    testWidgets('si no se puede leer el plan, ofrece reintentar', (
      tester,
    ) async {
      final repositorio = await montar(
        tester,
        fallarEn: 'listarSuscripciones',
        planes: [
          suscripcionDePrueba(
            inicio: hoy,
            fin: hoy.add(const Duration(days: 29)),
          ),
        ],
      );
      await irA(tester, 'Plan');
      expect(find.text('No pudimos cargar esta sección'), findsOneWidget);

      repositorio.fallarEn = null;
      await tocar(tester, find.text('Reintentar'));
      expect(find.text('Pro'), findsOneWidget);
    });
  });
}
