import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

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

  // Mock coupon data - in real app this would come from API
  final List<Coupon> _availableCoupons = [
    Coupon(
      id: '1',
      code: 'GREEN10',
      description: 'Giảm 10% cho đơn hàng từ 100k',
      discount: 0.1,
      discountType: 'percentage',
      minOrder: 100000,
      expiryDate: DateTime(2024, 12, 31),
    ),
    Coupon(
      id: '2',
      code: 'SHIPFREE',
      description: 'Miễn phí giao hàng',
      discount: 25000,
      discountType: 'fixed',
      minOrder: 150000,
      expiryDate: DateTime(2024, 12, 31),
    ),
    Coupon(
      id: '3',
      code: 'NEWUSER',
      description: 'Giảm 50k cho khách hàng mới',
      discount: 50000,
      discountType: 'fixed',
      minOrder: 200000,
      expiryDate: DateTime(2024, 12, 31),
    ),
  ];

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(String code) {
    final coupon = _availableCoupons.firstWhere(
      (c) => c.code.toLowerCase() == code.toLowerCase(),
      orElse: () => throw Exception('Mã giảm giá không hợp lệ'),
    );

    if (!coupon.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã giảm giá đã hết hạn')),
      );
      return;
    }

    widget.onCouponSelected({
      'id': coupon.id,
      'code': coupon.code,
      'description': coupon.description,
      'discount': coupon.discount,
      'discountType': coupon.discountType,
      'minOrder': coupon.minOrder,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã áp dụng mã ${coupon.code}')),
    );
  }

  void _removeCoupon() {
    widget.onCouponSelected({});
    _couponController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
                    hintText: 'Nhập mã giảm giá',
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
                        const SnackBar(content: Text('Mã giảm giá không hợp lệ')),
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
                  'Mã giảm giá có sẵn',
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