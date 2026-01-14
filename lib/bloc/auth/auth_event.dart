import 'package:equatable/equatable.dart';

/// Base class for all authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request user sign in.
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event to request user sign up.
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object?> get props => [email, password, name];
}

/// Event to request user sign out.
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Event to request password reset email.
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to check current authentication status.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
