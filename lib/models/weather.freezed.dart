// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeatherData {

// Coord 필드
 double get lon; double get lat;// WeatherCondition 필드 (첫 번째 항목만)
 int get weatherId; String get weatherMain; String get weatherDescription; String get weatherIcon;// Main 필드
 double get temp; double get feelsLike; double get tempMin; double get tempMax; int get pressure; int get humidity; int? get seaLevel; int? get grndLevel;// Wind 필드
 double get windSpeed; int get windDeg; double? get windGust;// Clouds 필드
 int get cloudsAll;// Sys 필드
 String get country; int get sunrise; int get sunset;// 기타 필드
 String get base; int get visibility; int get dt; int get timezone; int get id; String get name; int get cod;
/// Create a copy of WeatherData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherDataCopyWith<WeatherData> get copyWith => _$WeatherDataCopyWithImpl<WeatherData>(this as WeatherData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherData&&(identical(other.lon, lon) || other.lon == lon)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.weatherId, weatherId) || other.weatherId == weatherId)&&(identical(other.weatherMain, weatherMain) || other.weatherMain == weatherMain)&&(identical(other.weatherDescription, weatherDescription) || other.weatherDescription == weatherDescription)&&(identical(other.weatherIcon, weatherIcon) || other.weatherIcon == weatherIcon)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.feelsLike, feelsLike) || other.feelsLike == feelsLike)&&(identical(other.tempMin, tempMin) || other.tempMin == tempMin)&&(identical(other.tempMax, tempMax) || other.tempMax == tempMax)&&(identical(other.pressure, pressure) || other.pressure == pressure)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.seaLevel, seaLevel) || other.seaLevel == seaLevel)&&(identical(other.grndLevel, grndLevel) || other.grndLevel == grndLevel)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.windDeg, windDeg) || other.windDeg == windDeg)&&(identical(other.windGust, windGust) || other.windGust == windGust)&&(identical(other.cloudsAll, cloudsAll) || other.cloudsAll == cloudsAll)&&(identical(other.country, country) || other.country == country)&&(identical(other.sunrise, sunrise) || other.sunrise == sunrise)&&(identical(other.sunset, sunset) || other.sunset == sunset)&&(identical(other.base, base) || other.base == base)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.dt, dt) || other.dt == dt)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cod, cod) || other.cod == cod));
}


@override
int get hashCode => Object.hashAll([runtimeType,lon,lat,weatherId,weatherMain,weatherDescription,weatherIcon,temp,feelsLike,tempMin,tempMax,pressure,humidity,seaLevel,grndLevel,windSpeed,windDeg,windGust,cloudsAll,country,sunrise,sunset,base,visibility,dt,timezone,id,name,cod]);

@override
String toString() {
  return 'WeatherData(lon: $lon, lat: $lat, weatherId: $weatherId, weatherMain: $weatherMain, weatherDescription: $weatherDescription, weatherIcon: $weatherIcon, temp: $temp, feelsLike: $feelsLike, tempMin: $tempMin, tempMax: $tempMax, pressure: $pressure, humidity: $humidity, seaLevel: $seaLevel, grndLevel: $grndLevel, windSpeed: $windSpeed, windDeg: $windDeg, windGust: $windGust, cloudsAll: $cloudsAll, country: $country, sunrise: $sunrise, sunset: $sunset, base: $base, visibility: $visibility, dt: $dt, timezone: $timezone, id: $id, name: $name, cod: $cod)';
}


}

/// @nodoc
abstract mixin class $WeatherDataCopyWith<$Res>  {
  factory $WeatherDataCopyWith(WeatherData value, $Res Function(WeatherData) _then) = _$WeatherDataCopyWithImpl;
@useResult
$Res call({
 double lon, double lat, int weatherId, String weatherMain, String weatherDescription, String weatherIcon, double temp, double feelsLike, double tempMin, double tempMax, int pressure, int humidity, int? seaLevel, int? grndLevel, double windSpeed, int windDeg, double? windGust, int cloudsAll, String country, int sunrise, int sunset, String base, int visibility, int dt, int timezone, int id, String name, int cod
});




}
/// @nodoc
class _$WeatherDataCopyWithImpl<$Res>
    implements $WeatherDataCopyWith<$Res> {
  _$WeatherDataCopyWithImpl(this._self, this._then);

  final WeatherData _self;
  final $Res Function(WeatherData) _then;

/// Create a copy of WeatherData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lon = null,Object? lat = null,Object? weatherId = null,Object? weatherMain = null,Object? weatherDescription = null,Object? weatherIcon = null,Object? temp = null,Object? feelsLike = null,Object? tempMin = null,Object? tempMax = null,Object? pressure = null,Object? humidity = null,Object? seaLevel = freezed,Object? grndLevel = freezed,Object? windSpeed = null,Object? windDeg = null,Object? windGust = freezed,Object? cloudsAll = null,Object? country = null,Object? sunrise = null,Object? sunset = null,Object? base = null,Object? visibility = null,Object? dt = null,Object? timezone = null,Object? id = null,Object? name = null,Object? cod = null,}) {
  return _then(_self.copyWith(
lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,weatherId: null == weatherId ? _self.weatherId : weatherId // ignore: cast_nullable_to_non_nullable
as int,weatherMain: null == weatherMain ? _self.weatherMain : weatherMain // ignore: cast_nullable_to_non_nullable
as String,weatherDescription: null == weatherDescription ? _self.weatherDescription : weatherDescription // ignore: cast_nullable_to_non_nullable
as String,weatherIcon: null == weatherIcon ? _self.weatherIcon : weatherIcon // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as double,feelsLike: null == feelsLike ? _self.feelsLike : feelsLike // ignore: cast_nullable_to_non_nullable
as double,tempMin: null == tempMin ? _self.tempMin : tempMin // ignore: cast_nullable_to_non_nullable
as double,tempMax: null == tempMax ? _self.tempMax : tempMax // ignore: cast_nullable_to_non_nullable
as double,pressure: null == pressure ? _self.pressure : pressure // ignore: cast_nullable_to_non_nullable
as int,humidity: null == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as int,seaLevel: freezed == seaLevel ? _self.seaLevel : seaLevel // ignore: cast_nullable_to_non_nullable
as int?,grndLevel: freezed == grndLevel ? _self.grndLevel : grndLevel // ignore: cast_nullable_to_non_nullable
as int?,windSpeed: null == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double,windDeg: null == windDeg ? _self.windDeg : windDeg // ignore: cast_nullable_to_non_nullable
as int,windGust: freezed == windGust ? _self.windGust : windGust // ignore: cast_nullable_to_non_nullable
as double?,cloudsAll: null == cloudsAll ? _self.cloudsAll : cloudsAll // ignore: cast_nullable_to_non_nullable
as int,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,sunrise: null == sunrise ? _self.sunrise : sunrise // ignore: cast_nullable_to_non_nullable
as int,sunset: null == sunset ? _self.sunset : sunset // ignore: cast_nullable_to_non_nullable
as int,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,dt: null == dt ? _self.dt : dt // ignore: cast_nullable_to_non_nullable
as int,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cod: null == cod ? _self.cod : cod // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherData].
extension WeatherDataPatterns on WeatherData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherData value)  $default,){
final _that = this;
switch (_that) {
case _WeatherData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherData value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lon,  double lat,  int weatherId,  String weatherMain,  String weatherDescription,  String weatherIcon,  double temp,  double feelsLike,  double tempMin,  double tempMax,  int pressure,  int humidity,  int? seaLevel,  int? grndLevel,  double windSpeed,  int windDeg,  double? windGust,  int cloudsAll,  String country,  int sunrise,  int sunset,  String base,  int visibility,  int dt,  int timezone,  int id,  String name,  int cod)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherData() when $default != null:
return $default(_that.lon,_that.lat,_that.weatherId,_that.weatherMain,_that.weatherDescription,_that.weatherIcon,_that.temp,_that.feelsLike,_that.tempMin,_that.tempMax,_that.pressure,_that.humidity,_that.seaLevel,_that.grndLevel,_that.windSpeed,_that.windDeg,_that.windGust,_that.cloudsAll,_that.country,_that.sunrise,_that.sunset,_that.base,_that.visibility,_that.dt,_that.timezone,_that.id,_that.name,_that.cod);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lon,  double lat,  int weatherId,  String weatherMain,  String weatherDescription,  String weatherIcon,  double temp,  double feelsLike,  double tempMin,  double tempMax,  int pressure,  int humidity,  int? seaLevel,  int? grndLevel,  double windSpeed,  int windDeg,  double? windGust,  int cloudsAll,  String country,  int sunrise,  int sunset,  String base,  int visibility,  int dt,  int timezone,  int id,  String name,  int cod)  $default,) {final _that = this;
switch (_that) {
case _WeatherData():
return $default(_that.lon,_that.lat,_that.weatherId,_that.weatherMain,_that.weatherDescription,_that.weatherIcon,_that.temp,_that.feelsLike,_that.tempMin,_that.tempMax,_that.pressure,_that.humidity,_that.seaLevel,_that.grndLevel,_that.windSpeed,_that.windDeg,_that.windGust,_that.cloudsAll,_that.country,_that.sunrise,_that.sunset,_that.base,_that.visibility,_that.dt,_that.timezone,_that.id,_that.name,_that.cod);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lon,  double lat,  int weatherId,  String weatherMain,  String weatherDescription,  String weatherIcon,  double temp,  double feelsLike,  double tempMin,  double tempMax,  int pressure,  int humidity,  int? seaLevel,  int? grndLevel,  double windSpeed,  int windDeg,  double? windGust,  int cloudsAll,  String country,  int sunrise,  int sunset,  String base,  int visibility,  int dt,  int timezone,  int id,  String name,  int cod)?  $default,) {final _that = this;
switch (_that) {
case _WeatherData() when $default != null:
return $default(_that.lon,_that.lat,_that.weatherId,_that.weatherMain,_that.weatherDescription,_that.weatherIcon,_that.temp,_that.feelsLike,_that.tempMin,_that.tempMax,_that.pressure,_that.humidity,_that.seaLevel,_that.grndLevel,_that.windSpeed,_that.windDeg,_that.windGust,_that.cloudsAll,_that.country,_that.sunrise,_that.sunset,_that.base,_that.visibility,_that.dt,_that.timezone,_that.id,_that.name,_that.cod);case _:
  return null;

}
}

}

/// @nodoc


class _WeatherData implements WeatherData {
  const _WeatherData({required this.lon, required this.lat, required this.weatherId, required this.weatherMain, required this.weatherDescription, required this.weatherIcon, required this.temp, required this.feelsLike, required this.tempMin, required this.tempMax, required this.pressure, required this.humidity, this.seaLevel, this.grndLevel, required this.windSpeed, required this.windDeg, this.windGust, required this.cloudsAll, required this.country, required this.sunrise, required this.sunset, required this.base, required this.visibility, required this.dt, required this.timezone, required this.id, required this.name, required this.cod});
  

// Coord 필드
@override final  double lon;
@override final  double lat;
// WeatherCondition 필드 (첫 번째 항목만)
@override final  int weatherId;
@override final  String weatherMain;
@override final  String weatherDescription;
@override final  String weatherIcon;
// Main 필드
@override final  double temp;
@override final  double feelsLike;
@override final  double tempMin;
@override final  double tempMax;
@override final  int pressure;
@override final  int humidity;
@override final  int? seaLevel;
@override final  int? grndLevel;
// Wind 필드
@override final  double windSpeed;
@override final  int windDeg;
@override final  double? windGust;
// Clouds 필드
@override final  int cloudsAll;
// Sys 필드
@override final  String country;
@override final  int sunrise;
@override final  int sunset;
// 기타 필드
@override final  String base;
@override final  int visibility;
@override final  int dt;
@override final  int timezone;
@override final  int id;
@override final  String name;
@override final  int cod;

/// Create a copy of WeatherData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherDataCopyWith<_WeatherData> get copyWith => __$WeatherDataCopyWithImpl<_WeatherData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherData&&(identical(other.lon, lon) || other.lon == lon)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.weatherId, weatherId) || other.weatherId == weatherId)&&(identical(other.weatherMain, weatherMain) || other.weatherMain == weatherMain)&&(identical(other.weatherDescription, weatherDescription) || other.weatherDescription == weatherDescription)&&(identical(other.weatherIcon, weatherIcon) || other.weatherIcon == weatherIcon)&&(identical(other.temp, temp) || other.temp == temp)&&(identical(other.feelsLike, feelsLike) || other.feelsLike == feelsLike)&&(identical(other.tempMin, tempMin) || other.tempMin == tempMin)&&(identical(other.tempMax, tempMax) || other.tempMax == tempMax)&&(identical(other.pressure, pressure) || other.pressure == pressure)&&(identical(other.humidity, humidity) || other.humidity == humidity)&&(identical(other.seaLevel, seaLevel) || other.seaLevel == seaLevel)&&(identical(other.grndLevel, grndLevel) || other.grndLevel == grndLevel)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.windDeg, windDeg) || other.windDeg == windDeg)&&(identical(other.windGust, windGust) || other.windGust == windGust)&&(identical(other.cloudsAll, cloudsAll) || other.cloudsAll == cloudsAll)&&(identical(other.country, country) || other.country == country)&&(identical(other.sunrise, sunrise) || other.sunrise == sunrise)&&(identical(other.sunset, sunset) || other.sunset == sunset)&&(identical(other.base, base) || other.base == base)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.dt, dt) || other.dt == dt)&&(identical(other.timezone, timezone) || other.timezone == timezone)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.cod, cod) || other.cod == cod));
}


@override
int get hashCode => Object.hashAll([runtimeType,lon,lat,weatherId,weatherMain,weatherDescription,weatherIcon,temp,feelsLike,tempMin,tempMax,pressure,humidity,seaLevel,grndLevel,windSpeed,windDeg,windGust,cloudsAll,country,sunrise,sunset,base,visibility,dt,timezone,id,name,cod]);

@override
String toString() {
  return 'WeatherData(lon: $lon, lat: $lat, weatherId: $weatherId, weatherMain: $weatherMain, weatherDescription: $weatherDescription, weatherIcon: $weatherIcon, temp: $temp, feelsLike: $feelsLike, tempMin: $tempMin, tempMax: $tempMax, pressure: $pressure, humidity: $humidity, seaLevel: $seaLevel, grndLevel: $grndLevel, windSpeed: $windSpeed, windDeg: $windDeg, windGust: $windGust, cloudsAll: $cloudsAll, country: $country, sunrise: $sunrise, sunset: $sunset, base: $base, visibility: $visibility, dt: $dt, timezone: $timezone, id: $id, name: $name, cod: $cod)';
}


}

/// @nodoc
abstract mixin class _$WeatherDataCopyWith<$Res> implements $WeatherDataCopyWith<$Res> {
  factory _$WeatherDataCopyWith(_WeatherData value, $Res Function(_WeatherData) _then) = __$WeatherDataCopyWithImpl;
@override @useResult
$Res call({
 double lon, double lat, int weatherId, String weatherMain, String weatherDescription, String weatherIcon, double temp, double feelsLike, double tempMin, double tempMax, int pressure, int humidity, int? seaLevel, int? grndLevel, double windSpeed, int windDeg, double? windGust, int cloudsAll, String country, int sunrise, int sunset, String base, int visibility, int dt, int timezone, int id, String name, int cod
});




}
/// @nodoc
class __$WeatherDataCopyWithImpl<$Res>
    implements _$WeatherDataCopyWith<$Res> {
  __$WeatherDataCopyWithImpl(this._self, this._then);

  final _WeatherData _self;
  final $Res Function(_WeatherData) _then;

/// Create a copy of WeatherData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lon = null,Object? lat = null,Object? weatherId = null,Object? weatherMain = null,Object? weatherDescription = null,Object? weatherIcon = null,Object? temp = null,Object? feelsLike = null,Object? tempMin = null,Object? tempMax = null,Object? pressure = null,Object? humidity = null,Object? seaLevel = freezed,Object? grndLevel = freezed,Object? windSpeed = null,Object? windDeg = null,Object? windGust = freezed,Object? cloudsAll = null,Object? country = null,Object? sunrise = null,Object? sunset = null,Object? base = null,Object? visibility = null,Object? dt = null,Object? timezone = null,Object? id = null,Object? name = null,Object? cod = null,}) {
  return _then(_WeatherData(
lon: null == lon ? _self.lon : lon // ignore: cast_nullable_to_non_nullable
as double,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,weatherId: null == weatherId ? _self.weatherId : weatherId // ignore: cast_nullable_to_non_nullable
as int,weatherMain: null == weatherMain ? _self.weatherMain : weatherMain // ignore: cast_nullable_to_non_nullable
as String,weatherDescription: null == weatherDescription ? _self.weatherDescription : weatherDescription // ignore: cast_nullable_to_non_nullable
as String,weatherIcon: null == weatherIcon ? _self.weatherIcon : weatherIcon // ignore: cast_nullable_to_non_nullable
as String,temp: null == temp ? _self.temp : temp // ignore: cast_nullable_to_non_nullable
as double,feelsLike: null == feelsLike ? _self.feelsLike : feelsLike // ignore: cast_nullable_to_non_nullable
as double,tempMin: null == tempMin ? _self.tempMin : tempMin // ignore: cast_nullable_to_non_nullable
as double,tempMax: null == tempMax ? _self.tempMax : tempMax // ignore: cast_nullable_to_non_nullable
as double,pressure: null == pressure ? _self.pressure : pressure // ignore: cast_nullable_to_non_nullable
as int,humidity: null == humidity ? _self.humidity : humidity // ignore: cast_nullable_to_non_nullable
as int,seaLevel: freezed == seaLevel ? _self.seaLevel : seaLevel // ignore: cast_nullable_to_non_nullable
as int?,grndLevel: freezed == grndLevel ? _self.grndLevel : grndLevel // ignore: cast_nullable_to_non_nullable
as int?,windSpeed: null == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double,windDeg: null == windDeg ? _self.windDeg : windDeg // ignore: cast_nullable_to_non_nullable
as int,windGust: freezed == windGust ? _self.windGust : windGust // ignore: cast_nullable_to_non_nullable
as double?,cloudsAll: null == cloudsAll ? _self.cloudsAll : cloudsAll // ignore: cast_nullable_to_non_nullable
as int,country: null == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String,sunrise: null == sunrise ? _self.sunrise : sunrise // ignore: cast_nullable_to_non_nullable
as int,sunset: null == sunset ? _self.sunset : sunset // ignore: cast_nullable_to_non_nullable
as int,base: null == base ? _self.base : base // ignore: cast_nullable_to_non_nullable
as String,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as int,dt: null == dt ? _self.dt : dt // ignore: cast_nullable_to_non_nullable
as int,timezone: null == timezone ? _self.timezone : timezone // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,cod: null == cod ? _self.cod : cod // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
