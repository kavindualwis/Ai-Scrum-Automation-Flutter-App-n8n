import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late SharedPreferences _prefs;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegistered = false;
  bool _isInitialized = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isRegistered => _isRegistered;
  bool get isInitialized => _isInitialized;
  bool get showSplash => !isAuthenticated || !isRegistered;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _initializePreferences();
      await _checkAuthStatus();
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isRegistered = _prefs.getBool('isRegistered') ?? false;
  }

  Future<void> _checkAuthStatus() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      _user = UserModel(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        displayName: currentUser.displayName,
        isRegistered: _isRegistered,
      );
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      _user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: name,
        isRegistered: true,
      );

      _isRegistered = true;
      await _prefs.setBool('isRegistered', true);
      await _prefs.setString('userId', userCredential.user!.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: userCredential.user?.displayName,
        isRegistered: true,
      );

      _isRegistered = true;
      await _prefs.setBool('isRegistered', true);
      await _prefs.setString('userId', userCredential.user!.uid);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseAuth.signOut();
      _user = null;
      _isRegistered = false;
      await _prefs.setBool('isRegistered', false);
      await _prefs.remove('userId');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
