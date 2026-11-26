// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuenta_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

@ProviderFor(cuentaRepositorio)
final cuentaRepositorioProvider = CuentaRepositorioProvider._();

/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

final class CuentaRepositorioProvider
    extends
        $FunctionalProvider<
          CuentaRepositorio,
          CuentaRepositorio,
          CuentaRepositorio
        >
    with $Provider<CuentaRepositorio> {
  /// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
  /// lugar de `presentation` que construye la implementación de `data`.
  CuentaRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuentaRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuentaRepositorioHash();

  @$internal
  @override
  $ProviderElement<CuentaRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CuentaRepositorio create(Ref ref) {
    return cuentaRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CuentaRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CuentaRepositorio>(value),
    );
  }
}

String _$cuentaRepositorioHash() => r'42158da7014dc279bfc3d14e31dd61a98b53f5c8';

/// Perfil de quien tiene la sesión. Se vuelve a leer si cambia el acceso
/// (otra sesión u otro distribuidor).

@ProviderFor(perfil)
final perfilProvider = PerfilProvider._();

/// Perfil de quien tiene la sesión. Se vuelve a leer si cambia el acceso
/// (otra sesión u otro distribuidor).

final class PerfilProvider
    extends $FunctionalProvider<AsyncValue<Perfil>, Perfil, FutureOr<Perfil>>
    with $FutureModifier<Perfil>, $FutureProvider<Perfil> {
  /// Perfil de quien tiene la sesión. Se vuelve a leer si cambia el acceso
  /// (otra sesión u otro distribuidor).
  PerfilProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'perfilProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$perfilHash();

  @$internal
  @override
  $FutureProviderElement<Perfil> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Perfil> create(Ref ref) {
    return perfil(ref);
  }
}

String _$perfilHash() => r'479957bfc67d325281c715137c1baf3762543d2a';

/// Escrituras de la cuenta. Lanzan [ErrorCuenta]; la pantalla lo convierte
/// en mensaje con [mensajeDeCuenta].

@ProviderFor(accionesCuenta)
final accionesCuentaProvider = AccionesCuentaProvider._();

/// Escrituras de la cuenta. Lanzan [ErrorCuenta]; la pantalla lo convierte
/// en mensaje con [mensajeDeCuenta].

final class AccionesCuentaProvider
    extends $FunctionalProvider<AccionesCuenta, AccionesCuenta, AccionesCuenta>
    with $Provider<AccionesCuenta> {
  /// Escrituras de la cuenta. Lanzan [ErrorCuenta]; la pantalla lo convierte
  /// en mensaje con [mensajeDeCuenta].
  AccionesCuentaProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accionesCuentaProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accionesCuentaHash();

  @$internal
  @override
  $ProviderElement<AccionesCuenta> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccionesCuenta create(Ref ref) {
    return accionesCuenta(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccionesCuenta value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccionesCuenta>(value),
    );
  }
}

String _$accionesCuentaHash() => r'29d67aef7f048b0f1e244a1b6b4221100738a507';
