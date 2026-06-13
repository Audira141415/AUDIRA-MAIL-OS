// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxController)
final inboxControllerProvider = InboxControllerProvider._();

final class InboxControllerProvider
    extends $AsyncNotifierProvider<InboxController, List<EmailModel>> {
  InboxControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxControllerHash();

  @$internal
  @override
  InboxController create() => InboxController();
}

String _$inboxControllerHash() => r'15e87198d17de3583c638f85febe6a54668d92a6';

abstract class _$InboxController extends $AsyncNotifier<List<EmailModel>> {
  FutureOr<List<EmailModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<EmailModel>>, List<EmailModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<EmailModel>>, List<EmailModel>>,
              AsyncValue<List<EmailModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
