class Coupon {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String type; // 'PERCENTAGE' or 'FIXED_AMOUNT'
  final double discountValue;
  final double? maxDiscount;
  final double pointsRequired;
  final DateTime validUntil;
  final int? exchangeLimit;
  final int exchangeCount;
  final String status; // 'ACTIVE', 'INACTIVE', 'EXPIRED'
  final String applicability; // 'GENERAL' or 'SPECIFIC_CUSTOMER'

  const Coupon({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    required this.discountValue,
    this.maxDiscount,
    required this.pointsRequired,
    required this.validUntil,
    this.exchangeLimit,
    required this.exchangeCount,
    required this.status,
    required this.applicability,
  });

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'].toString(),
      code: map['code'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      type: map['type'] as String,
      discountValue: (map['discountValue'] as num).toDouble(),
      maxDiscount: map['maxDiscount'] != null ? (map['maxDiscount'] as num).toDouble() : null,
      pointsRequired: (map['pointsRequired'] as num).toDouble(),
      validUntil: DateTime.parse(map['validUntil'] as String),
      exchangeLimit: map['exchangeLimit'] as int?,
      exchangeCount: (map['exchangeCount'] as num?)?.toInt() ?? 0,
      status: map['status'] as String,
      applicability: map['applicability'] as String,
    );
  }

  // Helper getters
  bool get isValid => DateTime.now().isBefore(validUntil) && status == 'ACTIVE';
  bool get isAvailable => isValid && (exchangeLimit == null || exchangeCount < exchangeLimit!);
}