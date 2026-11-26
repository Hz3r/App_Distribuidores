import 'package:core/core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/acceso.dart';
import 'control_acceso.dart';

part 'sesion_activa.g.dart';

/// La membresía con la que se está dentro de la app: la activa de
/// [ConAcceso], o `null` (sin sesión, cargando, error o sin elegir). De ella
/// salen `distribuidorId`, `distribuidor` y `clienteNegocio` (con su
/// `listaPreciosId`).
///
/// Se mantiene viva como [ControlAcceso], porque la escuchan providers que
/// también se mantienen vivos (el carrito).
@Riverpod(keepAlive: true)
Membresia? membresiaActiva(Ref ref) =>
    switch (ref.watch(controlAccesoProvider)) {
      ConAcceso(:final activa) => activa,
      _ => null,
    };
