import 'package:green_kitchen_app/models/customer_reivew.dart';

class MenuMealReview {
  final int id;
  final int menuMealId;
  final String menuMealTitle;
  final Customer? customer;
  final int customerId;  // Thêm trường này
  final String customerName;
  final int rating;
  final String comment;
  final String? createdAt;
  final String? updatedAt;

  MenuMealReview({
    required this.id,
    required this.menuMealId,
    required this.menuMealTitle,
    this.customer,
    required this.customerId,  // Thêm vào constructor
    required this.customerName,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create an instance from JSON
  factory MenuMealReview.fromJson(Map<String, dynamic> json) {
    return MenuMealReview(
      id: json['id'] as int,
      menuMealId: json['menuMealId'] as int,
      menuMealTitle: json['menuMealTitle'] as String,
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      customerId: json['customerId'] as int? ?? (json['customer'] != null ? json['customer']['id'] as int : 0),  // Lấy từ customer.id nếu không có
      customerName: json['customerName'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  // Method to convert the object to JSON (optional, for sending data back)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menuMealId': menuMealId,
      'menuMealTitle': menuMealTitle,
      'customer': customer?.toJson(),
      'customerId': customerId,  // Thêm vào toJson
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}