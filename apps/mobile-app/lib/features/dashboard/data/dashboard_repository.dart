import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ApiClient());
});

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository(this._apiClient);

  Future<DashboardStats> getStats() async {
    final json = await _apiClient.get('/api/dashboard/stats');
    return DashboardStats.fromJson(json as Map<String, dynamic>);
  }

  Future<List<OtpEntry>> getRecentOtps({String searchQuery = '', String? accountId, int page = 1, int limit = 10}) async {
    final params = <String>[];
    if (searchQuery.isNotEmpty) params.add('search=${Uri.encodeComponent(searchQuery)}');
    if (accountId != null) params.add('accountId=${Uri.encodeComponent(accountId)}');
    params.add('page=$page');
    params.add('limit=$limit');
    
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final json = await _apiClient.get('/api/dashboard/recent-otps$query');
    final list = json as List<dynamic>;
    return list.map((item) => OtpEntry.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<EmailEntry>> getRecentEmails({String searchQuery = '', String? accountId, int page = 1, int limit = 20}) async {
    final params = <String>[];
    if (searchQuery.isNotEmpty) params.add('search=${Uri.encodeComponent(searchQuery)}');
    if (accountId != null) params.add('accountId=${Uri.encodeComponent(accountId)}');
    params.add('page=$page');
    params.add('limit=$limit');
    
    final query = params.isNotEmpty ? '?${params.join('&')}' : '';
    final json = await _apiClient.get('/api/dashboard/recent-emails$query');
    final list = json as List<dynamic>;
    return list.map((item) => EmailEntry.fromJson(item as Map<String, dynamic>)).toList();
  }
}
