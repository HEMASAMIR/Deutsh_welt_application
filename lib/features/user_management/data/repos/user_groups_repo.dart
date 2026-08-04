import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';

// ─── User Groups Repository ───────────────────────────────────────────────────

abstract class UserGroupsRepo {
  /// POST /api/users/{userId}/groups/
  /// Available groups: "Admin", "Moderator", "Student"
  /// Requires can_manage_groups_and_perms permission.
  Future<Either<Failure, void>> assignGroups({
    required int userId,
    required List<String> groups,
  });
}

// ─── Implementation ───────────────────────────────────────────────────────────

class UserGroupsRepoImpl implements UserGroupsRepo {
  final Dio _dio;

  UserGroupsRepoImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, void>> assignGroups({
    required int userId,
    required List<String> groups,
  }) async {
    try {
      await _dio.post(
        '/api/users/$userId/groups/',
        data: {'groups': groups},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
