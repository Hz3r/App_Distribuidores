// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'config_tema.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConfigTema {

 String get nombre; String? get logoUrl; String get colorPrimario; String get colorSecundario;
/// Create a copy of ConfigTema
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConfigTemaCopyWith<ConfigTema> get copyWith => _$ConfigTemaCopyWithImpl<ConfigTema>(this as ConfigTema, _$identity);

  /// Serializes this ConfigTema to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ConfigTema;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConfigTema&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.logoUrl, _this.logoUrl) || other.logoUrl == _this.logoUrl)&&(identical(other.colorPrimario, _this.colorPrimario) || other.colorPrimario == _this.colorPrimario)&&(identical(other.colorSecundario, _this.colorSecundario) || other.colorSecundario == _this.colorSecundario));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ConfigTema;
  return Object.hash(runtimeType,_this.nombre,_this.logoUrl,_this.colorPrimario,_this.colorSecundario);
}

@override
String toString() {
  final _this = this as ConfigTema;
  return 'ConfigTema(nombre: ${_this.nombre}, logoUrl: ${_this.logoUrl}, colorPrimario: ${_this.colorPrimario}, colorSecundario: ${_this.colorSecundario})';
}


}

/// @nodoc
abstract mixin class $ConfigTemaCopyWith<$Res>  {
  factory $ConfigTemaCopyWith(ConfigTema value, $Res Function(ConfigTema) _then) = _$ConfigTemaCopyWithImpl;
@useResult
$Res call({
 String nombre, String? logoUrl, String colorPrimario, String colorSecundario
});




}
/// @nodoc
class _$ConfigTemaCopyWithImpl<$Res>
    implements $ConfigTemaCopyWith<$Res> {
  _$ConfigTemaCopyWithImpl(this._self, this._then);

  final ConfigTema _self;
  final $Res Function(ConfigTema) _then;

/// Create a copy of ConfigTema
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nombre = null,Object? logoUrl = freezed,Object? colorPrimario = null,Object? colorSecundario = null,}) {
  return _then(ConfigTema(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,colorPrimario: null == colorPrimario ? _self.colorPrimario : colorPrimario // ignore: cast_nullable_to_non_nullable
as String,colorSecundario: null == colorSecundario ? _self.colorSecundario : colorSecundario // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ConfigTema].
extension ConfigTemaPatterns on ConfigTema {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConfigTema value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConfigTema() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConfigTema value)  $default,){
final _that = this;
switch (_that) {
case _ConfigTema():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConfigTema value)?  $default,){
final _that = this;
switch (_that) {
case _ConfigTema() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nombre,  String? logoUrl,  String colorPrimario,  String colorSecundario)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConfigTema() when $default != null:
return $default(_that.nombre,_that.logoUrl,_that.colorPrimario,_that.colorSecundario);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nombre,  String? logoUrl,  String colorPrimario,  String colorSecundario)  $default,) {final _that = this;
switch (_that) {
case _ConfigTema():
return $default(_that.nombre,_that.logoUrl,_that.colorPrimario,_that.colorSecundario);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nombre,  String? logoUrl,  String colorPrimario,  String colorSecundario)?  $default,) {final _that = this;
switch (_that) {
case _ConfigTema() when $default != null:
return $default(_that.nombre,_that.logoUrl,_that.colorPrimario,_that.colorSecundario);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConfigTema implements ConfigTema {
  const _ConfigTema({this.nombre = '', this.logoUrl, this.colorPrimario = '#1F3A5F', this.colorSecundario = '#F2A900'});
  factory _ConfigTema.fromJson(Map<String, dynamic> json) => _$ConfigTemaFromJson(json);

@override@JsonKey() final  String nombre;
@override final  String? logoUrl;
@override@JsonKey() final  String colorPrimario;
@override@JsonKey() final  String colorSecundario;

/// Create a copy of ConfigTema
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConfigTemaCopyWith<_ConfigTema> get copyWith => __$ConfigTemaCopyWithImpl<_ConfigTema>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConfigTemaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConfigTema&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.colorPrimario, colorPrimario) || other.colorPrimario == colorPrimario)&&(identical(other.colorSecundario, colorSecundario) || other.colorSecundario == colorSecundario));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,nombre,logoUrl,colorPrimario,colorSecundario);
}

@override
String toString() {
    return 'ConfigTema(nombre: $nombre, logoUrl: $logoUrl, colorPrimario: $colorPrimario, colorSecundario: $colorSecundario)';
}


}

/// @nodoc
abstract mixin class _$ConfigTemaCopyWith<$Res> implements $ConfigTemaCopyWith<$Res> {
  factory _$ConfigTemaCopyWith(_ConfigTema value, $Res Function(_ConfigTema) _then) = __$ConfigTemaCopyWithImpl;
@override @useResult
$Res call({
 String nombre, String? logoUrl, String colorPrimario, String colorSecundario
});




}
/// @nodoc
class __$ConfigTemaCopyWithImpl<$Res>
    implements _$ConfigTemaCopyWith<$Res> {
  __$ConfigTemaCopyWithImpl(this._self, this._then);

  final _ConfigTema _self;
  final $Res Function(_ConfigTema) _then;

/// Create a copy of ConfigTema
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nombre = null,Object? logoUrl = freezed,Object? colorPrimario = null,Object? colorSecundario = null,}) {
  return _then(_ConfigTema(
nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,colorPrimario: null == colorPrimario ? _self.colorPrimario : colorPrimario // ignore: cast_nullable_to_non_nullable
as String,colorSecundario: null == colorSecundario ? _self.colorSecundario : colorSecundario // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
