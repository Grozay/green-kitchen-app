import 'package:green_kitchen_app/models/enum.dart';
import 'package:green_kitchen_app/models/menu_meal.dart';

class CartItem {
  final int id;
  final int cartId;
  final bool isCustom;
  final MenuMeal? menuMeal;
  final CustomMeal? customMeal;
  final WeekMeal? weekMeal;
  final OrderItemType itemType;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String title;
  final String image;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  CartItem({
    required this.id,
    required this.cartId,
    required this.isCustom,
    this.menuMeal,
    this.customMeal,
    this.weekMeal,
    required this.itemType,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.title,
    required this.image,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      return CartItem(
        id: json['id'] ?? 0,
        cartId: json['cartId'] ?? 0,
        isCustom: json['isCustom'] ?? false,
        menuMeal: json['menuMeal'] != null ? MenuMeal.fromJson(json['menuMeal']) : null,
        customMeal: json['customMeal'] != null ? CustomMeal.fromJson(json['customMeal']) : null,
        weekMeal: json['weekMeal'] != null ? WeekMeal.fromJson(json['weekMeal']) : null,
        itemType: json['itemType'] != null ? OrderItemType.values.firstWhere((e) => e.name == json['itemType']) : OrderItemType.MENU_MEAL, // Thêm null check
        quantity: json['quantity'] ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
        title: json['title'] ?? '',
        image: json['image'] ?? '',
        description: json['description'] ?? '',
        calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('Error parsing CartItem: $e');
      rethrow; // Hoặc return default CartItem
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'isCustom': isCustom,
      'menuMeal': menuMeal?.toJson(),
      'customMeal': customMeal?.toJson(),
      'weekMeal': weekMeal?.toJson(),
      'itemType': itemType.name, // Serialize enum
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'title': title,
      'image': image,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

// class MenuMeal {
//   final int id;
//   final String title;
//   final String description;
//   final double calories;
//   final double protein;
//   final double carbs;
//   final double fat;
//   final String image;
//   final double price;
//   final String slug;
//   final int stock;
//   final MenuMealType type; // Thay String bằng MenuMealType
//   final Set<String> menuIngredients; // Thay List<MenuIngredient> bằng Set<String> để match backend (Set<MenuIngredients>)
//   final List<MenuMealReviewResponse> reviews; // Thêm nếu cần, hoặc bỏ nếu không dùng

//   MenuMeal({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.calories,
//     required this.protein,
//     required this.carbs,
//     required this.fat,
//     required this.image,
//     required this.price,
//     required this.slug,
//     required this.stock,
//     required this.type,
//     required this.menuIngredients,
//     required this.reviews,
//   });

//   factory MenuMeal.fromJson(Map<String, dynamic> json) {
//     try {
//       return MenuMeal(
//         id: json['id'] ?? 0,
//         title: json['title'] ?? '',
//         description: json['description'] ?? '',
//         calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
//         protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
//         carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
//         fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
//         image: json['image'] ?? '',
//         price: (json['price'] as num?)?.toDouble() ?? 0.0,
//         slug: json['slug'] ?? '',
//         stock: json['stock'] ?? 0,
//         type: json['type'] != null ? MenuMealType.values.firstWhere((e) => e.name == json['type']) : MenuMealType.BALANCE, // Thêm null check
//         menuIngredients: (json['menuIngredients'] as List?)?.map((item) => item.toString()).toSet() ?? <String>{},
//         reviews: (json['reviews'] as List?)?.map((item) => MenuMealReviewResponse.fromJson(item)).toList() ?? [],
//       );
//     } catch (e) {
//       print('Error parsing MenuMeal: $e');
//       throw e; // Hoặc return default MenuMeal
//     }
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'calories': calories,
//       'protein': protein,
//       'carbs': carbs,
//       'fat': fat,
//       'image': image,
//       'price': price,
//       'slug': slug,
//       'stock': stock,
//       'type': type.name, // Serialize enum
//       'menuIngredients': menuIngredients.toList(),
//       'reviews': reviews.map((item) => item.toJson()).toList(),
//     };
//   }
// }

// // Thêm class MenuMealReviewResponse nếu cần
// class MenuMealReviewResponse {
//   final int id;
//   final String comment;
//   final double rating;

//   MenuMealReviewResponse({
//     required this.id,
//     required this.comment,
//     required this.rating,
//   });

//   factory MenuMealReviewResponse.fromJson(Map<String, dynamic> json) {
//     return MenuMealReviewResponse(
//       id: json['id'],
//       comment: json['comment'],
//       rating: (json['rating'] as num).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'comment': comment,
//       'rating': rating,
//     };
//   }
// }

class CustomMeal {
  final int? id;
  final int? customerId; // Thêm từ CustomMealResponse.java
  final String? title;
  final double? price; // Thêm
  final String? description; // Thêm
  final String? image; // Thêm
  final double? protein; // Thêm
  final double? calories; // Thêm
  final double? carb; // Thêm
  final double? fat; // Thêm
  final List<CustomMealDetailResponse>? details; // Thêm

  CustomMeal({
    this.id,
    this.customerId,
    this.title,
    this.price,
    this.description,
    this.image,
    this.protein,
    this.calories,
    this.carb,
    this.fat,
    this.details,
  });

  factory CustomMeal.fromJson(Map<String, dynamic> json) {
    return CustomMeal(
      id: json['id'],
      customerId: json['customerId'],
      title: json['title'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      description: json['description'],
      image: json['image'],
      protein: json['protein'] != null ? (json['protein'] as num).toDouble() : null,
      calories: json['calories'] != null ? (json['calories'] as num).toDouble() : null,
      carb: json['carb'] != null ? (json['carb'] as num).toDouble() : null,
      fat: json['fat'] != null ? (json['fat'] as num).toDouble() : null,
      details: json['details'] != null ? (json['details'] as List).map((item) => CustomMealDetailResponse.fromJson(item)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'title': title,
      'price': price,
      'description': description,
      'image': image,
      'protein': protein,
      'calories': calories,
      'carb': carb,
      'fat': fat,
      'details': details?.map((item) => item.toJson()).toList(),
    };
  }
}

// Thêm class CustomMealDetailResponse
class CustomMealDetailResponse {
  final int id;
  final String title;
  final IngredientType type; // Thay String bằng IngredientType
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String description;
  final String image;
  final double quantity;

  CustomMealDetailResponse({
    required this.id,
    required this.title,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.description,
    required this.image,
    required this.quantity,
  });

  factory CustomMealDetailResponse.fromJson(Map<String, dynamic> json) {
    return CustomMealDetailResponse(
      id: json['id'],
      title: json['title'],
      type: IngredientType.values.firstWhere((e) => e.name == json['type']), // Parse enum
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      description: json['description'],
      image: json['image'],
      quantity: (json['quantity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name, // Serialize enum
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'description': description,
      'image': image,
      'quantity': quantity,
    };
  }
}

class WeekMeal {
  final int? id;
  final String? type; // Thêm từ WeekMealResponse.java
  final DateTime? weekStart; // Thêm
  final DateTime? weekEnd; // Thêm
  final List<WeekMealDayResponse>? days; // Thêm

  WeekMeal({
    this.id,
    this.type,
    this.weekStart,
    this.weekEnd,
    this.days,
  });

  factory WeekMeal.fromJson(Map<String, dynamic> json) {
    return WeekMeal(
      id: json['id'],
      type: json['type'],
      weekStart: json['weekStart'] != null ? DateTime.parse(json['weekStart']) : null,
      weekEnd: json['weekEnd'] != null ? DateTime.parse(json['weekEnd']) : null,
      days: json['days'] != null ? (json['days'] as List).map((item) => WeekMealDayResponse.fromJson(item)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'weekStart': weekStart?.toIso8601String(),
      'weekEnd': weekEnd?.toIso8601String(),
      'days': days?.map((item) => item.toJson()).toList(),
    };
  }
}

// Thêm class WeekMealDayResponse
class WeekMealDayResponse {
  final int id;
  final String day;
  final DateTime date;
  final String type;
  final MenuMeal? meal1;
  final MenuMeal? meal2;
  final MenuMeal? meal3;

  WeekMealDayResponse({
    required this.id,
    required this.day,
    required this.date,
    required this.type,
    this.meal1,
    this.meal2,
    this.meal3,
  });

  factory WeekMealDayResponse.fromJson(Map<String, dynamic> json) {
    return WeekMealDayResponse(
      id: json['id'],
      day: json['day'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      meal1: json['meal1'] != null ? MenuMeal.fromJson(json['meal1']) : null,
      meal2: json['meal2'] != null ? MenuMeal.fromJson(json['meal2']) : null,
      meal3: json['meal3'] != null ? MenuMeal.fromJson(json['meal3']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'date': date.toIso8601String(),
      'type': type,
      'meal1': meal1?.toJson(),
      'meal2': meal2?.toJson(),
      'meal3': meal3?.toJson(),
    };
  }
}

class MenuIngredient {
  final int id;
  final String name;

  MenuIngredient({
    required this.id,
    required this.name,
  });

  factory MenuIngredient.fromJson(Map<String, dynamic> json) {
    return MenuIngredient(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Review {
  final int id;
  final String comment;
  final double rating;

  Review({
    required this.id,
    required this.comment,
    required this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      comment: json['comment'],
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'rating': rating,
    };
  }
}

class Cart {
  final int id;
  final int customerId;
  final List<CartItem> cartItems;
  final double totalAmount;
  final int totalItems;
  final int totalQuantity;

  Cart({
    required this.id,
    required this.customerId,
    required this.cartItems,
    required this.totalAmount,
    required this.totalItems,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    try {
      return Cart(
        id: json['id'] ?? 0,
        customerId: json['customerId'] ?? 0,
        cartItems: (json['cartItems'] as List?)?.map((item) => CartItem.fromJson(item)).toList() ?? [],
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        totalItems: json['totalItems'] ?? 0,
        totalQuantity: json['totalQuantity'] ?? 0,
      );
    } catch (e) {
      print('Error parsing Cart: $e');
      rethrow; // Hoặc return default Cart
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'cartItems': cartItems.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'totalQuantity': totalQuantity,
    };
  }

  // Thêm copyWith method
  Cart copyWith({
    int? id,
    int? customerId,
    List<CartItem>? cartItems,
    double? totalAmount,
    int? totalItems,
    int? totalQuantity,
  }) {
    return Cart(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }
}

enum ItemType {
  menuMeal('MENU_MEAL'),
  customMeal('CUSTOM_MEAL'),
  weekMeal('WEEK_MEAL');

  const ItemType(this.value);
  final String value;
}

enum MealType {
  balance('BALANCE'),
  protein('PROTEIN'),
  lowCarb('LOW_CARB');

  const MealType(this.value);
  final String value;
}
