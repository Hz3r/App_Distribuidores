// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movimiento_stock.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MovimientoStock {

 String get id; String get distribuidorId; String get productoId; TipoMovimientoStock get tipo; int get deltaFisico; int get deltaComprometido; String? get pedidoId; String? get hechoPor; String? get nota; DateTime get creadoEn;
/// Create a copy of MovimientoStock
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovimientoStockCopyWith<MovimientoStock> get copyWith => _$MovimientoStockCopyWithImpl<MovimientoStock>(this as MovimientoStock, _$identity);

  /// Serializes this MovimientoStock to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MovimientoStock;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovimientoStock&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.productoId, _this.productoId) || other.productoId == _this.productoId)&&(identical(other.tipo, _this.tipo) || other.tipo == _this.tipo)&&(identical(other.deltaFisico, _this.deltaFisico) || other.deltaFisico == _this.deltaFisico)&&(identical(other.deltaComprometido, _this.deltaComprometido) || other.deltaComprometido == _this.deltaComprometido)&&(identical(other.pedidoId, _this.pedidoId) || other.pedidoId == _this.pedidoId)&&(identical(other.hechoPor, _this.hechoPor) || other.hechoPor == _this.hechoPor)&&(identical(other.nota, _this.nota) || other.nota == _this.nota)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MovimientoStock;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.productoId,_this.tipo,_this.deltaFisico,_this.deltaComprometido,_this.pedidoId,_this.hechoPor,_this.nota,_this.creadoEn);
}

@override
String toString() {
  final _this = this as MovimientoStock;
  return 'MovimientoStock(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, productoId: ${_this.productoId}, tipo: ${_this.tipo}, deltaFisico: ${_this.deltaFisico}, deltaComprometido: ${_this.deltaComprometido}, pedidoId: ${_this.pedidoId}, hechoPor: ${_this.hechoPor}, nota: ${_this.nota}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $MovimientoStockCopyWith<$Res>  {
  factory $MovimientoStockCopyWith(MovimientoStock value, $Res Function(MovimientoStock) _then) = _$MovimientoStockCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String productoId, TipoMovimientoStock tipo, int deltaFisico, int deltaComprometido, String? pedidoId, String? hechoPor, String? nota, DateTime creadoEn
});




}
/// @nodoc
class _$MovimientoStockCopyWithImpl<$Res>
    implements $MovimientoStockCopyWith<$Res> {
  _$MovimientoStockCopyWithImpl(this._self, this._then);

  final MovimientoStock _self;
  final $Res Function(MovimientoStock) _then;

/// Create a copy of MovimientoStock
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? productoId = null,Object? tipo = null,Object? deltaFisico = null,Object? deltaComprometido = null,Object? pedidoId = freezed,Object? hechoPor = freezed,Object? nota = freezed,Object? creadoEn = null,}) {
  return _then(MovimientoStock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoMovimientoStock,deltaFisico: null == deltaFisico ? _self.deltaFisico : deltaFisico // ignore: cast_nullable_to_non_nullable
as int,deltaComprometido: null == deltaComprometido ? _self.deltaComprometido : deltaComprometido // ignore: cast_nullable_to_non_nullable
as int,pedidoId: freezed == pedidoId ? _self.pedidoId : pedidoId // ignore: cast_nullable_to_non_nullable
as String?,hechoPor: freezed == hechoPor ? _self.hechoPor : hechoPor // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MovimientoStock].
extension MovimientoStockPatterns on MovimientoStock {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovimientoStock value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovimientoStock() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovimientoStock value)  $default,){
final _that = this;
switch (_that) {
case _MovimientoStock():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovimientoStock value)?  $default,){
final _that = this;
switch (_that) {
case _MovimientoStock() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String productoId,  TipoMovimientoStock tipo,  int deltaFisico,  int deltaComprometido,  String? pedidoId,  String? hechoPor,  String? nota,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovimientoStock() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.productoId,_that.tipo,_that.deltaFisico,_that.deltaComprometido,_that.pedidoId,_that.hechoPor,_that.nota,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String productoId,  TipoMovimientoStock tipo,  int deltaFisico,  int deltaComprometido,  String? pedidoId,  String? hechoPor,  String? nota,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _MovimientoStock():
return $default(_that.id,_that.distribuidorId,_that.productoId,_that.tipo,_that.deltaFisico,_that.deltaComprometido,_that.pedidoId,_that.hechoPor,_that.nota,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String productoId,  TipoMovimientoStock tipo,  int deltaFisico,  int deltaComprometido,  String? pedidoId,  String? hechoPor,  String? nota,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _MovimientoStock() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.productoId,_that.tipo,_that.deltaFisico,_that.deltaComprometido,_that.pedidoId,_that.hechoPor,_that.nota,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MovimientoStock implements MovimientoStock {
  const _MovimientoStock({required this.id, required this.distribuidorId, required this.productoId, required this.tipo, required this.deltaFisico, required this.deltaComprometido, this.pedidoId, this.hechoPor, this.nota, required this.creadoEn});
  factory _MovimientoStock.fromJson(Map<String, dynamic> json) => _$MovimientoStockFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String productoId;
@override final  TipoMovimientoStock tipo;
@override final  int deltaFisico;
@override final  int deltaComprometido;
@override final  String? pedidoId;
@override final  String? hechoPor;
@override final  String? nota;
@override final  DateTime creadoEn;

/// Create a copy of MovimientoStock
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovimientoStockCopyWith<_MovimientoStock> get copyWith => __$MovimientoStockCopyWithImpl<_MovimientoStock>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MovimientoStockToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovimientoStock&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.deltaFisico, deltaFisico) || other.deltaFisico == deltaFisico)&&(identical(other.deltaComprometido, deltaComprometido) || other.deltaComprometido == deltaComprometido)&&(identical(other.pedidoId, pedidoId) || other.pedidoId == pedidoId)&&(identical(other.hechoPor, hechoPor) || other.hechoPor == hechoPor)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,productoId,tipo,deltaFisico,deltaComprometido,pedidoId,hechoPor,nota,creadoEn);
}

@override
String toString() {
    return 'MovimientoStock(id: $id, distribuidorId: $distribuidorId, productoId: $productoId, tipo: $tipo, deltaFisico: $deltaFisico, deltaComprometido: $deltaComprometido, pedidoId: $pedidoId, hechoPor: $hechoPor, nota: $nota, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$MovimientoStockCopyWith<$Res> implements $MovimientoStockCopyWith<$Res> {
  factory _$MovimientoStockCopyWith(_MovimientoStock value, $Res Function(_MovimientoStock) _then) = __$MovimientoStockCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String productoId, TipoMovimientoStock tipo, int deltaFisico, int deltaComprometido, String? pedidoId, String? hechoPor, String? nota, DateTime creadoEn
});




}
/// @nodoc
class __$MovimientoStockCopyWithImpl<$Res>
    implements _$MovimientoStockCopyWith<$Res> {
  __$MovimientoStockCopyWithImpl(this._self, this._then);

  final _MovimientoStock _self;
  final $Res Function(_MovimientoStock) _then;

/// Create a copy of MovimientoStock
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? productoId = null,Object? tipo = null,Object? deltaFisico = null,Object? deltaComprometido = null,Object? pedidoId = freezed,Object? hechoPor = freezed,Object? nota = freezed,Object? creadoEn = null,}) {
  return _then(_MovimientoStock(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,tipo: null == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as TipoMovimientoStock,deltaFisico: null == deltaFisico ? _self.deltaFisico : deltaFisico // ignore: cast_nullable_to_non_nullable
as int,deltaComprometido: null == deltaComprometido ? _self.deltaComprometido : deltaComprometido // ignore: cast_nullable_to_non_nullable
as int,pedidoId: freezed == pedidoId ? _self.pedidoId : pedidoId // ignore: cast_nullable_to_non_nullable
as String?,hechoPor: freezed == hechoPor ? _self.hechoPor : hechoPor // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
