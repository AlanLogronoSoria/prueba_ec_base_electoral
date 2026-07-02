import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/change_password_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/coordinador_provincial/presentation/bloc/provincial_bloc.dart';
import '../features/coordinador_provincial/presentation/pages/provincial_dashboard_page.dart';
import '../features/coordinador_recinto/presentation/bloc/recinto_bloc.dart';
import '../features/coordinador_recinto/presentation/pages/recinto_dashboard_page.dart';
import '../features/veedor/presentation/bloc/veedor_bloc.dart';
import '../features/veedor/presentation/pages/veedor_dashboard_page.dart';

GoRouter createAppRouter(AuthBloc authBloc) {
  final refreshNotifier = _AuthStateNotifier(authBloc);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
    final isLoggingIn = state.matchedLocation == '/login';
    final isChangingPassword = state.matchedLocation == '/change-password';
    final isResettingPassword =
        state.matchedLocation.startsWith('/reset-password');
    final isForgotPassword = state.matchedLocation == '/forgot-password';

    if (isResettingPassword || isForgotPassword) return null;

    if (authState is AuthUnauthenticated && !isLoggingIn) return '/login';
    if (authState is AuthRequiresPasswordChange && !isChangingPassword) {
      return '/change-password';
    }
    if (authState is AuthAuthenticated) {
      if (isLoggingIn || isChangingPassword) {
        return switch (authState.usuario.rol) {
          'coordinador_provincial' => '/provincial',
          'coordinador_recinto' => '/recinto',
          'veedor' => '/veedor',
          _ => '/login',
        };
      }
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final userId = state.uri.queryParameters['userId'] ?? '';
        final secret = state.uri.queryParameters['secret'] ?? '';
        return ResetPasswordPage(userId: userId, secret: secret);
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: context.read<ProvincialBloc>(),
            ),
            BlocProvider.value(
              value: context.read<RecintoBloc>(),
            ),
            BlocProvider.value(
              value: context.read<VeedorBloc>(),
            ),
          ],
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/provincial',
          builder: (context, state) => const ProvincialDashboardPage(),
        ),
        GoRoute(
          path: '/recinto',
          builder: (context, state) => const RecintoDashboardPage(),
        ),
        GoRoute(
          path: '/veedor',
          builder: (context, state) => const VeedorDashboardPage(),
        ),
      ],
    ),
  ],
  );
}

class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(AuthBloc authBloc) {
    _subscription = authBloc.stream.listen((_) => notifyListeners());
  }

  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
