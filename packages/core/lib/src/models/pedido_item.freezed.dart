// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PedidoItem {

 String get id; String get distribuidorId; String get pedidoId; String get presentacionId; String get productoId; String get nombreProducto; String get nombrePresentacion; int get factor; int get cantidad; int get precioUnitarioCentimos; int get subtotalCentimos; DateTime get creadoEn;
/// Create a copy of PedidoItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PedidoItemCopyWith<PedidoItem> get copyWith => _$PedidoItemCopyWithImpl<PedidoItem>(this as PedidoItem, _$identity);

  /// Serializes this PedidoItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PedidoItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PedidoItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.pedidoId, _this.pedidoId) || other.pedidoId == _this.pedidoId)&&(identical(other.presentacionId, _this.presentacionId) || other.presentacionId == _this.presentacionId)&&(identical(other.productoId, _this.productoId) || other.productoId == _this.productoId)&&(identical(other.nombreProducto, _this.nombreProducto) || other.nombreProducto == _this.nombreProducto)&&(identical(other.nombrePresentacion, _this.nombrePresentacion) || other.nombrePresentacion == _this.nombrePresentacion)&&(identical(other.factor, _this.factor) || other.factor == _this.factor)&&(identical(other.cantidad, _this.cantidad) || other.cantidad == _this.cantidad)&&(identical(other.precioUnitarioCentimos, _this.precioUnitarioCentimos) || other.precioUnitarioCentimos == _this.precioUnitarioCentimos)&&(identical(other.subtotalCentimos, _this.subtotalCentimos) || other.subtotalCentimos == _this.subtotalCentimos)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PedidoItem;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.pedidoId,_this.presentacionId,_this.productoId,_this.nombreProducto,_this.nombrePresentacion,_this.factor,_this.cantidad,_this.precioUnitarioCentimos,_this.subtotalCentimos,_this.creadoEn);
}

@override
String toString() {
  final _this = this as PedidoItem;
  return 'PedidoItem(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, pedidoId: ${_this.pedidoId}, presentacionId: ${_this.presentacionId}, productoId: ${_this.productoId}, nombreProducto: ${_this.nombreProducto}, nombrePresentacion: ${_this.nombrePresentacion}, factor: ${_this.factor}, cantidad: ${_this.cantidad}, precioUnitarioCentimos: ${_this.precioUnitarioCentimos}, subtotalCentimos: ${_this.subtotalCentimos}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $PedidoItemCopyWith<$Res>  {
  factory $PedidoItemCopyWith(PedidoItem value, $Res Function(PedidoItem) _then) = _$PedidoItemCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String pedidoId, String presentacionId, String productoId, String nombreProducto, String nombrePresentacion, int factor, int cantidad, int precioUnitarioCentimos, int subtotalCentimos, DateTime creadoEn
});




}
/// @nodoc
class _$PedidoItemCopyWithImpl<$Res>
    implements $PedidoItemCopyWith<$Res> {
  _$PedidoItemCopyWithImpl(this._self, this._then);

  final PedidoItem _self;
  final $Res Function(PedidoItem) _then;

/// Create a copy of PedidoItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? pedidoId = null,Object? presentacionId = null,Object? productoId = null,Object? nombreProducto = null,Object? nombrePresentacion = null,Object? factor = null,Object? cantidad = null,Object? precioUnitarioCentimos = null,Object? subtotalCentimos = null,Object? creadoEn = null,}) {
  return _then(PedidoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,pedidoId: null == pedidoId ? _self.pedidoId : pedidoId // ignore: cast_nullable_to_non_nullable
as String,presentacionId: null == presentacionId ? _self.presentacionId : presentacionId // ignore: cast_nullable_to_non_nullable
as String,productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,nombreProducto: null == nombreProducto ? _self.nombreProducto : nombreProducto // ignore: cast_nullable_to_non_nullable
as String,nombrePresentacion: null == nombrePresentacion ? _self.nombrePresentacion : nombrePresentacion // ignore: cast_nullable_to_non_nullable
as String,factor: null == factor ? _self.factor : factor // ignore: cast_nullable_to_non_nullable
as int,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,precioUnitarioCentimos: null == precioUnitarioCentimos ? _self.precioUnitarioCentimos : precioUnitarioCentimos // ignore: cast_nullable_to_non_nullable
as int,subtotalCentimos: null == subtotalCentimos ? _self.subtotalCentimos : subtotalCentimos // ignore: cast_nullable_to_non_nullable
as int,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PedidoItem].
extension PedidoItemPatterns on PedidoItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PedidoItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PedidoItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PedidoItem value)  $default,){
final _that = this;
switch (_that) {
case _PedidoItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PedidoItem value)?  $default,){
final _that = this;
switch (_that) {
case _PedidoItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String pedidoId,  String presentacionId,  String productoId,  String nombreProducto,  String nombrePresentacion,  int factor,  int cantidad,  int precioUnitarioCentimos,  int subtotalCentimos,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PedidoItem() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.presentacionId,_that.productoId,_that.nombreProducto,_that.nombrePresentacion,_that.factor,_that.cantidad,_that.precioUnitarioCentimos,_that.subtotalCentimos,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String pedidoId,  String presentacionId,  String productoId,  String nombreProducto,  String nombrePresentacion,  int factor,  int cantidad,  int precioUnitarioCentimos,  int subtotalCentimos,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _PedidoItem():
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.presentacionId,_that.productoId,_that.nombreProducto,_that.nombrePresentacion,_that.factor,_that.cantidad,_that.precioUnitarioCentimos,_that.subtotalCentimos,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String pedidoId,  String presentacionId,  String productoId,  String nombreProducto,  String nombrePresentacion,  int factor,  int cantidad,  int precioUnitarioCentimos,  int subtotalCentimos,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _PedidoItem() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.presentacionId,_that.productoId,_that.nombreProducto,_that.nombrePresentacion,_that.factor,_that.cantidad,_that.precioUnitarioCentimos,_that.subtotalCentimos,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PedidoItem implements PedidoItem {
  const _PedidoItem({required this.id, required this.distribuidorId, required this.pedidoId, required this.presentacionId, required this.productoId, required this.nombreProducto, required this.nombrePresentacion, required this.factor, required this.cantidad, required this.precioUnitarioCentimos, required this.subtotalCentimos, required this.creadoEn});
  factory _PedidoItem.fromJson(Map<String, dynamic> json) => _$PedidoItemFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String pedidoId;
@override final  String presentacionId;
@override final  String productoId;
@override final  String nombreProducto;
@override final  String nombrePresentacion;
@override final  int factor;
@override final  int cantidad;
@override final  int precioUnitarioCentimos;
@override final  int subtotalCentimos;
@override final  DateTime creadoEn;

/// Create a copy of PedidoItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PedidoItemCopyWith<_PedidoItem> get copyWith => __$PedidoItemCopyWithImpl<_PedidoItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PedidoItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PedidoItem&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.pedidoId, pedidoId) || other.pedidoId == pedidoId)&&(identical(other.presentacionId, presentacionId) || other.presentacionId == presentacionId)&&(identical(other.productoId, productoId) || other.productoId == productoId)&&(identical(other.nombreProducto, nombreProducto) || other.nombreProducto == nombreProducto)&&(identical(other.nombrePresentacion, nombrePresentacion) || other.nombrePresentacion == nombrePresentacion)&&(identical(other.factor, factor) || other.factor == factor)&&(identical(other.cantidad, cantidad) || other.cantidad == cantidad)&&(identical(other.precioUnitarioCentimos, precioUnitarioCentimos) || other.precioUnitarioCentimos == precioUnitarioCentimos)&&(identical(other.subtotalCentimos, subtotalCentimos) || other.subtotalCentimos == subtotalCentimos)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,pedidoId,presentacionId,productoId,nombreProducto,nombrePresentacion,factor,cantidad,precioUnitarioCentimos,subtotalCentimos,creadoEn);
}

@override
String toString() {
    return 'PedidoItem(id: $id, distribuidorId: $distribuidorId, pedidoId: $pedidoId, presentacionId: $presentacionId, productoId: $productoId, nombreProducto: $nombreProducto, nombrePresentacion: $nombrePresentacion, factor: $factor, cantidad: $cantidad, precioUnitarioCentimos: $precioUnitarioCentimos, subtotalCentimos: $subtotalCentimos, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$PedidoItemCopyWith<$Res> implements $PedidoItemCopyWith<$Res> {
  factory _$PedidoItemCopyWith(_PedidoItem value, $Res Function(_PedidoItem) _then) = __$PedidoItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String pedidoId, String presentacionId, String productoId, String nombreProducto, String nombrePresentacion, int factor, int cantidad, int precioUnitarioCentimos, int subtotalCentimos, DateTime creadoEn
});




}
/// @nodoc
class __$PedidoItemCopyWithImpl<$Res>
    implements _$PedidoItemCopyWith<$Res> {
  __$PedidoItemCopyWithImpl(this._self, this._then);

  final _PedidoItem _self;
  final $Res Function(_PedidoItem) _then;

/// Create a copy of PedidoItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? pedidoId = null,Object? presentacionId = null,Object? productoId = null,Object? nombreProducto = null,Object? nombrePresentacion = null,Object? factor = null,Object? cantidad = null,Object? precioUnitarioCentimos = null,Object? subtotalCentimos = null,Object? creadoEn = null,}) {
  return _then(_PedidoItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,pedidoId: null == pedidoId ? _self.pedidoId : pedidoId // ignore: cast_nullable_to_non_nullable
as String,presentacionId: null == presentacionId ? _self.presentacionId : presentacionId // ignore: cast_nullable_to_non_nullable
as String,productoId: null == productoId ? _self.productoId : productoId // ignore: cast_nullable_to_non_nullable
as String,nombreProducto: null == nombreProducto ? _self.nombreProducto : nombreProducto // ignore: cast_nullable_to_non_nullable
as String,nombrePresentacion: null == nombrePresentacion ? _self.nombrePresentacion : nombrePresentacion // ignore: cast_nullable_to_non_nullable
as String,factor: null == factor ? _self.factor : factor // ignore: cast_nullable_to_non_nullable
as int,cantidad: null == cantidad ? _self.cantidad : cantidad // ignore: cast_nullable_to_non_nullable
as int,precioUnitarioCentimos: null == precioUnitarioCentimos ? _self.precioUnitarioCentimos : precioUnitarioCentimos // ignore: cast_nullable_to_non_nullable
as int,subtotalCentimos: null == subtotalCentimos ? _self.subtotalCentimos : subtotalCentimos // ignore: cast_nullable_to_non_nullable
as int,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
