//endpoint
var baseUrl = 'http://192.168.1.23:8080';

var menuMeals = '$baseUrl/apis/v1/menu-meals/customers';
var menuMealBySlug = '$baseUrl/apis/v1/menu-meals/customers/slug/:slug';

// Cart endpoints
var getCartByCustomerId = '$baseUrl/apis/v1/cart/customers/:customerId';
var addMealToCart = '$baseUrl/apis/v1/cart/customers/:customerId/meals';
var removeMealFromCart = '$baseUrl/apis/v1/cart/customers/:customerId/cart-items/:cartItemId';
var increaseMealQuantityInCart = '$baseUrl/apis/v1/cart/customers/:customerId/cart-items/:cartItemId/increase';
var decreaseMealQuantityInCart = '$baseUrl/apis/v1/cart/customers/:customerId/cart-items/:cartItemId/decrease';