class CreateOrderRequest {
  final int customerId;
  final String street;
  final String ward;
  final String district;
  final String city;
  final String recipientName;
  final String recipientPhone;
  final DateTime? deliveryTime;
  final double subtotal;
  final double shippingFee;
  final double? membershipDiscount;
  final double? couponDiscount;
  final double totalAmount;
  final String paymentMethod;
  final String? paypalOrderId;
  final String? notes;
  final List<OrderItemRequest> orderItems;

  CreateOrderRequest({
    required this.customerId,
    required this.street,
    required this.ward,
    required this.district,
    required this.city,
    required this.recipientName,
    required this.recipientPhone,
    this.deliveryTime,
    required this.subtotal,
    required this.shippingFee,
    this.membershipDiscount,
    this.couponDiscount,
    required this.totalAmount,
    required this.paymentMethod,
    this.paypalOrderId,
    this.notes,
    required this.orderItems,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'deliveryTime': deliveryTime?.toIso8601String(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'membershipDiscount': membershipDiscount,
      'couponDiscount': couponDiscount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paypalOrderId': paypalOrderId,
      'notes': notes,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItemRequest {
  final String itemType; // "MENU_MEAL", "CUSTOM_MEAL", "WEEK_MEAL"
  final int? menuMealId;
  final int? customMealId;
  final int? weekMealId;
  final int quantity;
  final double unitPrice;
  final String? notes;

  OrderItemRequest({
    required this.itemType,
    this.menuMealId,
    this.customMealId,
    this.weekMealId,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemType': itemType,
      'menuMealId': menuMealId,
      'customMealId': customMealId,
      'weekMealId': weekMealId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'notes': notes,
    };
  }
}