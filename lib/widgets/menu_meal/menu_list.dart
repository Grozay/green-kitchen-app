import 'package:flutter/material.dart';
import '../../models/menu_meal.dart';
import 'meal_card.dart';
import '../../theme/app_colors.dart';

class MenuList extends StatelessWidget {
  final List<MenuMeal> meals;
  final bool loading;
  final ValueChanged<MenuMeal>? onTap;

  const MenuList({
    super.key,
    required this.meals,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          double itemWidth = (constraints.maxWidth - 8) / 2; // 2 cột với spacing 8
          if (itemWidth < 160) itemWidth = constraints.maxWidth - 16; // 1 cột nếu quá nhỏ

          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(8, (index) {
              return Container(
                width: itemWidth,
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
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
                        color: AppColors.inputFill,
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
            }),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = (constraints.maxWidth - 8) / 2; // 2 cột với spacing 8

        if (itemWidth < 160) {
          itemWidth = constraints.maxWidth - 16; // 1 cột với padding 16
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: meals.map((item) {
            final typeBasedIndex = _getTypeBasedIndex(meals, meals.indexOf(item));
            return SizedBox(
              width: itemWidth,
              child: MealCard(
                item: item,
                typeBasedIndex: typeBasedIndex,
                onTap: onTap != null ? () => onTap!(item) : null,
              ),
            );
          }).toList(),
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
