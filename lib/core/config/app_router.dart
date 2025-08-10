import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // <-- Pastikan import ini ada
import 'package:go_router/go_router.dart';
import 'package:bundacare/core/injection_container.dart' as di; // <-- Pastikan import ini ada
import 'package:bundacare/presentation/bloc/food/food_bloc.dart'; // <-- Pastikan import ini ada
import 'package:bundacare/presentation/screens/auth/login_screen.dart';
import 'package:bundacare/presentation/screens/home/home_screen.dart';
import 'package:bundacare/presentation/screens/profile/profile_screen.dart';
import 'package:bundacare/presentation/screens/camera/camera_screen.dart';
import 'package:bundacare/presentation/screens/main_shell.dart';
import 'package:bundacare/core/services/supabase_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // ================== PERUBAHAN DI SINI ==================
          // Kita bungkus MainShell dengan BlocProvider untuk FoodBloc
          return BlocProvider(
            create: (context) => di.sl<FoodBloc>()..add(FetchTodaysFood()),
            child: MainShell(navigationShell: navigationShell),
          );
          // ========================================================
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/camera', builder: (context, state) => const CameraScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final loggedIn = supabase.auth.currentUser != null;
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}