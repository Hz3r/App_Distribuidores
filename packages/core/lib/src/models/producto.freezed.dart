// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'producto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Producto {

 String get id; String get distribuidorId; String get categoriaId; String get nombre; String? get descripcion; String? get imagenUrl; bool get activo;
/// Create a copy of Producto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductoCopyWith<Producto> get copyWith => _$ProductoCopyWithImpl<Producto>(this as Producto, _$identity);

  /// Serializes this Producto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Producto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Producto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.distribuidorId, _this.distribuidorId) || other.distribuidorId == _this.distribuidorId)&&(identical(other.categoriaId, _this.categoriaId) || other.categoriaId == _this.categoriaId)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.descripcion, _this.descripcion) || other.descripcion == _this.descripcion)&&(identical(other.imagenUrl, _this.imagenUrl) || other.imagenUrl == _this.imagenUrl)&&(identical(other.activo, _this.activo) || other.activo == _this.activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Producto;
  return Object.hash(runtimeType,_this.id,_this.distribuidorId,_this.categoriaId,_this.nombre,_this.descripcion,_this.imagenUrl,_this.activo);
}

@override
String toString() {
  final _this = this as Producto;
  return 'Producto(id: ${_this.id}, distribuidorId: ${_this.distribuidorId}, categoriaId: ${_this.categoriaId}, nombre: ${_this.nombre}, descripcion: ${_this.descripcion}, imagenUrl: ${_this.imagenUrl}, activo: ${_this.activo})';
}


}

/// @nodoc
abstract mixin class $ProductoCopyWith<$Res>  {
  factory $ProductoCopyWith(Producto value, $Res Function(Producto) _then) = _$ProductoCopyWithImpl;
@useResult
$Res call({
 String id, String distribuidorId, String categoriaId, String nombre, String? descripcion, String? imagenUrl, bool activo
});




}
/// @nodoc
class _$ProductoCopyWithImpl<$Res>
    implements $ProductoCopyWith<$Res> {
  _$ProductoCopyWithImpl(this._self, this._then);

  final Producto _self;
  final $Res Function(Producto) _then;

/// Create a copy of Producto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? distribuidorId = null,Object? categoriaId = null,Object? nombre = null,Object? descripcion = freezed,Object? imagenUrl = freezed,Object? activo = null,}) {
  return _then(Producto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,categoriaId: null == categoriaId ? _self.categoriaId : categoriaId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,descripcion: freezed == descripcion ? _self.descripcion : descripcion // ignore: cast_nullable_to_non_nullable
as String?,imagenUrl: freezed == imagenUrl ? _self.imagenUrl : imagenUrl // ignore: cast_nullable_to_non_nullable
as String?,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Producto].
extension ProductoPatterns on Producto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Producto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Producto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Producto value)  $default,){
final _that = this;
switch (_that) {
case _Producto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Producto value)?  $default,){
final _that = this;
switch (_that) {
case _Producto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String categoriaId,  String nombre,  String? descripcion,  String? imagenUrl,  bool activo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Producto() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.categoriaId,_that.nombre,_that.descripcion,_that.imagenUrl,_that.activo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String distribuidorId,  String categoriaId,  String nombre,  String? descripcion,  String? imagenUrl,  bool activo)  $default,) {final _that = this;
switch (_that) {
case _Producto():
return $default(_that.id,_that.distribuidorId,_that.categoriaId,_that.nombre,_that.descripcion,_that.imagenUrl,_that.activo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String distribuidorId,  String categoriaId,  String nombre,  String? descripcion,  String? imagenUrl,  bool activo)?  $default,) {final _that = this;
switch (_that) {
case _Producto() when $default != null:
return $default(_that.id,_that.distribuidorId,_that.categoriaId,_that.nombre,_that.descripcion,_that.imagenUrl,_that.activo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Producto implements Producto {
  const _Producto({required this.id, required this.distribuidorId, required this.categoriaId, required this.nombre, this.descripcion, this.imagenUrl, this.activo = true});
  factory _Producto.fromJson(Map<String, dynamic> json) => _$ProductoFromJson(json);

@override final  String id;
@override final  String distribuidorId;
@override final  String categoriaId;
@override final  String nombre;
@override final  String? descripcion;
@override final  String? imagenUrl;
@override@JsonKey() final  bool activo;

/// Create a copy of Producto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductoCopyWith<_Producto> get copyWith => __$ProductoCopyWithImpl<_Producto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Producto&&(identical(other.id, id) || other.id == id)&&(identical(other.distribuidorId, distribuidorId) || other.distribuidorId == distribuidorId)&&(identical(other.categoriaId, categoriaId) || other.categoriaId == categoriaId)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.descripcion, descripcion) || other.descripcion == descripcion)&&(identical(other.imagenUrl, imagenUrl) || other.imagenUrl == imagenUrl)&&(identical(other.activo, activo) || other.activo == activo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,distribuidorId,categoriaId,nombre,descripcion,imagenUrl,activo);
}

@override
String toString() {
    return 'Producto(id: $id, distribuidorId: $distribuidorId, categoriaId: $categoriaId, nombre: $nombre, descripcion: $descripcion, imagenUrl: $imagenUrl, activo: $activo)';
}


}

/// @nodoc
abstract mixin class _$ProductoCopyWith<$Res> implements $ProductoCopyWith<$Res> {
  factory _$ProductoCopyWith(_Producto value, $Res Function(_Producto) _then) = __$ProductoCopyWithImpl;
@override @useResult
$Res call({
 String id, String distribuidorId, String categoriaId, String nombre, String? descripcion, String? imagenUrl, bool activo
});




}
/// @nodoc
class __$ProductoCopyWithImpl<$Res>
    implements _$ProductoCopyWith<$Res> {
  __$ProductoCopyWithImpl(this._self, this._then);

  final _Producto _self;
  final $Res Function(_Producto) _then;

/// Create a copy of Producto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? distribuidorId = null,Object? categoriaId = null,Object? nombre = null,Object? descripcion = freezed,Object? imagenUrl = freezed,Object? activo = null,}) {
  return _then(_Producto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,distribuidorId: null == distribuidorId ? _self.distribuidorId : distribuidorId // ignore: cast_nullable_to_non_nullable
as String,categoriaId: null == categoriaId ? _self.categoriaId : categoriaId // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,descripcion: freezed == descripcion ? _self.descripcion : descripcion // ignore: cast_nullable_to_non_nullable
as String?,imagenUrl: freezed == imagenUrl ? _self.imagenUrl : imagenUrl // ignore: cast_nullable_to_non_nullable
as String?,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
