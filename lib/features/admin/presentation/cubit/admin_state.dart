import '../../data/models/student_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/video_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/book_model.dart';

abstract class AdminState {
  const AdminState();
}

class AdminInitialState extends AdminState {}

class AdminLoadingState extends AdminState {}

class AdminLoadedState extends AdminState {
  final List<StudentModel> students;
  final List<CourseModel> courses;
  final List<VideoModel> videos;
  final List<CommentModel> comments;
  final List<BookModel> books;
  final String searchQuery;
  final String filterCourse;

  const AdminLoadedState({
    required this.students,
    required this.courses,
    required this.videos,
    required this.comments,
    this.books = const [],
    this.searchQuery = '',
    this.filterCourse = 'الكل',
  });

  AdminLoadedState copyWith({
    List<StudentModel>? students,
    List<CourseModel>? courses,
    List<VideoModel>? videos,
    List<CommentModel>? comments,
    List<BookModel>? books,
    String? searchQuery,
    String? filterCourse,
  }) {
    return AdminLoadedState(
      students: students ?? this.students,
      courses: courses ?? this.courses,
      videos: videos ?? this.videos,
      comments: comments ?? this.comments,
      books: books ?? this.books,
      searchQuery: searchQuery ?? this.searchQuery,
      filterCourse: filterCourse ?? this.filterCourse,
    );
  }

  // Helper getters for course counts
  Map<String, int> get courseRegistrationCounts {
    final Map<String, int> counts = {};
    for (var course in courses) {
      counts[course.title] = 0;
    }
    for (var student in students) {
      if (student.courseLevel.isNotEmpty) {
        counts[student.courseLevel] = (counts[student.courseLevel] ?? 0) + 1;
      }
    }
    return counts;
  }

  int get totalRegisteredUsers => students.length;
}

class AdminErrorState extends AdminState {
  final String message;
  const AdminErrorState(this.message);
}
