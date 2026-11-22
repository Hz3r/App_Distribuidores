import 'package:freezed_annotation/freezed_annotation.dart';

part 'categoria.freezed.dart';
part 'categoria.g.dart';

/// Categoría de producto (ron, pisco, whisky, cerveza, vino...), tabla `categorias`.
@freezed
abstract class Categoria with _$Categoria {
  const factory Categoria({
    required String id,
    required String distribuidorId,
    required String nombre,
    required int orden,
    required bool activo,
    required DateTime creadoEn,
  }) = _Categoria;

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      _$CategoriaFromJson(json);
}
