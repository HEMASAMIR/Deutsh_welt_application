class StudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String courseLevel; // e.g. "A1 - المبتدئين"
  final DateTime joinedDate;
  final bool isActive;

  const StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.courseLevel,
    required this.joinedDate,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName'.trim();

  StudentModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? courseLevel,
    DateTime? joinedDate,
    bool? isActive,
  }) {
    return StudentModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      courseLevel: courseLevel ?? this.courseLevel,
      joinedDate: joinedDate ?? this.joinedDate,
      isActive: isActive ?? this.isActive,
    );
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      courseLevel: json['course_level'] ?? json['courseLevel'] ?? 'A1 - المبتدئين',
      joinedDate: json['joined_date'] != null
          ? DateTime.parse(json['joined_date'])
          : DateTime.now(),
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phone,
      'course_level': courseLevel,
      'joined_date': joinedDate.toIso8601String(),
      'is_active': isActive,
    };
  }
}
