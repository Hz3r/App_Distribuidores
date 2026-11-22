// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'precio_lista.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrecioLista {

 String get id; String get distribuidorId; String get listaPreciosId; String get presentacionId; int get precioCentimos; DateTime get creadoEn;
/// Create a copy of PrecioLista
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrecioListaCopyWith<PrecioLista> get copyWith => _$PrecioListaCopyWithImpl<PrecioLista>(this as PrecioLista, _$identity);

  /// Serializes this PrecioLista to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as PrecioLista;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrecioLista&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.listaPreciosId, _this.listaPreciosId) || other.listaPreciosId == _this.listaPreciosId)&&(identical(other.presentacionId, _this.presentacionId) || other.presentacionId == _this.presentacionId)&&(identical(other.precioCentimos, _this.precioCentimos) || other.precioCentimos == _this.precioCentimos)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as PrecioLista;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.listaPreciosId,_this.presentacionId,_this.precioCentimos,_this.creadoEn);
}

@override
String toString() {
  final _this = this as PrecioLista;
  return 'PrecioLista(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, listaPreciosId: ${_this.listaPreciosId}, presentacionId: ${_this.presentacionId}, precioCentimos: ${_this.precioCentimos}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $PrecioListaCopyWith<$Res>  {
  factory $PrecioListaCopyWith(PrecioLista value, $Res Function(PrecioLista) _then) = _$PrecioListaCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String listaPreciosId, String presentacionId, int precioCentimos, DateTime creadoEn
});




}
/// @nodoc
class _$PrecioListaCopyWithImpl<$Res>
    implements $PrecioListaCopyWith<$Res> {
  _$PrecioListaCopyWithImpl(this._self, this._then);

  final PrecioLista _self;
  final $Res Function(PrecioLista) _then;

/// Create a copy of PrecioLista
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? listaPreciosId = null,Object? presentacionId = null,Object? precioCentimos = null,Object? creadoEn = null,}) {
  return _then(PrecioLista(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,listaPreciosId: null == listaPreciosId ? _self.listaPreciosId : listaPreciosId // ignore: cast_nullable_to_non_nullable
as String,presentacionId: null == presentacionId ? _self.presentacionId : presentacionId // ignore: cast_nullable_to_non_nullable
as String,precioCentimos: null == precioCentimos ? _self.precioCentimos : precioCentimos // ignore: cast_nullable_to_non_nullable
as int,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PrecioLista].
extension PrecioListaPatterns on PrecioLista {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrecioLista value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrecioLista() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrecioLista value)  $default,){
final _that = this;
switch (_that) {
case _PrecioLista():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrecioLista value)?  $default,){
final _that = this;
switch (_that) {
case _PrecioLista() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String listaPreciosId,  String presentacionId,  int precioCentimos,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrecioLista() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.listaPreciosId,_that.presentacionId,_that.precioCentimos,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String listaPreciosId,  String presentacionId,  int precioCentimos,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _PrecioLista():
return $default(_that.id,_that.distribuidorId,_that.listaPreciosId,_that.presentacionId,_that.precioCentimos,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String listaPreciosId,  String presentacionId,  int precioCentimos,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _PrecioLista() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.listaPreciosId,_that.presentacionId,_that.precioCentimos,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrecioLista implements PrecioLista {
  const _PrecioLista({required this.id, required this.distribuidorId, required this.listaPreciosId, required this.presentacionId, required this.precioCentimos, required this.creadoEn});
  factory _PrecioLista.fromJson(Map<String, dynamic> json) => _$PrecioListaFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String listaPreciosId;
@override final  String presentacionId;
@override final  int precioCentimos;
@override final  DateTime creadoEn;

/// Create a copy of PrecioLista
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrecioListaCopyWith<_PrecioLista> get copyWith => __$PrecioListaCopyWithImpl<_PrecioLista>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrecioListaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrecioLista&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.listaPreciosId, listaPreciosId) || other.listaPreciosId == listaPreciosId)&&(identical(other.presentacionId, presentacionId) || other.presentacionId == presentacionId)&&(identical(other.precioCentimos, precioCentimos) || other.precioCentimos == precioCentimos)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,listaPreciosId,presentacionId,precioCentimos,creadoEn);
}

@override
String toString() {
    return 'PrecioLista(id: $id, distribuidorId: $distribuidorId, listaPreciosId: $listaPreciosId, presentacionId: $presentacionId, precioCentimos: $precioCentimos, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$PrecioListaCopyWith<$Res> implements $PrecioListaCopyWith<$Res> {
  factory _$PrecioListaCopyWith(_PrecioLista value, $Res Function(_PrecioLista) _then) = __$PrecioListaCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String listaPreciosId, String presentacionId, int precioCentimos, DateTime creadoEn
});




}
/// @nodoc
class __$PrecioListaCopyWithImpl<$Res>
    implements _$PrecioListaCopyWith<$Res> {
  __$PrecioListaCopyWithImpl(this._self, this._then);

  final _PrecioLista _self;
  final $Res Function(_PrecioLista) _then;

/// Create a copy of PrecioLista
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? listaPreciosId = null,Object? presentacionId = null,Object? precioCentimos = null,Object? creadoEn = null,}) {
  return _then(_PrecioLista(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,listaPreciosId: null == listaPreciosId ? _self.listaPreciosId : listaPreciosId // ignore: cast_nullable_to_non_nullable
as String,presentacionId: null == presentacionId ? _self.presentacionId : presentacionId // ignore: cast_nullable_to_non_nullable
as String,precioCentimos: null == precioCentimos ? _self.precioCentimos : precioCentimos // ignore: cast_nullable_to_non_nullable
as int,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
