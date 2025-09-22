class MenuMeal {
  final int id;
  final String title;
  final String description;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String image;
  final double? price;  // Made nullable to handle null in JSON
  final String slug;
  final int stock;
  final int soldCount;
  final String type;
  final List<String> menuIngredients;
  final List<dynamic> reviews;

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
    required this.soldCount,
    required this.type,
    required this.menuIngredients,
    required this.reviews,
  });

  factory MenuMeal.fromJson(Map<String, dynamic> json) {
    return MenuMeal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      calories: json['calories'],
      protein: json['protein'],
      carbs: json['carbs'],
      fat: json['fat'],
      image: json['image'],
      price: json['price'] as double?,  // Handle null
      slug: json['slug'],
      stock: json['stock'],
      soldCount: json['soldCount'] ?? 0,
      type: json['type'],
      menuIngredients: List<String>.from(json['menuIngredients']),
      reviews: json['reviews'],
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
      'soldCount': soldCount,
      'type': type,
      'menuIngredients': menuIngredients,
      'reviews': reviews,
    };
  }
}