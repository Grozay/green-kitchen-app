import 'package:flutter/material.dart';
import 'package:green_kitchen_app/models/ingredient.dart';
import 'package:green_kitchen_app/services/ingredient_service.dart';  // Add this import

class IngredientWithQuantity {
  final Ingredient item;
  int quantity;

  IngredientWithQuantity({
    required this.item,
    this.quantity = 0,
  });
}

class MealSelection {
  IngredientWithQuantity? protein;
  IngredientWithQuantity? carbs;
  IngredientWithQuantity? side;
  IngredientWithQuantity? sauce;

  MealSelection({
    this.protein,
    this.carbs,
    this.side,
    this.sauce,
  });

  void clear() {
    protein = null;
    carbs = null;
    side = null;
    sauce = null;
  }
}

class CustomMealProvider extends ChangeNotifier {
  // Add fields for available items
  List<Ingredient> availableProteins = [];
  List<Ingredient> availableCarbs = [];
  List<Ingredient> availableSides = [];
  List<Ingredient> availableSauces = [];

  // Initial state
  Map<String, List<IngredientWithQuantity>> selectedItems = {
    'protein': [],
    'carbs': [],
    'side': [],
    'sauce': []
  };

  String title = '';
  String description = '';
  String image = 'https://res.cloudinary.com/quyendev/image/upload/v1750922086/Top-blade-beef-steak-300x300_fvv3fj.png';
  double totalCalories = 0;
  double totalProtein = 0;
  double totalCarbs = 0;
  double totalFat = 0;

  // Getters
  Map<String, List<IngredientWithQuantity>> get selectCurrentMeal {
    return selectedItems;
  }

  MealSelection get selection {
    return MealSelection(
      protein: selectedItems['protein']?.isNotEmpty == true 
          ? selectedItems['protein']!.last : null,
      carbs: selectedItems['carbs']?.isNotEmpty == true 
          ? selectedItems['carbs']!.last : null,
      side: selectedItems['side']?.isNotEmpty == true 
          ? selectedItems['side']!.last : null,
      sauce: selectedItems['sauce']?.isNotEmpty == true 
          ? selectedItems['sauce']!.last : null,
    );
  }

  double get totalPrice {
    double total = 0;
    for (var category in selectedItems.values) {
      for (var item in category) {
        total += (item.item.price ?? 0) * item.quantity;
      }
    }
    return total;
  }

  bool get isComplete {
    return selectedItems['protein']?.isNotEmpty == true &&
           selectedItems['carbs']?.isNotEmpty == true &&
           selectedItems['side']?.isNotEmpty == true &&
           selectedItems['sauce']?.isNotEmpty == true;
  }

  // Reducers
  void addItem(Ingredient ingredient) {
    final typeKey = ingredient.type.toLowerCase();
    final existingItemIndex = selectedItems[typeKey]!.indexWhere(
      (item) => item.item.id == ingredient.id,
    );

    if (existingItemIndex != -1) {
      selectedItems[typeKey]![existingItemIndex].quantity += 1;
    } else {
      selectedItems[typeKey]!.add(IngredientWithQuantity(
        item: ingredient,
        quantity: 1,
      ));
    }

    // Cập nhật nutrition totals
    totalProtein += ingredient.protein ?? 0;
    totalCarbs += ingredient.carbs ?? 0;
    totalFat += ingredient.fat ?? 0;

    notifyListeners();
  }

  void removeItem(Ingredient ingredient) {
    final typeKey = ingredient.type.toLowerCase();
    final existingItemIndex = selectedItems[typeKey]!.indexWhere(
      (item) => item.item.id == ingredient.id,
    );

    if (existingItemIndex != -1) {
      final itemToRemove = selectedItems[typeKey]![existingItemIndex];
      
      if (itemToRemove.quantity > 1) {
        itemToRemove.quantity -= 1;
      } else {
        selectedItems[typeKey]!.removeAt(existingItemIndex);
      }

      // Cập nhật nutrition totals
      totalProtein -= ingredient.protein ?? 0;
      totalCarbs -= ingredient.carbs ?? 0;
      totalFat -= ingredient.fat ?? 0;

      notifyListeners();
    }
  }

  void clearCart() {
    selectedItems = {
      'protein': [],
      'carbs': [],
      'side': [],
      'sauce': []
    };
    
    title = '';
    description = '';
    image = 'https://res.cloudinary.com/quyendev/image/upload/v1750922086/Top-blade-beef-steak-300x300_fvv3fj.png';
    totalCalories = 0;
    totalProtein = 0;
    totalCarbs = 0;
    totalFat = 0;

    notifyListeners();
  }

  // total calories = (Protein (g) × 4) + (Carbs (g) × 4) + (Fat (g) × 9)
  Map<String, double> get selectMealTotals {
    return {
      'totalCalories': (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9),
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }

  // Các methods bổ sung cho UI
  void increaseQuantity(Ingredient ingredient) {
    addItem(ingredient);
  }

  void decreaseQuantity(Ingredient ingredient) {
    removeItem(ingredient);
  }

  int getItemQuantity(Ingredient ingredient) {
    final typeKey = ingredient.type.toLowerCase();
    final existingItem = selectedItems[typeKey]?.firstWhere(
      (item) => item.item.id == ingredient.id,
      orElse: () => IngredientWithQuantity(item: ingredient, quantity: 0),
    );
    return existingItem?.quantity ?? 0;
  }

  void selectMealItem(Ingredient ingredient) {
    addItem(ingredient);
  }

  void clearSelection() {
    clearCart();
  }

  // Sauce suggestion logic
  List<Ingredient> getSuggestedSauces() {
    final proteinItem = selectedItems['protein']?.isNotEmpty == true 
        ? selectedItems['protein']!.last.item : null;
    
    if (proteinItem == null) return [];

    // Logic gợi ý sauce dựa trên protein (có thể customize)
    return []; // Trả về danh sách sauce được gợi ý
  }

  // Setters
  void setTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void setDescription(String newDescription) {
    description = newDescription;
    notifyListeners();
  }

  void setImage(String newImage) {
    image = newImage;
    notifyListeners();
  }

  // Add method to load available items
  Future<void> loadAvailableItems() async {
    final categorizedIngredients = await IngredientService.getIngredients();
    availableProteins = categorizedIngredients['protein'] ?? [];
    availableCarbs = categorizedIngredients['carbs'] ?? [];
    availableSides = categorizedIngredients['side'] ?? [];
    availableSauces = categorizedIngredients['sauce'] ?? [];
    notifyListeners();
  }

  // Add getter for flat list (for your request to remove categories)
  List<Ingredient> get allIngredients {
    return [...availableProteins, ...availableCarbs, ...availableSides, ...availableSauces];
  }
}