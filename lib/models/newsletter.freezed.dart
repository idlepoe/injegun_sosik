// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'newsletter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Newsletter {

 String get articleSeq; String get title; String? get thumbnailUrl; String? get pdfStorageUrl; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Newsletter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewsletterCopyWith<Newsletter> get copyWith => _$NewsletterCopyWithImpl<Newsletter>(this as Newsletter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Newsletter&&(identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.pdfStorageUrl, pdfStorageUrl) || other.pdfStorageUrl == pdfStorageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,articleSeq,title,thumbnailUrl,pdfStorageUrl,createdAt,updatedAt);

@override
String toString() {
  return 'Newsletter(articleSeq: $articleSeq, title: $title, thumbnailUrl: $thumbnailUrl, pdfStorageUrl: $pdfStorageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $NewsletterCopyWith<$Res>  {
  factory $NewsletterCopyWith(Newsletter value, $Res Function(Newsletter) _then) = _$NewsletterCopyWithImpl;
@useResult
$Res call({
 String articleSeq, String title, String? thumbnailUrl, String? pdfStorageUrl, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$NewsletterCopyWithImpl<$Res>
    implements $NewsletterCopyWith<$Res> {
  _$NewsletterCopyWithImpl(this._self, this._then);

  final Newsletter _self;
  final $Res Function(Newsletter) _then;

/// Create a copy of Newsletter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? articleSeq = null,Object? title = null,Object? thumbnailUrl = freezed,Object? pdfStorageUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
articleSeq: null == articleSeq ? _self.articleSeq : articleSeq // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,pdfStorageUrl: freezed == pdfStorageUrl ? _self.pdfStorageUrl : pdfStorageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Newsletter].
extension NewsletterPatterns on Newsletter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Newsletter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Newsletter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Newsletter value)  $default,){
final _that = this;
switch (_that) {
case _Newsletter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Newsletter value)?  $default,){
final _that = this;
switch (_that) {
case _Newsletter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String articleSeq,  String title,  String? thumbnailUrl,  String? pdfStorageUrl,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Newsletter() when $default != null:
return $default(_that.articleSeq,_that.title,_that.thumbnailUrl,_that.pdfStorageUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String articleSeq,  String title,  String? thumbnailUrl,  String? pdfStorageUrl,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Newsletter():
return $default(_that.articleSeq,_that.title,_that.thumbnailUrl,_that.pdfStorageUrl,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String articleSeq,  String title,  String? thumbnailUrl,  String? pdfStorageUrl,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Newsletter() when $default != null:
return $default(_that.articleSeq,_that.title,_that.thumbnailUrl,_that.pdfStorageUrl,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Newsletter implements Newsletter {
  const _Newsletter({required this.articleSeq, required this.title, this.thumbnailUrl, this.pdfStorageUrl, this.createdAt, this.updatedAt});
  

@override final  String articleSeq;
@override final  String title;
@override final  String? thumbnailUrl;
@override final  String? pdfStorageUrl;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Newsletter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewsletterCopyWith<_Newsletter> get copyWith => __$NewsletterCopyWithImpl<_Newsletter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Newsletter&&(identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq)&&(identical(other.title, title) || other.title == title)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.pdfStorageUrl, pdfStorageUrl) || other.pdfStorageUrl == pdfStorageUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,articleSeq,title,thumbnailUrl,pdfStorageUrl,createdAt,updatedAt);

@override
String toString() {
  return 'Newsletter(articleSeq: $articleSeq, title: $title, thumbnailUrl: $thumbnailUrl, pdfStorageUrl: $pdfStorageUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$NewsletterCopyWith<$Res> implements $NewsletterCopyWith<$Res> {
  factory _$NewsletterCopyWith(_Newsletter value, $Res Function(_Newsletter) _then) = __$NewsletterCopyWithImpl;
@override @useResult
$Res call({
 String articleSeq, String title, String? thumbnailUrl, String? pdfStorageUrl, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$NewsletterCopyWithImpl<$Res>
    implements _$NewsletterCopyWith<$Res> {
  __$NewsletterCopyWithImpl(this._self, this._then);

  final _Newsletter _self;
  final $Res Function(_Newsletter) _then;

/// Create a copy of Newsletter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? articleSeq = null,Object? title = null,Object? thumbnailUrl = freezed,Object? pdfStorageUrl = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Newsletter(
articleSeq: null == articleSeq ? _self.articleSeq : articleSeq // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,pdfStorageUrl: freezed == pdfStorageUrl ? _self.pdfStorageUrl : pdfStorageUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
