// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'categoria.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Categoria {

 String get id; String get distribuidorId; String get nombre; int get orden;
/// Create a copy of Categoria
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CategoriaCopyWith<Categoria> get copyWith => _$CategoriaCopyWithImpl<Categoria>(this as Categoria, _$identity);

  /// Serializes this Categoria to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Categoria;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Categoria&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.orden, _this.orden) || other.orden == _this.orden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Categoria;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.nombre,_this.orden);
}

@override
String toString() {
  final _this = this as Categoria;
  return 'Categoria(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, nombre: ${_this.nombre}, orden: ${_this.orden})';
}


}

/// @nodoc
abstract mixin class $CategoriaCopyWith<$Res>  {
  factory $CategoriaCopyWith(Categoria value, $Res Function(Categoria) _then) = _$CategoriaCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String nombre, int orden
});




}
/// @nodoc
class _$CategoriaCopyWithImpl<$Res>
    implements $CategoriaCopyWith<$Res> {
  _$CategoriaCopyWithImpl(this._self, this._then);

  final Categoria _self;
  final $Res Function(Categoria) _then;

/// Create a copy of Categoria
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? nombre = null,Object? orden = null,}) {
  return _then(Categoria(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Categoria].
extension CategoriaPatterns on Categoria {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Categoria value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Categoria() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Categoria value)  $default,){
final _that = this;
switch (_that) {
case _Categoria():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Categoria value)?  $default,){
final _that = this;
switch (_that) {
case _Categoria() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String nombre,  int orden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Categoria() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.nombre,_that.orden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String nombre,  int orden)  $default,) {final _that = this;
switch (_that) {
case _Categoria():
return $default(_that.id,_that.distribuidorId,_that.nombre,_that.orden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String nombre,  int orden)?  $default,) {final _that = this;
switch (_that) {
case _Categoria() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.nombre,_that.orden);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Categoria implements Categoria {
  const _Categoria({required this.id, required this.distribuidorId, required this.nombre, this.orden = 0});
  factory _Categoria.fromJson(Map<String, dynamic> json) => _$CategoriaFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String nombre;
@override@JsonKey() final  int orden;

/// Create a copy of Categoria
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoriaCopyWith<_Categoria> get copyWith => __$CategoriaCopyWithImpl<_Categoria>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CategoriaToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Categoria&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.orden, orden) || other.orden == orden));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,nombre,orden);
}

@override
String toString() {
    return 'Categoria(id: $id, distribuidorId: $distribuidorId, nombre: $nombre, orden: $orden)';
}


}

/// @nodoc
abstract mixin class _$CategoriaCopyWith<$Res> implements $CategoriaCopyWith<$Res> {
  factory _$CategoriaCopyWith(_Categoria value, $Res Function(_Categoria) _then) = __$CategoriaCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String nombre, int orden
});




}
/// @nodoc
class __$CategoriaCopyWithImpl<$Res>
    implements _$CategoriaCopyWith<$Res> {
  __$CategoriaCopyWithImpl(this._self, this._then);

  final _Categoria _self;
  final $Res Function(_Categoria) _then;

/// Create a copy of Categoria
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? nombre = null,Object? orden = null,}) {
  return _then(_Categoria(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,orden: null == orden ? _self.orden : orden // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
