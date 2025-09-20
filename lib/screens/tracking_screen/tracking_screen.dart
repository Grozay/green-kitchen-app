import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import 'order_status_progress_widget.dart';
import 'order_details_card_widget.dart';
import 'order_items_list_widget.dart';

class TrackingScreen extends StatefulWidget {
  final String? orderCode;

  const TrackingScreen({super.key, this.orderCode});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TextEditingController _orderCodeController = TextEditingController();
  bool _isLoading = false;
  OrderModel? _orderData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // If orderCode is provided, auto-populate and search
    if (widget.orderCode != null) {
      _orderCodeController.text = widget.orderCode!;
      _searchOrder();
    }
  }

  @override
  void dispose() {
    _orderCodeController.dispose();
    super.dispose();
  }

  Future<void> _searchOrder() async {
    final orderCode = _orderCodeController.text.trim();

    if (orderCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an order code';
      });
      return;
    }

    // Validate format: must start with "GK-"
    if (!orderCode.startsWith('GK-')) {
      setState(() {
        _errorMessage = 'Order code must start with "GK-" (e.g., GK-123456789)';
      });
      return;
    }

    // Validate minimum length after "GK-"
    if (orderCode.length < 5) {
      setState(() {
        _errorMessage = 'Please enter a valid order code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Call API to track order
      final order = await OrderService.trackOrder(orderCode);

      setState(() {
        _orderData = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Order not found')
            ? 'Order not found. Please check your order code and try again.'
            : 'Network error. Please try again later.';
        _orderData = null;
        _isLoading = false;
      });
    }
  }

  void _resetSearch() {
    setState(() {
      _orderCodeController.clear();
      _orderData = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'ORDER TRACKING',
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Description
            Text(
              'Enter your order code to view the status and details of your order',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Search Form
            if (_orderData == null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _orderCodeController,
                      hintText: 'Enter order code (e.g., GK-123456789)',
                      enabled: !_isLoading,
                      onSubmitted: (_) => _searchOrder(),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: _isLoading ? 'Searching...' : 'Search',
                      onPressed: _isLoading ? null : _searchOrder,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Search Again Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _resetSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search another order'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],

            // Error Message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Order Results
            if (_orderData != null) ...[
              const SizedBox(height: 24),
              // Order Status Progress
              OrderStatusProgressWidget(orderData: _orderData!),
              const SizedBox(height: 24),

              // Order Details Card
              OrderDetailsCardWidget(order: _orderData!),
              const SizedBox(height: 24),

              // Order Items List
              OrderItemsListWidget(order: _orderData!),
            ],
          ],
        ),
      ),
    );
  }
}