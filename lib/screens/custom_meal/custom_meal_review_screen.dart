import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:green_kitchen_app/constants/constants.dart';
import 'package:green_kitchen_app/provider/custom_meal_provider.dart';
import 'package:provider/provider.dart';
import 'package:green_kitchen_app/provider/cart_provider.dart';
import 'package:intl/intl.dart';  // Add this import for NumberFormat
import 'package:green_kitchen_app/services/custom_meal_service.dart';
import 'package:green_kitchen_app/provider/auth_provider.dart';

class CustomMealReviewScreen extends StatefulWidget {
  const CustomMealReviewScreen({super.key});

  @override
  State<CustomMealReviewScreen> createState() => _CustomMealReviewScreenState();
}

class _CustomMealReviewScreenState extends State<CustomMealReviewScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
        final selectedItems = [
          if (provider.selection.protein != null) provider.selection.protein!,
          if (provider.selection.carbs != null) provider.selection.carbs!,
          if (provider.selection.side != null) provider.selection.side!,
          if (provider.selection.sauce != null) provider.selection.sauce!,
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Review Custom Meal'),
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
                        child: const Text('Order'),
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
    _titleController.text = 'My Custom Bowl';
    _descriptionController.text = 'Custom meal with selected ingredients';
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
                  // Get customer ID from AuthProvider
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final customerIdString = authProvider.currentUser?.id;
                  if (customerIdString == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please log in to order')),
                    );
                    return;
                  }
                  final customerId = int.parse(customerIdString); // Parse to int

                  // Prepare custom meal data
                  final customMealData = {
                    'customerId': customerId,
                    'title': title,
                    'description': description,
                    'calories': provider.totalCalories.round(),
                    'protein': provider.totalProtein.round(),
                    'carb': provider.totalCarbs.round(),
                    'fat': provider.totalFat.round(),
                    'price': provider.totalPrice,
                    'image': imageCustomMealDefault, // Replace with actual default image
                    'proteins': provider.selection.protein != null
                        ? [{'ingredientId': provider.selection.protein!.item.id, 'quantity': provider.selection.protein!.quantity}]
                        : [],
                    'carbs': provider.selection.carbs != null
                        ? [{'ingredientId': provider.selection.carbs!.item.id, 'quantity': provider.selection.carbs!.quantity}]
                        : [],
                    'sides': provider.selection.side != null
                        ? [{'ingredientId': provider.selection.side!.item.id, 'quantity': provider.selection.side!.quantity}]
                        : [],
                    'sauces': provider.selection.sauce != null
                        ? [{'ingredientId': provider.selection.sauce!.item.id, 'quantity': provider.selection.sauce!.quantity}]
                        : [],
                  };

                  try {
                    // Create custom meal
                    final customMealService = CustomMealService();
                    final savedCustomMeal = await customMealService.createCustomMeal(customMealData);

                    // Prepare cart item data
                    final cartItemData = {
                      'isCustom': true,
                      'customMealId': savedCustomMeal.id,
                      'quantity': 1,
                      'unitPrice': provider.totalPrice,
                      'totalPrice': provider.totalPrice,
                      'title': savedCustomMeal.title ?? 'My Custom Bowl',
                      'description': savedCustomMeal.description ?? 'Custom meal with selected ingredients',
                      'calories': provider.totalCalories.round(),
                      'protein': provider.totalProtein.round(),
                      'carbs': provider.totalCarbs.round(),
                      'fat': provider.totalFat.round(),
                      'itemType': ORDER_TYPE_CUSTOM_MEAL,
                      'image': imageCustomMealDefault,
                    };

                    // Add to cart
                    final cartProvider = Provider.of<CartProvider>(context, listen: false);
                    
                    await cartProvider.addMealToCart(customerId, cartItemData);

                    provider.clearSelection();
                    Navigator.of(context).pop(); // Close modal
                    GoRouter.of(context).pop(); // Go back to previous screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Custom meal added to cart!')),
                    );
                    GoRouter.of(context).push('/custom-meal');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add custom meal to cart: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter title and description')),
                  );
                }
              },
              child: const Text('Confirm Order'),
            ),
          ],
        );
      },
    );
  }
}