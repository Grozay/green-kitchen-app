import 'package:firebase_auth/firebase_auth.dart';
import '../services/service.dart';
import '../apis/endpoint.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  String? _verificationId;
  String? _phoneNumber; // Will store the original phone number
  String? _formattedPhoneNumber; // Will store the formatted phone number for Firebase

  // Callbacks for verification states
  Function()? _onVerificationCompleted;
  Function(String)? _onVerificationFailed;
  Function()? _onCodeSent;

  // Set callbacks
  void setCallbacks({
    Function()? onVerificationCompleted,
    Function(String)? onVerificationFailed,
    Function()? onCodeSent,
  }) {
    _onVerificationCompleted = onVerificationCompleted;
    _onVerificationFailed = onVerificationFailed;
    _onCodeSent = onCodeSent;
  }

  // Send OTP to phone number
  Future<void> sendOTP(String phoneNumber) async {
    try {
      _phoneNumber = phoneNumber;
      _formattedPhoneNumber = _formatVietnamesePhoneNumber(phoneNumber);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _formattedPhoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _onVerificationCompleted?.call();
        },
        verificationFailed: (FirebaseAuthException e) {
          _onVerificationFailed?.call(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _onCodeSent?.call();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      _onVerificationFailed?.call('Failed to send OTP: $e');
    }
  }

  // Verify OTP and sign in
  Future<Map<String, dynamic>> verifyOTP(String smsCode) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID is null. Please request OTP again.');
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      return await _signInWithCredential(credential);
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Sign in with credential and authenticate with backend
  Future<Map<String, dynamic>> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('User is null after sign in');
      }

      // Get Firebase ID Token
      String? firebaseIdToken = await userCredential.user!.getIdToken();

      if (firebaseIdToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Prepare data for backend
      Map<String, dynamic> phoneLoginData = {
        'firebaseIdToken': firebaseIdToken,
        'phoneNumber': _phoneNumber ?? userCredential.user!.phoneNumber,
      };

      // Call backend phone-login endpoint
      final response = await _apiService.post(
        ApiEndpoints.phoneLogin,
        body: phoneLoginData,
        includeAuth: false, // Phone login doesn't need existing auth token
      );

      return {
        'success': true,
        'user': userCredential.user,
        'backendResponse': response,
        'firebaseIdToken': firebaseIdToken,
        'phoneNumber': _phoneNumber,
      };
    } catch (e) {
      throw Exception('Failed to authenticate with backend: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _phoneNumber = null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  // Format Vietnamese phone number to international format
  String _formatVietnamesePhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // If starts with 0, replace with +84
    if (cleaned.startsWith('0')) {
      return '+84${cleaned.substring(1)}';
    }

    // If already starts with +84, return as is
    if (cleaned.startsWith('84')) {
      return '+$cleaned';
    }

    // If already international format, return as is
    if (cleaned.startsWith('+84')) {
      return cleaned;
    }

    // Default case: assume it's a Vietnamese number and add +84
    return '+84$cleaned';
  }
}