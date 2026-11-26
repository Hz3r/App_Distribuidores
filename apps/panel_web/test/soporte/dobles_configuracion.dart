import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:panel_web/src/features/configuracion/domain/configuracion_repositorio.dart';
import 'package:panel_web/src/features/configuracion/domain/plan_vigente.dart';
import 'package:panel_web/src/features/configuracion/domain/validaciones.dart';
import 'package:panel_web/src/features/cuenta/domain/cuenta_repositorio.dart';

import 'dobles.dart';

/// PNG válido de 1×1 px, para que `Image.memory` pueda dibujarlo.
final pngDePrueba = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

/// URL pública de un logo del distribuidor `d1` subido por el panel.
const urlLogoD1 =
    'https://demo.supabase.co/storage/v1/object/public/catalogo/d1/marca/logo-1.png';

/// Distribuidor `d1` con datos de plataforma completos.
Distribuidor distribuidorDePrueba({ConfigTema tema = const ConfigTema()}) =>
    membresia('d1').distribuidor!.copyWith(
      nombre: 'Licores del Norte S.A.C.',
      documento: '20601234567',
      rubro: 'Licores',
      telefono: '044 123456',
      slug: 'licores-del-norte',
      configTema: tema,
    );

Plan planDePrueba({
  String nombre = 'Pro',
  int precio = 19900,
  Map<String, dynamic> limites = const {
    'max_clientes': 500,
    'max_productos': 2000,
    'max_usuarios': 15,
  },
}) => Plan(
  id: 'plan-$nombre',
  codigo: nombre.toLowerCase(),
  nombre: nombre,
  precioMensualCentimos: precio,
  moneda: 'PEN',
  limites: limites,
  activo: true,
  creadoEn: DateTime.utc(2026),
);

PlanVigente suscripcionDePrueba({
  EstadoSuscripcion estado = EstadoSuscripcion.activa,
  required DateTime inicio,
  required DateTime fin,
  Plan? plan,
}) {
  final elPlan = plan ?? planDePrueba();
  return PlanVigente(
    suscripcion: Suscripcion(
      id: 's-${estado.name}-${fin.toIso8601String()}',
      distribuidorId: 'd1',
      planId: elPlan.id,
      estado: estado,
      periodoInicio: inicio,
      periodoFin: fin,
      creadoEn: inicio,
    ),
    plan: elPlan,
  );
}

/// Doble de [ConfiguracionRepositorio]: guarda en memoria y anota cada
/// operación en [llamadas]. [fallarEn] hace fallar la operación con ese
/// nombre.
class ConfiguracionDoble implements ConfiguracionRepositorio {
  ConfiguracionDoble({Distribuidor? distribuidor, List<PlanVigente>? planes})
    : distribuidor = distribuidor ?? distribuidorDePrueba(),
      planes = planes ?? [];

  Distribuidor distribuidor;
  List<PlanVigente> planes;
  final llamadas = <String>[];
  String? fallarEn;
  MotivoErrorConfiguracion motivo = MotivoErrorConfiguracion.desconocido;
  int subidas = 0;

  void _anotar(String operacion, String detalle) {
    if (fallarEn == operacion) throw ErrorConfiguracion(motivo);
    llamadas.add('$operacion $detalle');
  }

  @override
  Future<Distribuidor> actualizarNegocio(
    String distribuidorId,
    DatosNegocio datos,
  ) async {
    _anotar(
      'actualizarNegocio',
      '$distribuidorId nombre=${datos.nombre} tel=${datos.telefono}',
    );
    final telefono = datos.telefono?.trim() ?? '';
    return distribuidor = distribuidor.copyWith(
      nombre: datos.nombre,
      telefono: telefono.isEmpty ? null : telefono,
    );
  }

  @override
  Future<Distribuidor> guardarTema(
    String distribuidorId,
    ConfigTema tema,
  ) async {
    _anotar(
      'guardarTema',
      '$distribuidorId nombre=${tema.nombre} logo=${tema.logoUrl} '
          '${tema.colorPrimario} ${tema.colorSecundario}',
    );
    return distribuidor = distribuidor.copyWith(configTema: tema);
  }

  @override
  Future<String> subirLogo(
    String distribuidorId,
    Uint8List bytes,
    TipoImagen tipo,
  ) async {
    _anotar('subirLogo', '$distribuidorId ${tipo.name} ${bytes.length}');
    subidas++;
    return 'https://demo.supabase.co/storage/v1/object/public/catalogo/'
        '${carpetaLogo(distribuidorId)}logo-nuevo-$subidas.${tipo.extension}';
  }

  @override
  Future<void> borrarArchivo(String ruta) async {
    _anotar('borrarArchivo', ruta);
  }

  @override
  Future<List<PlanVigente>> listarSuscripciones(String distribuidorId) async {
    if (fallarEn == 'listarSuscripciones') throw ErrorConfiguracion(motivo);
    return planes;
  }
}

/// Doble de [SelectorImagen]: devuelve [siguiente] (null = canceló).
class SelectorImagenDoble implements SelectorImagen {
  SelectorImagenDoble({this.siguiente});

  ImagenElegida? siguiente;
  bool fallar = false;
  int aperturas = 0;

  @override
  Future<ImagenElegida?> elegir() async {
    aperturas++;
    if (fallar) throw StateError('sin acceso a archivos');
    return siguiente;
  }
}

/// Doble de [CuentaRepositorio] con un perfil en memoria y una contraseña.
class CuentaDoble implements CuentaRepositorio {
  CuentaDoble({Perfil? perfil, this.contrasena = 'Clave2026'})
    : perfil =
          perfil ??
          Perfil(
            id: 'p1',
            nombre: 'Ana Torres',
            telefono: '+51987654321',
            esSuperAdmin: false,
            creadoEn: DateTime.utc(2026),
          );

  Perfil perfil;
  String contrasena;
  final llamadas = <String>[];
  String? fallarEn;
  MotivoErrorCuenta motivo = MotivoErrorCuenta.desconocido;

  @override
  Future<Perfil> leerPerfil() async {
    if (fallarEn == 'leerPerfil') throw ErrorCuenta(motivo);
    return perfil;
  }

  @override
  Future<Perfil> actualizarNombre(String nombre) async {
    if (fallarEn == 'actualizarNombre') throw ErrorCuenta(motivo);
    llamadas.add('actualizarNombre ${nombre.trim()}');
    return perfil = perfil.copyWith(nombre: nombre.trim());
  }

  @override
  Future<void> cambiarContrasena({
    required String actual,
    required String nueva,
  }) async {
    if (fallarEn == 'cambiarContrasena') throw ErrorCuenta(motivo);
    if (actual != contrasena) {
      throw const ErrorCuenta(MotivoErrorCuenta.contrasenaIncorrecta);
    }
    llamadas.add('cambiarContrasena');
    contrasena = nueva;
  }
}
