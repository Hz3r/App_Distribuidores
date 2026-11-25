// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'control_acceso.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(membresiasRepositorio)
final membresiasRepositorioProvider = MembresiasRepositorioProvider._();

final class MembresiasRepositorioProvider
    extends
        $FunctionalProvider<
          MembresiasRepositorio,
          MembresiasRepositorio,
          MembresiasRepositorio
        >
    with $Provider<MembresiasRepositorio> {
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

@ProviderFor(autenticacion)
final autenticacionProvider = AutenticacionProvider._();

final class AutenticacionProvider
    extends $FunctionalProvider<Autenticacion, Autenticacion, Autenticacion>
    with $Provider<Autenticacion> {
  AutenticacionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autenticacionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autenticacionHash();

  @$internal
  @override
  $ProviderElement<Autenticacion> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Autenticacion create(Ref ref) {
    return autenticacion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Autenticacion value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Autenticacion>(value),
    );
  }
}

String _$autenticacionHash() => r'08ee1554a4cbf863e7208e044d062080f90f69bb';

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

/// Acceso de la persona al panel: decide con qué distribuidor y rol entra
/// según sus membresías. La redirección la hace el router leyendo este estado.
///
/// Mismo diseño que el de `app_movil` (las apps no se importan entre sí).

@ProviderFor(ControlAcceso)
final controlAccesoProvider = ControlAccesoProvider._();

/// Acceso de la persona al panel: decide con qué distribuidor y rol entra
/// según sus membresías. La redirección la hace el router leyendo este estado.
///
/// Mismo diseño que el de `app_movil` (las apps no se importan entre sí).
final class ControlAccesoProvider
    extends $NotifierProvider<ControlAcceso, Acceso> {
  /// Acceso de la persona al panel: decide con qué distribuidor y rol entra
  /// según sus membresías. La redirección la hace el router leyendo este estado.
  ///
  /// Mismo diseño que el de `app_movil` (las apps no se importan entre sí).
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

String _$controlAccesoHash() => r'4f7115f652b6e0954a7aa32c338f5bfb158da63d';

/// Acceso de la persona al panel: decide con qué distribuidor y rol entra
/// según sus membresías. La redirección la hace el router leyendo este estado.
///
/// Mismo diseño que el de `app_movil` (las apps no se importan entre sí).

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

/// Membresía con la que la persona está usando el panel, o null si todavía
/// no entró a ningún distribuidor.

@ProviderFor(membresiaActiva)
final membresiaActivaProvider = MembresiaActivaProvider._();

/// Membresía con la que la persona está usando el panel, o null si todavía
/// no entró a ningún distribuidor.

final class MembresiaActivaProvider
    extends $FunctionalProvider<Membresia?, Membresia?, Membresia?>
    with $Provider<Membresia?> {
  /// Membresía con la que la persona está usando el panel, o null si todavía
  /// no entró a ningún distribuidor.
  MembresiaActivaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'membresiaActivaProvider',
        isAutoDispose: true,
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

String _$membresiaActivaHash() => r'42d5908789e658459b08e60978d0fbd6bed86de8';
