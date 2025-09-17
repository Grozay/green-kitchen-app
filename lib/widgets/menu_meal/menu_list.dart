import 'package:flutter/material.dart';
import '../../models/menu_meal.dart';
import 'meal_card.dart';

class MenuList extends StatelessWidget {
  final List<MenuMeal> meals;
  final bool loading;
  final ValueChanged<MenuMeal>? onAddToCart;
  final ValueChanged<MenuMeal>? onIncrease;
  final ValueChanged<MenuMeal>? onDecrease;
  final Map<int, int>? quantities;
  final ValueChanged<MenuMeal>? onTap;

  const MenuList({
    Key? key,
    required this.meals,
    this.loading = false,
    this.onAddToCart,
    this.onIncrease,
    this.onDecrease,
    this.quantities,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.75,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 100,
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 20, color: Colors.grey[300]),
                      const SizedBox(height: 6),
                      Container(height: 16, width: 100, color: Colors.grey[300]),
                      const SizedBox(height: 6),
                      Container(height: 12, color: Colors.grey[300]),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.55, // Increased from 0.57 to 0.65 for more vertical space
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final item = meals[index];
        final typeBasedIndex = _getTypeBasedIndex(meals, index);
        final quantity = quantities?[item.id];

        return MealCard(
          item: item,
          typeBasedIndex: typeBasedIndex,
          onAddToCart: onAddToCart != null ? () => onAddToCart!(item) : null,
          onIncrease: onIncrease != null ? () => onIncrease!(item) : null,
          onDecrease: onDecrease != null ? () => onDecrease!(item) : null,
          quantity: quantity,
          onTap: onTap != null ? () => onTap!(item) : null,
        );
      },
    );
  }

  int _getTypeBasedIndex(List<MenuMeal> items, int currentIndex) {
    final currentItem = items[currentIndex];
    final currentType = currentItem.type;

    int typeIndex = 1;
    for (int i = 0; i < currentIndex; i++) {
      if (items[i].type == currentType) {
        typeIndex++;
      }
    }
    return typeIndex;
  }
}
