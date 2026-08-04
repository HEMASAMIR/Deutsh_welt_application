part of 'comments_cubit.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  final List<CommentModel> comments;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;

  const CommentsLoaded({
    required this.comments,
    required this.totalCount,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  CommentsLoaded copyWith({
    List<CommentModel>? comments,
    int? totalCount,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CommentsLoaded(
      comments: comments ?? this.comments,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [comments, totalCount, hasMore, isLoadingMore];
}

class CommentsError extends CommentsState {
  final String message;
  final bool isNoInternet;

  const CommentsError(this.message, {this.isNoInternet = false});

  @override
  List<Object?> get props => [message, isNoInternet];
}

// ─── Action States (for posting / editing / deleting) ────────────────────────
class CommentActionLoading extends CommentsState {
  const CommentActionLoading();
}

class CommentPosted extends CommentsState {
  final CommentModel comment;
  const CommentPosted(this.comment);

  @override
  List<Object?> get props => [comment];
}

class ReplyPosted extends CommentsState {
  final ReplyModel reply;
  final int commentId;
  const ReplyPosted(this.reply, this.commentId);

  @override
  List<Object?> get props => [reply, commentId];
}

class CommentEdited extends CommentsState {
  final int commentId;
  final String newContent;
  const CommentEdited(this.commentId, this.newContent);

  @override
  List<Object?> get props => [commentId, newContent];
}

class CommentDeleted extends CommentsState {
  final int commentId;
  const CommentDeleted(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

class CommentActionError extends CommentsState {
  final String message;
  final bool isRateLimit;

  const CommentActionError(this.message, {this.isRateLimit = false});

  @override
  List<Object?> get props => [message, isRateLimit];
}
