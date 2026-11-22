import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_tema.freezed.dart';
part 'config_tema.g.dart';

/// Personalización visual del distribuidor. Colores en formato `#RRGGBB`.
/// Todos los campos tienen valor por defecto: la BD crea el distribuidor con
/// `config_tema = '{}'` y ese JSON vacío tiene que leerse sin fallar.
@freezed
abstract class ConfigTema with _$ConfigTema {
  const factory ConfigTema({
    @Default('') String nombre,
    String? logoUrl,
    @Default('#1F3A5F') String colorPrimario,
    @Default('#F2A900') String colorSecundario,
  }) = _ConfigTema;

  factory ConfigTema.fromJson(Map<String, dynamic> json) =>
      _$ConfigTemaFromJson(json);
}
