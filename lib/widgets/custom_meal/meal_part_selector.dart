import 'package:flutter/material.dart';
import 'package:green_kitchen_app/models/ingredient.dart';
import 'package:green_kitchen_app/widgets/custom_meal/meal_item_card.dart';

class meal_part_selector extends StatelessWidget {
  const meal_part_selector({
    super.key,
    required this.title,
    required this.items,
    required this.getItemQuantity,
    required this.onIncreaseQuantity,
    required this.onDecreaseQuantity,
    required this.number, // Thêm parameter number
  });

  final String title;
  final List<Ingredient> items;
  final Function(Ingredient p1) getItemQuantity;
  final Function(Ingredient p1) onIncreaseQuantity;
  final Function(Ingredient p1) onDecreaseQuantity;
  final int number; // Thêm biến number

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
                      number.toString(),
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
                  childAspectRatio: 0.70,
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