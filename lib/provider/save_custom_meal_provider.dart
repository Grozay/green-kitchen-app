import 'package:flutter/material.dart';
import '../models/custom_meal.dart';
import '../services/custom_meal_service.dart';

class SavedCustomMealsProvider with ChangeNotifier {
  final CustomMealService _service = CustomMealService();
  List<CustomMeal> _savedMeals = [];
  bool _isLoading = false;

  List<CustomMeal> get savedMeals => _savedMeals;
  bool get isLoading => _isLoading;

  Future<void> loadSavedMeals(int customerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _savedMeals = await _service.getCustomMealsForCustomer(customerId);
    } catch (e) {
      _savedMeals = [];
      print('Error loading saved meals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}