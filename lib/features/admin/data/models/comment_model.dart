class CommentModel {
  final String id;
  final String videoId;
  final String userName;
  final String userAvatar;
  final String courseTitle;
  final String commentText;
  final DateTime createdAt;
  final bool isApproved;

  const CommentModel({
    required this.id,
    this.videoId = '',
    required this.userName,
    this.userAvatar = '',
    required this.courseTitle,
    required this.commentText,
    required this.createdAt,
    required this.isApproved,
  });

  CommentModel copyWith({
    String? id,
    String? videoId,
    String? userName,
    String? userAvatar,
    String? courseTitle,
    String? commentText,
    DateTime? createdAt,
    bool? isApproved,
  }) {
    return CommentModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      courseTitle: courseTitle ?? this.courseTitle,
      commentText: commentText ?? this.commentText,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      videoId: json['video_id'] ?? json['videoId'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? 'طالب',
      userAvatar: json['user_avatar'] ?? json['userAvatar'] ?? '',
      courseTitle: json['course_title'] ?? json['courseTitle'] ?? '',
      commentText: json['comment_text'] ?? json['commentText'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isApproved: json['is_approved'] ?? json['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'video_id': videoId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'course_title': courseTitle,
      'comment_text': commentText,
      'created_at': createdAt.toIso8601String(),
      'is_approved': isApproved,
    };
  }
}
