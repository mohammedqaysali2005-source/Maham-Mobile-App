import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/presentation/bloc/project_bloc.dart';
import '../../features/projects/domain/repositories/board_repository.dart';
import '../../features/projects/data/repositories/board_repository_impl.dart';
import '../../features/projects/presentation/bloc/board_bloc.dart';
import '../../features/tasks/presentation/bloc/tasks_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Storage Service
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // Network Interceptors
  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor(sl()));
  sl.registerLazySingleton<ErrorInterceptor>(() => ErrorInterceptor());

  // Dio Client
  sl.registerLazySingleton<DioClient>(() => DioClient(sl(), sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<ProjectRepository>(
      () => ProjectRepositoryImpl(sl()));
  sl.registerLazySingleton<BoardRepository>(
      () => BoardRepositoryImpl(sl()));

  // Blocs
  sl.registerLazySingleton(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton(() => ProjectBloc(repository: sl()));
  sl.registerLazySingleton(() => BoardBloc(repository: sl()));
  sl.registerLazySingleton(() => TasksBloc(repository: sl()));
}
