class Mother {
  final String id;
  final String fullname;
  final String phoneNumber;
  final String email;
  final String? profilePhotoUrl;
  final bool isVerified;

  Mother({
    required this.id,
    required this.fullname,
    required this.phoneNumber,
    required this.email,
    this.profilePhotoUrl,
    this.isVerified = false,
  });

  factory Mother.fromJson(Map<String, dynamic> json) {
    return Mother(
      id: json['_id'] ?? '',
      fullname: json['fullname'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      profilePhotoUrl: json['profilePhoto'],
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullname': fullname,
      'phone_number': phoneNumber,
      'email': email,
      'profilePhoto': profilePhotoUrl,
      'isVerified': isVerified,
    };
  }
}
