import 'package:core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/membresias_repositorio.dart';

/// [MembresiasRepositorio] sobre Supabase. Delgado a propósito: solo lee y
/// escribe; la lógica de acceso vive en `domain/acceso.dart`.
class MembresiasRepositorioSupabase implements MembresiasRepositorio {
  MembresiasRepositorioSupabase(this._cliente);

  final SupabaseClient _cliente;

  /// Clave en `user_metadata` del distribuidor preferido **del panel**. La
  /// app móvil usa `distribuidor_activo`: una persona puede ser admin en un
  /// distribuidor y cliente en otro (contrato, sección 7).
  static const _clavePreferido = 'distribuidor_activo_panel';

  @override
  Future<List<Membresia>> listarMias() async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) {
      throw StateError('No hay sesión para leer las membresías.');
    }
    // El filtro por perfil_id es obligatorio: la política deja a un admin o
    // vendedor ver las membresías de todo su distribuidor, no solo las suyas.
    final filas = await _cliente
        .from('membresias')
        .select('*, distribuidor:distribuidores(*)')
        .eq('perfil_id', usuario.id);
    return filas.map(Membresia.fromJson).toList();
  }

  @override
  String? distribuidorPreferido() {
    final valor = _cliente.auth.currentUser?.userMetadata?[_clavePreferido];
    return valor is String ? valor : null;
  }

  @override
  Future<void> guardarDistribuidorPreferido(String distribuidorId) async {
    await _cliente.auth.updateUser(
      UserAttributes(data: {_clavePreferido: distribuidorId}),
    );
  }
}
