import 'menu_meal_review.dart';  // Thêm import để dùng MenuMealReview

class MenuMeal {
  final int id;
  final String title;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String image;
  final double? price;
  final String slug;
  final int stock;
  final String type;
  final List<String> menuIngredients;
  final List<MenuMealReview> reviews;  // Giữ nguyên, giờ dùng từ menu_meal_review.dart

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
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      calories: (json['calories'] ?? 0.0).toDouble(),
      protein: (json['protein'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fat: (json['fat'] ?? 0.0).toDouble(),
      image: json['image'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      slug: json['slug'] ?? '',
      stock: json['stock'] ?? 0,
      type: json['type'] ?? '',
      menuIngredients: json['menuIngredients'] != null ? List<String>.from(json['menuIngredients']) : [],
      reviews: json['reviews'] != null ? (json['reviews'] as List).map((e) => MenuMealReview.fromJson(e)).toList() : [],
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
      'menuIngredients': menuIngredients,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }
}

// Loại bỏ class MenuMealReview khỏi đây (để tránh xung đột)