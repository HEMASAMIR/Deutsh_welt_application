import 'package:equatable/equatable.dart';

// ─── Student-Facing Book Model ─────────────────────────────────────────────────
/// Returned by GET /api/books/ (grouped by level)
class BookApiModel extends Equatable {
  final int id;
  final String name;
  final String level; // e.g. "A1", "A2", "B1", "B2"
  final String price;
  final bool isActive;
  final bool hasAccess; // true → show download button; false → show purchase flow

  const BookApiModel({
    required this.id,
    required this.name,
    required this.level,
    required this.price,
    required this.isActive,
    required this.hasAccess,
  });

  factory BookApiModel.fromJson(Map<String, dynamic> json) {
    return BookApiModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      isActive: json['is_active'] ?? true,
      hasAccess: json['has_access'] ?? false,
    );
  }

  /// Formatted price string — e.g. "200 جنيه"
  String get formattedPrice {
    final val = double.tryParse(price);
    if (val == null) return price;
    return '${val.toStringAsFixed(0)} جنيه';
  }

  @override
  List<Object?> get props => [id, name, level, price, isActive, hasAccess];
}

// ─── Admin Book Model ─────────────────────────────────────────────────────────
/// Returned by GET /api/books/admin/ (flat list, includes all books even inactive)
class AdminBookApiModel extends BookApiModel {
  const AdminBookApiModel({
    required super.id,
    required super.name,
    required super.level,
    required super.price,
    required super.isActive,
    required super.hasAccess,
  });

  factory AdminBookApiModel.fromJson(Map<String, dynamic> json) {
    return AdminBookApiModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      isActive: json['is_active'] ?? true,
      hasAccess: json['has_access'] ?? false,
    );
  }

  @override
  List<Object?> get props => [...super.props];
}

// ─── Book User Access Model ───────────────────────────────────────────────────
/// Returned by GET /api/books/admin/{id}/users/
class BookUserAccess extends Equatable {
  final int id;
  final int userId;
  final String userEmail;
  final String userFirstName;
  final String userLastName;
  final int bookId;
  final String bookName;
  final DateTime grantedAt;
  final bool isActive;

  const BookUserAccess({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userFirstName,
    required this.userLastName,
    required this.bookId,
    required this.bookName,
    required this.grantedAt,
    required this.isActive,
  });

  factory BookUserAccess.fromJson(Map<String, dynamic> json) {
    return BookUserAccess(
      id: json['id'] ?? 0,
      userId: json['user'] ?? 0,
      userEmail: json['user_email'] ?? '',
      userFirstName: json['user_first_name'] ?? '',
      userLastName: json['user_last_name'] ?? '',
      bookId: json['book'] ?? 0,
      bookName: json['book_name'] ?? '',
      grantedAt:
          DateTime.tryParse(json['granted_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  String get displayName => '$userFirstName $userLastName'.trim();

  @override
  List<Object?> get props =>
      [id, userId, userEmail, userFirstName, userLastName, bookId, bookName, grantedAt, isActive];
}
