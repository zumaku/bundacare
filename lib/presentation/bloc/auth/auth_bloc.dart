import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bundacare/domain/entities/user_profile.dart';
import 'package:bundacare/domain/usecases/auth/get_user_profile.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase; // <-- Ganti import dengan alias
import 'package:bundacare/domain/usecases/auth/sign_in_with_google.dart';
import 'package:bundacare/domain/usecases/auth/sign_out.dart'; // <-- Tambahkan import

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final SignOut _signOut;
  final GetUserProfile _getUserProfile;
  // Gunakan tipe dari package supabase
  late final StreamSubscription<supabase.AuthState> _authStateSubscription; 

  AuthBloc({
    required SignInWithGoogle signInWithGoogle,
    required SignOut signOut,
    required GetUserProfile getUserProfile,
    required supabase.SupabaseClient supabaseClient, // Gunakan alias
  })  : _signInWithGoogle = signInWithGoogle,
        _signOut = signOut,
        _getUserProfile = getUserProfile,
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

    on<_AuthUserChanged>((event, emit) async { // Jadikan async
      if (event.user != null) {
        try {
          // Saat user berubah (login), ambil profilnya
          final profile = await _getUserProfile();
          emit(Authenticated(event.user!, profile: profile));
        } catch (e) {
          // Jika gagal ambil profil, tetap autentikasi tapi tanpa profil
          emit(Authenticated(event.user!)); 
        }
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