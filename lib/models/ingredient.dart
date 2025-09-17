class Ingredient {
  final int id;
  final String title;
  final String description;
  final double protein;
  final double carbs;
  final double fat;
  final String image;
  final double price;
  final String type; // 'protein', 'carbs', 'side', 'sauce'

  Ingredient({
    required this.id,
    required this.title,
    required this.description,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.image,
    required this.price,
    required this.type,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'],
      protein: json['protein'] ?? 0.0,
      carbs: json['carbs'] ?? 0.0,
      fat: json['fat'] ?? 0.0,
      image: json['image'] ?? '',
      price: json['price'] ?? 0.0,
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'image': image,
      'price': price,
      'type': type,
    };
  }

  double get calories => (protein * 4) + (carbs * 4) + (fat * 9);
}

class IngredientWithQuantity {
  final Ingredient item;
  final int quantity;

  IngredientWithQuantity({
    required this.item,
    this.quantity = 0,
  });

  double get totalCalories => item.calories * quantity;
  double get totalProtein => item.protein * quantity;
  double get totalCarbs => item.carbs * quantity;
  double get totalFat => item.fat * quantity;
  double get totalPrice => item.price * quantity;

  IngredientWithQuantity copyWith({
    Ingredient? item,
    int? quantity,
  }) {
    return IngredientWithQuantity(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CustomMealSelection {
  final IngredientWithQuantity? protein;
  final IngredientWithQuantity? carbs;
  final IngredientWithQuantity? side;
  final IngredientWithQuantity? sauce;

  CustomMealSelection({
    this.protein,
    this.carbs,
    this.side,
    this.sauce,
  });

  bool get isComplete => protein != null && carbs != null && side != null && sauce != null && protein!.quantity > 0 && carbs!.quantity > 0 && side!.quantity > 0 && sauce!.quantity > 0;

  double get totalCalories => (protein?.totalCalories ?? 0) + (carbs?.totalCalories ?? 0) + (side?.totalCalories ?? 0) + (sauce?.totalCalories ?? 0);

  double get totalProtein => (protein?.totalProtein ?? 0) + (carbs?.totalProtein ?? 0) + (side?.totalProtein ?? 0) + (sauce?.totalProtein ?? 0);

  double get totalCarbs => (protein?.totalCarbs ?? 0) + (carbs?.totalCarbs ?? 0) + (side?.totalCarbs ?? 0) + (sauce?.totalCarbs ?? 0);

  double get totalFat => (protein?.totalFat ?? 0) + (carbs?.totalFat ?? 0) + (side?.totalFat ?? 0) + (sauce?.totalFat ?? 0);

  double get totalPrice => (protein?.totalPrice ?? 0) + (carbs?.totalPrice ?? 0) + (side?.totalPrice ?? 0) + (sauce?.totalPrice ?? 0);

  List<IngredientWithQuantity> get selectedItems {
    return [protein, carbs, side, sauce].where((item) => item != null).cast<IngredientWithQuantity>().toList();
  }

  CustomMealSelection copyWith({
    IngredientWithQuantity? protein,
    IngredientWithQuantity? carbs,
    IngredientWithQuantity? side,
    IngredientWithQuantity? sauce,
  }) {
    return CustomMealSelection(
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      side: side ?? this.side,
      sauce: sauce ?? this.sauce,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein': protein != null ? {'item': protein!.item.toJson(), 'quantity': protein!.quantity} : null,
      'carbs': carbs != null ? {'item': carbs!.item.toJson(), 'quantity': carbs!.quantity} : null,
      'side': side != null ? {'item': side!.item.toJson(), 'quantity': side!.quantity} : null,
      'sauce': sauce != null ? {'item': sauce!.item.toJson(), 'quantity': sauce!.quantity} : null,
    };
  }
}

class NutritionInfo {
  final double protein;
  final double carbs;
  final double fat;

  NutritionInfo({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory NutritionInfo.zero() {
    return NutritionInfo(
      protein: 0,
      carbs: 0,
      fat: 0,
    );
  }

  NutritionInfo operator +(NutritionInfo other) {
    return NutritionInfo(
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fat: fat + other.fat,
    );
  }

  double get calories => (protein * 4) + (carbs * 4) + (fat * 9);

  @override
  String toString() {
    return 'Calories: ${calories.toStringAsFixed(0)}, Protein: ${protein.toStringAsFixed(1)}g, Carbs: ${carbs.toStringAsFixed(1)}g, Fat: ${fat.toStringAsFixed(1)}g';
  }
}
