class Customer {
  final int? id;
  final String customerName;
  final String companyName;
  final String email;
  final String phone;
  final String gst;
  final String gstTreatment;
  final String placeOfSupply;
  final String state;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Customer({
    this.id,
    required this.customerName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.gst,
    required this.gstTreatment,
    required this.placeOfSupply,
    required this.state,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      customerName: json['customer_name'] ?? '',
      companyName: json['company_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gst: json['gst'] ?? '',
      gstTreatment: json['gst_treatment'] ?? '',
      placeOfSupply: json['place_of_supply'] ?? '',
      state: json['state'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'company_name': companyName,
      'email': email,
      'phone': phone,
      'gst': gst,
      'gst_treatment': gstTreatment,
      'place_of_supply': placeOfSupply,
      'state': state,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Customer copyWith({
    int? id,
    String? customerName,
    String? companyName,
    String? email,
    String? phone,
    String? gst,
    String? gstTreatment,
    String? placeOfSupply,
    String? state,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gst: gst ?? this.gst,
      gstTreatment: gstTreatment ?? this.gstTreatment,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      state: state ?? this.state,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
