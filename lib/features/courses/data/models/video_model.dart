import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String title;
  final int length; // in seconds
  final String? thumbnailUrl;
  final String embedUrl;
  final int order;

  const VideoModel({
    required this.id,
    required this.title,
    required this.length,
    this.thumbnailUrl,
    required this.embedUrl,
    required this.order,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      length: json['length'] ?? 0,
      thumbnailUrl: json['thumbnail_url'],
      embedUrl: json['embed_url'] ?? '',
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'length': length,
        'thumbnail_url': thumbnailUrl,
        'embed_url': embedUrl,
        'order': order,
      };

  /// Formats seconds → "MM:SS" (e.g. 720 → "12:00")
  String get formattedDuration {
    final minutes = length ~/ 60;
    final secs = length % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [id, title, length, thumbnailUrl, embedUrl, order];
}

// ─── Course File Model ────────────────────────────────────────────────────────
/// Represents a downloadable PDF/file attached to a course level.
/// Returned inside the `files` array from GET /api/courses/levels/{id}/videos/
class CourseFileModel extends Equatable {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  const CourseFileModel({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory CourseFileModel.fromJson(Map<String, dynamic> json) {
    return CourseFileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, isActive, createdAt];
}

// ─── Level Videos Response ────────────────────────────────────────────────────
class LevelVideosResponse extends Equatable {
  final Map<String, dynamic> level; // raw level data
  final List<VideoModel> videos;
  final List<CourseFileModel> files; // course attachments/PDFs

  const LevelVideosResponse({
    required this.level,
    required this.videos,
    this.files = const [],
  });

  factory LevelVideosResponse.fromJson(Map<String, dynamic> json) {
    return LevelVideosResponse(
      level: json['level'] ?? {},
      videos: (json['videos'] as List<dynamic>?)
              ?.map((v) => VideoModel.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      files: (json['files'] as List<dynamic>?)
              ?.map((f) => CourseFileModel.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [level, videos, files];
}

