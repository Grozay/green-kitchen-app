class CartItem {
  final int id;
  final int cartId;
  final bool isCustom;
  final MenuMeal? menuMeal;
  final CustomMeal? customMeal;
  final WeekMeal? weekMeal;
  final String itemType;
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
    return CartItem(
      id: json['id'],
      cartId: json['cartId'],
      isCustom: json['isCustom'],
      menuMeal: json['menuMeal'] != null ? MenuMeal.fromJson(json['menuMeal']) : null,
      customMeal: json['customMeal'] != null ? CustomMeal.fromJson(json['customMeal']) : null,
      weekMeal: json['weekMeal'] != null ? WeekMeal.fromJson(json['weekMeal']) : null,
      itemType: json['itemType'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      title: json['title'],
      image: json['image'],
      description: json['description'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cartId': cartId,
      'isCustom': isCustom,
      'menuMeal': menuMeal?.toJson(),
      'customMeal': customMeal?.toJson(),
      'weekMeal': weekMeal?.toJson(),
      'itemType': itemType,
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

class MenuMeal {
  final int id;
  final String title;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String image;
  final double price;
  final String slug;
  final int stock;
  final String type;
  final List<MenuIngredient> menuIngredients;
  final List<Review> reviews;

  MenuMeal({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.image,
    required this.price,
    required this.slug,
    required this.stock,
    required this.type,
    required this.menuIngredients,
    required this.reviews,
  });

  factory MenuMeal.fromJson(Map<String, dynamic> json) {
    return MenuMeal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      image: json['image'],
      price: (json['price'] as num).toDouble(),
      slug: json['slug'],
      stock: json['stock'],
      type: json['type'],
      menuIngredients: (json['menuIngredients'] as List)
          .map((item) => MenuIngredient.fromJson(item))
          .toList(),
      reviews: (json['reviews'] as List)
          .map((item) => Review.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'image': image,
      'price': price,
      'slug': slug,
      'stock': stock,
      'type': type,
      'menuIngredients': menuIngredients.map((item) => item.toJson()).toList(),
      'reviews': reviews.map((item) => item.toJson()).toList(),
    };
  }
}

class CustomMeal {
  final int? id;
  final String? title;

  CustomMeal({
    this.id,
    this.title,
  });

  factory CustomMeal.fromJson(Map<String, dynamic> json) {
    return CustomMeal(
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class WeekMeal {
  final int? id;
  final String? title;

  WeekMeal({
    this.id,
    this.title,
  });

  factory WeekMeal.fromJson(Map<String, dynamic> json) {
    return WeekMeal(
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
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
  // Add more properties as needed

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
    return Cart(
      id: json['id'],
      customerId: json['customerId'],
      cartItems: (json['cartItems'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalItems: json['totalItems'],
      totalQuantity: json['totalQuantity'],
    );
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