import '../apis/endpoint.dart';
import '../services/service.dart';

class CustomerCouponService {
  static final ApiService _apiService = ApiService();

  static Future<void> useCoupon({
    required String couponId,
    required String orderId,
  }) async {
    try {
      final data = {
        'id': couponId,
        'usedAt': DateTime.now().toIso8601String(),
        'orderId': orderId,
        'status': 'USED',
      };
      await _apiService.put(ApiEndpoints.customerUseCoupon, body: data);
    } catch (e) {
      throw Exception('Failed to update coupon usage: $e');
    }
  }
}
