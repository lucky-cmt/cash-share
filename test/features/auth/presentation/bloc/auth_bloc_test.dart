import 'package:bloc_test/bloc_test.dart';
import 'package:cash_distro/core/usecases/usecase.dart';
import 'package:cash_distro/features/auth/domain/entities/user_entity.dart';
import 'package:cash_distro/features/auth/domain/usecases/delete_account.dart';
import 'package:cash_distro/features/auth/domain/usecases/get_current_user.dart';
import 'package:cash_distro/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:cash_distro/features/auth/domain/usecases/sign_out.dart';
import 'package:cash_distro/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cash_distro/features/auth/presentation/bloc/auth_event.dart';
import 'package:cash_distro/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignOut extends Mock implements SignOut {}

class MockDeleteAccount extends Mock implements DeleteAccount {}

void main() {
  late MockGetCurrentUser mockGetCurrentUser;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late MockDeleteAccount mockDeleteAccount;

  const testUser = UserEntity(
    id: 'user-1',
    email: 'friend@cashdistro.app',
    displayName: 'Alex',
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUser();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();
    mockDeleteAccount = MockDeleteAccount();
  });

  AuthBloc buildBloc() => AuthBloc(
        getCurrentUser: mockGetCurrentUser,
        signInWithGoogle: mockSignInWithGoogle,
        signOut: mockSignOut,
        deleteAccount: mockDeleteAccount,
      );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when user is signed in',
    build: () {
      when(() => mockGetCurrentUser(any()))
          .thenAnswer((_) async => const Right(testUser));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthCheckRequested()),
    expect: () => const [
      AuthLoading(),
      AuthAuthenticated(testUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthUnauthenticated] when no user is signed in',
    build: () {
      when(() => mockGetCurrentUser(any()))
          .thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const AuthCheckRequested()),
    expect: () => const [
      AuthLoading(),
      AuthUnauthenticated(),
    ],
  );
}
