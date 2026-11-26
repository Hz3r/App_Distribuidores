// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sesion_activa.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// La membresía con la que se está dentro de la app: la activa de
/// [ConAcceso], o `null` (sin sesión, cargando, error o sin elegir). De ella
/// salen `distribuidorId`, `distribuidor` y `clienteNegocio` (con su
/// `listaPreciosId`).
///
/// Se mantiene viva como [ControlAcceso], porque la escuchan providers que
/// también se mantienen vivos (el carrito).

@ProviderFor(membresiaActiva)
final membresiaActivaProvider = MembresiaActivaProvider._();

/// La membresía con la que se está dentro de la app: la activa de
/// [ConAcceso], o `null` (sin sesión, cargando, error o sin elegir). De ella
/// salen `distribuidorId`, `distribuidor` y `clienteNegocio` (con su
/// `listaPreciosId`).
///
/// Se mantiene viva como [ControlAcceso], porque la escuchan providers que
/// también se mantienen vivos (el carrito).

final class MembresiaActivaProvider
    extends $FunctionalProvider<Membresia?, Membresia?, Membresia?>
    with $Provider<Membresia?> {
  /// La membresía con la que se está dentro de la app: la activa de
  /// [ConAcceso], o `null` (sin sesión, cargando, error o sin elegir). De ella
  /// salen `distribuidorId`, `distribuidor` y `clienteNegocio` (con su
  /// `listaPreciosId`).
  ///
  /// Se mantiene viva como [ControlAcceso], porque la escuchan providers que
  /// también se mantienen vivos (el carrito).
  MembresiaActivaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membresiaActivaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membresiaActivaHash();

  @$internal
  @override
  $ProviderElement<Membresia?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Membresia? create(Ref ref) {
    return membresiaActiva(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Membresia? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Membresia?>(value),
    );
  }
}

String _$membresiaActivaHash() => r'fcc42bb4565b6898c6c9a8d547e2bce2a49418ef';
