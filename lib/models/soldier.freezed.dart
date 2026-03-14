// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'soldier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Soldier {

/// 행정동(구분)
 String get district;/// 업종 코드 (URL 기준)
 String get category;/// 업소명
 String get name;/// 주소
 String get address;/// 전화번호 (빈 문자열 가능)
 String get phone;/// 위도 (geocoding 성공 시만)
 double? get lat;/// 경도 (geocoding 성공 시만)
 double? get lng;/// geohash (encodeGeohash 결과, geocoding 성공 시만)
 String? get geohash;/// Google Geocoding API place_id (geocoding 성공 시만)
 String? get placeId;/// Place 사진 1장 URL (getMedia photoUri, 400x400)
 String? get photoUrl;/// 최종 반영 시각 (ISO8601 문자열, Firestore updatedAt 변환)
 String? get updatedAt;
/// Create a copy of Soldier
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SoldierCopyWith<Soldier> get copyWith => _$SoldierCopyWithImpl<Soldier>(this as Soldier, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Soldier&&(identical(other.district, district) || other.district == district)&&(identical(other.category, category) || other.category == category)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,district,category,name,address,phone,lat,lng,geohash,placeId,photoUrl,updatedAt);

@override
String toString() {
  return 'Soldier(district: $district, category: $category, name: $name, address: $address, phone: $phone, lat: $lat, lng: $lng, geohash: $geohash, placeId: $placeId, photoUrl: $photoUrl, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SoldierCopyWith<$Res>  {
  factory $SoldierCopyWith(Soldier value, $Res Function(Soldier) _then) = _$SoldierCopyWithImpl;
@useResult
$Res call({
 String district, String category, String name, String address, String phone, double? lat, double? lng, String? geohash, String? placeId, String? photoUrl, String? updatedAt
});




}
/// @nodoc
class _$SoldierCopyWithImpl<$Res>
    implements $SoldierCopyWith<$Res> {
  _$SoldierCopyWithImpl(this._self, this._then);

  final Soldier _self;
  final $Res Function(Soldier) _then;

/// Create a copy of Soldier
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? district = null,Object? category = null,Object? name = null,Object? address = null,Object? phone = null,Object? lat = freezed,Object? lng = freezed,Object? geohash = freezed,Object? placeId = freezed,Object? photoUrl = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,geohash: freezed == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Soldier].
extension SoldierPatterns on Soldier {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Soldier value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Soldier() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Soldier value)  $default,){
final _that = this;
switch (_that) {
case _Soldier():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Soldier value)?  $default,){
final _that = this;
switch (_that) {
case _Soldier() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String district,  String category,  String name,  String address,  String phone,  double? lat,  double? lng,  String? geohash,  String? placeId,  String? photoUrl,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Soldier() when $default != null:
return $default(_that.district,_that.category,_that.name,_that.address,_that.phone,_that.lat,_that.lng,_that.geohash,_that.placeId,_that.photoUrl,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String district,  String category,  String name,  String address,  String phone,  double? lat,  double? lng,  String? geohash,  String? placeId,  String? photoUrl,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Soldier():
return $default(_that.district,_that.category,_that.name,_that.address,_that.phone,_that.lat,_that.lng,_that.geohash,_that.placeId,_that.photoUrl,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String district,  String category,  String name,  String address,  String phone,  double? lat,  double? lng,  String? geohash,  String? placeId,  String? photoUrl,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Soldier() when $default != null:
return $default(_that.district,_that.category,_that.name,_that.address,_that.phone,_that.lat,_that.lng,_that.geohash,_that.placeId,_that.photoUrl,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Soldier implements Soldier {
  const _Soldier({required this.district, required this.category, required this.name, required this.address, required this.phone, this.lat, this.lng, this.geohash, this.placeId, this.photoUrl, this.updatedAt});
  

/// 행정동(구분)
@override final  String district;
/// 업종 코드 (URL 기준)
@override final  String category;
/// 업소명
@override final  String name;
/// 주소
@override final  String address;
/// 전화번호 (빈 문자열 가능)
@override final  String phone;
/// 위도 (geocoding 성공 시만)
@override final  double? lat;
/// 경도 (geocoding 성공 시만)
@override final  double? lng;
/// geohash (encodeGeohash 결과, geocoding 성공 시만)
@override final  String? geohash;
/// Google Geocoding API place_id (geocoding 성공 시만)
@override final  String? placeId;
/// Place 사진 1장 URL (getMedia photoUri, 400x400)
@override final  String? photoUrl;
/// 최종 반영 시각 (ISO8601 문자열, Firestore updatedAt 변환)
@override final  String? updatedAt;

/// Create a copy of Soldier
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SoldierCopyWith<_Soldier> get copyWith => __$SoldierCopyWithImpl<_Soldier>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Soldier&&(identical(other.district, district) || other.district == district)&&(identical(other.category, category) || other.category == category)&&(identical(other.name, name) || other.name == name)&&(identical(other.address, address) || other.address == address)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,district,category,name,address,phone,lat,lng,geohash,placeId,photoUrl,updatedAt);

@override
String toString() {
  return 'Soldier(district: $district, category: $category, name: $name, address: $address, phone: $phone, lat: $lat, lng: $lng, geohash: $geohash, placeId: $placeId, photoUrl: $photoUrl, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SoldierCopyWith<$Res> implements $SoldierCopyWith<$Res> {
  factory _$SoldierCopyWith(_Soldier value, $Res Function(_Soldier) _then) = __$SoldierCopyWithImpl;
@override @useResult
$Res call({
 String district, String category, String name, String address, String phone, double? lat, double? lng, String? geohash, String? placeId, String? photoUrl, String? updatedAt
});




}
/// @nodoc
class __$SoldierCopyWithImpl<$Res>
    implements _$SoldierCopyWith<$Res> {
  __$SoldierCopyWithImpl(this._self, this._then);

  final _Soldier _self;
  final $Res Function(_Soldier) _then;

/// Create a copy of Soldier
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? district = null,Object? category = null,Object? name = null,Object? address = null,Object? phone = null,Object? lat = freezed,Object? lng = freezed,Object? geohash = freezed,Object? placeId = freezed,Object? photoUrl = freezed,Object? updatedAt = freezed,}) {
  return _then(_Soldier(
district: null == district ? _self.district : district // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,geohash: freezed == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String?,placeId: freezed == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
