class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String fullAddress;
  final String state;
  final String district;
  final String phone;
  final String verifiedOtp;
  final String? avatar;
  final String createdAt;
  final String updatedAt;
  final String otpVerified;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.fullAddress,
    required this.state,
    required this.district,
    required this.phone,
    required this.verifiedOtp,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    required this.otpVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at']?.toString(),
      fullAddress: json['full_address'] ?? '',
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      phone: json['phone'] ?? '',
      verifiedOtp: json['verified_otp']?.toString() ?? '0',
      avatar: json['avatar']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      otpVerified: json['otp_verified']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'full_address': fullAddress,
      'state': state,
      'district': district,
      'phone': phone,
      'verified_otp': verifiedOtp,
      'avatar': avatar,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'otp_verified': otpVerified,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? emailVerifiedAt,
    String? fullAddress,
    String? state,
    String? district,
    String? phone,
    String? verifiedOtp,
    String? avatar,
    String? createdAt,
    String? updatedAt,
    String? otpVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      fullAddress: fullAddress ?? this.fullAddress,
      state: state ?? this.state,
      district: district ?? this.district,
      phone: phone ?? this.phone,
      verifiedOtp: verifiedOtp ?? this.verifiedOtp,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      otpVerified: otpVerified ?? this.otpVerified,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, phone: $phone, state: $state, district: $district)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
