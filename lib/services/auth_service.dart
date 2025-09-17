import '../apis/endpoint.dart';
import '../models/model.dart';
import '../services/service.dart';
import '../services/google_auth_service.dart';

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
      final loginRequest = LoginRequest(email: email, password: password);
      final response = await _apiService.post(
        ApiEndpoints.login,
        body: loginRequest.toJson(),
        includeAuth: false, // No auth token needed for login
      );

      final authResponse = AuthResponse.fromJson(response);

      // Store token if login successful
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
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  // Register new user
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

      return AuthResponse(
        success: true,
        message: 'Logged out successfully',
      );
    } catch (e) {
      // Even if API call fails, clear local token
      await _apiService.clearAuthToken();

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
      final response = await _apiService.get(ApiEndpoints.getProfile);
      return User.fromJson(response['user']);
    } catch (e) {
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