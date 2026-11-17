// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cliente_negocio.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClienteNegocio {

 String get id; String get distribuidorId; String get nombreNegocio; String? get usuarioId; String? get direccion;
/// Create a copy of ClienteNegocio
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClienteNegocioCopyWith<ClienteNegocio> get copyWith => _$ClienteNegocioCopyWithImpl<ClienteNegocio>(this as ClienteNegocio, _$identity);

  /// Serializes this ClienteNegocio to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClienteNegocio;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClienteNegocio&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.nombreNegocio, _this.nombreNegocio) || other.nombreNegocio == _this.nombreNegocio)&&(identical(other.usuarioId, _this.usuarioId) || other.usuarioId == _this.usuarioId)&&(identical(other.direccion, _this.direccion) || other.direccion == _this.direccion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClienteNegocio;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.nombreNegocio,_this.usuarioId,_this.direccion);
}

@override
String toString() {
  final _this = this as ClienteNegocio;
  return 'ClienteNegocio(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, nombreNegocio: ${_this.nombreNegocio}, usuarioId: ${_this.usuarioId}, direccion: ${_this.direccion})';
}


}

/// @nodoc
abstract mixin class $ClienteNegocioCopyWith<$Res>  {
  factory $ClienteNegocioCopyWith(ClienteNegocio value, $Res Function(ClienteNegocio) _then) = _$ClienteNegocioCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String nombreNegocio, String? usuarioId, String? direccion
});




}
/// @nodoc
class _$ClienteNegocioCopyWithImpl<$Res>
    implements $ClienteNegocioCopyWith<$Res> {
  _$ClienteNegocioCopyWithImpl(this._self, this._then);

  final ClienteNegocio _self;
  final $Res Function(ClienteNegocio) _then;

/// Create a copy of ClienteNegocio
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? nombreNegocio = null,Object? usuarioId = freezed,Object? direccion = freezed,}) {
  return _then(ClienteNegocio(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,nombreNegocio: null == nombreNegocio ? _self.nombreNegocio : nombreNegocio // ignore: cast_nullable_to_non_nullable
as String,usuarioId: freezed == usuarioId ? _self.usuarioId : usuarioId // ignore: cast_nullable_to_non_nullable
as String?,direccion: freezed == direccion ? _self.direccion : direccion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClienteNegocio].
extension ClienteNegocioPatterns on ClienteNegocio {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClienteNegocio value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClienteNegocio() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClienteNegocio value)  $default,){
final _that = this;
switch (_that) {
case _ClienteNegocio():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClienteNegocio value)?  $default,){
final _that = this;
switch (_that) {
case _ClienteNegocio() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String nombreNegocio,  String? usuarioId,  String? direccion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClienteNegocio() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.nombreNegocio,_that.usuarioId,_that.direccion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String nombreNegocio,  String? usuarioId,  String? direccion)  $default,) {final _that = this;
switch (_that) {
case _ClienteNegocio():
return $default(_that.id,_that.distribuidorId,_that.nombreNegocio,_that.usuarioId,_that.direccion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String nombreNegocio,  String? usuarioId,  String? direccion)?  $default,) {final _that = this;
switch (_that) {
case _ClienteNegocio() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.nombreNegocio,_that.usuarioId,_that.direccion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClienteNegocio implements ClienteNegocio {
  const _ClienteNegocio({required this.id, required this.distribuidorId, required this.nombreNegocio, this.usuarioId, this.direccion});
  factory _ClienteNegocio.fromJson(Map<String, dynamic> json) => _$ClienteNegocioFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String nombreNegocio;
@override final  String? usuarioId;
@override final  String? direccion;

/// Create a copy of ClienteNegocio
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClienteNegocioCopyWith<_ClienteNegocio> get copyWith => __$ClienteNegocioCopyWithImpl<_ClienteNegocio>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClienteNegocioToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClienteNegocio&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.nombreNegocio, nombreNegocio) || other.nombreNegocio == nombreNegocio)&&(identical(other.usuarioId, usuarioId) || other.usuarioId == usuarioId)&&(identical(other.direccion, direccion) || other.direccion == direccion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,nombreNegocio,usuarioId,direccion);
}

@override
String toString() {
    return 'ClienteNegocio(id: $id, distribuidorId: $distribuidorId, nombreNegocio: $nombreNegocio, usuarioId: $usuarioId, direccion: $direccion)';
}


}

/// @nodoc
abstract mixin class _$ClienteNegocioCopyWith<$Res> implements $ClienteNegocioCopyWith<$Res> {
  factory _$ClienteNegocioCopyWith(_ClienteNegocio value, $Res Function(_ClienteNegocio) _then) = __$ClienteNegocioCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String nombreNegocio, String? usuarioId, String? direccion
});




}
/// @nodoc
class __$ClienteNegocioCopyWithImpl<$Res>
    implements _$ClienteNegocioCopyWith<$Res> {
  __$ClienteNegocioCopyWithImpl(this._self, this._then);

  final _ClienteNegocio _self;
  final $Res Function(_ClienteNegocio) _then;

/// Create a copy of ClienteNegocio
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? nombreNegocio = null,Object? usuarioId = freezed,Object? direccion = freezed,}) {
  return _then(_ClienteNegocio(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,nombreNegocio: null == nombreNegocio ? _self.nombreNegocio : nombreNegocio // ignore: cast_nullable_to_non_nullable
as String,usuarioId: freezed == usuarioId ? _self.usuarioId : usuarioId // ignore: cast_nullable_to_non_nullable
as String?,direccion: freezed == direccion ? _self.direccion : direccion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
