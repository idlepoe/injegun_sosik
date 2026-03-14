// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_slider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardSliderItem {

/// 이미지 절대 URL
 String get imageUrl;/// 이미지 alt 텍스트
 String get imageAlt;/// 제목 (div.hidden_txt, 없으면 imageAlt)
 String get title;/// 링크 URL (아이템이 <a>일 때만, 빈/http:// 는 null)
 String? get linkUrl;/// linkUrl 쿼리 articleSeq (inje.go.kr 포함 시)
 String? get articleSeq;/// data-seq 속성
 String? get dataSeq;/// slick-cloned 제외 후 순서 (0부터)
 int get order;
/// Create a copy of DashboardSliderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSliderItemCopyWith<DashboardSliderItem> get copyWith => _$DashboardSliderItemCopyWithImpl<DashboardSliderItem>(this as DashboardSliderItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSliderItem&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageAlt, imageAlt) || other.imageAlt == imageAlt)&&(identical(other.title, title) || other.title == title)&&(identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl)&&(identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq)&&(identical(other.dataSeq, dataSeq) || other.dataSeq == dataSeq)&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode => Object.hash(runtimeType,imageUrl,imageAlt,title,linkUrl,articleSeq,dataSeq,order);

@override
String toString() {
  return 'DashboardSliderItem(imageUrl: $imageUrl, imageAlt: $imageAlt, title: $title, linkUrl: $linkUrl, articleSeq: $articleSeq, dataSeq: $dataSeq, order: $order)';
}


}

/// @nodoc
abstract mixin class $DashboardSliderItemCopyWith<$Res>  {
  factory $DashboardSliderItemCopyWith(DashboardSliderItem value, $Res Function(DashboardSliderItem) _then) = _$DashboardSliderItemCopyWithImpl;
@useResult
$Res call({
 String imageUrl, String imageAlt, String title, String? linkUrl, String? articleSeq, String? dataSeq, int order
});




}
/// @nodoc
class _$DashboardSliderItemCopyWithImpl<$Res>
    implements $DashboardSliderItemCopyWith<$Res> {
  _$DashboardSliderItemCopyWithImpl(this._self, this._then);

  final DashboardSliderItem _self;
  final $Res Function(DashboardSliderItem) _then;

/// Create a copy of DashboardSliderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? imageUrl = null,Object? imageAlt = null,Object? title = null,Object? linkUrl = freezed,Object? articleSeq = freezed,Object? dataSeq = freezed,Object? order = null,}) {
  return _then(_self.copyWith(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,imageAlt: null == imageAlt ? _self.imageAlt : imageAlt // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,linkUrl: freezed == linkUrl ? _self.linkUrl : linkUrl // ignore: cast_nullable_to_non_nullable
as String?,articleSeq: freezed == articleSeq ? _self.articleSeq : articleSeq // ignore: cast_nullable_to_non_nullable
as String?,dataSeq: freezed == dataSeq ? _self.dataSeq : dataSeq // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSliderItem].
extension DashboardSliderItemPatterns on DashboardSliderItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSliderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSliderItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSliderItem value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSliderItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSliderItem value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSliderItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String imageUrl,  String imageAlt,  String title,  String? linkUrl,  String? articleSeq,  String? dataSeq,  int order)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSliderItem() when $default != null:
return $default(_that.imageUrl,_that.imageAlt,_that.title,_that.linkUrl,_that.articleSeq,_that.dataSeq,_that.order);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String imageUrl,  String imageAlt,  String title,  String? linkUrl,  String? articleSeq,  String? dataSeq,  int order)  $default,) {final _that = this;
switch (_that) {
case _DashboardSliderItem():
return $default(_that.imageUrl,_that.imageAlt,_that.title,_that.linkUrl,_that.articleSeq,_that.dataSeq,_that.order);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String imageUrl,  String imageAlt,  String title,  String? linkUrl,  String? articleSeq,  String? dataSeq,  int order)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSliderItem() when $default != null:
return $default(_that.imageUrl,_that.imageAlt,_that.title,_that.linkUrl,_that.articleSeq,_that.dataSeq,_that.order);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSliderItem implements DashboardSliderItem {
  const _DashboardSliderItem({required this.imageUrl, required this.imageAlt, required this.title, required this.linkUrl, this.articleSeq, this.dataSeq, required this.order});
  

/// 이미지 절대 URL
@override final  String imageUrl;
/// 이미지 alt 텍스트
@override final  String imageAlt;
/// 제목 (div.hidden_txt, 없으면 imageAlt)
@override final  String title;
/// 링크 URL (아이템이 <a>일 때만, 빈/http:// 는 null)
@override final  String? linkUrl;
/// linkUrl 쿼리 articleSeq (inje.go.kr 포함 시)
@override final  String? articleSeq;
/// data-seq 속성
@override final  String? dataSeq;
/// slick-cloned 제외 후 순서 (0부터)
@override final  int order;

/// Create a copy of DashboardSliderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSliderItemCopyWith<_DashboardSliderItem> get copyWith => __$DashboardSliderItemCopyWithImpl<_DashboardSliderItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSliderItem&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.imageAlt, imageAlt) || other.imageAlt == imageAlt)&&(identical(other.title, title) || other.title == title)&&(identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl)&&(identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq)&&(identical(other.dataSeq, dataSeq) || other.dataSeq == dataSeq)&&(identical(other.order, order) || other.order == order));
}


@override
int get hashCode => Object.hash(runtimeType,imageUrl,imageAlt,title,linkUrl,articleSeq,dataSeq,order);

@override
String toString() {
  return 'DashboardSliderItem(imageUrl: $imageUrl, imageAlt: $imageAlt, title: $title, linkUrl: $linkUrl, articleSeq: $articleSeq, dataSeq: $dataSeq, order: $order)';
}


}

/// @nodoc
abstract mixin class _$DashboardSliderItemCopyWith<$Res> implements $DashboardSliderItemCopyWith<$Res> {
  factory _$DashboardSliderItemCopyWith(_DashboardSliderItem value, $Res Function(_DashboardSliderItem) _then) = __$DashboardSliderItemCopyWithImpl;
@override @useResult
$Res call({
 String imageUrl, String imageAlt, String title, String? linkUrl, String? articleSeq, String? dataSeq, int order
});




}
/// @nodoc
class __$DashboardSliderItemCopyWithImpl<$Res>
    implements _$DashboardSliderItemCopyWith<$Res> {
  __$DashboardSliderItemCopyWithImpl(this._self, this._then);

  final _DashboardSliderItem _self;
  final $Res Function(_DashboardSliderItem) _then;

/// Create a copy of DashboardSliderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? imageUrl = null,Object? imageAlt = null,Object? title = null,Object? linkUrl = freezed,Object? articleSeq = freezed,Object? dataSeq = freezed,Object? order = null,}) {
  return _then(_DashboardSliderItem(
imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,imageAlt: null == imageAlt ? _self.imageAlt : imageAlt // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,linkUrl: freezed == linkUrl ? _self.linkUrl : linkUrl // ignore: cast_nullable_to_non_nullable
as String?,articleSeq: freezed == articleSeq ? _self.articleSeq : articleSeq // ignore: cast_nullable_to_non_nullable
as String?,dataSeq: freezed == dataSeq ? _self.dataSeq : dataSeq // ignore: cast_nullable_to_non_nullable
as String?,order: null == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
