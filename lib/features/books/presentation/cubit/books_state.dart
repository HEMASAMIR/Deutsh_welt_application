import 'package:equatable/equatable.dart';
import '../../data/models/book_api_model.dart';

abstract class BooksState extends Equatable {
  const BooksState();
  @override
  List<Object?> get props => [];
}

class BooksInitial extends BooksState {
  const BooksInitial();
}

class BooksLoading extends BooksState {
  const BooksLoading();
}

class BooksLoaded extends BooksState {
  /// Grouped by level key, e.g. {"A1": [...], "A2": [...]}
  final Map<String, List<BookApiModel>> books;
  const BooksLoaded(this.books);
  @override
  List<Object?> get props => [books];
}

class BooksError extends BooksState {
  final String message;
  const BooksError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Download States ─────────────────────────────────────────────────────────

class BookDownloading extends BooksState {
  final int bookId;
  const BookDownloading(this.bookId);
  @override
  List<Object?> get props => [bookId];
}

class BookDownloadSuccess extends BooksState {
  final int bookId;
  final List<int> bytes;
  const BookDownloadSuccess({required this.bookId, required this.bytes});
  @override
  List<Object?> get props => [bookId];
}

class BookDownloadError extends BooksState {
  final String message;
  const BookDownloadError(this.message);
  @override
  List<Object?> get props => [message];
}
