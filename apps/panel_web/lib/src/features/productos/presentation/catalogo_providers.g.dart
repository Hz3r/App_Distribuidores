// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogo_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

@ProviderFor(catalogoRepositorio)
final catalogoRepositorioProvider = CatalogoRepositorioProvider._();

/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

final class CatalogoRepositorioProvider
    extends
        $FunctionalProvider<
          CatalogoRepositorio,
          CatalogoRepositorio,
          CatalogoRepositorio
        >
    with $Provider<CatalogoRepositorio> {
  /// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
  /// lugar de `presentation` que construye la implementación de `data`.
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

/// Categorías del distribuidor activo.

@ProviderFor(categorias)
final categoriasProvider = CategoriasProvider._();

/// Categorías del distribuidor activo.

final class CategoriasProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Categoria>>,
          List<Categoria>,
          FutureOr<List<Categoria>>
        >
    with $FutureModifier<List<Categoria>>, $FutureProvider<List<Categoria>> {
  /// Categorías del distribuidor activo.
  CategoriasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriasHash();

  @$internal
  @override
  $FutureProviderElement<List<Categoria>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Categoria>> create(Ref ref) {
    return categorias(ref);
  }
}

String _$categoriasHash() => r'6741c3e8714bef5d85e6984f4250778cd1889b56';

/// Productos del distribuidor activo, con sus presentaciones. Lo comparten
/// Productos y Disponibilidad.

@ProviderFor(productos)
final productosProvider = ProductosProvider._();

/// Productos del distribuidor activo, con sus presentaciones. Lo comparten
/// Productos y Disponibilidad.

final class ProductosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Producto>>,
          List<Producto>,
          FutureOr<List<Producto>>
        >
    with $FutureModifier<List<Producto>>, $FutureProvider<List<Producto>> {
  /// Productos del distribuidor activo, con sus presentaciones. Lo comparten
  /// Productos y Disponibilidad.
  ProductosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productosHash();

  @$internal
  @override
  $FutureProviderElement<List<Producto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Producto>> create(Ref ref) {
    return productos(ref);
  }
}

String _$productosHash() => r'2a7fd37a01dbb146917db08578b38f758fbefce4';

/// Escrituras del catálogo. Cada una vuelve a leer lo que cambió. Lanzan
/// [ErrorCatalogo]; la pantalla lo convierte en mensaje con [mensajeDe].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.

@ProviderFor(accionesCatalogo)
final accionesCatalogoProvider = AccionesCatalogoProvider._();

/// Escrituras del catálogo. Cada una vuelve a leer lo que cambió. Lanzan
/// [ErrorCatalogo]; la pantalla lo convierte en mensaje con [mensajeDe].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.

final class AccionesCatalogoProvider
    extends
        $FunctionalProvider<
          AccionesCatalogo,
          AccionesCatalogo,
          AccionesCatalogo
        >
    with $Provider<AccionesCatalogo> {
  /// Escrituras del catálogo. Cada una vuelve a leer lo que cambió. Lanzan
  /// [ErrorCatalogo]; la pantalla lo convierte en mensaje con [mensajeDe].
  ///
  /// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
  /// usando el `ref` después de esperar a la red.
  AccionesCatalogoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accionesCatalogoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accionesCatalogoHash();

  @$internal
  @override
  $ProviderElement<AccionesCatalogo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccionesCatalogo create(Ref ref) {
    return accionesCatalogo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccionesCatalogo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccionesCatalogo>(value),
    );
  }
}

String _$accionesCatalogoHash() => r'6553f445c6706f73c1f6cc087bc5f3f2c2c8f688';
