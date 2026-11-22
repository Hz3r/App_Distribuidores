// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pago_suscripcion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PagoSuscripcion {

 String get id; String get distribuidorId; String get suscripcionId; int get montoCentimos; String get metodo; DateTime get periodoInicio; DateTime get periodoFin; String? get registradoPor; String? get referenciaExterna; String? get nota; DateTime get creadoEn;
/// Create a copy of PagoSuscripcion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagoSuscripcionCopyWith<PagoSuscripcion> get copyWith => _$PagoSuscripcionCopyWithImpl<PagoSuscripcion>(this as PagoSuscripcion, _$identity);

  /// Serializes this PagoSuscripcion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PagoSuscripcion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PagoSuscripcion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.suscripcionId, _this.suscripcionId) || other.suscripcionId == _this.suscripcionId)&&(identical(other.montoCentimos, _this.montoCentimos) || other.montoCentimos == _this.montoCentimos)&&(identical(other.metodo, _this.metodo) || other.metodo == _this.metodo)&&(identical(other.periodoInicio, _this.periodoInicio) || other.periodoInicio == _this.periodoInicio)&&(identical(other.periodoFin, _this.periodoFin) || other.periodoFin == _this.periodoFin)&&(identical(other.registradoPor, _this.registradoPor) || other.registradoPor == _this.registradoPor)&&(identical(other.referenciaExterna, _this.referenciaExterna) || other.referenciaExterna == _this.referenciaExterna)&&(identical(other.nota, _this.nota) || other.nota == _this.nota)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PagoSuscripcion;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.suscripcionId,_this.montoCentimos,_this.metodo,_this.periodoInicio,_this.periodoFin,_this.registradoPor,_this.referenciaExterna,_this.nota,_this.creadoEn);
}

@override
String toString() {
  final _this = this as PagoSuscripcion;
  return 'PagoSuscripcion(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, suscripcionId: ${_this.suscripcionId}, montoCentimos: ${_this.montoCentimos}, metodo: ${_this.metodo}, periodoInicio: ${_this.periodoInicio}, periodoFin: ${_this.periodoFin}, registradoPor: ${_this.registradoPor}, referenciaExterna: ${_this.referenciaExterna}, nota: ${_this.nota}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $PagoSuscripcionCopyWith<$Res>  {
  factory $PagoSuscripcionCopyWith(PagoSuscripcion value, $Res Function(PagoSuscripcion) _then) = _$PagoSuscripcionCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String suscripcionId, int montoCentimos, String metodo, DateTime periodoInicio, DateTime periodoFin, String? registradoPor, String? referenciaExterna, String? nota, DateTime creadoEn
});




}
/// @nodoc
class _$PagoSuscripcionCopyWithImpl<$Res>
    implements $PagoSuscripcionCopyWith<$Res> {
  _$PagoSuscripcionCopyWithImpl(this._self, this._then);

  final PagoSuscripcion _self;
  final $Res Function(PagoSuscripcion) _then;

/// Create a copy of PagoSuscripcion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? suscripcionId = null,Object? montoCentimos = null,Object? metodo = null,Object? periodoInicio = null,Object? periodoFin = null,Object? registradoPor = freezed,Object? referenciaExterna = freezed,Object? nota = freezed,Object? creadoEn = null,}) {
  return _then(PagoSuscripcion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,suscripcionId: null == suscripcionId ? _self.suscripcionId : suscripcionId // ignore: cast_nullable_to_non_nullable
as String,montoCentimos: null == montoCentimos ? _self.montoCentimos : montoCentimos // ignore: cast_nullable_to_non_nullable
as int,metodo: null == metodo ? _self.metodo : metodo // ignore: cast_nullable_to_non_nullable
as String,periodoInicio: null == periodoInicio ? _self.periodoInicio : periodoInicio // ignore: cast_nullable_to_non_nullable
as DateTime,periodoFin: null == periodoFin ? _self.periodoFin : periodoFin // ignore: cast_nullable_to_non_nullable
as DateTime,registradoPor: freezed == registradoPor ? _self.registradoPor : registradoPor // ignore: cast_nullable_to_non_nullable
as String?,referenciaExterna: freezed == referenciaExterna ? _self.referenciaExterna : referenciaExterna // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PagoSuscripcion].
extension PagoSuscripcionPatterns on PagoSuscripcion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PagoSuscripcion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PagoSuscripcion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PagoSuscripcion value)  $default,){
final _that = this;
switch (_that) {
case _PagoSuscripcion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PagoSuscripcion value)?  $default,){
final _that = this;
switch (_that) {
case _PagoSuscripcion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String suscripcionId,  int montoCentimos,  String metodo,  DateTime periodoInicio,  DateTime periodoFin,  String? registradoPor,  String? referenciaExterna,  String? nota,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PagoSuscripcion() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.suscripcionId,_that.montoCentimos,_that.metodo,_that.periodoInicio,_that.periodoFin,_that.registradoPor,_that.referenciaExterna,_that.nota,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String suscripcionId,  int montoCentimos,  String metodo,  DateTime periodoInicio,  DateTime periodoFin,  String? registradoPor,  String? referenciaExterna,  String? nota,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _PagoSuscripcion():
return $default(_that.id,_that.distribuidorId,_that.suscripcionId,_that.montoCentimos,_that.metodo,_that.periodoInicio,_that.periodoFin,_that.registradoPor,_that.referenciaExterna,_that.nota,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String suscripcionId,  int montoCentimos,  String metodo,  DateTime periodoInicio,  DateTime periodoFin,  String? registradoPor,  String? referenciaExterna,  String? nota,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _PagoSuscripcion() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.suscripcionId,_that.montoCentimos,_that.metodo,_that.periodoInicio,_that.periodoFin,_that.registradoPor,_that.referenciaExterna,_that.nota,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PagoSuscripcion implements PagoSuscripcion {
  const _PagoSuscripcion({required this.id, required this.distribuidorId, required this.suscripcionId, required this.montoCentimos, required this.metodo, required this.periodoInicio, required this.periodoFin, this.registradoPor, this.referenciaExterna, this.nota, required this.creadoEn});
  factory _PagoSuscripcion.fromJson(Map<String, dynamic> json) => _$PagoSuscripcionFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String suscripcionId;
@override final  int montoCentimos;
@override final  String metodo;
@override final  DateTime periodoInicio;
@override final  DateTime periodoFin;
@override final  String? registradoPor;
@override final  String? referenciaExterna;
@override final  String? nota;
@override final  DateTime creadoEn;

/// Create a copy of PagoSuscripcion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagoSuscripcionCopyWith<_PagoSuscripcion> get copyWith => __$PagoSuscripcionCopyWithImpl<_PagoSuscripcion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagoSuscripcionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PagoSuscripcion&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.suscripcionId, suscripcionId) || other.suscripcionId == suscripcionId)&&(identical(other.montoCentimos, montoCentimos) || other.montoCentimos == montoCentimos)&&(identical(other.metodo, metodo) || other.metodo == metodo)&&(identical(other.periodoInicio, periodoInicio) || other.periodoInicio == periodoInicio)&&(identical(other.periodoFin, periodoFin) || other.periodoFin == periodoFin)&&(identical(other.registradoPor, registradoPor) || other.registradoPor == registradoPor)&&(identical(other.referenciaExterna, referenciaExterna) || other.referenciaExterna == referenciaExterna)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,suscripcionId,montoCentimos,metodo,periodoInicio,periodoFin,registradoPor,referenciaExterna,nota,creadoEn);
}

@override
String toString() {
    return 'PagoSuscripcion(id: $id, distribuidorId: $distribuidorId, suscripcionId: $suscripcionId, montoCentimos: $montoCentimos, metodo: $metodo, periodoInicio: $periodoInicio, periodoFin: $periodoFin, registradoPor: $registradoPor, referenciaExterna: $referenciaExterna, nota: $nota, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$PagoSuscripcionCopyWith<$Res> implements $PagoSuscripcionCopyWith<$Res> {
  factory _$PagoSuscripcionCopyWith(_PagoSuscripcion value, $Res Function(_PagoSuscripcion) _then) = __$PagoSuscripcionCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String suscripcionId, int montoCentimos, String metodo, DateTime periodoInicio, DateTime periodoFin, String? registradoPor, String? referenciaExterna, String? nota, DateTime creadoEn
});




}
/// @nodoc
class __$PagoSuscripcionCopyWithImpl<$Res>
    implements _$PagoSuscripcionCopyWith<$Res> {
  __$PagoSuscripcionCopyWithImpl(this._self, this._then);

  final _PagoSuscripcion _self;
  final $Res Function(_PagoSuscripcion) _then;

/// Create a copy of PagoSuscripcion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? suscripcionId = null,Object? montoCentimos = null,Object? metodo = null,Object? periodoInicio = null,Object? periodoFin = null,Object? registradoPor = freezed,Object? referenciaExterna = freezed,Object? nota = freezed,Object? creadoEn = null,}) {
  return _then(_PagoSuscripcion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,suscripcionId: null == suscripcionId ? _self.suscripcionId : suscripcionId // ignore: cast_nullable_to_non_nullable
as String,montoCentimos: null == montoCentimos ? _self.montoCentimos : montoCentimos // ignore: cast_nullable_to_non_nullable
as int,metodo: null == metodo ? _self.metodo : metodo // ignore: cast_nullable_to_non_nullable
as String,periodoInicio: null == periodoInicio ? _self.periodoInicio : periodoInicio // ignore: cast_nullable_to_non_nullable
as DateTime,periodoFin: null == periodoFin ? _self.periodoFin : periodoFin // ignore: cast_nullable_to_non_nullable
as DateTime,registradoPor: freezed == registradoPor ? _self.registradoPor : registradoPor // ignore: cast_nullable_to_non_nullable
as String?,referenciaExterna: freezed == referenciaExterna ? _self.referenciaExterna : referenciaExterna // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
