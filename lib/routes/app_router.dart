import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/history_page.dart';
import '../presentation/pages/detail_page.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const SplashPage()),
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/home', builder: (c, s) => const HomePage()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
      GoRoute(path: '/history', builder: (c, s) => const HistoryPage()),
      GoRoute(path: '/detail/:log_id', builder: (c, s) {
        final logId = s.pathParameters['log_id'] ?? '';
        return DetailPage(logId: logId);
      }),
    ],
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final loggedIn = session != null;
      final loggingIn =
          state.uri.toString() == '/login' || state.uri.toString() == '/';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && state.uri.toString() == '/login') return '/home';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange.map((event) => event),
    ),
  );
}
