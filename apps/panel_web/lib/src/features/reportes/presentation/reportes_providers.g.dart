// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reportes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exportador inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

@ProviderFor(exportador)
final exportadorProvider = ExportadorProvider._();

/// Exportador inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

final class ExportadorProvider
    extends $FunctionalProvider<Exportador, Exportador, Exportador>
    with $Provider<Exportador> {
  /// Exportador inyectable; las pruebas lo reemplazan con un doble. Único
  /// lugar de `presentation` que construye la implementación de `data`.
  ExportadorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportadorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportadorHash();

  @$internal
  @override
  $ProviderElement<Exportador> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Exportador create(Ref ref) {
    return exportador(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Exportador value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Exportador>(value),
    );
  }
}

String _$exportadorHash() => r'75d00016f49840adde02f3c4014ff12beaf4c1d2';

/// Pedidos del distribuidor activo creados en [periodo], con sus líneas. Lo
/// usan el reporte en pantalla y la exportación a Excel, así los dos
/// muestran exactamente lo mismo.

@ProviderFor(pedidosDelPeriodo)
final pedidosDelPeriodoProvider = PedidosDelPeriodoFamily._();

/// Pedidos del distribuidor activo creados en [periodo], con sus líneas. Lo
/// usan el reporte en pantalla y la exportación a Excel, así los dos
/// muestran exactamente lo mismo.

final class PedidosDelPeriodoProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Pedido>>,
          List<Pedido>,
          FutureOr<List<Pedido>>
        >
    with $FutureModifier<List<Pedido>>, $FutureProvider<List<Pedido>> {
  /// Pedidos del distribuidor activo creados en [periodo], con sus líneas. Lo
  /// usan el reporte en pantalla y la exportación a Excel, así los dos
  /// muestran exactamente lo mismo.
  PedidosDelPeriodoProvider._({
    required PedidosDelPeriodoFamily super.from,
    required Periodo super.argument,
  }) : super(
         retry: null,
         name: r'pedidosDelPeriodoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pedidosDelPeriodoHash();

  @override
  String toString() {
    return r'pedidosDelPeriodoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Pedido>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Pedido>> create(Ref ref) {
    final argument = this.argument as Periodo;
    return pedidosDelPeriodo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PedidosDelPeriodoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pedidosDelPeriodoHash() => r'9055b529f0eaf0d92dd011365479206a4beaa79e';

/// Pedidos del distribuidor activo creados en [periodo], con sus líneas. Lo
/// usan el reporte en pantalla y la exportación a Excel, así los dos
/// muestran exactamente lo mismo.

final class PedidosDelPeriodoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Pedido>>, Periodo> {
  PedidosDelPeriodoFamily._()
    : super(
        retry: null,
        name: r'pedidosDelPeriodoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Pedidos del distribuidor activo creados en [periodo], con sus líneas. Lo
  /// usan el reporte en pantalla y la exportación a Excel, así los dos
  /// muestran exactamente lo mismo.

  PedidosDelPeriodoProvider call(Periodo periodo) =>
      PedidosDelPeriodoProvider._(argument: periodo, from: this);

  @override
  String toString() => r'pedidosDelPeriodoProvider';
}
