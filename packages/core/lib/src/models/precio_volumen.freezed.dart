// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'precio_volumen.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrecioVolumen {

 String get id; String get distribuidorId; String get presentacionId; int get cantidadMinima; int get precioCentimos; DateTime get creadoEn;
/// Create a copy of PrecioVolumen
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrecioVolumenCopyWith<PrecioVolumen> get copyWith => _$PrecioVolumenCopyWithImpl<PrecioVolumen>(this as PrecioVolumen, _$identity);

  /// Serializes this PrecioVolumen to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PrecioVolumen;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrecioVolumen&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.presentacionId, _this.presentacionId) || other.presentacionId == _this.presentacionId)&&(identical(other.cantidadMinima, _this.cantidadMinima) || other.cantidadMinima == _this.cantidadMinima)&&(identical(other.precioCentimos, _this.precioCentimos) || other.precioCentimos == _this.precioCentimos)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PrecioVolumen;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.presentacionId,_this.cantidadMinima,_this.precioCentimos,_this.creadoEn);
}

@override
String toString() {
  final _this = this as PrecioVolumen;
  return 'PrecioVolumen(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, presentacionId: ${_this.presentacionId}, cantidadMinima: ${_this.cantidadMinima}, precioCentimos: ${_this.precioCentimos}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $PrecioVolumenCopyWith<$Res>  {
  factory $PrecioVolumenCopyWith(PrecioVolumen value, $Res Function(PrecioVolumen) _then) = _$PrecioVolumenCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String presentacionId, int cantidadMinima, int precioCentimos, DateTime creadoEn
});




}
/// @nodoc
class _$PrecioVolumenCopyWithImpl<$Res>
    implements $PrecioVolumenCopyWith<$Res> {
  _$PrecioVolumenCopyWithImpl(this._self, this._then);

  final PrecioVolumen _self;
  final $Res Function(PrecioVolumen) _then;

/// Create a copy of PrecioVolumen
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? presentacionId = null,Object? cantidadMinima = null,Object? precioCentimos = null,Object? creadoEn = null,}) {
  return _then(PrecioVolumen(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,presentacionId: null == presentacionId ? _self.presentacionId : presentacionId // ignore: cast_nullable_to_non_nullable
as String,cantidadMinima: null == cantidadMinima ? _self.cantidadMinima : cantidadMinima // ignore: cast_nullable_to_non_nullable
as int,precioCentimos: null == precioCentimos ? _self.precioCentimos : precioCentimos // ignore: cast_nullable_to_non_nullable
as int,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PrecioVolumen].
extension PrecioVolumenPatterns on PrecioVolumen {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrecioVolumen value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrecioVolumen() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrecioVolumen value)  $default,){
final _that = this;
switch (_that) {
case _PrecioVolumen():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrecioVolumen value)?  $default,){
final _that = this;
switch (_that) {
case _PrecioVolumen() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String presentacionId,  int cantidadMinima,  int precioCentimos,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrecioVolumen() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.presentacionId,_that.cantidadMinima,_that.precioCentimos,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String presentacionId,  int cantidadMinima,  int precioCentimos,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _PrecioVolumen():
return $default(_that.id,_that.distribuidorId,_that.presentacionId,_that.cantidadMinima,_that.precioCentimos,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String presentacionId,  int cantidadMinima,  int precioCentimos,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _PrecioVolumen() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.presentacionId,_that.cantidadMinima,_that.precioCentimos,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrecioVolumen implements PrecioVolumen {
  const _PrecioVolumen({required this.id, required this.distribuidorId, required this.presentacionId, required this.cantidadMinima, required this.precioCentimos, required this.creadoEn});
  factory _PrecioVolumen.fromJson(Map<String, dynamic> json) => _$PrecioVolumenFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String presentacionId;
@override final  int cantidadMinima;
@override final  int precioCentimos;
@override final  DateTime creadoEn;

/// Create a copy of PrecioVolumen
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrecioVolumenCopyWith<_PrecioVolumen> get copyWith => __$PrecioVolumenCopyWithImpl<_PrecioVolumen>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrecioVolumenToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrecioVolumen&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.presentacionId, presentacionId) || other.presentacionId == presentacionId)&&(identical(other.cantidadMinima, cantidadMinima) || other.cantidadMinima == cantidadMinima)&&(identical(other.precioCentimos, precioCentimos) || other.precioCentimos == precioCentimos)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,presentacionId,cantidadMinima,precioCentimos,creadoEn);
}

@override
String toString() {
    return 'PrecioVolumen(id: $id, distribuidorId: $distribuidorId, presentacionId: $presentacionId, cantidadMinima: $cantidadMinima, precioCentimos: $precioCentimos, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$PrecioVolumenCopyWith<$Res> implements $PrecioVolumenCopyWith<$Res> {
  factory _$PrecioVolumenCopyWith(_PrecioVolumen value, $Res Function(_PrecioVolumen) _then) = __$PrecioVolumenCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String presentacionId, int cantidadMinima, int precioCentimos, DateTime creadoEn
});




}
/// @nodoc
class __$PrecioVolumenCopyWithImpl<$Res>
    implements _$PrecioVolumenCopyWith<$Res> {
  __$PrecioVolumenCopyWithImpl(this._self, this._then);

  final _PrecioVolumen _self;
  final $Res Function(_PrecioVolumen) _then;

/// Create a copy of PrecioVolumen
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? presentacionId = null,Object? cantidadMinima = null,Object? precioCentimos = null,Object? creadoEn = null,}) {
  return _then(_PrecioVolumen(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,presentacionId: null == presentacionId ? _self.presentacionId : presentacionId // ignore: cast_nullable_to_non_nullable
as String,cantidadMinima: null == cantidadMinima ? _self.cantidadMinima : cantidadMinima // ignore: cast_nullable_to_non_nullable
as int,precioCentimos: null == precioCentimos ? _self.precioCentimos : precioCentimos // ignore: cast_nullable_to_non_nullable
as int,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
