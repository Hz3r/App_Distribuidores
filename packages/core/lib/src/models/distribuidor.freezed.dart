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

 String get id; String get nombre; String get slug; String? get rubro; String? get documento; String? get telefono; EstadoDistribuidor get estado; String get moneda; String get zonaHoraria; ConfigTema get configTema; DateTime get creadoEn;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Distribuidor&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.slug, _this.slug) || other.slug == _this.slug)&&(identical(other.rubro, _this.rubro) || other.rubro == _this.rubro)&&(identical(other.documento, _this.documento) || other.documento == _this.documento)&&(identical(other.telefono, _this.telefono) || other.telefono == _this.telefono)&&(identical(other.estado, _this.estado) || other.estado == _this.estado)&&(identical(other.moneda, _this.moneda) || other.moneda == _this.moneda)&&(identical(other.zonaHoraria, _this.zonaHoraria) || other.zonaHoraria == _this.zonaHoraria)&&(identical(other.configTema, _this.configTema) || other.configTema == _this.configTema)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Distribuidor;
  return Object.hash(runtimeType,_this.id,_this.nombre,_this.slug,_this.rubro,_this.documento,_this.telefono,_this.estado,_this.moneda,_this.zonaHoraria,_this.configTema,_this.creadoEn);
}

@override
String toString() {
  final _this = this as Distribuidor;
  return 'Distribuidor(id: ${_this.id}, nombre: ${_this.nombre}, slug: ${_this.slug}, rubro: ${_this.rubro}, documento: ${_this.documento}, telefono: ${_this.telefono}, estado: ${_this.estado}, moneda: ${_this.moneda}, zonaHoraria: ${_this.zonaHoraria}, configTema: ${_this.configTema}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $DistribuidorCopyWith<$Res>  {
  factory $DistribuidorCopyWith(Distribuidor value, $Res Function(Distribuidor) _then) = _$DistribuidorCopyWithImpl;
@useResult
$Res call({
 String id, String nombre, String slug, String? rubro, String? documento, String? telefono, EstadoDistribuidor estado, String moneda, String zonaHoraria, ConfigTema configTema, DateTime creadoEn
});


$ConfigTemaCopyWith<$Res> get configTema;

}
/// @nodoc
class _$DistribuidorCopyWithImpl<$Res>
    implements $DistribuidorCopyWith<$Res> {
  _$DistribuidorCopyWithImpl(this._self, this._then);

  final Distribuidor _self;
  final $Res Function(Distribuidor) _then;

/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nombre = null,Object? slug = null,Object? rubro = freezed,Object? documento = freezed,Object? telefono = freezed,Object? estado = null,Object? moneda = null,Object? zonaHoraria = null,Object? configTema = null,Object? creadoEn = null,}) {
  return _then(Distribuidor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,rubro: freezed == rubro ? _self.rubro : rubro // ignore: cast_nullable_to_non_nullable
as String?,documento: freezed == documento ? _self.documento : documento // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoDistribuidor,moneda: null == moneda ? _self.moneda : moneda // ignore: cast_nullable_to_non_nullable
as String,zonaHoraria: null == zonaHoraria ? _self.zonaHoraria : zonaHoraria // ignore: cast_nullable_to_non_nullable
as String,configTema: null == configTema ? _self.configTema : configTema // ignore: cast_nullable_to_non_nullable
as ConfigTema,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfigTemaCopyWith<$Res> get configTema {
  
  return $ConfigTemaCopyWith<$Res>(_self.configTema, (value) {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nombre,  String slug,  String? rubro,  String? documento,  String? telefono,  EstadoDistribuidor estado,  String moneda,  String zonaHoraria,  ConfigTema configTema,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Distribuidor() when $default != null:
return $default(_that.id,_that.nombre,_that.slug,_that.rubro,_that.documento,_that.telefono,_that.estado,_that.moneda,_that.zonaHoraria,_that.configTema,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nombre,  String slug,  String? rubro,  String? documento,  String? telefono,  EstadoDistribuidor estado,  String moneda,  String zonaHoraria,  ConfigTema configTema,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _Distribuidor():
return $default(_that.id,_that.nombre,_that.slug,_that.rubro,_that.documento,_that.telefono,_that.estado,_that.moneda,_that.zonaHoraria,_that.configTema,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nombre,  String slug,  String? rubro,  String? documento,  String? telefono,  EstadoDistribuidor estado,  String moneda,  String zonaHoraria,  ConfigTema configTema,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Distribuidor() when $default != null:
return $default(_that.id,_that.nombre,_that.slug,_that.rubro,_that.documento,_that.telefono,_that.estado,_that.moneda,_that.zonaHoraria,_that.configTema,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Distribuidor implements Distribuidor {
  const _Distribuidor({required this.id, required this.nombre, required this.slug, this.rubro, this.documento, this.telefono, required this.estado, required this.moneda, required this.zonaHoraria, required this.configTema, required this.creadoEn});
  factory _Distribuidor.fromJson(Map<String, dynamic> json) => _$DistribuidorFromJson(json);

@override final  String id;
@override final  String nombre;
@override final  String slug;
@override final  String? rubro;
@override final  String? documento;
@override final  String? telefono;
@override final  EstadoDistribuidor estado;
@override final  String moneda;
@override final  String zonaHoraria;
@override final  ConfigTema configTema;
@override final  DateTime creadoEn;

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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Distribuidor&&(identical(other.id, id) || other.id == id)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.rubro, rubro) || other.rubro == rubro)&&(identical(other.documento, documento) || other.documento == documento)&&(identical(other.telefono, telefono) || other.telefono == telefono)&&(identical(other.estado, estado) || other.estado == estado)&&(identical(other.moneda, moneda) || other.moneda == moneda)&&(identical(other.zonaHoraria, zonaHoraria) || other.zonaHoraria == zonaHoraria)&&(identical(other.configTema, configTema) || other.configTema == configTema)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,nombre,slug,rubro,documento,telefono,estado,moneda,zonaHoraria,configTema,creadoEn);
}

@override
String toString() {
    return 'Distribuidor(id: $id, nombre: $nombre, slug: $slug, rubro: $rubro, documento: $documento, telefono: $telefono, estado: $estado, moneda: $moneda, zonaHoraria: $zonaHoraria, configTema: $configTema, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$DistribuidorCopyWith<$Res> implements $DistribuidorCopyWith<$Res> {
  factory _$DistribuidorCopyWith(_Distribuidor value, $Res Function(_Distribuidor) _then) = __$DistribuidorCopyWithImpl;
@override @useResult
$Res call({
 String id, String nombre, String slug, String? rubro, String? documento, String? telefono, EstadoDistribuidor estado, String moneda, String zonaHoraria, ConfigTema configTema, DateTime creadoEn
});


@override $ConfigTemaCopyWith<$Res> get configTema;

}
/// @nodoc
class __$DistribuidorCopyWithImpl<$Res>
    implements _$DistribuidorCopyWith<$Res> {
  __$DistribuidorCopyWithImpl(this._self, this._then);

  final _Distribuidor _self;
  final $Res Function(_Distribuidor) _then;

/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nombre = null,Object? slug = null,Object? rubro = freezed,Object? documento = freezed,Object? telefono = freezed,Object? estado = null,Object? moneda = null,Object? zonaHoraria = null,Object? configTema = null,Object? creadoEn = null,}) {
  return _then(_Distribuidor(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,rubro: freezed == rubro ? _self.rubro : rubro // ignore: cast_nullable_to_non_nullable
as String?,documento: freezed == documento ? _self.documento : documento // ignore: cast_nullable_to_non_nullable
as String?,telefono: freezed == telefono ? _self.telefono : telefono // ignore: cast_nullable_to_non_nullable
as String?,estado: null == estado ? _self.estado : estado // ignore: cast_nullable_to_non_nullable
as EstadoDistribuidor,moneda: null == moneda ? _self.moneda : moneda // ignore: cast_nullable_to_non_nullable
as String,zonaHoraria: null == zonaHoraria ? _self.zonaHoraria : zonaHoraria // ignore: cast_nullable_to_non_nullable
as String,configTema: null == configTema ? _self.configTema : configTema // ignore: cast_nullable_to_non_nullable
as ConfigTema,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of Distribuidor
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConfigTemaCopyWith<$Res> get configTema {
  
  return $ConfigTemaCopyWith<$Res>(_self.configTema, (value) {
    return _then(_self.copyWith(configTema: value));
  });
}
}

// dart format on
