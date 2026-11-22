// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'suscripcion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Suscripcion {

 String get id; String get distribuidorId; String get planId; EstadoSuscripcion get estado; DateTime get periodoInicio; DateTime get periodoFin; String? get proveedorPago; String? get referenciaExterna; DateTime get creadoEn;
/// Create a copy of Suscripcion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuscripcionCopyWith<Suscripcion> get copyWith => _$SuscripcionCopyWithImpl<Suscripcion>(this as Suscripcion, _$identity);

  /// Serializes this Suscripcion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Suscripcion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Suscripcion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.planId, _this.planId) || other.planId == _this.planId)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.periodoInicio, _this.periodoInicio) || other.periodoInicio == _this.periodoInicio)&&(identical(other.periodoFin, _this.periodoFin) || other.periodoFin == _this.periodoFin)&&(identical(other.proveedorPago, _this.proveedorPago) || other.proveedorPago == _this.proveedorPago)&&(identical(other.referenciaExterna, _this.referenciaExterna) || other.referenciaExterna == _this.referenciaExterna)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Suscripcion;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.planId,_this.estado,_this.periodoInicio,_this.periodoFin,_this.proveedorPago,_this.referenciaExterna,_this.creadoEn);
}

@override
String toString() {
  final _this = this as Suscripcion;
  return 'Suscripcion(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, planId: ${_this.planId}, estado: ${_this.estado}, periodoInicio: ${_this.periodoInicio}, periodoFin: ${_this.periodoFin}, proveedorPago: ${_this.proveedorPago}, referenciaExterna: ${_this.referenciaExterna}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $SuscripcionCopyWith<$Res>  {
  factory $SuscripcionCopyWith(Suscripcion value, $Res Function(Suscripcion) _then) = _$SuscripcionCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String planId, EstadoSuscripcion estado, DateTime periodoInicio, DateTime periodoFin, String? proveedorPago, String? referenciaExterna, DateTime creadoEn
});




}
/// @nodoc
class _$SuscripcionCopyWithImpl<$Res>
    implements $SuscripcionCopyWith<$Res> {
  _$SuscripcionCopyWithImpl(this._self, this._then);

  final Suscripcion _self;
  final $Res Function(Suscripcion) _then;

/// Create a copy of Suscripcion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? planId = null,Object? estado = null,Object? periodoInicio = null,Object? periodoFin = null,Object? proveedorPago = freezed,Object? referenciaExterna = freezed,Object? creadoEn = null,}) {
  return _then(Suscripcion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoSuscripcion,periodoInicio: null == periodoInicio ? _self.periodoInicio : periodoInicio // ignore: cast_nullable_to_non_nullable
as DateTime,periodoFin: null == periodoFin ? _self.periodoFin : periodoFin // ignore: cast_nullable_to_non_nullable
as DateTime,proveedorPago: freezed == proveedorPago ? _self.proveedorPago : proveedorPago // ignore: cast_nullable_to_non_nullable
as String?,referenciaExterna: freezed == referenciaExterna ? _self.referenciaExterna : referenciaExterna // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Suscripcion].
extension SuscripcionPatterns on Suscripcion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Suscripcion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Suscripcion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Suscripcion value)  $default,){
final _that = this;
switch (_that) {
case _Suscripcion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Suscripcion value)?  $default,){
final _that = this;
switch (_that) {
case _Suscripcion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String planId,  EstadoSuscripcion estado,  DateTime periodoInicio,  DateTime periodoFin,  String? proveedorPago,  String? referenciaExterna,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Suscripcion() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.planId,_that.estado,_that.periodoInicio,_that.periodoFin,_that.proveedorPago,_that.referenciaExterna,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String planId,  EstadoSuscripcion estado,  DateTime periodoInicio,  DateTime periodoFin,  String? proveedorPago,  String? referenciaExterna,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _Suscripcion():
return $default(_that.id,_that.distribuidorId,_that.planId,_that.estado,_that.periodoInicio,_that.periodoFin,_that.proveedorPago,_that.referenciaExterna,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String planId,  EstadoSuscripcion estado,  DateTime periodoInicio,  DateTime periodoFin,  String? proveedorPago,  String? referenciaExterna,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Suscripcion() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.planId,_that.estado,_that.periodoInicio,_that.periodoFin,_that.proveedorPago,_that.referenciaExterna,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Suscripcion implements Suscripcion {
  const _Suscripcion({required this.id, required this.distribuidorId, required this.planId, required this.estado, required this.periodoInicio, required this.periodoFin, this.proveedorPago, this.referenciaExterna, required this.creadoEn});
  factory _Suscripcion.fromJson(Map<String, dynamic> json) => _$SuscripcionFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String planId;
@override final  EstadoSuscripcion estado;
@override final  DateTime periodoInicio;
@override final  DateTime periodoFin;
@override final  String? proveedorPago;
@override final  String? referenciaExterna;
@override final  DateTime creadoEn;

/// Create a copy of Suscripcion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuscripcionCopyWith<_Suscripcion> get copyWith => __$SuscripcionCopyWithImpl<_Suscripcion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuscripcionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Suscripcion&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.periodoInicio, periodoInicio) || other.periodoInicio == periodoInicio)&&(identical(other.periodoFin, periodoFin) || other.periodoFin == periodoFin)&&(identical(other.proveedorPago, proveedorPago) || other.proveedorPago == proveedorPago)&&(identical(other.referenciaExterna, referenciaExterna) || other.referenciaExterna == referenciaExterna)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,planId,estado,periodoInicio,periodoFin,proveedorPago,referenciaExterna,creadoEn);
}

@override
String toString() {
    return 'Suscripcion(id: $id, distribuidorId: $distribuidorId, planId: $planId, estado: $estado, periodoInicio: $periodoInicio, periodoFin: $periodoFin, proveedorPago: $proveedorPago, referenciaExterna: $referenciaExterna, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$SuscripcionCopyWith<$Res> implements $SuscripcionCopyWith<$Res> {
  factory _$SuscripcionCopyWith(_Suscripcion value, $Res Function(_Suscripcion) _then) = __$SuscripcionCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String planId, EstadoSuscripcion estado, DateTime periodoInicio, DateTime periodoFin, String? proveedorPago, String? referenciaExterna, DateTime creadoEn
});




}
/// @nodoc
class __$SuscripcionCopyWithImpl<$Res>
    implements _$SuscripcionCopyWith<$Res> {
  __$SuscripcionCopyWithImpl(this._self, this._then);

  final _Suscripcion _self;
  final $Res Function(_Suscripcion) _then;

/// Create a copy of Suscripcion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? planId = null,Object? estado = null,Object? periodoInicio = null,Object? periodoFin = null,Object? proveedorPago = freezed,Object? referenciaExterna = freezed,Object? creadoEn = null,}) {
  return _then(_Suscripcion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoSuscripcion,periodoInicio: null == periodoInicio ? _self.periodoInicio : periodoInicio // ignore: cast_nullable_to_non_nullable
as DateTime,periodoFin: null == periodoFin ? _self.periodoFin : periodoFin // ignore: cast_nullable_to_non_nullable
as DateTime,proveedorPago: freezed == proveedorPago ? _self.proveedorPago : proveedorPago // ignore: cast_nullable_to_non_nullable
as String?,referenciaExterna: freezed == referenciaExterna ? _self.referenciaExterna : referenciaExterna // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
