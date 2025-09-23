import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/constants/constants.dart';
import 'package:green_kitchen_app/provider/cart_provider.dart';
import 'package:green_kitchen_app/provider/custom_meal_provider.dart';
import 'package:green_kitchen_app/provider/save_custom_meal_provider.dart';
import 'package:provider/provider.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';
import 'package:green_kitchen_app/models/custom_meal.dart';
import 'package:green_kitchen_app/widgets/custom_meal/nutrition_info.dart'; // Reuse nutrition_info widget
import 'package:green_kitchen_app/services/custom_meal_service.dart'; // Import CustomMealService
import 'package:intl/intl.dart'; // Import intl package for NumberFormat

class SavedCustomMealsScreen extends StatefulWidget {
  const SavedCustomMealsScreen({super.key});

  @override
  State<SavedCustomMealsScreen> createState() => _SavedCustomMealsScreenState();
}

class _SavedCustomMealsScreenState extends State<SavedCustomMealsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated &&
          authProvider.currentUser?.id != null) {
        final customerId =
            int.tryParse(authProvider.currentUser!.id) ??
            0; // Parse to int safely
        context.read<SavedCustomMealsProvider>().loadSavedMeals(customerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SavedCustomMealsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => GoRouter.of(context).push('/'),
            ),
            title: const Text(
              'Saved Custom Meals',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
            actions: [
              Consumer<CartProvider>(
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
                      if (cartProvider.cartItemCount >
                          0) // Đảm bảo condition đúng
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
                              minWidth: 15,
                              minHeight: 15,
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
          body: Container(
            color: AppColors.background,
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.savedMeals.isEmpty
                ? const Center(child: Text('No saved meals found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.savedMeals.length,
                    itemBuilder: (context, index) {
                      final meal = provider.savedMeals[index];
                      return _buildMealCard(meal);
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _buildMealCard(CustomMeal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: meal.image.isNotEmpty
                  ? Image.network(
                      meal.image,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 40,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            // Title and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  // Wrap title in Expanded to prevent overflow
                  child: Text(
                    meal.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis, // Cut off if too long
                    maxLines: 1, // Limit to 1 line
                  ),
                ),
                Text(
                  '${NumberFormat('#,###', 'vi_VN').format(meal.price)} VND',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              meal.description,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis, // Cut off if too long
              maxLines: 2, // Limit to 2 lines
            ),
            const SizedBox(height: 12),
            // Nutrition Info
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  nutrition_info(
                    value: meal.calories.toStringAsFixed(0),
                    label: 'Cal',
                  ),
                  const SizedBox(width: 16),
                  nutrition_info(
                    value: '${meal.protein.toStringAsFixed(1)}g',
                    label: 'Protein',
                  ),
                  const SizedBox(width: 16),
                  nutrition_info(
                    value: '${meal.carb.toStringAsFixed(1)}g',
                    label: 'Carbs',
                  ),
                  const SizedBox(width: 16),
                  nutrition_info(
                    value: '${meal.fat.toStringAsFixed(1)}g',
                    label: 'Fat',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Details (Ingredients)
            const Text(
              'Ingredients:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...meal.details
                .take(3)
                .map(
                  // Limit to first 3 ingredients to avoid long list
                  (detail) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '- ${detail.title} (Quantity: ${detail.quantity.toInt()}) - ${detail.type}',
                      overflow: TextOverflow.ellipsis, // Cut off if too long
                      maxLines: 1, // Limit to 1 line
                    ),
                  ),
                ),
            if (meal.details.length > 3)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  '... and more',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 12),

            // 2 nút trên: Adjust và Delete
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      // Load the meal into CustomMealProvider for editing
                      final customMealProvider = Provider.of<CustomMealProvider>(
                        context,
                        listen: false,
                      );
                      customMealProvider.loadFromCustomMeal(meal);
                      // Navigate to custom meal screen for editing
                      GoRouter.of(context).push(
                        '/saved-custom-meal/create',
                      ); // Change to '/custom-meal/create'
                    },
                    child: const Text(
                      'Adjust',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Custom Meal'),
                            content: Text('Are you sure you want to delete "${meal.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        try {
                          // Import service and call delete
                          final customMealService = CustomMealService();
                          await customMealService.deleteCustomMeal(meal.id);

                          // Reload data
                          final authProvider = context.read<AuthProvider>();
                          if (authProvider.isAuthenticated &&
                              authProvider.currentUser?.id != null) {
                            final customerId = int.tryParse(authProvider.currentUser!.id) ?? 0;
                            context.read<SavedCustomMealsProvider>().loadSavedMeals(customerId);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Deleted successfully')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete: $e')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Nút Add to Cart chiếm hết width
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final customerIdString = authProvider.currentUser?.id;
                  if (customerIdString == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please log in to add to cart'),
                      ),
                    );
                    return;
                  }
                  final customerId = int.parse(customerIdString);

                  final cartItemData = {
                    'isCustom': true,
                    'customMealId': meal.id,
                    'quantity': 1,
                    'unitPrice': meal.price,
                    'totalPrice': meal.price,
                    'title': meal.title,
                    'description': meal.description,
                    'calories': meal.calories,
                    'protein': meal.protein,
                    'carbs': meal.carb,
                    'fat': meal.fat,
                    'itemType': ORDER_TYPE_CUSTOM_MEAL,
                    'image': meal.image,
                  };

                  try {
                    final cartProvider = Provider.of<CartProvider>(
                      context,
                      listen: false,
                    );
                    await cartProvider.addMealToCart(customerId, cartItemData);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add to cart: $e')),
                    );
                  }
                },
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
