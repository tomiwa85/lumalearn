import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screens
import '../../shared/widgets/scaffold_with_navbar.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/progress_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import 'package:lumalearn/features/session/session_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',

    // 1. LISTEN TO AUTH CHANGES
    // This tells the router to re-check the "redirect" logic
    // whenever the user logs in or logs out.
    refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),

    // 2. THE GUARD LOGIC
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/';

      // Rule A: If NOT logged in, and trying to go to protected pages -> Go to Login
      if (!isLoggedIn && !isLoggingIn && !isSplash) {
        return '/login';
      }

      // Rule B: If Logged in, and trying to go to Login -> Go to Home
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }

      // Rule C: Allow Splash screen to handle itself (it waits 3s then navigates)
      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/session',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SessionScreen(),
      ),
    ],
  );
});

// 3. HELPER CLASS
// This converts the Supabase Stream into something GoRouter can listen to.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}