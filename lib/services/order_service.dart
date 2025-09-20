import '../apis/endpoint.dart';
import '../models/order_model.dart';
import '../models/create_order_request.dart';
import '../services/service.dart';

class OrderService {
  static final ApiService _apiService = ApiService();

  // Initialize service
  static Future<void> init() async {
    await _apiService.init();
  }
  static Future<OrderModel?> trackOrder(String orderCode) async {
    try {
      final response = await _apiService.get(ApiEndpoints.trackOrder(orderCode));

      if (response is Map<String, dynamic>) {
        return OrderModel.fromJson(response);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      if (e.toString().contains('Order not found')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Create order
  static Future<OrderModel> createOrder({
    required int customerId,
    required String street,
    required String ward,
    required String district,
    required String city,
    required String recipientName,
    required String recipientPhone,
    required DateTime? deliveryTime,
    required double subtotal,
    required double shippingFee,
    required double totalAmount,
    required String paymentMethod,
    required List<OrderItemRequest> orderItems,
    double? membershipDiscount,
    double? couponDiscount,
    String? paypalOrderId,
    String? notes,
  }) async {
    try {
      final createOrderRequest = CreateOrderRequest(
        customerId: customerId,
        street: street,
        ward: ward,
        district: district,
        city: city,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        deliveryTime: deliveryTime,
        subtotal: subtotal,
        shippingFee: shippingFee,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        orderItems: orderItems,
        membershipDiscount: membershipDiscount,
        couponDiscount: couponDiscount,
        paypalOrderId: paypalOrderId,
        notes: notes,
      );

      final response = await _apiService.post(
        '${ApiEndpoints.baseUrl}/orders',
        body: createOrderRequest.toJson(),
      );

      if (response is Map<String, dynamic>) {
        return OrderModel.fromJson(response);
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Process COD payment
  static Future<Map<String, dynamic>> processCodPayment({
    required String orderId,
    required double amount,
  }) async {
    try {
      final paymentData = {
        'orderId': orderId,
        'amount': amount,
        'paymentMethod': 'COD',
        'status': 'PENDING',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await _apiService.post(
        '${ApiEndpoints.baseUrl}/payments/cod',
        body: paymentData,
      );

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      // If payment processing fails, don't throw error - just log it
      // The order was already created successfully
      print('Warning: COD payment processing failed: $e');
      return {
        'orderId': orderId,
        'amount': amount,
        'status': 'PENDING',
        'message': 'Payment processing will be handled manually'
      };
    }
  }

  // Process PayPal payment
  static Future<Map<String, dynamic>> processPayPalPayment({
    required String orderId,
    required double amount,
    required String paypalOrderId,
    required String payerId,
  }) async {
    try {
      final paymentData = {
        'orderId': orderId,
        'amount': amount,
        'paymentMethod': 'PAYPAL',
        'paypalOrderId': paypalOrderId,
        'payerId': payerId,
        'status': 'COMPLETED',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final response = await _apiService.post(
        '${ApiEndpoints.baseUrl}/payments/paypal',
        body: paymentData,
      );

      if (response is Map<String, dynamic>) {
        return response;
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      // If payment processing fails, don't throw error - just log it
      // The order was already created successfully
      print('Warning: PayPal payment processing failed: $e');
      return {
        'orderId': orderId,
        'amount': amount,
        'paypalOrderId': paypalOrderId,
        'status': 'COMPLETED',
        'message': 'Payment processing will be handled manually'
      };
    }
  }

  // Get exchange rate for PayPal conversion
  static Future<double> getExchangeRate() async {
    try {
      final response = await _apiService.get('${ApiEndpoints.baseUrl}/exchange-rate/usd-vnd');

      if (response is Map<String, dynamic> && response.containsKey('rate')) {
        return (response['rate'] as num).toDouble();
      } else {
        return 23000.0; // Default fallback rate
      }
    } catch (e) {
      return 23000.0; // Default fallback rate
    }
  }
}