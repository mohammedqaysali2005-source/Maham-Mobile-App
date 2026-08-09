import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/service_locator.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/tasks/presentation/screens/tasks_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/projects/presentation/screens/board_kanban_screen.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;
      final isAuthRoute = state.uri.toString().startsWith('/login') ||
          state.uri.toString().startsWith('/register') ||
          state.uri.toString().startsWith('/splash');

      if (authState is Authenticated && isAuthRoute) {
        return '/home';
      }
      if (authState is Unauthenticated && !isAuthRoute) {
        return '/login';
      }
      return null;
    },
    routes: [
      // ── Splash ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),

      // ── Auth ─────────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: _slideTransition,
        ),
        routes: [
          GoRoute(
            path: 'register',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const RegisterScreen(),
              transitionsBuilder: _slideTransition,
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: _slideTransition,
        ),
      ),

      // ── Shell (الشاشات المحمية) ──────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => _noTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/projects',
            pageBuilder: (context, state) => _noTransitionPage(
              key: state.pageKey,
              child: const ProjectsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final projectId = state.pathParameters['id']!;
                  return ProjectDetailScreen(projectId: projectId);
                },
              ),
              GoRoute(
                path: ':id/boards/:boardId',
                builder: (context, state) {
                  final projectId = state.pathParameters['id']!;
                  final boardId = state.pathParameters['boardId']!;
                  return BoardKanbanScreen(projectId: projectId, boardId: boardId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (context, state) => _noTransitionPage(
              key: state.pageKey,
              child: const TasksScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => _noTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => _noTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة\n${state.uri}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/splash'),
              child: const Text('الرئيسية', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    ),
  );

  static Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      get _slideTransition => (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeInOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          };

  static NoTransitionPage<void> _noTransitionPage({
    required LocalKey key,
    required Widget child,
  }) =>
      NoTransitionPage<void>(key: key, child: child);
}
