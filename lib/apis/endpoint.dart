// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - Update this to your actual backend URL

  // static const String baseUrl = 'http://172.16.2.9:8080/apis/v1'; //Trung
  
  // static const String baseUrl = 'http://192.168.1.23:8080/apis/v1'; //Quyen

  static const String baseUrl = 'http://10.0.2.2:8080/apis/v1'; //Kiet


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
  var menuMeals = '$baseUrl/menu-meals/customers';
  var menuMealBySlug = '$baseUrl/menu-meals/customers/slug/:slug';

  // Ingredient endpoints
  var ingredients = '$baseUrl/ingredients';
  // var ingredientById = '$baseUrl/ingredients/:id';

  // Store endpoints
  var stores = '$baseUrl/stores';

  // Chat endpoints
  static const String chatRoot = '$baseUrl/chat';
  static const String initGuest = '$chatRoot/init-guest';
  static const String send = '$chatRoot/send';
  static const String messagesPaged = '$chatRoot/messages-paged';
  static const String messages = '$chatRoot/messages';
  static const String conversations = '$chatRoot/conversations';
  static const String markRead = '$chatRoot/mark-read';

  //cart
  var getCartByCustomerId = '$baseUrl/carts/customer/:customerId';
  var addMealToCart = '$baseUrl/carts/customer/items/:customerId';
  var removeMealFromCart =
      '$baseUrl/carts/customer/:customerId/items/:cartItemId';
  var increaseMealQuantityInCart =
      '$baseUrl/carts/customer/:customerId/items/:cartItemId/increase';
  var decreaseMealQuantityInCart =
      '$baseUrl/carts/customer/:customerId/items/:cartItemId/decrease';

  // Week Meal Plan endpoints
  var getWeekMealPlan = '$baseUrl/week-meals';
  var getByIdWeekMeal = '$baseUrl/week-meals/:id';
  var getWeekMealDays = '$baseUrl/week-meals/:weekMealId/days';
  var getWeekMealDayById = '$baseUrl/week-meals/:weekMealId/days/:dayId';

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  //profile
  
}

// //endpoint
// var baseUrl = 'http://192.168.1.172:8080';
