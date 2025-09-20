import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/cart_provider.dart';
import '../../provider/auth_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/delivery_info_step.dart';
import 'widgets/checkout_summary_step.dart';
import 'widgets/order_confirm_step.dart';

enum CheckoutStep {
  deliveryInfo,
  summary,
  confirm,
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
        _currentStep = CheckoutStep.confirm;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep == CheckoutStep.summary) {
      setState(() {
        _currentStep = CheckoutStep.deliveryInfo;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == CheckoutStep.confirm) {
      setState(() {
        _currentStep = CheckoutStep.summary;
      });
      _pageController.previousPage(
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
          onPressed: () => context.pop(),
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
                      CheckoutSummaryStep(
                        formData: _formData,
                        cart: cart,
                        onFormDataChanged: _onFormDataChanged,
                        onNext: _nextStep,
                        onPrevious: _previousStep,
                      ),
                      OrderConfirmStep(
                        formData: _formData,
                        cart: cart,
                        onPrevious: _previousStep,
                        onOrderPlaced: () => _placeOrder(cartProvider),
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
          _buildStepCircle(CheckoutStep.deliveryInfo, 'Địa chỉ'),
          _buildStepLine(),
          _buildStepCircle(CheckoutStep.summary, 'Tóm tắt'),
          _buildStepLine(),
          _buildStepCircle(CheckoutStep.confirm, 'Xác nhận'),
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
      // TODO: Implement actual order placement
      await Future.delayed(const Duration(seconds: 2));

      // Show success and navigate to tracking
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/tracking');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}