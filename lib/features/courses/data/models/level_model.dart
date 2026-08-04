import 'package:equatable/equatable.dart';

class LevelModel extends Equatable {
  final int id;
  final String name;
  final String title;
  final String description;
  final String? price;
  final String? oldPrice;
  final int order;
  final bool hasAccess;

  const LevelModel({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    this.price,
    this.oldPrice,
    required this.order,
    required this.hasAccess,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString(),
      oldPrice: json['old_price']?.toString(),
      order: json['order'] ?? 0,
      hasAccess: json['has_access'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'title': title,
        'description': description,
        'price': price,
        'old_price': oldPrice,
        'order': order,
        'has_access': hasAccess,
      };

  /// Helper: e.g. "500.00" → "500 EGP"
  String get formattedPrice {
    if (price == null) return '';
    final val = double.tryParse(price!);
    if (val == null) return '';
    return '${val.toStringAsFixed(0)} جنيه';
  }

  String get formattedOldPrice {
    if (oldPrice == null) return '';
    final val = double.tryParse(oldPrice!);
    if (val == null) return '';
    return '${val.toStringAsFixed(0)} جنيه';
  }

  @override
  List<Object?> get props => [id, name, title, description, price, oldPrice, order, hasAccess];
}

// ─── Admin Level Model ────────────────────────────────────────────────────────
class AdminLevelModel extends LevelModel {
  final String? bunnyCollectionId;
  final bool isActive;
  final int accessCount;

  const AdminLevelModel({
    required super.id,
    required super.name,
    required super.title,
    required super.description,
    super.price,
    super.oldPrice,
    required super.order,
    required super.hasAccess,
    this.bunnyCollectionId,
    required this.isActive,
    required this.accessCount,
  });

  factory AdminLevelModel.fromJson(Map<String, dynamic> json) {
    return AdminLevelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString(),
      oldPrice: json['old_price']?.toString(),
      order: json['order'] ?? 0,
      hasAccess: json['has_access'] ?? true,
      bunnyCollectionId: json['bunny_collection_id'],
      isActive: json['is_active'] ?? true,
      accessCount: json['access_count'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [...super.props, bunnyCollectionId, isActive, accessCount];
}
