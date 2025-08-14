part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthSignInWithGoogleRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

class _AuthUserChanged extends AuthEvent {
  final supabase.User? user; // <-- Gunakan tipe User dari Supabase
  const _AuthUserChanged(this.user);
}

class AuthPregnancyStartDateUpdated extends AuthEvent {
  final DateTime date;
  const AuthPregnancyStartDateUpdated(this.date);

  @override
  List<Object> get props => [date];
}