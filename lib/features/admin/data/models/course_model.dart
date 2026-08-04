class CourseModel {
  final String id;
  final String title;
  final String level; // e.g. A1, A2, B1, B2
  final String description;
  final double price;
  final int enrolledCount;
  final bool isActive;

  const CourseModel({
    required this.id,
    required this.title,
    required this.level,
    required this.description,
    required this.price,
    required this.enrolledCount,
    this.isActive = true,
  });

  CourseModel copyWith({
    String? id,
    String? title,
    String? level,
    String? description,
    double? price,
    int? enrolledCount,
    bool? isActive,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
      description: description ?? this.description,
      price: price ?? this.price,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      isActive: isActive ?? this.isActive,
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      level: json['level'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      enrolledCount: json['enrolled_count'] ?? json['enrolledCount'] ?? 0,
      isActive: json['is_active'] ?? json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'level': level,
      'description': description,
      'price': price,
      'enrolled_count': enrolledCount,
      'is_active': isActive,
    };
  }
}
