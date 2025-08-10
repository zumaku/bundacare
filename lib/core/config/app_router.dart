import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bundacare/presentation/screens/auth/login_screen.dart';
import 'package:bundacare/presentation/screens/home/home_screen.dart';
import 'package:bundacare/presentation/screens/profile/profile_screen.dart';
import 'package:bundacare/presentation/screens/history/history_screen.dart';
import 'package:bundacare/core/services/supabase_service.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      // GoRoute(
      //   path: '/history',
      //   builder: (context, state) => const HistoryScreen(),
      // ),
      // Contoh rute dengan parameter
      // GoRoute(
      //   path: '/detail/:log_id',
      //   builder: (context, state) {
      //     final logId = state.pathParameters['log_id']!;
      //     return DetailScreen(logId: logId);
      //   },
      // ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = supabase.auth.currentUser != null;
      final loggingIn = state.matchedLocation == '/login';

      // Jika belum login dan tidak sedang di halaman login, redirect ke /login
      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      // Jika sudah login dan mencoba akses halaman login, redirect ke home
      if (loggingIn) {
        return '/';
      }

      return null; // Tidak perlu redirect
    },
    // Refresh listener untuk GoRouter agar bereaksi pada perubahan status auth
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  );
}

// Helper class untuk membuat GoRouter mendengarkan stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}