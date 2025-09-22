import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../services/voucher_service.dart';
import '../../../models/coupon.dart';
import '../../../provider/auth_provider.dart';

class CouponSelector extends StatefulWidget {
  final Map<String, dynamic>? selectedCoupon;
  final Function(Map<String, dynamic>) onCouponSelected;

  const CouponSelector({
    super.key,
    this.selectedCoupon,
    required this.onCouponSelected,
  });

  @override
  State<CouponSelector> createState() => _CouponSelectorState();
}

class _CouponSelectorState extends State<CouponSelector> {
  final TextEditingController _couponController = TextEditingController();
  bool _isExpanded = false;
  bool _isCustomerCouponsExpanded = false;
  List<Coupon> _availableCoupons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // For demo, use a mock customer ID
      const mockCustomerId = 1;
      final vouchers = await VoucherService.getAvailableVouchers(
        customerId: mockCustomerId,
      );
      final coupons = vouchers.map((voucher) => Coupon.fromMap(voucher)).toList();

      setState(() {
        _availableCoupons = coupons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to load voucher list: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(String code) async {
    try {
      // For demo, use a mock customer ID and order value
      const mockCustomerId = 1;
      const mockOrderValue = 100000.0; // Minimum order value for demo

      final voucher = await VoucherService.validateVoucherCode(
        code,
        orderValue: mockOrderValue,
        customerId: mockCustomerId,
      );

      if (!mounted) return;

      if (voucher == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid voucher code or does not meet conditions')),
        );
        return;
      }

      widget.onCouponSelected({
        'id': voucher['id'],
        'code': voucher['code'],
        'description': voucher['description'],
        'discount': voucher['discountValue'],
        'discountType': voucher['discountType'],
        'pointsRequired': voucher['pointsRequired'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied voucher ${voucher['code']}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred while applying voucher')),
      );
    }
  }

  void _removeCoupon() {
    widget.onCouponSelected({});
    _couponController.clear();
  }

  void _applyCouponFromAvailable(Coupon coupon) async {
    try {
      // For demo, use a mock customer ID and order value
      const mockCustomerId = 1;
      const mockOrderValue = 100000.0; // Minimum order value for demo

      final voucher = await VoucherService.validateVoucherCode(
        coupon.code,
        orderValue: mockOrderValue,
        customerId: mockCustomerId,
      );

      if (!mounted) return;

      if (voucher == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid voucher code or does not meet conditions')),
        );
        return;
      }

      widget.onCouponSelected({
        'id': voucher['id'],
        'code': voucher['code'],
        'description': voucher['description'],
        'discount': voucher['discountValue'],
        'discountType': voucher['discountType'],
        'pointsRequired': voucher['pointsRequired'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Applied voucher ${voucher['code']}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred while applying voucher')),
      );
    }
  }

  void _applyCustomerCoupon(Map<String, dynamic> coupon) {
    // CustomerCoupon đã có sẵn thông tin, áp dụng trực tiếp không cần validate
    widget.onCouponSelected({
      'id': coupon['id'],
      'code': coupon['couponCode'],
      'description': coupon['couponDescription'] ?? coupon['couponName'],
      'discount': coupon['couponDiscountValue'],
      'discountType': coupon['couponType'] == 'PERCENTAGE' ? 'percentage' : 'fixed',
      'pointsRequired': coupon['pointsRequired'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied coupon ${coupon['couponCode']}')),
    );
  }

  Future<void> _showExchangeConfirmationDialog(Coupon coupon) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerDetails = authProvider.customerDetails;
    final membershipInfo = customerDetails?['membership'] ?? {};
    final availablePoints = membershipInfo['availablePoints'] ?? 0;
    final pointsRequired = coupon.pointsRequired;

    if (availablePoints < pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient points to exchange this coupon'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exchange Coupon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Do you want to use ${pointsRequired.toStringAsFixed(0)} points to exchange this coupon?'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(coupon.description ?? ''),
                    const SizedBox(height: 4),
                    Text(
                      coupon.type == 'PERCENTAGE'
                          ? '${coupon.discountValue.toInt()}% discount'
                          : '${coupon.discountValue.toStringAsFixed(0)}đ discount',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your points: ${availablePoints.toStringAsFixed(0)} → ${(availablePoints - pointsRequired).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text(
                'Exchange',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _exchangeCoupon(coupon);
    }
  }

  Future<void> _exchangeCoupon(Coupon coupon) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerDetails = authProvider.customerDetails;
      final customerId = customerDetails?['id'] ?? 1;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final newCoupon = await VoucherService.exchangePointsForCoupon(
        customerId: customerId,
        couponId: int.parse(coupon.id),
      );

      // Hide loading
      if (mounted) Navigator.of(context).pop();

      if (newCoupon != null) {
        // Add to customer coupons
        authProvider.addCustomerCoupon(newCoupon);

        // Apply the coupon immediately
        widget.onCouponSelected({
          'id': newCoupon['id'],
          'code': newCoupon['code'],
          'description': newCoupon['description'],
          'discount': newCoupon['discountValue'],
          'discountType': newCoupon['discountType'],
          'pointsRequired': newCoupon['pointsRequired'],
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully exchanged ${newCoupon['code']} with ${coupon.pointsRequired.toStringAsFixed(0)} points'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Hide loading
      if (mounted) Navigator.of(context).pop();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to exchange coupon: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final customerDetails = authProvider.customerDetails;
    final membershipInfo = customerDetails?['membership'] ?? [];
    final customerCoupons = customerDetails?['customerCoupons'] ?? [];

    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading voucher list...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVouchers,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Available Points Display
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Available Points: ${membershipInfo?['availablePoints']?.toString() ?? '0'} pts',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Customer Coupons Section
          if (customerCoupons.isNotEmpty) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _isCustomerCouponsExpanded = !_isCustomerCouponsExpanded;
                });
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.card_giftcard, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your Coupons (${customerCoupons.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Icon(
                      _isCustomerCouponsExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            // Customer Coupons List
            if (_isCustomerCouponsExpanded) ...[
              const SizedBox(height: 12),
              ...customerCoupons.map((coupon) => _buildCustomerCouponOption(coupon)),
            ],

            const SizedBox(height: 16),
          ],


          // Applied coupon display
          if (widget.selectedCoupon != null && widget.selectedCoupon!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.selectedCoupon!['code']}: ${widget.selectedCoupon!['description']}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.green, size: 20),
                    onPressed: _removeCoupon,
                  ),
                ],
              ),
            ),
          ],

          // Available coupons toggle
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Available Coupons for Exchange',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),

          // Available coupons list
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            ..._availableCoupons.where((coupon) => coupon.isValid && coupon.applicability == 'GENERAL').map(
              (coupon) => _buildCouponOption(coupon),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponOption(Coupon coupon) {
    final isSelected = widget.selectedCoupon?['id'] == coupon.id;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final customerDetails = authProvider.customerDetails;
    final membershipInfo = customerDetails?['membership'] ?? {};
    final availablePoints = membershipInfo['availablePoints'] ?? 0;
    final canExchange = availablePoints >= coupon.pointsRequired;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          // Hủy chọn coupon đã được chọn
          _removeCoupon();
        } else {
          // Áp dụng coupon mới
          _applyCouponFromAvailable(coupon);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.inputBorder,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppColors.secondary.withValues(alpha: 0.05) : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  coupon.code,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    coupon.type == 'PERCENTAGE'
                        ? '${coupon.discountValue.toInt()}%'
                        : '${coupon.discountValue.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check_circle,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              coupon.description ?? '',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Points required: ${coupon.pointsRequired.toStringAsFixed(0)} points',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: canExchange ? () => _showExchangeConfirmationDialog(coupon) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canExchange ? Colors.orange : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      'Exchange',
                      style: TextStyle(
                        color: canExchange ? Colors.white : Colors.grey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!canExchange) ...[
              const SizedBox(height: 4),
              Text(
                'Insufficient points (${availablePoints.toStringAsFixed(0)}/${coupon.pointsRequired.toStringAsFixed(0)})',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCouponOption(Map<String, dynamic> coupon) {
    final isAvailable = coupon['status'] == 'AVAILABLE';
    final couponName = coupon['couponName'] ?? 'Coupon';
    final couponCode = coupon['couponCode'] ?? '';
    final discountValue = coupon['couponDiscountValue'] ?? 0;
    final discountType = coupon['couponType'] ?? 'FIXED_AMOUNT';
    final expiresAt = coupon['expiresAt'] != null ? _formatDate(coupon['expiresAt']) : 'N/A';
    final isSelected = widget.selectedCoupon?['id'] == coupon['id'];

    return GestureDetector(
      onTap: () {
        if (isAvailable) {
          if (isSelected) {
            // Hủy chọn coupon đã được chọn
            _removeCoupon();
          } else {
            // Áp dụng customer coupon trực tiếp (không cần validate)
            _applyCustomerCoupon(coupon);
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAvailable ? (isSelected ? Colors.blue.withValues(alpha: 0.05) : Colors.white) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : (isAvailable ? Colors.blue.withValues(alpha: 0.3) : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  color: isAvailable ? Colors.blue : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    couponName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Code: $couponCode',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              'Discount: ${discountType == 'PERCENTAGE' ? '$discountValue%' : '${discountValue.toString()} VND'}',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            Text(
              'Expires: $expiresAt',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable ? Colors.green : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Used',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}