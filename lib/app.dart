import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/di/service_locator.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/projects/presentation/bloc/project_bloc.dart';
import 'features/projects/presentation/bloc/board_bloc.dart';
import 'features/tasks/presentation/bloc/tasks_bloc.dart';

class MahamApp extends StatelessWidget {
  const MahamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider.value(
          value: sl<ProjectBloc>(),
        ),
        BlocProvider.value(
          value: sl<BoardBloc>(),
        ),
        BlocProvider.value(
          value: sl<TasksBloc>(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
