import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../models/book_api_model.dart';
import 'books_repo.dart';

// ─── Student Books Repo Impl ──────────────────────────────────────────────────
class BooksRepoImpl implements BooksRepo {
  final Dio _dio;

  BooksRepoImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, Map<String, List<BookApiModel>>>> getBooks() async {
    try {
      final response = await _dio.get('/api/books/');
      final data = response.data as Map<String, dynamic>;

      final grouped = <String, List<BookApiModel>>{};
      data.forEach((level, books) {
        if (books is List) {
          grouped[level] = books
              .map((b) => BookApiModel.fromJson(b as Map<String, dynamic>))
              .toList();
        }
      });

      return Right(grouped);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Response<List<int>>>> downloadBook(int bookId) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/books/$bookId/download/',
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

// ─── Admin Books Repo Impl ────────────────────────────────────────────────────
class AdminBooksRepoImpl implements AdminBooksRepo {
  final Dio _dio;

  AdminBooksRepoImpl({required Dio dio}) : _dio = dio;

  @override
  Future<Either<Failure, List<AdminBookApiModel>>> getAllBooks() async {
    try {
      final response = await _dio.get('/api/books/admin/');
      final list = (response.data as List<dynamic>)
          .map((b) => AdminBookApiModel.fromJson(b as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminBookApiModel>> createBook(
      FormData formData) async {
    try {
      final response = await _dio.post(
        '/api/books/admin/',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return Right(
          AdminBookApiModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminBookApiModel>> editBook(
      int bookId, FormData formData) async {
    try {
      final response = await _dio.patch(
        '/api/books/admin/$bookId/',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      return Right(
          AdminBookApiModel.fromJson(response.data as Map<String, dynamic>));
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(int bookId) async {
    try {
      await _dio.delete('/api/books/admin/$bookId/');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookUserAccess>>> getBookUsers(
      int bookId) async {
    try {
      final response = await _dio.get('/api/books/admin/$bookId/users/');
      final list = (response.data as List<dynamic>)
          .map((u) => BookUserAccess.fromJson(u as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> grantBookAccess(
      {required int bookId, required int userId}) async {
    try {
      await _dio.post(
        '/api/books/admin/$bookId/grant/',
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
  Future<Either<Failure, void>> revokeBookAccess(
      {required int bookId, required int userId}) async {
    try {
      await _dio.post(
        '/api/books/admin/$bookId/revoke/',
        data: {'user_id': userId},
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handle(e));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
