import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'profile_cache_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProfileCacheService _cacheService = ProfileCacheService();

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user!.updateDisplayName(name);

      await _firestore.collection('users').doc(result.user!.uid).set({
        'id': result.user!.uid,
        'name': name,
        'email': email,
        'photoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Cache profile data for offline use
      await _cacheService.cacheProfile(
        displayName: name,
        email: email,
        userId: result.user!.uid,
      );

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Cache profile data for offline use
      await _cacheService.cacheProfile(
        displayName: result.user?.displayName,
        email: result.user?.email,
        userId: result.user?.uid,
      );

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _cacheService.clearCache();
    notifyListeners();
  }

  Future<UserModel?> getCurrentUserData() async {
    if (currentUser == null) return null;
    
    DocumentSnapshot doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
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
}