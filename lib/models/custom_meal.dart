// Enum cho IngredientType (dựa trên backend và context trước)

// Model cho CustomMealDetail (tương ứng CustomMealDetailResponse.java)
class CustomMealDetail {
  final int id;
  final String title;
  final String type;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String description;
  final String image;
  final double quantity;

  CustomMealDetail({
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

  // Factory constructor từ JSON (từ API response)
  factory CustomMealDetail.fromJson(Map<String, dynamic> json) {
    return CustomMealDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Chuyển thành JSON (để gửi lên API nếu cần)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString().split('.').last, // E.g., "PROTEIN"
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

// Model cho CustomMeal (tương ứng CustomMealResponse.java)
class CustomMeal {
  final int id;
  final int customerId;
  final String title;
  final double price;
  final String description;
  final String image;
  final double protein;
  final double calories;
  final double carb; // Backend có 'carb', có thể là typo của 'carbs'
  final double fat;
  final List<CustomMealDetail> details;

  CustomMeal({
    required this.id,
    required this.customerId,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.protein,
    required this.calories,
    required this.carb,
    required this.fat,
    required this.details,
  });

  // Factory constructor từ JSON (từ API response)
  factory CustomMeal.fromJson(Map<String, dynamic> json) {
    return CustomMeal(
      id: json['id'] as int,
      customerId: json['customerId'] as int,
      title: json['title'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      carb: (json['carb'] as num?)?.toDouble() ?? 0.0, // Backend: 'carb'
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      details: (json['details'] as List<dynamic>?)
              ?.map((item) => CustomMealDetail.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Chuyển thành JSON (để gửi lên API nếu cần)
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
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}