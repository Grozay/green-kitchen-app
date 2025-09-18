import 'package:green_kitchen_app/utils/api_error.dart';
import '../models/cart.dart'; // Giả định bạn có model Cart
import '../apis/endpoint.dart';
import '../services/service.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final ApiService _apiService = ApiService();

  // Initialize service
  Future<void> init() async {
    await _apiService.init();
  }

  // Get cart by customer ID
  Future<Cart> getCartByCustomerId(int customerId) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.getCartByCustomerId.replaceFirst(
        ':customerId',
        customerId.toString(),
      );
      final response = await _apiService.get(url);
      return Cart.fromJson(response);
    } catch (e) {
      print('Error in getCartByCustomerId: $e'); // Debug error
      if (e is ApiError) {
        throw Exception('Failed to load cart: ${e.message}');
      }
      throw Exception('Failed to load cart: ${e.toString()}');
    }
  }

  // Add meal to cart
  Future<Cart> addMealToCart(int customerId, Map<String, dynamic> data) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.addMealToCart.replaceFirst(
        ':customerId',
        customerId.toString(),
      );
      final response = await _apiService.post(url, body: data);
      return Cart.fromJson(response);
    } catch (e) {
      if (e is ApiError) {
        throw Exception('Failed to add meal to cart: ${e.message}');
      }
      throw Exception('Failed to add meal to cart: ${e.toString()}');
    }
  }

  // Increase quantity
  Future<Cart> increaseQuantity(int customerId, int cartItemId) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.increaseMealQuantityInCart
          .replaceFirst(':customerId', customerId.toString())
          .replaceFirst(':cartItemId', cartItemId.toString());

      print('DEBUG: Increase quantity URL: $url'); // Debug log

      final response = await _apiService.post(url); // Thay đổi từ put sang post

      print('DEBUG: Increase quantity response: $response'); // Debug log

      return Cart.fromJson(response);
    } catch (e) {
      print('DEBUG: Increase quantity error: $e'); // Debug log
      if (e is ApiError) {
        throw Exception('Failed to increase quantity: ${e.message}');
      }
      throw Exception('Failed to increase quantity: ${e.toString()}');
    }
  }

  // Decrease quantity
  Future<Cart> decreaseQuantity(int customerId, int cartItemId) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.decreaseMealQuantityInCart
          .replaceFirst(':customerId', customerId.toString())
          .replaceFirst(':cartItemId', cartItemId.toString());

      print('DEBUG: Decrease quantity URL: $url'); // Debug log

      final response = await _apiService.post(url); // Thay đổi từ put sang post

      print('DEBUG: Decrease quantity response: $response'); // Debug log

      return Cart.fromJson(response);
    } catch (e) {
      print('DEBUG: Decrease quantity error: $e'); // Debug log
      if (e is ApiError) {
        throw Exception('Failed to decrease quantity: ${e.message}');
      }
      throw Exception('Failed to decrease quantity: ${e.toString()}');
    }
  }

  // Remove from cart
  Future<Cart> removeFromCart(int customerId, int cartItemId) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.removeMealFromCart
          .replaceFirst(':customerId', customerId.toString())
          .replaceFirst(':cartItemId', cartItemId.toString());
      final response = await _apiService.delete(url);
      return Cart.fromJson(response);
    } catch (e) {
      if (e is ApiError) {
        throw Exception('Failed to remove from cart: ${e.message}');
      }
      throw Exception('Failed to remove from cart: ${e.toString()}');
    }
  }

  // Create cart data for adding meal
  static Map<String, dynamic> createAddToCartData({
    required int menuMealId,
    required int quantity,
    required double unitPrice,
    required String title,
    required String description,
    required String image,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    String? specialInstructions,
    bool isCustom = false,
    String itemType = 'MENU_MEAL',
  }) {
    double totalPrice = unitPrice * quantity;
    return {
      'isCustom': isCustom,
      'menuMealId': menuMealId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'title': title,
      'description': description,
      'image': image,
      'itemType': itemType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'specialInstructions': specialInstructions,
    };
  }
}
