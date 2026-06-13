import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_model.freezed.dart';
part 'email_model.g.dart';

@freezed
abstract class EmailModel with _$EmailModel {
  const factory EmailModel({
    required String id,
    required String sender,
    required String subject,
    required String bodyText,
    required String bodyHtml,
    required String category,
    required bool isRead,
    required DateTime receivedAt,
    String? securityAnalysis,
    int? securityScore,
    String? sentiment,
  }) = _EmailModel;

  factory EmailModel.fromJson(Map<String, dynamic> json) => _$EmailModelFromJson(json);
}
