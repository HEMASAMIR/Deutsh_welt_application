import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../models/managed_user_model.dart';
import 'user_manage_repo.dart';

class UserManageRepoImpl implements UserManageRepo {
  final Dio _dio;

  UserManageRepoImpl({required Dio dio}) : _dio = dio;

  // ─── List Users ─────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<ManagedUserModel>>> listUsers({
    String? search,
    bool? isActive,
    bool? isStaff,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (search != null && search.isNotEmpty) 'search': search,
        if (isActive != null) 'is_active': isActive,
        if (isStaff != null) 'is_staff': isStaff,
      };

      final response = await _dio.get(
        '/api/users/manage/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;

      // Handle both paginated { results: [...] } and plain list responses
      final List<dynamic> rawList;
      if (data is Map && data.containsKey('results')) {
        rawList = data['results'] as List<dynamic>;
      } else if (data is List) {
        rawList = data;
      } else {
        rawList = [];
      }

      final users = rawList
          .map((json) =>
              ManagedUserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(users);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Create User ────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, ManagedUserModel>> createUser(
      CreateUserPayload payload) async {
    try {
      final response = await _dio.post(
        '/api/users/manage/',
        data: payload.toJson(),
      );
      return Right(
          ManagedUserModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Get User Details ────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, ManagedUserModel>> getUserDetails(int userId) async {
    try {
      final response = await _dio.get('/api/users/manage/$userId/');
      return Right(
          ManagedUserModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Update User (PUT) ───────────────────────────────────────────────────────
  @override
  Future<Either<Failure, ManagedUserModel>> updateUser({
    required int userId,
    required ManagedUserModel user,
    String? newPassword,
  }) async {
    try {
      final body = user.toJson();
      if (newPassword != null && newPassword.isNotEmpty) {
        body['password'] = newPassword;
      }

      final response = await _dio.put(
        '/api/users/manage/$userId/',
        data: body,
      );
      return Right(
          ManagedUserModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Partial Update User (PATCH) ─────────────────────────────────────────────
  @override
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
  }) async {
    try {
      // Build a dummy model to use the toPartialJson helper
      final body = ManagedUserModel(
        id: userId,
        username: '',
        email: '',
        firstName: '',
        lastName: '',
        isActive: true,
        isStaff: false,
        isSuperuser: false,
      ).toPartialJson(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        isActive: isActive,
        isStaff: isStaff,
        isSuperuser: isSuperuser,
        password: password,
      );

      final response = await _dio.patch(
        '/api/users/manage/$userId/',
        data: body,
      );
      return Right(
          ManagedUserModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Delete User ─────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> deleteUser(int userId) async {
    try {
      await _dio.delete('/api/users/manage/$userId/');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ─── Assign Groups (Roles) ───────────────────────────────────────────────────
  @override
  Future<Either<Failure, void>> assignUserGroups({
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

