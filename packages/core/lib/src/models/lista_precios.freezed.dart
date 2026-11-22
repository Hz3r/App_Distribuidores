// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lista_precios.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListaPrecios {

 String get id; String get distribuidorId; String get nombre; bool get activo; DateTime get creadoEn;
/// Create a copy of ListaPrecios
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListaPreciosCopyWith<ListaPrecios> get copyWith => _$ListaPreciosCopyWithImpl<ListaPrecios>(this as ListaPrecios, _$identity);

  /// Serializes this ListaPrecios to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ListaPrecios;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListaPrecios&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.activo, _this.activo) || other.activo == _this.activo)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ListaPrecios;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.nombre,_this.activo,_this.creadoEn);
}

@override
String toString() {
  final _this = this as ListaPrecios;
  return 'ListaPrecios(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, nombre: ${_this.nombre}, activo: ${_this.activo}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $ListaPreciosCopyWith<$Res>  {
  factory $ListaPreciosCopyWith(ListaPrecios value, $Res Function(ListaPrecios) _then) = _$ListaPreciosCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String nombre, bool activo, DateTime creadoEn
});




}
/// @nodoc
class _$ListaPreciosCopyWithImpl<$Res>
    implements $ListaPreciosCopyWith<$Res> {
  _$ListaPreciosCopyWithImpl(this._self, this._then);

  final ListaPrecios _self;
  final $Res Function(ListaPrecios) _then;

/// Create a copy of ListaPrecios
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? nombre = null,Object? activo = null,Object? creadoEn = null,}) {
  return _then(ListaPrecios(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ListaPrecios].
extension ListaPreciosPatterns on ListaPrecios {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListaPrecios value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListaPrecios() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListaPrecios value)  $default,){
final _that = this;
switch (_that) {
case _ListaPrecios():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListaPrecios value)?  $default,){
final _that = this;
switch (_that) {
case _ListaPrecios() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String nombre,  bool activo,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListaPrecios() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.nombre,_that.activo,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String nombre,  bool activo,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _ListaPrecios():
return $default(_that.id,_that.distribuidorId,_that.nombre,_that.activo,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String nombre,  bool activo,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _ListaPrecios() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.nombre,_that.activo,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListaPrecios implements ListaPrecios {
  const _ListaPrecios({required this.id, required this.distribuidorId, required this.nombre, required this.activo, required this.creadoEn});
  factory _ListaPrecios.fromJson(Map<String, dynamic> json) => _$ListaPreciosFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String nombre;
@override final  bool activo;
@override final  DateTime creadoEn;

/// Create a copy of ListaPrecios
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListaPreciosCopyWith<_ListaPrecios> get copyWith => __$ListaPreciosCopyWithImpl<_ListaPrecios>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListaPreciosToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListaPrecios&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,nombre,activo,creadoEn);
}

@override
String toString() {
    return 'ListaPrecios(id: $id, distribuidorId: $distribuidorId, nombre: $nombre, activo: $activo, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$ListaPreciosCopyWith<$Res> implements $ListaPreciosCopyWith<$Res> {
  factory _$ListaPreciosCopyWith(_ListaPrecios value, $Res Function(_ListaPrecios) _then) = __$ListaPreciosCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String nombre, bool activo, DateTime creadoEn
});




}
/// @nodoc
class __$ListaPreciosCopyWithImpl<$Res>
    implements _$ListaPreciosCopyWith<$Res> {
  __$ListaPreciosCopyWithImpl(this._self, this._then);

  final _ListaPrecios _self;
  final $Res Function(_ListaPrecios) _then;

/// Create a copy of ListaPrecios
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? nombre = null,Object? activo = null,Object? creadoEn = null,}) {
  return _then(_ListaPrecios(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
