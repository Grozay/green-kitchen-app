enum MenuIngredients {
  GLUTEN,
  PEANUTS,
  TREE_NUTS,
  DAIRY,
  EGG,
  SOY,
  FISH,
  SHELLFISH,
  SESAME,
  CELERY,
  MUSTARD,
  LUPIN,
  MOLLUSCS,
  SULPHITES
}

class MenuMealLiteResponse {
  final int? id;                    // Long nullable từ BE
  final String title;               // title từ BE
  final String slug;                // slug từ BE
  final String? image;              // image từ BE
  final double? carb;               // carbs từ BE
  final double? calo;               // calories từ BE
  final double? protein;            // protein từ BE
  final double? fat;                // fat từ BE
  final double? price;              // price từ BE
  final Set<MenuIngredients>? menuIngredient; // Set<enum> từ BE

  MenuMealLiteResponse({
    this.id,
    required this.title,
    required this.slug,
    this.image,
    this.carb,
    this.calo,
    this.protein,
    this.fat,
    this.price,
    this.menuIngredient,
  });

  factory MenuMealLiteResponse.fromJson(Map<String, dynamic> json) {
    return MenuMealLiteResponse(
      id: json['id'],
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      image: json['image'],
      carb: json['carb']?.toDouble(),
      calo: json['calo']?.toDouble(),
      protein: json['protein']?.toDouble(),
      fat: json['fat']?.toDouble(),
      price: json['price']?.toDouble(),
      menuIngredient: json['menuIngredient'] != null 
          ? (json['menuIngredient'] as List)
              .map((item) => MenuIngredients.values.firstWhere(
                (e) => e.name == item,
                orElse: () => MenuIngredients.GLUTEN,
              ))
              .toSet()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'slug': slug,
      if (image != null) 'image': image,
      if (carb != null) 'carb': carb,
      if (calo != null) 'calo': calo,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (price != null) 'price': price,
      if (menuIngredient != null) 
        'menuIngredient': menuIngredient!.map((e) => e.name).toList(),
    };
  }

  // Helper getters for UI
  String get displayName => title;
  String get imageUrl => image ?? '';
  int get calories => calo?.round() ?? 0;
  List<String> get ingredients => 
      menuIngredient?.map((e) => e.name).toList() ?? [];
}
