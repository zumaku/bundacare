part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final supabase.User user; // <-- Gunakan tipe User dari Supabase
  final UserProfile? profile;

  const Authenticated(this.user, {this.profile});

  @override
  List<Object?> get props => [user, profile];
}

class Unauthenticated extends AuthState {
    final String? message;
    const Unauthenticated({this.message});

    @override
    List<Object?> get props => [message];
}