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
      // print('Error in getCartByCustomerId: $e'); // Debug error
      if (e is ApiError) {
        throw Exception('Failed to load cart: ${e.message}');
      }
      throw Exception('Failed to load cart: ${e.toString()}');
    }
  }

  // Increase quantity - Sửa để fetch lại full cart sau khi update
  Future<Cart> increaseQuantity(int customerId, int cartItemId) async {
    try {
      final endpoints = ApiEndpoints();
      final updateUrl = endpoints.increaseMealQuantityInCart
          .replaceFirst(':customerId', customerId.toString())
          .replaceFirst(':cartItemId', cartItemId.toString());

      // print('DEBUG: Increase quantity URL: $updateUrl');

      // Gọi API increase (chỉ để update)
      await _apiService.post(updateUrl);

      // Sau đó fetch lại full cart
      return await getCartByCustomerId(customerId);
    } catch (e) {
      // print('DEBUG: Increase quantity error: $e');
      if (e is ApiError) {
        throw Exception('Failed to increase quantity: ${e.message}');
      }
      throw Exception('Failed to increase quantity: ${e.toString()}');
    }
  }

  // Decrease quantity - Sửa để fetch lại full cart sau khi update
  Future<Cart> decreaseQuantity(int customerId, int cartItemId) async {
    try {
      final endpoints = ApiEndpoints();
      final updateUrl = endpoints.decreaseMealQuantityInCart
          .replaceFirst(':customerId', customerId.toString())
          .replaceFirst(':cartItemId', cartItemId.toString());

      // print('DEBUG: Decrease quantity URL: $updateUrl');

      // Gọi API decrease (chỉ để update)
      await _apiService.post(updateUrl);

      // Sau đó fetch lại full cart
      return await getCartByCustomerId(customerId);
    } catch (e) {
      // print('DEBUG: Decrease quantity error: $e');
      if (e is ApiError) {
        throw Exception('Failed to decrease quantity: ${e.message}');
      }
      throw Exception('Failed to decrease quantity: ${e.toString()}');
    }
  }

  Future<Cart> removeFromCart(int customerId, int cartItemId) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.removeMealFromCart
          .replaceFirst(':customerId', customerId.toString())
          .replaceFirst(':cartItemId', cartItemId.toString());
      
      // print('DEBUG: Remove from cart URL: $url');
      
      await _apiService.delete(url);
      
      return await getCartByCustomerId(customerId);
    } catch (e) {
      if (e is ApiError) {
        if (e.statusCode >= 200 && e.statusCode < 300 || e.statusCode == 404) {
          try {
            return await getCartByCustomerId(customerId);
          } catch (fetchError) {
            return Cart(
              id: 0,
              customerId: customerId,
              cartItems: [],
              totalAmount: 0.0,
              totalItems: 0,
              totalQuantity: 0,
            );
          }
        }
        
        throw Exception('Failed to remove from cart: ${e.toString()}');
      }
      
      throw Exception('Failed to remove from cart: ${e.toString()}');
    }
  }

  // Add meal to cart - Sửa để fetch lại full cart sau khi add
  Future<Cart> addMealToCart(int customerId, Map<String, dynamic> data) async {
    try {
      final endpoints = ApiEndpoints();
      final url = endpoints.addMealToCart.replaceFirst(
        ':customerId',
        customerId.toString(),
      );
      
      // print('DEBUG: Add to cart URL: $url');
      // print('DEBUG: Add to cart data: $data');
      
      // Gọi API add (chỉ để thêm)
      await _apiService.post(url, body: data);
      
      // Sau đó fetch lại full cart
      return await getCartByCustomerId(customerId);
    } catch (e) {
      // print('DEBUG: Add to cart error: $e');
      if (e is ApiError) {
        throw Exception('Failed to add meal to cart: ${e.message}');
      }
      throw Exception('Failed to add meal to cart: ${e.toString()}');
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
