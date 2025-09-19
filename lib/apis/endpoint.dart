// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - Update this to your actual backend URL
  // static const String baseUrl = 'http://192.168.1.23:8080/apis/v1';
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
  static String getProfile(String email) => '$baseUrl/customers/email/$email';
  static const String updateProfile = '$baseUrl/customers/update';
  static const String changePassword = '$baseUrl/customers/updatePassword';

  //Order endpoints
  static String trackOrder(String orderCode) => '$baseUrl/orders/search/$orderCode';

  // Menu endpoints
  static const String menuMeals = '$baseUrl/menu-meals/customers';
  static const String menuMealBySlug = '$baseUrl/menu-meals/customers/slug/:slug';
  

  // Cart endpoints
  var getCartByCustomerId = '$baseUrl/cart/customers/:customerId';
  var addMealToCart = '$baseUrl/cart/customers/:customerId/meals';
  var removeMealFromCart =
      '$baseUrl/cart/customers/:customerId/cart-items/:cartItemId';
  var increaseMealQuantityInCart =
      '$baseUrl/cart/customers/:customerId/cart-items/:cartItemId/increase';
  var decreaseMealQuantityInCart =
      '$baseUrl/cart/customers/:customerId/cart-items/:cartItemId/decrease';

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
