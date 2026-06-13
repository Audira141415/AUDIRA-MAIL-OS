// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmailModel _$EmailModelFromJson(Map<String, dynamic> json) => _EmailModel(
  id: json['id'] as String,
  sender: json['sender'] as String,
  subject: json['subject'] as String,
  bodyText: json['bodyText'] as String,
  bodyHtml: json['bodyHtml'] as String,
  category: json['category'] as String,
  isRead: json['isRead'] as bool,
  receivedAt: DateTime.parse(json['receivedAt'] as String),
  securityAnalysis: json['securityAnalysis'] as String?,
  securityScore: (json['securityScore'] as num?)?.toInt(),
  sentiment: json['sentiment'] as String?,
);

Map<String, dynamic> _$EmailModelToJson(_EmailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'subject': instance.subject,
      'bodyText': instance.bodyText,
      'bodyHtml': instance.bodyHtml,
      'category': instance.category,
      'isRead': instance.isRead,
      'receivedAt': instance.receivedAt.toIso8601String(),
      'securityAnalysis': instance.securityAnalysis,
      'securityScore': instance.securityScore,
      'sentiment': instance.sentiment,
    };
