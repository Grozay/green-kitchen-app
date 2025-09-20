import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  Cart? _cart;
  bool _isLoading = false;
  String? _error;
  SharedPreferences? _prefs;
  static const String _cartKey = 'cart_data_v2';

  Cart? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get cartItemCount => _cart?.totalItems ?? 0;
  double get totalAmount => _cart?.totalAmount ?? 0.0;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await loadCartFromLocal();
  }

  Future<void> loadCartFromLocal() async {
    if (_prefs == null) {
      await initialize();
    }

    final cartJson = _prefs!.getString(_cartKey);
    if (cartJson != null) {
      try {
        final cartMap = jsonDecode(cartJson);
        _cart = Cart.fromJson(cartMap);
      } catch (e) {
        print('Error parsing cart from local: $e');
        _cart = null;
      }
    } else {
      _cart = null;
    }
  }

  // Lưu cart vào local storage (sau khi update từ API)
  Future<void> _saveCartToLocal() async {
    if (_prefs == null) {
      await initialize();
    }

    if (_cart != null) {
      final cartJson = jsonEncode(_cart!.toJson());
      await _prefs!.setString(_cartKey, cartJson);
    }
  }

  // Fetch cart từ API
  Future<void> fetchCart(int customerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (customerId == 0) {
        // Nếu chưa login (customerId = 0), load từ local storage
        await loadCartFromLocal();
      } else {
        // Nếu đã login, fetch từ API
        final cartData = await CartService().getCartByCustomerId(customerId);
        _cart = cartData;
        await _saveCartToLocal(); // Lưu lại local để đồng bộ
      }
    } catch (e) {
      _error = 'Failed to fetch cart: $e';
      // Fallback: Load từ local nếu API fail
      await loadCartFromLocal();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncCartAfterLogin(int customerId) async {
    if (_cart == null || _cart!.cartItems.isEmpty)
      return; // Không có gì để sync

    try {
      // Loop qua từng item trong local cart và add vào DB
      for (var item in _cart!.cartItems) {
        final data = {
          'isCustom': item.isCustom,
          'menuMealId':
              item.menuMeal?.id ?? item.id, // Fallback nếu không có menuMeal
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'totalPrice': item.totalPrice,
          'title': item.title,
          'description': item.description,
          'image': item.image,
          'itemType': item.itemType,
          'calories': item.calories,
          'protein': item.protein,
          'carbs': item.carbs,
          'fat': item.fat,
        };
        await CartService().addMealToCart(
          customerId,
          data,
        ); // Add từng item, merge tự động
      }

      // Sau khi add xong, fetch lại cart từ DB để update state (bao gồm merge)
      await fetchCart(customerId);

      // Clear local cart sau khi sync thành công
      _cart = null;
      await _saveCartToLocal();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sync cart after login: $e';
      notifyListeners();
    }
  }

  // Remove from cart với optimistic update và better error handling
  Future<void> removeFromCart(int customerId, int cartItemId) async {
    if (_cart == null) return;

    // Background API call
    try {
      if (customerId == 0) {
        final itemToRemove = _cart!.cartItems.firstWhere(
          (item) => item.id == cartItemId,
          orElse: () => throw Exception('Item not found in cart'),
        );

        final updatedItems = _cart!.cartItems
            .where((item) => item.id != cartItemId)
            .toList();

        // Tính lại totals
        final newTotalAmount = updatedItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        final newTotalItems = updatedItems.length;
        final newTotalQuantity = updatedItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );

        _cart = _cart!.copyWith(
          cartItems: updatedItems,
          totalAmount: newTotalAmount,
          totalItems: newTotalItems,
          totalQuantity: newTotalQuantity,
        );

        // Clear any previous errors
        _error = null;
        notifyListeners();
        await _saveCartToLocal();
        return; // Không gọi API
      } else {
        final originalCart = _cart!;
        final itemToRemove = _cart!.cartItems.firstWhere(
          (item) => item.id == cartItemId,
          orElse: () => throw Exception('Item not found in cart'),
        );

        final updatedItems = _cart!.cartItems
            .where((item) => item.id != cartItemId)
            .toList();

        // Tính lại totals
        final newTotalAmount = updatedItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        final newTotalItems = updatedItems.length;
        final newTotalQuantity = updatedItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );

        _cart = _cart!.copyWith(
          cartItems: updatedItems,
          totalAmount: newTotalAmount,
          totalItems: newTotalItems,
          totalQuantity: newTotalQuantity,
        );

        // Clear any previous errors
        _error = null;
        notifyListeners();
        await _saveCartToLocal();
      }
      final updatedCart = await CartService().removeFromCart(
        customerId,
        cartItemId,
      );

      _cart = updatedCart;
      await _saveCartToLocal();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to remove item. Please try again !';
      notifyListeners();
      await _saveCartToLocal();
    }
  }

  // Increase quantity với optimistic update
  Future<void> increaseQuantity(int customerId, int cartItemId) async {
    if (_cart == null) return;
    // Background API call
    try {
      if (customerId == 0) {
        // Optimistic update local
        final updatedItems = _cart!.cartItems.map((item) {
          if (item.id == cartItemId) {
            final newQuantity = item.quantity + 1;
            final newTotalPrice = item.unitPrice * newQuantity;
            return CartItem(
              id: item.id,
              cartId: item.cartId,
              isCustom: item.isCustom,
              menuMeal: item.menuMeal,
              customMeal: item.customMeal,
              weekMeal: item.weekMeal,
              itemType: item.itemType,
              quantity: newQuantity,
              unitPrice: item.unitPrice,
              totalPrice: newTotalPrice,
              title: item.title,
              image: item.image,
              description: item.description,
              calories: item.calories,
              protein: item.protein,
              carbs: item.carbs,
              fat: item.fat,
            );
          }
          return item;
        }).toList();

        // Tính lại totals
        final newTotalAmount = updatedItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        final newTotalQuantity = updatedItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );

        _cart = _cart!.copyWith(
          cartItems: updatedItems,
          totalAmount: newTotalAmount,
          totalQuantity: newTotalQuantity,
        );
        notifyListeners();
        await _saveCartToLocal();
        return; // Không gọi API
      } else {
        final originalCart = _cart!;
        final updatedItems = _cart!.cartItems.map((item) {
          if (item.id == cartItemId) {
            final newQuantity = item.quantity + 1;
            final newTotalPrice = item.unitPrice * newQuantity;
            return CartItem(
              id: item.id,
              cartId: item.cartId,
              isCustom: item.isCustom,
              menuMeal: item.menuMeal,
              customMeal: item.customMeal,
              weekMeal: item.weekMeal,
              itemType: item.itemType,
              quantity: newQuantity,
              unitPrice: item.unitPrice,
              totalPrice: newTotalPrice,
              title: item.title,
              image: item.image,
              description: item.description,
              calories: item.calories,
              protein: item.protein,
              carbs: item.carbs,
              fat: item.fat,
            );
          }
          return item;
        }).toList();

        // Tính lại totals
        final newTotalAmount = updatedItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        final newTotalQuantity = updatedItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );

        _cart = _cart!.copyWith(
          cartItems: updatedItems,
          totalAmount: newTotalAmount,
          totalQuantity: newTotalQuantity,
        );
        notifyListeners();
        await _saveCartToLocal();
        final updatedCart = await CartService().increaseQuantity(
          customerId,
          cartItemId,
        );
        _cart = updatedCart;
      }
      await _saveCartToLocal();
      notifyListeners();
    } catch (e) {
      // Revert optimistic update nếu API fail
      // _cart = originalCart;
      _error = 'Failed to increase quantity. Please try again.';
      notifyListeners();
      await _saveCartToLocal();
    }
  }

  // Decrease quantity với optimistic update
  Future<void> decreaseQuantity(int customerId, int cartItemId) async {
    if (_cart == null) return;

    // Nếu customerId = 0 (chưa login), chỉ xử lý local

    // Nếu đã login, gọi API như bình thường
    // Optimistic update - Giảm quantity hoặc xóa item ngay lập tức

    // Background API call
    try {
      if (customerId == 0) {
        // Optimistic update local
        final currentItem = _cart!.cartItems.firstWhere(
          (item) => item.id == cartItemId,
        );

        List<CartItem> updatedItems;
        if (currentItem.quantity <= 1) {
          // Remove item if quantity becomes 0
          updatedItems = _cart!.cartItems
              .where((item) => item.id != cartItemId)
              .toList();
        } else {
          // Decrease quantity
          updatedItems = _cart!.cartItems.map((item) {
            if (item.id == cartItemId) {
              final newQuantity = item.quantity - 1;
              final newTotalPrice = item.unitPrice * newQuantity;
              return CartItem(
                id: item.id,
                cartId: item.cartId,
                isCustom: item.isCustom,
                menuMeal: item.menuMeal,
                customMeal: item.customMeal,
                weekMeal: item.weekMeal,
                itemType: item.itemType,
                quantity: newQuantity,
                unitPrice: item.unitPrice,
                totalPrice: newTotalPrice,
                title: item.title,
                image: item.image,
                description: item.description,
                calories: item.calories,
                protein: item.protein,
                carbs: item.carbs,
                fat: item.fat,
              );
            }
            return item;
          }).toList();
        }

        // Tính lại totals
        final newTotalAmount = updatedItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        final newTotalItems = updatedItems.length;
        final newTotalQuantity = updatedItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );

        _cart = _cart!.copyWith(
          cartItems: updatedItems,
          totalAmount: newTotalAmount,
          totalItems: newTotalItems,
          totalQuantity: newTotalQuantity,
        );
        notifyListeners();
        await _saveCartToLocal();
        return; // Không gọi API
      } else {
        final originalCart = _cart!;
        final currentItem = _cart!.cartItems.firstWhere(
          (item) => item.id == cartItemId,
        );

        List<CartItem> updatedItems;
        if (currentItem.quantity <= 1) {
          // Remove item if quantity becomes 0
          updatedItems = _cart!.cartItems
              .where((item) => item.id != cartItemId)
              .toList();
        } else {
          // Decrease quantity
          updatedItems = _cart!.cartItems.map((item) {
            if (item.id == cartItemId) {
              final newQuantity = item.quantity - 1;
              final newTotalPrice = item.unitPrice * newQuantity;
              return CartItem(
                id: item.id,
                cartId: item.cartId,
                isCustom: item.isCustom,
                menuMeal: item.menuMeal,
                customMeal: item.customMeal,
                weekMeal: item.weekMeal,
                itemType: item.itemType,
                quantity: newQuantity,
                unitPrice: item.unitPrice,
                totalPrice: newTotalPrice,
                title: item.title,
                image: item.image,
                description: item.description,
                calories: item.calories,
                protein: item.protein,
                carbs: item.carbs,
                fat: item.fat,
              );
            }
            return item;
          }).toList();
        }

        // Tính lại totals
        final newTotalAmount = updatedItems.fold(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        final newTotalItems = updatedItems.length;
        final newTotalQuantity = updatedItems.fold(
          0,
          (sum, item) => sum + item.quantity,
        );

        _cart = _cart!.copyWith(
          cartItems: updatedItems,
          totalAmount: newTotalAmount,
          totalItems: newTotalItems,
          totalQuantity: newTotalQuantity,
        );
        notifyListeners();
        await _saveCartToLocal();
      }
      final updatedCart = await CartService().decreaseQuantity(
        customerId,
        cartItemId,
      );
      _cart = updatedCart;
      await _saveCartToLocal();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to decrease quantity. Please try again.';
      notifyListeners();
      await _saveCartToLocal();
    }
  }

  // Add meal to cart
  Future<void> addMealToCart(
    int customerId,
    Map<String, dynamic> itemData,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('customerId: $customerId');
      if (customerId == 0) {
        await _addToLocalCart(itemData);
      } else {
        final updatedCart = await CartService().addMealToCart(
          customerId,
          itemData,
        );
        _cart = updatedCart;
        await _saveCartToLocal();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _addToLocalCart(Map<String, dynamic> itemData) async {
    // Sử dụng menuMealId hoặc customMealId làm id để merge sản phẩm giống nhau
    final uniqueId = itemData['menuMealId'] ?? itemData['customMealId'] ?? DateTime.now().millisecondsSinceEpoch;
    final newItem = CartItem(
      id: uniqueId,
      cartId: 0, // Temporary
      isCustom: itemData['isCustom'] ?? false,
      menuMeal: itemData['menuMeal'], // Set nếu có data
      customMeal: itemData['customMeal'], // Set nếu có data
      weekMeal: null,
      itemType: itemData['itemType'],
      quantity: itemData['quantity'] ?? 1,
      unitPrice: itemData['unitPrice'] ?? 0.0,
      totalPrice: itemData['totalPrice'] ?? 0.0,
      title: itemData['title'] ?? '',
      image: itemData['image'] ?? '',
      description: itemData['description'] ?? '',
      calories: itemData['calories'] ?? 0.0,
      protein: itemData['protein'] ?? 0.0,
      carbs: itemData['carbs'] ?? 0.0,
      fat: itemData['fat'] ?? 0.0,
    );

    // Nếu _cart null, tạo mới
    if (_cart == null) {
      _cart = Cart(
        id: 0,
        customerId: 0,
        cartItems: [newItem],
        totalAmount: newItem.totalPrice,
        totalItems: 1,
        totalQuantity: newItem.quantity,
      );
    } else {
      // Check nếu item đã tồn tại (dựa trên id, giờ là menuMealId hoặc customMealId)
      final existingIndex = _cart!.cartItems.indexWhere(
        (item) => item.id == newItem.id,
      );
      if (existingIndex != -1) {
        final existingItem = _cart!.cartItems[existingIndex];
        final updatedItem = CartItem(
          id: existingItem.id,
          cartId: existingItem.cartId,
          isCustom: existingItem.isCustom,
          menuMeal: existingItem.menuMeal,
          customMeal: existingItem.customMeal,
          weekMeal: existingItem.weekMeal,
          itemType: existingItem.itemType,
          quantity: existingItem.quantity + newItem.quantity,
          unitPrice: existingItem.unitPrice,
          totalPrice: existingItem.unitPrice * (existingItem.quantity + newItem.quantity),
          title: existingItem.title,
          image: existingItem.image,
          description: existingItem.description,
          calories: existingItem.calories,
          protein: existingItem.protein,
          carbs: existingItem.carbs,
          fat: existingItem.fat,
        );
        _cart!.cartItems[existingIndex] = updatedItem;
      } else {
        // Add mới
        _cart!.cartItems.add(newItem);
      }

      // Tính lại totals
      final newTotalAmount = _cart!.cartItems.fold(
        0.0,
        (sum, item) => sum + item.totalPrice,
      );
      final newTotalItems = _cart!.cartItems.length;
      final newTotalQuantity = _cart!.cartItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

      _cart = _cart!.copyWith(
        cartItems: _cart!.cartItems,
        totalAmount: newTotalAmount,
        totalItems: newTotalItems,
        totalQuantity: newTotalQuantity,
      );
    }

    // Save local
    await _saveCartToLocal();
  }

  Future<void> clearCart() async {
    _cart = null;
    if (_prefs != null) {
      await _prefs!.remove(_cartKey);
    }
    _saveCartToLocal(); // Lưu local để đảm bảo clear
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// CustomMealProvider giữ nguyên (không thay đổi)
// class CustomMealProvider extends ChangeNotifier {
//   CustomMealSelection _selection = CustomMealSelection();
//   List<Ingredient> _availableProteins = [];
//   List<Ingredient> _availableCarbs = [];
//   List<Ingredient> _availableSides = [];
//   List<Ingredient> _availableSauces = [];
//   bool _isLoading = false;
//   String? _error;

//   CustomMealSelection get selection => _selection;
//   List<Ingredient> get availableProteins => _availableProteins;
//   List<Ingredient> get availableCarbs => _availableCarbs;
//   List<Ingredient> get availableSides => _availableSides;
//   List<Ingredient> get availableSauces => _availableSauces;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   // Nutrition getters
//   double get totalCalories => _selection.totalCalories;
//   double get totalProtein => _selection.totalProtein;
//   double get totalCarbs => _selection.totalCarbs;
//   double get totalFat => _selection.totalFat;
//   double get totalPrice => _selection.totalPrice;
//   bool get isComplete => _selection.isComplete;

//   // Load available meal items (mock data for now)
//   Future<void> loadAvailableItems() async {
//     try {
//       final categorizedIngredients = await IngredientService.getIngredients();

//       // Gán theo type
//       _availableProteins = categorizedIngredients['protein'] ?? [];
//       _availableCarbs = categorizedIngredients['carbs'] ?? [];
//       _availableSides = categorizedIngredients['side'] ?? [];
//       _availableSauces = categorizedIngredients['sauce'] ?? [];

//       notifyListeners();
//     } catch (e) {
//       print('Error loading ingredients: $e');
//     }
//   }

//   // Select meal item
//   void selectMealItem(Ingredient item) {
//     switch (item.type) {
//       case 'PROTEIN':
//         _selection = _selection.copyWith(
//           protein: IngredientWithQuantity(item: item, quantity: 1),
//         );
//         break;
//       case 'CARBS':
//         _selection = _selection.copyWith(
//           carbs: IngredientWithQuantity(item: item, quantity: 1),
//         );
//         break;
//       case 'SIDE':
//         _selection = _selection.copyWith(
//           side: IngredientWithQuantity(item: item, quantity: 1),
//         );
//         break;
//       case 'SAUCE':
//         _selection = _selection.copyWith(
//           sauce: IngredientWithQuantity(item: item, quantity: 1),
//         );
//         break;
//     }
//     notifyListeners();
//   }

//   // Increase quantity for a meal item
//   void increaseQuantity(Ingredient item) {
//     switch (item.type) {
//       case 'PROTEIN':
//         if (_selection.protein != null &&
//             _selection.protein!.item.id == item.id) {
//           final newQuantity = _selection.protein!.quantity + 1;
//           _selection = _selection.copyWith(
//             protein: _selection.protein!.copyWith(quantity: newQuantity),
//           );
//         } else {
//           _selection = _selection.copyWith(
//             protein: IngredientWithQuantity(item: item, quantity: 1),
//           );
//         }
//         break;
//       case 'CARBS':
//         if (_selection.carbs != null && _selection.carbs!.item.id == item.id) {
//           final newQuantity = _selection.carbs!.quantity + 1;
//           _selection = _selection.copyWith(
//             carbs: _selection.carbs!.copyWith(quantity: newQuantity),
//           );
//         } else {
//           _selection = _selection.copyWith(
//             carbs: IngredientWithQuantity(item: item, quantity: 1),
//           );
//         }
//         break;
//       case 'SIDE':
//         if (_selection.side != null && _selection.side!.item.id == item.id) {
//           final newQuantity = _selection.side!.quantity + 1;
//           _selection = _selection.copyWith(
//             side: _selection.side!.copyWith(quantity: newQuantity),
//           );
//         } else {
//           _selection = _selection.copyWith(
//             side: IngredientWithQuantity(item: item, quantity: 1),
//           );
//         }
//         break;
//       case 'SAUCE':
//         if (_selection.sauce != null && _selection.sauce!.item.id == item.id) {
//           final newQuantity = _selection.sauce!.quantity + 1;
//           _selection = _selection.copyWith(
//             sauce: _selection.sauce!.copyWith(quantity: newQuantity),
//           );
//         } else {
//           _selection = _selection.copyWith(
//             sauce: IngredientWithQuantity(item: item, quantity: 1),
//           );
//         }
//         break;
//     }
//     notifyListeners();
//   }

//   // Decrease quantity for a meal item
//   void decreaseQuantity(Ingredient item) {
//     switch (item.type) {
//       case 'PROTEIN':
//         if (_selection.protein != null &&
//             _selection.protein!.item.id == item.id &&
//             _selection.protein!.quantity > 0) {
//           final newQuantity = _selection.protein!.quantity - 1;
//           if (newQuantity <= 0) {
//             _selection = _selection.copyWith(protein: null);
//           } else {
//             _selection = _selection.copyWith(
//               protein: _selection.protein!.copyWith(quantity: newQuantity),
//             );
//           }
//         }
//         break;
//       case 'CARBS':
//         if (_selection.carbs != null &&
//             _selection.carbs!.item.id == item.id &&
//             _selection.carbs!.quantity > 0) {
//           final newQuantity = _selection.carbs!.quantity - 1;
//           if (newQuantity <= 0) {
//             _selection = _selection.copyWith(carbs: null);
//           } else {
//             _selection = _selection.copyWith(
//               carbs: _selection.carbs!.copyWith(quantity: newQuantity),
//             );
//           }
//         }
//         break;
//       case 'SIDE':
//         if (_selection.side != null &&
//             _selection.side!.item.id == item.id &&
//             _selection.side!.quantity > 0) {
//           final newQuantity = _selection.side!.quantity - 1;
//           if (newQuantity <= 0) {
//             _selection = _selection.copyWith(side: null);
//           } else {
//             _selection = _selection.copyWith(
//               side: _selection.side!.copyWith(quantity: newQuantity),
//             );
//           }
//         }
//         break;
//       case 'SAUCE':
//         if (_selection.sauce != null &&
//             _selection.sauce!.item.id == item.id &&
//             _selection.sauce!.quantity > 0) {
//           final newQuantity = _selection.sauce!.quantity - 1;
//           if (newQuantity <= 0) {
//             _selection = _selection.copyWith(sauce: null);
//           } else {
//             _selection = _selection.copyWith(
//               sauce: _selection.sauce!.copyWith(quantity: newQuantity),
//             );
//           }
//         }
//         break;
//     }
//     notifyListeners();
//   }

//   // Get quantity for a specific item
//   int getItemQuantity(Ingredient item) {
//     switch (item.type) {
//       case 'PROTEIN':
//         return _selection.protein != null &&
//                 _selection.protein!.item.id == item.id
//             ? _selection.protein!.quantity
//             : 0;
//       case 'CARBS':
//         return _selection.carbs != null && _selection.carbs!.item.id == item.id
//             ? _selection.carbs!.quantity
//             : 0;
//       case 'SIDE':
//         return _selection.side != null && _selection.side!.item.id == item.id
//             ? _selection.side!.quantity
//             : 0;
//       case 'SAUCE':
//         return _selection.sauce != null && _selection.sauce!.item.id == item.id
//             ? _selection.sauce!.quantity
//             : 0;
//       default:
//         return 0;
//     }
//   }

//   // Clear selection
//   void clearSelection() {
//     _selection = CustomMealSelection();
//     notifyListeners();
//   }

//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   // Get suggested sauces based on protein
//   List<Ingredient> getSuggestedSauces() {
//     if (_selection.protein == null) return [];

//     final proteinName = _selection.protein!.item.title.toLowerCase();
//     if (proteinName.contains('chicken')) {
//       return _availableSauces
//           .where((sauce) => sauce.title.toLowerCase().contains('teriyaki'))
//           .toList();
//     } else if (proteinName.contains('salmon')) {
//       return _availableSauces
//           .where((sauce) => sauce.title.toLowerCase().contains('pesto'))
//           .toList();
//     } else if (proteinName.contains('tofu')) {
//       return _availableSauces
//           .where((sauce) => sauce.title.toLowerCase().contains('teriyaki'))
//           .toList();
//     }

//     return _availableSauces;
//   }
// }
