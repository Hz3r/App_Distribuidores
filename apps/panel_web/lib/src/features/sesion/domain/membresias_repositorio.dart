import 'package:core/core.dart';

/// Acceso a las membresías de la persona con sesión y a su distribuidor
/// preferido en el panel. Las decisiones (cuáles sirven, cuál se usa) están
/// en `acceso.dart`, no aquí.
abstract interface class MembresiasRepositorio {
  /// Membresías de la persona con sesión, con su distribuidor embebido.
  Future<List<Membresia>> listarMias();

  /// Distribuidor preferido guardado en la cuenta, o null.
  String? distribuidorPreferido();

  Future<void> guardarDistribuidorPreferido(String distribuidorId);
}
