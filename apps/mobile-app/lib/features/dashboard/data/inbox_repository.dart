import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';
import '../domain/models/email_model.dart';

part 'inbox_repository.g.dart';

class InboxRepository {
  final Dio _dio;

  InboxRepository(this._dio);

  Future<List<EmailModel>> fetchRecentEmails({String search = '', String category = 'All'}) async {
    try {
      final response = await _dio.get('/dashboard/recent-emails', queryParameters: {
        'search': search,
        'category': category,
      });
      
      final List<dynamic> data = response.data;
      return data.map((json) => EmailModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch emails: $e');
    }
  }

  Future<String> draftAiReply(String subject, String bodyText) async {
    try {
      final response = await _dio.post('/copilot/analyze-sentiment', data: {
        'subject': subject,
        'body': bodyText,
      });
      return response.data['draftedReply'] ?? 'No reply generated.';
    } catch (e) {
      throw Exception('Failed to generate AI reply: $e');
    }
  }
}

@riverpod
InboxRepository inboxRepository(Ref ref) {
  return InboxRepository(ref.watch(dioClientProvider));
}
