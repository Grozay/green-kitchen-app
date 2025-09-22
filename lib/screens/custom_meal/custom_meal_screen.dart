import 'package:flutter/material.dart';
import 'package:green_kitchen_app/models/ingredient.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart';
import 'package:green_kitchen_app/provider/custom_meal_provider.dart';
import 'package:green_kitchen_app/theme/app_colors.dart';
import 'package:green_kitchen_app/widgets/custom_meal/nutrition_info.dart';
import 'package:provider/provider.dart';
import 'package:green_kitchen_app/widgets/custom_meal/meal_item_card.dart';
import 'package:green_kitchen_app/provider/cart_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/widgets/custom_meal/tab_ingredient.dart'; // Import the tab widget

class CustomMealScreen extends StatefulWidget {
  const CustomMealScreen({super.key});

  @override
  State<CustomMealScreen> createState() => _CustomMealScreenState();
}

class _CustomMealScreenState extends State<CustomMealScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController ??= TabController(length: 4, vsync: this);

    // Load available items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomMealProvider>().loadAvailableItems();
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure _tabController is initialized (for hot reload)
    _tabController ??= TabController(length: 4, vsync: this);

    return Consumer<CustomMealProvider>(
      builder: (context, customMealProvider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: const Text(
              'Custom Meal',
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
                      if (cartProvider.cartItemCount > 0)
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
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Add TabBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: tab_ingredient(
                    tabController: _tabController!,
                  ), // Use the tab widget
                ),
                const SizedBox(height: 16),
                // TabBarView with grids
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Protein tab
                      _buildIngredientGrid(
                        customMealProvider.availableProteins,
                        customMealProvider,
                      ),
                      // Carbs tab
                      _buildIngredientGrid(
                        customMealProvider.availableCarbs,
                        customMealProvider,
                      ),
                      // Side tab
                      _buildIngredientGrid(
                        customMealProvider.availableSides,
                        customMealProvider,
                      ),
                      // Sauce tab
                      _buildIngredientGrid(
                        customMealProvider.availableSauces,
                        customMealProvider,
                      ),
                    ],
                  ),
                ),
                // Nutrition info and button
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            nutrition_info(
                              value: customMealProvider.totalCalories
                                  .toStringAsFixed(0),
                              label: 'Cal',
                            ),
                            const SizedBox(
                              width: 40,
                            ), // Increased spacing from 12 to 16
                            nutrition_info(
                              value:
                                  '${customMealProvider.totalProtein.toStringAsFixed(1)}g',
                              label: 'Protein',
                            ),
                            const SizedBox(
                              width: 40,
                            ), // Increased spacing from 12 to 16
                            nutrition_info(
                              value:
                                  '${customMealProvider.totalCarbs.toStringAsFixed(1)}g',
                              label: 'Carbs',
                            ),
                            const SizedBox(
                              width: 40,
                            ), // Increased spacing from 12 to 16
                            nutrition_info(
                              value:
                                  '${customMealProvider.totalFat.toStringAsFixed(1)}g',
                              label: 'Fat',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1CC29F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed:
                              customMealProvider.selection.protein != null
                              ? () {
                                  // Check if user is logged in
                                  final authProvider =
                                      Provider.of<AuthProvider>(
                                        context,
                                        listen: false,
                                      );
                                  if (!authProvider.isAuthenticated) {
                                    _showLoginPrompt(context);
                                  } else {
                                    GoRouter.of(
                                      context,
                                    ).push('/custom-meal/review');
                                  }
                                }
                              : null,
                          child: const Text(
                            'Order Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientGrid(
    List<Ingredient> ingredients,
    CustomMealProvider provider,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.70,
      ),
      itemCount: ingredients.length,
      itemBuilder: (context, index) {
        final ingredient = ingredients[index];
        final quantity = provider.getItemQuantity(ingredient);
        return MealItemCard(
          item: ingredient,
          quantity: quantity,
          onIncrease: () => provider.increaseQuantity(ingredient),
          onDecrease: () => provider.decreaseQuantity(ingredient),
        );
      },
    );
  }

  void _showSauceSuggestionDialog(
    BuildContext context,
    CustomMealProvider provider,
  ) {
    final suggestedSauces = provider.getSuggestedSauces();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Suggested Sauces'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestedSauces.length,
              itemBuilder: (context, index) {
                final sauce = suggestedSauces[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(sauce.image),
                  ),
                  title: Text(sauce.title),
                  subtitle: Text('\$${sauce.price.toStringAsFixed(2)}'),
                  onTap: () {
                    provider.selectMealItem(sauce);
                    Navigator.of(context).pop();
                    _showOrderConfirmation(context, provider);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderConfirmation(
    BuildContext context,
    CustomMealProvider provider,
  ) {
    if (!provider.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select all meal components'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Order'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Protein: ${provider.selection.protein?.item.title ?? 'None'}',
              ),
              Text('Carbs: ${provider.selection.carbs?.item.title ?? 'None'}'),
              Text('Side: ${provider.selection.side?.item.title ?? 'None'}'),
              Text('Sauce: ${provider.selection.sauce?.item.title ?? 'None'}'),
              const SizedBox(height: 16),
              Text('Total: \$${provider.totalPrice.toStringAsFixed(2)}'),
              Text('Calories: ${provider.totalCalories.toStringAsFixed(0)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Custom meal added to cart!'),
                    backgroundColor: Colors.green,
                  ),
                );
                provider.clearSelection();
              },
              child: const Text('Add to Cart'),
            ),
          ],
        );
      },
    );
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
                GoRouter.of(context).push('/auth/login'); // Adjust route as needed
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
