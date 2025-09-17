import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/ingredient.dart';
import '../services/cart_service.dart';

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

class CustomMealProvider with ChangeNotifier {
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock data - replace with API calls later
      _availableProteins = [
        Ingredient(
          id: 1,
          title: 'Chicken Breast',
          description: 'Grilled chicken breast',
          protein: 31,
          carbs: 0,
          fat: 3.6,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 8.99,
          type: 'protein',
        ),
        Ingredient(
          id: 2,
          title: 'Salmon Fillet',
          description: 'Fresh salmon fillet',
          protein: 22,
          carbs: 0,
          fat: 13,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 12.99,
          type: 'protein',
        ),
        Ingredient(
          id: 3,
          title: 'Organic Tofu',
          description: 'Organic tofu cubes',
          protein: 10,
          carbs: 3.5,
          fat: 5.3,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 6.99,
          type: 'protein',
        ),
      ];

      _availableCarbs = [
        Ingredient(
          id: 4,
          title: 'Brown Rice',
          description: 'Whole grain brown rice',
          protein: 5,
          carbs: 44,
          fat: 1.8,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 3.99,
          type: 'carbs',
        ),
        Ingredient(
          id: 5,
          title: 'Quinoa',
          description: 'Organic quinoa',
          protein: 8,
          carbs: 39,
          fat: 3.6,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 4.99,
          type: 'carbs',
        ),
      ];

      _availableSides = [
        Ingredient(
          id: 6,
          title: 'Mixed Vegetables',
          description: 'Seasonal mixed vegetables',
          protein: 3,
          carbs: 13,
          fat: 0.3,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 4.99,
          type: 'side',
        ),
        Ingredient(
          id: 7,
          title: 'Sweet Potato',
          description: 'Baked sweet potato',
          protein: 2,
          carbs: 26,
          fat: 0.1,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 3.49,
          type: 'side',
        ),
      ];

      _availableSauces = [
        Ingredient(
          id: 8,
          title: 'Teriyaki Sauce',
          description: 'Low-sodium teriyaki sauce',
          protein: 1,
          carbs: 9,
          fat: 0.5,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 2.99,
          type: 'sauce',
        ),
        Ingredient(
          id: 9,
          title: 'Pesto Sauce',
          description: 'Basil pesto sauce',
          protein: 2,
          carbs: 1,
          fat: 8,
          image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=200&q=80',
          price: 3.49,
          type: 'sauce',
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Select meal item
  void selectMealItem(Ingredient item) {
    switch (item.type) {
      case 'protein':
        _selection = _selection.copyWith(protein: IngredientWithQuantity(item: item, quantity: 1));
        break;
      case 'carbs':
        _selection = _selection.copyWith(carbs: IngredientWithQuantity(item: item, quantity: 1));
        break;
      case 'side':
        _selection = _selection.copyWith(side: IngredientWithQuantity(item: item, quantity: 1));
        break;
      case 'sauce':
        _selection = _selection.copyWith(sauce: IngredientWithQuantity(item: item, quantity: 1));
        break;
    }
    notifyListeners();
  }

  // Increase quantity for a meal item
  void increaseQuantity(Ingredient item) {
    switch (item.type) {
      case 'protein':
        if (_selection.protein != null && _selection.protein!.item.id == item.id) {
          final newQuantity = _selection.protein!.quantity + 1;
          _selection = _selection.copyWith(
            protein: _selection.protein!.copyWith(quantity: newQuantity),
          );
        } else {
          _selection = _selection.copyWith(protein: IngredientWithQuantity(item: item, quantity: 1));
        }
        break;
      case 'carbs':
        if (_selection.carbs != null && _selection.carbs!.item.id == item.id) {
          final newQuantity = _selection.carbs!.quantity + 1;
          _selection = _selection.copyWith(
            carbs: _selection.carbs!.copyWith(quantity: newQuantity),
          );
        } else {
          _selection = _selection.copyWith(carbs: IngredientWithQuantity(item: item, quantity: 1));
        }
        break;
      case 'side':
        if (_selection.side != null && _selection.side!.item.id == item.id) {
          final newQuantity = _selection.side!.quantity + 1;
          _selection = _selection.copyWith(
            side: _selection.side!.copyWith(quantity: newQuantity),
          );
        } else {
          _selection = _selection.copyWith(side: IngredientWithQuantity(item: item, quantity: 1));
        }
        break;
      case 'sauce':
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
      case 'protein':
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
      case 'carbs':
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
      case 'side':
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
      case 'sauce':
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
      case 'protein':
        return _selection.protein != null && _selection.protein!.item.id == item.id ? _selection.protein!.quantity : 0;
      case 'carbs':
        return _selection.carbs != null && _selection.carbs!.item.id == item.id ? _selection.carbs!.quantity : 0;
      case 'side':
        return _selection.side != null && _selection.side!.item.id == item.id ? _selection.side!.quantity : 0;
      case 'sauce':
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