import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_tema.freezed.dart';
part 'config_tema.g.dart';

/// Personalización visual del distribuidor. Colores en formato `#RRGGBB`.
@freezed
abstract class ConfigTema with _$ConfigTema {
  const factory ConfigTema({
    required String nombre,
    String? logoUrl,
    @Default('#1F3A5F') String colorPrimario,
    @Default('#F2A900') String colorSecundario,
  }) = _ConfigTema;

  factory ConfigTema.fromJson(Map<String, dynamic> json) =>
      _$ConfigTemaFromJson(json);
}
