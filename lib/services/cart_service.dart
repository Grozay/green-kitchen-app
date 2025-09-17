import 'dart:convert';
import 'package:http/http.dart' as http;
import '../apis/endpoint.dart';
import '../models/cart.dart';

class CartService {
  // Get cart by customer ID
  static Future<Cart> getCartByCustomerId(int customerId) async {
    final url = '$baseUrl/apis/v1/cart/customers/$customerId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to load cart');
    }
  }

  // Add meal to cart
  static Future<Cart> addMealToCart(int customerId, Map<String, dynamic> data) async {
    final url = '$baseUrl/apis/v1/cart/customers/$customerId/meals';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to add meal to cart');
    }
  }

  // Increase quantity
  static Future<Cart> increaseQuantity(int customerId, int cartItemId) async {
    final url = '$baseUrl/apis/v1/cart/customers/$customerId/cart-items/$cartItemId/increase';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to increase quantity');
    }
  }

  // Decrease quantity
  static Future<Cart> decreaseQuantity(int customerId, int cartItemId) async {
    final url = '$baseUrl/apis/v1/cart/customers/$customerId/cart-items/$cartItemId/decrease';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to decrease quantity');
    }
  }

  // Remove from cart
  static Future<Cart> removeFromCart(int customerId, int cartItemId) async {
    final url = '$baseUrl/apis/v1/cart/customers/$customerId/cart-items/$cartItemId';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Cart.fromJson(data);
    } else {
      throw Exception('Failed to remove from cart');
    }
  }

  // Create cart data for adding meal
  static Map<String, dynamic> createAddToCartData({
    required int menuMealId,
    required int quantity,
    String? specialInstructions,
  }) {
    return {
      'menuMealId': menuMealId,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
    };
  }
}
