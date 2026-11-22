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

 String get id; String get distribuidorId; int get numero; String get clienteId; String? get creadoPor; String? get repartidorId; EstadoPedido get estado; DespachoPedido get despacho; String? get direccionEntrega; String? get notaCliente; int get totalCentimos; CondicionPago get condicionPago; MetodoPago? get metodoPago; EstadoPago get estadoPago; int get saldoPendienteCentimos; int? get plazoCreditoDias; DateTime? get venceEn; String? get motivoCancelacion; String get claveIdempotencia; DateTime? get entregadoEn; DateTime get creadoEn; List<PedidoItem> get items; List<PedidoEvento> get eventos;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Pedido&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.numero, _this.numero) || other.numero == _this.numero)&&(identical(other.clienteId, _this.clienteId) || other.clienteId == _this.clienteId)&&(identical(other.creadoPor, _this.creadoPor) || other.creadoPor == _this.creadoPor)&&(identical(other.repartidorId, _this.repartidorId) || other.repartidorId == _this.repartidorId)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.despacho, _this.despacho) || other.despacho == _this.despacho)&&(identical(other.direccionEntrega, _this.direccionEntrega) || other.direccionEntrega == _this.direccionEntrega)&&(identical(other.notaCliente, _this.notaCliente) || other.notaCliente == _this.notaCliente)&&(identical(other.totalCentimos, _this.totalCentimos) || other.totalCentimos == _this.totalCentimos)&&(identical(other.condicionPago, _this.condicionPago) || other.condicionPago == _this.condicionPago)&&(identical(other.metodoPago, _this.metodoPago) || other.metodoPago == _this.metodoPago)&&(identical(other.estadoPago, _this.estadoPago) || other.estadoPago == _this.estadoPago)&&(identical(other.saldoPendienteCentimos, _this.saldoPendienteCentimos) || other.saldoPendienteCentimos == _this.saldoPendienteCentimos)&&(identical(other.plazoCreditoDias, _this.plazoCreditoDias) || other.plazoCreditoDias == _this.plazoCreditoDias)&&(identical(other.venceEn, _this.venceEn) || other.venceEn == _this.venceEn)&&(identical(other.motivoCancelacion, _this.motivoCancelacion) || other.motivoCancelacion == _this.motivoCancelacion)&&(identical(other.claveIdempotencia, _this.claveIdempotencia) || other.claveIdempotencia == _this.claveIdempotencia)&&(identical(other.entregadoEn, _this.entregadoEn) || other.entregadoEn == _this.entregadoEn)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn)&&const DeepCollectionEquality().equals(other.items, _this.items)&&const DeepCollectionEquality().equals(other.eventos, _this.eventos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Pedido;
  return Object.hashAll([runtimeType,_this.id,_this.distribuidorId,_this.numero,_this.clienteId,_this.creadoPor,_this.repartidorId,_this.estado,_this.despacho,_this.direccionEntrega,_this.notaCliente,_this.totalCentimos,_this.condicionPago,_this.metodoPago,_this.estadoPago,_this.saldoPendienteCentimos,_this.plazoCreditoDias,_this.venceEn,_this.motivoCancelacion,_this.claveIdempotencia,_this.entregadoEn,_this.creadoEn,const DeepCollectionEquality().hash(_this.items),const DeepCollectionEquality().hash(_this.eventos)]);
}

@override
String toString() {
  final _this = this as Pedido;
  return 'Pedido(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, numero: ${_this.numero}, clienteId: ${_this.clienteId}, creadoPor: ${_this.creadoPor}, repartidorId: ${_this.repartidorId}, estado: ${_this.estado}, despacho: ${_this.despacho}, direccionEntrega: ${_this.direccionEntrega}, notaCliente: ${_this.notaCliente}, totalCentimos: ${_this.totalCentimos}, condicionPago: ${_this.condicionPago}, metodoPago: ${_this.metodoPago}, estadoPago: ${_this.estadoPago}, saldoPendienteCentimos: ${_this.saldoPendienteCentimos}, plazoCreditoDias: ${_this.plazoCreditoDias}, venceEn: ${_this.venceEn}, motivoCancelacion: ${_this.motivoCancelacion}, claveIdempotencia: ${_this.claveIdempotencia}, entregadoEn: ${_this.entregadoEn}, creadoEn: ${_this.creadoEn}, items: ${_this.items}, eventos: ${_this.eventos})';
}


}

/// @nodoc
abstract mixin class $PedidoCopyWith<$Res>  {
  factory $PedidoCopyWith(Pedido value, $Res Function(Pedido) _then) = _$PedidoCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, int numero, String clienteId, String? creadoPor, String? repartidorId, EstadoPedido estado, DespachoPedido despacho, String? direccionEntrega, String? notaCliente, int totalCentimos, CondicionPago condicionPago, MetodoPago? metodoPago, EstadoPago estadoPago, int saldoPendienteCentimos, int? plazoCreditoDias, DateTime? venceEn, String? motivoCancelacion, String claveIdempotencia, DateTime? entregadoEn, DateTime creadoEn, List<PedidoItem> items, List<PedidoEvento> eventos
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? numero = null,Object? clienteId = null,Object? creadoPor = freezed,Object? repartidorId = freezed,Object? estado = null,Object? despacho = null,Object? direccionEntrega = freezed,Object? notaCliente = freezed,Object? totalCentimos = null,Object? condicionPago = null,Object? metodoPago = freezed,Object? estadoPago = null,Object? saldoPendienteCentimos = null,Object? plazoCreditoDias = freezed,Object? venceEn = freezed,Object? motivoCancelacion = freezed,Object? claveIdempotencia = null,Object? entregadoEn = freezed,Object? creadoEn = null,Object? items = null,Object? eventos = null,}) {
  return _then(Pedido(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,numero: null == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as int,clienteId: null == clienteId ? _self.clienteId : clienteId // ignore: cast_nullable_to_non_nullable
as String,creadoPor: freezed == creadoPor ? _self.creadoPor : creadoPor // ignore: cast_nullable_to_non_nullable
as String?,repartidorId: freezed == repartidorId ? _self.repartidorId : repartidorId // ignore: cast_nullable_to_non_nullable
as String?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,despacho: null == despacho ? _self.despacho : despacho // ignore: cast_nullable_to_non_nullable
as DespachoPedido,direccionEntrega: freezed == direccionEntrega ? _self.direccionEntrega : direccionEntrega // ignore: cast_nullable_to_non_nullable
as String?,notaCliente: freezed == notaCliente ? _self.notaCliente : notaCliente // ignore: cast_nullable_to_non_nullable
as String?,totalCentimos: null == totalCentimos ? _self.totalCentimos : totalCentimos // ignore: cast_nullable_to_non_nullable
as int,condicionPago: null == condicionPago ? _self.condicionPago : condicionPago // ignore: cast_nullable_to_non_nullable
as CondicionPago,metodoPago: freezed == metodoPago ? _self.metodoPago : metodoPago // ignore: cast_nullable_to_non_nullable
as MetodoPago?,estadoPago: null == estadoPago ? _self.estadoPago : estadoPago // ignore: cast_nullable_to_non_nullable
as EstadoPago,saldoPendienteCentimos: null == saldoPendienteCentimos ? _self.saldoPendienteCentimos : saldoPendienteCentimos // ignore: cast_nullable_to_non_nullable
as int,plazoCreditoDias: freezed == plazoCreditoDias ? _self.plazoCreditoDias : plazoCreditoDias // ignore: cast_nullable_to_non_nullable
as int?,venceEn: freezed == venceEn ? _self.venceEn : venceEn // ignore: cast_nullable_to_non_nullable
as DateTime?,motivoCancelacion: freezed == motivoCancelacion ? _self.motivoCancelacion : motivoCancelacion // ignore: cast_nullable_to_non_nullable
as String?,claveIdempotencia: null == claveIdempotencia ? _self.claveIdempotencia : claveIdempotencia // ignore: cast_nullable_to_non_nullable
as String,entregadoEn: freezed == entregadoEn ? _self.entregadoEn : entregadoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<PedidoItem>,eventos: null == eventos ? _self.eventos : eventos // ignore: cast_nullable_to_non_nullable
as List<PedidoEvento>,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  int numero,  String clienteId,  String? creadoPor,  String? repartidorId,  EstadoPedido estado,  DespachoPedido despacho,  String? direccionEntrega,  String? notaCliente,  int totalCentimos,  CondicionPago condicionPago,  MetodoPago? metodoPago,  EstadoPago estadoPago,  int saldoPendienteCentimos,  int? plazoCreditoDias,  DateTime? venceEn,  String? motivoCancelacion,  String claveIdempotencia,  DateTime? entregadoEn,  DateTime creadoEn,  List<PedidoItem> items,  List<PedidoEvento> eventos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Pedido() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.numero,_that.clienteId,_that.creadoPor,_that.repartidorId,_that.estado,_that.despacho,_that.direccionEntrega,_that.notaCliente,_that.totalCentimos,_that.condicionPago,_that.metodoPago,_that.estadoPago,_that.saldoPendienteCentimos,_that.plazoCreditoDias,_that.venceEn,_that.motivoCancelacion,_that.claveIdempotencia,_that.entregadoEn,_that.creadoEn,_that.items,_that.eventos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  int numero,  String clienteId,  String? creadoPor,  String? repartidorId,  EstadoPedido estado,  DespachoPedido despacho,  String? direccionEntrega,  String? notaCliente,  int totalCentimos,  CondicionPago condicionPago,  MetodoPago? metodoPago,  EstadoPago estadoPago,  int saldoPendienteCentimos,  int? plazoCreditoDias,  DateTime? venceEn,  String? motivoCancelacion,  String claveIdempotencia,  DateTime? entregadoEn,  DateTime creadoEn,  List<PedidoItem> items,  List<PedidoEvento> eventos)  $default,) {final _that = this;
switch (_that) {
case _Pedido():
return $default(_that.id,_that.distribuidorId,_that.numero,_that.clienteId,_that.creadoPor,_that.repartidorId,_that.estado,_that.despacho,_that.direccionEntrega,_that.notaCliente,_that.totalCentimos,_that.condicionPago,_that.metodoPago,_that.estadoPago,_that.saldoPendienteCentimos,_that.plazoCreditoDias,_that.venceEn,_that.motivoCancelacion,_that.claveIdempotencia,_that.entregadoEn,_that.creadoEn,_that.items,_that.eventos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  int numero,  String clienteId,  String? creadoPor,  String? repartidorId,  EstadoPedido estado,  DespachoPedido despacho,  String? direccionEntrega,  String? notaCliente,  int totalCentimos,  CondicionPago condicionPago,  MetodoPago? metodoPago,  EstadoPago estadoPago,  int saldoPendienteCentimos,  int? plazoCreditoDias,  DateTime? venceEn,  String? motivoCancelacion,  String claveIdempotencia,  DateTime? entregadoEn,  DateTime creadoEn,  List<PedidoItem> items,  List<PedidoEvento> eventos)?  $default,) {final _that = this;
switch (_that) {
case _Pedido() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.numero,_that.clienteId,_that.creadoPor,_that.repartidorId,_that.estado,_that.despacho,_that.direccionEntrega,_that.notaCliente,_that.totalCentimos,_that.condicionPago,_that.metodoPago,_that.estadoPago,_that.saldoPendienteCentimos,_that.plazoCreditoDias,_that.venceEn,_that.motivoCancelacion,_that.claveIdempotencia,_that.entregadoEn,_that.creadoEn,_that.items,_that.eventos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Pedido implements Pedido {
  const _Pedido({required this.id, required this.distribuidorId, required this.numero, required this.clienteId, this.creadoPor, this.repartidorId, required this.estado, required this.despacho, this.direccionEntrega, this.notaCliente, required this.totalCentimos, required this.condicionPago, this.metodoPago, required this.estadoPago, required this.saldoPendienteCentimos, this.plazoCreditoDias, this.venceEn, this.motivoCancelacion, required this.claveIdempotencia, this.entregadoEn, required this.creadoEn,  List<PedidoItem> items = const <PedidoItem>[],  List<PedidoEvento> eventos = const <PedidoEvento>[]}): _items = items,_eventos = eventos;
  factory _Pedido.fromJson(Map<String, dynamic> json) => _$PedidoFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  int numero;
@override final  String clienteId;
@override final  String? creadoPor;
@override final  String? repartidorId;
@override final  EstadoPedido estado;
@override final  DespachoPedido despacho;
@override final  String? direccionEntrega;
@override final  String? notaCliente;
@override final  int totalCentimos;
@override final  CondicionPago condicionPago;
@override final  MetodoPago? metodoPago;
@override final  EstadoPago estadoPago;
@override final  int saldoPendienteCentimos;
@override final  int? plazoCreditoDias;
@override final  DateTime? venceEn;
@override final  String? motivoCancelacion;
@override final  String claveIdempotencia;
@override final  DateTime? entregadoEn;
@override final  DateTime creadoEn;
 final  List<PedidoItem> _items;
@override@JsonKey() List<PedidoItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

 final  List<PedidoEvento> _eventos;
@override@JsonKey() List<PedidoEvento> get eventos {
  if (_eventos is EqualUnmodifiableListView) return _eventos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_eventos);
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pedido&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.clienteId, clienteId) || other.clienteId == clienteId)&&(identical(other.creadoPor, creadoPor) || other.creadoPor == creadoPor)&&(identical(other.repartidorId, repartidorId) || other.repartidorId == repartidorId)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.despacho, despacho) || other.despacho == despacho)&&(identical(other.direccionEntrega, direccionEntrega) || other.direccionEntrega == direccionEntrega)&&(identical(other.notaCliente, notaCliente) || other.notaCliente == notaCliente)&&(identical(other.totalCentimos, totalCentimos) || other.totalCentimos == totalCentimos)&&(identical(other.condicionPago, condicionPago) || other.condicionPago == condicionPago)&&(identical(other.metodoPago, metodoPago) || other.metodoPago == metodoPago)&&(identical(other.estadoPago, estadoPago) || other.estadoPago == estadoPago)&&(identical(other.saldoPendienteCentimos, saldoPendienteCentimos) || other.saldoPendienteCentimos == saldoPendienteCentimos)&&(identical(other.plazoCreditoDias, plazoCreditoDias) || other.plazoCreditoDias == plazoCreditoDias)&&(identical(other.venceEn, venceEn) || other.venceEn == venceEn)&&(identical(other.motivoCancelacion, motivoCancelacion) || other.motivoCancelacion == motivoCancelacion)&&(identical(other.claveIdempotencia, claveIdempotencia) || other.claveIdempotencia == claveIdempotencia)&&(identical(other.entregadoEn, entregadoEn) || other.entregadoEn == entregadoEn)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn)&&const DeepCollectionEquality().equals(other.items, _items)&&const DeepCollectionEquality().equals(other.eventos, _eventos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,distribuidorId,numero,clienteId,creadoPor,repartidorId,estado,despacho,direccionEntrega,notaCliente,totalCentimos,condicionPago,metodoPago,estadoPago,saldoPendienteCentimos,plazoCreditoDias,venceEn,motivoCancelacion,claveIdempotencia,entregadoEn,creadoEn,const DeepCollectionEquality().hash(_items),const DeepCollectionEquality().hash(_eventos)]);
}

@override
String toString() {
    return 'Pedido(id: $id, distribuidorId: $distribuidorId, numero: $numero, clienteId: $clienteId, creadoPor: $creadoPor, repartidorId: $repartidorId, estado: $estado, despacho: $despacho, direccionEntrega: $direccionEntrega, notaCliente: $notaCliente, totalCentimos: $totalCentimos, condicionPago: $condicionPago, metodoPago: $metodoPago, estadoPago: $estadoPago, saldoPendienteCentimos: $saldoPendienteCentimos, plazoCreditoDias: $plazoCreditoDias, venceEn: $venceEn, motivoCancelacion: $motivoCancelacion, claveIdempotencia: $claveIdempotencia, entregadoEn: $entregadoEn, creadoEn: $creadoEn, items: $items, eventos: $eventos)';
}


}

/// @nodoc
abstract mixin class _$PedidoCopyWith<$Res> implements $PedidoCopyWith<$Res> {
  factory _$PedidoCopyWith(_Pedido value, $Res Function(_Pedido) _then) = __$PedidoCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, int numero, String clienteId, String? creadoPor, String? repartidorId, EstadoPedido estado, DespachoPedido despacho, String? direccionEntrega, String? notaCliente, int totalCentimos, CondicionPago condicionPago, MetodoPago? metodoPago, EstadoPago estadoPago, int saldoPendienteCentimos, int? plazoCreditoDias, DateTime? venceEn, String? motivoCancelacion, String claveIdempotencia, DateTime? entregadoEn, DateTime creadoEn, List<PedidoItem> items, List<PedidoEvento> eventos
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? numero = null,Object? clienteId = null,Object? creadoPor = freezed,Object? repartidorId = freezed,Object? estado = null,Object? despacho = null,Object? direccionEntrega = freezed,Object? notaCliente = freezed,Object? totalCentimos = null,Object? condicionPago = null,Object? metodoPago = freezed,Object? estadoPago = null,Object? saldoPendienteCentimos = null,Object? plazoCreditoDias = freezed,Object? venceEn = freezed,Object? motivoCancelacion = freezed,Object? claveIdempotencia = null,Object? entregadoEn = freezed,Object? creadoEn = null,Object? items = null,Object? eventos = null,}) {
  return _then(_Pedido(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,numero: null == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as int,clienteId: null == clienteId ? _self.clienteId : clienteId // ignore: cast_nullable_to_non_nullable
as String,creadoPor: freezed == creadoPor ? _self.creadoPor : creadoPor // ignore: cast_nullable_to_non_nullable
as String?,repartidorId: freezed == repartidorId ? _self.repartidorId : repartidorId // ignore: cast_nullable_to_non_nullable
as String?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoPedido,despacho: null == despacho ? _self.despacho : despacho // ignore: cast_nullable_to_non_nullable
as DespachoPedido,direccionEntrega: freezed == direccionEntrega ? _self.direccionEntrega : direccionEntrega // ignore: cast_nullable_to_non_nullable
as String?,notaCliente: freezed == notaCliente ? _self.notaCliente : notaCliente // ignore: cast_nullable_to_non_nullable
as String?,totalCentimos: null == totalCentimos ? _self.totalCentimos : totalCentimos // ignore: cast_nullable_to_non_nullable
as int,condicionPago: null == condicionPago ? _self.condicionPago : condicionPago // ignore: cast_nullable_to_non_nullable
as CondicionPago,metodoPago: freezed == metodoPago ? _self.metodoPago : metodoPago // ignore: cast_nullable_to_non_nullable
as MetodoPago?,estadoPago: null == estadoPago ? _self.estadoPago : estadoPago // ignore: cast_nullable_to_non_nullable
as EstadoPago,saldoPendienteCentimos: null == saldoPendienteCentimos ? _self.saldoPendienteCentimos : saldoPendienteCentimos // ignore: cast_nullable_to_non_nullable
as int,plazoCreditoDias: freezed == plazoCreditoDias ? _self.plazoCreditoDias : plazoCreditoDias // ignore: cast_nullable_to_non_nullable
as int?,venceEn: freezed == venceEn ? _self.venceEn : venceEn // ignore: cast_nullable_to_non_nullable
as DateTime?,motivoCancelacion: freezed == motivoCancelacion ? _self.motivoCancelacion : motivoCancelacion // ignore: cast_nullable_to_non_nullable
as String?,claveIdempotencia: null == claveIdempotencia ? _self.claveIdempotencia : claveIdempotencia // ignore: cast_nullable_to_non_nullable
as String,entregadoEn: freezed == entregadoEn ? _self.entregadoEn : entregadoEn // ignore: cast_nullable_to_non_nullable
as DateTime?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<PedidoItem>,eventos: null == eventos ? _self._eventos : eventos // ignore: cast_nullable_to_non_nullable
as List<PedidoEvento>,
  ));
}


}

// dart format on
