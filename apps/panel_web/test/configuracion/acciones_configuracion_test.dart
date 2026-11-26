import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:panel_web/src/features/configuracion/domain/configuracion_repositorio.dart';
import 'package:panel_web/src/features/configuracion/presentation/configuracion_providers.dart';
import 'package:panel_web/src/features/sesion/presentation/control_acceso.dart';

import '../soporte/dobles.dart';
import '../soporte/dobles_configuracion.dart';

void main() {
  late ConfiguracionDoble repositorio;
  late ProviderContainer contenedor;

  void crear(ConfigTema tema) {
    repositorio = ConfiguracionDoble(
      distribuidor: distribuidorDePrueba(tema: tema),
    );
    contenedor = ProviderContainer(
      overrides: [
        controlAccesoProvider.overrideWith(
          () => ControlAccesoFalso(
            accesoCon(
              membresia('d1').copyWith(distribuidor: repositorio.distribuidor),
            ),
          ),
        ),
        configuracionRepositorioProvider.overrideWithValue(repositorio),
      ],
    );
    addTearDown(contenedor.dispose);
  }

  AccionesConfiguracion acciones() =>
      contenedor.read(accionesConfiguracionProvider);

  ConfigTema? temaEnAcceso() =>
      contenedor.read(membresiaActivaProvider)?.distribuidor?.configTema;

  Future<void> guardar(CambioLogo logo, {String nombre = 'Licores'}) =>
      acciones().guardarMarca(
        nombreComercial: nombre,
        colorPrimario: '#0F766E',
        colorSecundario: '#F2A900',
        logo: logo,
      );

  test('mantener el logo guarda el tema con el mismo logo y no borra nada', () async {
    crear(const ConfigTema(logoUrl: urlLogoD1));

    await guardar(const MantenerLogo(), nombre: '  Licores del Norte  ');

    expect(repositorio.llamadas, [
      'guardarTema d1 nombre=Licores del Norte logo=$urlLogoD1 #0F766E #F2A900',
    ]);
    expect(temaEnAcceso()?.colorPrimario, '#0F766E');
  });

  test('un logo nuevo se sube, se guarda y se borra el anterior', () async {
    crear(const ConfigTema(logoUrl: urlLogoD1));

    await guardar(NuevoLogo(pngDePrueba));

    final nuevo = temaEnAcceso()?.logoUrl;
    expect(nuevo, endsWith('/catalogo/d1/marca/logo-nuevo-1.png'));
    expect(repositorio.llamadas, [
      'subirLogo d1 png ${pngDePrueba.length}',
      'guardarTema d1 nombre=Licores logo=$nuevo #0F766E #F2A900',
      'borrarArchivo d1/marca/logo-1.png',
    ]);
  });

  test(
    'si el guardado falla, borra lo recién subido y conserva el anterior',
    () async {
      crear(const ConfigTema(logoUrl: urlLogoD1));
      repositorio.fallarEn = 'guardarTema';

      await expectLater(
        guardar(NuevoLogo(pngDePrueba)),
        throwsA(isA<ErrorConfiguracion>()),
      );

      expect(repositorio.llamadas, [
        'subirLogo d1 png ${pngDePrueba.length}',
        'borrarArchivo d1/marca/logo-nuevo-1.png',
      ]);
      expect(temaEnAcceso()?.logoUrl, urlLogoD1);
    },
  );

  test(
    'si no se puede borrar el logo anterior, igual queda guardado',
    () async {
      crear(const ConfigTema(logoUrl: urlLogoD1));
      repositorio.fallarEn = 'borrarArchivo';

      await guardar(const QuitarLogo());

      expect(repositorio.llamadas.single, startsWith('guardarTema d1'));
      expect(temaEnAcceso()?.logoUrl, isNull);
    },
  );

  test('quitar un logo que no subió el panel no intenta borrarlo', () async {
    crear(const ConfigTema(logoUrl: 'https://otro.com/logo.png'));

    await guardar(const QuitarLogo());

    expect(repositorio.llamadas, hasLength(1));
    expect(temaEnAcceso()?.logoUrl, isNull);
  });

  test('un archivo que no es imagen no se sube', () async {
    crear(const ConfigTema());

    await expectLater(
      guardar(NuevoLogo(Uint8List.fromList('%PDF-1.7'.codeUnits))),
      throwsA(
        isA<ErrorConfiguracion>().having(
          (e) => e.motivo,
          'motivo',
          MotivoErrorConfiguracion.datoInvalido,
        ),
      ),
    );
    expect(repositorio.llamadas, isEmpty);
  });

  test('guardarNegocio actualiza el distribuidor del acceso', () async {
    crear(const ConfigTema());

    await acciones().guardarNegocio(
      const DatosNegocio(nombre: 'Licores SAC', telefono: ''),
    );

    final distribuidor = contenedor.read(membresiaActivaProvider)?.distribuidor;
    expect(distribuidor?.nombre, 'Licores SAC');
    expect(distribuidor?.telefono, isNull);
  });

  test('mensajes de error en lenguaje simple', () {
    expect(
      mensajeDeConfiguracion(
        const ErrorConfiguracion(MotivoErrorConfiguracion.sinPermiso),
      ),
      contains('administrador'),
    );
    expect(mensajeDeConfiguracion(StateError('x')), contains('conexión'));
  });
}
