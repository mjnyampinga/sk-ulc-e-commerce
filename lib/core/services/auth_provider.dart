import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../../data/models/user.dart' as app_user;
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AuthProvider extends ChangeNotifier {
  User? _firebaseUser;
  app_user.User? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  User? get firebaseUser => _firebaseUser;
  app_user.User? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    // Don't initialize Firebase auth in constructor
    initialize();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // The StreamBuilder in AuthWrapper now handles listening to this.
    // We just need to sync the state.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      syncFirebaseUser(user);
    });
  }

  /// Syncs the user from Firebase and updates the local state.
  /// Called by the AuthWrapper's StreamBuilder.
  void syncFirebaseUser(User? user) {
    if (user != _firebaseUser) {
      _firebaseUser = user;
      if (user != null) {
        _loadUserProfile(user.uid);
      } else {
        _userProfile = null;
        notifyListeners(); // Notify for logout
      }
    }
  }

  Future<void> _loadUserProfile(String userId) async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      final box = await Hive.openBox<app_user.User>('user_profiles');
      if (connectivityResult != ConnectivityResult.none) {
        // Online: fetch from Firestore and update Hive
        _userProfile = await FirebaseService.getUserProfile(userId);
        if (_userProfile != null) {
          await box.put(userId, _userProfile!);
        }
      } else {
        // Offline: load from Hive
        _userProfile = box.get(userId);
      }
      notifyListeners(); // Notify after profile loads
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String userType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserCredential? result = await FirebaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        userType: userType,
      );

      if (result != null) {
        _firebaseUser = result.user;
        await _loadUserProfile(result.user!.uid);
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to create account');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserCredential? result = await FirebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('AuthProvider: signIn result: $result');

      if (result != null) {
        _firebaseUser = result.user;
        await _loadUserProfile(result.user!.uid);
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to sign in');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      print('AuthProvider: signIn error: $e');
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithPhone({
    required String phoneNumber,
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential? result =
          await FirebaseService.signInWithPhoneCredential(credential);

      if (result != null) {
        _firebaseUser = result.user;
        await _loadUserProfile(result.user!.uid);
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to sign in with phone');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signUpWithPhone({
    required String phoneNumber,
    required String username,
    required String userType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      UserCredential? result = await FirebaseService.signUpWithPhone(
        phoneNumber: phoneNumber,
        username: username,
        userType: userType,
      );

      if (result != null) {
        _firebaseUser = result.user;
        await _loadUserProfile(result.user!.uid);
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to create account with phone');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(_getErrorMessage(e));
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    print('AuthProvider: signOut called');
    try {
      // The StreamBuilder will handle the UI change.
      await FirebaseService.signOut();
      print('AuthProvider: FirebaseService.signOut completed');
    } catch (e) {
      print('AuthProvider: signOut error: $e');
      _setError('Failed to sign out');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_firebaseUser != null) {
      try {
        await FirebaseService.queueOrUpdateUserProfile(
            _firebaseUser!.uid, data);
        await _loadUserProfile(_firebaseUser!.uid);
      } catch (e) {
        _setError('Failed to update profile');
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return error.message ?? 'An error occurred during authentication.';
      }
    }
    return 'An unexpected error occurred.';
  }
}
