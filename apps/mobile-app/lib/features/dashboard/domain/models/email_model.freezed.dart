// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmailModel {

 String get id; String get sender; String get subject; String get bodyText; String get bodyHtml; String get category; bool get isRead; DateTime get receivedAt; String? get securityAnalysis; int? get securityScore; String? get sentiment;
/// Create a copy of EmailModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailModelCopyWith<EmailModel> get copyWith => _$EmailModelCopyWithImpl<EmailModel>(this as EmailModel, _$identity);

  /// Serializes this EmailModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.bodyHtml, bodyHtml) || other.bodyHtml == bodyHtml)&&(identical(other.category, category) || other.category == category)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.securityAnalysis, securityAnalysis) || other.securityAnalysis == securityAnalysis)&&(identical(other.securityScore, securityScore) || other.securityScore == securityScore)&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sender,subject,bodyText,bodyHtml,category,isRead,receivedAt,securityAnalysis,securityScore,sentiment);

@override
String toString() {
  return 'EmailModel(id: $id, sender: $sender, subject: $subject, bodyText: $bodyText, bodyHtml: $bodyHtml, category: $category, isRead: $isRead, receivedAt: $receivedAt, securityAnalysis: $securityAnalysis, securityScore: $securityScore, sentiment: $sentiment)';
}


}

/// @nodoc
abstract mixin class $EmailModelCopyWith<$Res>  {
  factory $EmailModelCopyWith(EmailModel value, $Res Function(EmailModel) _then) = _$EmailModelCopyWithImpl;
@useResult
$Res call({
 String id, String sender, String subject, String bodyText, String bodyHtml, String category, bool isRead, DateTime receivedAt, String? securityAnalysis, int? securityScore, String? sentiment
});




}
/// @nodoc
class _$EmailModelCopyWithImpl<$Res>
    implements $EmailModelCopyWith<$Res> {
  _$EmailModelCopyWithImpl(this._self, this._then);

  final EmailModel _self;
  final $Res Function(EmailModel) _then;

/// Create a copy of EmailModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sender = null,Object? subject = null,Object? bodyText = null,Object? bodyHtml = null,Object? category = null,Object? isRead = null,Object? receivedAt = null,Object? securityAnalysis = freezed,Object? securityScore = freezed,Object? sentiment = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,bodyHtml: null == bodyHtml ? _self.bodyHtml : bodyHtml // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,securityAnalysis: freezed == securityAnalysis ? _self.securityAnalysis : securityAnalysis // ignore: cast_nullable_to_non_nullable
as String?,securityScore: freezed == securityScore ? _self.securityScore : securityScore // ignore: cast_nullable_to_non_nullable
as int?,sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmailModel].
extension EmailModelPatterns on EmailModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmailModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmailModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmailModel value)  $default,){
final _that = this;
switch (_that) {
case _EmailModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmailModel value)?  $default,){
final _that = this;
switch (_that) {
case _EmailModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sender,  String subject,  String bodyText,  String bodyHtml,  String category,  bool isRead,  DateTime receivedAt,  String? securityAnalysis,  int? securityScore,  String? sentiment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmailModel() when $default != null:
return $default(_that.id,_that.sender,_that.subject,_that.bodyText,_that.bodyHtml,_that.category,_that.isRead,_that.receivedAt,_that.securityAnalysis,_that.securityScore,_that.sentiment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sender,  String subject,  String bodyText,  String bodyHtml,  String category,  bool isRead,  DateTime receivedAt,  String? securityAnalysis,  int? securityScore,  String? sentiment)  $default,) {final _that = this;
switch (_that) {
case _EmailModel():
return $default(_that.id,_that.sender,_that.subject,_that.bodyText,_that.bodyHtml,_that.category,_that.isRead,_that.receivedAt,_that.securityAnalysis,_that.securityScore,_that.sentiment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sender,  String subject,  String bodyText,  String bodyHtml,  String category,  bool isRead,  DateTime receivedAt,  String? securityAnalysis,  int? securityScore,  String? sentiment)?  $default,) {final _that = this;
switch (_that) {
case _EmailModel() when $default != null:
return $default(_that.id,_that.sender,_that.subject,_that.bodyText,_that.bodyHtml,_that.category,_that.isRead,_that.receivedAt,_that.securityAnalysis,_that.securityScore,_that.sentiment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmailModel implements EmailModel {
  const _EmailModel({required this.id, required this.sender, required this.subject, required this.bodyText, required this.bodyHtml, required this.category, required this.isRead, required this.receivedAt, this.securityAnalysis, this.securityScore, this.sentiment});
  factory _EmailModel.fromJson(Map<String, dynamic> json) => _$EmailModelFromJson(json);

@override final  String id;
@override final  String sender;
@override final  String subject;
@override final  String bodyText;
@override final  String bodyHtml;
@override final  String category;
@override final  bool isRead;
@override final  DateTime receivedAt;
@override final  String? securityAnalysis;
@override final  int? securityScore;
@override final  String? sentiment;

/// Create a copy of EmailModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmailModelCopyWith<_EmailModel> get copyWith => __$EmailModelCopyWithImpl<_EmailModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmailModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmailModel&&(identical(other.id, id) || other.id == id)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.subject, subject) || other.subject == subject)&&(identical(other.bodyText, bodyText) || other.bodyText == bodyText)&&(identical(other.bodyHtml, bodyHtml) || other.bodyHtml == bodyHtml)&&(identical(other.category, category) || other.category == category)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt)&&(identical(other.securityAnalysis, securityAnalysis) || other.securityAnalysis == securityAnalysis)&&(identical(other.securityScore, securityScore) || other.securityScore == securityScore)&&(identical(other.sentiment, sentiment) || other.sentiment == sentiment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sender,subject,bodyText,bodyHtml,category,isRead,receivedAt,securityAnalysis,securityScore,sentiment);

@override
String toString() {
  return 'EmailModel(id: $id, sender: $sender, subject: $subject, bodyText: $bodyText, bodyHtml: $bodyHtml, category: $category, isRead: $isRead, receivedAt: $receivedAt, securityAnalysis: $securityAnalysis, securityScore: $securityScore, sentiment: $sentiment)';
}


}

/// @nodoc
abstract mixin class _$EmailModelCopyWith<$Res> implements $EmailModelCopyWith<$Res> {
  factory _$EmailModelCopyWith(_EmailModel value, $Res Function(_EmailModel) _then) = __$EmailModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String sender, String subject, String bodyText, String bodyHtml, String category, bool isRead, DateTime receivedAt, String? securityAnalysis, int? securityScore, String? sentiment
});




}
/// @nodoc
class __$EmailModelCopyWithImpl<$Res>
    implements _$EmailModelCopyWith<$Res> {
  __$EmailModelCopyWithImpl(this._self, this._then);

  final _EmailModel _self;
  final $Res Function(_EmailModel) _then;

/// Create a copy of EmailModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sender = null,Object? subject = null,Object? bodyText = null,Object? bodyHtml = null,Object? category = null,Object? isRead = null,Object? receivedAt = null,Object? securityAnalysis = freezed,Object? securityScore = freezed,Object? sentiment = freezed,}) {
  return _then(_EmailModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sender: null == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String,subject: null == subject ? _self.subject : subject // ignore: cast_nullable_to_non_nullable
as String,bodyText: null == bodyText ? _self.bodyText : bodyText // ignore: cast_nullable_to_non_nullable
as String,bodyHtml: null == bodyHtml ? _self.bodyHtml : bodyHtml // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,securityAnalysis: freezed == securityAnalysis ? _self.securityAnalysis : securityAnalysis // ignore: cast_nullable_to_non_nullable
as String?,securityScore: freezed == securityScore ? _self.securityScore : securityScore // ignore: cast_nullable_to_non_nullable
as int?,sentiment: freezed == sentiment ? _self.sentiment : sentiment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
