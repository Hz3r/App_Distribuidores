// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'carrito_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Carrito de la sesión, solo en memoria. Se vacía cuando cambia la
/// membresía activa: otro distribuidor, otra persona o cierre de sesión.

@ProviderFor(CarritoActual)
final carritoActualProvider = CarritoActualProvider._();

/// Carrito de la sesión, solo en memoria. Se vacía cuando cambia la
/// membresía activa: otro distribuidor, otra persona o cierre de sesión.
final class CarritoActualProvider
    extends $NotifierProvider<CarritoActual, Carrito> {
  /// Carrito de la sesión, solo en memoria. Se vacía cuando cambia la
  /// membresía activa: otro distribuidor, otra persona o cierre de sesión.
  CarritoActualProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carritoActualProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carritoActualHash();

  @$internal
  @override
  CarritoActual create() => CarritoActual();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Carrito value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Carrito>(value),
    );
  }
}

String _$carritoActualHash() => r'd6f05449f1ec17938b7fccb93a65bad083877428';

/// Carrito de la sesión, solo en memoria. Se vacía cuando cambia la
/// membresía activa: otro distribuidor, otra persona o cierre de sesión.

abstract class _$CarritoActual extends $Notifier<Carrito> {
  Carrito build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Carrito, Carrito>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Carrito, Carrito>,
              Carrito,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
