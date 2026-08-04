import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/repos/courses_repo.dart';
import '../../../../../../core/errors/failures.dart';

part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final CoursesRepo _coursesRepo;

  /// Track pagination internally
  int _currentPage = 1;
  bool _hasMore = true;
  final List<CommentModel> _comments = [];

  /// Stored context for pagination / actions (set on first load)
  int? _levelId;
  String? _videoId;

  CommentsCubit({required CoursesRepo coursesRepo})
      : _coursesRepo = coursesRepo,
        super(const CommentsInitial());

  // ─── Load First Page ───────────────────────────────────────────────────────
  Future<void> loadComments({
    required int levelId,
    required String videoId,
  }) async {
    _levelId = levelId;
    _videoId = videoId;
    _currentPage = 1;
    _hasMore = true;
    _comments.clear();

    emit(const CommentsLoading());

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(const CommentsError(
        'لا يوجد اتصال بالإنترنت.',
        isNoInternet: true,
      ));
      return;
    }

    final result = await _coursesRepo.getComments(
      levelId: levelId,
      videoId: videoId,
      page: _currentPage,
    );

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(CommentsError(
          failure.message,
          isNoInternet: failure is NetworkFailure,
        ));
      },
      (paginated) {
        _comments.addAll(paginated.results);
        _hasMore = paginated.hasNextPage;
        emit(CommentsLoaded(
          comments: List.unmodifiable(_comments),
          totalCount: paginated.count,
          hasMore: _hasMore,
        ));
      },
    );
  }

  // ─── Load More (Pagination) ────────────────────────────────────────────────
  Future<void> loadMoreComments() async {
    if (!_hasMore || state is! CommentsLoaded) return;
    final currentState = state as CommentsLoaded;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    _currentPage++;

    final result = await _coursesRepo.getComments(
      levelId: _levelId!,
      videoId: _videoId!,
      page: _currentPage,
    );

    result.fold(
      (failure) {
        _currentPage--; // revert on failure
        if (failure is UnauthorizedFailure) return;
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (paginated) {
        _comments.addAll(paginated.results);
        _hasMore = paginated.hasNextPage;
        emit(CommentsLoaded(
          comments: List.unmodifiable(_comments),
          totalCount: paginated.count,
          hasMore: _hasMore,
          isLoadingMore: false,
        ));
      },
    );
  }

  // ─── Post Comment ──────────────────────────────────────────────────────────
  Future<void> postComment(String content) async {
    if (_levelId == null || _videoId == null) return;

    emit(const CommentActionLoading());

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(const CommentActionError('لا يوجد اتصال بالإنترنت.'));
      _restoreListState();
      return;
    }

    final result = await _coursesRepo.createComment(
      levelId: _levelId!,
      videoId: _videoId!,
      content: content,
    );

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        final isRateLimit = failure.message.contains('429') ||
            failure.message.contains('طلبات كثيرة');
        emit(CommentActionError(
          isRateLimit
              ? 'أرسلت تعليقات كثيرة، انتظر قليلاً ثم حاول مرة أخرى.'
              : failure.message,
          isRateLimit: isRateLimit,
        ));
        _restoreListState();
      },
      (comment) {
        // ✅ Optimistic: prepend to local list immediately
        _comments.insert(0, comment);
        emit(CommentPosted(comment));
        // Immediately transition to loaded state with updated list
        emit(CommentsLoaded(
          comments: List.unmodifiable(_comments),
          totalCount: (_comments.length),
          hasMore: _hasMore,
        ));
      },
    );
  }

  // ─── Reply to Comment ──────────────────────────────────────────────────────
  Future<void> postReply({
    required int commentId,
    required String content,
  }) async {
    if (_levelId == null || _videoId == null) return;

    emit(const CommentActionLoading());

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(const CommentActionError('لا يوجد اتصال بالإنترنت.'));
      _restoreListState();
      return;
    }

    final result = await _coursesRepo.replyToComment(
      levelId: _levelId!,
      videoId: _videoId!,
      commentId: commentId,
      content: content,
    );

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(CommentActionError(failure.message));
        _restoreListState();
      },
      (reply) {
        // ✅ Optimistic: append reply to the parent comment
        final idx = _comments.indexWhere((c) => c.id == commentId);
        if (idx != -1) {
          final updated = _comments[idx].copyWith(
            replies: [..._comments[idx].replies, reply],
            replyCount: _comments[idx].replyCount + 1,
          );
          _comments[idx] = updated;
        }
        emit(ReplyPosted(reply, commentId));
        emit(CommentsLoaded(
          comments: List.unmodifiable(_comments),
          totalCount: _comments.length,
          hasMore: _hasMore,
        ));
      },
    );
  }

  // ─── Edit Comment ──────────────────────────────────────────────────────────
  Future<void> editComment({
    required int commentId,
    required String newContent,
  }) async {
    if (_levelId == null || _videoId == null) return;

    emit(const CommentActionLoading());

    final result = await _coursesRepo.editComment(
      levelId: _levelId!,
      videoId: _videoId!,
      commentId: commentId,
      content: newContent,
    );

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(CommentActionError(failure.message));
        _restoreListState();
      },
      (_) {
        // ✅ Update local list
        final idx = _comments.indexWhere((c) => c.id == commentId);
        if (idx != -1) {
          _comments[idx] = _comments[idx].copyWith(content: newContent);
        }
        emit(CommentEdited(commentId, newContent));
        emit(CommentsLoaded(
          comments: List.unmodifiable(_comments),
          totalCount: _comments.length,
          hasMore: _hasMore,
        ));
      },
    );
  }

  // ─── Delete Comment ────────────────────────────────────────────────────────
  Future<void> deleteComment(int commentId) async {
    if (_levelId == null || _videoId == null) return;

    emit(const CommentActionLoading());

    final result = await _coursesRepo.deleteComment(
      levelId: _levelId!,
      videoId: _videoId!,
      commentId: commentId,
    );

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(CommentActionError(failure.message));
        _restoreListState();
      },
      (_) {
        // ✅ Soft-delete: update content to sentinel value
        final idx = _comments.indexWhere((c) => c.id == commentId);
        if (idx != -1) {
          _comments[idx] = _comments[idx].copyWith(
            content: 'This comment was removed.',
          );
        }
        emit(CommentDeleted(commentId));
        emit(CommentsLoaded(
          comments: List.unmodifiable(_comments),
          totalCount: _comments.length,
          hasMore: _hasMore,
        ));
      },
    );
  }

  // ─── Restore list state after an action error ─────────────────────────────
  void _restoreListState() {
    emit(CommentsLoaded(
      comments: List.unmodifiable(_comments),
      totalCount: _comments.length,
      hasMore: _hasMore,
    ));
  }

  // ─── Reset ─────────────────────────────────────────────────────────────────
  void reset() {
    _currentPage = 1;
    _hasMore = true;
    _comments.clear();
    _levelId = null;
    _videoId = null;
    emit(const CommentsInitial());
  }
}
