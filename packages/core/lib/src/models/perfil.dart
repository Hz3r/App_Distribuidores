import 'package:freezed_annotation/freezed_annotation.dart';

part 'perfil.freezed.dart';
part 'perfil.g.dart';

/// Perfil de una persona, tabla `perfiles`. `id` coincide con `auth.users.id`.
@freezed
abstract class Perfil with _$Perfil {
  const factory Perfil({
    required String id,
    required String nombre,
    String? telefono,
    required bool esSuperAdmin,
    required DateTime creadoEn,
  }) = _Perfil;

  factory Perfil.fromJson(Map<String, dynamic> json) => _$PerfilFromJson(json);
}
