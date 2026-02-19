// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Attachment {

/// 첨부 다운로드 URL (상대 경로 또는 절대 경로)
 String get attachmentUrl;/// 첨부 파일명
 String get attachmentName;/// 첨부 fileSeq
 String? get fileSeq;
/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentCopyWith<Attachment> get copyWith => _$AttachmentCopyWithImpl<Attachment>(this as Attachment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl)&&(identical(other.attachmentName, attachmentName) || other.attachmentName == attachmentName)&&(identical(other.fileSeq, fileSeq) || other.fileSeq == fileSeq));
}


@override
int get hashCode => Object.hash(runtimeType,attachmentUrl,attachmentName,fileSeq);

@override
String toString() {
  return 'Attachment(attachmentUrl: $attachmentUrl, attachmentName: $attachmentName, fileSeq: $fileSeq)';
}


}

/// @nodoc
abstract mixin class $AttachmentCopyWith<$Res>  {
  factory $AttachmentCopyWith(Attachment value, $Res Function(Attachment) _then) = _$AttachmentCopyWithImpl;
@useResult
$Res call({
 String attachmentUrl, String attachmentName, String? fileSeq
});




}
/// @nodoc
class _$AttachmentCopyWithImpl<$Res>
    implements $AttachmentCopyWith<$Res> {
  _$AttachmentCopyWithImpl(this._self, this._then);

  final Attachment _self;
  final $Res Function(Attachment) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attachmentUrl = null,Object? attachmentName = null,Object? fileSeq = freezed,}) {
  return _then(_self.copyWith(
attachmentUrl: null == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String,attachmentName: null == attachmentName ? _self.attachmentName : attachmentName // ignore: cast_nullable_to_non_nullable
as String,fileSeq: freezed == fileSeq ? _self.fileSeq : fileSeq // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Attachment].
extension AttachmentPatterns on Attachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Attachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Attachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Attachment value)  $default,){
final _that = this;
switch (_that) {
case _Attachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Attachment value)?  $default,){
final _that = this;
switch (_that) {
case _Attachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String attachmentUrl,  String attachmentName,  String? fileSeq)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Attachment() when $default != null:
return $default(_that.attachmentUrl,_that.attachmentName,_that.fileSeq);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String attachmentUrl,  String attachmentName,  String? fileSeq)  $default,) {final _that = this;
switch (_that) {
case _Attachment():
return $default(_that.attachmentUrl,_that.attachmentName,_that.fileSeq);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String attachmentUrl,  String attachmentName,  String? fileSeq)?  $default,) {final _that = this;
switch (_that) {
case _Attachment() when $default != null:
return $default(_that.attachmentUrl,_that.attachmentName,_that.fileSeq);case _:
  return null;

}
}

}

/// @nodoc


class _Attachment implements Attachment {
  const _Attachment({required this.attachmentUrl, required this.attachmentName, this.fileSeq});
  

/// 첨부 다운로드 URL (상대 경로 또는 절대 경로)
@override final  String attachmentUrl;
/// 첨부 파일명
@override final  String attachmentName;
/// 첨부 fileSeq
@override final  String? fileSeq;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentCopyWith<_Attachment> get copyWith => __$AttachmentCopyWithImpl<_Attachment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Attachment&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl)&&(identical(other.attachmentName, attachmentName) || other.attachmentName == attachmentName)&&(identical(other.fileSeq, fileSeq) || other.fileSeq == fileSeq));
}


@override
int get hashCode => Object.hash(runtimeType,attachmentUrl,attachmentName,fileSeq);

@override
String toString() {
  return 'Attachment(attachmentUrl: $attachmentUrl, attachmentName: $attachmentName, fileSeq: $fileSeq)';
}


}

/// @nodoc
abstract mixin class _$AttachmentCopyWith<$Res> implements $AttachmentCopyWith<$Res> {
  factory _$AttachmentCopyWith(_Attachment value, $Res Function(_Attachment) _then) = __$AttachmentCopyWithImpl;
@override @useResult
$Res call({
 String attachmentUrl, String attachmentName, String? fileSeq
});




}
/// @nodoc
class __$AttachmentCopyWithImpl<$Res>
    implements _$AttachmentCopyWith<$Res> {
  __$AttachmentCopyWithImpl(this._self, this._then);

  final _Attachment _self;
  final $Res Function(_Attachment) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attachmentUrl = null,Object? attachmentName = null,Object? fileSeq = freezed,}) {
  return _then(_Attachment(
attachmentUrl: null == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String,attachmentName: null == attachmentName ? _self.attachmentName : attachmentName // ignore: cast_nullable_to_non_nullable
as String,fileSeq: freezed == fileSeq ? _self.fileSeq : fileSeq // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$Article {

/// 게시글 타입 ("weekschedule" | "notice")
 String get type;/// 상세 페이지 URL
 String? get url;/// 글 번호 (상세 진입 키)
 String get articleSeq;/// 게시판 코드
 String? get boardCode;/// 제목
 String get title;/// 작성자
 String get author;/// 등록일 (YYYY-MM-DD)
 String get registeredAt;/// 본문 (HTML 포함)
 String get content;/// 첨부파일 리스트
 List<Attachment> get attachments;
/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArticleCopyWith<Article> get copyWith => _$ArticleCopyWithImpl<Article>(this as Article, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Article&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq)&&(identical(other.boardCode, boardCode) || other.boardCode == boardCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}


@override
int get hashCode => Object.hash(runtimeType,type,url,articleSeq,boardCode,title,author,registeredAt,content,const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'Article(type: $type, url: $url, articleSeq: $articleSeq, boardCode: $boardCode, title: $title, author: $author, registeredAt: $registeredAt, content: $content, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $ArticleCopyWith<$Res>  {
  factory $ArticleCopyWith(Article value, $Res Function(Article) _then) = _$ArticleCopyWithImpl;
@useResult
$Res call({
 String type, String? url, String articleSeq, String? boardCode, String title, String author, String registeredAt, String content, List<Attachment> attachments
});




}
/// @nodoc
class _$ArticleCopyWithImpl<$Res>
    implements $ArticleCopyWith<$Res> {
  _$ArticleCopyWithImpl(this._self, this._then);

  final Article _self;
  final $Res Function(Article) _then;

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? url = freezed,Object? articleSeq = null,Object? boardCode = freezed,Object? title = null,Object? author = null,Object? registeredAt = null,Object? content = null,Object? attachments = null,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,articleSeq: null == articleSeq ? _self.articleSeq : articleSeq // ignore: cast_nullable_to_non_nullable
as String,boardCode: freezed == boardCode ? _self.boardCode : boardCode // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,
  ));
}

}


/// Adds pattern-matching-related methods to [Article].
extension ArticlePatterns on Article {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Article value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Article() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Article value)  $default,){
final _that = this;
switch (_that) {
case _Article():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Article value)?  $default,){
final _that = this;
switch (_that) {
case _Article() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? url,  String articleSeq,  String? boardCode,  String title,  String author,  String registeredAt,  String content,  List<Attachment> attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that.type,_that.url,_that.articleSeq,_that.boardCode,_that.title,_that.author,_that.registeredAt,_that.content,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? url,  String articleSeq,  String? boardCode,  String title,  String author,  String registeredAt,  String content,  List<Attachment> attachments)  $default,) {final _that = this;
switch (_that) {
case _Article():
return $default(_that.type,_that.url,_that.articleSeq,_that.boardCode,_that.title,_that.author,_that.registeredAt,_that.content,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? url,  String articleSeq,  String? boardCode,  String title,  String author,  String registeredAt,  String content,  List<Attachment> attachments)?  $default,) {final _that = this;
switch (_that) {
case _Article() when $default != null:
return $default(_that.type,_that.url,_that.articleSeq,_that.boardCode,_that.title,_that.author,_that.registeredAt,_that.content,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc


class _Article implements Article {
  const _Article({required this.type, this.url, required this.articleSeq, this.boardCode, required this.title, required this.author, required this.registeredAt, required this.content, final  List<Attachment> attachments = const []}): _attachments = attachments;
  

/// 게시글 타입 ("weekschedule" | "notice")
@override final  String type;
/// 상세 페이지 URL
@override final  String? url;
/// 글 번호 (상세 진입 키)
@override final  String articleSeq;
/// 게시판 코드
@override final  String? boardCode;
/// 제목
@override final  String title;
/// 작성자
@override final  String author;
/// 등록일 (YYYY-MM-DD)
@override final  String registeredAt;
/// 본문 (HTML 포함)
@override final  String content;
/// 첨부파일 리스트
 final  List<Attachment> _attachments;
/// 첨부파일 리스트
@override@JsonKey() List<Attachment> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}


/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArticleCopyWith<_Article> get copyWith => __$ArticleCopyWithImpl<_Article>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Article&&(identical(other.type, type) || other.type == type)&&(identical(other.url, url) || other.url == url)&&(identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq)&&(identical(other.boardCode, boardCode) || other.boardCode == boardCode)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}


@override
int get hashCode => Object.hash(runtimeType,type,url,articleSeq,boardCode,title,author,registeredAt,content,const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'Article(type: $type, url: $url, articleSeq: $articleSeq, boardCode: $boardCode, title: $title, author: $author, registeredAt: $registeredAt, content: $content, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$ArticleCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$ArticleCopyWith(_Article value, $Res Function(_Article) _then) = __$ArticleCopyWithImpl;
@override @useResult
$Res call({
 String type, String? url, String articleSeq, String? boardCode, String title, String author, String registeredAt, String content, List<Attachment> attachments
});




}
/// @nodoc
class __$ArticleCopyWithImpl<$Res>
    implements _$ArticleCopyWith<$Res> {
  __$ArticleCopyWithImpl(this._self, this._then);

  final _Article _self;
  final $Res Function(_Article) _then;

/// Create a copy of Article
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? url = freezed,Object? articleSeq = null,Object? boardCode = freezed,Object? title = null,Object? author = null,Object? registeredAt = null,Object? content = null,Object? attachments = null,}) {
  return _then(_Article(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,articleSeq: null == articleSeq ? _self.articleSeq : articleSeq // ignore: cast_nullable_to_non_nullable
as String,boardCode: freezed == boardCode ? _self.boardCode : boardCode // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<Attachment>,
  ));
}


}

// dart format on
