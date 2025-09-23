import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/cart_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../models/cart.dart';
import 'coupon_selector.dart';
import 'payment_method_selector.dart';

class OrderSummaryStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onFormDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OrderSummaryStep({
    super.key,
    required this.formData,
    required this.onFormDataChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<OrderSummaryStep> createState() => _OrderSummaryStepState();
}

class _OrderSummaryStepState extends State<OrderSummaryStep> {
  final _couponController = TextEditingController();
  String _paymentMethod = 'cod';

  @override
  void initState() {
    super.initState();
    _couponController.text = widget.formData['couponCode'] ?? '';
    _paymentMethod = widget.formData['paymentMethod'] ?? 'cod';
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _handlePaymentMethodChanged(String method) {
    setState(() {
      _paymentMethod = method;
    });
    widget.onFormDataChanged('paymentMethod', method);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cartItems = cartProvider.cart?.cartItems ?? [];
        final subtotal = cartProvider.cart?.totalAmount ?? 0.0;
        final shippingFee = (widget.formData['shippingFee'] as num?)?.toDouble() ?? 0.0;
        final membershipDiscount = (widget.formData['membershipDiscount'] as num?)?.toDouble() ?? 0.0;
        final couponDiscount = (widget.formData['couponDiscount'] as num?)?.toDouble() ?? 0.0;
        final total = subtotal + shippingFee - membershipDiscount - couponDiscount;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Items Section
              _buildSectionHeader('Selected Items'),
              const SizedBox(height: 16),
              _buildOrderItems(cartItems),

              const SizedBox(height: 20),

              // Coupon Section
              _buildSectionHeader('Coupon Code'),
              const SizedBox(height: 12),
              CouponSelector(
                selectedCoupon: widget.formData['selectedCoupon'],
                onCouponSelected: (coupon) {
                  widget.onFormDataChanged('selectedCoupon', coupon);
                  // Calculate discount based on coupon
                  if (coupon.isNotEmpty) {
                    final discountType = coupon['discountType'];
                    final discountValue = coupon['discount'];
                    double discount = 0;

                    if (discountType == 'percentage') {
                      discount = subtotal * discountValue;
                    } else {
                      discount = discountValue;
                    }

                    widget.onFormDataChanged('couponDiscount', discount);
                  } else {
                    widget.onFormDataChanged('couponDiscount', 0);
                  }
                },
              ),

              const SizedBox(height: 20),

              // Payment Method Section
              _buildSectionHeader('Payment Method'),
              const SizedBox(height: 12),
              PaymentMethodSelector(
                selectedMethod: _paymentMethod,
                onMethodChanged: _handlePaymentMethodChanged,
              ),

              const SizedBox(height: 20),

              // Price Summary Section
              _buildSectionHeader('Order Summary'),
              const SizedBox(height: 12),
              _buildPriceSummary(
                subtotal: subtotal,
                shippingFee: shippingFee,
                membershipDiscount: membershipDiscount,
                couponDiscount: couponDiscount,
                total: total,
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.inputBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: widget.onNext,
                      child: const Text(
                        'Confirm Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildOrderItems(List<CartItem> cartItems) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        children: cartItems.map((item) {
          final itemTotal = item.unitPrice * item.quantity;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Item Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item.image),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        // Handle image loading error
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantity: ${item.quantity}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Item Price
                Text(
                  '${_formatPrice(itemTotal)}₫',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceSummary({
    required double subtotal,
    required double shippingFee,
    required double membershipDiscount,
    required double couponDiscount,
    required double total,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          _buildPriceRow('Subtotal:', _formatPrice(subtotal)),
          const SizedBox(height: 8),
          _buildPriceRow('Shipping Fee:', shippingFee > 0 ? _formatPrice(shippingFee) : 'Free'),
          if (membershipDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Membership Discount:', '-${_formatPrice(membershipDiscount)}', isDiscount: true),
          ],
          if (couponDiscount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow('Coupon Discount:', '-${_formatPrice(couponDiscount)}', isDiscount: true),
          ],
          const Divider(height: 24),
          _buildPriceRow('Total:', _formatPrice(total), isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? AppColors.secondary : (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}