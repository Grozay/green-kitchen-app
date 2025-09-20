import 'package:flutter/material.dart';
// import 'package:green_kitchen_app/models/cartItem.dart'; // Bỏ import này
import 'package:green_kitchen_app/provider/cart_provider.dart'; // Giữ import CartProvider
import 'package:green_kitchen_app/widgets/cart/cart_item.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/cart.dart'; // Thay cartv2.dart bằng cart.dart
import '../../theme/app_colors.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart'; // Thêm import AuthProvider
import 'package:intl/intl.dart'; // Thêm import này

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Fix: Parse String to int safely
      final customerId = int.tryParse(authProvider.currentUser?.id ?? '0') ?? 0;
      cartProvider.fetchCart(customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, AuthProvider>(
      builder: (context, cartProvider, authProvider, child) {
        final cart = cartProvider.cart;
        final isLoading = cartProvider.isLoading;
        final error = cartProvider.error;

        // Fix: Parse String to int safely
        final customerId =
            int.tryParse(authProvider.currentUser?.id ?? '0') ?? 0;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                GoRouter.of(context).pop();
              },
            ),
            title: Text(
              'Cart (${cartProvider.cartItemCount})',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Loading indicator
                          if (isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            ),

                          // Error message
                          if (error != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundAlt,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Error: $error',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cartProvider.clearError();
                                      cartProvider.fetchCart(
                                        customerId,
                                      ); // Thay CURRENT_CUSTOMER_ID
                                    },
                                    icon: Icon(
                                      Icons.refresh,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Empty cart message
                          if (!isLoading &&
                              cart != null &&
                              cart.cartItems.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 64,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Your cart is empty',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add some products to your cart',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.go('/menu-meal');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'View Menu',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Cart items
                          if (!isLoading &&
                              cart != null &&
                              cart.cartItems.isNotEmpty)
                            ...cart.cartItems.map(
                              (cartItem) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _CartItemWidget(
                                  cartItem: cartItem,
                                  onIncrease: () =>
                                      cartProvider.increaseQuantity(
                                        customerId, // Thay CURRENT_CUSTOMER_ID
                                        cartItem.id,
                                      ),
                                  onDecrease: () =>
                                      cartProvider.decreaseQuantity(
                                        customerId, // Thay CURRENT_CUSTOMER_ID
                                        cartItem.id,
                                      ),
                                  onRemove: () => cartProvider.removeFromCart(
                                    customerId, // Thay CURRENT_CUSTOMER_ID
                                    cartItem.id,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(
                            height: 100,
                          ), // Space for fixed bottom section
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Fixed bottom section
          bottomNavigationBar:
              (!isLoading && cart != null && cart.cartItems.isNotEmpty)
              ? Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Total Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${cartProvider.cartItemCount} Meals',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${NumberFormat('#,###', 'vi_VN').format(cartProvider.totalAmount)} VND',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Place Order Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            // Thêm check login
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            if (!authProvider.isAuthenticated) {
                              _showLoginPrompt(context);
                            } else {
                              GoRouter.of(
                                context,
                              ).push('/checkout');
                            }
                          },
                          child: const Text(
                            'Proceed to Checkout',
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
                )
              : null,
        );
      },
    );
  }
}

class _CartItemWidget extends StatelessWidget {
  final CartItem cartItem; // Giờ là CartItem từ cart.dart
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemWidget({
    required this.cartItem,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return CartItemWidget(
      // Thay cart_item thành CartItemWidget
      cartItem: cartItem,
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      onRemove: onRemove,
    );
  }
}

void _showLoginPrompt(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to log in to place an order. Do you want to go to the login page?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(
                context,
              ).push('/auth/login'); // Adjust route as needed
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}
