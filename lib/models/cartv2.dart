import 'cartItem.dart';

class CartV2 {
  final int id;
  final int customerId;
  final List<CartItem> cartItems;
  final double totalAmount;
  final int totalItems;
  final int totalQuantity;

  CartV2({
    required this.id,
    required this.customerId,
    required this.cartItems,
    required this.totalAmount,
    required this.totalItems,
    required this.totalQuantity,
  });

  factory CartV2.fromJson(Map<String, dynamic> json) {
    return CartV2(
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

  CartV2 copyWith({
    int? id,
    int? customerId,
    List<CartItem>? cartItems,
    double? totalAmount,
    int? totalItems,
    int? totalQuantity,
  }) {
    return CartV2(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      cartItems: cartItems ?? this.cartItems,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }
}