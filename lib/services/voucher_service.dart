import 'dart:convert';
import 'package:http/http.dart' as http;
import '../apis/endpoint.dart';

class VoucherService {
  // Get all available vouchers for a customer
  static Future<List<Map<String, dynamic>>> getAvailableVouchers({
    required int customerId,
    double? orderValue,
  }) async {
    try {
      final url = Uri.parse('${ApiEndpoints.baseUrl}/coupons/available');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final vouchers = data.map((item) {
          return {
            'id': item['id'].toString(),
            'code': item['code'] as String,
            'name': item['name'] as String,
            'description': item['description'] as String? ?? '',
            'type': item['type'] as String,
            'discountValue': (item['discountValue'] as num).toDouble(),
            'maxDiscount': item['maxDiscount'] as double?,
            'pointsRequired': (item['pointsRequired'] as num).toDouble(),
            'validUntil': item['validUntil'] as String,
            'exchangeLimit': item['exchangeLimit'] as int?,
            'exchangeCount': (item['exchangeCount'] as num?)?.toInt() ?? 0,
            'status': item['status'] as String,
            'applicability': item['applicability'] as String,
            'isActive': item['status'] == 'ACTIVE',
            'usageLimit': null,
            'usedCount': 0,
          };
        }).toList();

        // Filter by order value if provided (optional)
        if (orderValue != null) {
          return vouchers.where((voucher) {
            // You can add order value filtering logic here if needed
            return true; // For now, return all
          }).toList();
        }

        return vouchers;
      } else {
        throw Exception('Failed to load vouchers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load vouchers: $e');
    }
  }

  // Validate voucher code
  static Future<Map<String, dynamic>?> validateVoucherCode(
    String code, {
    required double orderValue,
    int? customerId,
  }) async {
    try {
      if (customerId == null) {
        throw Exception('Customer ID is required');
      }

      final url = Uri.parse(ApiEndpoints.validateVoucherCode(code, customerId, orderValue: orderValue));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'id': data['id'].toString(),
          'code': data['code'] as String,
          'name': data['name'] as String,
          'description': data['description'] as String? ?? '',
          'discountType': data['discountType'] == 'PERCENTAGE' ? 'percentage' : 'fixed',
          'discountValue': (data['discountValue'] as num).toDouble(),
          'maximumDiscount': data['maxDiscount'] as double?,
          'pointsRequired': (data['pointsRequired'] as num?)?.toDouble() ?? 0.0,
          'expiresAt': data['expiresAt'] as String,
        };
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Invalid voucher code');
      } else {
        throw Exception('Failed to validate voucher: ${response.statusCode}');
      }
    } catch (e) {
      return null;
    }
  }

  // Calculate discount amount for a voucher
  static double calculateDiscountAmount(
    Map<String, dynamic> voucher,
    double orderValue,
  ) {
    final discountType = voucher['discountType'];
    final discountValue = voucher['discountValue'] as double;
    final maximumDiscount = voucher['maximumDiscount'] as double?;

    double discount = 0.0;

    if (discountType == 'PERCENTAGE') {
      discount = orderValue * (discountValue / 100);
    } else if (discountType == 'FIXED_AMOUNT') {
      discount = discountValue;
    }

    // Apply maximum discount limit if set
    if (maximumDiscount != null && discount > maximumDiscount) {
      discount = maximumDiscount;
    }

    return discount;
  }

  // Apply voucher to order
  static Future<bool> applyVoucher({
    required int customerId,
    required String voucherId,
    required String orderId,
  }) async {
    try {
      // In real app, this would call the API to apply voucher
      // final response = await http.post(
      //   Uri.parse('${ApiEndpoints.baseUrl}/orders/$orderId/apply-voucher'),
      //   body: jsonEncode({
      //     'customerId': customerId,
      //     'voucherId': voucherId,
      //   }),
      // );

      // For demo, simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      throw Exception('Failed to apply voucher: $e');
    }
  }

  // Get customer's voucher history
  static Future<List<Map<String, dynamic>>> getCustomerVoucherHistory(int customerId) async {
    try {
      // In real app, this would call the API
      // final response = await http.get(Uri.parse('${ApiEndpoints.baseUrl}/customers/$customerId/voucher-history'));

      // For demo, return empty list
      await Future.delayed(const Duration(milliseconds: 300));
      return [];
    } catch (e) {
      throw Exception('Failed to load voucher history: $e');
    }
  }

  // Exchange points for voucher (loyalty program)
  static Future<List<Map<String, dynamic>>> getExchangeableVouchers() async {
    try {
      // In real app, this would call the API
      // final response = await http.get(Uri.parse('${ApiEndpoints.baseUrl}/vouchers/exchangeable'));

      // For demo, return some exchangeable vouchers
      await Future.delayed(const Duration(milliseconds: 300));

      return [
        {
          'id': '5',
          'name': 'Đổi điểm - Giảm 20k',
          'description': 'Đổi 100 điểm lấy voucher giảm 20k',
          'pointsRequired': 100,
          'discountType': 'FIXED_AMOUNT',
          'discountValue': 20000.0,
          'minimumOrderValue': 100000.0,
          'validDays': 30,
        },
        {
          'id': '6',
          'name': 'Đổi điểm - Giảm 5%',
          'description': 'Đổi 200 điểm lấy voucher giảm 5%',
          'pointsRequired': 200,
          'discountType': 'PERCENTAGE',
          'discountValue': 5.0,
          'minimumOrderValue': 200000.0,
          'validDays': 30,
        },
      ];
    } catch (e) {
      throw Exception('Failed to load exchangeable vouchers: $e');
    }
  }

  // Exchange points for voucher
  static Future<bool> exchangeVoucher({
    required int customerId,
    required String voucherId,
  }) async {
    try {
      // In real app, this would call the API
      // final response = await http.post(
      //   Uri.parse('${ApiEndpoints.baseUrl}/customers/$customerId/exchange-voucher'),
      //   body: jsonEncode({'voucherId': voucherId}),
      // );

      // For demo, simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      throw Exception('Failed to exchange voucher: $e');
    }
  }

  // Format voucher display text
  static String formatVoucherDisplay(Map<String, dynamic> voucher) {
    final discountType = voucher['discountType'];
    final discountValue = voucher['discountValue'];

    if (discountType == 'PERCENTAGE') {
      return '${discountValue.toInt()}%';
    } else {
      return '${_formatPrice(discountValue)}₫';
    }
  }

  // Format price helper
  static String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}