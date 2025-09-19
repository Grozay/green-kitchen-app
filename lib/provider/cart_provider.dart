// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/cart.dart';
// import '../models/ingredient.dart';
// import '../services/cart_service.dart';
// import '../services/ingredient_service.dart';

// class CartProvider with ChangeNotifier {
//   Cart? _cart;
//   bool _isLoading = false;
//   String? _error;
//   SharedPreferences? _prefs;
//   static const String _cartKey = 'cart_data';

//   Cart? get cart => _cart;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   int get cartItemCount => _cart?.totalItems ?? 0;
//   double get totalAmount => _cart?.totalAmount ?? 0.0;

//   // Khởi tạo và load từ local storage
//   Future<void> initialize() async {
//     _prefs = await SharedPreferences.getInstance();
//     await loadCartFromLocal();
//   }

//   // Load từ local storage
//   Future<void> loadCartFromLocal() async {
//     if (_prefs == null) {
//       await initialize(); // Tự động khởi tạo nếu chưa có
//     }

//     final cartJson = _prefs!.getString(_cartKey);
//     if (cartJson != null) {
//       final cartMap = jsonDecode(cartJson);
//       _cart = Cart.fromJson(cartMap);
//     } else {
//       // KHÔNG tạo cart trống ở đây, để null để loadCart() biết cần load từ server
//       _cart = null;
//     }
//   }

//   // Lưu cart vào local storage
//   Future<void> _saveCartToLocal() async {
//     if (_prefs == null) {
//       await initialize(); // Tự động khởi tạo nếu chưa có
//     }

//     if (_cart != null) {
//       final cartJson = jsonEncode(_cart!.toJson());
//       await _prefs!.setString(_cartKey, cartJson);
//     }
//   }

//   // Add meal to cart (CRUD trực tiếp trên local, sync background)
//   Future<void> addMealToCart(
//     int customerId, {
//     required int menuMealId,
//     required int quantity,
//     required double unitPrice,
//     required String title,
//     required String description,
//     required String image,
//     required int calories,
//     required double protein,
//     required double carbs,
//     required double fat,
//   }) async {
//     if (_cart == null) {
//       _cart = Cart(
//         cartItems: [],
//         totalAmount: 0.0,
//         totalItems: 0,
//         totalQuantity: 0,
//       );
//     }

//     final existingItemIndex = _cart!.cartItems.indexWhere(
//       (item) => item.menuMealId == menuMealId,
//     );
//     if (existingItemIndex != -1) {
//       // Update existing item
//       final existingItem = _cart!.cartItems[existingItemIndex];
//       final newQuantity = existingItem.quantity + quantity;
//       _cart!.cartItems[existingItemIndex] = existingItem.copyWith(
//         quantity: newQuantity,
//         totalPrice: unitPrice * newQuantity,
//       );
//     } else {
//       final newItem = CartItem(
//         id: DateTime.now().millisecondsSinceEpoch, // Tạm thời tạo ID giả
//         menuMealId: menuMealId,
//         quantity: quantity,
//         unitPrice: unitPrice,
//         totalPrice: unitPrice * quantity,
//         menuMealTitle: title,
//         menuMealDescription: description,
//         menuMealImage: image,
//         calories: calories.toDouble(),
//         protein: protein,
//         carbs: carbs,
//         fat: fat,
//         ingredients: [],
//       );
//       _cart!.cartItems.add(newItem);
//     }

//     _recalculateCartTotals();
//     await _saveCartToLocal();
//     notifyListeners();

//     // Sync với server trong background
//     _syncAddToServer(
//       customerId,
//       menuMealId,
//       quantity,
//       unitPrice,
//       title,
//       description,
//       image,
//       calories,
//       protein,
//       carbs,
//       fat,
//     );
//   }

//   // Increase quantity (CRUD trên local, sync background)
//   Future<void> increaseQuantity(int customerId, int cartItemId) async {
//     if (_cart == null) return;

//     final itemIndex = _cart!.cartItems.indexWhere(
//       (item) => item.id == cartItemId,
//     );
//     if (itemIndex != -1) {
//       final item = _cart!.cartItems[itemIndex];
//       final newQuantity = item.quantity + 1;
//       _cart!.cartItems[itemIndex] = item.copyWith(
//         quantity: newQuantity,
//         totalPrice: item.unitPrice * newQuantity,
//       );
//       _recalculateCartTotals();
//       await _saveCartToLocal();
//       notifyListeners();

//       // Sync với server
//       _syncIncreaseToServer(customerId, cartItemId);
//     }
//   }

//   // Decrease quantity (CRUD trên local, sync background)
//   Future<void> decreaseQuantity(int customerId, int cartItemId) async {
//     if (_cart == null) return;

//     final itemIndex = _cart!.cartItems.indexWhere(
//       (item) => item.id == cartItemId,
//     );
//     if (itemIndex != -1) {
//       final item = _cart!.cartItems[itemIndex];
//       if (item.quantity > 1) {
//         final newQuantity = item.quantity - 1;
//         _cart!.cartItems[itemIndex] = item.copyWith(
//           quantity: newQuantity,
//           totalPrice: item.unitPrice * newQuantity,
//         );
//         _recalculateCartTotals();
//         await _saveCartToLocal();
//         notifyListeners();

//         // Sync với server
//         _syncDecreaseToServer(customerId, cartItemId);
//       } else {
//         // Nếu quantity = 1, remove item
//         await removeFromCart(customerId, cartItemId);
//       }
//     }
//   }

//   // Remove item from cart (CRUD trên local, sync background)
//   Future<void> removeFromCart(int customerId, int cartItemId) async {
//     if (_cart == null) return;

//     _cart!.cartItems.removeWhere((item) => item.id == cartItemId);
//     _recalculateCartTotals();
//     await _saveCartToLocal();
//     notifyListeners();

//     // Sync với server
//     _syncRemoveToServer(customerId, cartItemId);
//   }

//   // Helper: Recalculate totals
//   void _recalculateCartTotals() {
//     if (_cart == null) return;

//     double totalAmount = 0.0;
//     int totalQuantity = 0;

//     for (final item in _cart!.cartItems) {
//       totalAmount += item.totalPrice;
//       totalQuantity += item.quantity;
//     }

//     _cart = _cart!.copyWith(
//       totalAmount: totalAmount,
//       totalItems: _cart!.cartItems.length,
//       totalQuantity: totalQuantity,
//     );
//   }

//   // Sync methods (background, không ảnh hưởng UI)
//   Future<void> _syncWithServerInBackground(int customerId) async {
//     try {
//       final serverCart = await CartService().getCartByCustomerId(customerId);
//       _cart = serverCart;
//       await _saveCartToLocal();
//       notifyListeners();
//     } catch (e) {
//       // Silent fail, giữ local data
//       print('Sync failed: $e');
//     }
//   }

//   Future<void> _syncAddToServer(
//     int customerId,
//     int menuMealId,
//     int quantity,
//     double unitPrice,
//     String title,
//     String description,
//     String image,
//     int calories,
//     double protein,
//     double carbs,
//     double fat,
//   ) async {
//     try {
//       final data = CartService.createAddToCartData(
//         menuMealId: menuMealId,
//         quantity: quantity,
//         unitPrice: unitPrice,
//         title: title,
//         description: description,
//         image: image,
//         calories: calories,
//         protein: protein,
//         carbs: carbs,
//         fat: fat,
//       );
//       await CartService().addMealToCart(customerId, data);
//     } catch (e) {
//       print('Sync add failed: $e');
//     }
//   }

//   Future<void> _syncIncreaseToServer(int customerId, int cartItemId) async {
//     try {
//       await CartService().increaseQuantity(customerId, cartItemId);
//     } catch (e) {
//       print('Sync increase failed: $e');
//     }
//   }

//   Future<void> _syncDecreaseToServer(int customerId, int cartItemId) async {
//     try {
//       await CartService().decreaseQuantity(customerId, cartItemId);
//     } catch (e) {
//       print('Sync decrease failed: $e');
//     }
//   }

//   Future<void> _syncRemoveToServer(int customerId, int cartItemId) async {
//     try {
//       await CartService().removeFromCart(customerId, cartItemId);
//     } catch (e) {
//       print('Sync remove failed: $e');
//     }
//   }

//   // Clear cart (xóa local và server nếu cần)
//   Future<void> clearCart(int customerId) async {
//     if (_prefs == null) {
//       await initialize(); // Tự động khởi tạo nếu chưa có
//     }

//     _cart = Cart(
//       cartItems: [],
//       totalAmount: 0.0,
//       totalItems: 0,
//       totalQuantity: 0,
//     );
//     await _prefs!.remove(_cartKey);
//     notifyListeners();

//     // Có thể sync clear với server nếu API hỗ trợ
//   }

//   // Clear error
//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }

//   // Các getter helper (giữ nguyên)
//   CartItem? getCartItemByMenuMealId(int menuMealId) {
//     if (_cart == null) return null;
//     try {
//       return _cart!.cartItems.firstWhere(
//         (item) => item.menuMealId == menuMealId,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   bool isMealInCart(int menuMealId) {
//     return getCartItemByMenuMealId(menuMealId) != null;
//   }

//   int getMealQuantity(int menuMealId) {
//     final item = getCartItemByMenuMealId(menuMealId);
//     return item?.quantity ?? 0;
//   }

//   // Hoặc nếu bạn muốn có method riêng để check lần đầu sử dụng
//   Future<void> initializeCart(int customerId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       // Kiểm tra có data local không
//       await loadCartFromLocal();

//       if (_cart == null) {
//         // Lần đầu sử dụng, load từ server
//         try {
//           _cart = await CartService().getCartByCustomerId(customerId);
//           print('Loaded cart from server: ${_cart?.cartItems.length} items');
//         } catch (e) {
//           // Server không có data hoặc lỗi, tạo cart trống
//           print('No cart on server or error: $e');
//           _cart = Cart(
//             cartItems: [],
//             totalAmount: 0.0,
//             totalItems: 0,
//             totalQuantity: 0,
//           );
//         }

//         // Lưu vào local storage
//         await _saveCartToLocal();
//       } else {
//         print('Loaded cart from local: ${_cart?.cartItems.length} items');
//         // Có data local, sync với server trong background
//         _syncWithServerInBackground(customerId);
//       }
//     } catch (e) {
//       _error = e.toString();
//       if (_cart == null) {
//         _cart = Cart(
//           cartItems: [],
//           totalAmount: 0.0,
//           totalItems: 0,
//           totalQuantity: 0,
//         );
//       }
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }

// // CustomMealProvider giữ nguyên (không thay đổi)
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
