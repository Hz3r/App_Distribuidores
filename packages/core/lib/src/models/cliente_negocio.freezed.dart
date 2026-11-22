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

 String get id; String get distribuidorId; String get nombreNegocio; String? get documento; String? get direccion; String? get referencia; String? get telefono; bool get activo; DateTime get creadoEn; String? get listaPreciosId; bool get creditoHabilitado; int? get limiteCreditoCentimos; int? get plazoCreditoDias;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClienteNegocio&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.nombreNegocio, _this.nombreNegocio) || other.nombreNegocio == _this.nombreNegocio)&&(identical(other.documento, _this.documento) || other.documento == _this.documento)&&(identical(other.direccion, _this.direccion) || other.direccion == _this.direccion)&&(identical(other.referencia, _this.referencia) || other.referencia == _this.referencia)&&(identical(other.telefono, _this.telefono) || other.telefono == _this.telefono)&&(identical(other.activo, _this.activo) || other.activo == _this.activo)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn)&&(identical(other.listaPreciosId, _this.listaPreciosId) || other.listaPreciosId == _this.listaPreciosId)&&(identical(other.creditoHabilitado, _this.creditoHabilitado) || other.creditoHabilitado == _this.creditoHabilitado)&&(identical(other.limiteCreditoCentimos, _this.limiteCreditoCentimos) || other.limiteCreditoCentimos == _this.limiteCreditoCentimos)&&(identical(other.plazoCreditoDias, _this.plazoCreditoDias) || other.plazoCreditoDias == _this.plazoCreditoDias));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClienteNegocio;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.nombreNegocio,_this.documento,_this.direccion,_this.referencia,_this.telefono,_this.activo,_this.creadoEn,_this.listaPreciosId,_this.creditoHabilitado,_this.limiteCreditoCentimos,_this.plazoCreditoDias);
}

@override
String toString() {
  final _this = this as ClienteNegocio;
  return 'ClienteNegocio(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, nombreNegocio: ${_this.nombreNegocio}, documento: ${_this.documento}, direccion: ${_this.direccion}, referencia: ${_this.referencia}, telefono: ${_this.telefono}, activo: ${_this.activo}, creadoEn: ${_this.creadoEn}, listaPreciosId: ${_this.listaPreciosId}, creditoHabilitado: ${_this.creditoHabilitado}, limiteCreditoCentimos: ${_this.limiteCreditoCentimos}, plazoCreditoDias: ${_this.plazoCreditoDias})';
}


}

/// @nodoc
abstract mixin class $ClienteNegocioCopyWith<$Res>  {
  factory $ClienteNegocioCopyWith(ClienteNegocio value, $Res Function(ClienteNegocio) _then) = _$ClienteNegocioCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String nombreNegocio, String? documento, String? direccion, String? referencia, String? telefono, bool activo, DateTime creadoEn, String? listaPreciosId, bool creditoHabilitado, int? limiteCreditoCentimos, int? plazoCreditoDias
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? nombreNegocio = null,Object? documento = freezed,Object? direccion = freezed,Object? referencia = freezed,Object? telefono = freezed,Object? activo = null,Object? creadoEn = null,Object? listaPreciosId = freezed,Object? creditoHabilitado = null,Object? limiteCreditoCentimos = freezed,Object? plazoCreditoDias = freezed,}) {
  return _then(ClienteNegocio(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,nombreNegocio: null == nombreNegocio ? _self.nombreNegocio : nombreNegocio // ignore: cast_nullable_to_non_nullable
as String,documento: freezed == documento ? _self.documento : documento // ignore: cast_nullable_to_non_nullable
as String?,direccion: freezed == direccion ? _self.direccion : direccion // ignore: cast_nullable_to_non_nullable
as String?,referencia: freezed == referencia ? _self.referencia : referencia // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,listaPreciosId: freezed == listaPreciosId ? _self.listaPreciosId : listaPreciosId // ignore: cast_nullable_to_non_nullable
as String?,creditoHabilitado: null == creditoHabilitado ? _self.creditoHabilitado : creditoHabilitado // ignore: cast_nullable_to_non_nullable
as bool,limiteCreditoCentimos: freezed == limiteCreditoCentimos ? _self.limiteCreditoCentimos : limiteCreditoCentimos // ignore: cast_nullable_to_non_nullable
as int?,plazoCreditoDias: freezed == plazoCreditoDias ? _self.plazoCreditoDias : plazoCreditoDias // ignore: cast_nullable_to_non_nullable
as int?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String nombreNegocio,  String? documento,  String? direccion,  String? referencia,  String? telefono,  bool activo,  DateTime creadoEn,  String? listaPreciosId,  bool creditoHabilitado,  int? limiteCreditoCentimos,  int? plazoCreditoDias)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClienteNegocio() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.nombreNegocio,_that.documento,_that.direccion,_that.referencia,_that.telefono,_that.activo,_that.creadoEn,_that.listaPreciosId,_that.creditoHabilitado,_that.limiteCreditoCentimos,_that.plazoCreditoDias);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String nombreNegocio,  String? documento,  String? direccion,  String? referencia,  String? telefono,  bool activo,  DateTime creadoEn,  String? listaPreciosId,  bool creditoHabilitado,  int? limiteCreditoCentimos,  int? plazoCreditoDias)  $default,) {final _that = this;
switch (_that) {
case _ClienteNegocio():
return $default(_that.id,_that.distribuidorId,_that.nombreNegocio,_that.documento,_that.direccion,_that.referencia,_that.telefono,_that.activo,_that.creadoEn,_that.listaPreciosId,_that.creditoHabilitado,_that.limiteCreditoCentimos,_that.plazoCreditoDias);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String nombreNegocio,  String? documento,  String? direccion,  String? referencia,  String? telefono,  bool activo,  DateTime creadoEn,  String? listaPreciosId,  bool creditoHabilitado,  int? limiteCreditoCentimos,  int? plazoCreditoDias)?  $default,) {final _that = this;
switch (_that) {
case _ClienteNegocio() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.nombreNegocio,_that.documento,_that.direccion,_that.referencia,_that.telefono,_that.activo,_that.creadoEn,_that.listaPreciosId,_that.creditoHabilitado,_that.limiteCreditoCentimos,_that.plazoCreditoDias);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClienteNegocio implements ClienteNegocio {
  const _ClienteNegocio({required this.id, required this.distribuidorId, required this.nombreNegocio, this.documento, this.direccion, this.referencia, this.telefono, required this.activo, required this.creadoEn, this.listaPreciosId, required this.creditoHabilitado, this.limiteCreditoCentimos, this.plazoCreditoDias});
  factory _ClienteNegocio.fromJson(Map<String, dynamic> json) => _$ClienteNegocioFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String nombreNegocio;
@override final  String? documento;
@override final  String? direccion;
@override final  String? referencia;
@override final  String? telefono;
@override final  bool activo;
@override final  DateTime creadoEn;
@override final  String? listaPreciosId;
@override final  bool creditoHabilitado;
@override final  int? limiteCreditoCentimos;
@override final  int? plazoCreditoDias;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClienteNegocio&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.nombreNegocio, nombreNegocio) || other.nombreNegocio == nombreNegocio)&&(identical(other.documento, documento) || other.documento == documento)&&(identical(other.direccion, direccion) || other.direccion == direccion)&&(identical(other.referencia, referencia) || other.referencia == referencia)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn)&&(identical(other.listaPreciosId, listaPreciosId) || other.listaPreciosId == listaPreciosId)&&(identical(other.creditoHabilitado, creditoHabilitado) || other.creditoHabilitado == creditoHabilitado)&&(identical(other.limiteCreditoCentimos, limiteCreditoCentimos) || other.limiteCreditoCentimos == limiteCreditoCentimos)&&(identical(other.plazoCreditoDias, plazoCreditoDias) || other.plazoCreditoDias == plazoCreditoDias));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,nombreNegocio,documento,direccion,referencia,telefono,activo,creadoEn,listaPreciosId,creditoHabilitado,limiteCreditoCentimos,plazoCreditoDias);
}

@override
String toString() {
    return 'ClienteNegocio(id: $id, distribuidorId: $distribuidorId, nombreNegocio: $nombreNegocio, documento: $documento, direccion: $direccion, referencia: $referencia, telefono: $telefono, activo: $activo, creadoEn: $creadoEn, listaPreciosId: $listaPreciosId, creditoHabilitado: $creditoHabilitado, limiteCreditoCentimos: $limiteCreditoCentimos, plazoCreditoDias: $plazoCreditoDias)';
}


}

/// @nodoc
abstract mixin class _$ClienteNegocioCopyWith<$Res> implements $ClienteNegocioCopyWith<$Res> {
  factory _$ClienteNegocioCopyWith(_ClienteNegocio value, $Res Function(_ClienteNegocio) _then) = __$ClienteNegocioCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String nombreNegocio, String? documento, String? direccion, String? referencia, String? telefono, bool activo, DateTime creadoEn, String? listaPreciosId, bool creditoHabilitado, int? limiteCreditoCentimos, int? plazoCreditoDias
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? nombreNegocio = null,Object? documento = freezed,Object? direccion = freezed,Object? referencia = freezed,Object? telefono = freezed,Object? activo = null,Object? creadoEn = null,Object? listaPreciosId = freezed,Object? creditoHabilitado = null,Object? limiteCreditoCentimos = freezed,Object? plazoCreditoDias = freezed,}) {
  return _then(_ClienteNegocio(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,nombreNegocio: null == nombreNegocio ? _self.nombreNegocio : nombreNegocio // ignore: cast_nullable_to_non_nullable
as String,documento: freezed == documento ? _self.documento : documento // ignore: cast_nullable_to_non_nullable
as String?,direccion: freezed == direccion ? _self.direccion : direccion // ignore: cast_nullable_to_non_nullable
as String?,referencia: freezed == referencia ? _self.referencia : referencia // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,listaPreciosId: freezed == listaPreciosId ? _self.listaPreciosId : listaPreciosId // ignore: cast_nullable_to_non_nullable
as String?,creditoHabilitado: null == creditoHabilitado ? _self.creditoHabilitado : creditoHabilitado // ignore: cast_nullable_to_non_nullable
as bool,limiteCreditoCentimos: freezed == limiteCreditoCentimos ? _self.limiteCreditoCentimos : limiteCreditoCentimos // ignore: cast_nullable_to_non_nullable
as int?,plazoCreditoDias: freezed == plazoCreditoDias ? _self.plazoCreditoDias : plazoCreditoDias // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
