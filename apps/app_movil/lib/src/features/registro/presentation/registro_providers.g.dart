// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registro_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.

@ProviderFor(invitacionesRepositorio)
final invitacionesRepositorioProvider = InvitacionesRepositorioProvider._();

/// Repositorio inyectable; las pruebas lo reemplazan con un doble.
///
/// Es el único lugar de `presentation` que construye la implementación de
/// `data`: las pantallas dependen solo de este provider y de `domain`.

final class InvitacionesRepositorioProvider
    extends
        $FunctionalProvider<
          InvitacionesRepositorio,
          InvitacionesRepositorio,
          InvitacionesRepositorio
        >
    with $Provider<InvitacionesRepositorio> {
  /// Repositorio inyectable; las pruebas lo reemplazan con un doble.
  ///
  /// Es el único lugar de `presentation` que construye la implementación de
  /// `data`: las pantallas dependen solo de este provider y de `domain`.
  InvitacionesRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitacionesRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitacionesRepositorioHash();

  @$internal
  @override
  $ProviderElement<InvitacionesRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InvitacionesRepositorio create(Ref ref) {
    return invitacionesRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InvitacionesRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InvitacionesRepositorio>(value),
    );
  }
}

String _$invitacionesRepositorioHash() =>
    r'5f62f1465c1fec420f2fab0a9df7fc9771cced2d';

/// Repositorio de la cuenta (registro, ingreso y registro pendiente);
/// las pruebas lo reemplazan con un doble.

@ProviderFor(cuentasRepositorio)
final cuentasRepositorioProvider = CuentasRepositorioProvider._();

/// Repositorio de la cuenta (registro, ingreso y registro pendiente);
/// las pruebas lo reemplazan con un doble.

final class CuentasRepositorioProvider
    extends
        $FunctionalProvider<
          CuentasRepositorio,
          CuentasRepositorio,
          CuentasRepositorio
        >
    with $Provider<CuentasRepositorio> {
  /// Repositorio de la cuenta (registro, ingreso y registro pendiente);
  /// las pruebas lo reemplazan con un doble.
  CuentasRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cuentasRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cuentasRepositorioHash();

  @$internal
  @override
  $ProviderElement<CuentasRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CuentasRepositorio create(Ref ref) {
    return cuentasRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CuentasRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CuentasRepositorio>(value),
    );
  }
}

String _$cuentasRepositorioHash() =>
    r'c56e622acf32c1322b08063f21636756b03ed4f9';

/// Lógica de la pantalla de código: consulta el código cuando se completa y
/// canjea cuando ya hay sesión. Sin Flutter, para probarla con un doble del
/// repositorio.

@ProviderFor(IngresoCodigo)
final ingresoCodigoProvider = IngresoCodigoProvider._();

/// Lógica de la pantalla de código: consulta el código cuando se completa y
/// canjea cuando ya hay sesión. Sin Flutter, para probarla con un doble del
/// repositorio.
final class IngresoCodigoProvider
    extends $NotifierProvider<IngresoCodigo, EstadoIngresoCodigo> {
  /// Lógica de la pantalla de código: consulta el código cuando se completa y
  /// canjea cuando ya hay sesión. Sin Flutter, para probarla con un doble del
  /// repositorio.
  IngresoCodigoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ingresoCodigoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ingresoCodigoHash();

  @$internal
  @override
  IngresoCodigo create() => IngresoCodigo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EstadoIngresoCodigo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EstadoIngresoCodigo>(value),
    );
  }
}

String _$ingresoCodigoHash() => r'9a42067bea2d58e415c6fc34a5f7af736dea7900';

/// Lógica de la pantalla de código: consulta el código cuando se completa y
/// canjea cuando ya hay sesión. Sin Flutter, para probarla con un doble del
/// repositorio.

abstract class _$IngresoCodigo extends $Notifier<EstadoIngresoCodigo> {
  EstadoIngresoCodigo build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EstadoIngresoCodigo, EstadoIngresoCodigo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EstadoIngresoCodigo, EstadoIngresoCodigo>,
              EstadoIngresoCodigo,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
