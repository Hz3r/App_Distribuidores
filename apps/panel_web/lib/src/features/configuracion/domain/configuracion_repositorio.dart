import 'dart:typed_data';

import 'package:core/core.dart';

import 'plan_vigente.dart';
import 'validaciones.dart';

/// Datos del negocio que el admin puede editar (la BD solo deja `nombre` y
/// `telefono`; RUC, rubro y zona horaria los cambia la plataforma).
class DatosNegocio {
  const DatosNegocio({required this.nombre, this.telefono});

  final String nombre;
  final String? telefono;
}

/// Imagen elegida por la persona, aún sin subir.
class ImagenElegida {
  const ImagenElegida({required this.nombre, required this.bytes});

  final String nombre;
  final Uint8List bytes;
}

/// Por qué falló una operación de configuración.
enum MotivoErrorConfiguracion {
  /// La cuenta no es admin de este distribuidor (o perdió el acceso).
  sinPermiso,

  /// Dato o archivo que la base de datos o Storage rechazó.
  datoInvalido,

  /// Red, servicio caído u otro fallo.
  desconocido,
}

class ErrorConfiguracion implements Exception {
  const ErrorConfiguracion(this.motivo);

  final MotivoErrorConfiguracion motivo;

  @override
  String toString() => 'ErrorConfiguracion(${motivo.name})';
}

/// Datos del distribuidor, su marca y su plan. Las operaciones que fallan
/// lanzan [ErrorConfiguracion].
abstract interface class ConfiguracionRepositorio {
  /// Guarda nombre y teléfono y devuelve el distribuidor como quedó.
  Future<Distribuidor> actualizarNegocio(
    String distribuidorId,
    DatosNegocio datos,
  );

  /// Reemplaza `config_tema` y devuelve el distribuidor como quedó.
  Future<Distribuidor> guardarTema(String distribuidorId, ConfigTema tema);

  /// Sube el logo a `catalogo/<distribuidorId>/marca/` y devuelve su URL
  /// pública. Cada subida usa un nombre nuevo, así la app no muestra una
  /// copia vieja guardada en caché.
  Future<String> subirLogo(
    String distribuidorId,
    Uint8List bytes,
    TipoImagen tipo,
  );

  /// Borra un archivo del bucket `catalogo` (ruta dentro del bucket).
  Future<void> borrarArchivo(String ruta);

  /// Suscripciones del distribuidor, cada una con su plan.
  Future<List<PlanVigente>> listarSuscripciones(String distribuidorId);
}

/// Abre el selector de archivos del navegador para elegir una imagen.
abstract interface class SelectorImagen {
  /// Null si la persona canceló.
  Future<ImagenElegida?> elegir();
}
