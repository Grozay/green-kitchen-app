import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
      // print('DEBUG PhoneAuthService: Starting sendOTP for $phoneNumber');
      _phoneNumber = phoneNumber;
      _formattedPhoneNumber = _formatVietnamesePhoneNumber(phoneNumber);
      // print('DEBUG PhoneAuthService: Formatted phone: $_formattedPhoneNumber');

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _formattedPhoneNumber!,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // print('DEBUG PhoneAuthService: Auto verification completed');
          await FirebaseAuth.instance.signInWithCredential(credential);
          _onVerificationCompleted?.call();
        },
        verificationFailed: (FirebaseAuthException e) {
          // print('DEBUG PhoneAuthService: Verification failed: ${e.message}');
          _onVerificationFailed?.call(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          // print('DEBUG PhoneAuthService: Code sent, verificationId: $verificationId');
          _verificationId = verificationId;
          _onCodeSent?.call();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // print('DEBUG PhoneAuthService: Code auto retrieval timeout');
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      // print('DEBUG PhoneAuthService: sendOTP exception: $e');
      _onVerificationFailed?.call('Failed to send OTP: $e');
    }
  }

  // Verify OTP and sign in (simplified - just Firebase verification)
  Future<Map<String, dynamic>> verifyOTP(String smsCode) async {
    try {
      // print('DEBUG PhoneAuthService: Starting verifyOTP with code: $smsCode');
      if (_verificationId == null) {
        // print('DEBUG PhoneAuthService: Verification ID is null');
        return {
          'success': false,
          'message': 'Verification ID is null. Please request OTP again.',
        };
      }

      // print('DEBUG PhoneAuthService: Creating credential with verificationId: $_verificationId');
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // print('DEBUG PhoneAuthService: Signing in with credential');
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        // print('DEBUG PhoneAuthService: User is null after sign in');
        return {
          'success': false,
          'message': 'User is null after sign in',
        };
      }

      // print('DEBUG PhoneAuthService: Sign in successful, phone: ${userCredential.user!.phoneNumber}');
      // Return success with phone number - no backend call here
      return {
        'success': true,
        'phoneNumber': _phoneNumber ?? userCredential.user!.phoneNumber,
        'firebaseUser': userCredential.user,
      };
    } catch (e) {
      // print('DEBUG PhoneAuthService: verifyOTP exception: $e');
      return {
        'success': false,
        'message': 'Failed to verify OTP: ${e.toString()}',
      };
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