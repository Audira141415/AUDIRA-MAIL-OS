import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  String get baseUrl {
    // Gunakan 10.0.2.2 untuk Android Emulator agar bisa mengakses localhost host PC
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3311';
    }
    // Jika dijalankan di Windows/Web, gunakan localhost
    return 'http://localhost:3311';
  }

  Future<Map<String, String>> _getHeaders({String? overrideToken}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = overrideToken ?? prefs.getString('access_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, String? overrideToken}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(overrideToken: overrideToken);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    try {
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.body.isEmpty) return null;
    
    final decodedJson = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedJson;
    } else {
      throw Exception(decodedJson['message'] ?? 'API Request failed');
    }
  }
}
