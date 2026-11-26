import 'package:core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
/// leen el mismo) y se vuelve a cargar al cambiar de distribuidor o de lista;
/// `ref.invalidate(catalogoProvider)` lo refresca. Sin membresía activa
/// falla con [StateError].
@Riverpod(keepAlive: true)
Future<Catalogo> catalogo(Ref ref) async {
  final (:distribuidorId, :listaPreciosId) = ref.watch(
    membresiaActivaProvider.select(
      (m) => (
        distribuidorId: m?.distribuidorId,
        listaPreciosId: m?.clienteNegocio?.listaPreciosId,
      ),
    ),
  );
  if (distribuidorId == null) {
    throw StateError('No hay un distribuidor activo para leer el catálogo.');
  }
  return ref
      .watch(catalogoRepositorioProvider)
      .cargar(distribuidorId: distribuidorId, listaPreciosId: listaPreciosId);
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
