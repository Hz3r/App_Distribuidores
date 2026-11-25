// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clientes_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

@ProviderFor(clientesRepositorio)
final clientesRepositorioProvider = ClientesRepositorioProvider._();

/// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
/// lugar de `presentation` que construye la implementación de `data`.

final class ClientesRepositorioProvider
    extends
        $FunctionalProvider<
          ClientesRepositorio,
          ClientesRepositorio,
          ClientesRepositorio
        >
    with $Provider<ClientesRepositorio> {
  /// Repositorio inyectable; las pruebas lo reemplazan con un doble. Único
  /// lugar de `presentation` que construye la implementación de `data`.
  ClientesRepositorioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientesRepositorioProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientesRepositorioHash();

  @$internal
  @override
  $ProviderElement<ClientesRepositorio> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientesRepositorio create(Ref ref) {
    return clientesRepositorio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientesRepositorio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientesRepositorio>(value),
    );
  }
}

String _$clientesRepositorioHash() =>
    r'cac7776fc50eee5fc7cfc8564802ed17fd0f7588';

/// Hora actual, para saber si una invitación venció. Las pruebas la fijan.

@ProviderFor(reloj)
final relojProvider = RelojProvider._();

/// Hora actual, para saber si una invitación venció. Las pruebas la fijan.

final class RelojProvider
    extends
        $FunctionalProvider<
          DateTime Function(),
          DateTime Function(),
          DateTime Function()
        >
    with $Provider<DateTime Function()> {
  /// Hora actual, para saber si una invitación venció. Las pruebas la fijan.
  RelojProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'relojProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$relojHash();

  @$internal
  @override
  $ProviderElement<DateTime Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DateTime Function() create(Ref ref) {
    return reloj(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime Function()>(value),
    );
  }
}

String _$relojHash() => r'614099210aea97dccb5b899b144ebf30c42577ec';

/// Clientes del distribuidor activo.

@ProviderFor(clientes)
final clientesProvider = ClientesProvider._();

/// Clientes del distribuidor activo.

final class ClientesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ClienteNegocio>>,
          List<ClienteNegocio>,
          FutureOr<List<ClienteNegocio>>
        >
    with
        $FutureModifier<List<ClienteNegocio>>,
        $FutureProvider<List<ClienteNegocio>> {
  /// Clientes del distribuidor activo.
  ClientesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientesHash();

  @$internal
  @override
  $FutureProviderElement<List<ClienteNegocio>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ClienteNegocio>> create(Ref ref) {
    return clientes(ref);
  }
}

String _$clientesHash() => r'3d6989f57e9113e3bacab284e520224fa1f09ffa';

/// Personas que entran a la app a nombre de los clientes.

@ProviderFor(personasCliente)
final personasClienteProvider = PersonasClienteProvider._();

/// Personas que entran a la app a nombre de los clientes.

final class PersonasClienteProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PersonaCliente>>,
          List<PersonaCliente>,
          FutureOr<List<PersonaCliente>>
        >
    with
        $FutureModifier<List<PersonaCliente>>,
        $FutureProvider<List<PersonaCliente>> {
  /// Personas que entran a la app a nombre de los clientes.
  PersonasClienteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'personasClienteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$personasClienteHash();

  @$internal
  @override
  $FutureProviderElement<List<PersonaCliente>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PersonaCliente>> create(Ref ref) {
    return personasCliente(ref);
  }
}

String _$personasClienteHash() => r'6bc53de8e2de9fc866aacc8044c549b15f7e5dc5';

/// Invitaciones a clientes del distribuidor activo. Las comparten Clientes e
/// Invitaciones.

@ProviderFor(invitaciones)
final invitacionesProvider = InvitacionesProvider._();

/// Invitaciones a clientes del distribuidor activo. Las comparten Clientes e
/// Invitaciones.

final class InvitacionesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Invitacion>>,
          List<Invitacion>,
          FutureOr<List<Invitacion>>
        >
    with $FutureModifier<List<Invitacion>>, $FutureProvider<List<Invitacion>> {
  /// Invitaciones a clientes del distribuidor activo. Las comparten Clientes e
  /// Invitaciones.
  InvitacionesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitacionesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitacionesHash();

  @$internal
  @override
  $FutureProviderElement<List<Invitacion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Invitacion>> create(Ref ref) {
    return invitaciones(ref);
  }
}

String _$invitacionesHash() => r'863c1a60cdae562a343bfc74d68dd3fad8bf21c8';

/// Escrituras de clientes e invitaciones. Cada una vuelve a leer lo que
/// cambió. Lanzan [ErrorClientes]; la pantalla lo convierte en mensaje con
/// [mensajeDeClientes].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.

@ProviderFor(accionesClientes)
final accionesClientesProvider = AccionesClientesProvider._();

/// Escrituras de clientes e invitaciones. Cada una vuelve a leer lo que
/// cambió. Lanzan [ErrorClientes]; la pantalla lo convierte en mensaje con
/// [mensajeDeClientes].
///
/// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
/// usando el `ref` después de esperar a la red.

final class AccionesClientesProvider
    extends
        $FunctionalProvider<
          AccionesClientes,
          AccionesClientes,
          AccionesClientes
        >
    with $Provider<AccionesClientes> {
  /// Escrituras de clientes e invitaciones. Cada una vuelve a leer lo que
  /// cambió. Lanzan [ErrorClientes]; la pantalla lo convierte en mensaje con
  /// [mensajeDeClientes].
  ///
  /// `keepAlive`: las pantallas lo leen sin escucharlo y sus métodos siguen
  /// usando el `ref` después de esperar a la red.
  AccionesClientesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accionesClientesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accionesClientesHash();

  @$internal
  @override
  $ProviderElement<AccionesClientes> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AccionesClientes create(Ref ref) {
    return accionesClientes(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccionesClientes value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccionesClientes>(value),
    );
  }
}

String _$accionesClientesHash() => r'a03cf68e591e48789f338edbcea2bdf820ae7f28';
