// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuracion_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(configuracionRepositorio)
final configuracionRepositorioProvider = ConfiguracionRepositorioProvider._();

final class ConfiguracionRepositorioProvider
    extends
        $FunctionalProvider<
          ConfiguracionRepositorio,
          ConfiguracionRepositorio,
          ConfiguracionRepositorio
        >
    with $Provider<ConfiguracionRepositorio> {
  ConfiguracionRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'configuracionRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$configuracionRepositorioHash();

  @$internal
  @override
  $ProviderElement<ConfiguracionRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConfiguracionRepositorio create(Ref ref) {
    return configuracionRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfiguracionRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfiguracionRepositorio>(value),
    );
  }
}

String _$configuracionRepositorioHash() =>
    r'a6e6248fceb29a9c6f5156fca42726b63c0d0c83';

@ProviderFor(selectorImagen)
final selectorImagenProvider = SelectorImagenProvider._();

final class SelectorImagenProvider
    extends $FunctionalProvider<SelectorImagen, SelectorImagen, SelectorImagen>
    with $Provider<SelectorImagen> {
  SelectorImagenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectorImagenProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectorImagenHash();

  @$internal
  @override
  $ProviderElement<SelectorImagen> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SelectorImagen create(Ref ref) {
    return selectorImagen(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SelectorImagen value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SelectorImagen>(value),
    );
  }
}

String _$selectorImagenHash() => r'a390a5138c1ca7d10e81bd6ffaeb01a5416b387b';

/// Plan del distribuidor activo, o null si no tiene suscripción.

@ProviderFor(planVigente)
final planVigenteProvider = PlanVigenteProvider._();

/// Plan del distribuidor activo, o null si no tiene suscripción.

final class PlanVigenteProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlanVigente?>,
          PlanVigente?,
          FutureOr<PlanVigente?>
        >
    with $FutureModifier<PlanVigente?>, $FutureProvider<PlanVigente?> {
  /// Plan del distribuidor activo, o null si no tiene suscripción.
  PlanVigenteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'planVigenteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$planVigenteHash();

  @$internal
  @override
  $FutureProviderElement<PlanVigente?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlanVigente?> create(Ref ref) {
    return planVigente(ref);
  }
}

String _$planVigenteHash() => r'd3e7ac74ab748cb088fd119be8e1cb9688d39b56';

/// Escrituras de la configuración. Tras guardar, actualizan el distribuidor
/// en el acceso para que el menú lo muestre al instante. Lanzan
/// [ErrorConfiguracion]; la pantalla lo convierte en mensaje con
/// [mensajeDeConfiguracion].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.

@ProviderFor(accionesConfiguracion)
final accionesConfiguracionProvider = AccionesConfiguracionProvider._();

/// Escrituras de la configuración. Tras guardar, actualizan el distribuidor
/// en el acceso para que el menú lo muestre al instante. Lanzan
/// [ErrorConfiguracion]; la pantalla lo convierte en mensaje con
/// [mensajeDeConfiguracion].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.

final class AccionesConfiguracionProvider
    extends
        $FunctionalProvider<
          AccionesConfiguracion,
          AccionesConfiguracion,
          AccionesConfiguracion
        >
    with $Provider<AccionesConfiguracion> {
  /// Escrituras de la configuración. Tras guardar, actualizan el distribuidor
  /// en el acceso para que el menú lo muestre al instante. Lanzan
  /// [ErrorConfiguracion]; la pantalla lo convierte en mensaje con
  /// [mensajeDeConfiguracion].
  ///
  /// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
  /// usando el `ref` después de esperar a la red.
  AccionesConfiguracionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accionesConfiguracionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accionesConfiguracionHash();

  @$internal
  @override
  $ProviderElement<AccionesConfiguracion> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AccionesConfiguracion create(Ref ref) {
    return accionesConfiguracion(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccionesConfiguracion value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccionesConfiguracion>(value),
    );
  }
}

String _$accionesConfiguracionHash() =>
    r'0b00180c5ca06a58eb667480f3ed3dfa54c33d14';
