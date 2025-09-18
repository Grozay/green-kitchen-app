class CartItem {
  final int id;
  final int menuMealId;
  final String menuMealTitle;
  final String? menuMealImage;
  final double unitPrice;
  final String? menuMealDescription;
  final int quantity;
  final double totalPrice;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> ingredients;

  CartItem({
    required this.id,
    required this.menuMealId,
    required this.menuMealTitle,
    this.menuMealImage,
    required this.unitPrice,
    this.menuMealDescription,
    required this.quantity,
    required this.totalPrice,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      menuMealId: json['menuMealId'] ?? json['menuMeal']?['id'] ?? 0,
      menuMealTitle: json['menuMealTitle'] ?? json['menuMeal']?['title'] ?? '',
      menuMealImage: json['menuMealImage'] ?? json['menuMeal']?['image'],
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      calories: (json['calories'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      ingredients: List<String>.from(json['ingredients'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuMealId': menuMealId,
      'menuMealTitle': menuMealTitle,
      'menuMealImage': menuMealImage,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': ingredients,
    };
  }

  CartItem copyWith({
    int? id,
    int? menuMealId,
    String? menuMealTitle,
    String? menuMealImage,
    double? unitPrice,
    int? quantity,
    double? totalPrice,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    List<String>? ingredients,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuMealId: menuMealId ?? this.menuMealId,
      menuMealTitle: menuMealTitle ?? this.menuMealTitle,
      menuMealImage: menuMealImage ?? this.menuMealImage,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}

class Cart {
  final List<CartItem> cartItems;
  final double totalAmount;
  final int totalItems;
  final int totalQuantity;

  Cart({
    required this.cartItems,
    required this.totalAmount,
    required this.totalItems,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartItems: (json['cartItems'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      totalItems: json['totalItems'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'totalQuantity': totalQuantity,
    };
  }

  Cart copyWith({
    List<CartItem>? cartItems,
    double? totalAmount,
    int? totalItems,
    int? totalQuantity,
  }) {
    return Cart(
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }
}
