// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Indicadores del distribuidor activo, calculados con los pedidos desde el
/// día 1 del mes anterior. Se vuelve a leer cada vez que se abre el
/// Dashboard.

@ProviderFor(datosDashboard)
final datosDashboardProvider = DatosDashboardProvider._();

/// Indicadores del distribuidor activo, calculados con los pedidos desde el
/// día 1 del mes anterior. Se vuelve a leer cada vez que se abre el
/// Dashboard.

final class DatosDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<DatosDashboard>,
          DatosDashboard,
          FutureOr<DatosDashboard>
        >
    with $FutureModifier<DatosDashboard>, $FutureProvider<DatosDashboard> {
  /// Indicadores del distribuidor activo, calculados con los pedidos desde el
  /// día 1 del mes anterior. Se vuelve a leer cada vez que se abre el
  /// Dashboard.
  DatosDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'datosDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$datosDashboardHash();

  @$internal
  @override
  $FutureProviderElement<DatosDashboard> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DatosDashboard> create(Ref ref) {
    return datosDashboard(ref);
  }
}

String _$datosDashboardHash() => r'c8e4e0beb87774f7fba6be69c1d515a2f56e07ae';
