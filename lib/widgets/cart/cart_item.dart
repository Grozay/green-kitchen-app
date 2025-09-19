import 'package:flutter/material.dart';
import 'package:green_kitchen_app/models/cart.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItem cartItem;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image ở trên cùng
          Center(
            child:
                cartItem.image.isEmpty
                ? CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[400],
                    child: Text(
                      cartItem.title.isNotEmpty // Thay menuMealTitle bằng title
                          ? cartItem.title[0].toUpperCase()
                          : 'M',
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      cartItem.image, // Thay menuMealImage bằng image
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[400],
                          child: Text(
                            cartItem.title.isNotEmpty // Thay menuMealTitle bằng title
                                ? cartItem.title[0].toUpperCase()
                                : 'M',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          // Title bên dưới
          Text(
            cartItem.title, // Thay menuMealTitle bằng title
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
              Expanded(child: Text('${cartItem.fat.toStringAsFixed(1)}g Fat')),
            ],
          ),
          if (cartItem.menuMeal?.menuIngredients.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (cartItem.menuMeal?.menuIngredients ?? [])
                  .map(
                    (ingredient) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          // Price bên dưới
          Text(
            '${cartItem.unitPrice.toStringAsFixed(0)} VNĐ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          // Hàng action bên dưới (quantity và delete)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      print('Decrease pressed for item ${cartItem.id}, quantity: ${cartItem.quantity}');
                      if (cartItem.quantity > 1) {
                        onDecrease();
                      } else {
                        // Show confirmation before removing
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: Text(
                                'Do you want to remove "${cartItem.title}" from the cart?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    onDecrease(); // Call decrease which will remove
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
                      }
                    },
                    color: Colors.black,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${cartItem.quantity}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onIncrease,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: Text(
                          'Do you want to remove "${cartItem.title}" from the cart?', // Thay menuMealTitle bằng title
                        ),
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
    );
  }
}
