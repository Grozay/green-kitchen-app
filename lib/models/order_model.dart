class OrderModel {
  final String id;
  final String orderCode;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String recipientName;
  final String recipientPhone;
  final String street;
  final String ward;
  final String district;
  final String city;
  final String paymentMethod;
  final String paymentStatus;
  final double totalAmount;
  final double subtotal;
  final double shippingFee;
  final double membershipDiscount;
  final double couponDiscount;
  final double pointEarn;
  final String? notes;
  final DateTime? confirmedAt;
  final DateTime? preparingAt;
  final DateTime? shippingAt;
  final DateTime? deliveredAt;
  final DateTime? canceledAt;
  final DateTime? deliveryTime;
  final String? paypalOrderId;
  final List<OrderItemModel> orderItems;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.recipientName,
    required this.recipientPhone,
    required this.street,
    required this.ward,
    required this.district,
    required this.city,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.totalAmount,
    required this.subtotal,
    required this.shippingFee,
    required this.membershipDiscount,
    required this.couponDiscount,
    required this.pointEarn,
    this.notes,
    this.confirmedAt,
    this.preparingAt,
    this.shippingAt,
    this.deliveredAt,
    this.canceledAt,
    this.deliveryTime,
    this.paypalOrderId,
    required this.orderItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderCode: json['orderCode'] ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      recipientName: json['recipientName'] ?? '',
      recipientPhone: json['recipientPhone'] ?? '',
      street: json['street'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'cod',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      membershipDiscount: (json['membershipDiscount'] as num?)?.toDouble() ?? 0.0,
      couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
      pointEarn: (json['pointEarn'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      preparingAt: json['preparingAt'] != null ? DateTime.parse(json['preparingAt']) : null,
      shippingAt: json['shippingAt'] != null ? DateTime.parse(json['shippingAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      canceledAt: json['canceledAt'] != null ? DateTime.parse(json['canceledAt']) : null,
      deliveryTime: json['deliveryTime'] != null ? DateTime.parse(json['deliveryTime']) : null,
      paypalOrderId: json['paypalOrderId'],
      orderItems: (json['orderItems'] as List<dynamic>?)
          ?.map((item) => OrderItemModel.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderCode': orderCode,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'totalAmount': totalAmount,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'membershipDiscount': membershipDiscount,
      'couponDiscount': couponDiscount,
      'pointEarn': pointEarn,
      'notes': notes,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'preparingAt': preparingAt?.toIso8601String(),
      'shippingAt': shippingAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
      'deliveryTime': deliveryTime?.toIso8601String(),
      'paypalOrderId': paypalOrderId,
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItemModel {
  final String id;
  final String itemType;
  final String title;
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String image;
  final String? notes;

  OrderItemModel({
    required this.id,
    required this.itemType,
    required this.title,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.image,
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      itemType: json['itemType']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemType': itemType,
      'title': title,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'image': image,
      'notes': notes,
    };
  }
}