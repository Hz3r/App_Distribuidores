// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pago.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pago {

 String get id; String get distribuidorId; String get pedidoId; String get clienteId; int get montoCentimos; MetodoPago get metodo; String? get referencia; String? get nota; String? get registradoPor; DateTime? get anuladoEn; String? get anuladoPor; DateTime get creadoEn;
/// Create a copy of Pago
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PagoCopyWith<Pago> get copyWith => _$PagoCopyWithImpl<Pago>(this as Pago, _$identity);

  /// Serializes this Pago to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Pago;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pago&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.pedidoId, _this.pedidoId) || other.pedidoId == _this.pedidoId)&&(identical(other.clienteId, _this.clienteId) || other.clienteId == _this.clienteId)&&(identical(other.montoCentimos, _this.montoCentimos) || other.montoCentimos == _this.montoCentimos)&&(identical(other.metodo, _this.metodo) || other.metodo == _this.metodo)&&(identical(other.referencia, _this.referencia) || other.referencia == _this.referencia)&&(identical(other.nota, _this.nota) || other.nota == _this.nota)&&(identical(other.registradoPor, _this.registradoPor) || other.registradoPor == _this.registradoPor)&&(identical(other.anuladoEn, _this.anuladoEn) || other.anuladoEn == _this.anuladoEn)&&(identical(other.anuladoPor, _this.anuladoPor) || other.anuladoPor == _this.anuladoPor)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Pago;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.pedidoId,_this.clienteId,_this.montoCentimos,_this.metodo,_this.referencia,_this.nota,_this.registradoPor,_this.anuladoEn,_this.anuladoPor,_this.creadoEn);
}

@override
String toString() {
  final _this = this as Pago;
  return 'Pago(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, pedidoId: ${_this.pedidoId}, clienteId: ${_this.clienteId}, montoCentimos: ${_this.montoCentimos}, metodo: ${_this.metodo}, referencia: ${_this.referencia}, nota: ${_this.nota}, registradoPor: ${_this.registradoPor}, anuladoEn: ${_this.anuladoEn}, anuladoPor: ${_this.anuladoPor}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $PagoCopyWith<$Res>  {
  factory $PagoCopyWith(Pago value, $Res Function(Pago) _then) = _$PagoCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String pedidoId, String clienteId, int montoCentimos, MetodoPago metodo, String? referencia, String? nota, String? registradoPor, DateTime? anuladoEn, String? anuladoPor, DateTime creadoEn
});




}
/// @nodoc
class _$PagoCopyWithImpl<$Res>
    implements $PagoCopyWith<$Res> {
  _$PagoCopyWithImpl(this._self, this._then);

  final Pago _self;
  final $Res Function(Pago) _then;

/// Create a copy of Pago
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? pedidoId = null,Object? clienteId = null,Object? montoCentimos = null,Object? metodo = null,Object? referencia = freezed,Object? nota = freezed,Object? registradoPor = freezed,Object? anuladoEn = freezed,Object? anuladoPor = freezed,Object? creadoEn = null,}) {
  return _then(Pago(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,pedidoId: null == pedidoId ? _self.pedidoId : pedidoId // ignore: cast_nullable_to_non_nullable
as String,clienteId: null == clienteId ? _self.clienteId : clienteId // ignore: cast_nullable_to_non_nullable
as String,montoCentimos: null == montoCentimos ? _self.montoCentimos : montoCentimos // ignore: cast_nullable_to_non_nullable
as int,metodo: null == metodo ? _self.metodo : metodo // ignore: cast_nullable_to_non_nullable
as MetodoPago,referencia: freezed == referencia ? _self.referencia : referencia // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,registradoPor: freezed == registradoPor ? _self.registradoPor : registradoPor // ignore: cast_nullable_to_non_nullable
as String?,anuladoEn: freezed == anuladoEn ? _self.anuladoEn : anuladoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,anuladoPor: freezed == anuladoPor ? _self.anuladoPor : anuladoPor // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Pago].
extension PagoPatterns on Pago {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pago value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pago() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pago value)  $default,){
final _that = this;
switch (_that) {
case _Pago():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pago value)?  $default,){
final _that = this;
switch (_that) {
case _Pago() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String pedidoId,  String clienteId,  int montoCentimos,  MetodoPago metodo,  String? referencia,  String? nota,  String? registradoPor,  DateTime? anuladoEn,  String? anuladoPor,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pago() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.clienteId,_that.montoCentimos,_that.metodo,_that.referencia,_that.nota,_that.registradoPor,_that.anuladoEn,_that.anuladoPor,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String pedidoId,  String clienteId,  int montoCentimos,  MetodoPago metodo,  String? referencia,  String? nota,  String? registradoPor,  DateTime? anuladoEn,  String? anuladoPor,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _Pago():
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.clienteId,_that.montoCentimos,_that.metodo,_that.referencia,_that.nota,_that.registradoPor,_that.anuladoEn,_that.anuladoPor,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String pedidoId,  String clienteId,  int montoCentimos,  MetodoPago metodo,  String? referencia,  String? nota,  String? registradoPor,  DateTime? anuladoEn,  String? anuladoPor,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Pago() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.clienteId,_that.montoCentimos,_that.metodo,_that.referencia,_that.nota,_that.registradoPor,_that.anuladoEn,_that.anuladoPor,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pago implements Pago {
  const _Pago({required this.id, required this.distribuidorId, required this.pedidoId, required this.clienteId, required this.montoCentimos, required this.metodo, this.referencia, this.nota, this.registradoPor, this.anuladoEn, this.anuladoPor, required this.creadoEn});
  factory _Pago.fromJson(Map<String, dynamic> json) => _$PagoFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String pedidoId;
@override final  String clienteId;
@override final  int montoCentimos;
@override final  MetodoPago metodo;
@override final  String? referencia;
@override final  String? nota;
@override final  String? registradoPor;
@override final  DateTime? anuladoEn;
@override final  String? anuladoPor;
@override final  DateTime creadoEn;

/// Create a copy of Pago
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PagoCopyWith<_Pago> get copyWith => __$PagoCopyWithImpl<_Pago>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PagoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pago&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.pedidoId, pedidoId) || other.pedidoId == pedidoId)&&(identical(other.clienteId, clienteId) || other.clienteId == clienteId)&&(identical(other.montoCentimos, montoCentimos) || other.montoCentimos == montoCentimos)&&(identical(other.metodo, metodo) || other.metodo == metodo)&&(identical(other.referencia, referencia) || other.referencia == referencia)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.registradoPor, registradoPor) || other.registradoPor == registradoPor)&&(identical(other.anuladoEn, anuladoEn) || other.anuladoEn == anuladoEn)&&(identical(other.anuladoPor, anuladoPor) || other.anuladoPor == anuladoPor)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,pedidoId,clienteId,montoCentimos,metodo,referencia,nota,registradoPor,anuladoEn,anuladoPor,creadoEn);
}

@override
String toString() {
    return 'Pago(id: $id, distribuidorId: $distribuidorId, pedidoId: $pedidoId, clienteId: $clienteId, montoCentimos: $montoCentimos, metodo: $metodo, referencia: $referencia, nota: $nota, registradoPor: $registradoPor, anuladoEn: $anuladoEn, anuladoPor: $anuladoPor, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$PagoCopyWith<$Res> implements $PagoCopyWith<$Res> {
  factory _$PagoCopyWith(_Pago value, $Res Function(_Pago) _then) = __$PagoCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String pedidoId, String clienteId, int montoCentimos, MetodoPago metodo, String? referencia, String? nota, String? registradoPor, DateTime? anuladoEn, String? anuladoPor, DateTime creadoEn
});




}
/// @nodoc
class __$PagoCopyWithImpl<$Res>
    implements _$PagoCopyWith<$Res> {
  __$PagoCopyWithImpl(this._self, this._then);

  final _Pago _self;
  final $Res Function(_Pago) _then;

/// Create a copy of Pago
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? pedidoId = null,Object? clienteId = null,Object? montoCentimos = null,Object? metodo = null,Object? referencia = freezed,Object? nota = freezed,Object? registradoPor = freezed,Object? anuladoEn = freezed,Object? anuladoPor = freezed,Object? creadoEn = null,}) {
  return _then(_Pago(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,pedidoId: null == pedidoId ? _self.pedidoId : pedidoId // ignore: cast_nullable_to_non_nullable
as String,clienteId: null == clienteId ? _self.clienteId : clienteId // ignore: cast_nullable_to_non_nullable
as String,montoCentimos: null == montoCentimos ? _self.montoCentimos : montoCentimos // ignore: cast_nullable_to_non_nullable
as int,metodo: null == metodo ? _self.metodo : metodo // ignore: cast_nullable_to_non_nullable
as MetodoPago,referencia: freezed == referencia ? _self.referencia : referencia // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,registradoPor: freezed == registradoPor ? _self.registradoPor : registradoPor // ignore: cast_nullable_to_non_nullable
as String?,anuladoEn: freezed == anuladoEn ? _self.anuladoEn : anuladoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,anuladoPor: freezed == anuladoPor ? _self.anuladoPor : anuladoPor // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
