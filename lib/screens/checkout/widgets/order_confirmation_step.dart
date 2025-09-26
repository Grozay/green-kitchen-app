import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class OrderConfirmationStep extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Map<String, dynamic> orderSummary;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const OrderConfirmationStep({
    super.key,
    required this.formData,
    required this.orderSummary,
    required this.onConfirm,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.inputBorder),
            ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order Confirmation',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please review before placing your order',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ),

          const SizedBox(height: 24),

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

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
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
                    'Place Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person, 'Recipient', formData['fullName'] ?? ''),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.phone, 'Phone Number', formData['phone'] ?? ''),
          const SizedBox(height: 6),
          _buildInfoRow(Icons.location_on, 'Address', formData['address'] ?? ''),
          const SizedBox(height: 6),
          _buildInfoRow(
            Icons.access_time,
            'Estimated Delivery Time',
            _getDeliveryTimeDisplay(),
          ),
          if (formData['note'] != null && formData['note'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoRow(Icons.note, 'Note', formData['note']),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final paymentMethod = formData['paymentMethod'] ?? 'cod';
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
            const Divider(height: 16),
          ],

          // Price breakdown
          _buildPriceRow('Subtotal:', _formatPrice(subtotal)),
          const SizedBox(height: 6),
          _buildPriceRow('Shipping Fee:', shippingFee > 0 ? _formatPrice(shippingFee) : 'Free'),
          if (membershipDiscount > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow('Membership Discount:', '-${_formatPrice(membershipDiscount)}', isDiscount: true),
          ],
          if (couponDiscount > 0) ...[
            const SizedBox(height: 6),
            _buildPriceRow('Coupon Discount:', '-${_formatPrice(couponDiscount)}', isDiscount: true),
          ],
          const Divider(height: 16),
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
    final imageUrl = item['image'] ?? item['imageUrl'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.fastfood,
                            color: Colors.grey[600],
                            size: 24,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fastfood,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Quantity: $quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Price
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
          size: 18,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 16,
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

  String _getDeliveryTimeDisplay() {
    final deliveryTime = formData['deliveryTime'];
    if (deliveryTime == null) {
      return 'Will be confirmed after order placement';
    }
    
    return _formatDeliveryTime(deliveryTime);
  }

  String _formatDeliveryTime(dynamic deliveryTime) {
    try {
      final dt = deliveryTime is DateTime ? deliveryTime : DateTime.parse(deliveryTime.toString());
      final now = DateTime.now();
      
      // Format ngày
      String dateStr;
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        dateStr = 'Today';
      } else if (dt.year == now.year && dt.month == now.month && dt.day == now.day + 1) {
        dateStr = 'Tomorrow';
      } else {
        final day = dt.day.toString().padLeft(2, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final year = dt.year.toString();
        dateStr = '$day/$month/$year';
      }
      
      // Format giờ
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final timeStr = '$hour:$minute';
      
      return '$dateStr at $timeStr';
    } catch (e) {
      return 'Will be confirmed after order placement';
    }
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
