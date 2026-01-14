import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/profile_cache_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC for managing authentication state.
///
/// Handles user sign in, sign up, sign out, and password reset operations.
/// Listens to Firebase auth state changes to keep state in sync.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final ProfileCacheService _cacheService;
  StreamSubscription<User?>? _authSubscription;

  AuthBloc({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    ProfileCacheService? cacheService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _cacheService = cacheService ?? ProfileCacheService(),
        super(const AuthState.initial()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthCheckRequested>(_onCheckRequested);

    // Listen to auth state changes
    _authSubscription = _auth.authStateChanges().listen((user) {
      add(const AuthCheckRequested());
    });
  }

  /// Current Firebase user (for backward compatibility).
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes (for AuthWrapper).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Cache profile data for offline use
      await _cacheService.cacheProfile(
        displayName: result.user?.displayName,
        email: result.user?.email,
        userId: result.user?.uid,
      );

      emit(AuthState.authenticated(result.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_handleAuthError(e)));
    } catch (e) {
      emit(const AuthState.error('An unexpected error occurred'));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      await result.user!.updateDisplayName(event.name);

      await _firestore.collection('users').doc(result.user!.uid).set({
        'id': result.user!.uid,
        'name': event.name,
        'email': event.email,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Cache profile data for offline use
      await _cacheService.cacheProfile(
        displayName: event.name,
        email: event.email,
        userId: result.user!.uid,
      );

      emit(AuthState.authenticated(result.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_handleAuthError(e)));
    } catch (e) {
      emit(AuthState.error('An unexpected error occurred: $e'));
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthState.loading());

    try {
      await _auth.signOut();
      await _cacheService.clearCache();
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(const AuthState.error('Failed to sign out'));
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _auth.sendPasswordResetEmail(email: event.email);
      // Don't change auth state, just send the email
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(_handleAuthError(e)));
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthState.authenticated(user));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
