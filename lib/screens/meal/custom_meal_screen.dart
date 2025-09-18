import 'package:flutter/material.dart';
import 'package:green_kitchen_app/widgets/custom_meal/meal_part_selector.dart';
import 'package:green_kitchen_app/widgets/custom_meal/nutrition_info.dart';
import 'package:green_kitchen_app/widgets/custom_meal/tab_ingredient.dart';
import 'package:provider/provider.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';
import 'package:green_kitchen_app/widgets/custom_meal/meal_item_card.dart';
import 'package:green_kitchen_app/provider/cart_provider.dart';
import 'package:green_kitchen_app/models/ingredient.dart';

class CustomMealScreen extends StatefulWidget {
  const CustomMealScreen({super.key});

  @override
  State<CustomMealScreen> createState() => _CustomMealScreenState();
}

class _CustomMealScreenState extends State<CustomMealScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load available items when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomMealProvider>().loadAvailableItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomMealProvider>(
      builder: (context, customMealProvider, child) {
        return NavBar(
          body: Container(
            color: Color(0xFFF5EFE7),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // TabBar for meal parts
                tab_ingredient(tabController: _tabController),

                const SizedBox(height: 24),

                // TabBarView with scrollable content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _MealPartSelector(
                        title: 'SELECT PROTEIN',
                        items: customMealProvider.availableProteins,
                        selectedItem: customMealProvider.selection.protein,
                        onIncreaseQuantity: (item) => customMealProvider.increaseQuantity(item),
                        onDecreaseQuantity: (item) => customMealProvider.decreaseQuantity(item),
                        getItemQuantity: (item) => customMealProvider.getItemQuantity(item),
                        number: 1, // Protein là 1
                      ),
                      _MealPartSelector(
                        title: 'SELECT CARBS',
                        items: customMealProvider.availableCarbs,
                        selectedItem: customMealProvider.selection.carbs,
                        onIncreaseQuantity: (item) => customMealProvider.increaseQuantity(item),
                        onDecreaseQuantity: (item) => customMealProvider.decreaseQuantity(item),
                        getItemQuantity: (item) => customMealProvider.getItemQuantity(item),
                        number: 2, // Carbs là 2
                      ),
                      _MealPartSelector(
                        title: 'SELECT SIDE',
                        items: customMealProvider.availableSides,
                        selectedItem: customMealProvider.selection.side,
                        onIncreaseQuantity: (item) => customMealProvider.increaseQuantity(item),
                        onDecreaseQuantity: (item) => customMealProvider.decreaseQuantity(item),
                        getItemQuantity: (item) => customMealProvider.getItemQuantity(item),
                        number: 3, // Side là 3
                      ),
                      _MealPartSelector(
                        title: 'SELECT SAUCE',
                        items: customMealProvider.availableSauces,
                        selectedItem: customMealProvider.selection.sauce,
                        onIncreaseQuantity: (item) => customMealProvider.increaseQuantity(item),
                        onDecreaseQuantity: (item) => customMealProvider.decreaseQuantity(item),
                        getItemQuantity: (item) => customMealProvider.getItemQuantity(item),
                        number: 4, // Sauce là 4
                      ),
                    ],
                  ),
                ),

                // Nutrition info and Suggest button at bottom
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Compact nutrition info
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _NutritionInfo(
                              value: customMealProvider.totalCalories.toStringAsFixed(0),
                              label: 'Cal',
                            ),
                            const SizedBox(width: 8),
                            _NutritionInfo(
                              value: '${customMealProvider.totalProtein.toStringAsFixed(1)}g',
                              label: 'Protein',
                            ),
                            const SizedBox(width: 8),
                            _NutritionInfo(
                              value: '${customMealProvider.totalCarbs.toStringAsFixed(1)}g',
                              label: 'Carbs',
                            ),
                            const SizedBox(width: 8),
                            _NutritionInfo(
                              value: '${customMealProvider.totalFat.toStringAsFixed(1)}g',
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
                          onPressed: customMealProvider.selection.protein != null
                              ? () => _showSauceSuggestionDialog(context, customMealProvider)
                              : null,
                          child: const Text(
                            'Suggest Sauce',
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

  void _showSauceSuggestionDialog(BuildContext context, CustomMealProvider provider) {
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

  void _showOrderConfirmation(BuildContext context, CustomMealProvider provider) {
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
              Text('Protein: ${provider.selection.protein?.item.title ?? 'None'}'),
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
}




class _MealPartSelector extends StatelessWidget {
  final String title;
  final List<Ingredient> items;
  final IngredientWithQuantity? selectedItem;
  final Function(Ingredient) onIncreaseQuantity;
  final Function(Ingredient) onDecreaseQuantity;
  final Function(Ingredient) getItemQuantity;
  final int number;

  const _MealPartSelector({
    required this.title,
    required this.items,
    this.selectedItem,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.getItemQuantity,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return meal_part_selector(title: title, items: items, getItemQuantity: getItemQuantity, onIncreaseQuantity: onIncreaseQuantity, onDecreaseQuantity: onDecreaseQuantity, number: number); // Truyền number
  }
}



class _NutritionInfo extends StatelessWidget {
  final String value;
  final String label;
  const _NutritionInfo({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return nutrition_info(value: value, label: label);
  }
}



