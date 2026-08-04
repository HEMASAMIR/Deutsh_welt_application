/// Model representing a user returned from the Admin User Management API.
/// Endpoint: GET/POST /api/users/manage/ and GET/PUT/PATCH/DELETE /api/users/manage/{id}/
class ManagedUserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final DateTime? dateJoined;
  final DateTime? lastLogin;

  const ManagedUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
    this.dateJoined,
    this.lastLogin,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? username : name;
  }

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    if (firstName.isNotEmpty) return firstName[0].toUpperCase();
    if (username.isNotEmpty) return username[0].toUpperCase();
    return '?';
  }

  String get roleLabel {
    if (isSuperuser) return 'مدير عام';
    if (isStaff) return 'مشرف';
    return 'طالب';
  }

  factory ManagedUserModel.fromJson(Map<String, dynamic> json) {
    return ManagedUserModel(
      id: json['id'] as int? ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
      isStaff: json['is_staff'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      dateJoined: json['date_joined'] != null
          ? DateTime.tryParse(json['date_joined'].toString())
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
    };
  }

  /// Used for PATCH (partial update) — only sends non-null fields.
  Map<String, dynamic> toPartialJson({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    String? password,
  }) {
    return {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (isActive != null) 'is_active': isActive,
      if (isStaff != null) 'is_staff': isStaff,
      if (isSuperuser != null) 'is_superuser': isSuperuser,
      if (password != null && password.isNotEmpty) 'password': password,
    };
  }

  ManagedUserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    DateTime? dateJoined,
    DateTime? lastLogin,
  }) {
    return ManagedUserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      isStaff: isStaff ?? this.isStaff,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedUserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Payload for creating a new user via POST /api/users/manage/
class CreateUserPayload {
  final String username;
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;

  const CreateUserPayload({
    required this.username,
    required this.email,
    required this.password,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber,
    this.isActive = true,
    this.isStaff = false,
    this.isSuperuser = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      if (phoneNumber != null && phoneNumber!.isNotEmpty)
        'phone_number': phoneNumber,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
    };
  }
}
