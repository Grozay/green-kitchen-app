// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - Update this to your actual backend URL
  static const String baseUrls = 'http://192.168.1.123:8080/apis/v1';

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
