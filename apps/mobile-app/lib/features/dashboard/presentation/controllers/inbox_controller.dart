import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/inbox_repository.dart';
import '../../domain/models/email_model.dart';

part 'inbox_controller.g.dart';

@riverpod
class InboxController extends _$InboxController {
  @override
  FutureOr<List<EmailModel>> build() async {
    return _fetchEmails();
  }

  Future<List<EmailModel>> _fetchEmails() async {
    final repo = ref.watch(inboxRepositoryProvider);
    return repo.fetchRecentEmails();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchEmails());
  }
}
