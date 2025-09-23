import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../constants/constants.dart';
import '../../models/menu_meal.dart';
import '../../provider/auth_provider.dart';
import '../../provider/cart_provider.dart';
import '../../theme/app_colors.dart';

class BottomBarWidget extends StatefulWidget {
  final MenuMeal menuMeal;
  final int quantity;
  final Function(int) onQuantityChanged;

  const BottomBarWidget({
    super.key,
    required this.menuMeal,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  State<BottomBarWidget> createState() => _BottomBarWidgetState();
}

class _BottomBarWidgetState extends State<BottomBarWidget> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (widget.quantity > 1) {
                          widget.onQuantityChanged(widget.quantity - 1);
                        }
                      },
                      icon: const Icon(Icons.remove, color: AppColors.textPrimary, size: 20),
                    ),
                    Text(
                      '${widget.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (widget.quantity < widget.menuMeal.stock) {
                          widget.onQuantityChanged(widget.quantity + 1);
                        }
                      },
                      icon: const Icon(Icons.add, color: AppColors.textPrimary, size: 20),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  Text(
                    '${NumberFormat('#,###', 'vi_VN').format(widget.menuMeal.price! * widget.quantity)}VNĐ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: widget.menuMeal.stock == 0
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: Text(
                        'Out of Stock',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () async {
                      final customerIdString = authProvider.currentUser?.id;
                      final customerId = customerIdString != null ? int.parse(customerIdString) : 0;

                      final itemData = {
                        'isCustom': false,
                        'menuMealId': widget.menuMeal.id,
                        'quantity': widget.quantity,
                        'unitPrice': widget.menuMeal.price,
                        'totalPrice': widget.menuMeal.price! * widget.quantity,
                        'title': widget.menuMeal.title,
                        'description': widget.menuMeal.description,
                        'image': widget.menuMeal.image,
                        'itemType': ORDER_TYPE_MENU_MEAL,
                        'calories': widget.menuMeal.calories,
                        'protein': widget.menuMeal.protein,
                        'carbs': widget.menuMeal.carbs,
                        'fat': widget.menuMeal.fat,
                      };

                      await cartProvider.addMealToCart(customerId, itemData);
                      if (cartProvider.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${cartProvider.error}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add to Cart',
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
    );
  }
}