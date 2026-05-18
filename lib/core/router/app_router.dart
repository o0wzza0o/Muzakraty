import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_event_state.dart' as app_auth;
import '../../features/auth/phone_login/phone_login_screen.dart';
import '../../features/auth/otp/otp_screen.dart';
import '../../features/auth/access_code/access_code_screen.dart';
import '../../features/onboarding/profile_setup/profile_setup_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/courses/course_list/my_courses_screen.dart';
import '../../features/courses/course_detail/course_detail_screen.dart';
import '../../features/courses/video_player/video_player_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/profile/profile_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAtRoot = state.matchedLocation == '/';
      final isAtLogin = state.matchedLocation == '/login';
      final isAtOnboarding = state.matchedLocation == '/onboarding';

      // Still loading - show splash
      if (authState is app_auth.AuthInitial || authState is app_auth.AuthLoading) {
        return isAtRoot ? null : '/';
      }

      // Authenticated - go to home
      if (authState is app_auth.Authenticated) {
        return (isAtRoot || isAtLogin) ? '/home' : null;
      }

      // Needs onboarding
      if (authState is app_auth.AuthenticatedNeedsOnboarding) {
        return isAtOnboarding ? null : '/onboarding';
      }

      // Unauthenticated - go to login
      if (authState is app_auth.Unauthenticated || authState is app_auth.AuthError) {
        return (isAtRoot || isAtLogin) ? '/login' : '/login';
      }

      return null;
    },
    refreshListenable: _AuthRefreshNotifier(),
    routes: [
      // Splash/Loading route
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/access-code',
        name: 'access-code',
        builder: (context, state) => const AccessCodeScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main app shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/my-courses',
            name: 'my-courses',
            builder: (context, state) => const MyCoursesScreen(),
          ),
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Course detail (full screen)
      GoRoute(
        path: '/course/:id',
        name: 'course-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CourseDetailScreen(courseId: id);
        },
      ),

      // Video player (full screen)
      GoRoute(
        path: '/video/:courseId/:lessonId',
        name: 'video-player',
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final lessonId = state.pathParameters['lessonId'] ?? '';
          return VideoPlayerScreen(
            courseId: courseId,
            lessonId: lessonId,
          );
        },
      ),
    ],
  );
}

/// Splash screen shown while checking auth status
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, app_auth.AuthState>(
      listener: (context, state) {
        // Router redirect will handle navigation
        if (state is app_auth.Authenticated) {
          context.go('/home');
        } else if (state is app_auth.AuthenticatedNeedsOnboarding) {
          context.go('/onboarding');
        } else if (state is app_auth.Unauthenticated || state is app_auth.AuthError) {
          context.go('/login');
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

/// Notifies GoRouter when auth state changes
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier();
}
