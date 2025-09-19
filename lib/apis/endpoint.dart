// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - Update this to your actual backend URL
  static const String baseUrls = 'http://192.168.1.23:8080/apis/v1';
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

  static String trackOrder(String orderCode) => '$baseUrl/orders/search/$orderCode';

  //endpoint
  // static const String baseUrl = 'http://192.168.1.23:8080';

  // MenuMeal endpoints
  var menuMeals = '$baseUrls/menu-meals/customers';
  var menuMealBySlug = '$baseUrls/menu-meals/customers/slug/:slug';

  // Ingredient endpoints
  var ingredients = '$baseUrls/ingredients';
  // var ingredientById = '$baseUrl/ingredients/:id';

  //cart
  var getCartByCustomerId = '$baseUrls/carts/customer/:customerId';
  var addMealToCart = '$baseUrls/carts/customer/items/:customerId';
  var removeMealFromCart =
      '$baseUrls/carts/customer/:customerId/items/:cartItemId';
  var increaseMealQuantityInCart =
      '$baseUrls/carts/customer/:customerId/items/:cartItemId/increase';
  var decreaseMealQuantityInCart =
      '$baseUrls/carts/customer/:customerId/items/:cartItemId/decrease';

  // Week Meal Plan endpoints
  var getWeekMealPlan = '$baseUrls/week-meals';
  var getByIdWeekMeal = '$baseUrls/week-meals/:id';
  var getWeekMealDays = '$baseUrls/week-meals/:weekMealId/days';
  var getWeekMealDayById = '$baseUrls/week-meals/:weekMealId/days/:dayId';

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

// //endpoint
// var baseUrl = 'http://192.168.1.172:8080';
