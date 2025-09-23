import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/constants/constants.dart';
// Hide CustomMeal from cart.dart
import 'package:green_kitchen_app/models/custom_meal.dart'; // Import CustomMeal from custom_meal.dart
import 'package:green_kitchen_app/provider/custom_meal_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add this import for NumberFormat
import 'package:green_kitchen_app/services/custom_meal_service.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart';
import 'package:green_kitchen_app/provider/save_custom_meal_provider.dart'; // Add this import

class SaveCustomMealReviewScreen extends StatefulWidget {
  final CustomMeal? mealToEdit; // Add this parameter

  const SaveCustomMealReviewScreen({super.key, this.mealToEdit});

  @override
  State<SaveCustomMealReviewScreen> createState() =>
      _SaveCustomMealReviewScreenState();
}

class _SaveCustomMealReviewScreenState
    extends State<SaveCustomMealReviewScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Prefill if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CustomMealProvider>(context, listen: false);
      if (provider.isEditing) {
        _titleController.text = provider.title;
        _descriptionController.text = provider.description;
      } else if (widget.mealToEdit != null) {
        _titleController.text = widget.mealToEdit!.title ?? '';
        _descriptionController.text = widget.mealToEdit!.description ?? '';
      } else {
        _titleController.text = 'My Custom Bowl';
        _descriptionController.text = 'Custom meal with selected ingredients';
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomMealProvider>(
      builder: (context, provider, child) {
        // Change to show all selected items, not just selection
        final selectedItems = provider.selectCurrentMeal.values
            .expand((list) => list)
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Review your Custom Meal'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final item = selectedItems[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(item.item.image),
                      ),
                      title: Text(item.item.title),
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Text(
                        '${NumberFormat('#,###', 'vi_VN').format(item.item.price * item.quantity)} VND',
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Total: ${NumberFormat('#,###', 'vi_VN').format(provider.totalPrice)} VND',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showOrderModal(context, provider),
                        child: const Text('Save Custom Meal'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOrderModal(BuildContext context, CustomMealProvider provider) {
    // Set default values for title and description
    _titleController.text = provider.isEditing
        ? provider.title
        : 'My Custom Bowl';
    _descriptionController.text = provider.isEditing
        ? provider.description
        : 'Custom meal with selected ingredients';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Custom Meal Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final description = _descriptionController.text.trim();
                if (title.isNotEmpty && description.isNotEmpty) {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final customerIdString = authProvider.currentUser?.id;
                  if (customerIdString == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in to save')),
                    );
                    return;
                  }
                  final customerId = int.parse(customerIdString);

                  // Compute selectedItems here
                  final selectedItems = provider.selectCurrentMeal.values
                      .expand((list) => list)
                      .toList();

                  // Debug logs
                  print('DEBUG: selectedItems before save: $selectedItems');
                  print('DEBUG: selectedItems length: ${selectedItems.length}');

                  // Prepare data (adjusted for update API, including missing fields)
                  final mealData = {
                    'customerId': customerId,
                    'title': title,
                    'description': description,
                    'name': title, // As per your example
                    'calories': provider.totalCalories.round(),
                    'protein': provider.totalProtein.round(),
                    'carb': provider.totalCarbs.round(),
                    'fat': provider.totalFat.round(),
                    'price': provider.totalPrice,
                    'image': imageCustomMealDefault,  // Use the constant
                    'proteins': selectedItems
                        .where((item) => item.item.type.toLowerCase() == 'protein')
                        .map((item) => {
                              'ingredientId': item.item.id,
                              'quantity': item.quantity,
                            })
                        .toList(),
                    'carbs': selectedItems
                        .where((item) => item.item.type.toLowerCase() == 'carbs')
                        .map((item) => {
                              'ingredientId': item.item.id,
                              'quantity': item.quantity,
                            })
                        .toList(),
                    'sides': selectedItems
                        .where((item) => item.item.type.toLowerCase() == 'side')
                        .map((item) => {
                              'ingredientId': item.item.id,
                              'quantity': item.quantity,
                            })
                        .toList(),
                    'sauces': selectedItems
                        .where((item) => item.item.type.toLowerCase() == 'sauce')
                        .map((item) => {
                              'ingredientId': item.item.id,
                              'quantity': item.quantity,
                            })
                        .toList(),
                  };

                  try {
                    final customMealService = CustomMealService();
                    CustomMeal savedCustomMeal;
                    if (provider.isEditing && provider.editingMeal != null) {
                      // Update existing meal
                      savedCustomMeal = await customMealService
                          .updateCustomMeal(provider.editingMeal!.id, mealData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Custom meal updated!')),
                      );

                      // Reload saved meals to update data
                      final savedMealsProvider =
                          Provider.of<SavedCustomMealsProvider>(
                            context,
                            listen: false,
                          );
                      await savedMealsProvider.loadSavedMeals(customerId);
                    } else {
                      // Create new meal
                      savedCustomMeal = await customMealService
                          .createCustomMeal(mealData);

                      // Prepare cart item data
                      final cartItemData = {
                        'isCustom': true,
                        'customMealId': savedCustomMeal.id,
                        'quantity': 1,
                        'unitPrice': provider.totalPrice,
                        'totalPrice': provider.totalPrice,
                        'title': savedCustomMeal.title ?? 'My Custom Bowl',
                        'description':
                            savedCustomMeal.description ??
                            'Custom meal with selected ingredients',
                        'calories': provider.totalCalories.round(),
                        'protein': provider.totalProtein.round(),
                        'carbs': provider.totalCarbs.round(),
                        'fat': provider.totalFat.round(),
                        'itemType': ORDER_TYPE_CUSTOM_MEAL,
                        'image': imageCustomMealDefault,  // Use the constant
                      };

                      // Add to cart
                      // final cartProvider = Provider.of<CartProvider>(context, listen: false);

                      // await cartProvider.addMealToCart(customerId, cartItemData);
                    }

                    provider.clearSelection();
                    provider.isEditing = false; // Reset editing flag
                    provider.editingMeal = null; // Reset editing meal
                    Navigator.of(context).pop(); // Close modal
                    GoRouter.of(context).push('/saved-custom-meal'); // Go back
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save custom meal: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter title and description'),
                    ),
                  );
                }
              },
              child: Text(
                provider.isEditing ? 'Save' : 'Confirm Save',
              ), // Change button text based on provider
            ),
          ],
        );
      },
    );
  }
}
