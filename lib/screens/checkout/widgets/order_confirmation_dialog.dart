import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class OrderConfirmationDialog extends StatelessWidget {
  final Map<String, dynamic> deliveryInfo;
  final String paymentMethod;
  final Map<String, dynamic> orderSummary;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const OrderConfirmationDialog({
    super.key,
    required this.deliveryInfo,
    required this.paymentMethod,
    required this.orderSummary,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Order Confirmation',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please review the information before placing your order',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Delivery Information
                    _buildSection(
                      'Delivery Information',
                      Icons.location_on,
                      _buildDeliveryInfo(),
                    ),

                    const SizedBox(height: 24),

                    // Payment Method
                    _buildSection(
                      'Payment Method',
                      Icons.payment,
                      _buildPaymentMethod(),
                    ),

                    const SizedBox(height: 24),

                    // Order Summary
                    _buildSection(
                      'Order Summary',
                      Icons.shopping_cart,
                      _buildOrderSummary(),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.inputBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    final fullAddress = [
      deliveryInfo['address'],
      deliveryInfo['ward'],
      deliveryInfo['district'],
      deliveryInfo['city'],
    ].where((part) => part != null && part.toString().isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person, 'Recipient', deliveryInfo['fullName'] ?? ''),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone, 'Phone Number', deliveryInfo['phone'] ?? ''),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Address', fullAddress),
          if (deliveryInfo['deliveryTime'] != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              'Time',
              _formatDateTime(deliveryInfo['deliveryTime']),
            ),
          ],
          if (deliveryInfo['note'] != null && deliveryInfo['note'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.note, 'Note', deliveryInfo['note']),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final methodText = paymentMethod == 'cod'
        ? 'Cash on Delivery (COD)'
        : 'PayPal Payment';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            paymentMethod == 'cod' ? Icons.local_shipping : Icons.payment,
            color: paymentMethod == 'cod' ? AppColors.primary : const Color(0xFF0070ba),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              methodText,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final items = orderSummary['items'] as List<dynamic>? ?? [];
    final subtotal = (orderSummary['subtotal'] as num?)?.toDouble() ?? 0.0;
    final shippingFee = (orderSummary['shippingFee'] as num?)?.toDouble() ?? 0.0;
    final membershipDiscount = (orderSummary['membershipDiscount'] as num?)?.toDouble() ?? 0.0;
    final couponDiscount = (orderSummary['couponDiscount'] as num?)?.toDouble() ?? 0.0;
    final total = (orderSummary['total'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Items list
          if (items.isNotEmpty) ...[
            ...items.map((item) => _buildOrderItem(item)),
            const Divider(height: 24),
          ],

          // Price breakdown
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

  Widget _buildOrderItem(dynamic item) {
    final name = item['name'] ?? item['title'] ?? 'Unknown Item';
    final quantity = item['quantity'] ?? 1;
    final price = item['price'] ?? item['totalPrice'] ?? 0.0;
    final totalPrice = price * quantity;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$name x$quantity',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            _formatPrice(totalPrice),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? AppColors.secondary : (isTotal ? AppColors.primary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Not specified';

    try {
      final dt = dateTime is DateTime ? dateTime : DateTime.parse(dateTime.toString());
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');

      return '$day/$month/$year $hour:$minute';
    } catch (e) {
      return 'Not specified';
    }
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}₫';
  }
}