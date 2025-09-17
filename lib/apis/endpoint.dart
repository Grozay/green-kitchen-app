// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - Update this to your actual backend URL
  static const String baseUrls = 'http://10.0.2.2:8080/apis/v1';

  // Authentication endpoints
  static const String login = '$baseUrls/auth/login';
  static const String register = '$baseUrls/auth/register';
  static const String mobileRegister = '$baseUrls/auth/mobile-register';
  static const String verifyOtp = '$baseUrls/auth/verifyOtpCode';
  static const String logout = '$baseUrls/auth/logout';
  static const String googleLogin = '$baseUrls/auth/google-login';
  static const String googleLoginMobile = '$baseUrls/auth/google-login-mobile';
  static const String phoneLogin = '$baseUrls/auth/phone-login';

  // User endpoints
  static const String getProfile = '$baseUrls/user/profile';
  static const String updateProfile = '$baseUrls/user/profile';

  

  //endpoint
  static const String baseUrl = 'http://192.168.1.23:8080';

  static const String menuMeals = '$baseUrl/apis/v1/menu-meals/customers';
  static const String menuMealBySlug = '$baseUrl/apis/v1/menu-meals/customers/slug/:slug';

  // Cart endpoints
  var getCartByCustomerId = '$baseUrl/apis/v1/cart/customers/:customerId';
  var addMealToCart = '$baseUrl/apis/v1/cart/customers/:customerId/meals';
  var removeMealFromCart =
      '$baseUrl/apis/v1/cart/customers/:customerId/cart-items/:cartItemId';
  var increaseMealQuantityInCart =
      '$baseUrl/apis/v1/cart/customers/:customerId/cart-items/:cartItemId/increase';
  var decreaseMealQuantityInCart =
      '$baseUrl/apis/v1/cart/customers/:customerId/cart-items/:cartItemId/decrease';

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
