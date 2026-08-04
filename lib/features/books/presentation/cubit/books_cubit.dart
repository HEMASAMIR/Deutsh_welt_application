import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/books_repo.dart';
import 'books_state.dart';

class BooksCubit extends Cubit<BooksState> {
  final BooksRepo _booksRepo;

  BooksCubit({required BooksRepo booksRepo})
      : _booksRepo = booksRepo,
        super(const BooksInitial());

  // ─── Fetch all books (student view) ─────────────────────────────────────────
  Future<void> fetchBooks() async {
    emit(const BooksLoading());
    final result = await _booksRepo.getBooks();
    result.fold(
      (failure) => emit(BooksError(failure.message)),
      (books) => emit(BooksLoaded(books)),
    );
  }

  // ─── Download a book PDF ─────────────────────────────────────────────────────
  /// Emits [BookDownloading] → [BookDownloadSuccess] or [BookDownloadError].
  /// The caller is responsible for saving/opening the bytes.
  Future<void> downloadBook(int bookId) async {
    // Keep loaded books visible while downloading
    final currentBooks =
        state is BooksLoaded ? (state as BooksLoaded).books : null;

    emit(BookDownloading(bookId));

    final result = await _booksRepo.downloadBook(bookId);
    result.fold(
      (failure) => emit(BookDownloadError(failure.message)),
      (response) {
        final bytes = response.data;
        if (bytes == null || bytes.isEmpty) {
          emit(const BookDownloadError('تعذر تحميل الملف، يرجى المحاولة لاحقاً'));
          return;
        }
        emit(BookDownloadSuccess(bookId: bookId, bytes: bytes));
        // Restore loaded state
        if (currentBooks != null) {
          emit(BooksLoaded(currentBooks));
        }
      },
    );
  }
}
