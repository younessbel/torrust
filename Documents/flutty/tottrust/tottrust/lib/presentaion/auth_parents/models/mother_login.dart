class Mother_Login {
  final String id;
  final String fullname;
  final String phoneNumber;
  final String email;
  final String? profilePictureUrl;

  Mother_Login({
    required this.id,
    required this.fullname,
    required this.phoneNumber,
    required this.email,
    this.profilePictureUrl,
  });

  factory Mother_Login.fromJson(Map<String, dynamic> json) {
    return Mother_Login(
      id: json['_id'] ?? '',
      fullname: json['fullname'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullname': fullname,
      'phone_number': phoneNumber,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }
}
