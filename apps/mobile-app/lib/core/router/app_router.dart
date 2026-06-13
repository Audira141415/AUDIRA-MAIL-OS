import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/inbox_screen.dart';
import '../../features/dashboard/presentation/screens/email_detail_screen.dart';
import '../../features/dashboard/domain/models/email_model.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final isAuth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/inbox',
    redirect: (context, state) {
      final isGoingToLogin = state.matchedLocation == '/login' || state.matchedLocation == '/register';
      
      if (!isAuth && !isGoingToLogin) {
        return '/login';
      }
      if (isAuth && isGoingToLogin) {
        return '/inbox';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/inbox',
        builder: (context, state) => const InboxScreen(),
      ),
      GoRoute(
        path: '/email/:id',
        builder: (context, state) {
          final email = state.extra as EmailModel;
          return EmailDetailScreen(email: email);
        },
      ),
    ],
  );
}
