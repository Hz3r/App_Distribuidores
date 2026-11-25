// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_acceso.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.

@ProviderFor(membresiasRepositorio)
final membresiasRepositorioProvider = MembresiasRepositorioProvider._();

/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.

final class MembresiasRepositorioProvider
    extends
        $FunctionalProvider<
          MembresiasRepositorio,
          MembresiasRepositorio,
          MembresiasRepositorio
        >
    with $Provider<MembresiasRepositorio> {
  /// Repositorio inyectable; las pruebas lo reemplazan con un doble.
  ///
  /// Es el único lugar de `presentation` que construye la implementación de
  /// `data`: las pantallas dependen solo de este provider y de `domain`.
  MembresiasRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membresiasRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$membresiasRepositorioHash();

  @$internal
  @override
  $ProviderElement<MembresiasRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MembresiasRepositorio create(Ref ref) {
    return membresiasRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MembresiasRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MembresiasRepositorio>(value),
    );
  }
}

String _$membresiasRepositorioHash() =>
    r'dbb025b8deec32fd322090420938b061c446c095';

/// Flujo de "hay sesión / no hay sesión"; las pruebas lo reemplazan.
///
/// Empieza con el estado actual de la sesión. Si la sesión pasa directamente
/// a otra persona, emite `false` y luego `true` para forzar una recarga.

@ProviderFor(haySesion)
final haySesionProvider = HaySesionProvider._();

/// Flujo de "hay sesión / no hay sesión"; las pruebas lo reemplazan.
///
/// Empieza con el estado actual de la sesión. Si la sesión pasa directamente
/// a otra persona, emite `false` y luego `true` para forzar una recarga.

final class HaySesionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Flujo de "hay sesión / no hay sesión"; las pruebas lo reemplazan.
  ///
  /// Empieza con el estado actual de la sesión. Si la sesión pasa directamente
  /// a otra persona, emite `false` y luego `true` para forzar una recarga.
  HaySesionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'haySesionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$haySesionHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return haySesion(ref);
  }
}

String _$haySesionHash() => r'dd6d00d7e37b4f0f73ed560afb31064f316fb8ec';

/// Acceso de la persona en la app móvil: decide a qué zona entra según sus
/// membresías. La redirección la hace el router leyendo este estado.

@ProviderFor(ControlAcceso)
final controlAccesoProvider = ControlAccesoProvider._();

/// Acceso de la persona en la app móvil: decide a qué zona entra según sus
/// membresías. La redirección la hace el router leyendo este estado.
final class ControlAccesoProvider
    extends $NotifierProvider<ControlAcceso, Acceso> {
  /// Acceso de la persona en la app móvil: decide a qué zona entra según sus
  /// membresías. La redirección la hace el router leyendo este estado.
  ControlAccesoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'controlAccesoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$controlAccesoHash();

  @$internal
  @override
  ControlAcceso create() => ControlAcceso();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Acceso value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Acceso>(value),
    );
  }
}

String _$controlAccesoHash() => r'e1a99444131a56e54966de58d0a2913e58abcb28';

/// Acceso de la persona en la app móvil: decide a qué zona entra según sus
/// membresías. La redirección la hace el router leyendo este estado.

abstract class _$ControlAcceso extends $Notifier<Acceso> {
  Acceso build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Acceso, Acceso>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Acceso, Acceso>,
              Acceso,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
