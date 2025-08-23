class Subscription {
  final int id;
  final String planName;
  final String planPrice;
  final String planValidity;
  final String userAddCount;
  final String businessAddCount;
  final String invoiceAddCount;
  final String planStatus;
  final String createdAt;
  final String updatedAt;
  final String planDescription;

  Subscription({
    required this.id,
    required this.planName,
    required this.planPrice,
    required this.planValidity,
    required this.userAddCount,
    required this.businessAddCount,
    required this.invoiceAddCount,
    required this.planStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.planDescription,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      planName: json['plan_name'] ?? '',
      planPrice: json['plan_price'] ?? '0.00',
      planValidity: json['plan_validity'] ?? '30',
      userAddCount: json['user_add_count'] ?? '1',
      businessAddCount: json['business_add_count'] ?? '1',
      invoiceAddCount: json['invoice_add_count'] ?? '100',
      planStatus: json['plan_status'] ?? 'inactive',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      planDescription: json['plan_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'plan_price': planPrice,
      'plan_validity': planValidity,
      'user_add_count': userAddCount,
      'business_add_count': businessAddCount,
      'invoice_add_count': invoiceAddCount,
      'plan_status': planStatus,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'plan_description': planDescription,
    };
  }

  // Helper methods
  double get priceAsDouble => double.tryParse(planPrice) ?? 0.0;
  int get validityAsInt => int.tryParse(planValidity) ?? 30;
  bool get isActive => planStatus == 'active';
  bool get isUnlimited => planValidity.toLowerCase() == 'unlimited';
}
