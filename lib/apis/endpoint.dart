// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - Update this to your actual backend URL
  static const String baseUrl = 'http://10.0.2.2:8080/apis/v1';

  // Authentication endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String mobileRegister = '$baseUrl/auth/mobile-register';
  static const String verifyOtp = '$baseUrl/auth/verifyOtpCode';
  static const String logout = '$baseUrl/auth/logout';
  static const String googleLogin = '$baseUrl/auth/google-login';
  static const String googleLoginMobile = '$baseUrl/auth/google-login-mobile';
  static const String phoneLogin = '$baseUrl/auth/phone-login';

  // User endpoints
  static const String getProfile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile';

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}