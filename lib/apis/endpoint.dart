// API Endpoints Configuration
class ApiEndpoints {
  // Base URL - Update this to your actual backend URL

  // static const String baseUrl = 'http://172.16.2.9:8080/apis/v1'; //Trung

  static const String baseUrl = 'http://192.168.1.23:8080/apis/v1'; //Quyen

  // static const String baseUrl = 'http://10.0.2.2:8080/apis/v1'; //Kiet

  // Authentication endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String mobileRegister = '$baseUrl/auth/mobile-register';
  static const String verifyOtp = '$baseUrl/auth/verifyOtpCode';
  static const String logout = '$baseUrl/auth/logout';
  static const String googleLogin = '$baseUrl/auth/google-login';
  static const String googleLoginMobile = '$baseUrl/auth/google-login-mobile';
  static const String phoneLogin = '$baseUrl/auth/phone-login';
  static const String phoneLoginMobile = '$baseUrl/auth/phone-login-mobile';

  // User endpoints
  static String getProfile(String email) => '$baseUrl/customers/email/$email';
  static const String updateProfile = '$baseUrl/customers/update';
  static const String changePassword = '$baseUrl/customers/updatePassword';

  static String trackOrder(String orderCode) =>
      '$baseUrl/orders/search/$orderCode';

  // MenuMeal endpoints
  var menuMeals = '$baseUrl/menu-meals/customers';
  var menuMealBySlug = '$baseUrl/menu-meals/customers/slug/:slug';

  //reivew menu meal
  var getMenuMealReviews = '$baseUrl/menu-meal-reviews/menu-meal/:menuMealId';
  var createMenuMealReview = '$baseUrl/menu-meal-reviews';
  var updateMenuMealReview = '$baseUrl/menu-meal-reviews/:reviewId';

  // CustomMeal endpoints
  var createCustomMeal = '$baseUrl/custom-meals';
  var getCustomMealsForCustomer = '$baseUrl/custom-meals/customer/:customerId';
  var updateCustomMeal = '$baseUrl/custom-meals/:id';

  // Ingredient endpoints
  var ingredients = '$baseUrl/ingredients';
  var ingredientById = '$baseUrl/ingredients/:id';

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

  // Customer coupons
  static String getAvailableCustomerCoupons(int customerId) => '$baseUrl/customer-coupons/customer/$customerId/available';
  static String validateVoucherCode(String code, int customerId, {double? orderValue}) {
    final params = orderValue != null ? '?orderValue=$orderValue' : '';
    return '$baseUrl/coupons/validate/$code?customerId=$customerId$params';
  }

  // Week Meal Plan endpoints
  // var getWeekMealPlan = '$baseUrl/week-meals';
  // var getByIdWeekMeal = '$baseUrl/week-meals/:id';
  // var getWeekMealDays = '$baseUrl/week-meals/:weekMealId/days';
  // var getWeekMealDayById = '$baseUrl/week-meals/:weekMealId/days/:dayId';

  static const String submitFeedback = '$baseUrl/feedback';
  static const String submitSupportRequest = '$baseUrl/support-request';

  // Timeout configurations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Feedback endpoints
  static const String submitFeedback = '$baseUrl/support/feedback';
  static const String submitSupportRequest = '$baseUrl/support/ticket';

}
