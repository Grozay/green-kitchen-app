class Customer {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final DateTime? passwordUpdatedAt;
  final String email;
  final DateTime? birthDate;
  final String? gender;
  final String? phone;
  final bool isActive;
  final bool isPhoneLogin;
  final bool isEmailLogin;
  final String? oauthProvider;
  final String? oauthProviderId;
  final bool isOauthUser;
  final List<Address>? addresses;
  final List<CustomerTDEE>? customerTDEEs;
  final List<PointHistory>? pointHistories;
  final Membership? membership;
  final CustomerReference? customerReference;
  final List<Order>? orders;  // Quan trọng: để check purchase
  final List<CustomerCoupon>? customerCoupons;
  final String? fullName;

  Customer({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.firstName,
    this.lastName,
    this.avatar,
    this.passwordUpdatedAt,
    required this.email,
    this.birthDate,
    this.gender,
    this.phone,
    required this.isActive,
    required this.isPhoneLogin,
    required this.isEmailLogin,
    this.oauthProvider,
    this.oauthProviderId,
    required this.isOauthUser,
    this.addresses,
    this.customerTDEEs,
    this.pointHistories,
    this.membership,
    this.customerReference,
    this.orders,
    this.customerCoupons,
    this.fullName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      passwordUpdatedAt: json['passwordUpdatedAt'] != null ? DateTime.parse(json['passwordUpdatedAt']) : null,
      email: json['email'] ?? '',
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'],
      phone: json['phone'],
      isActive: json['isActive'] ?? true,
      isPhoneLogin: json['isPhoneLogin'] ?? false,
      isEmailLogin: json['isEmailLogin'] ?? true,
      oauthProvider: json['oauthProvider'],
      oauthProviderId: json['oauthProviderId'],
      isOauthUser: json['isOauthUser'] ?? false,
      addresses: json['addresses'] != null ? (json['addresses'] as List).map((e) => Address.fromJson(e)).toList() : null,
      customerTDEEs: json['customerTDEEs'] != null ? (json['customerTDEEs'] as List).map((e) => CustomerTDEE.fromJson(e)).toList() : null,
      pointHistories: json['pointHistories'] != null ? (json['pointHistories'] as List).map((e) => PointHistory.fromJson(e)).toList() : null,
      membership: json['membership'] != null ? Membership.fromJson(json['membership']) : null,
      customerReference: json['customerReference'] != null ? CustomerReference.fromJson(json['customerReference']) : null,
      orders: json['orders'] != null ? (json['orders'] as List).map((e) => Order.fromJson(e)).toList() : null,  // Parse orders
      customerCoupons: json['customerCoupons'] != null ? (json['customerCoupons'] as List).map((e) => CustomerCoupon.fromJson(e)).toList() : null,
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'passwordUpdatedAt': passwordUpdatedAt?.toIso8601String(),
      'email': email,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'phone': phone,
      'isActive': isActive,
      'isPhoneLogin': isPhoneLogin,
      'isEmailLogin': isEmailLogin,
      'oauthProvider': oauthProvider,
      'oauthProviderId': oauthProviderId,
      'isOauthUser': isOauthUser,
      'addresses': addresses?.map((e) => e.toJson()).toList(),
      'customerTDEEs': customerTDEEs?.map((e) => e.toJson()).toList(),
      'pointHistories': pointHistories?.map((e) => e.toJson()).toList(),
      'membership': membership?.toJson(),
      'customerReference': customerReference?.toJson(),
      'orders': orders?.map((e) => e.toJson()).toList(),
      'customerCoupons': customerCoupons?.map((e) => e.toJson()).toList(),
      'fullName': fullName,
    };
  }
}

// Các sub-models dựa trên response
class Address {
  final int id;
  final String street;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;

  Address({
    required this.id,
    required this.street,
    required this.ward,
    required this.district,
    required this.city,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? 0,
      street: json['street'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'isDefault': isDefault,
    };
  }
}

class CustomerTDEE {
  final int id;
  final double tdee;

  CustomerTDEE({
    required this.id,
    required this.tdee,
  });

  factory CustomerTDEE.fromJson(Map<String, dynamic> json) {
    return CustomerTDEE(
      id: json['id'] ?? 0,
      tdee: (json['tdee'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tdee': tdee,
    };
  }
}

class PointHistory {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double spentAmount;
  final double pointsEarned;
  final DateTime? earnedAt;
  final DateTime? expiresAt;
  final String transactionType;
  final String description;
  final String? orderId;
  final bool isExpired;

  PointHistory({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.spentAmount,
    required this.pointsEarned,
    this.earnedAt,
    this.expiresAt,
    required this.transactionType,
    required this.description,
    this.orderId,
    required this.isExpired,
  });

  factory PointHistory.fromJson(Map<String, dynamic> json) {
    return PointHistory(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      spentAmount: (json['spentAmount'] ?? 0.0).toDouble(),
      pointsEarned: (json['pointsEarned'] ?? 0.0).toDouble(),
      earnedAt: json['earnedAt'] != null ? DateTime.parse(json['earnedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      transactionType: json['transactionType'] ?? '',
      description: json['description'] ?? '',
      orderId: json['orderId'],
      isExpired: json['isExpired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'spentAmount': spentAmount,
      'pointsEarned': pointsEarned,
      'earnedAt': earnedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'transactionType': transactionType,
      'description': description,
      'orderId': orderId,
      'isExpired': isExpired,
    };
  }
}

class Membership {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String currentTier;
  final double totalSpentLast6Months;
  final double availablePoints;
  final double totalPointsEarned;
  final double totalPointsUsed;
  final DateTime? lastUpdatedAt;
  final DateTime? tierAchievedAt;

  Membership({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.currentTier,
    required this.totalSpentLast6Months,
    required this.availablePoints,
    required this.totalPointsEarned,
    required this.totalPointsUsed,
    this.lastUpdatedAt,
    this.tierAchievedAt,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      currentTier: json['currentTier'] ?? '',
      totalSpentLast6Months: (json['totalSpentLast6Months'] ?? 0.0).toDouble(),
      availablePoints: (json['availablePoints'] ?? 0.0).toDouble(),
      totalPointsEarned: (json['totalPointsEarned'] ?? 0.0).toDouble(),
      totalPointsUsed: (json['totalPointsUsed'] ?? 0.0).toDouble(),
      lastUpdatedAt: json['lastUpdatedAt'] != null ? DateTime.parse(json['lastUpdatedAt']) : null,
      tierAchievedAt: json['tierAchievedAt'] != null ? DateTime.parse(json['tierAchievedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'currentTier': currentTier,
      'totalSpentLast6Months': totalSpentLast6Months,
      'availablePoints': availablePoints,
      'totalPointsEarned': totalPointsEarned,
      'totalPointsUsed': totalPointsUsed,
      'lastUpdatedAt': lastUpdatedAt?.toIso8601String(),
      'tierAchievedAt': tierAchievedAt?.toIso8601String(),
    };
  }
}

class CustomerReference {
  final int id;
  final String code;

  CustomerReference({
    required this.id,
    required this.code,
  });

  factory CustomerReference.fromJson(Map<String, dynamic> json) {
    return CustomerReference(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
    };
  }
}

class Order {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String orderCode;
  final String status;
  final String paymentStatus;
  final String street;
  final String ward;
  final String district;
  final String city;
  final String recipientName;
  final String recipientPhone;
  final DateTime? deliveryTime;
  final DateTime? confirmedAt;
  final DateTime? preparingAt;
  final DateTime? shippingAt;
  final DateTime? deliveredAt;
  final DateTime? canceledAt;
  final double subtotal;
  final double shippingFee;
  final double membershipDiscount;
  final double couponDiscount;
  final double totalAmount;
  final double pointEarn;
  final String notes;
  final String paymentMethod;
  final List<OrderItem>? orderItems;  // Quan trọng: để check title

  Order({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.orderCode,
    required this.status,
    required this.paymentStatus,
    required this.street,
    required this.ward,
    required this.district,
    required this.city,
    required this.recipientName,
    required this.recipientPhone,
    this.deliveryTime,
    this.confirmedAt,
    this.preparingAt,
    this.shippingAt,
    this.deliveredAt,
    this.canceledAt,
    required this.subtotal,
    required this.shippingFee,
    required this.membershipDiscount,
    required this.couponDiscount,
    required this.totalAmount,
    required this.pointEarn,
    required this.notes,
    required this.paymentMethod,
    this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      orderCode: json['orderCode'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      street: json['street'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      recipientName: json['recipientName'] ?? '',
      recipientPhone: json['recipientPhone'] ?? '',
      deliveryTime: json['deliveryTime'] != null ? DateTime.parse(json['deliveryTime']) : null,
      confirmedAt: json['confirmedAt'] != null ? DateTime.parse(json['confirmedAt']) : null,
      preparingAt: json['preparingAt'] != null ? DateTime.parse(json['preparingAt']) : null,
      shippingAt: json['shippingAt'] != null ? DateTime.parse(json['shippingAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      canceledAt: json['canceledAt'] != null ? DateTime.parse(json['canceledAt']) : null,
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0.0).toDouble(),
      membershipDiscount: (json['membershipDiscount'] ?? 0.0).toDouble(),
      couponDiscount: (json['couponDiscount'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      pointEarn: (json['pointEarn'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      orderItems: json['orderItems'] != null ? (json['orderItems'] as List).map((e) => OrderItem.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'orderCode': orderCode,
      'status': status,
      'paymentStatus': paymentStatus,
      'street': street,
      'ward': ward,
      'district': district,
      'city': city,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'deliveryTime': deliveryTime?.toIso8601String(),
      'confirmedAt': confirmedAt?.toIso8601String(),
      'preparingAt': preparingAt?.toIso8601String(),
      'shippingAt': shippingAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'membershipDiscount': membershipDiscount,
      'couponDiscount': couponDiscount,
      'totalAmount': totalAmount,
      'pointEarn': pointEarn,
      'notes': notes,
      'paymentMethod': paymentMethod,
      'orderItems': orderItems?.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String itemType;
  final String title;  // Quan trọng: để check purchase
  final String description;
  final String image;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String notes;

  OrderItem({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.itemType,
    required this.title,
    required this.description,
    required this.image,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      itemType: json['itemType'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'itemType': itemType,
      'title': title,
      'description': description,
      'image': image,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'notes': notes,
    };
  }
}

class CustomerCoupon {
  final int id;
  final String code;
  final double discount;

  CustomerCoupon({
    required this.id,
    required this.code,
    required this.discount,
  });

  factory CustomerCoupon.fromJson(Map<String, dynamic> json) {
    return CustomerCoupon(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      discount: (json['discount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
    };
  }
}