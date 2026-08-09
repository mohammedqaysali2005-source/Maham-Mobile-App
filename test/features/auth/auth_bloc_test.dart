import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:maham_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:maham_app/features/auth/data/models/auth_response_model.dart';
import 'package:maham_app/shared/models/user_model.dart';
import 'package:maham_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:maham_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:maham_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  final tUser = UserModel(
    id: 'user-123',
    fullName: 'Test User',
    email: 'test@maham.com',
    role: 'Member',
    createdAt: DateTime.now(),
  );

  final tAuthResponse = AuthResponseModel(
    token: 'jwt-token-xyz',
    user: tUser,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state is AuthInitial', () {
    expect(authBloc.state, AuthInitial());
  });

  group('AuthCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when getMe succeeds',
      build: () {
        when(() => mockAuthRepository.getMe()).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthLoading(),
        Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when getMe throws',
      build: () {
        when(() => mockAuthRepository.getMe()).thenThrow(Exception('No token'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });

  group('LoginRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when login is successful',
      build: () {
        when(() => mockAuthRepository.login('test@maham.com', 'password123'))
            .thenAnswer((_) async => tAuthResponse);
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(email: 'test@maham.com', password: 'password123')),
      expect: () => [
        AuthLoading(),
        Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(() => mockAuthRepository.login('test@maham.com', 'password123'))
            .thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(email: 'test@maham.com', password: 'password123')),
      expect: () => [
        AuthLoading(),
        const AuthFailure('Exception: Invalid credentials'),
      ],
    );
  });

  group('RegisterRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when registration is successful',
      build: () {
        when(() => mockAuthRepository.register('Test User', 'test@maham.com', 'password123'))
            .thenAnswer((_) async => tAuthResponse);
        return authBloc;
      },
      act: (bloc) => bloc.add(const RegisterRequested(
        fullName: 'Test User',
        email: 'test@maham.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when registration fails',
      build: () {
        when(() => mockAuthRepository.register('Test User', 'test@maham.com', 'password123'))
            .thenThrow(Exception('Email already exists'));
        return authBloc;
      },
      act: (bloc) => bloc.add(const RegisterRequested(
        fullName: 'Test User',
        email: 'test@maham.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        const AuthFailure('Exception: Email already exists'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] on logout',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(LogoutRequested()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });
}
