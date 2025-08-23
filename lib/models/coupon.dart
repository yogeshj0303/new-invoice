class Coupon {
  final int id;
  final String couponCode;
  final String discount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Coupon({
    required this.id,
    required this.couponCode,
    required this.discount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] ?? 0,
      couponCode: json['coupon_code'] ?? '',
      discount: json['discount'] ?? '0.00',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupon_code': couponCode,
      'discount': discount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Get discount as double
  double get discountAsDouble {
    try {
      return double.parse(discount);
    } catch (e) {
      return 0.0;
    }
  }

  // Get discount percentage
  double get discountPercentage {
    try {
      return double.parse(discount);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  String toString() {
    return 'Coupon(id: $id, couponCode: $couponCode, discount: $discount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
