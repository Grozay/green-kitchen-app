import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:green_kitchen_app/widgets/nav_bar.dart';
import 'package:green_kitchen_app/widgets/custom_meal/meal_item_card.dart';
import 'package:green_kitchen_app/provider/provider.dart';
import 'package:green_kitchen_app/models/ingredient.dart';

class CustomMealScreen extends StatefulWidget {
  const CustomMealScreen({Key? key}) : super(key: key);

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

                // Custom Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFF7DD3C0),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Color(0xFF4B0036),
                    unselectedLabelColor: Colors.white,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'PROTEIN'),
                      Tab(text: 'CARBS'),
                      Tab(text: 'SIDE'),
                      Tab(text: 'SAUCE'),
                    ],
                  ),
                ),

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
                      ),
                      _MealPartSelector(
                        title: 'SELECT CARBS',
                        items: customMealProvider.availableCarbs,
                        selectedItem: customMealProvider.selection.carbs,
                        onIncreaseQuantity: (item) => customMealProvider.increaseQuantity(item),
                        onDecreaseQuantity: (item) => customMealProvider.decreaseQuantity(item),
                        getItemQuantity: (item) => customMealProvider.getItemQuantity(item),
                      ),
                      _MealPartSelector(
                        title: 'SELECT SIDE',
                        items: customMealProvider.availableSides,
                        selectedItem: customMealProvider.selection.side,
                        onIncreaseQuantity: (item) => customMealProvider.increaseQuantity(item),
                        onDecreaseQuantity: (item) => customMealProvider.decreaseQuantity(item),
                        getItemQuantity: (item) => customMealProvider.getItemQuantity(item),
                      ),
                      _MealPartSelector(
                        title: 'SELECT SAUCE',
                        items: customMealProvider.availableSauces,
                        selectedItem: customMealProvider.selection.sauce,
                        onIncreaseQuantity: (item) => customMealProvider.increaseQuantity(item),
                        onDecreaseQuantity: (item) => customMealProvider.decreaseQuantity(item),
                        getItemQuantity: (item) => customMealProvider.getItemQuantity(item),
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

  const _MealPartSelector({
    required this.title,
    required this.items,
    this.selectedItem,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.getItemQuantity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF5EFE7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Color(0xFF4B0036),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF4B0036),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.9,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final quantity = getItemQuantity(item);
                  return MealItemCard(
                    item: item,
                    quantity: quantity,
                    onIncrease: () => onIncreaseQuantity(item),
                    onDecrease: () => onDecreaseQuantity(item),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionInfo extends StatelessWidget {
  final String value;
  final String label;
  const _NutritionInfo({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF4B0036),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
