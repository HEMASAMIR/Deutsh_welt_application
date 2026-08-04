class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String adminStudents = '/admin-students';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String resetPasswordSent = '/reset-password-sent';
  static const String studentDashboard = '/student-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String courseContent = '/course-content';
  static const String instructorBio = '/instructor-bio';
  static const String privacy = '/privacy';
  static const String profile = '/profile';
  static const String book = '/book';
  static const String adminBookManage = '/admin-book-manage';

  // ── Courses / Levels ──────────────────────────────────────────────────────
  /// Arg: none — shows the 4 German levels list.
  static const String levels = '/levels';

  /// Arg: Map{'levelId': int, 'levelName': String}
  static const String levelVideos = '/level-videos';

  /// Arg: Map{'video': VideoModel, 'levelId': int}
  static const String videoPlayer = '/video-player';

  /// Arg: Map{'video': VideoModel, 'levelId': int}
  static const String videoComments = '/video-comments';

  // ── Admin ─────────────────────────────────────────────────────────────────
  /// Arg: none — admin-only levels management view.
  static const String adminLevels = '/admin-levels';

  /// Arg: Map{'levelId': int, 'levelName': String}
  static const String adminLevelUsers = '/admin-level-users';

  // ── User Management (Admin Only) ───────────────────────────────────
  /// Requires admin auth. Shows full user list with CRUD.
  static const String userManage = '/admin-user-manage';

  /// Admin Settings Route
  static const String adminAppSettings = '/admin-app-settings';
}

