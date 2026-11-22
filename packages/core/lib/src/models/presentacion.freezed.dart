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

 String get id; String get distribuidorId; String get productoId; String get nombre; int get factor; int get precioBaseCentimos; int get orden; bool get activo; DateTime get creadoEn; List<PrecioVolumen> get preciosVolumen;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Presentacion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.productoId, _this.productoId) || other.productoId == _this.productoId)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.factor, _this.factor) || other.factor == _this.factor)&&(identical(other.precioBaseCentimos, _this.precioBaseCentimos) || other.precioBaseCentimos == _this.precioBaseCentimos)&&(identical(other.orden, _this.orden) || other.orden == _this.orden)&&(identical(other.activo, _this.activo) || other.activo == _this.activo)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn)&&const DeepCollectionEquality().equals(other.preciosVolumen, _this.preciosVolumen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Presentacion;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.productoId,_this.nombre,_this.factor,_this.precioBaseCentimos,_this.orden,_this.activo,_this.creadoEn,const DeepCollectionEquality().hash(_this.preciosVolumen));
}

@override
String toString() {
  final _this = this as Presentacion;
  return 'Presentacion(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, productoId: ${_this.productoId}, nombre: ${_this.nombre}, factor: ${_this.factor}, precioBaseCentimos: ${_this.precioBaseCentimos}, orden: ${_this.orden}, activo: ${_this.activo}, creadoEn: ${_this.creadoEn}, preciosVolumen: ${_this.preciosVolumen})';
}


}

/// @nodoc
abstract mixin class $PresentacionCopyWith<$Res>  {
  factory $PresentacionCopyWith(Presentacion value, $Res Function(Presentacion) _then) = _$PresentacionCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String productoId, String nombre, int factor, int precioBaseCentimos, int orden, bool activo, DateTime creadoEn, List<PrecioVolumen> preciosVolumen
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? productoId = null,Object? nombre = null,Object? factor = null,Object? precioBaseCentimos = null,Object? orden = null,Object? activo = null,Object? creadoEn = null,Object? preciosVolumen = null,}) {
  return _then(Presentacion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,factor: null == factor ? _self.factor : factor // ignore: cast_nullable_to_non_nullable
as int,precioBaseCentimos: null == precioBaseCentimos ? _self.precioBaseCentimos : precioBaseCentimos // ignore: cast_nullable_to_non_nullable
as int,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,preciosVolumen: null == preciosVolumen ? _self.preciosVolumen : preciosVolumen // ignore: cast_nullable_to_non_nullable
as List<PrecioVolumen>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String productoId,  String nombre,  int factor,  int precioBaseCentimos,  int orden,  bool activo,  DateTime creadoEn,  List<PrecioVolumen> preciosVolumen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Presentacion() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.productoId,_that.nombre,_that.factor,_that.precioBaseCentimos,_that.orden,_that.activo,_that.creadoEn,_that.preciosVolumen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String productoId,  String nombre,  int factor,  int precioBaseCentimos,  int orden,  bool activo,  DateTime creadoEn,  List<PrecioVolumen> preciosVolumen)  $default,) {final _that = this;
switch (_that) {
case _Presentacion():
return $default(_that.id,_that.distribuidorId,_that.productoId,_that.nombre,_that.factor,_that.precioBaseCentimos,_that.orden,_that.activo,_that.creadoEn,_that.preciosVolumen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String productoId,  String nombre,  int factor,  int precioBaseCentimos,  int orden,  bool activo,  DateTime creadoEn,  List<PrecioVolumen> preciosVolumen)?  $default,) {final _that = this;
switch (_that) {
case _Presentacion() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.productoId,_that.nombre,_that.factor,_that.precioBaseCentimos,_that.orden,_that.activo,_that.creadoEn,_that.preciosVolumen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Presentacion extends Presentacion {
  const _Presentacion({required this.id, required this.distribuidorId, required this.productoId, required this.nombre, required this.factor, required this.precioBaseCentimos, required this.orden, required this.activo, required this.creadoEn,  List<PrecioVolumen> preciosVolumen = const <PrecioVolumen>[]}): _preciosVolumen = preciosVolumen,super._();
  factory _Presentacion.fromJson(Map<String, dynamic> json) => _$PresentacionFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String productoId;
@override final  String nombre;
@override final  int factor;
@override final  int precioBaseCentimos;
@override final  int orden;
@override final  bool activo;
@override final  DateTime creadoEn;
 final  List<PrecioVolumen> _preciosVolumen;
@override@JsonKey() List<PrecioVolumen> get preciosVolumen {
  if (_preciosVolumen is EqualUnmodifiableListView) return _preciosVolumen;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preciosVolumen);
}


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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Presentacion&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.factor, factor) || other.factor == factor)&&(identical(other.precioBaseCentimos, precioBaseCentimos) || other.precioBaseCentimos == precioBaseCentimos)&&(identical(other.orden, orden) || other.orden == orden)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn)&&const DeepCollectionEquality().equals(other.preciosVolumen, _preciosVolumen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,productoId,nombre,factor,precioBaseCentimos,orden,activo,creadoEn,const DeepCollectionEquality().hash(_preciosVolumen));
}

@override
String toString() {
    return 'Presentacion(id: $id, distribuidorId: $distribuidorId, productoId: $productoId, nombre: $nombre, factor: $factor, precioBaseCentimos: $precioBaseCentimos, orden: $orden, activo: $activo, creadoEn: $creadoEn, preciosVolumen: $preciosVolumen)';
}


}

/// @nodoc
abstract mixin class _$PresentacionCopyWith<$Res> implements $PresentacionCopyWith<$Res> {
  factory _$PresentacionCopyWith(_Presentacion value, $Res Function(_Presentacion) _then) = __$PresentacionCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String productoId, String nombre, int factor, int precioBaseCentimos, int orden, bool activo, DateTime creadoEn, List<PrecioVolumen> preciosVolumen
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? productoId = null,Object? nombre = null,Object? factor = null,Object? precioBaseCentimos = null,Object? orden = null,Object? activo = null,Object? creadoEn = null,Object? preciosVolumen = null,}) {
  return _then(_Presentacion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,factor: null == factor ? _self.factor : factor // ignore: cast_nullable_to_non_nullable
as int,precioBaseCentimos: null == precioBaseCentimos ? _self.precioBaseCentimos : precioBaseCentimos // ignore: cast_nullable_to_non_nullable
as int,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,preciosVolumen: null == preciosVolumen ? _self._preciosVolumen : preciosVolumen // ignore: cast_nullable_to_non_nullable
as List<PrecioVolumen>,
  ));
}


}

// dart format on
