import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../models/cart.dart';
import 'coupon_selector.dart';
import 'payment_method_selector.dart';

class CheckoutSummaryStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Cart cart;
  final Function(String, dynamic) onFormDataChanged;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const CheckoutSummaryStep({
    super.key,
    required this.formData,
    required this.cart,
    required this.onFormDataChanged,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<CheckoutSummaryStep> createState() => _CheckoutSummaryStepState();
}

class _CheckoutSummaryStepState extends State<CheckoutSummaryStep> {
  String _selectedPaymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    // Initialize payment method from form data
    _selectedPaymentMethod = widget.formData['paymentMethod'] ?? 'cash';
  }

  void _handlePaymentMethodChanged(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
    widget.onFormDataChanged('paymentMethod', method);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Section
          _buildSectionHeader('Order Summary'),
          const SizedBox(height: 16),
          _buildOrderSummary(),

          const SizedBox(height: 24),

          // Coupon Section
          _buildSectionHeader('Coupon Code'),
          const SizedBox(height: 16),
          CouponSelector(
            selectedCoupon: widget.formData['selectedCoupon'],
            onCouponSelected: (coupon) {
              widget.onFormDataChanged('selectedCoupon', coupon);
            },
          ),

          const SizedBox(height: 24),

          // Payment Method Section
          _buildSectionHeader('Payment Method'),
          const SizedBox(height: 16),
          PaymentMethodSelector(
            selectedMethod: _selectedPaymentMethod,
            onMethodChanged: _handlePaymentMethodChanged,
          ),

          const SizedBox(height: 32),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.primary),
                  ),
                  onPressed: widget.onPrevious,
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                    'Continue',
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

  Widget _buildOrderSummary() {
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
          // Order Items
          ...widget.cart.cartItems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Quantity: ${item.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.unitPrice.toStringAsFixed(0)}đ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          )),

          const Divider(height: 24),

          // Order Totals
          _buildTotalRow('Subtotal', '${widget.cart.totalAmount.toStringAsFixed(0)}đ'),
          _buildTotalRow('Shipping Fee', '25,000đ'),
          _buildTotalRow('VAT Tax (10%)', '${(widget.cart.totalAmount * 0.1).toStringAsFixed(0)}đ'),

          // Coupon discount if applied
          if (widget.formData['selectedCoupon'] != null) ...[
            _buildTotalRow(
              'Discount (${widget.formData['selectedCoupon']['code']})',
              '-${widget.formData['selectedCoupon']['discount'].toStringAsFixed(0)}đ',
              isDiscount: true,
            ),
          ],

          const Divider(height: 16),
          _buildTotalRow(
            'Total',
            '${_calculateTotal().toStringAsFixed(0)}đ',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount, {bool isTotal = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTotal() {
    double subtotal = widget.cart.totalAmount;
    double shipping = 25000;
    double tax = subtotal * 0.1;
    double discount = 0;

    if (widget.formData['selectedCoupon'] != null) {
      discount = widget.formData['selectedCoupon']['discount'];
    }

    return subtotal + shipping + tax - discount;
  }
}