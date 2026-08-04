import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../models/comment_model.dart';
import '../models/level_model.dart';
import '../models/user_access_model.dart';
import '../models/video_model.dart';
import 'courses_repo.dart';

class CoursesRepoImpl implements CoursesRepo {
  final Dio _dio;

  CoursesRepoImpl({required Dio dio}) : _dio = dio;

  // ─── Get Levels ────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<LevelModel>>> getLevels() async {
    try {
      final response = await _dio.get('/api/courses/levels/');
      final levels = (response.data as List<dynamic>)
          .map((json) => LevelModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(levels);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Get Level Videos ──────────────────────────────────────────────────────
  @override
  Future<Either<Failure, LevelVideosResponse>> getLevelVideos(int levelId) async {
    try {
      final response = await _dio.get('/api/courses/levels/$levelId/videos/');
      final data = LevelVideosResponse.fromJson(
          response.data as Map<String, dynamic>);
      return Right(data);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Get Comments ──────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, PaginatedCommentsModel>> getComments({
    required int levelId,
    required String videoId,
    int page = 1,
  }) async {
    try {
      final response = await _dio.get(
        '/api/courses/levels/$levelId/videos/$videoId/comments/',
        queryParameters: {'page': page},
      );
      return Right(PaginatedCommentsModel.fromJson(
          response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Create Comment ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, CommentModel>> createComment({
    required int levelId,
    required String videoId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/api/courses/levels/$levelId/videos/$videoId/comments/',
        data: {'content': content},
      );
      return Right(
          CommentModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Reply to Comment ──────────────────────────────────────────────────────
  @override
  Future<Either<Failure, ReplyModel>> replyToComment({
    required int levelId,
    required String videoId,
    required int commentId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        '/api/courses/levels/$levelId/videos/$videoId/comments/$commentId/reply/',
        data: {'content': content},
      );
      return Right(
          ReplyModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Edit Comment ──────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> editComment({
    required int levelId,
    required String videoId,
    required int commentId,
    required String content,
  }) async {
    try {
      await _dio.put(
        '/api/courses/levels/$levelId/videos/$videoId/comments/$commentId/',
        data: {'content': content},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Delete Comment ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> deleteComment({
    required int levelId,
    required String videoId,
    required int commentId,
  }) async {
    try {
      await _dio.delete(
        '/api/courses/levels/$levelId/videos/$videoId/comments/$commentId/',
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Download Course File ──────────────────────────────────────────────────
  @override
  Future<Either<Failure, Response<List<int>>>> downloadCourseFile({
    required int levelId,
    required int fileId,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/courses/levels/$levelId/files/$fileId/download/',
        options: Options(responseType: ResponseType.bytes),
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}


// ─── Admin Repo Impl ──────────────────────────────────────────────────────────
class AdminCoursesRepoImpl implements AdminCoursesRepo {
  final Dio _dio;

  AdminCoursesRepoImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, List<AdminLevelModel>>> getAdminLevels() async {
    try {
      final response = await _dio.get('/api/courses/admin/levels/');
      final levels = (response.data as List<dynamic>)
          .map((json) =>
              AdminLevelModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(levels);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminLevelModel>> createLevel(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post('/api/courses/admin/levels/', data: data);
      return Right(AdminLevelModel.fromJson(
          response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminLevelModel>> updateLevel(
      int levelId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
          '/api/courses/admin/levels/$levelId/', data: data);
      return Right(AdminLevelModel.fromJson(
          response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLevel(int levelId) async {
    try {
      await _dio.delete('/api/courses/admin/levels/$levelId/');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserAccessModel>> grantAccess({
    required int levelId,
    required int userId,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/api/courses/admin/levels/$levelId/grant/',
        data: {
          'user_id': userId,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
      final access = UserAccessModel.fromJson(
          response.data['access'] as Map<String, dynamic>);
      return Right(access);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> revokeAccess({
    required int levelId,
    required int userId,
  }) async {
    try {
      await _dio.post(
        '/api/courses/admin/levels/$levelId/revoke/',
        data: {'user_id': userId},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserAccessModel>>> getLevelUsers(
      int levelId) async {
    try {
      final response =
          await _dio.get('/api/courses/admin/levels/$levelId/users/');
      final users = (response.data as List<dynamic>)
          .map((json) =>
              UserAccessModel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Right(users);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshVideoCache(int levelId) async {
    try {
      await _dio.post('/api/courses/admin/levels/$levelId/refresh-cache/');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
