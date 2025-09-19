import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/constants/app_constants.dart'; // Import cho CURRENT_CUSTOMER_ID
import 'package:green_kitchen_app/constants/constants.dart';
import 'package:green_kitchen_app/models/menu_meal.dart';
import 'package:green_kitchen_app/services/menu_meal_service.dart';
import 'package:provider/provider.dart';
import '../../provider/cart_provider_v2.dart';
import '../../provider/auth_provider.dart';
import '../../theme/app_colors.dart';

class MenuDetailScreen extends StatefulWidget {
  final String slug;

  const MenuDetailScreen({Key? key, required this.slug}) : super(key: key);

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  MenuMeal? menuMeal;
  bool loading = true;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadMenuMeal();
    // Thêm fetch cart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProviderV2>(context, listen: false);
      // final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final customerId = CURRENT_CUSTOMER_ID; // Lấy từ authProvider nếu có
      cartProvider.fetchCart(customerId);
    });
  }

  void _loadMenuMeal() async {
    try {
      final meal = await MenuMealService().getMenuMealBySlug(widget.slug);
      setState(() {
        menuMeal = meal;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProviderV2, AuthProvider>(
      builder: (context, cartProvider, authProvider, child) {
        // final customerId = authProvider.customer?.id ?? 0; // Uncomment nếu AuthProvider có field customer.id
        final customerId = CURRENT_CUSTOMER_ID; // Giữ nguyên nếu dùng constant

        if (loading) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Loading...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            body: Center(child: CircularProgressIndicator(color: AppColors.secondary)),
          );
        }

        if (menuMeal == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Error',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            body: Center(child: Text('Meal not found')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              menuMeal!.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            actions: [
              Consumer<CartProviderV2>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.shopping_cart,
                          color: AppColors.textPrimary,
                        ),
                        onPressed: () {
                          GoRouter.of(context).push('/cart');
                        },
                      ),
                      if (cartProvider.cartItemCount > 0) // Đảm bảo condition đúng
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '${cartProvider.cartItemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Container(
                            height: 380,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              image: DecorationImage(
                                image: NetworkImage(menuMeal!.image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Title
                          Text(
                            menuMeal!.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            menuMeal!.description,
                            style: const TextStyle(
                              fontSize: 16, 
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Nutritional Info
                          Text(
                            'Nutritional Information',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNutrient(
                                'Calories',
                                '${menuMeal!.calories.toInt()}',
                              ),
                              _buildNutrient(
                                'Protein',
                                '${menuMeal!.protein.toInt()}g',
                              ),
                              _buildNutrient('Carbs', '${menuMeal!.carbs.toInt()}g'),
                              _buildNutrient('Fat', '${menuMeal!.fat.toInt()}g'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Rating
                          Row(
                            children: [
                              const Text(
                                'Rating: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < 4 ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                              const SizedBox(width: 8),
                              const Text(
                                '4.5 (120 reviews)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 100), // Space for bottom bar
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
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
                // Row containing quantity selector and total price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity selector on the left
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
                              if (quantity > 1) {
                                setState(() {
                                  quantity--;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.remove,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (quantity < (menuMeal!.stock)) { // Thêm ?? 0 để handle null
                                setState(() {
                                  quantity++;
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.add,
                              color: AppColors.textPrimary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Total price on the right
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          '${(menuMeal!.price! * quantity).toStringAsFixed(0)}đ',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary, // Thay Color(0xFF00B8A9) bằng AppColors.secondary
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Full width button to add to cart
                SizedBox(
                  width: double.infinity,
                  child: (menuMeal!.stock ?? 0) == 0 // Thêm ?? 0 để handle null
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
                            final itemData = {
                              'isCustom': false,
                              'menuMealId': menuMeal!.id, // Giờ safe vì check null
                              'quantity': quantity,
                              'unitPrice': menuMeal!.price,
                              'totalPrice': menuMeal!.price! * quantity,
                              'title': menuMeal!.title,
                              'description': menuMeal!.description,
                              'image': menuMeal!.image,
                              'itemType': ORDER_TYPE_MENU_MEAL,
                              'calories': menuMeal!.calories,
                              'protein': menuMeal!.protein,
                              'carbs': menuMeal!.carbs,
                              'fat': menuMeal!.fat,
                            };

                            await cartProvider.addMealToCart(customerId, itemData);
                            if (cartProvider.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: ${cartProvider.error}')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added to cart!')),
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
          ),
        );
      },
    );
  }

  Widget _buildNutrient(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label, 
          style: const TextStyle(
            fontSize: 12, 
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
