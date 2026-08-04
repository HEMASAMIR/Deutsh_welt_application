import 'package:equatable/equatable.dart';

class UserAccessModel extends Equatable {
  final int id;
  final int user;
  final String userEmail;
  final String userFirstName;
  final String userLastName;
  final int level;
  final String levelName;
  final DateTime grantedAt;
  final String grantedByEmail;
  final bool isActive;
  final String? notes;

  const UserAccessModel({
    required this.id,
    required this.user,
    required this.userEmail,
    required this.userFirstName,
    required this.userLastName,
    required this.level,
    required this.levelName,
    required this.grantedAt,
    required this.grantedByEmail,
    required this.isActive,
    this.notes,
  });

  factory UserAccessModel.fromJson(Map<String, dynamic> json) {
    return UserAccessModel(
      id: json['id'] ?? 0,
      user: json['user'] ?? 0,
      userEmail: json['user_email'] ?? '',
      userFirstName: json['user_first_name'] ?? '',
      userLastName: json['user_last_name'] ?? '',
      level: json['level'] ?? 0,
      levelName: json['level_name'] ?? '',
      grantedAt:
          DateTime.tryParse(json['granted_at'] ?? '') ?? DateTime.now(),
      grantedByEmail: json['granted_by_email'] ?? '',
      isActive: json['is_active'] ?? true,
      notes: json['notes'],
    );
  }

  String get userFullName => '$userFirstName $userLastName'.trim();

  @override
  List<Object?> get props => [
        id,
        user,
        userEmail,
        userFirstName,
        userLastName,
        level,
        levelName,
        grantedAt,
        grantedByEmail,
        isActive,
        notes,
      ];
}
