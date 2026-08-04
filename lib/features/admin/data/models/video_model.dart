class VideoModel {
  final String id;
  final String courseId;
  final String courseTitle;
  final String title;
  final String videoUrl;
  final String duration;
  final int lessonNumber;
  final bool isLocked;

  const VideoModel({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.title,
    required this.videoUrl,
    required this.duration,
    required this.lessonNumber,
    this.isLocked = false,
  });

  VideoModel copyWith({
    String? id,
    String? courseId,
    String? courseTitle,
    String? title,
    String? videoUrl,
    String? duration,
    int? lessonNumber,
    bool? isLocked,
  }) {
    return VideoModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseTitle: courseTitle ?? this.courseTitle,
      title: title ?? this.title,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      lessonNumber: lessonNumber ?? this.lessonNumber,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id'] ?? json['courseId'] ?? '',
      courseTitle: json['course_title'] ?? json['courseTitle'] ?? '',
      title: json['title'] ?? '',
      videoUrl: json['video_url'] ?? json['videoUrl'] ?? '',
      duration: json['duration'] ?? '',
      lessonNumber: json['lesson_number'] ?? json['lessonNumber'] ?? 1,
      isLocked: json['is_locked'] ?? json['isLocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'course_title': courseTitle,
      'title': title,
      'video_url': videoUrl,
      'duration': duration,
      'lesson_number': lessonNumber,
      'is_locked': isLocked,
    };
  }
}
