import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../models/book_api_model.dart';

// ─── Student Books Repository ─────────────────────────────────────────────────
abstract class BooksRepo {
  /// GET /api/books/
  /// Returns books grouped by level: { "A1": [...], "A2": [...] }
  Future<Either<Failure, Map<String, List<BookApiModel>>>> getBooks();

  /// GET /api/books/{id}/download/
  /// Returns a Dio [Response] with bytes (PDF stream).
  /// Only succeeds if user has access (has_access: true).
  Future<Either<Failure, Response<List<int>>>> downloadBook(int bookId);
}

// ─── Admin Books Repository ───────────────────────────────────────────────────
abstract class AdminBooksRepo {
  /// GET /api/books/admin/ — flat list, includes inactive books
  Future<Either<Failure, List<AdminBookApiModel>>> getAllBooks();

  /// POST /api/books/admin/ — multipart/form-data with file upload
  Future<Either<Failure, AdminBookApiModel>> createBook(FormData formData);

  /// PATCH /api/books/admin/{id}/ — partial update (multipart)
  Future<Either<Failure, AdminBookApiModel>> editBook(
      int bookId, FormData formData);

  /// DELETE /api/books/admin/{id}/
  Future<Either<Failure, void>> deleteBook(int bookId);

  /// GET /api/books/admin/{id}/users/
  Future<Either<Failure, List<BookUserAccess>>> getBookUsers(int bookId);

  /// POST /api/books/admin/{id}/grant/
  Future<Either<Failure, void>> grantBookAccess(
      {required int bookId, required int userId});

  /// POST /api/books/admin/{id}/revoke/
  Future<Either<Failure, void>> revokeBookAccess(
      {required int bookId, required int userId});
}
