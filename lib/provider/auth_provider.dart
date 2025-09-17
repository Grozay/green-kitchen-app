import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/phone_auth_service.dart';

// AuthProvider manages authentication state
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PhoneAuthService _phoneAuthService = PhoneAuthService();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  // Initialize provider
  Future<void> init() async {
    await _authService.init();
    await checkAuthStatus();
  }

  // Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _clearError();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      _setError('Failed to check authentication status');
    } finally {
      _setLoading(false);
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);

      if (response.success) {
        _currentUser = response.user;
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Login failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register user
  Future<bool> register(String email, String password, {String? firstName, String? lastName}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(email, password, firstName: firstName, lastName: lastName);

      if (response.success) {
        // Don't set currentUser yet - wait for email verification
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register user with mobile (OTP)
  Future<bool> mobileRegister(String email, String password, {String? firstName, String? lastName}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.mobileRegister(email, password, firstName: firstName, lastName: lastName);

      if (response.success) {
        // Don't set currentUser yet - wait for OTP verification
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Mobile registration failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Google Sign In
  Future<bool> googleSignIn() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.googleSignIn();

      if (response.success) {
        _currentUser = response.user;
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      _setError('Google sign in failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phone authentication - Send OTP
  Future<bool> sendOTP(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      // Set callbacks for PhoneAuthService
      _phoneAuthService.setCallbacks(
        onVerificationCompleted: () {
          _setLoading(false);
          _setError('Auto-verification completed');
        },
        onVerificationFailed: (String error) {
          _setLoading(false);
          _setError(error);
        },
        onCodeSent: () {
          _setLoading(false);
          _setError('OTP sent successfully'); // Use as success message
        },
      );

      await _phoneAuthService.sendOTP(phoneNumber);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to send OTP: ${e.toString()}');
      return false;
    }
  }

  // Phone authentication - Verify OTP
  Future<bool> verifyOTP(String smsCode) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _phoneAuthService.verifyOTP(smsCode);

      if (result['success'] == true) {
        // Set current user from backend response
        final backendResponse = result['backendResponse'];
        if (backendResponse is Map<String, dynamic>) {
          _currentUser = User.fromJson(backendResponse);
        } else {
          // Create a basic user from Firebase data
          _currentUser = User(
            id: result['firebaseIdToken']?.substring(0, 10) ?? 'firebase_user',
            email: '', // Phone auth doesn't have email
            phone: result['phoneNumber'],
            fullName: 'Phone User',
          );
        }
        notifyListeners();
        return true;
      } else {
        _setError('OTP verification failed');
        return false;
      }
    } catch (e) {
      _setError('OTP verification failed: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();
      await _phoneAuthService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout failed');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  void updateUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _clearError();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}