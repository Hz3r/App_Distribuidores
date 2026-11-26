import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../sesion/presentation/control_acceso.dart';
import '../data/configuracion_repositorio_supabase.dart';
import '../data/selector_imagen_navegador.dart';
import '../domain/configuracion_repositorio.dart';
import '../domain/plan_vigente.dart';
import '../domain/validaciones.dart';

part 'configuracion_providers.g.dart';

// Único lugar de `presentation` que construye las implementaciones de
// `data`; las pruebas reemplazan estos providers con dobles.

@Riverpod(keepAlive: true)
ConfiguracionRepositorio configuracionRepositorio(Ref ref) =>
    ConfiguracionRepositorioSupabase(supabase);

@Riverpod(keepAlive: true)
SelectorImagen selectorImagen(Ref ref) => const SelectorImagenNavegador();

/// Plan del distribuidor activo, o null si no tiene suscripción.
@riverpod
Future<PlanVigente?> planVigente(Ref ref) async {
  final membresia = ref.watch(membresiaActivaProvider);
  if (membresia == null) return null;
  final todas = await ref
      .watch(configuracionRepositorioProvider)
      .listarSuscripciones(membresia.distribuidorId);
  return elegirPlan(todas);
}

/// Qué hacer con el logo al guardar la marca.
sealed class CambioLogo {
  const CambioLogo();
}

final class MantenerLogo extends CambioLogo {
  const MantenerLogo();
}

final class QuitarLogo extends CambioLogo {
  const QuitarLogo();
}

final class NuevoLogo extends CambioLogo {
  const NuevoLogo(this.bytes);

  final Uint8List bytes;
}

/// Escrituras de la configuración. Tras guardar, actualizan el distribuidor
/// en el acceso para que el menú lo muestre al instante. Lanzan
/// [ErrorConfiguracion]; la pantalla lo convierte en mensaje con
/// [mensajeDeConfiguracion].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.
@Riverpod(keepAlive: true)
AccionesConfiguracion accionesConfiguracion(Ref ref) =>
    AccionesConfiguracion(ref);

class AccionesConfiguracion {
  AccionesConfiguracion(this._ref);

  final Ref _ref;

  ConfiguracionRepositorio get _repositorio =>
      _ref.read(configuracionRepositorioProvider);

  Distribuidor get _distribuidor {
    final distribuidor = _ref.read(membresiaActivaProvider)?.distribuidor;
    if (distribuidor == null) {
      throw const ErrorConfiguracion(MotivoErrorConfiguracion.sinPermiso);
    }
    return distribuidor;
  }

  Future<void> guardarNegocio(DatosNegocio datos) async {
    final actualizado = await _repositorio.actualizarNegocio(
      _distribuidor.id,
      datos,
    );
    _ref
        .read(controlAccesoProvider.notifier)
        .actualizarDistribuidor(actualizado);
  }

  /// Guarda nombre comercial, colores y logo. Si se sube un logo nuevo y
  /// luego falla el guardado, borra lo subido; si todo sale bien, borra el
  /// logo anterior (solo si lo subió el panel).
  Future<void> guardarMarca({
    required String nombreComercial,
    required String colorPrimario,
    required String colorSecundario,
    required CambioLogo logo,
  }) async {
    final distribuidor = _distribuidor;
    final anterior = distribuidor.configTema.logoUrl;

    String? subido;
    final String? logoUrl;
    switch (logo) {
      case MantenerLogo():
        logoUrl = anterior;
      case QuitarLogo():
        logoUrl = null;
      case NuevoLogo(:final bytes):
        final tipo = tipoDeImagen(bytes);
        if (tipo == null || validarLogo(bytes) != null) {
          throw const ErrorConfiguracion(MotivoErrorConfiguracion.datoInvalido);
        }
        subido = await _repositorio.subirLogo(distribuidor.id, bytes, tipo);
        logoUrl = subido;
    }

    final Distribuidor actualizado;
    try {
      actualizado = await _repositorio.guardarTema(
        distribuidor.id,
        ConfigTema(
          nombre: nombreComercial.trim(),
          logoUrl: logoUrl,
          colorPrimario: colorPrimario,
          colorSecundario: colorSecundario,
        ),
      );
    } catch (_) {
      if (subido != null) await _borrarSinFallar(subido, distribuidor.id);
      rethrow;
    }

    _ref
        .read(controlAccesoProvider.notifier)
        .actualizarDistribuidor(actualizado);
    if (anterior != null && anterior != logoUrl) {
      await _borrarSinFallar(anterior, distribuidor.id);
    }
  }

  /// Borra un logo que ya no se usa. Si falla, solo queda un archivo
  /// huérfano en el bucket: se registra y no se molesta a la persona.
  Future<void> _borrarSinFallar(String url, String distribuidorId) async {
    final ruta = rutaDeLogo(url, distribuidorId);
    if (ruta == null) return;
    try {
      await _repositorio.borrarArchivo(ruta);
    } catch (e, st) {
      developer.log(
        'No se pudo borrar el logo anterior.',
        name: 'configuracion',
        error: e,
        stackTrace: st,
      );
    }
  }
}

/// Mensaje para la persona según por qué falló la operación.
String mensajeDeConfiguracion(Object error) {
  final motivo = error is ErrorConfiguracion
      ? error.motivo
      : MotivoErrorConfiguracion.desconocido;
  return switch (motivo) {
    MotivoErrorConfiguracion.sinPermiso =>
      'Solo el administrador puede cambiar la configuración.',
    MotivoErrorConfiguracion.datoInvalido =>
      'Hay un dato o un archivo que no es válido. Revísalo e inténtalo de '
          'nuevo.',
    MotivoErrorConfiguracion.desconocido =>
      'No pudimos guardar. Revisa tu conexión e inténtalo de nuevo.',
  };
}
