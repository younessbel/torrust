class Contact {
  final String id;
  final String name;
  final String? imageUrl;
  final String? lastMessage;
  final String? lastMessageTime;
  final String? email;
  final String? phoneNumber;
  final String? bio;
  final String? prefLocation;
  final List<String>? favoriteBabysitters;
  final List<String>? savedBabysitters;
  final List<String>? preferredAgeGroups;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Contact({
    required this.id,
    required this.name,
    this.imageUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.email,
    this.phoneNumber,
    this.bio,
    this.prefLocation,
    this.favoriteBabysitters,
    this.savedBabysitters,
    this.preferredAgeGroups,
    this.createdAt,
    this.updatedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['fullname'] ?? json['name'] ?? 'Unknown Contact',
      imageUrl: json['profile_picture'] ?? json['imageUrl'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      prefLocation: json['pref_location'],
      favoriteBabysitters: json['favorite_babysitters'] != null 
          ? List<String>.from(json['favorite_babysitters'])
          : null,
      savedBabysitters: json['saved_babysitters'] != null 
          ? List<String>.from(json['saved_babysitters'])
          : null,
      preferredAgeGroups: json['preferred_age_groups'] != null 
          ? List<String>.from(json['preferred_age_groups'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Create contact from babysitter data (matches your API response format)
  factory Contact.fromBabysitter(Map<String, dynamic> json) {
    return Contact(
      id: json['_id']?.toString() ?? '',
      name: json['fullname'] ?? 'Unknown Babysitter',
      email: json['email'],
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      prefLocation: json['pref_location'],
      imageUrl: json['profile_picture'],
      lastMessage: 'Tap to start chatting',
      lastMessageTime: 'Available',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  // Create contact from mother data (matches your API response format)
  factory Contact.fromMother(Map<String, dynamic> json) {
    return Contact(
      id: json['_id']?.toString() ?? '',
      name: json['fullname'] ?? 'Unknown Mother',
      email: json['email'],
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      prefLocation: json['pref_location'],
      imageUrl: json['profile_picture'],
      favoriteBabysitters: json['favorite_babysitters'] != null 
          ? List<String>.from(json['favorite_babysitters'])
          : null,
      savedBabysitters: json['saved_babysitters'] != null 
          ? List<String>.from(json['saved_babysitters'])
          : null,
      preferredAgeGroups: json['preferred_age_groups'] != null 
          ? List<String>.from(json['preferred_age_groups'])
          : null,
      lastMessage: 'Tap to start chatting',
      lastMessageTime: 'Available',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullname': name,
      'email': email,
      'phone_number': phoneNumber,
      'bio': bio,
      'pref_location': prefLocation,
      'profile_picture': imageUrl,
      'favorite_babysitters': favoriteBabysitters,
      'saved_babysitters': savedBabysitters,
      'preferred_age_groups': preferredAgeGroups,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, email: $email, phone: $phoneNumber}';
  }
}
