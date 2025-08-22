class BusinessProfile {
  final int id;
  final int userId;
  final String businessId;
  final String businessName;
  final String gstNo;
  final String phoneNoFirst;
  final String phoneNoSecond;
  final String email;
  final String businessEmail;
  final String businessAddress;
  final String pincode;
  final String businessDesc;
  final String? digitalSign;
  final String businessState;
  final String businessCategory;
  final String website;
  final String? businessSignature;
  final String createdAt;
  final String updatedAt;
  final String businessType;

  BusinessProfile({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.businessName,
    required this.gstNo,
    required this.phoneNoFirst,
    required this.phoneNoSecond,
    required this.email,
    required this.businessEmail,
    required this.businessAddress,
    required this.pincode,
    required this.businessDesc,
    this.digitalSign,
    required this.businessState,
    required this.businessCategory,
    required this.website,
    this.businessSignature,
    required this.createdAt,
    required this.updatedAt,
    required this.businessType,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      businessId: json['business_id'] ?? '',
      businessName: json['business_name'] ?? '',
      gstNo: json['gst_no'] ?? '',
      phoneNoFirst: json['phone_no_first'] ?? '',
      phoneNoSecond: json['phone_no_second'] ?? '',
      email: json['email'] ?? '',
      businessEmail: json['business_email'] ?? '',
      businessAddress: json['business_address'] ?? '',
      pincode: json['pincode'] ?? '',
      businessDesc: json['business_desc'] ?? '',
      digitalSign: json['digital_sign'],
      businessState: json['business_state'] ?? '',
      businessCategory: json['business_category'] ?? '',
      website: json['website'] ?? '',
      businessSignature: json['business_signature'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      businessType: json['business_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_id': businessId,
      'business_name': businessName,
      'gst_no': gstNo,
      'phone_no_first': phoneNoFirst,
      'phone_no_second': phoneNoSecond,
      'email': email,
      'business_email': businessEmail,
      'business_address': businessAddress,
      'pincode': pincode,
      'business_desc': businessDesc,
      'digital_sign': digitalSign,
      'business_state': businessState,
      'business_category': businessCategory,
      'website': website,
      'business_signature': businessSignature,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'business_type': businessType,
    };
  }
}
