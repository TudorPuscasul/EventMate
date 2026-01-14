import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Represents the authentication status.
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

/// State representing authentication status.
class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Initial state - checking auth status.
  const AuthState.initial() : this(status: AuthStatus.initial);

  /// Loading state - auth operation in progress.
  const AuthState.loading() : this(status: AuthStatus.loading);

  /// Authenticated state - user is signed in.
  const AuthState.authenticated(User user)
      : this(status: AuthStatus.authenticated, user: user);

  /// Unauthenticated state - user is signed out.
  const AuthState.unauthenticated() : this(status: AuthStatus.unauthenticated);

  /// Error state - auth operation failed.
  const AuthState.error(String message)
      : this(status: AuthStatus.unauthenticated, errorMessage: message);

  /// Whether the user is authenticated.
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Whether an auth operation is in progress.
  bool get isLoading => status == AuthStatus.loading;

  /// Copy with method for state updates.
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage];
}
