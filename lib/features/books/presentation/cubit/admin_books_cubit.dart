import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/book_api_model.dart';
import '../../data/repos/books_repo.dart';
import 'admin_books_state.dart';

class AdminBooksCubit extends Cubit<AdminBooksState> {
  final AdminBooksRepo _adminBooksRepo;

  // Cache the last loaded books list so the UI never goes blank during ops
  List<AdminBookApiModel> _cachedBooks = [];

  AdminBooksCubit({required AdminBooksRepo adminBooksRepo})
      : _adminBooksRepo = adminBooksRepo,
        super(const AdminBooksInitial());

  // ─── Fetch all books (admin view) ────────────────────────────────────────────
  Future<void> fetchAllBooks() async {
    emit(AdminBooksLoading(cachedBooks: _cachedBooks));
    final result = await _adminBooksRepo.getAllBooks();
    result.fold(
      (failure) => emit(AdminBooksError(failure.message)),
      (books) {
        _cachedBooks = books;
        emit(AdminBooksLoaded(books));
      },
    );
  }

  // ─── Create book ─────────────────────────────────────────────────────────────
  /// [formData] must include: name, level, price, is_active, file (PDF)
  Future<void> createBook(FormData formData) async {
    emit(AdminBookOperationLoading(cachedBooks: _cachedBooks));
    final result = await _adminBooksRepo.createBook(formData);
    result.fold(
      (failure) => emit(AdminBookOperationError(failure.message)),
      (_) async {
        emit(const AdminBookOperationSuccess('تم إضافة الكتاب بنجاح ✅'));
        await fetchAllBooks();
      },
    );
  }

  // ─── Edit book ───────────────────────────────────────────────────────────────
  Future<void> editBook(int bookId, FormData formData) async {
    emit(AdminBookOperationLoading(cachedBooks: _cachedBooks));
    final result = await _adminBooksRepo.editBook(bookId, formData);
    result.fold(
      (failure) => emit(AdminBookOperationError(failure.message)),
      (_) async {
        emit(const AdminBookOperationSuccess('تم تحديث الكتاب بنجاح ✅'));
        await fetchAllBooks();
      },
    );
  }

  // ─── Delete book ─────────────────────────────────────────────────────────────
  Future<void> deleteBook(int bookId) async {
    emit(AdminBookOperationLoading(cachedBooks: _cachedBooks));
    final result = await _adminBooksRepo.deleteBook(bookId);
    result.fold(
      (failure) => emit(AdminBookOperationError(failure.message)),
      (_) async {
        emit(const AdminBookOperationSuccess('تم حذف الكتاب بنجاح ✅'));
        await fetchAllBooks();
      },
    );
  }

  // ─── Fetch users with book access ─────────────────────────────────────────────
  Future<void> fetchBookUsers(int bookId) async {
    final result = await _adminBooksRepo.getBookUsers(bookId);
    result.fold(
      (failure) => emit(AdminBooksError(failure.message)),
      (users) => emit(AdminBookUsersLoaded(users: users, bookId: bookId)),
    );
  }

  // ─── Grant access ────────────────────────────────────────────────────────────
  Future<void> grantAccess({required int bookId, required int userId}) async {
    emit(AdminBookOperationLoading(cachedBooks: _cachedBooks));
    final result =
        await _adminBooksRepo.grantBookAccess(bookId: bookId, userId: userId);
    result.fold(
      (failure) => emit(AdminBookOperationError(failure.message)),
      (_) async {
        emit(const AdminBookOperationSuccess('تم منح الصلاحية بنجاح ✅'));
        await fetchBookUsers(bookId);
      },
    );
  }

  // ─── Revoke access ───────────────────────────────────────────────────────────
  Future<void> revokeAccess({required int bookId, required int userId}) async {
    emit(AdminBookOperationLoading(cachedBooks: _cachedBooks));
    final result = await _adminBooksRepo.revokeBookAccess(
        bookId: bookId, userId: userId);
    result.fold(
      (failure) => emit(AdminBookOperationError(failure.message)),
      (_) async {
        emit(const AdminBookOperationSuccess('تم سحب الصلاحية بنجاح ✅'));
        await fetchBookUsers(bookId);
      },
    );
  }
}
