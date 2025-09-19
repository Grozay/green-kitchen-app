import 'dart:convert';
import 'package:http/http.dart' as http;
import '../apis/endpoint.dart';
import '../models/order_model.dart';

class OrderService {
  static Future<OrderModel?> trackOrder(String orderCode) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.trackOrder(orderCode)),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Order not found');
      } else {
        throw Exception('Failed to track order: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('Order not found')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}