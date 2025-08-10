import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/di/di.dart' as di;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = di.sl<AuthRepository>();

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<SignInWithGoogleRequested>((event, emit) async {
      emit(AuthLoading());
      await _authRepository.signInWithGoogle();
      final user = await _authRepository.getCurrentUser();
      if (user != null) emit(AuthAuthenticated(user));
      else emit(AuthUnauthenticated());
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    });
  }
}
