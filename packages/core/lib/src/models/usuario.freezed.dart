// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'usuario.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Usuario {

 String get id; String get distribuidorId; RolUsuario get rol; String get nombre; String? get telefono;
/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UsuarioCopyWith<Usuario> get copyWith => _$UsuarioCopyWithImpl<Usuario>(this as Usuario, _$identity);

  /// Serializes this Usuario to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Usuario;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Usuario&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.rol, _this.rol) || other.rol == _this.rol)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.telefono, _this.telefono) || other.telefono == _this.telefono));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Usuario;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.rol,_this.nombre,_this.telefono);
}

@override
String toString() {
  final _this = this as Usuario;
  return 'Usuario(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, rol: ${_this.rol}, nombre: ${_this.nombre}, telefono: ${_this.telefono})';
}


}

/// @nodoc
abstract mixin class $UsuarioCopyWith<$Res>  {
  factory $UsuarioCopyWith(Usuario value, $Res Function(Usuario) _then) = _$UsuarioCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, RolUsuario rol, String nombre, String? telefono
});




}
/// @nodoc
class _$UsuarioCopyWithImpl<$Res>
    implements $UsuarioCopyWith<$Res> {
  _$UsuarioCopyWithImpl(this._self, this._then);

  final Usuario _self;
  final $Res Function(Usuario) _then;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? rol = null,Object? nombre = null,Object? telefono = freezed,}) {
  return _then(Usuario(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolUsuario,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Usuario].
extension UsuarioPatterns on Usuario {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Usuario value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Usuario() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Usuario value)  $default,){
final _that = this;
switch (_that) {
case _Usuario():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Usuario value)?  $default,){
final _that = this;
switch (_that) {
case _Usuario() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  RolUsuario rol,  String nombre,  String? telefono)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Usuario() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.rol,_that.nombre,_that.telefono);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  RolUsuario rol,  String nombre,  String? telefono)  $default,) {final _that = this;
switch (_that) {
case _Usuario():
return $default(_that.id,_that.distribuidorId,_that.rol,_that.nombre,_that.telefono);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  RolUsuario rol,  String nombre,  String? telefono)?  $default,) {final _that = this;
switch (_that) {
case _Usuario() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.rol,_that.nombre,_that.telefono);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Usuario implements Usuario {
  const _Usuario({required this.id, required this.distribuidorId, required this.rol, required this.nombre, this.telefono});
  factory _Usuario.fromJson(Map<String, dynamic> json) => _$UsuarioFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  RolUsuario rol;
@override final  String nombre;
@override final  String? telefono;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UsuarioCopyWith<_Usuario> get copyWith => __$UsuarioCopyWithImpl<_Usuario>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UsuarioToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Usuario&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.telefono, telefono) || other.telefono == telefono));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,rol,nombre,telefono);
}

@override
String toString() {
    return 'Usuario(id: $id, distribuidorId: $distribuidorId, rol: $rol, nombre: $nombre, telefono: $telefono)';
}


}

/// @nodoc
abstract mixin class _$UsuarioCopyWith<$Res> implements $UsuarioCopyWith<$Res> {
  factory _$UsuarioCopyWith(_Usuario value, $Res Function(_Usuario) _then) = __$UsuarioCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, RolUsuario rol, String nombre, String? telefono
});




}
/// @nodoc
class __$UsuarioCopyWithImpl<$Res>
    implements _$UsuarioCopyWith<$Res> {
  __$UsuarioCopyWithImpl(this._self, this._then);

  final _Usuario _self;
  final $Res Function(_Usuario) _then;

/// Create a copy of Usuario
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? rol = null,Object? nombre = null,Object? telefono = freezed,}) {
  return _then(_Usuario(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolUsuario,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
