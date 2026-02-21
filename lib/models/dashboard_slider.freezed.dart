// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_slider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardSliderItem {
  String get imageUrl;
  String get imageAlt;
  String get title;
  String? get linkUrl;
  String? get articleSeq;
  String? get dataSeq;
  int get order;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DashboardSliderItemCopyWith<DashboardSliderItem> get copyWith =>
      _$DashboardSliderItemCopyWithImpl<DashboardSliderItem>(this as DashboardSliderItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DashboardSliderItem &&
            (identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl) &&
            (identical(other.imageAlt, imageAlt) || other.imageAlt == imageAlt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl) &&
            (identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq) &&
            (identical(other.dataSeq, dataSeq) || other.dataSeq == dataSeq) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imageUrl, imageAlt, title, linkUrl, articleSeq, dataSeq, order);

  @override
  String toString() =>
      'DashboardSliderItem(imageUrl: $imageUrl, imageAlt: $imageAlt, title: $title, linkUrl: $linkUrl, articleSeq: $articleSeq, dataSeq: $dataSeq, order: $order)';
}

/// @nodoc
abstract mixin class $DashboardSliderItemCopyWith<$Res> {
  factory $DashboardSliderItemCopyWith(DashboardSliderItem value, $Res Function(DashboardSliderItem) then) =
      _$DashboardSliderItemCopyWithImpl<$Res>;

  @useResult
  $Res call(
      {String imageUrl, String imageAlt, String title, String? linkUrl, String? articleSeq, String? dataSeq, int order});
}

/// @nodoc
class _$DashboardSliderItemCopyWithImpl<$Res> implements $DashboardSliderItemCopyWith<$Res> {
  _$DashboardSliderItemCopyWithImpl(this._self, this._then);

  final DashboardSliderItem _self;
  final $Res Function(DashboardSliderItem) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imageUrl = null,
    Object? imageAlt = null,
    Object? title = null,
    Object? linkUrl = freezed,
    Object? articleSeq = freezed,
    Object? dataSeq = freezed,
    Object? order = null,
  }) {
    return _then(_self.copyWith(
      imageUrl: null == imageUrl ? _self.imageUrl : imageUrl as String,
      imageAlt: null == imageAlt ? _self.imageAlt : imageAlt as String,
      title: null == title ? _self.title : title as String,
      linkUrl: freezed == linkUrl ? _self.linkUrl : linkUrl as String?,
      articleSeq: freezed == articleSeq ? _self.articleSeq : articleSeq as String?,
      dataSeq: freezed == dataSeq ? _self.dataSeq : dataSeq as String?,
      order: null == order ? _self.order : order as int,
    ));
  }
}

/// @nodoc
abstract mixin class _$DashboardSliderItemCopyWith<$Res> implements $DashboardSliderItemCopyWith<$Res> {
  factory _$DashboardSliderItemCopyWith(_DashboardSliderItem value, $Res Function(_DashboardSliderItem) then) =
      __$DashboardSliderItemCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call(
      {String imageUrl, String imageAlt, String title, String? linkUrl, String? articleSeq, String? dataSeq, int order});
}

/// @nodoc
class __$DashboardSliderItemCopyWithImpl<$Res> extends _$DashboardSliderItemCopyWithImpl<$Res>
    implements _$DashboardSliderItemCopyWith<$Res> {
  __$DashboardSliderItemCopyWithImpl(this._self, this._thenCallback)
      : super(_self, _thenCallback as $Res Function(DashboardSliderItem));

  final _DashboardSliderItem _self;
  final $Res Function(_DashboardSliderItem) _thenCallback;

  @override
  $Res call({
    Object? imageUrl = null,
    Object? imageAlt = null,
    Object? title = null,
    Object? linkUrl = freezed,
    Object? articleSeq = freezed,
    Object? dataSeq = freezed,
    Object? order = null,
  }) {
    return _thenCallback(_DashboardSliderItem(
      imageUrl: null == imageUrl ? _self.imageUrl : imageUrl as String,
      imageAlt: null == imageAlt ? _self.imageAlt : imageAlt as String,
      title: null == title ? _self.title : title as String,
      linkUrl: freezed == linkUrl ? _self.linkUrl : linkUrl as String?,
      articleSeq: freezed == articleSeq ? _self.articleSeq : articleSeq as String?,
      dataSeq: freezed == dataSeq ? _self.dataSeq : dataSeq as String?,
      order: null == order ? _self.order : order as int,
    ));
  }
}

class _DashboardSliderItem implements DashboardSliderItem {
  const _DashboardSliderItem(
      {required this.imageUrl,
      required this.imageAlt,
      required this.title,
      required this.linkUrl,
      this.articleSeq,
      this.dataSeq,
      required this.order});

  @override
  final String imageUrl;
  @override
  final String imageAlt;
  @override
  final String title;
  @override
  final String? linkUrl;
  @override
  final String? articleSeq;
  @override
  final String? dataSeq;
  @override
  final int order;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DashboardSliderItemCopyWith<_DashboardSliderItem> get copyWith =>
      __$DashboardSliderItemCopyWithImpl<_DashboardSliderItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is _DashboardSliderItem &&
            (identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl) &&
            (identical(other.imageAlt, imageAlt) || other.imageAlt == imageAlt) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl) &&
            (identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq) &&
            (identical(other.dataSeq, dataSeq) || other.dataSeq == dataSeq) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imageUrl, imageAlt, title, linkUrl, articleSeq, dataSeq, order);

  @override
  String toString() =>
      'DashboardSliderItem(imageUrl: $imageUrl, imageAlt: $imageAlt, title: $title, linkUrl: $linkUrl, articleSeq: $articleSeq, dataSeq: $dataSeq, order: $order)';
}
