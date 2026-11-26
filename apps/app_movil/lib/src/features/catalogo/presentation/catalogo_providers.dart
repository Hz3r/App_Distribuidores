import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/lectura_vigente.dart';
import '../../sesion/presentation/sesion_activa.dart';
import '../data/catalogo_repositorio_supabase.dart';
import '../domain/catalogo.dart';
import '../domain/catalogo_repositorio.dart';
import '../domain/filtros_catalogo.dart';

part 'catalogo_providers.g.dart';

/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.
@Riverpod(keepAlive: true)
CatalogoRepositorio catalogoRepositorio(Ref ref) =>
    CatalogoRepositorioSupabase(supabase);

/// Catálogo del distribuidor activo con los precios de la lista de la bodega.
///
/// Se guarda en memoria mientras dure la sesión (inicio, catálogo y detalle
/// leen el mismo) y se vuelve a cargar al cambiar de distribuidor o de rol;
/// `ref.invalidate(catalogoProvider)` lo refresca. Sin membresía activa
/// falla con [StateError]. Sin reintentos automáticos: un fallo se ve de
/// inmediato con "Reintentar".
@Riverpod(keepAlive: true, retry: sinReintentos)
Future<Catalogo> catalogo(Ref ref) async {
  final (identidad: (:distribuidorId, :clienteNegocioId), :esCliente) = ref
      .watch(
        membresiaActivaProvider.select(
          (m) => (
            identidad: identidadCatalogo(m),
            esCliente: m?.rol == RolMembresia.cliente,
          ),
        ),
      );
  if (distribuidorId == null) {
    throw StateError('No hay un distribuidor activo para leer el catálogo.');
  }
  return ref
      .watch(catalogoRepositorioProvider)
      .cargar(
        distribuidorId: distribuidorId,
        esCliente: esCliente,
        clienteNegocioId: clienteNegocioId,
      );
}

/// Para quién es el catálogo de [membresia]: su distribuidor y, si es una
/// bodega, su `clienteNegocioId` (`null` para otros roles). El catálogo se
/// recarga cuando cambia, y las pantallas solo usan uno con esta identidad.
({String? distribuidorId, String? clienteNegocioId}) identidadCatalogo(
  Membresia? membresia,
) => (
  distribuidorId: membresia?.distribuidorId,
  clienteNegocioId: membresia?.rol == RolMembresia.cliente
      ? membresia?.clienteNegocioId
      : null,
);

/// El catálogo como lo leen las pantallas: la [lectura] de [catalogoProvider]
/// y el [catalogo], solo si es de la membresía activa (mismo distribuidor y
/// misma bodega, ver [identidadCatalogo]). Mientras llega el de otra,
/// [catalogo] es `null` y la pantalla dice "cargando" (o el error): nunca
/// muestra productos ni precios de la anterior, ni deja agregarlos. Al
/// deslizar para recargar sigue siendo el actual.
({AsyncValue<Catalogo> lectura, Catalogo? catalogo}) observarCatalogo(
  WidgetRef ref,
) {
  final (:distribuidorId, :clienteNegocioId) = ref.watch(
    membresiaActivaProvider.select(identidadCatalogo),
  );
  final lectura = ref.watch(catalogoProvider);
  return (
    lectura: lectura,
    catalogo: lectura.valorVigente(
      (c) => c.esDe(
        distribuidorId: distribuidorId,
        clienteNegocioId: clienteNegocioId,
      ),
    ),
  );
}

/// Filtros elegidos en el catálogo. Se conservan sin pantallas que los
/// escuchen (el inicio elige una categoría antes de abrir el catálogo) y
/// vuelven a empezar al cambiar de distribuidor.
@Riverpod(keepAlive: true)
class FiltrosCatalogoActuales extends _$FiltrosCatalogoActuales {
  @override
  FiltrosCatalogo build() {
    ref.watch(membresiaActivaProvider.select((m) => m?.distribuidorId));
    return const FiltrosCatalogo();
  }

  void fijar(FiltrosCatalogo filtros) => state = filtros;
}
