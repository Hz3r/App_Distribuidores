// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_tema.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConfigTema _$ConfigTemaFromJson(Map<String, dynamic> json) => _ConfigTema(
  nombre: json['nombre'] as String,
  logoUrl: json['logo_url'] as String?,
  colorPrimario: json['color_primario'] as String? ?? '#1F3A5F',
  colorSecundario: json['color_secundario'] as String? ?? '#F2A900',
);

Map<String, dynamic> _$ConfigTemaToJson(_ConfigTema instance) =>
    <String, dynamic>{
      'nombre': instance.nombre,
      'logo_url': instance.logoUrl,
      'color_primario': instance.colorPrimario,
      'color_secundario': instance.colorSecundario,
    };
