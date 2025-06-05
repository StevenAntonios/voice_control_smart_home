part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class RegisterLoading extends AuthState {}

final class RegisterSuccess extends AuthState {}

class RegisterFailed extends AuthState {
  final String message;
  RegisterFailed({required this.message});
}

final class LoginLoading extends AuthState {}

final class LoginSuccess extends AuthState {
  final String username;
  LoginSuccess(this.username);
}

final class LoginFailed extends AuthState {}
