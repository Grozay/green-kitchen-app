import '../apis/endpoint.dart';
import '../models/user.dart';
import '../services/service.dart';
import '../services/google_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// AuthService handles authentication logic
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // Initialize service
  Future<void> init() async {
    await _apiService.init();
  }

  // Login with email and password
  Future<AuthResponse> login(String email, String password) async {
    try {
      final loginRequest = {
        'email': email,
        'password': password,
      };
      // print('DEBUG: Email login request: $loginRequest');

      // Use direct HTTP call like Google login for consistency
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(loginRequest),
      );

      // print('DEBUG: Email login HTTP response status: ${response.statusCode}');
      // print('DEBUG: Email login HTTP response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        // print('DEBUG: Email AuthResponse parsed successfully');

        // Store token if login successful
        if (authResponse.success && authResponse.token != null) {
          await _apiService.setAuthToken(authResponse.token!);
          // print('DEBUG: Email login token stored successfully');
          
          // Store user data for auto login
          if (authResponse.user != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('current_user', json.encode(authResponse.user!.toJson()));
            // print('DEBUG: User data stored successfully');
          }
        }

        return authResponse;
      } else {
        // Handle error response
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['msg'] ?? 'Login failed';
          // print('DEBUG: Email login failed with error: $errorMessage');
          return AuthResponse(
            success: false,
            message: errorMessage,
          );
        } catch (e) {
          // print('DEBUG: Failed to parse email login error response: ${response.body}');
          return AuthResponse(
            success: false,
            message: 'Login failed: HTTP ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      // print('DEBUG: Email login network error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Login with phone number (mobile version - just phone, no Firebase token)
  Future<AuthResponse> phoneLoginMobile(String phone) async {
    try {
      final phoneLoginRequest = {
        'phone': phone,
      };
      // print('DEBUG: Phone login mobile request: $phoneLoginRequest');

      // Use direct HTTP call
      final response = await http.post(
        Uri.parse(ApiEndpoints.phoneLoginMobile),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(phoneLoginRequest),
      );

      // print('DEBUG: Phone login mobile HTTP response status: ${response.statusCode}');
      // print('DEBUG: Phone login mobile HTTP response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        // print('DEBUG: Phone login mobile AuthResponse parsed successfully - user email: ${authResponse.user?.email}');

        // Store token if login successful
        if (authResponse.success && authResponse.token != null) {
          await _apiService.setAuthToken(authResponse.token!);
          // print('DEBUG: Phone login mobile token stored successfully');
          
          // Store user data for auto login
          if (authResponse.user != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('current_user', json.encode(authResponse.user!.toJson()));
            // print('DEBUG: Phone user data stored successfully');
          }
        }

        return authResponse;
      } else {
        // Handle error response
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['msg'] ?? 'Phone login failed';
          // print('DEBUG: Phone login mobile failed with error: $errorMessage');
          return AuthResponse(
            success: false,
            message: errorMessage,
          );
        } catch (e) {
          // print('DEBUG: Failed to parse phone login mobile error response: ${response.body}');
          return AuthResponse(
            success: false,
            message: 'Phone login failed: HTTP ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      // print('DEBUG: Phone login mobile network error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Login with phone number
  Future<AuthResponse> phoneLogin(String phone) async {
    try {
      final phoneLoginRequest = {
        'phone': phone,
      };
      // print('DEBUG: Phone login request: $phoneLoginRequest');

      // Use direct HTTP call like Google login for consistency
      final response = await http.post(
        Uri.parse(ApiEndpoints.phoneLogin),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(phoneLoginRequest),
      );

      // print('DEBUG: Phone login HTTP response status: ${response.statusCode}');
      // print('DEBUG: Phone login HTTP response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        // print('DEBUG: Phone AuthResponse parsed successfully');

        // Store token if login successful
        if (authResponse.success && authResponse.token != null) {
          await _apiService.setAuthToken(authResponse.token!);
          // print('DEBUG: Phone login token stored successfully');
        }

        return authResponse;
      } else {
        // Handle error response
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? errorData['msg'] ?? 'Phone login failed';
          // print('DEBUG: Phone login failed with error: $errorMessage');
          return AuthResponse(
            success: false,
            message: errorMessage,
          );
        } catch (e) {
          // print('DEBUG: Failed to parse phone login error response: ${response.body}');
          return AuthResponse(
            success: false,
            message: 'Phone login failed: HTTP ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      // print('DEBUG: Phone login network error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
  Future<AuthResponse> register(String email, String password, {String? firstName, String? lastName}) async {
    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final response = await _apiService.post(
        ApiEndpoints.register,
        body: registerRequest.toJson(),
        includeAuth: false, // No auth token needed for register
      );

      final authResponse = AuthResponse.fromJson(response);

      return authResponse;
    } catch (e) {
      if (e is ApiError) {
        return AuthResponse(
          success: false,
          message: e.message,
        );
      }
      return AuthResponse(
        success: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  // Register new user with mobile (OTP)
  Future<AuthResponse> mobileRegister(String email, String password, {String? firstName, String? lastName}) async {
    try {
      final registerRequest = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final response = await _apiService.post(
        ApiEndpoints.mobileRegister,
        body: registerRequest.toJson(),
        includeAuth: false, // No auth token needed for register
      );

      final authResponse = AuthResponse.fromJson(response);

      return authResponse;
    } catch (e) {
      if (e is ApiError) {
        return AuthResponse(
          success: false,
          message: e.message,
        );
      }
      return AuthResponse(
        success: false,
        message: 'Mobile registration failed: ${e.toString()}',
      );
    }
  }

  // Verify OTP for registration
  Future<AuthResponse> verifyOtp(String email, String token) async {
    try {
      final verifyRequest = {
        'email': email,
        'token': token,
      };

      final response = await _apiService.post(
        ApiEndpoints.verifyOtp,
        body: verifyRequest,
        includeAuth: false, // No auth token needed for OTP verification
      );

      final authResponse = AuthResponse.fromJson(response);

      // Store token if verification successful
      if (authResponse.success && authResponse.token != null) {
        await _apiService.setAuthToken(authResponse.token!);
      }

      return authResponse;
    } catch (e) {
      if (e is ApiError) {
        return AuthResponse(
          success: false,
          message: e.message,
        );
      }
      return AuthResponse(
        success: false,
        message: 'OTP verification failed: ${e.toString()}',
      );
    }
  }

  // Logout user
  Future<AuthResponse> logout() async {
    try {
      // Call logout endpoint if needed
      await _apiService.post(ApiEndpoints.logout);

      // Clear stored token
      await _apiService.clearAuthToken();
      
      // Clear stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      // print('DEBUG: User data cleared successfully');

      return AuthResponse(
        success: true,
        message: 'Logged out successfully',
      );
    } catch (e) {
      // Even if API call fails, clear local token
      await _apiService.clearAuthToken();
      
      // Clear stored user data  
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user');
      // print('DEBUG: User data cleared after error');

      if (e is ApiError) {
        return AuthResponse(
          success: true, // Consider it successful since we cleared local token
          message: 'Logged out locally (API error: ${e.message})',
        );
      }
      return AuthResponse(
        success: true,
        message: 'Logged out locally',
      );
    }
  }

  // Get current user profile
  Future<User?> getCurrentUser() async {
    try {
      // Get current user from stored data first
      final prefs = await SharedPreferences.getInstance();
      final storedUserData = prefs.getString('current_user');

      if (storedUserData != null) {
        final storedUser = User.fromJson(json.decode(storedUserData));

        // If user has email, fetch fresh customer data from backend
        if (storedUser.email.isNotEmpty) {
          try {
            final customerResponse = await _apiService.get(ApiEndpoints.getProfile(storedUser.email));

            if (customerResponse is Map<String, dynamic>) {
              // Update stored user with fresh data
              final updatedUser = User.fromJson(customerResponse);
              await prefs.setString('current_user', json.encode(updatedUser.toJson()));
              return updatedUser;
            }
          } catch (e) {
            // print('Error fetching fresh customer data: $e');
            // Return stored user as fallback
            return storedUser;
          }
        }

        return storedUser;
      }

      return null;
    } catch (e) {
      // print('Error getting current user: $e');
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Google Sign In
  Future<AuthResponse> googleSignIn() async {
    try {
      final googleAuthService = GoogleAuthService();
      final authResponse = await googleAuthService.signInAndAuthenticate();

      // Store token if login successful
      if (authResponse.success && authResponse.token != null) {
        await _apiService.setAuthToken(authResponse.token!);
        
        // Store user data for auto login
        if (authResponse.user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', json.encode(authResponse.user!.toJson()));
          // print('DEBUG: Google user data stored successfully');
        }
      }

      return authResponse;
    } catch (e) {
      if (e is ApiError) {
        return AuthResponse(
          success: false,
          message: e.message,
        );
      }
      return AuthResponse(
        success: false,
        message: 'Google sign in failed: ${e.toString()}',
      );
    }
  }

  // Get stored auth token
  Future<String?> getAuthToken() async {
    return await _apiService.getAuthToken();
  }
}