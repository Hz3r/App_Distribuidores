// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Plan {

 String get id; String get codigo; String get nombre; int get precioMensualCentimos; String get moneda; Map<String, dynamic> get limites; bool get activo; DateTime get creadoEn;
/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanCopyWith<Plan> get copyWith => _$PlanCopyWithImpl<Plan>(this as Plan, _$identity);

  /// Serializes this Plan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Plan;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Plan&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.codigo, _this.codigo) || other.codigo == _this.codigo)&&(identical(other.nombre, _this.nombre) || other.nombre == _this.nombre)&&(identical(other.precioMensualCentimos, _this.precioMensualCentimos) || other.precioMensualCentimos == _this.precioMensualCentimos)&&(identical(other.moneda, _this.moneda) || other.moneda == _this.moneda)&&const DeepCollectionEquality().equals(other.limites, _this.limites)&&(identical(other.activo, _this.activo) || other.activo == _this.activo)&&(identical(other.creadoEn, _this.creadoEn) || other.creadoEn == _this.creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Plan;
  return Object.hash(runtimeType,_this.id,_this.codigo,_this.nombre,_this.precioMensualCentimos,_this.moneda,const DeepCollectionEquality().hash(_this.limites),_this.activo,_this.creadoEn);
}

@override
String toString() {
  final _this = this as Plan;
  return 'Plan(id: ${_this.id}, codigo: ${_this.codigo}, nombre: ${_this.nombre}, precioMensualCentimos: ${_this.precioMensualCentimos}, moneda: ${_this.moneda}, limites: ${_this.limites}, activo: ${_this.activo}, creadoEn: ${_this.creadoEn})';
}


}

/// @nodoc
abstract mixin class $PlanCopyWith<$Res>  {
  factory $PlanCopyWith(Plan value, $Res Function(Plan) _then) = _$PlanCopyWithImpl;
@useResult
$Res call({
 String id, String codigo, String nombre, int precioMensualCentimos, String moneda, Map<String, dynamic> limites, bool activo, DateTime creadoEn
});




}
/// @nodoc
class _$PlanCopyWithImpl<$Res>
    implements $PlanCopyWith<$Res> {
  _$PlanCopyWithImpl(this._self, this._then);

  final Plan _self;
  final $Res Function(Plan) _then;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codigo = null,Object? nombre = null,Object? precioMensualCentimos = null,Object? moneda = null,Object? limites = null,Object? activo = null,Object? creadoEn = null,}) {
  return _then(Plan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precioMensualCentimos: null == precioMensualCentimos ? _self.precioMensualCentimos : precioMensualCentimos // ignore: cast_nullable_to_non_nullable
as int,moneda: null == moneda ? _self.moneda : moneda // ignore: cast_nullable_to_non_nullable
as String,limites: null == limites ? _self.limites : limites // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Plan].
extension PlanPatterns on Plan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Plan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Plan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Plan value)  $default,){
final _that = this;
switch (_that) {
case _Plan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Plan value)?  $default,){
final _that = this;
switch (_that) {
case _Plan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String codigo,  String nombre,  int precioMensualCentimos,  String moneda,  Map<String, dynamic> limites,  bool activo,  DateTime creadoEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that.id,_that.codigo,_that.nombre,_that.precioMensualCentimos,_that.moneda,_that.limites,_that.activo,_that.creadoEn);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String codigo,  String nombre,  int precioMensualCentimos,  String moneda,  Map<String, dynamic> limites,  bool activo,  DateTime creadoEn)  $default,) {final _that = this;
switch (_that) {
case _Plan():
return $default(_that.id,_that.codigo,_that.nombre,_that.precioMensualCentimos,_that.moneda,_that.limites,_that.activo,_that.creadoEn);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String codigo,  String nombre,  int precioMensualCentimos,  String moneda,  Map<String, dynamic> limites,  bool activo,  DateTime creadoEn)?  $default,) {final _that = this;
switch (_that) {
case _Plan() when $default != null:
return $default(_that.id,_that.codigo,_that.nombre,_that.precioMensualCentimos,_that.moneda,_that.limites,_that.activo,_that.creadoEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Plan implements Plan {
  const _Plan({required this.id, required this.codigo, required this.nombre, required this.precioMensualCentimos, required this.moneda, required  Map<String, dynamic> limites, required this.activo, required this.creadoEn}): _limites = limites;
  factory _Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);

@override final  String id;
@override final  String codigo;
@override final  String nombre;
@override final  int precioMensualCentimos;
@override final  String moneda;
 final  Map<String, dynamic> _limites;
@override Map<String, dynamic> get limites {
  if (_limites is EqualUnmodifiableMapView) return _limites;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_limites);
}

@override final  bool activo;
@override final  DateTime creadoEn;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanCopyWith<_Plan> get copyWith => __$PlanCopyWithImpl<_Plan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Plan&&(identical(other.id, id) || other.id == id)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.nombre, nombre) || other.nombre == nombre)&&(identical(other.precioMensualCentimos, precioMensualCentimos) || other.precioMensualCentimos == precioMensualCentimos)&&(identical(other.moneda, moneda) || other.moneda == moneda)&&const DeepCollectionEquality().equals(other.limites, _limites)&&(identical(other.activo, activo) || other.activo == activo)&&(identical(other.creadoEn, creadoEn) || other.creadoEn == creadoEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,codigo,nombre,precioMensualCentimos,moneda,const DeepCollectionEquality().hash(_limites),activo,creadoEn);
}

@override
String toString() {
    return 'Plan(id: $id, codigo: $codigo, nombre: $nombre, precioMensualCentimos: $precioMensualCentimos, moneda: $moneda, limites: $limites, activo: $activo, creadoEn: $creadoEn)';
}


}

/// @nodoc
abstract mixin class _$PlanCopyWith<$Res> implements $PlanCopyWith<$Res> {
  factory _$PlanCopyWith(_Plan value, $Res Function(_Plan) _then) = __$PlanCopyWithImpl;
@override @useResult
$Res call({
 String id, String codigo, String nombre, int precioMensualCentimos, String moneda, Map<String, dynamic> limites, bool activo, DateTime creadoEn
});




}
/// @nodoc
class __$PlanCopyWithImpl<$Res>
    implements _$PlanCopyWith<$Res> {
  __$PlanCopyWithImpl(this._self, this._then);

  final _Plan _self;
  final $Res Function(_Plan) _then;

/// Create a copy of Plan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codigo = null,Object? nombre = null,Object? precioMensualCentimos = null,Object? moneda = null,Object? limites = null,Object? activo = null,Object? creadoEn = null,}) {
  return _then(_Plan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,nombre: null == nombre ? _self.nombre : nombre // ignore: cast_nullable_to_non_nullable
as String,precioMensualCentimos: null == precioMensualCentimos ? _self.precioMensualCentimos : precioMensualCentimos // ignore: cast_nullable_to_non_nullable
as int,moneda: null == moneda ? _self.moneda : moneda // ignore: cast_nullable_to_non_nullable
as String,limites: null == limites ? _self._limites : limites // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,activo: null == activo ? _self.activo : activo // ignore: cast_nullable_to_non_nullable
as bool,creadoEn: null == creadoEn ? _self.creadoEn : creadoEn // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
