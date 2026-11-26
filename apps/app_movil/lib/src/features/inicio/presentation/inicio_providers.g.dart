// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inicio_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` del inicio que construye la
/// implementación de `data`.

@ProviderFor(pedidosResumenRepositorio)
final pedidosResumenRepositorioProvider = PedidosResumenRepositorioProvider._();

/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` del inicio que construye la
/// implementación de `data`.

final class PedidosResumenRepositorioProvider
    extends
        $FunctionalProvider<
          PedidosResumenRepositorio,
          PedidosResumenRepositorio,
          PedidosResumenRepositorio
        >
    with $Provider<PedidosResumenRepositorio> {
  /// Repositorio inyectable; las pruebas lo reemplazan con un doble.
  ///
  /// Es el único lugar de `presentation` del inicio que construye la
  /// implementación de `data`.
  PedidosResumenRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pedidosResumenRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pedidosResumenRepositorioHash();

  @$internal
  @override
  $ProviderElement<PedidosResumenRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PedidosResumenRepositorio create(Ref ref) {
    return pedidosResumenRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PedidosResumenRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PedidosResumenRepositorio>(value),
    );
  }
}

String _$pedidosResumenRepositorioHash() =>
    r'd20e78a700def9b02fd3a809b3eb88b74c3b40a1';

/// Hora actual en UTC. Las pruebas la fijan para que el resumen no dependa
/// del día en que corren.

@ProviderFor(reloj)
final relojProvider = RelojProvider._();

/// Hora actual en UTC. Las pruebas la fijan para que el resumen no dependa
/// del día en que corren.

final class RelojProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// Hora actual en UTC. Las pruebas la fijan para que el resumen no dependa
  /// del día en que corren.
  RelojProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relojProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relojHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return reloj(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$relojHash() => r'4063b20e2a3a094255407b57b040e6b6d8b67540';

/// Resumen de compras de la bodega activa para el inicio.
///
/// Se recalcula al cambiar de distribuidor o de bodega;
/// `ref.invalidate(resumenComprasProvider)` lo refresca. Sin una membresía de
/// bodega activa falla con [StateError]. Sin reintentos automáticos: un
/// fallo se ve de inmediato con "Reintentar".

@ProviderFor(resumenCompras)
final resumenComprasProvider = ResumenComprasProvider._();

/// Resumen de compras de la bodega activa para el inicio.
///
/// Se recalcula al cambiar de distribuidor o de bodega;
/// `ref.invalidate(resumenComprasProvider)` lo refresca. Sin una membresía de
/// bodega activa falla con [StateError]. Sin reintentos automáticos: un
/// fallo se ve de inmediato con "Reintentar".

final class ResumenComprasProvider
    extends
        $FunctionalProvider<
          AsyncValue<ResumenCompras>,
          ResumenCompras,
          FutureOr<ResumenCompras>
        >
    with $FutureModifier<ResumenCompras>, $FutureProvider<ResumenCompras> {
  /// Resumen de compras de la bodega activa para el inicio.
  ///
  /// Se recalcula al cambiar de distribuidor o de bodega;
  /// `ref.invalidate(resumenComprasProvider)` lo refresca. Sin una membresía de
  /// bodega activa falla con [StateError]. Sin reintentos automáticos: un
  /// fallo se ve de inmediato con "Reintentar".
  ResumenComprasProvider._()
    : super(
        from: null,
        argument: null,
        retry: sinReintentos,
        name: r'resumenComprasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resumenComprasHash();

  @$internal
  @override
  $FutureProviderElement<ResumenCompras> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ResumenCompras> create(Ref ref) {
    return resumenCompras(ref);
  }
}

String _$resumenComprasHash() => r'b592964f97434963ea88f059a97f6592dead51de';
