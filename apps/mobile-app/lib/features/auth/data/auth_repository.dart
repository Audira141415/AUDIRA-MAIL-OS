import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/dio_client.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('http://10.0.2.2:3311/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['access_token'];
    } catch (e) {
      if (e is DioException && e.response != null) {
         throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      await _dio.post('http://10.0.2.2:3311/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
    } catch (e) {
      if (e is DioException && e.response != null) {
         throw Exception(e.response?.data['message'] ?? 'Registration failed');
      }
      throw Exception('Registration failed: $e');
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(ref.watch(dioClientProvider));
}
