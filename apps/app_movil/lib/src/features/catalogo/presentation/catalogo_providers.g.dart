// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogo_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.

@ProviderFor(catalogoRepositorio)
final catalogoRepositorioProvider = CatalogoRepositorioProvider._();

/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.

final class CatalogoRepositorioProvider
    extends
        $FunctionalProvider<
          CatalogoRepositorio,
          CatalogoRepositorio,
          CatalogoRepositorio
        >
    with $Provider<CatalogoRepositorio> {
  /// Repositorio inyectable; las pruebas lo reemplazan con un doble.
  ///
  /// Es el único lugar de `presentation` que construye la implementación de
  /// `data`: las pantallas dependen solo de este provider y de `domain`.
  CatalogoRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogoRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogoRepositorioHash();

  @$internal
  @override
  $ProviderElement<CatalogoRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogoRepositorio create(Ref ref) {
    return catalogoRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogoRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogoRepositorio>(value),
    );
  }
}

String _$catalogoRepositorioHash() =>
    r'a483f98a008d270f5d9c13d8d051eb68226f5b72';

/// Catálogo del distribuidor activo con los precios de la lista de la bodega.
///
/// Se guarda en memoria mientras dure la sesión (inicio, catálogo y detalle
/// leen el mismo) y se vuelve a cargar al cambiar de distribuidor o de lista;
/// `ref.invalidate(catalogoProvider)` lo refresca. Sin membresía activa
/// falla con [StateError].

@ProviderFor(catalogo)
final catalogoProvider = CatalogoProvider._();

/// Catálogo del distribuidor activo con los precios de la lista de la bodega.
///
/// Se guarda en memoria mientras dure la sesión (inicio, catálogo y detalle
/// leen el mismo) y se vuelve a cargar al cambiar de distribuidor o de lista;
/// `ref.invalidate(catalogoProvider)` lo refresca. Sin membresía activa
/// falla con [StateError].

final class CatalogoProvider
    extends
        $FunctionalProvider<AsyncValue<Catalogo>, Catalogo, FutureOr<Catalogo>>
    with $FutureModifier<Catalogo>, $FutureProvider<Catalogo> {
  /// Catálogo del distribuidor activo con los precios de la lista de la bodega.
  ///
  /// Se guarda en memoria mientras dure la sesión (inicio, catálogo y detalle
  /// leen el mismo) y se vuelve a cargar al cambiar de distribuidor o de lista;
  /// `ref.invalidate(catalogoProvider)` lo refresca. Sin membresía activa
  /// falla con [StateError].
  CatalogoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogoHash();

  @$internal
  @override
  $FutureProviderElement<Catalogo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Catalogo> create(Ref ref) {
    return catalogo(ref);
  }
}

String _$catalogoHash() => r'89c8cf2c3bb0a2d8bb4c1b342899fbfdc490d4af';

/// Filtros elegidos en el catálogo. Se conservan sin pantallas que los
/// escuchen (el inicio elige una categoría antes de abrir el catálogo) y
/// vuelven a empezar al cambiar de distribuidor.

@ProviderFor(FiltrosCatalogoActuales)
final filtrosCatalogoActualesProvider = FiltrosCatalogoActualesProvider._();

/// Filtros elegidos en el catálogo. Se conservan sin pantallas que los
/// escuchen (el inicio elige una categoría antes de abrir el catálogo) y
/// vuelven a empezar al cambiar de distribuidor.
final class FiltrosCatalogoActualesProvider
    extends $NotifierProvider<FiltrosCatalogoActuales, FiltrosCatalogo> {
  /// Filtros elegidos en el catálogo. Se conservan sin pantallas que los
  /// escuchen (el inicio elige una categoría antes de abrir el catálogo) y
  /// vuelven a empezar al cambiar de distribuidor.
  FiltrosCatalogoActualesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filtrosCatalogoActualesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filtrosCatalogoActualesHash();

  @$internal
  @override
  FiltrosCatalogoActuales create() => FiltrosCatalogoActuales();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FiltrosCatalogo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FiltrosCatalogo>(value),
    );
  }
}

String _$filtrosCatalogoActualesHash() =>
    r'b13d613992fb610ea8b44a3dcc569b7fb2c5054e';

/// Filtros elegidos en el catálogo. Se conservan sin pantallas que los
/// escuchen (el inicio elige una categoría antes de abrir el catálogo) y
/// vuelven a empezar al cambiar de distribuidor.

abstract class _$FiltrosCatalogoActuales extends $Notifier<FiltrosCatalogo> {
  FiltrosCatalogo build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FiltrosCatalogo, FiltrosCatalogo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FiltrosCatalogo, FiltrosCatalogo>,
              FiltrosCatalogo,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
