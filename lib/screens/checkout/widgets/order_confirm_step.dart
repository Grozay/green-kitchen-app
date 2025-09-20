import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../models/cart.dart';
import 'store_selector.dart';

class OrderConfirmStep extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Cart cart;
  final VoidCallback onPrevious;
  final VoidCallback onOrderPlaced;

  const OrderConfirmStep({
    super.key,
    required this.formData,
    required this.cart,
    required this.onPrevious,
    required this.onOrderPlaced,
  });

  @override
  State<OrderConfirmStep> createState() => _OrderConfirmStepState();
}

class _OrderConfirmStepState extends State<OrderConfirmStep> {
  bool _isProcessing = false;

  void _handlePlaceOrder() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate order processing
      await Future.delayed(const Duration(seconds: 2));
      widget.onOrderPlaced();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStore = widget.formData['selectedStore'] as Store?;
    final selectedCoupon = widget.formData['selectedCoupon'];
    final paymentMethod = widget.formData['paymentMethod'] ?? 'cash';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Section
          _buildSectionHeader('Xác nhận đơn hàng'),
          const SizedBox(height: 16),
          _buildOrderSummary(),

          const SizedBox(height: 24),

          // Delivery Information Section
          _buildSectionHeader('Thông tin giao hàng'),
          const SizedBox(height: 16),
          _buildDeliveryInfo(selectedStore),

          const SizedBox(height: 24),

          // Payment Information Section
          _buildSectionHeader('Thông tin thanh toán'),
          const SizedBox(height: 16),
          _buildPaymentInfo(paymentMethod, selectedCoupon),

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
                    'Quay lại',
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
                  onPressed: _isProcessing ? null : _handlePlaceOrder,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          paymentMethod == 'cash' ? 'Đặt hàng' : 'Thanh toán',
                          style: const TextStyle(
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
                        'Số lượng: ${item.quantity}',
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
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(Store? selectedStore) {
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
          // Customer Info
          _buildInfoRow('Người nhận', widget.formData['fullName'] ?? ''),
          _buildInfoRow('Số điện thoại', widget.formData['phone'] ?? ''),
          _buildInfoRow('Email', widget.formData['email'] ?? ''),

          const Divider(height: 20),

          // Delivery Address
          _buildInfoRow('Địa chỉ', widget.formData['address'] ?? ''),
          _buildInfoRow('Phường/Xã', widget.formData['ward'] ?? ''),
          _buildInfoRow('Quận/Huyện', widget.formData['district'] ?? ''),
          _buildInfoRow('Tỉnh/Thành phố', widget.formData['city'] ?? ''),

          if (widget.formData['note']?.isNotEmpty ?? false) ...[
            const Divider(height: 20),
            _buildInfoRow('Ghi chú', widget.formData['note']),
          ],

          const Divider(height: 20),

          // Store Info
          if (selectedStore != null) ...[
            Row(
              children: [
                const Icon(Icons.store, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Cửa hàng giao hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedStore.name,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              selectedStore.address,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Khoảng cách: ${selectedStore.distance}km • ${selectedStore.estimatedTime}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(String paymentMethod, Map<String, dynamic>? selectedCoupon) {
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
          // Payment Method
          _buildInfoRow('Phương thức thanh toán', _getPaymentMethodName(paymentMethod)),

          // Coupon
          if (selectedCoupon != null && selectedCoupon.isNotEmpty) ...[
            const Divider(height: 20),
            _buildInfoRow('Mã giảm giá', selectedCoupon['code']),
            _buildInfoRow('Giảm giá', '-${_formatDiscount(selectedCoupon)}'),
          ],

          const Divider(height: 20),

          // Order Totals
          _buildTotalRow('Tạm tính', '${widget.cart.totalAmount.toStringAsFixed(0)}đ'),
          _buildTotalRow('Phí giao hàng', '25,000đ'),
          _buildTotalRow('Thuế VAT (10%)', '${(widget.cart.totalAmount * 0.1).toStringAsFixed(0)}đ'),

          if (selectedCoupon != null && selectedCoupon.isNotEmpty) ...[
            _buildTotalRow(
              'Giảm giá (${selectedCoupon['code']})',
              '-${_formatDiscount(selectedCoupon)}',
              isDiscount: true,
            ),
          ],

          const Divider(height: 16),
          _buildTotalRow(
            'Tổng cộng',
            '${_calculateTotal(selectedCoupon).toStringAsFixed(0)}đ',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
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

  String _getPaymentMethodName(String method) {
    switch (method) {
      case 'cash':
        return 'Thanh toán khi nhận hàng (COD)';
      case 'momo':
        return 'Ví MoMo';
      case 'zalopay':
        return 'ZaloPay';
      default:
        return 'Thanh toán khi nhận hàng (COD)';
    }
  }

  String _formatDiscount(Map<String, dynamic> coupon) {
    if (coupon['discountType'] == 'percentage') {
      return '${(coupon['discount'] * 100).toInt()}%';
    } else {
      return '${coupon['discount'].toStringAsFixed(0)}đ';
    }
  }

  double _calculateTotal(Map<String, dynamic>? selectedCoupon) {
    double subtotal = widget.cart.totalAmount;
    double shipping = 25000;
    double tax = subtotal * 0.1;
    double discount = 0;

    if (selectedCoupon != null && selectedCoupon.isNotEmpty) {
      if (selectedCoupon['discountType'] == 'percentage') {
        discount = subtotal * selectedCoupon['discount'];
      } else {
        discount = selectedCoupon['discount'];
      }
    }

    return subtotal + shipping + tax - discount;
  }
}