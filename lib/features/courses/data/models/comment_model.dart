import 'package:equatable/equatable.dart';

// ─── Comment User ─────────────────────────────────────────────────────────────
class CommentUserModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName; // Already truncated by API (e.g. "M.")
  final String? profilePhoto;

  const CommentUserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePhoto,
  });

  factory CommentUserModel.fromJson(Map<String, dynamic> json) {
    return CommentUserModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      profilePhoto: json['profile_photo'],
    );
  }

  String get displayName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, firstName, lastName, profilePhoto];
}

// ─── Reply Model ──────────────────────────────────────────────────────────────
class ReplyModel extends Equatable {
  final int id;
  final CommentUserModel user;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOwner;

  const ReplyModel({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isOwner,
  });

  factory ReplyModel.fromJson(Map<String, dynamic> json) {
    return ReplyModel(
      id: json['id'] ?? 0,
      user: CommentUserModel.fromJson(json['user'] ?? {}),
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isOwner: json['is_owner'] ?? false,
    );
  }

  @override
  List<Object?> get props => [id, user, content, createdAt, updatedAt, isOwner];
}

// ─── Comment Model ────────────────────────────────────────────────────────────
class CommentModel extends Equatable {
  final int id;
  final CommentUserModel user;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOwner;
  final int replyCount;
  final List<ReplyModel> replies;

  const CommentModel({
    required this.id,
    required this.user,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.isOwner,
    required this.replyCount,
    required this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      user: CommentUserModel.fromJson(json['user'] ?? {}),
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
      isOwner: json['is_owner'] ?? false,
      replyCount: json['reply_count'] ?? 0,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((r) => ReplyModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Returns true if this comment is deleted (soft-delete sentinel value)
  bool get isDeleted => content == 'This comment was removed.';

  /// Returns true if the comment is still within the 15-minute edit window
  bool get isEditable {
    final deadline = createdAt.add(const Duration(minutes: 15));
    return DateTime.now().isBefore(deadline);
  }

  /// Remaining editable seconds (0 if expired)
  int get remainingEditSeconds {
    final deadline = createdAt.add(const Duration(minutes: 15));
    final remaining = deadline.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  CommentModel copyWith({
    int? id,
    CommentUserModel? user,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isOwner,
    int? replyCount,
    List<ReplyModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      user: user ?? this.user,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOwner: isOwner ?? this.isOwner,
      replyCount: replyCount ?? this.replyCount,
      replies: replies ?? this.replies,
    );
  }

  @override
  List<Object?> get props =>
      [id, user, content, createdAt, updatedAt, isOwner, replyCount, replies];
}

// ─── Paginated Comments Response ──────────────────────────────────────────────
class PaginatedCommentsModel extends Equatable {
  final int count;
  final String? next;
  final String? previous;
  final List<CommentModel> results;

  const PaginatedCommentsModel({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedCommentsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedCommentsModel(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
              ?.map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  bool get hasNextPage => next != null;

  @override
  List<Object?> get props => [count, next, previous, results];
}
