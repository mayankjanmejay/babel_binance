import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<void> initialize() async {
    // Initialize auth state listeners
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in
      } else {
        // User is signed out
      }
    });
  }

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Biometric Authentication
  Future<bool> isBiometricsAvailable() async {
    return await _localAuth.canCheckBiometrics;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _localAuth.getAvailableBiometrics();
  }
}
