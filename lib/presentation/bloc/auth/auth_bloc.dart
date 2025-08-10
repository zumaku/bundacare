import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // <-- Ganti import dengan alias
import 'package:bundacare/domain/usecases/auth/sign_in_with_google.dart';
import 'package:bundacare/domain/usecases/auth/sign_out.dart'; // <-- Tambahkan import

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  // Gunakan tipe dari package supabase
  late final StreamSubscription<supabase.AuthState> _authStateSubscription; 

  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
    required supabase.SupabaseClient supabaseClient, // Gunakan alias
  })  : _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        super(AuthInitial()) {

    _authStateSubscription = supabaseClient.auth.onAuthStateChange.listen((data) {
      // User di sini adalah supabase.User
      add(_AuthUserChanged(data.session?.user));
    });

    on<AuthSignInWithGoogleRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _signInWithGoogle();
      } catch (e) {
        emit(Unauthenticated(message: 'Login Gagal: ${e.toString()}'));
      }
    });

    on<AuthSignOutRequested>((event, emit) async {
      emit(AuthLoading());
      await _signOut();
    });

    on<_AuthUserChanged>((event, emit) {
      if (event.user != null) {
        // user adalah supabase.User
        emit(Authenticated(event.user!)); 
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }
}