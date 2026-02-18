// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekschedule_row.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeekScheduleRow {

 String get date; String get time; String get eventContent; String get place; String get department; String get articleSeq;
/// Create a copy of WeekScheduleRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekScheduleRowCopyWith<WeekScheduleRow> get copyWith => _$WeekScheduleRowCopyWithImpl<WeekScheduleRow>(this as WeekScheduleRow, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekScheduleRow&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.eventContent, eventContent) || other.eventContent == eventContent)&&(identical(other.place, place) || other.place == place)&&(identical(other.department, department) || other.department == department)&&(identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq));
}


@override
int get hashCode => Object.hash(runtimeType,date,time,eventContent,place,department,articleSeq);

@override
String toString() {
  return 'WeekScheduleRow(date: $date, time: $time, eventContent: $eventContent, place: $place, department: $department, articleSeq: $articleSeq)';
}


}

/// @nodoc
abstract mixin class $WeekScheduleRowCopyWith<$Res>  {
  factory $WeekScheduleRowCopyWith(WeekScheduleRow value, $Res Function(WeekScheduleRow) _then) = _$WeekScheduleRowCopyWithImpl;
@useResult
$Res call({
 String date, String time, String eventContent, String place, String department, String articleSeq
});




}
/// @nodoc
class _$WeekScheduleRowCopyWithImpl<$Res>
    implements $WeekScheduleRowCopyWith<$Res> {
  _$WeekScheduleRowCopyWithImpl(this._self, this._then);

  final WeekScheduleRow _self;
  final $Res Function(WeekScheduleRow) _then;

/// Create a copy of WeekScheduleRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? time = null,Object? eventContent = null,Object? place = null,Object? department = null,Object? articleSeq = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,eventContent: null == eventContent ? _self.eventContent : eventContent // ignore: cast_nullable_to_non_nullable
as String,place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,articleSeq: null == articleSeq ? _self.articleSeq : articleSeq // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [WeekScheduleRow].
extension WeekScheduleRowPatterns on WeekScheduleRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekScheduleRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekScheduleRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekScheduleRow value)  $default,){
final _that = this;
switch (_that) {
case _WeekScheduleRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekScheduleRow value)?  $default,){
final _that = this;
switch (_that) {
case _WeekScheduleRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  String time,  String eventContent,  String place,  String department,  String articleSeq)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekScheduleRow() when $default != null:
return $default(_that.date,_that.time,_that.eventContent,_that.place,_that.department,_that.articleSeq);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  String time,  String eventContent,  String place,  String department,  String articleSeq)  $default,) {final _that = this;
switch (_that) {
case _WeekScheduleRow():
return $default(_that.date,_that.time,_that.eventContent,_that.place,_that.department,_that.articleSeq);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  String time,  String eventContent,  String place,  String department,  String articleSeq)?  $default,) {final _that = this;
switch (_that) {
case _WeekScheduleRow() when $default != null:
return $default(_that.date,_that.time,_that.eventContent,_that.place,_that.department,_that.articleSeq);case _:
  return null;

}
}

}

/// @nodoc


class _WeekScheduleRow implements WeekScheduleRow {
  const _WeekScheduleRow({required this.date, required this.time, required this.eventContent, required this.place, required this.department, required this.articleSeq});
  

@override final  String date;
@override final  String time;
@override final  String eventContent;
@override final  String place;
@override final  String department;
@override final  String articleSeq;

/// Create a copy of WeekScheduleRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekScheduleRowCopyWith<_WeekScheduleRow> get copyWith => __$WeekScheduleRowCopyWithImpl<_WeekScheduleRow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekScheduleRow&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.eventContent, eventContent) || other.eventContent == eventContent)&&(identical(other.place, place) || other.place == place)&&(identical(other.department, department) || other.department == department)&&(identical(other.articleSeq, articleSeq) || other.articleSeq == articleSeq));
}


@override
int get hashCode => Object.hash(runtimeType,date,time,eventContent,place,department,articleSeq);

@override
String toString() {
  return 'WeekScheduleRow(date: $date, time: $time, eventContent: $eventContent, place: $place, department: $department, articleSeq: $articleSeq)';
}


}

/// @nodoc
abstract mixin class _$WeekScheduleRowCopyWith<$Res> implements $WeekScheduleRowCopyWith<$Res> {
  factory _$WeekScheduleRowCopyWith(_WeekScheduleRow value, $Res Function(_WeekScheduleRow) _then) = __$WeekScheduleRowCopyWithImpl;
@override @useResult
$Res call({
 String date, String time, String eventContent, String place, String department, String articleSeq
});




}
/// @nodoc
class __$WeekScheduleRowCopyWithImpl<$Res>
    implements _$WeekScheduleRowCopyWith<$Res> {
  __$WeekScheduleRowCopyWithImpl(this._self, this._then);

  final _WeekScheduleRow _self;
  final $Res Function(_WeekScheduleRow) _then;

/// Create a copy of WeekScheduleRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? time = null,Object? eventContent = null,Object? place = null,Object? department = null,Object? articleSeq = null,}) {
  return _then(_WeekScheduleRow(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,eventContent: null == eventContent ? _self.eventContent : eventContent // ignore: cast_nullable_to_non_nullable
as String,place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,department: null == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String,articleSeq: null == articleSeq ? _self.articleSeq : articleSeq // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
