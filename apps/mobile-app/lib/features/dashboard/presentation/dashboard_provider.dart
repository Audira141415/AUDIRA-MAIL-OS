import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../data/dashboard_repository.dart';
import '../data/dashboard_models.dart';
import '../../../../core/network/api_client.dart';

// Provider for Gmail accounts list
final gmailAccountsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final data = await ApiClient().get('/api/dashboard/gmail-accounts');
  if (data == null) return [];
  return List<Map<String, dynamic>>.from(data as List);
});

// --- Stats Provider ---
final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getStats();
});

class OtpFilter {
  final String searchQuery;
  final String? accountId;
  final int page;
  final int limit;

  OtpFilter({this.searchQuery = '', this.accountId, this.page = 1, this.limit = 10});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtpFilter &&
        other.searchQuery == searchQuery &&
        other.accountId == accountId &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(searchQuery, accountId, page, limit);
}

class EmailFilter {
  final String searchQuery;
  final String? accountId;
  final int page;
  final int limit;

  EmailFilter({this.searchQuery = '', this.accountId, this.page = 1, this.limit = 20});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmailFilter &&
        other.searchQuery == searchQuery &&
        other.accountId == accountId &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(searchQuery, accountId, page, limit);
}

class PaginationState<T> {
  final List<T> items;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  PaginationState({
    required this.items,
    required this.isLoading,
    required this.hasMore,
    required this.page,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }
}

// --- Recent OTPs Pagination Provider ---
class OtpPaginationNotifier extends Notifier<PaginationState<OtpEntry>> {
  final OtpFilter filter;
  OtpPaginationNotifier(this.filter);

  @override
  PaginationState<OtpEntry> build() {
    Future.microtask(loadMore);
    return PaginationState(items: [], isLoading: false, hasMore: true, page: 1);
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final newItems = await repo.getRecentOtps(
        searchQuery: filter.searchQuery,
        accountId: filter.accountId,
        page: state.page,
        limit: filter.limit,
      );

      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoading: false,
        hasMore: newItems.length == filter.limit,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = PaginationState(items: [], isLoading: false, hasMore: true, page: 1);
    await loadMore();
  }
}

final otpPaginationProvider = NotifierProvider.autoDispose.family<OtpPaginationNotifier, PaginationState<OtpEntry>, OtpFilter>(
  OtpPaginationNotifier.new,
);

// --- Recent Emails Pagination Provider ---
class EmailPaginationNotifier extends Notifier<PaginationState<EmailEntry>> {
  final EmailFilter filter;
  EmailPaginationNotifier(this.filter);

  @override
  PaginationState<EmailEntry> build() {
    Future.microtask(loadMore);
    return PaginationState(items: [], isLoading: false, hasMore: true, page: 1);
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final newItems = await repo.getRecentEmails(
        searchQuery: filter.searchQuery,
        accountId: filter.accountId,
        page: state.page,
        limit: filter.limit,
      );

      state = state.copyWith(
        items: [...state.items, ...newItems],
        isLoading: false,
        hasMore: newItems.length == filter.limit,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = PaginationState(items: [], isLoading: false, hasMore: true, page: 1);
    await loadMore();
  }
}

final emailPaginationProvider = NotifierProvider.autoDispose.family<EmailPaginationNotifier, PaginationState<EmailEntry>, EmailFilter>(
  EmailPaginationNotifier.new,
);

// --- Backward Compatibility for Dashboard Home Tab ---
final recentOtpsProvider = FutureProvider.family.autoDispose<List<OtpEntry>, OtpFilter>((ref, filter) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getRecentOtps(
    searchQuery: filter.searchQuery, 
    accountId: filter.accountId,
    page: filter.page,
    limit: filter.limit,
  );
});

final recentEmailsProvider = FutureProvider.family.autoDispose<List<EmailEntry>, EmailFilter>((ref, filter) async {
  final repo = ref.read(dashboardRepositoryProvider);
  return repo.getRecentEmails(
    searchQuery: filter.searchQuery, 
    accountId: filter.accountId,
    page: filter.page,
    limit: filter.limit,
  );
});
