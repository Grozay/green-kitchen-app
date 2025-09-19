import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/order_model.dart';

class OrderStatusProgressWidget extends StatefulWidget {
  final OrderModel orderData;

  const OrderStatusProgressWidget({
    super.key,
    required this.orderData,
  });

  @override
  State<OrderStatusProgressWidget> createState() => _OrderStatusProgressWidgetState();
}

class _OrderStatusProgressWidgetState extends State<OrderStatusProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final Map<String, dynamic> _statusConfig = {
    'confirmed': {
      'label': 'Confirmed',
      'icon': Icons.check_circle,
      'color': Colors.blue,
      'description': 'Order has been confirmed and is being prepared'
    },
    'preparing': {
      'label': 'Preparing',
      'icon': Icons.restaurant,
      'color': Colors.purple,
      'description': 'Kitchen is preparing your food'
    },
    'shipping': {
      'label': 'Shipping',
      'icon': Icons.local_shipping,
      'color': Colors.deepOrange,
      'description': 'Delivery person is on the way to you'
    },
    'delivered': {
      'label': 'Delivered',
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
      'description': 'Order has been delivered successfully'
    },
    'cancelled': {
      'label': 'Cancelled',
      'icon': Icons.cancel,
      'color': Colors.red,
      'description': 'Order has been cancelled'
    }
  };

  final List<String> _steps = [
    'confirmed',
    'preparing',
    'shipping',
    'delivered'
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _calculateProgress(),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _progressController.forward();
  }

  @override
  void didUpdateWidget(OrderStatusProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderData.status.toLowerCase() != widget.orderData.status.toLowerCase()) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _calculateProgress(),
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ));
      _progressController.forward(from: 0);
    }
  }

  double _calculateProgress() {
    final currentStatus = widget.orderData.status.toLowerCase();
    if (currentStatus == 'cancelled') return 0.0;

    final currentStepIndex = _steps.indexOf(currentStatus);
    if (currentStepIndex == -1) return 0.0;

    return ((currentStepIndex + 1) / _steps.length) * 100;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/'
             '${date.month.toString().padLeft(2, '0')}/'
             '${date.year} '
             '${date.hour.toString().padLeft(2, '0')}:'
             '${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStatus = widget.orderData.status.toLowerCase();
    final currentConfig = _statusConfig[currentStatus] ?? _statusConfig['confirmed'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              currentConfig['icon'],
              color: currentConfig['color'],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Status',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    currentConfig['label'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: currentConfig['color'],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Description
        Text(
          currentConfig['description'],
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),

        const SizedBox(height: 20),

        // Progress Bar
        if (currentStatus != 'cancelled') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Text(
                    '${_progressAnimation.value.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _progressAnimation.value / 100,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(currentConfig['color']),
              );
            },
          ),
        ],

        const SizedBox(height: 24),

        // Horizontal Status Steps
        if (currentStatus != 'cancelled') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _steps.map((step) {
              final config = _statusConfig[step];
              final isCompleted = _steps.indexOf(currentStatus) >= _steps.indexOf(step);
              final isActive = _steps.indexOf(currentStatus) == _steps.indexOf(step);

              // Get timestamp for this step
              String? time;
              if (step == 'confirmed' && widget.orderData.confirmedAt != null) {
                time = widget.orderData.confirmedAt!.toIso8601String();
              } else if (step == 'preparing' && widget.orderData.preparingAt != null) {
                time = widget.orderData.preparingAt!.toIso8601String();
              } else if (step == 'shipping' && widget.orderData.shippingAt != null) {
                time = widget.orderData.shippingAt!.toIso8601String();
              } else if (step == 'delivered' && widget.orderData.deliveredAt != null) {
                time = widget.orderData.deliveredAt!.toIso8601String();
              }

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Icon
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: isCompleted || isActive
                            ? config['color']
                            : Colors.grey.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        config['icon'],
                        color: isCompleted || isActive ? Colors.white : Colors.grey,
                        size: 22,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Status Label
                    Text(
                      config['label'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive
                            ? config['color']
                            : isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Timestamp
                    if (time != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(time),
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ] else ...[
          // Cancelled State
          Center(
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: currentConfig['color'],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    currentConfig['icon'],
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentConfig['label'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: currentConfig['color'],
                  ),
                ),
              ],
            ),
          ),
        ],

      ],
    );
  }
}