import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NutrientInfoWidget extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutrientInfoWidget({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNutrient('Calories', '${calories.toInt()}'),
        _buildNutrient('Protein', '${protein.toInt()}g'),
        _buildNutrient('Carbs', '${carbs.toInt()}g'),
        _buildNutrient('Fat', '${fat.toInt()}g'),
      ],
    );
  }

  Widget _buildNutrient(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}