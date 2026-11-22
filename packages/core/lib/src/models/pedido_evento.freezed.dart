// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pedido_evento.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PedidoEvento {

 String get id; String get distribuidorId; String get pedidoId; EstadoPedido? get estadoAnterior; EstadoPedido get estadoNuevo; String? get hechoPor; String? get nota; DateTime get creadoEn;
/// Create a copy of PedidoEvento
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PedidoEventoCopyWith<PedidoEvento> get copyWith => _$PedidoEventoCopyWithImpl<PedidoEvento>(this as PedidoEvento, _$identity);

  /// Serializes this PedidoEvento to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PedidoEvento;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PedidoEvento&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.pedidoId, _this.pedidoId) || other.pedidoId == _this.pedidoId)&&(identical(other.estadoAnterior, _this.estadoAnterior) || other.estadoAnterior == _this.estadoAnterior)&&(identical(other.estadoNuevo, _this.estadoNuevo) || other.estadoNuevo == _this.estadoNuevo)&&(identical(other.hechoPor, _this.hechoPor) || other.hechoPor == _this.hechoPor)&&(identical(other.nota, _this.nota) || other.nota == _this.nota)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PedidoEvento;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.pedidoId,_this.estadoAnterior,_this.estadoNuevo,_this.hechoPor,_this.nota,_this.creadoEn);
}

@override
String toString() {
  final _this = this as PedidoEvento;
  return 'PedidoEvento(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, pedidoId: ${_this.pedidoId}, estadoAnterior: ${_this.estadoAnterior}, estadoNuevo: ${_this.estadoNuevo}, hechoPor: ${_this.hechoPor}, nota: ${_this.nota}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $PedidoEventoCopyWith<$Res>  {
  factory $PedidoEventoCopyWith(PedidoEvento value, $Res Function(PedidoEvento) _then) = _$PedidoEventoCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String pedidoId, EstadoPedido? estadoAnterior, EstadoPedido estadoNuevo, String? hechoPor, String? nota, DateTime creadoEn
});




}
/// @nodoc
class _$PedidoEventoCopyWithImpl<$Res>
    implements $PedidoEventoCopyWith<$Res> {
  _$PedidoEventoCopyWithImpl(this._self, this._then);

  final PedidoEvento _self;
  final $Res Function(PedidoEvento) _then;

/// Create a copy of PedidoEvento
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? pedidoId = null,Object? estadoAnterior = freezed,Object? estadoNuevo = null,Object? hechoPor = freezed,Object? nota = freezed,Object? creadoEn = null,}) {
  return _then(PedidoEvento(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,pedidoId: null == pedidoId ? _self.pedidoId : pedidoId // ignore: cast_nullable_to_non_nullable
as String,estadoAnterior: freezed == estadoAnterior ? _self.estadoAnterior : estadoAnterior // ignore: cast_nullable_to_non_nullable
as EstadoPedido?,estadoNuevo: null == estadoNuevo ? _self.estadoNuevo : estadoNuevo // ignore: cast_nullable_to_non_nullable
as EstadoPedido,hechoPor: freezed == hechoPor ? _self.hechoPor : hechoPor // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PedidoEvento].
extension PedidoEventoPatterns on PedidoEvento {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PedidoEvento value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PedidoEvento() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PedidoEvento value)  $default,){
final _that = this;
switch (_that) {
case _PedidoEvento():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PedidoEvento value)?  $default,){
final _that = this;
switch (_that) {
case _PedidoEvento() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String pedidoId,  EstadoPedido? estadoAnterior,  EstadoPedido estadoNuevo,  String? hechoPor,  String? nota,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PedidoEvento() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.estadoAnterior,_that.estadoNuevo,_that.hechoPor,_that.nota,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String pedidoId,  EstadoPedido? estadoAnterior,  EstadoPedido estadoNuevo,  String? hechoPor,  String? nota,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _PedidoEvento():
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.estadoAnterior,_that.estadoNuevo,_that.hechoPor,_that.nota,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String pedidoId,  EstadoPedido? estadoAnterior,  EstadoPedido estadoNuevo,  String? hechoPor,  String? nota,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _PedidoEvento() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.pedidoId,_that.estadoAnterior,_that.estadoNuevo,_that.hechoPor,_that.nota,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PedidoEvento implements PedidoEvento {
  const _PedidoEvento({required this.id, required this.distribuidorId, required this.pedidoId, this.estadoAnterior, required this.estadoNuevo, this.hechoPor, this.nota, required this.creadoEn});
  factory _PedidoEvento.fromJson(Map<String, dynamic> json) => _$PedidoEventoFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String pedidoId;
@override final  EstadoPedido? estadoAnterior;
@override final  EstadoPedido estadoNuevo;
@override final  String? hechoPor;
@override final  String? nota;
@override final  DateTime creadoEn;

/// Create a copy of PedidoEvento
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PedidoEventoCopyWith<_PedidoEvento> get copyWith => __$PedidoEventoCopyWithImpl<_PedidoEvento>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PedidoEventoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PedidoEvento&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.pedidoId, pedidoId) || other.pedidoId == pedidoId)&&(identical(other.estadoAnterior, estadoAnterior) || other.estadoAnterior == estadoAnterior)&&(identical(other.estadoNuevo, estadoNuevo) || other.estadoNuevo == estadoNuevo)&&(identical(other.hechoPor, hechoPor) || other.hechoPor == hechoPor)&&(identical(other.nota, nota) || other.nota == nota)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,pedidoId,estadoAnterior,estadoNuevo,hechoPor,nota,creadoEn);
}

@override
String toString() {
    return 'PedidoEvento(id: $id, distribuidorId: $distribuidorId, pedidoId: $pedidoId, estadoAnterior: $estadoAnterior, estadoNuevo: $estadoNuevo, hechoPor: $hechoPor, nota: $nota, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$PedidoEventoCopyWith<$Res> implements $PedidoEventoCopyWith<$Res> {
  factory _$PedidoEventoCopyWith(_PedidoEvento value, $Res Function(_PedidoEvento) _then) = __$PedidoEventoCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String pedidoId, EstadoPedido? estadoAnterior, EstadoPedido estadoNuevo, String? hechoPor, String? nota, DateTime creadoEn
});




}
/// @nodoc
class __$PedidoEventoCopyWithImpl<$Res>
    implements _$PedidoEventoCopyWith<$Res> {
  __$PedidoEventoCopyWithImpl(this._self, this._then);

  final _PedidoEvento _self;
  final $Res Function(_PedidoEvento) _then;

/// Create a copy of PedidoEvento
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? pedidoId = null,Object? estadoAnterior = freezed,Object? estadoNuevo = null,Object? hechoPor = freezed,Object? nota = freezed,Object? creadoEn = null,}) {
  return _then(_PedidoEvento(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,pedidoId: null == pedidoId ? _self.pedidoId : pedidoId // ignore: cast_nullable_to_non_nullable
as String,estadoAnterior: freezed == estadoAnterior ? _self.estadoAnterior : estadoAnterior // ignore: cast_nullable_to_non_nullable
as EstadoPedido?,estadoNuevo: null == estadoNuevo ? _self.estadoNuevo : estadoNuevo // ignore: cast_nullable_to_non_nullable
as EstadoPedido,hechoPor: freezed == hechoPor ? _self.hechoPor : hechoPor // ignore: cast_nullable_to_non_nullable
as String?,nota: freezed == nota ? _self.nota : nota // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
