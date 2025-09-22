import 'package:flutter/material.dart';
import 'package:green_kitchen_app/constants/constants.dart';
// Hide CustomMeal from cart.dart
import 'package:green_kitchen_app/models/ingredient.dart';
import 'package:green_kitchen_app/models/custom_meal.dart';  // Use CustomMeal from this file
import 'package:green_kitchen_app/services/ingredient_service.dart';  // Add this import
// Add this import for CustomMealService

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
  bool isLoadingIngredients = false;
  String? ingredientsError;

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

  bool isEditing = false;
  CustomMeal? editingMeal;  // Add this to store the meal being edited

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
        total += (item.item.price) * item.quantity;
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

    // Update nutrition totals
    totalProtein += ingredient.protein ;
    totalCarbs += ingredient.carbs;
    totalFat += ingredient.fat;
    totalCalories += ((ingredient.protein) * 4) + ((ingredient.carbs) * 4) + ((ingredient.fat) * 9);  // Add calorie calculation

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

      // Update nutrition totals
      totalProtein -= ingredient.protein;
      totalCarbs -= ingredient.carbs;
      totalFat -= ingredient.fat;
      totalCalories -= ((ingredient.protein) * 4) + ((ingredient.carbs) * 4) + ((ingredient.fat) * 9);  // Add calorie calculation

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
    image = imageCustomMealDefault;
    totalCalories = 0;
    totalProtein = 0;
    totalCarbs = 0;
    totalFat = 0;

    notifyListeners();
  }

  // total calories = (Protein (g) × 4) + (Carbs (g) × 4) + (Fat (g) × 9)
  Map<String, double> get selectMealTotals {
    return {
      'totalCalories': totalCalories,  // Use stored value instead of recalculating
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
    };
  }

  // Additional methods for UI
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

    // Logic to suggest sauces based on protein (can be customized)
    return []; // Return list of suggested sauces
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
    try {
      isLoadingIngredients = true;
      ingredientsError = null;
      notifyListeners();
      
      final categorizedIngredients = await IngredientService.getIngredients();
      
      availableProteins = categorizedIngredients['protein'] ?? [];
      availableCarbs = categorizedIngredients['carbs'] ?? [];
      availableSides = categorizedIngredients['side'] ?? [];
      availableSauces = categorizedIngredients['sauce'] ?? [];
      
      notifyListeners();
    } catch (e) {
      ingredientsError = e.toString();
      // Set empty lists on error
      availableProteins = [];
      availableCarbs = [];
      availableSides = [];
      availableSauces = [];
      notifyListeners();
    } finally {
      isLoadingIngredients = false;
      notifyListeners();
    }
  }

  // Add getter for flat list (for your request to remove categories)
  List<Ingredient> get allIngredients {
    return [...availableProteins, ...availableCarbs, ...availableSides, ...availableSauces];
  }

  // Add this method to load a CustomMeal for editing
  void loadFromCustomMeal(CustomMeal meal) {
    print('DEBUG: Available proteins: ${availableProteins.length}, carbs: ${availableCarbs.length}, sides: ${availableSides.length}, sauces: ${availableSauces.length}');
    clearCart();  // Clear existing state
    isEditing = true;  // Set editing flag
    editingMeal = meal;  // Store the meal
    title = meal.title ?? '';
    description = meal.description ?? '';
    image = meal.image ?? imageCustomMealDefault;  // Use valid URL
    totalCalories = meal.calories.toDouble() ?? 0.0;
    totalProtein = meal.protein.toDouble() ?? 0.0;
    totalCarbs = meal.carb.toDouble() ?? 0.0;
    totalFat = meal.fat.toDouble() ?? 0.0;

    for (var detail in meal.details ?? []) {
      final typeKey = detail.type.toLowerCase();  // e.g., 'protein', 'carbs', etc.
      if (selectedItems.containsKey(typeKey)) {
        // Find the real Ingredient from available lists
        List<Ingredient> availableList;
        if (typeKey == 'protein') {
          availableList = availableProteins;
        } else if (typeKey == 'carbs') {
          availableList = availableCarbs;
        } else if (typeKey == 'side') {
          availableList = availableSides;
        } else if (typeKey == 'sauce') {
          availableList = availableSauces;
        } else {
          print('DEBUG: Skipping unknown type: $typeKey');
          continue;  // Skip if type not recognized
        }

        final Ingredient realIngredient = availableList.firstWhere(
          (ing) => ing.id == detail.id,
          orElse: () => Ingredient(
            id: 0,  // Use 0 as not found indicator
            title: '',
            type: '',
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            description: '',
            image: '',
            price: 0,
            stock: 0,
          ),
        );

        if (realIngredient.id != 0) {
          print('DEBUG: Found real ingredient: ${realIngredient.title}, price: ${realIngredient.price}');
          // Use real ingredient
          selectedItems[typeKey]!.add(IngredientWithQuantity(
            item: realIngredient,
            quantity: detail.quantity.toInt(),
          ));
        } else {
          print('DEBUG: Real ingredient not found, using mock for: ${detail.title}');
          // Fallback to mock if not found
          final mockIngredient = Ingredient(
            id: detail.id,
            title: detail.title,
            type: detail.type,
            calories: detail.calories,
            protein: detail.protein,
            carbs: detail.carbs,
            fat: detail.fat,
            description: detail.description,
            image: detail.image,
            price: 0,  // Set to 0 since detail.price not available
            stock: 0,  // Placeholder
          );
          selectedItems[typeKey]!.add(IngredientWithQuantity(
            item: mockIngredient,
            quantity: detail.quantity.toInt(),
          ));
        }
      }
    }
    print('DEBUG: Selected items after loading: $selectedItems');
    notifyListeners();
  }

}