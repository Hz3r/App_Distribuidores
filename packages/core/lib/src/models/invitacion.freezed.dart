// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitacion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Invitacion {

 String get id; String get distribuidorId; String get codigo; RolMembresia get rol; String? get clienteNegocioId; String? get creadaPor; DateTime get venceEn; String? get usadaPor; DateTime? get usadaEn; DateTime? get revocadaEn; DateTime get creadoEn;
/// Create a copy of Invitacion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InvitacionCopyWith<Invitacion> get copyWith => _$InvitacionCopyWithImpl<Invitacion>(this as Invitacion, _$identity);

  /// Serializes this Invitacion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Invitacion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Invitacion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.codigo, _this.codigo) || other.codigo == _this.codigo)&&(identical(other.rol, _this.rol) || other.rol == _this.rol)&&(identical(other.clienteNegocioId, _this.clienteNegocioId) || other.clienteNegocioId == _this.clienteNegocioId)&&(identical(other.creadaPor, _this.creadaPor) || other.creadaPor == _this.creadaPor)&&(identical(other.venceEn, _this.venceEn) || other.venceEn == _this.venceEn)&&(identical(other.usadaPor, _this.usadaPor) || other.usadaPor == _this.usadaPor)&&(identical(other.usadaEn, _this.usadaEn) || other.usadaEn == _this.usadaEn)&&(identical(other.revocadaEn, _this.revocadaEn) || other.revocadaEn == _this.revocadaEn)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Invitacion;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.codigo,_this.rol,_this.clienteNegocioId,_this.creadaPor,_this.venceEn,_this.usadaPor,_this.usadaEn,_this.revocadaEn,_this.creadoEn);
}

@override
String toString() {
  final _this = this as Invitacion;
  return 'Invitacion(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, codigo: ${_this.codigo}, rol: ${_this.rol}, clienteNegocioId: ${_this.clienteNegocioId}, creadaPor: ${_this.creadaPor}, venceEn: ${_this.venceEn}, usadaPor: ${_this.usadaPor}, usadaEn: ${_this.usadaEn}, revocadaEn: ${_this.revocadaEn}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $InvitacionCopyWith<$Res>  {
  factory $InvitacionCopyWith(Invitacion value, $Res Function(Invitacion) _then) = _$InvitacionCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String codigo, RolMembresia rol, String? clienteNegocioId, String? creadaPor, DateTime venceEn, String? usadaPor, DateTime? usadaEn, DateTime? revocadaEn, DateTime creadoEn
});




}
/// @nodoc
class _$InvitacionCopyWithImpl<$Res>
    implements $InvitacionCopyWith<$Res> {
  _$InvitacionCopyWithImpl(this._self, this._then);

  final Invitacion _self;
  final $Res Function(Invitacion) _then;

/// Create a copy of Invitacion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? codigo = null,Object? rol = null,Object? clienteNegocioId = freezed,Object? creadaPor = freezed,Object? venceEn = null,Object? usadaPor = freezed,Object? usadaEn = freezed,Object? revocadaEn = freezed,Object? creadoEn = null,}) {
  return _then(Invitacion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolMembresia,clienteNegocioId: freezed == clienteNegocioId ? _self.clienteNegocioId : clienteNegocioId // ignore: cast_nullable_to_non_nullable
as String?,creadaPor: freezed == creadaPor ? _self.creadaPor : creadaPor // ignore: cast_nullable_to_non_nullable
as String?,venceEn: null == venceEn ? _self.venceEn : venceEn // ignore: cast_nullable_to_non_nullable
as DateTime,usadaPor: freezed == usadaPor ? _self.usadaPor : usadaPor // ignore: cast_nullable_to_non_nullable
as String?,usadaEn: freezed == usadaEn ? _self.usadaEn : usadaEn // ignore: cast_nullable_to_non_nullable
as DateTime?,revocadaEn: freezed == revocadaEn ? _self.revocadaEn : revocadaEn // ignore: cast_nullable_to_non_nullable
as DateTime?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Invitacion].
extension InvitacionPatterns on Invitacion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Invitacion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Invitacion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Invitacion value)  $default,){
final _that = this;
switch (_that) {
case _Invitacion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Invitacion value)?  $default,){
final _that = this;
switch (_that) {
case _Invitacion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String codigo,  RolMembresia rol,  String? clienteNegocioId,  String? creadaPor,  DateTime venceEn,  String? usadaPor,  DateTime? usadaEn,  DateTime? revocadaEn,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Invitacion() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.codigo,_that.rol,_that.clienteNegocioId,_that.creadaPor,_that.venceEn,_that.usadaPor,_that.usadaEn,_that.revocadaEn,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String codigo,  RolMembresia rol,  String? clienteNegocioId,  String? creadaPor,  DateTime venceEn,  String? usadaPor,  DateTime? usadaEn,  DateTime? revocadaEn,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _Invitacion():
return $default(_that.id,_that.distribuidorId,_that.codigo,_that.rol,_that.clienteNegocioId,_that.creadaPor,_that.venceEn,_that.usadaPor,_that.usadaEn,_that.revocadaEn,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String codigo,  RolMembresia rol,  String? clienteNegocioId,  String? creadaPor,  DateTime venceEn,  String? usadaPor,  DateTime? usadaEn,  DateTime? revocadaEn,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Invitacion() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.codigo,_that.rol,_that.clienteNegocioId,_that.creadaPor,_that.venceEn,_that.usadaPor,_that.usadaEn,_that.revocadaEn,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Invitacion implements Invitacion {
  const _Invitacion({required this.id, required this.distribuidorId, required this.codigo, required this.rol, this.clienteNegocioId, this.creadaPor, required this.venceEn, this.usadaPor, this.usadaEn, this.revocadaEn, required this.creadoEn});
  factory _Invitacion.fromJson(Map<String, dynamic> json) => _$InvitacionFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String codigo;
@override final  RolMembresia rol;
@override final  String? clienteNegocioId;
@override final  String? creadaPor;
@override final  DateTime venceEn;
@override final  String? usadaPor;
@override final  DateTime? usadaEn;
@override final  DateTime? revocadaEn;
@override final  DateTime creadoEn;

/// Create a copy of Invitacion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InvitacionCopyWith<_Invitacion> get copyWith => __$InvitacionCopyWithImpl<_Invitacion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InvitacionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Invitacion&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.rol, rol) || other.rol == rol)&&(identical(other.clienteNegocioId, clienteNegocioId) || other.clienteNegocioId == clienteNegocioId)&&(identical(other.creadaPor, creadaPor) || other.creadaPor == creadaPor)&&(identical(other.venceEn, venceEn) || other.venceEn == venceEn)&&(identical(other.usadaPor, usadaPor) || other.usadaPor == usadaPor)&&(identical(other.usadaEn, usadaEn) || other.usadaEn == usadaEn)&&(identical(other.revocadaEn, revocadaEn) || other.revocadaEn == revocadaEn)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,codigo,rol,clienteNegocioId,creadaPor,venceEn,usadaPor,usadaEn,revocadaEn,creadoEn);
}

@override
String toString() {
    return 'Invitacion(id: $id, distribuidorId: $distribuidorId, codigo: $codigo, rol: $rol, clienteNegocioId: $clienteNegocioId, creadaPor: $creadaPor, venceEn: $venceEn, usadaPor: $usadaPor, usadaEn: $usadaEn, revocadaEn: $revocadaEn, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$InvitacionCopyWith<$Res> implements $InvitacionCopyWith<$Res> {
  factory _$InvitacionCopyWith(_Invitacion value, $Res Function(_Invitacion) _then) = __$InvitacionCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String codigo, RolMembresia rol, String? clienteNegocioId, String? creadaPor, DateTime venceEn, String? usadaPor, DateTime? usadaEn, DateTime? revocadaEn, DateTime creadoEn
});




}
/// @nodoc
class __$InvitacionCopyWithImpl<$Res>
    implements _$InvitacionCopyWith<$Res> {
  __$InvitacionCopyWithImpl(this._self, this._then);

  final _Invitacion _self;
  final $Res Function(_Invitacion) _then;

/// Create a copy of Invitacion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? codigo = null,Object? rol = null,Object? clienteNegocioId = freezed,Object? creadaPor = freezed,Object? venceEn = null,Object? usadaPor = freezed,Object? usadaEn = freezed,Object? revocadaEn = freezed,Object? creadoEn = null,}) {
  return _then(_Invitacion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,rol: null == rol ? _self.rol : rol // ignore: cast_nullable_to_non_nullable
as RolMembresia,clienteNegocioId: freezed == clienteNegocioId ? _self.clienteNegocioId : clienteNegocioId // ignore: cast_nullable_to_non_nullable
as String?,creadaPor: freezed == creadaPor ? _self.creadaPor : creadaPor // ignore: cast_nullable_to_non_nullable
as String?,venceEn: null == venceEn ? _self.venceEn : venceEn // ignore: cast_nullable_to_non_nullable
as DateTime,usadaPor: freezed == usadaPor ? _self.usadaPor : usadaPor // ignore: cast_nullable_to_non_nullable
as String?,usadaEn: freezed == usadaEn ? _self.usadaEn : usadaEn // ignore: cast_nullable_to_non_nullable
as DateTime?,revocadaEn: freezed == revocadaEn ? _self.revocadaEn : revocadaEn // ignore: cast_nullable_to_non_nullable
as DateTime?,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
