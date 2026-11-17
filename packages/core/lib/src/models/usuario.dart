import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'usuario.freezed.dart';
part 'usuario.g.dart';

/// Perfil de usuario. `id` coincide con auth.users.id.
@freezed
abstract class Usuario with _$Usuario {
  const factory Usuario({
    required String id,
    required String distribuidorId,
    required RolUsuario rol,
    required String nombre,
    String? telefono,
  }) = _Usuario;

  factory Usuario.fromJson(Map<String, dynamic> json) =>
      _$UsuarioFromJson(json);
}
