import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/managed_user_model.dart';

/// Abstract repository for Admin User Management.
/// All endpoints require admin (is_staff) authentication.
///
/// Base: /api/users/manage/
abstract class UserManageRepo {
  /// GET /api/users/manage/
  /// Returns paginated list of all users.
  Future<Either<Failure, List<ManagedUserModel>>> listUsers({
    String? search,
    bool? isActive,
    bool? isStaff,
  });

  /// POST /api/users/manage/
  /// Creates a new user account. Requires unique username & email.
  Future<Either<Failure, ManagedUserModel>> createUser(
      CreateUserPayload payload);

  /// GET /api/users/manage/{id}/
  /// Retrieves full details of a single user.
  Future<Either<Failure, ManagedUserModel>> getUserDetails(int userId);

  /// PUT /api/users/manage/{id}/
  /// Full replacement update of a user.
  Future<Either<Failure, ManagedUserModel>> updateUser({
    required int userId,
    required ManagedUserModel user,
    String? newPassword,
  });

  /// PATCH /api/users/manage/{id}/
  /// Partial update — only sends the provided fields.
  Future<Either<Failure, ManagedUserModel>> partialUpdateUser({
    required int userId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    String? password,
  });

  /// DELETE /api/users/manage/{id}/
  /// Permanently deletes a user account.
  Future<Either<Failure, void>> deleteUser(int userId);

  /// POST /api/users/{userId}/groups/
  /// Assign roles to user ("Admin", "Moderator", "Student").
  Future<Either<Failure, void>> assignUserGroups({
    required int userId,
    required List<String> groups,
  });
}

