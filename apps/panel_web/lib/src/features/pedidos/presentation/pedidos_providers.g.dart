// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedidos_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

@ProviderFor(pedidosRepositorio)
final pedidosRepositorioProvider = PedidosRepositorioProvider._();

/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

final class PedidosRepositorioProvider
    extends
        $FunctionalProvider<
          PedidosRepositorio,
          PedidosRepositorio,
          PedidosRepositorio
        >
    with $Provider<PedidosRepositorio> {
  /// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
  /// lugar de `presentation` que construye la implementación de `data`.
  PedidosRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pedidosRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pedidosRepositorioHash();

  @$internal
  @override
  $ProviderElement<PedidosRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PedidosRepositorio create(Ref ref) {
    return pedidosRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PedidosRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PedidosRepositorio>(value),
    );
  }
}

String _$pedidosRepositorioHash() =>
    r'f42e87dcaed3b20ec5cdcf6dc8b965a054a71b83';

/// Pedidos recientes del distribuidor activo, del más nuevo al más antiguo.

@ProviderFor(pedidos)
final pedidosProvider = PedidosProvider._();

/// Pedidos recientes del distribuidor activo, del más nuevo al más antiguo.

final class PedidosProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Pedido>>,
          List<Pedido>,
          FutureOr<List<Pedido>>
        >
    with $FutureModifier<List<Pedido>>, $FutureProvider<List<Pedido>> {
  /// Pedidos recientes del distribuidor activo, del más nuevo al más antiguo.
  PedidosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pedidosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pedidosHash();

  @$internal
  @override
  $FutureProviderElement<List<Pedido>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Pedido>> create(Ref ref) {
    return pedidos(ref);
  }
}

String _$pedidosHash() => r'f0b67463f7f45ee50049a13f0927192494f8cf6f';

/// Pagos de un pedido.

@ProviderFor(pagosDePedido)
final pagosDePedidoProvider = PagosDePedidoFamily._();

/// Pagos de un pedido.

final class PagosDePedidoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Pago>>,
          List<Pago>,
          FutureOr<List<Pago>>
        >
    with $FutureModifier<List<Pago>>, $FutureProvider<List<Pago>> {
  /// Pagos de un pedido.
  PagosDePedidoProvider._({
    required PagosDePedidoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pagosDePedidoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pagosDePedidoHash();

  @override
  String toString() {
    return r'pagosDePedidoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Pago>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Pago>> create(Ref ref) {
    final argument = this.argument as String;
    return pagosDePedido(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PagosDePedidoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pagosDePedidoHash() => r'3b7660422c495a574ac5b42e66e7f327e7481316';

/// Pagos de un pedido.

final class PagosDePedidoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Pago>>, String> {
  PagosDePedidoFamily._()
    : super(
        retry: null,
        name: r'pagosDePedidoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Pagos de un pedido.

  PagosDePedidoProvider call(String pedidoId) =>
      PagosDePedidoProvider._(argument: pedidoId, from: this);

  @override
  String toString() => r'pagosDePedidoProvider';
}

/// Escrituras de pedidos y pagos. Cada una vuelve a leer lo que cambió.
/// Lanzan [ErrorPedidos]; la pantalla lo convierte en mensaje con
/// [mensajeDePedidos].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.

@ProviderFor(accionesPedidos)
final accionesPedidosProvider = AccionesPedidosProvider._();

/// Escrituras de pedidos y pagos. Cada una vuelve a leer lo que cambió.
/// Lanzan [ErrorPedidos]; la pantalla lo convierte en mensaje con
/// [mensajeDePedidos].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.

final class AccionesPedidosProvider
    extends
        $FunctionalProvider<AccionesPedidos, AccionesPedidos, AccionesPedidos>
    with $Provider<AccionesPedidos> {
  /// Escrituras de pedidos y pagos. Cada una vuelve a leer lo que cambió.
  /// Lanzan [ErrorPedidos]; la pantalla lo convierte en mensaje con
  /// [mensajeDePedidos].
  ///
  /// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
  /// usando el `ref` después de esperar a la red.
  AccionesPedidosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accionesPedidosProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accionesPedidosHash();

  @$internal
  @override
  $ProviderElement<AccionesPedidos> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccionesPedidos create(Ref ref) {
    return accionesPedidos(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccionesPedidos value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccionesPedidos>(value),
    );
  }
}

String _$accionesPedidosHash() => r'7b8ccce7e8ab0a90ad21cf9e9ed635e6359a0afc';
