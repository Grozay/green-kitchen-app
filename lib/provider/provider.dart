import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/ingredient.dart';
import '../services/cart_service.dart';
import '../services/ingredient_service.dart';

class CartProvider with ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;
  String? _error;

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get cartItemCount => _cart?.totalItems ?? 0;
  double get totalAmount => _cart?.totalAmount ?? 0.0;

  // Load cart for a customer
  Future<void> loadCart(int customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await CartService.getCartByCustomerId(customerId);
    } catch (e) {
      _error = e.toString();
      _cart = Cart(
        cartItems: [],
        totalAmount: 0.0,
        totalItems: 0,
        totalQuantity: 0,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add meal to cart
  Future<void> addMealToCart(int customerId, {
    required int menuMealId,
    required int quantity,
    String? specialInstructions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = CartService.createAddToCartData(
        menuMealId: menuMealId,
        quantity: quantity,
        specialInstructions: specialInstructions,
      );

      _cart = await CartService.addMealToCart(customerId, data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Increase quantity
  Future<void> increaseQuantity(int customerId, int cartItemId) async {
    if (_cart == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await CartService.increaseQuantity(customerId, cartItemId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Decrease quantity
  Future<void> decreaseQuantity(int customerId, int cartItemId) async {
    if (_cart == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await CartService.decreaseQuantity(customerId, cartItemId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int customerId, int cartItemId) async {
    if (_cart == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await CartService.removeFromCart(customerId, cartItemId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _cart = Cart(
      cartItems: [],
      totalAmount: 0.0,
      totalItems: 0,
      totalQuantity: 0,
    );
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get cart item by menu meal ID
  CartItem? getCartItemByMenuMealId(int menuMealId) {
    if (_cart == null) return null;
    try {
      return _cart!.cartItems.firstWhere(
        (item) => item.menuMealId == menuMealId,
      );
    } catch (e) {
      return null;
    }
  }

  // Check if meal is in cart
  bool isMealInCart(int menuMealId) {
    return getCartItemByMenuMealId(menuMealId) != null;
  }

  // Get quantity of specific meal in cart
  int getMealQuantity(int menuMealId) {
    final item = getCartItemByMenuMealId(menuMealId);
    return item?.quantity ?? 0;
  }
}

class CustomMealProvider extends ChangeNotifier {
  CustomMealSelection _selection = CustomMealSelection();
  List<Ingredient> _availableProteins = [];
  List<Ingredient> _availableCarbs = [];
  List<Ingredient> _availableSides = [];
  List<Ingredient> _availableSauces = [];
  bool _isLoading = false;
  String? _error;

  CustomMealSelection get selection => _selection;
  List<Ingredient> get availableProteins => _availableProteins;
  List<Ingredient> get availableCarbs => _availableCarbs;
  List<Ingredient> get availableSides => _availableSides;
  List<Ingredient> get availableSauces => _availableSauces;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Nutrition getters
  double get totalCalories => _selection.totalCalories;
  double get totalProtein => _selection.totalProtein;
  double get totalCarbs => _selection.totalCarbs;
  double get totalFat => _selection.totalFat;
  double get totalPrice => _selection.totalPrice;
  bool get isComplete => _selection.isComplete;

  // Load available meal items (mock data for now)
  Future<void> loadAvailableItems() async {
    try {
      final categorizedIngredients = await IngredientService.getIngredients();
      
      // Gán theo type
      _availableProteins = categorizedIngredients['protein'] ?? [];
      _availableCarbs = categorizedIngredients['carbs'] ?? [];
      _availableSides = categorizedIngredients['side'] ?? [];
      _availableSauces = categorizedIngredients['sauce'] ?? [];
      
      notifyListeners();
    } catch (e) {
      print('Error loading ingredients: $e');
    }
  }

  // Select meal item
  void selectMealItem(Ingredient item) {
    switch (item.type) {
      case 'PROTEIN':
        _selection = _selection.copyWith(protein: IngredientWithQuantity(item: item, quantity: 1));
        break;
      case 'CARBS':
        _selection = _selection.copyWith(carbs: IngredientWithQuantity(item: item, quantity: 1));
        break;
      case 'SIDE':
        _selection = _selection.copyWith(side: IngredientWithQuantity(item: item, quantity: 1));
        break;
      case 'SAUCE':
        _selection = _selection.copyWith(sauce: IngredientWithQuantity(item: item, quantity: 1));
        break;
    }
    notifyListeners();
  }

  // Increase quantity for a meal item
  void increaseQuantity(Ingredient item) {
    switch (item.type) {
      case 'PROTEIN':
        if (_selection.protein != null && _selection.protein!.item.id == item.id) {
          final newQuantity = _selection.protein!.quantity + 1;
          _selection = _selection.copyWith(
            protein: _selection.protein!.copyWith(quantity: newQuantity),
          );
        } else {
          _selection = _selection.copyWith(protein: IngredientWithQuantity(item: item, quantity: 1));
        }
        break;
      case 'CARBS':
        if (_selection.carbs != null && _selection.carbs!.item.id == item.id) {
          final newQuantity = _selection.carbs!.quantity + 1;
          _selection = _selection.copyWith(
            carbs: _selection.carbs!.copyWith(quantity: newQuantity),
          );
        } else {
          _selection = _selection.copyWith(carbs: IngredientWithQuantity(item: item, quantity: 1));
        }
        break;
      case 'SIDE':
        if (_selection.side != null && _selection.side!.item.id == item.id) {
          final newQuantity = _selection.side!.quantity + 1;
          _selection = _selection.copyWith(
            side: _selection.side!.copyWith(quantity: newQuantity),
          );
        } else {
          _selection = _selection.copyWith(side: IngredientWithQuantity(item: item, quantity: 1));
        }
        break;
      case 'SAUCE':
        if (_selection.sauce != null && _selection.sauce!.item.id == item.id) {
          final newQuantity = _selection.sauce!.quantity + 1;
          _selection = _selection.copyWith(
            sauce: _selection.sauce!.copyWith(quantity: newQuantity),
          );
        } else {
          _selection = _selection.copyWith(sauce: IngredientWithQuantity(item: item, quantity: 1));
        }
        break;
    }
    notifyListeners();
  }

  // Decrease quantity for a meal item
  void decreaseQuantity(Ingredient item) {
    switch (item.type) {
      case 'PROTEIN':
        if (_selection.protein != null && _selection.protein!.item.id == item.id && _selection.protein!.quantity > 0) {
          final newQuantity = _selection.protein!.quantity - 1;
          if (newQuantity <= 0) {
            _selection = _selection.copyWith(protein: null);
          } else {
            _selection = _selection.copyWith(
              protein: _selection.protein!.copyWith(quantity: newQuantity),
            );
          }
        }
        break;
      case 'CARBS':
        if (_selection.carbs != null && _selection.carbs!.item.id == item.id && _selection.carbs!.quantity > 0) {
          final newQuantity = _selection.carbs!.quantity - 1;
          if (newQuantity <= 0) {
            _selection = _selection.copyWith(carbs: null);
          } else {
            _selection = _selection.copyWith(
              carbs: _selection.carbs!.copyWith(quantity: newQuantity),
            );
          }
        }
        break;
      case 'SIDE':
        if (_selection.side != null && _selection.side!.item.id == item.id && _selection.side!.quantity > 0) {
          final newQuantity = _selection.side!.quantity - 1;
          if (newQuantity <= 0) {
            _selection = _selection.copyWith(side: null);
          } else {
            _selection = _selection.copyWith(
              side: _selection.side!.copyWith(quantity: newQuantity),
            );
          }
        }
        break;
      case 'SAUCE':
        if (_selection.sauce != null && _selection.sauce!.item.id == item.id && _selection.sauce!.quantity > 0) {
          final newQuantity = _selection.sauce!.quantity - 1;
          if (newQuantity <= 0) {
            _selection = _selection.copyWith(sauce: null);
          } else {
            _selection = _selection.copyWith(
              sauce: _selection.sauce!.copyWith(quantity: newQuantity),
            );
          }
        }
        break;
    }
    notifyListeners();
  }

  // Get quantity for a specific item
  int getItemQuantity(Ingredient item) {
    switch (item.type) {
      case 'PROTEIN':
        return _selection.protein != null && _selection.protein!.item.id == item.id ? _selection.protein!.quantity : 0;
      case 'CARBS':
        return _selection.carbs != null && _selection.carbs!.item.id == item.id ? _selection.carbs!.quantity : 0;
      case 'SIDE':
        return _selection.side != null && _selection.side!.item.id == item.id ? _selection.side!.quantity : 0;
      case 'SAUCE':
        return _selection.sauce != null && _selection.sauce!.item.id == item.id ? _selection.sauce!.quantity : 0;
      default:
        return 0;
    }
  }

  // Clear selection
  void clearSelection() {
    _selection = CustomMealSelection();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get suggested sauces based on protein
  List<Ingredient> getSuggestedSauces() {
    if (_selection.protein == null) return [];

    // Simple suggestion logic - can be enhanced
    final proteinName = _selection.protein!.item.title.toLowerCase();
    if (proteinName.contains('chicken')) {
      return _availableSauces.where((sauce) => sauce.title.toLowerCase().contains('teriyaki')).toList();
    } else if (proteinName.contains('salmon')) {
      return _availableSauces.where((sauce) => sauce.title.toLowerCase().contains('pesto')).toList();
    } else if (proteinName.contains('tofu')) {
      return _availableSauces.where((sauce) => sauce.title.toLowerCase().contains('teriyaki')).toList();
    }

    return _availableSauces;
  }
}