import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/shared_prefs_provider.dart';
import '../../data/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final token = prefs.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  Future<void> login(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    final token = await repo.login(email, password);
    
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('access_token', token);
    
    state = true;
  }

  Future<void> register(String email, String password, String name) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.register(email, password, name);
    // Auto login after register
    await login(email, password);
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('access_token');
    state = false;
  }
}
