// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presentacion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Presentacion {

 String get id; String get productoId; TipoPresentacion get tipo; String get nombre; int get precioBaseCentimos; int get stock; int get unidadesPorPresentacion;
/// Create a copy of Presentacion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresentacionCopyWith<Presentacion> get copyWith => _$PresentacionCopyWithImpl<Presentacion>(this as Presentacion, _$identity);

  /// Serializes this Presentacion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Presentacion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Presentacion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.productoId, _this.productoId) || other.productoId == _this.productoId)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.precioBaseCentimos, _this.precioBaseCentimos) || other.precioBaseCentimos == _this.precioBaseCentimos)&&(identical(other.stock, _this.stock) || other.stock == _this.stock)&&(identical(other.unidadesPorPresentacion, _this.unidadesPorPresentacion) || other.unidadesPorPresentacion == _this.unidadesPorPresentacion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Presentacion;
  return Object.hash(runtimeType,_this.id,_this.productoId,_this.tipo,_this.nombre,_this.precioBaseCentimos,_this.stock,_this.unidadesPorPresentacion);
}

@override
String toString() {
  final _this = this as Presentacion;
  return 'Presentacion(id: ${_this.id}, productoId: ${_this.productoId}, tipo: ${_this.tipo}, nombre: ${_this.nombre}, precioBaseCentimos: ${_this.precioBaseCentimos}, stock: ${_this.stock}, unidadesPorPresentacion: ${_this.unidadesPorPresentacion})';
}


}

/// @nodoc
abstract mixin class $PresentacionCopyWith<$Res>  {
  factory $PresentacionCopyWith(Presentacion value, $Res Function(Presentacion) _then) = _$PresentacionCopyWithImpl;
@useResult
$Res call({
 String id, String productoId, TipoPresentacion tipo, String nombre, int precioBaseCentimos, int stock, int unidadesPorPresentacion
});




}
/// @nodoc
class _$PresentacionCopyWithImpl<$Res>
    implements $PresentacionCopyWith<$Res> {
  _$PresentacionCopyWithImpl(this._self, this._then);

  final Presentacion _self;
  final $Res Function(Presentacion) _then;

/// Create a copy of Presentacion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productoId = null,Object? tipo = null,Object? nombre = null,Object? precioBaseCentimos = null,Object? stock = null,Object? unidadesPorPresentacion = null,}) {
  return _then(Presentacion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPresentacion,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precioBaseCentimos: null == precioBaseCentimos ? _self.precioBaseCentimos : precioBaseCentimos // ignore: cast_nullable_to_non_nullable
as int,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,unidadesPorPresentacion: null == unidadesPorPresentacion ? _self.unidadesPorPresentacion : unidadesPorPresentacion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Presentacion].
extension PresentacionPatterns on Presentacion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Presentacion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Presentacion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Presentacion value)  $default,){
final _that = this;
switch (_that) {
case _Presentacion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Presentacion value)?  $default,){
final _that = this;
switch (_that) {
case _Presentacion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productoId,  TipoPresentacion tipo,  String nombre,  int precioBaseCentimos,  int stock,  int unidadesPorPresentacion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Presentacion() when $default != null:
return $default(_that.id,_that.productoId,_that.tipo,_that.nombre,_that.precioBaseCentimos,_that.stock,_that.unidadesPorPresentacion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productoId,  TipoPresentacion tipo,  String nombre,  int precioBaseCentimos,  int stock,  int unidadesPorPresentacion)  $default,) {final _that = this;
switch (_that) {
case _Presentacion():
return $default(_that.id,_that.productoId,_that.tipo,_that.nombre,_that.precioBaseCentimos,_that.stock,_that.unidadesPorPresentacion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productoId,  TipoPresentacion tipo,  String nombre,  int precioBaseCentimos,  int stock,  int unidadesPorPresentacion)?  $default,) {final _that = this;
switch (_that) {
case _Presentacion() when $default != null:
return $default(_that.id,_that.productoId,_that.tipo,_that.nombre,_that.precioBaseCentimos,_that.stock,_that.unidadesPorPresentacion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Presentacion implements Presentacion {
  const _Presentacion({required this.id, required this.productoId, required this.tipo, required this.nombre, required this.precioBaseCentimos, required this.stock, this.unidadesPorPresentacion = 1});
  factory _Presentacion.fromJson(Map<String, dynamic> json) => _$PresentacionFromJson(json);

@override final  String id;
@override final  String productoId;
@override final  TipoPresentacion tipo;
@override final  String nombre;
@override final  int precioBaseCentimos;
@override final  int stock;
@override@JsonKey() final  int unidadesPorPresentacion;

/// Create a copy of Presentacion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresentacionCopyWith<_Presentacion> get copyWith => __$PresentacionCopyWithImpl<_Presentacion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresentacionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Presentacion&&(identical(other.id, id) || other.id == id)&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.precioBaseCentimos, precioBaseCentimos) || other.precioBaseCentimos == precioBaseCentimos)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.unidadesPorPresentacion, unidadesPorPresentacion) || other.unidadesPorPresentacion == unidadesPorPresentacion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,productoId,tipo,nombre,precioBaseCentimos,stock,unidadesPorPresentacion);
}

@override
String toString() {
    return 'Presentacion(id: $id, productoId: $productoId, tipo: $tipo, nombre: $nombre, precioBaseCentimos: $precioBaseCentimos, stock: $stock, unidadesPorPresentacion: $unidadesPorPresentacion)';
}


}

/// @nodoc
abstract mixin class _$PresentacionCopyWith<$Res> implements $PresentacionCopyWith<$Res> {
  factory _$PresentacionCopyWith(_Presentacion value, $Res Function(_Presentacion) _then) = __$PresentacionCopyWithImpl;
@override @useResult
$Res call({
 String id, String productoId, TipoPresentacion tipo, String nombre, int precioBaseCentimos, int stock, int unidadesPorPresentacion
});




}
/// @nodoc
class __$PresentacionCopyWithImpl<$Res>
    implements _$PresentacionCopyWith<$Res> {
  __$PresentacionCopyWithImpl(this._self, this._then);

  final _Presentacion _self;
  final $Res Function(_Presentacion) _then;

/// Create a copy of Presentacion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productoId = null,Object? tipo = null,Object? nombre = null,Object? precioBaseCentimos = null,Object? stock = null,Object? unidadesPorPresentacion = null,}) {
  return _then(_Presentacion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoPresentacion,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precioBaseCentimos: null == precioBaseCentimos ? _self.precioBaseCentimos : precioBaseCentimos // ignore: cast_nullable_to_non_nullable
as int,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,unidadesPorPresentacion: null == unidadesPorPresentacion ? _self.unidadesPorPresentacion : unidadesPorPresentacion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
