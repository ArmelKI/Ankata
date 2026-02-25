class User {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;
  final String? cnib;
  final String? gender;
  final String? profilePictureUrl;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.cnib,
    this.gender,
    this.profilePictureUrl,
    required this.isVerified,
    required this.createdAt,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      cnib: json['cnib'] as String?,
      gender: json['gender'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isVerified: json['isVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'cnib': cnib,
      'gender': gender,
      'profilePictureUrl': profilePictureUrl,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? cnib,
    String? gender,
    String? profilePictureUrl,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      cnib: cnib ?? this.cnib,
      gender: gender ?? this.gender,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
