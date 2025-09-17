import 'package:flutter/material.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import '../../models/cart.dart';
import '../../constants/app_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

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
      // Using hardcoded customer ID for development/testing
      cartProvider.loadCart(CURRENT_CUSTOMER_ID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final cart = cartProvider.cart;
        final isLoading = cartProvider.isLoading;
        final error = cartProvider.error;

        return NavBar(
          cartCount: cartProvider.cartItemCount,
          onCartTap: () {},
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart, color: Color(0xFF4B0036)),
                      const SizedBox(width: 8),
                      Text(
                        'Giỏ mua hàng (${cartProvider.cartItemCount} sản phẩm)',
                        style: const TextStyle(
                          color: Color(0xFF4B0036),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Loading indicator
                  if (isLoading)
                    const Center(child: CircularProgressIndicator()),

                  // Error message
                  if (error != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lỗi: $error',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              cartProvider.clearError();
                              cartProvider.loadCart(CURRENT_CUSTOMER_ID); // Reload cart
                            },
                            icon: const Icon(Icons.refresh, color: Colors.red),
                          ),
                        ],
                      ),
                    ),

                  // Empty cart message
                  if (!isLoading && cart != null && cart.cartItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Giỏ hàng trống',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Hãy thêm sản phẩm vào giỏ hàng của bạn',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Cart items
                  if (!isLoading && cart != null && cart.cartItems.isNotEmpty)
                    ...cart.cartItems.map((cartItem) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CartItemWidget(
                        cartItem: cartItem,
                        onIncrease: () => cartProvider.increaseQuantity(CURRENT_CUSTOMER_ID, cartItem.id),
                        onDecrease: () => cartProvider.decreaseQuantity(CURRENT_CUSTOMER_ID, cartItem.id),
                        onRemove: () => cartProvider.removeFromCart(CURRENT_CUSTOMER_ID, cartItem.id),
                      ),
                    )),

                  const SizedBox(height: 24),

                  // Summary Section
                  if (!isLoading && cart != null && cart.cartItems.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Delivery Address
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DELIVERY ADDRESS',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '2118 Thornridge Cir, Syracuse',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'EDIT',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B35),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Total Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL:',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${cartProvider.totalAmount.toStringAsFixed(0)} VNĐ',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Breakdown',
                                          style: TextStyle(
                                            color: Color(0xFFFF6B35),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Color(0xFFFF6B35),
                                          size: 12,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Place Order Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF6B35),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                // Navigate to payment screen using go_router
                                context.go('/payment');
                              },
                              child: Text(
                                'PLACE ORDER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or placeholder
          cartItem.menuMealImage == null || cartItem.menuMealImage!.isEmpty
              ? CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[400],
                  child: Text(
                    cartItem.menuMealTitle.isNotEmpty ? cartItem.menuMealTitle[0].toUpperCase() : 'M',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    cartItem.menuMealImage!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[400],
                        child: Text(
                          cartItem.menuMealTitle.isNotEmpty ? cartItem.menuMealTitle[0].toUpperCase() : 'M',
                          style: const TextStyle(fontSize: 32, color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.menuMealTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${cartItem.unitPrice.toStringAsFixed(0)} VNĐ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${cartItem.calories.toStringAsFixed(0)} Calories',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text('${cartItem.protein.toStringAsFixed(1)}g Protein'),
                    ),
                    Expanded(
                      child: Text('${cartItem.carbs.toStringAsFixed(1)}g Carbs'),
                    ),
                    Expanded(
                      child: Text('${cartItem.fat.toStringAsFixed(1)}g Fat'),
                    ),
                  ],
                ),
                if (cartItem.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: cartItem.ingredients.map((ingredient) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          // Quantity and delete
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: cartItem.quantity > 1 ? onDecrease : null,
                    color: cartItem.quantity > 1 ? Colors.black : Colors.grey,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onIncrease,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text('Bạn có chắc muốn xóa "${cartItem.menuMealTitle}" khỏi giỏ hàng?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onRemove();
                                },
                                child: const Text(
                                  'Xóa',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
