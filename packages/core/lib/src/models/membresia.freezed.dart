// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membresia.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Membresia {

 String get id; String get perfilId; String get distribuidorId; RolMembresia get rol; EstadoMembresia get estado; String? get clienteNegocioId; DateTime get creadoEn; Distribuidor? get distribuidor; ClienteNegocio? get clienteNegocio;
/// Create a copy of Membresia
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembresiaCopyWith<Membresia> get copyWith => _$MembresiaCopyWithImpl<Membresia>(this as Membresia, _$identity);

  /// Serializes this Membresia to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Membresia;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membresia&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.perfilId, _this.perfilId) || other.perfilId == _this.perfilId)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.rol, _this.rol) || other.rol == _this.rol)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.clienteNegocioId, _this.clienteNegocioId) || other.clienteNegocioId == _this.clienteNegocioId)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn)&&(identical(other.distribuidor, _this.distribuidor) || other.distribuidor == _this.distribuidor)&&(identical(other.clienteNegocio, _this.clienteNegocio) || other.clienteNegocio == _this.clienteNegocio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Membresia;
  return Object.hash(runtimeType,_this.id,_this.perfilId,_this.distribuidorId,_this.rol,_this.estado,_this.clienteNegocioId,_this.creadoEn,_this.distribuidor,_this.clienteNegocio);
}

@override
String toString() {
  final _this = this as Membresia;
  return 'Membresia(id: ${_this.id}, perfilId: ${_this.perfilId}, distribuidorId: ${_this.distribuidorId}, rol: ${_this.rol}, estado: ${_this.estado}, clienteNegocioId: ${_this.clienteNegocioId}, creadoEn: ${_this.creadoEn}, distribuidor: ${_this.distribuidor}, clienteNegocio: ${_this.clienteNegocio})';
}


}

/// @nodoc
abstract mixin class $MembresiaCopyWith<$Res>  {
  factory $MembresiaCopyWith(Membresia value, $Res Function(Membresia) _then) = _$MembresiaCopyWithImpl;
@useResult
$Res call({
 String id, String perfilId, String distribuidorId, RolMembresia rol, EstadoMembresia estado, String? clienteNegocioId, DateTime creadoEn, Distribuidor? distribuidor, ClienteNegocio? clienteNegocio
});


$DistribuidorCopyWith<$Res>? get distribuidor;$ClienteNegocioCopyWith<$Res>? get clienteNegocio;

}
/// @nodoc
class _$MembresiaCopyWithImpl<$Res>
    implements $MembresiaCopyWith<$Res> {
  _$MembresiaCopyWithImpl(this._self, this._then);

  final Membresia _self;
  final $Res Function(Membresia) _then;

/// Create a copy of Membresia
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? perfilId = null,Object? distribuidorId = null,Object? rol = null,Object? estado = null,Object? clienteNegocioId = freezed,Object? creadoEn = null,Object? distribuidor = freezed,Object? clienteNegocio = freezed,}) {
  return _then(Membresia(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,perfilId: null == perfilId ? _self.perfilId : perfilId // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolMembresia,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoMembresia,clienteNegocioId: freezed == clienteNegocioId ? _self.clienteNegocioId : clienteNegocioId // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,distribuidor: freezed == distribuidor ? _self.distribuidor : distribuidor // ignore: cast_nullable_to_non_nullable
as Distribuidor?,clienteNegocio: freezed == clienteNegocio ? _self.clienteNegocio : clienteNegocio // ignore: cast_nullable_to_non_nullable
as ClienteNegocio?,
  ));
}
/// Create a copy of Membresia
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DistribuidorCopyWith<$Res>? get distribuidor {
    if (_self.distribuidor == null) {
    return null;
  }

  return $DistribuidorCopyWith<$Res>(_self.distribuidor!, (value) {
    return _then(_self.copyWith(distribuidor: value));
  });
}/// Create a copy of Membresia
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClienteNegocioCopyWith<$Res>? get clienteNegocio {
    if (_self.clienteNegocio == null) {
    return null;
  }

  return $ClienteNegocioCopyWith<$Res>(_self.clienteNegocio!, (value) {
    return _then(_self.copyWith(clienteNegocio: value));
  });
}
}


/// Adds pattern-matching-related methods to [Membresia].
extension MembresiaPatterns on Membresia {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membresia value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membresia() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membresia value)  $default,){
final _that = this;
switch (_that) {
case _Membresia():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membresia value)?  $default,){
final _that = this;
switch (_that) {
case _Membresia() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String perfilId,  String distribuidorId,  RolMembresia rol,  EstadoMembresia estado,  String? clienteNegocioId,  DateTime creadoEn,  Distribuidor? distribuidor,  ClienteNegocio? clienteNegocio)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membresia() when $default != null:
return $default(_that.id,_that.perfilId,_that.distribuidorId,_that.rol,_that.estado,_that.clienteNegocioId,_that.creadoEn,_that.distribuidor,_that.clienteNegocio);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String perfilId,  String distribuidorId,  RolMembresia rol,  EstadoMembresia estado,  String? clienteNegocioId,  DateTime creadoEn,  Distribuidor? distribuidor,  ClienteNegocio? clienteNegocio)  $default,) {final _that = this;
switch (_that) {
case _Membresia():
return $default(_that.id,_that.perfilId,_that.distribuidorId,_that.rol,_that.estado,_that.clienteNegocioId,_that.creadoEn,_that.distribuidor,_that.clienteNegocio);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String perfilId,  String distribuidorId,  RolMembresia rol,  EstadoMembresia estado,  String? clienteNegocioId,  DateTime creadoEn,  Distribuidor? distribuidor,  ClienteNegocio? clienteNegocio)?  $default,) {final _that = this;
switch (_that) {
case _Membresia() when $default != null:
return $default(_that.id,_that.perfilId,_that.distribuidorId,_that.rol,_that.estado,_that.clienteNegocioId,_that.creadoEn,_that.distribuidor,_that.clienteNegocio);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Membresia extends Membresia {
  const _Membresia({required this.id, required this.perfilId, required this.distribuidorId, required this.rol, required this.estado, this.clienteNegocioId, required this.creadoEn, this.distribuidor, this.clienteNegocio}): super._();
  factory _Membresia.fromJson(Map<String, dynamic> json) => _$MembresiaFromJson(json);

@override final  String id;
@override final  String perfilId;
@override final  String distribuidorId;
@override final  RolMembresia rol;
@override final  EstadoMembresia estado;
@override final  String? clienteNegocioId;
@override final  DateTime creadoEn;
@override final  Distribuidor? distribuidor;
@override final  ClienteNegocio? clienteNegocio;

/// Create a copy of Membresia
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembresiaCopyWith<_Membresia> get copyWith => __$MembresiaCopyWithImpl<_Membresia>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembresiaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membresia&&(identical(other.id, id) || other.id == id)&&(identical(other.perfilId, perfilId) || other.perfilId == perfilId)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.clienteNegocioId, clienteNegocioId) || other.clienteNegocioId == clienteNegocioId)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn)&&(identical(other.distribuidor, distribuidor) || other.distribuidor == distribuidor)&&(identical(other.clienteNegocio, clienteNegocio) || other.clienteNegocio == clienteNegocio));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,perfilId,distribuidorId,rol,estado,clienteNegocioId,creadoEn,distribuidor,clienteNegocio);
}

@override
String toString() {
    return 'Membresia(id: $id, perfilId: $perfilId, distribuidorId: $distribuidorId, rol: $rol, estado: $estado, clienteNegocioId: $clienteNegocioId, creadoEn: $creadoEn, distribuidor: $distribuidor, clienteNegocio: $clienteNegocio)';
}


}

/// @nodoc
abstract mixin class _$MembresiaCopyWith<$Res> implements $MembresiaCopyWith<$Res> {
  factory _$MembresiaCopyWith(_Membresia value, $Res Function(_Membresia) _then) = __$MembresiaCopyWithImpl;
@override @useResult
$Res call({
 String id, String perfilId, String distribuidorId, RolMembresia rol, EstadoMembresia estado, String? clienteNegocioId, DateTime creadoEn, Distribuidor? distribuidor, ClienteNegocio? clienteNegocio
});


@override $DistribuidorCopyWith<$Res>? get distribuidor;@override $ClienteNegocioCopyWith<$Res>? get clienteNegocio;

}
/// @nodoc
class __$MembresiaCopyWithImpl<$Res>
    implements _$MembresiaCopyWith<$Res> {
  __$MembresiaCopyWithImpl(this._self, this._then);

  final _Membresia _self;
  final $Res Function(_Membresia) _then;

/// Create a copy of Membresia
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? perfilId = null,Object? distribuidorId = null,Object? rol = null,Object? estado = null,Object? clienteNegocioId = freezed,Object? creadoEn = null,Object? distribuidor = freezed,Object? clienteNegocio = freezed,}) {
  return _then(_Membresia(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,perfilId: null == perfilId ? _self.perfilId : perfilId // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolMembresia,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoMembresia,clienteNegocioId: freezed == clienteNegocioId ? _self.clienteNegocioId : clienteNegocioId // ignore: cast_nullable_to_non_nullable
as String?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,distribuidor: freezed == distribuidor ? _self.distribuidor : distribuidor // ignore: cast_nullable_to_non_nullable
as Distribuidor?,clienteNegocio: freezed == clienteNegocio ? _self.clienteNegocio : clienteNegocio // ignore: cast_nullable_to_non_nullable
as ClienteNegocio?,
  ));
}

/// Create a copy of Membresia
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DistribuidorCopyWith<$Res>? get distribuidor {
    if (_self.distribuidor == null) {
    return null;
  }

  return $DistribuidorCopyWith<$Res>(_self.distribuidor!, (value) {
    return _then(_self.copyWith(distribuidor: value));
  });
}/// Create a copy of Membresia
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClienteNegocioCopyWith<$Res>? get clienteNegocio {
    if (_self.clienteNegocio == null) {
    return null;
  }

  return $ClienteNegocioCopyWith<$Res>(_self.clienteNegocio!, (value) {
    return _then(_self.copyWith(clienteNegocio: value));
  });
}
}

// dart format on
