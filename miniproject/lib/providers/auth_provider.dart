import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  User? user;
  bool isLoading = true;
  bool hasEmergencyContact = false;
  String? errorMessage;

  late final StreamSubscription<User?> _authSubscription;

  AuthProvider() {
    _authSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    user = firebaseUser;
    errorMessage = null;

    if (firebaseUser != null) {
      await _firestoreService.ensureUserDocument(
        userId: firebaseUser.uid,
        email: firebaseUser.email ?? '',
      );
      hasEmergencyContact =
          await _firestoreService.hasEmergencyContact(firebaseUser.uid);
    } else {
      hasEmergencyContact = false;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.signUp(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? 'Signup failed.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await _authService.login(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (error) {
      errorMessage = error.message ?? 'Login failed.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<void> refreshEmergencyContactStatus() async {
    if (user == null) return;
    hasEmergencyContact = await _firestoreService.hasEmergencyContact(user!.uid);
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
