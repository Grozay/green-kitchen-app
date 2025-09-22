import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../apis/endpoint.dart';
import '../models/user.dart';
import '../config/env_config.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: EnvConfig.googleWebClientId,
    scopes: [
      'email',
      'profile',
    ],
  );

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (error) {
      // print('Google sign in error: $error');
      return null;
    }
  }

  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (error) {
      // print('Google sign out error: $error');
    }
  }

  /// Decode Google ID token to extract user information
  Map<String, dynamic> _decodeIdToken(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid JWT token format');
      }

      // Decode payload (second part)
      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

      return jsonDecode(decodedPayload);
    } catch (e) {
      throw Exception('Failed to decode ID token: $e');
    }
  }

  Future<AuthResponse> authenticateWithFlutter(String idToken) async {
    try {
      // Decode ID token to get user information
      final decodedToken = _decodeIdToken(idToken);

      // Extract user information from token
      final userInfo = {
        'id': decodedToken['sub'],
        'email': decodedToken['email'],
        'name': decodedToken['name'],
        'givenName': decodedToken['given_name'],
        'familyName': decodedToken['family_name'],
        'picture': decodedToken['picture'],
        'emailVerified': decodedToken['email_verified'],
        'locale': decodedToken['locale'],
      };

      // print('Decoded Google user info: $userInfo');

      final response = await http.post(
        Uri.parse(ApiEndpoints.googleLoginMobile),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userInfo': userInfo,
        }),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
        return authResponse;
      } else {
        throw Exception('Google authentication failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Google authentication error: $e');
    }
  }

  Future<AuthResponse> signInAndAuthenticate() async {
    try {
      // Sign in with Google
      final GoogleSignInAccount? account = await signInWithGoogle();
      if (account == null) {
        throw Exception('Google sign in cancelled');
      }

      // Get ID token
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // Authenticate
      final authResponse = await authenticateWithFlutter(idToken);
      return authResponse;
    } catch (e) {
      throw Exception('Google authentication failed: $e');
    }
  }
}