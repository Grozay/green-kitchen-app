import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/voucher_service.dart';

class Coupon {
  final String id;
  final String code;
  final String description;
  final double discount;
  final String discountType; // 'percentage' or 'fixed'
  final double minOrder;
  final DateTime expiryDate;

  const Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.discount,
    required this.discountType,
    required this.minOrder,
    required this.expiryDate,
  });

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'].toString(),
      code: map['code'] as String,
      description: map['description'] as String,
      discount: (map['discountValue'] as num).toDouble(),
      discountType: (map['discountType'] as String).toLowerCase(),
      minOrder: (map['minimumOrderValue'] as num?)?.toDouble() ?? 0.0,
      expiryDate: DateTime.parse(map['expiresAt'] as String),
    );
  }

  bool get isValid => DateTime.now().isBefore(expiryDate);
}

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
        _error = 'Không thể tải danh sách voucher: $e';
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
          const SnackBar(content: Text('Mã voucher không hợp lệ hoặc không đủ điều kiện')),
        );
        return;
      }

      widget.onCouponSelected({
        'id': voucher['id'],
        'code': voucher['code'],
        'description': voucher['description'],
        'discount': voucher['discountValue'],
        'discountType': voucher['discountType'].toLowerCase(),
        'minOrder': voucher['minimumOrderValue'],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã áp dụng voucher ${voucher['code']}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra khi áp dụng voucher')),
      );
    }
  }

  void _removeCoupon() {
    widget.onCouponSelected({});
    _couponController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Đang tải danh sách voucher...'),
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
              child: const Text('Thử lại'),
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
          // Coupon input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã voucher',
                    filled: true,
                    fillColor: AppColors.inputFill,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.inputBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.secondary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_couponController.text.isNotEmpty) {
                    try {
                      _applyCoupon(_couponController.text);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mã voucher không hợp lệ')),
                      );
                    }
                  }
                },
                child: const Text(
                  'Áp dụng',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

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
            child: Row(
              children: [
                Text(
                  'Voucher có sẵn',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),

          // Available coupons list
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            ..._availableCoupons.where((coupon) => coupon.isValid).map(
              (coupon) => _buildCouponOption(coupon),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponOption(Coupon coupon) {
    final isSelected = widget.selectedCoupon?['id'] == coupon.id;

    return GestureDetector(
      onTap: () {
        _couponController.text = coupon.code;
        _applyCoupon(coupon.code);
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
                    coupon.discountType == 'percentage'
                        ? '${(coupon.discount * 100).toInt()}%'
                        : '${coupon.discount.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              coupon.description,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Đơn tối thiểu: ${coupon.minOrder.toStringAsFixed(0)}đ',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}