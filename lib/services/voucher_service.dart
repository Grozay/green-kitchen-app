class VoucherService {
  // Fake voucher data for demo purposes
  static final List<Map<String, dynamic>> _fakeVouchers = [
    {
      'id': '1',
      'code': 'GREEN10',
      'name': 'Giảm 10%',
      'description': 'Giảm 10% cho đơn hàng từ 100k',
      'discountType': 'PERCENTAGE',
      'discountValue': 10.0,
      'minimumOrderValue': 100000.0,
      'maximumDiscount': null,
      'expiresAt': '2024-12-31T23:59:59Z',
      'isActive': true,
      'usageLimit': null,
      'usedCount': 0,
    },
    {
      'id': '2',
      'code': 'SHIPFREE',
      'name': 'Miễn phí giao hàng',
      'description': 'Miễn phí giao hàng cho đơn hàng từ 150k',
      'discountType': 'FIXED_AMOUNT',
      'discountValue': 25000.0,
      'minimumOrderValue': 150000.0,
      'maximumDiscount': null,
      'expiresAt': '2024-12-31T23:59:59Z',
      'isActive': true,
      'usageLimit': null,
      'usedCount': 0,
    },
    {
      'id': '3',
      'code': 'NEWUSER',
      'name': 'Khách hàng mới',
      'description': 'Giảm 50k cho khách hàng mới',
      'discountType': 'FIXED_AMOUNT',
      'discountValue': 50000.0,
      'minimumOrderValue': 200000.0,
      'maximumDiscount': null,
      'expiresAt': '2024-12-31T23:59:59Z',
      'isActive': true,
      'usageLimit': 1,
      'usedCount': 0,
    },
    {
      'id': '4',
      'code': 'FLASH50',
      'name': 'Flash Sale',
      'description': 'Giảm 50k cho đơn hàng từ 300k',
      'discountType': 'FIXED_AMOUNT',
      'discountValue': 50000.0,
      'minimumOrderValue': 300000.0,
      'maximumDiscount': 50000.0,
      'expiresAt': '2024-12-31T23:59:59Z',
      'isActive': true,
      'usageLimit': 100,
      'usedCount': 45,
    },
  ];

  // Get all available vouchers for a customer
  static Future<List<Map<String, dynamic>>> getAvailableVouchers({
    required int customerId,
    double? orderValue,
  }) async {
    try {
      // In real app, this would call the API with customer ID
      // final response = await http.get(Uri.parse('${ApiEndpoints.baseUrl}/customers/$customerId/vouchers'));

      // For demo, filter fake data based on criteria
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay

      final now = DateTime.now();
      final availableVouchers = _fakeVouchers.where((voucher) {
        // Check if voucher is active and not expired
        if (!voucher['isActive']) return false;

        final expiresAt = DateTime.parse(voucher['expiresAt']);
        if (expiresAt.isBefore(now)) return false;

        // Check usage limit
        final usageLimit = voucher['usageLimit'];
        final usedCount = voucher['usedCount'];
        if (usageLimit != null && usedCount >= usageLimit) return false;

        // Check minimum order value if provided
        final minOrderValue = voucher['minimumOrderValue'];
        if (orderValue != null && minOrderValue != null && orderValue < minOrderValue) {
          return false;
        }

        return true;
      }).toList();

      return availableVouchers;
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
      final vouchers = await getAvailableVouchers(
        customerId: customerId ?? 0,
        orderValue: orderValue,
      );

      return vouchers.firstWhere(
        (voucher) => voucher['code'].toString().toUpperCase() == code.toUpperCase(),
      );
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