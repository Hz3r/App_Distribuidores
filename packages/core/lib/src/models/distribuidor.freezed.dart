// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'distribuidor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Distribuidor {

 String get id; String get nombre; ConfigTema? get configTema;
/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DistribuidorCopyWith<Distribuidor> get copyWith => _$DistribuidorCopyWithImpl<Distribuidor>(this as Distribuidor, _$identity);

  /// Serializes this Distribuidor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Distribuidor;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Distribuidor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.configTema, _this.configTema) || other.configTema == _this.configTema));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Distribuidor;
  return Object.hash(runtimeType,_this.id,_this.nombre,_this.configTema);
}

@override
String toString() {
  final _this = this as Distribuidor;
  return 'Distribuidor(id: ${_this.id}, nombre: ${_this.nombre}, configTema: ${_this.configTema})';
}


}

/// @nodoc
abstract mixin class $DistribuidorCopyWith<$Res>  {
  factory $DistribuidorCopyWith(Distribuidor value, $Res Function(Distribuidor) _then) = _$DistribuidorCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, ConfigTema? configTema
});


$ConfigTemaCopyWith<$Res>? get configTema;

}
/// @nodoc
class _$DistribuidorCopyWithImpl<$Res>
    implements $DistribuidorCopyWith<$Res> {
  _$DistribuidorCopyWithImpl(this._self, this._then);

  final Distribuidor _self;
  final $Res Function(Distribuidor) _then;

/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? configTema = freezed,}) {
  return _then(Distribuidor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,configTema: freezed == configTema ? _self.configTema : configTema // ignore: cast_nullable_to_non_nullable
as ConfigTema?,
  ));
}
/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfigTemaCopyWith<$Res>? get configTema {
    if (_self.configTema == null) {
    return null;
  }

  return $ConfigTemaCopyWith<$Res>(_self.configTema!, (value) {
    return _then(_self.copyWith(configTema: value));
  });
}
}


/// Adds pattern-matching-related methods to [Distribuidor].
extension DistribuidorPatterns on Distribuidor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Distribuidor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Distribuidor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Distribuidor value)  $default,){
final _that = this;
switch (_that) {
case _Distribuidor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Distribuidor value)?  $default,){
final _that = this;
switch (_that) {
case _Distribuidor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  ConfigTema? configTema)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Distribuidor() when $default != null:
return $default(_that.id,_that.nombre,_that.configTema);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  ConfigTema? configTema)  $default,) {final _that = this;
switch (_that) {
case _Distribuidor():
return $default(_that.id,_that.nombre,_that.configTema);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  ConfigTema? configTema)?  $default,) {final _that = this;
switch (_that) {
case _Distribuidor() when $default != null:
return $default(_that.id,_that.nombre,_that.configTema);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Distribuidor implements Distribuidor {
  const _Distribuidor({required this.id, required this.nombre, this.configTema});
  factory _Distribuidor.fromJson(Map<String, dynamic> json) => _$DistribuidorFromJson(json);

@override final  String id;
@override final  String nombre;
@override final  ConfigTema? configTema;

/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DistribuidorCopyWith<_Distribuidor> get copyWith => __$DistribuidorCopyWithImpl<_Distribuidor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DistribuidorToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Distribuidor&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.configTema, configTema) || other.configTema == configTema));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nombre,configTema);
}

@override
String toString() {
    return 'Distribuidor(id: $id, nombre: $nombre, configTema: $configTema)';
}


}

/// @nodoc
abstract mixin class _$DistribuidorCopyWith<$Res> implements $DistribuidorCopyWith<$Res> {
  factory _$DistribuidorCopyWith(_Distribuidor value, $Res Function(_Distribuidor) _then) = __$DistribuidorCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, ConfigTema? configTema
});


@override $ConfigTemaCopyWith<$Res>? get configTema;

}
/// @nodoc
class __$DistribuidorCopyWithImpl<$Res>
    implements _$DistribuidorCopyWith<$Res> {
  __$DistribuidorCopyWithImpl(this._self, this._then);

  final _Distribuidor _self;
  final $Res Function(_Distribuidor) _then;

/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? configTema = freezed,}) {
  return _then(_Distribuidor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,configTema: freezed == configTema ? _self.configTema : configTema // ignore: cast_nullable_to_non_nullable
as ConfigTema?,
  ));
}

/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfigTemaCopyWith<$Res>? get configTema {
    if (_self.configTema == null) {
    return null;
  }

  return $ConfigTemaCopyWith<$Res>(_self.configTema!, (value) {
    return _then(_self.copyWith(configTema: value));
  });
}
}

// dart format on
