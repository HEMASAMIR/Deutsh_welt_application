import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../models/user_model.dart';

abstract class AuthRepo {
  Future<Either<Failure, AuthResponseModel>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, AuthResponseModel>> refreshToken({
    required String refresh,
  });

  Future<Either<Failure, void>> logout({
    required String refresh,
  });

  Future<Either<Failure, UserModel>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  });

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Either<Failure, AuthResponseModel>> googleAuth({required String token});

  Future<Either<Failure, UserModel>> getCurrentUser();

  Future<Either<Failure, UserModel>> updateProfile({
    String? name,
    String? phone,
  });

  Future<bool> isLoggedIn();
}
