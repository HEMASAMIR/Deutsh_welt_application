import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/level_model.dart';
import '../models/video_model.dart';
import '../models/comment_model.dart';
import '../models/user_access_model.dart';
import 'package:dio/dio.dart';

abstract class CoursesRepo {
  // ── Student Endpoints ──────────────────────────────────────────────────────

  /// Fetches all 4 German levels with access info for the current user.
  Future<Either<Failure, List<LevelModel>>> getLevels();

  /// Fetches all videos for a given level. Returns 403 if no access.
  Future<Either<Failure, LevelVideosResponse>> getLevelVideos(int levelId);

  // ── Comments ───────────────────────────────────────────────────────────────

  /// Lists paginated comments for a video (20 per page).
  Future<Either<Failure, PaginatedCommentsModel>> getComments({
    required int levelId,
    required String videoId,
    int page = 1,
  });

  /// Posts a new top-level comment.
  Future<Either<Failure, CommentModel>> createComment({
    required int levelId,
    required String videoId,
    required String content,
  });

  /// Replies to an existing comment. Returns 400 if replying to a reply.
  Future<Either<Failure, ReplyModel>> replyToComment({
    required int levelId,
    required String videoId,
    required int commentId,
    required String content,
  });

  /// Edits a comment (only within 15 min of posting).
  Future<Either<Failure, void>> editComment({
    required int levelId,
    required String videoId,
    required int commentId,
    required String content,
  });

  /// Soft-deletes a comment (owner) or any comment (admin).
  Future<Either<Failure, void>> deleteComment({
    required int levelId,
    required String videoId,
    required int commentId,
  });

  /// Downloads a course-level attached file (PDF).
  /// Returns a Dio [Response] with responseType = bytes.
  Future<Either<Failure, Response<List<int>>>> downloadCourseFile({
    required int levelId,
    required int fileId,
  });
}

// ─── Admin-Only Repository ────────────────────────────────────────────────────
abstract class AdminCoursesRepo {
  /// Lists all levels with admin details (bunny id, access counts, etc.).
  Future<Either<Failure, List<AdminLevelModel>>> getAdminLevels();

  /// Creates a new level.
  Future<Either<Failure, AdminLevelModel>> createLevel(
      Map<String, dynamic> data);

  /// Updates an existing level (full PUT).
  Future<Either<Failure, AdminLevelModel>> updateLevel(
      int levelId, Map<String, dynamic> data);

  /// Deletes a level permanently.
  Future<Either<Failure, void>> deleteLevel(int levelId);

  /// Grants a user access to a level.
  Future<Either<Failure, UserAccessModel>> grantAccess({
    required int levelId,
    required int userId,
    String? notes,
  });

  /// Revokes a user's access to a level.
  Future<Either<Failure, void>> revokeAccess({
    required int levelId,
    required int userId,
  });

  /// Lists all users who have access to a level.
  Future<Either<Failure, List<UserAccessModel>>> getLevelUsers(int levelId);

  /// Forces a cache refresh for a level's video list.
  Future<Either<Failure, void>> refreshVideoCache(int levelId);
}
