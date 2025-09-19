import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../theme/app_colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _displayedOrdersCount = 2; // Hiển thị 2 order đầu tiên
  final int _loadMoreCount = 2; // Mỗi lần load thêm 2 order

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final customerDetails = authProvider.customerDetails;
    final rawOrders = customerDetails?['orders'] ?? [];

    // Sắp xếp orders theo thời gian mới nhất trước
    final orders = List<Map<String, dynamic>>.from(rawOrders)
      ..sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA); // Mới nhất trước
      });

    // Lấy số lượng order để hiển thị
    final displayedOrders = orders.take(_displayedOrdersCount).toList();
    final hasMoreOrders = _displayedOrdersCount < orders.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Go Back',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với icon và text nổi bật
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order History',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your recent meal orders',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (orders.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No orders yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your order history will appear here',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Hiển thị orders
              ...displayedOrders.map(
                (order) => _buildOrderCard(order, context),
              ),

              // Nút xem thêm
              if (hasMoreOrders) ...[
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _loadMoreOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Xem thêm $_loadMoreCount đơn hàng',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.expand_more, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Đang hiển thị ${displayedOrders.length}/${orders.length} đơn hàng',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ] else if (orders.length > 2) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Đã hiển thị tất cả ${orders.length} đơn hàng',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _loadMoreOrders() {
    setState(() {
      _displayedOrdersCount += _loadMoreCount;
    });
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context) {
    final orderId = order['id'] ?? 'N/A';
    final orderCode = order['orderCode'] ?? 'N/A';
    final createdAt = order['createdAt'] ?? 'N/A';
    final status = order['status'] ?? 'Unknown';
    final paymentStatus = order['paymentStatus'] ?? 'Unknown';
    final deliveryTime = order['deliveryTime'] ?? 'N/A';

    // Address information
    final street = order['street'] ?? '';
    final ward = order['ward'] ?? '';
    final district = order['district'] ?? '';
    final city = order['city'] ?? '';
    final fullAddress = [
      street,
      ward,
      district,
      city,
    ].where((s) => s.isNotEmpty).join(', ');

    // Recipient information
    final recipientName = order['recipientName'] ?? 'N/A';
    final recipientPhone = order['recipientPhone'] ?? 'N/A';

    // Pricing information
    final subtotal = order['subtotal'] ?? 0.0;
    final shippingFee = order['shippingFee'] ?? 0.0;
    final membershipDiscount = order['membershipDiscount'] ?? 0.0;
    final couponDiscount = order['couponDiscount'] ?? 0.0;
    final totalAmount = order['totalAmount'] ?? 0.0;
    final pointEarn = order['pointEarn'] ?? 0.0;

    // Order items
    final orderItems = order['orderItems'] ?? [];

    // Format date
    String displayDate = createdAt;
    if (createdAt != 'N/A' && createdAt.toString().contains('T')) {
      try {
        final dateTime = DateTime.parse(createdAt);
        displayDate =
            '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        // Keep original date if parsing fails
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Order Code and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #$orderCode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'ID: $orderId',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getPaymentStatusColor(
                          paymentStatus,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        paymentStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: _getPaymentStatusColor(paymentStatus),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date and Delivery Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ordered: $displayDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (deliveryTime != 'N/A') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.delivery_dining,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Delivery: ${_formatDateTime(deliveryTime)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Delivery Address
            if (fullAddress.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          fullAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Recipient: $recipientName ($recipientPhone)',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Order Items
            if (orderItems.isNotEmpty) ...[
              Text(
                'Order Items:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              ...orderItems.map((item) => _buildOrderItem(item)),
              const SizedBox(height: 12),
            ],

            // Pricing Breakdown
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.inputBorder.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Subtotal', subtotal),
                  if (shippingFee > 0)
                    _buildPriceRow('Shipping Fee', shippingFee),
                  if (membershipDiscount > 0)
                    _buildPriceRow(
                      'Membership Discount',
                      -membershipDiscount,
                      isDiscount: true,
                    ),
                  if (couponDiscount > 0)
                    _buildPriceRow(
                      'Coupon Discount',
                      -couponDiscount,
                      isDiscount: true,
                    ),
                  const Divider(),
                  _buildPriceRow('Total Amount', totalAmount, isTotal: true),
                  if (pointEarn > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Points Earned: ${pointEarn.toStringAsFixed(0)} pts',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // View Details Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order #$orderCode details')),
                  );
                },
                child: Text(
                  'View Details',
                  style: TextStyle(
                    color: AppColors.primary,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
      case 'preparing':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  Color _getPaymentStatusColor(String paymentStatus) {
    switch (paymentStatus.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
        return Colors.red;
      case 'processing':
        return Colors.blue;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDateTime(String dateTimeString) {
    if (dateTimeString == 'N/A' || dateTimeString.isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final title = item['title'] ?? 'Unknown Item';
    final description = item['description'] ?? '';
    final quantity = item['quantity'] ?? 1;
    final unitPrice = item['unitPrice'] ?? 0.0;
    final totalPrice = item['totalPrice'] ?? 0.0;
    final image = item['image'] ?? '';
    final notes = item['notes'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.inputBorder.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: $quantity × \$${unitPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (notes.isNotEmpty)
                  Text(
                    'Notes: $notes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : AppColors.textPrimary,
            ),
          ),
          Text(
            '${isDiscount && amount > 0 ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isDiscount
                  ? Colors.red
                  : (isTotal ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
