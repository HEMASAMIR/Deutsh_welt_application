class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final bool isActive;
  final bool isStaff;
  final String? profilePhoto;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.isActive,
    required this.isStaff,
    this.profilePhoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'],
      isActive: json['is_active'] ?? false,
      isStaff: json['is_staff'] ?? false,
      profilePhoto: json['profile_photo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'is_staff': isStaff,
      'profile_photo': profilePhoto,
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}

class AuthResponseModel {
  final String access;
  final String refresh;
  final UserModel user;

  const AuthResponseModel({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      access: json['access'] ?? '',
      refresh: json['refresh'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
      'user': user.toJson(),
    };
  }
}
