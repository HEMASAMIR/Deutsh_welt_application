import 'package:equatable/equatable.dart';
import '../../data/models/book_api_model.dart';

abstract class AdminBooksState extends Equatable {
  const AdminBooksState();
  @override
  List<Object?> get props => [];
}

class AdminBooksInitial extends AdminBooksState {
  const AdminBooksInitial();
}

/// Loading state that carries the previously loaded books
/// so the UI can keep showing them instead of going blank.
class AdminBooksLoading extends AdminBooksState {
  final List<AdminBookApiModel> cachedBooks;
  const AdminBooksLoading({this.cachedBooks = const []});
  @override
  List<Object?> get props => [cachedBooks];
}

class AdminBooksLoaded extends AdminBooksState {
  final List<AdminBookApiModel> books;
  const AdminBooksLoaded(this.books);
  @override
  List<Object?> get props => [books];
}

class AdminBooksError extends AdminBooksState {
  final String message;
  const AdminBooksError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Operation-level loading — carries cached books to avoid blank UI
class AdminBookOperationLoading extends AdminBooksState {
  final List<AdminBookApiModel> cachedBooks;
  const AdminBookOperationLoading({this.cachedBooks = const []});
  @override
  List<Object?> get props => [cachedBooks];
}

class AdminBookOperationSuccess extends AdminBooksState {
  final String message;
  const AdminBookOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminBookOperationError extends AdminBooksState {
  final String message;
  const AdminBookOperationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── Book Users States ────────────────────────────────────────────────────────
class AdminBookUsersLoaded extends AdminBooksState {
  final List<BookUserAccess> users;
  final int bookId;
  const AdminBookUsersLoaded({required this.users, required this.bookId});
  @override
  List<Object?> get props => [users, bookId];
}
