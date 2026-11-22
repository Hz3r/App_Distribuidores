import 'package:freezed_annotation/freezed_annotation.dart';

part 'lista_precios.freezed.dart';
part 'lista_precios.g.dart';

/// Lista de precios especial para un grupo de clientes, tabla `listas_precios`.
@freezed
abstract class ListaPrecios with _$ListaPrecios {
  const factory ListaPrecios({
    required String id,
    required String distribuidorId,
    required String nombre,
    required bool activo,
    required DateTime creadoEn,
  }) = _ListaPrecios;

  factory ListaPrecios.fromJson(Map<String, dynamic> json) =>
      _$ListaPreciosFromJson(json);
}
