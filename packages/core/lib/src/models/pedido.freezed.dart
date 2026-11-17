// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pedido {

 String get id; String get distribuidorId; String get clienteId; EstadoPedido get estado; int get totalCentimos; DateTime get creadoEn; List<PedidoItem> get items;
/// Create a copy of Pedido
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PedidoCopyWith<Pedido> get copyWith => _$PedidoCopyWithImpl<Pedido>(this as Pedido, _$identity);

  /// Serializes this Pedido to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Pedido;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pedido&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.clienteId, _this.clienteId) || other.clienteId == _this.clienteId)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.totalCentimos, _this.totalCentimos) || other.totalCentimos == _this.totalCentimos)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn)&&const DeepCollectionEquality().equals(other.items, _this.items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Pedido;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.clienteId,_this.estado,_this.totalCentimos,_this.creadoEn,const DeepCollectionEquality().hash(_this.items));
}

@override
String toString() {
  final _this = this as Pedido;
  return 'Pedido(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, clienteId: ${_this.clienteId}, estado: ${_this.estado}, totalCentimos: ${_this.totalCentimos}, creadoEn: ${_this.creadoEn}, items: ${_this.items})';
}


}

/// @nodoc
abstract mixin class $PedidoCopyWith<$Res>  {
  factory $PedidoCopyWith(Pedido value, $Res Function(Pedido) _then) = _$PedidoCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String clienteId, EstadoPedido estado, int totalCentimos, DateTime creadoEn, List<PedidoItem> items
});




}
/// @nodoc
class _$PedidoCopyWithImpl<$Res>
    implements $PedidoCopyWith<$Res> {
  _$PedidoCopyWithImpl(this._self, this._then);

  final Pedido _self;
  final $Res Function(Pedido) _then;

/// Create a copy of Pedido
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? clienteId = null,Object? estado = null,Object? totalCentimos = null,Object? creadoEn = null,Object? items = null,}) {
  return _then(Pedido(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,clienteId: null == clienteId ? _self.clienteId : clienteId // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,totalCentimos: null == totalCentimos ? _self.totalCentimos : totalCentimos // ignore: cast_nullable_to_non_nullable
as int,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PedidoItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [Pedido].
extension PedidoPatterns on Pedido {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Pedido value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Pedido() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Pedido value)  $default,){
final _that = this;
switch (_that) {
case _Pedido():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Pedido value)?  $default,){
final _that = this;
switch (_that) {
case _Pedido() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String clienteId,  EstadoPedido estado,  int totalCentimos,  DateTime creadoEn,  List<PedidoItem> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pedido() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.clienteId,_that.estado,_that.totalCentimos,_that.creadoEn,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String clienteId,  EstadoPedido estado,  int totalCentimos,  DateTime creadoEn,  List<PedidoItem> items)  $default,) {final _that = this;
switch (_that) {
case _Pedido():
return $default(_that.id,_that.distribuidorId,_that.clienteId,_that.estado,_that.totalCentimos,_that.creadoEn,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String clienteId,  EstadoPedido estado,  int totalCentimos,  DateTime creadoEn,  List<PedidoItem> items)?  $default,) {final _that = this;
switch (_that) {
case _Pedido() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.clienteId,_that.estado,_that.totalCentimos,_that.creadoEn,_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pedido implements Pedido {
  const _Pedido({required this.id, required this.distribuidorId, required this.clienteId, required this.estado, required this.totalCentimos, required this.creadoEn,  List<PedidoItem> items = const <PedidoItem>[]}): _items = items;
  factory _Pedido.fromJson(Map<String, dynamic> json) => _$PedidoFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String clienteId;
@override final  EstadoPedido estado;
@override final  int totalCentimos;
@override final  DateTime creadoEn;
 final  List<PedidoItem> _items;
@override@JsonKey() List<PedidoItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of Pedido
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PedidoCopyWith<_Pedido> get copyWith => __$PedidoCopyWithImpl<_Pedido>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PedidoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pedido&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.clienteId, clienteId) || other.clienteId == clienteId)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.totalCentimos, totalCentimos) || other.totalCentimos == totalCentimos)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn)&&const DeepCollectionEquality().equals(other.items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,clienteId,estado,totalCentimos,creadoEn,const DeepCollectionEquality().hash(_items));
}

@override
String toString() {
    return 'Pedido(id: $id, distribuidorId: $distribuidorId, clienteId: $clienteId, estado: $estado, totalCentimos: $totalCentimos, creadoEn: $creadoEn, items: $items)';
}


}

/// @nodoc
abstract mixin class _$PedidoCopyWith<$Res> implements $PedidoCopyWith<$Res> {
  factory _$PedidoCopyWith(_Pedido value, $Res Function(_Pedido) _then) = __$PedidoCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String clienteId, EstadoPedido estado, int totalCentimos, DateTime creadoEn, List<PedidoItem> items
});




}
/// @nodoc
class __$PedidoCopyWithImpl<$Res>
    implements _$PedidoCopyWith<$Res> {
  __$PedidoCopyWithImpl(this._self, this._then);

  final _Pedido _self;
  final $Res Function(_Pedido) _then;

/// Create a copy of Pedido
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? clienteId = null,Object? estado = null,Object? totalCentimos = null,Object? creadoEn = null,Object? items = null,}) {
  return _then(_Pedido(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,clienteId: null == clienteId ? _self.clienteId : clienteId // ignore: cast_nullable_to_non_nullable
as String,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,totalCentimos: null == totalCentimos ? _self.totalCentimos : totalCentimos // ignore: cast_nullable_to_non_nullable
as int,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PedidoItem>,
  ));
}


}

// dart format on
