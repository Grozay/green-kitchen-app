import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/cart_provider.dart';
import '../../provider/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/customer_coupon_service.dart';
import '../../models/create_order_request.dart';
import '../../theme/app_colors.dart';
import 'widgets/delivery_info_step.dart';
import 'widgets/order_summary_step.dart';
import 'widgets/order_confirmation_step.dart';

enum CheckoutStep {
  deliveryInfo,
  summary,
  confirmation,
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PageController _pageController = PageController();
  CheckoutStep _currentStep = CheckoutStep.deliveryInfo;

  // Form data
  final Map<String, dynamic> _formData = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == CheckoutStep.deliveryInfo) {
      setState(() {
        _currentStep = CheckoutStep.summary;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == CheckoutStep.summary) {
      setState(() {
        _currentStep = CheckoutStep.confirmation;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onFormDataChanged(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, child) {
          final cart = cartProvider.cart;

          if (cart == null || cart.cartItems.isEmpty) {
            return const Center(
              child: Text('Your cart is empty'),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Step indicator
                _buildStepIndicator(),

                // Step content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DeliveryInfoStep(
                        formData: _formData,
                        onFormDataChanged: _onFormDataChanged,
                        onNext: _nextStep,
                      ),
                      OrderSummaryStep(
                        formData: _formData,
                        onFormDataChanged: _onFormDataChanged,
                        onNext: _nextStep,
                        onBack: () {
                          setState(() {
                            _currentStep = CheckoutStep.deliveryInfo;
                          });
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      OrderConfirmationStep(
                        formData: _formData,
                        orderSummary: {
                          'items': cart.cartItems.map((item) => {
                            'name': item.title,
                            'quantity': item.quantity,
                            'price': item.unitPrice,
                            'totalPrice': item.totalPrice,
                            'image': item.image,
                            'imageUrl': item.image,
                          }).toList(),
                          'subtotal': cart.totalAmount,
                          'shippingFee': (_formData['shippingFee'] as dynamic)?.toDouble() ?? 0.0,
                          'membershipDiscount': (_formData['membershipDiscount'] as dynamic)?.toDouble() ?? 0.0,
                          'couponDiscount': (_formData['couponDiscount'] as dynamic)?.toDouble() ?? 0.0,
                          'total': ((cart.totalAmount as dynamic).toDouble()) + ((_formData['shippingFee'] as dynamic)?.toDouble() ?? 0.0) -
                                   ((_formData['membershipDiscount'] as dynamic)?.toDouble() ?? 0.0) -
                                   ((_formData['couponDiscount'] as dynamic)?.toDouble() ?? 0.0),
                        },
                        onConfirm: () => _placeOrder(cartProvider),
                        onBack: () {
                          setState(() {
                            _currentStep = CheckoutStep.summary;
                          });
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStepCircle(CheckoutStep.deliveryInfo, 'Address'),
          _buildStepLine(),
          _buildStepCircle(CheckoutStep.summary, 'Summary'),
          _buildStepLine(),
          _buildStepCircle(CheckoutStep.confirmation, 'Confirmation'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(CheckoutStep step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep.index > step.index;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.secondary
                  : isActive
                      ? AppColors.primary
                      : AppColors.inputBorder,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      '${step.index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      height: 2,
      width: 40,
      color: AppColors.inputBorder,
    );
  }

  void _placeOrder(CartProvider cartProvider) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cart = cartProvider.cart;

      if (cart == null || authProvider.currentUser == null) {
        throw Exception('Missing cart or user information');
      }

      // Prepare order data
      final customerId = int.parse(authProvider.currentUser!.id);

      final paymentMethod = _formData['paymentMethod'] ?? 'cod';
      final subtotal = cart.totalAmount;
      final shippingFee = (_formData['shippingFee'] as num?)?.toDouble() ?? 0.0;
      final membershipDiscount = (_formData['membershipDiscount'] as num?)?.toDouble() ?? 0.0;
      final couponDiscount = (_formData['couponDiscount'] as num?)?.toDouble() ?? 0.0;
      final totalAmount = subtotal + shippingFee - membershipDiscount - couponDiscount;

      final orderItems = cart.cartItems.map((item) {
        // Determine item type
        String itemType;
        int? menuMealId;
        int? customMealId;

        if (item.menuMeal != null) {
          itemType = 'MENU_MEAL';
          menuMealId = item.menuMeal!.id;
        } else if (item.customMeal != null) {
          itemType = 'CUSTOM_MEAL';
          customMealId = item.customMeal!.id;
        } else {
          throw Exception('Invalid cart item: no menuMeal or customMeal');
        }

        return OrderItemRequest(
          itemType: itemType,
          menuMealId: menuMealId,
          customMealId: customMealId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        );
      }).toList();

      /// Create order
      final order = await OrderService.createOrder(
        customerId: customerId,
        street: _formData['address'] ?? '',
        ward: _formData['ward'] ?? '',
        district: _formData['district'] ?? '',
        city: _formData['city'] ?? '',
        recipientName: _formData['fullName'] ?? '',
        recipientPhone: _formData['phone'] ?? '',
        deliveryTime: _formData['deliveryTime'],
        subtotal: subtotal,
        shippingFee: shippingFee,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        orderItems: orderItems,
        membershipDiscount: membershipDiscount,
        couponDiscount: couponDiscount,
        notes: _formData['note'],
      );


      try {
        if (paymentMethod == 'cod') {
          await OrderService.processCodPayment(
            orderId: order.id.toString(),
            amount: totalAmount,
          );
        } else if (paymentMethod == 'paypal') {
          // PayPal processing would be handled in the PayPal payment flow
          // For now, we'll assume it's already processed
        }
      } catch (paymentError) {
        // Payment processing failed, but order was created
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order created successfully! Code: ${order.orderCode}. Payment error: $paymentError'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
          context.go('/tracking/${order.orderCode}');
        }
        // Don't clear cart if payment failed
        return; // Exit early since order was created but payment failed
      }

      // Step 3: Update customer coupon if used (only if order creation succeeded)
      final selectedCoupon = _formData['selectedCoupon'] as Map<String, dynamic>?;
      if (selectedCoupon != null && selectedCoupon.isNotEmpty && selectedCoupon['id'] != null) {
        try {
          await CustomerCouponService.useCoupon(
            customerCouponId: selectedCoupon['id'].toString(),
            orderId: order.id.toString(),
          );
        } catch (couponError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order successful! Code: ${order.orderCode}.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }

      // Step 4: Clear cart (only if both order creation and payment succeeded)
      try {
        await cartProvider.clearCartFromServer(customerId);
      } catch (cartError) {
        // Cart clearing failed, but order was created and payment processed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order successful! Code: ${order.orderCode}. Cart clearing error: $cartError'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }

      // Step 5: Show success and navigate to tracking
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed successfully! Order code: ${order.orderCode}'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/tracking/${order.orderCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}