import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../data/models/video_model.dart';
import '../cubit/comments/comments_cubit.dart';

class VideoCommentsView extends StatefulWidget {
  final VideoModel video;
  final int levelId;
  const VideoCommentsView({super.key, required this.video, required this.levelId});

  @override
  State<VideoCommentsView> createState() => _VideoCommentsViewState();
}

class _VideoCommentsViewState extends State<VideoCommentsView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    final rawUser = sl<StorageService>().user;
    if (rawUser != null) {
      try {
        _isAdmin = (jsonDecode(rawUser) as Map<String, dynamic>)['is_staff'] == true;
      } catch (_) {}
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<CommentsCubit>().loadMoreComments();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _post(BuildContext context) {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    if (content.length > 2000) {
      CustomSnackBar.show(context, message: 'الحد الأقصى للتعليق هو 2000 حرف.', type: SnackBarType.warning);
      return;
    }
    context.read<CommentsCubit>().postComment(content);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF0D9488),
      const Color(0xFF7C3AED),
      const Color(0xFFB45309),
      const Color(0xFFDB2777),
      const Color(0xFF0369A1),
    ];
    final index = name.codeUnits.fold<int>(0, (prev, element) => prev + element) % colors.length;
    return colors[index];
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  Future<void> _editComment(BuildContext context, int id, String initial) async {
    final controller = TextEditingController(text: initial);
    final updated = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تعديل التعليق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 5,
          maxLength: 2000,
          style: GoogleFonts.cairo(fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'اكتب تعديلك هنا...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('حفظ', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
    if (updated != null && updated.isNotEmpty && context.mounted) {
      context.read<CommentsCubit>().editComment(commentId: id, newContent: updated);
    }
  }

  Future<void> _reply(BuildContext context, int id) async {
    final controller = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('رد على التعليق', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 5,
          maxLength: 2000,
          style: GoogleFonts.cairo(fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'اكتب ردك هنا...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('إرسال', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
    if (reply != null && reply.isNotEmpty && context.mounted) {
      context.read<CommentsCubit>().postReply(commentId: id, content: reply);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CommentsCubit>()..loadComments(levelId: widget.levelId, videoId: widget.video.id),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          title: BlocBuilder<CommentsCubit, CommentsState>(
            buildWhen: (_, s) => s is CommentsLoaded || s is CommentsInitial,
            builder: (_, state) {
              final total = state is CommentsLoaded ? state.totalCount : 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مناقشات الدرس',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (total > 0)
                    Text('$total تعليق',
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: Colors.white.withValues(alpha: 0.75))),
                ],
              );
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<CommentsCubit, CommentsState>(
                listener: (context, state) {
                  if (state is CommentActionError) {
                    CustomSnackBar.show(context, message: state.message, type: SnackBarType.error);
                  }
                  if (state is CommentPosted) {
                    CustomSnackBar.show(context, message: 'تم إضافة تعليقك بنجاح.', type: SnackBarType.success);
                  }
                },
                builder: (context, state) {
                  if (state is CommentsLoading || state is CommentsInitial) {
                    return CustomShimmer.list(count: 4, height: 110);
                  }
                  if (state is CommentsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.cairo(color: AppColors.textSecondary),
                      ),
                    );
                  }
                  if (state is! CommentsLoaded) {
                    return const SizedBox.shrink();
                  }
                  if (state.comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 64,
                            color: AppColors.textHint.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد تعليقات بعد.\nكن أول من يشارك استفساره أو رأيه!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: state.comments.length + (state.hasMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      // Load-more spinner at the bottom
                      if (index == state.comments.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        );
                      }
                      final comment = state.comments[index];
                      final userColor = _getAvatarColor(comment.user.displayName);
                      final isDeleted = comment.isDeleted;

                      return FadeInUp(
                        duration: Duration(milliseconds: 300 + (index * 80)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: AppColors.border, width: 1.2),
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Comment Header
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: userColor.withValues(alpha: 0.12),
                                    child: Text(
                                      comment.user.firstName.isNotEmpty
                                          ? comment.user.firstName[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(color: userColor, fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.user.displayName,
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          _getTimeAgo(comment.createdAt),
                                          style: GoogleFonts.cairo(
                                            fontSize: 10,
                                            color: AppColors.textHint,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Comment Content
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  isDeleted ? 'تم حذف هذا التعليق.' : comment.content,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.5,
                                    color: isDeleted
                                        ? AppColors.textHint
                                        : AppColors.textPrimary,
                                    fontStyle: isDeleted ? FontStyle.italic : FontStyle.normal,
                                  ),
                                ),
                              ),
                              // Actions Row (Reply / Edit / Delete)
                              if (!isDeleted) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _reply(context, comment.id),
                                      icon: const Icon(Icons.reply_rounded, size: 16, color: AppColors.primaryBlue),
                                      label: Text(
                                        'رد',
                                        style: GoogleFonts.cairo(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    if (comment.isOwner && comment.isEditable)
                                      IconButton(
                                        tooltip: 'تعديل التعليق',
                                        onPressed: () => _editComment(context, comment.id, comment.content),
                                        icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                                      ),
                                    if (comment.isOwner || _isAdmin)
                                      IconButton(
                                        tooltip: 'حذف التعليق',
                                        onPressed: () => context.read<CommentsCubit>().deleteComment(comment.id),
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 16),
                                      ),
                                  ],
                                ),
                              ],
                              // Replies list
                              if (comment.replies.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Divider(height: 1),
                                const SizedBox(height: 10),
                                ...comment.replies.map((reply) {
                                  final rColor = _getAvatarColor(reply.user.displayName);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8, right: 16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: rColor.withValues(alpha: 0.12),
                                          child: Text(
                                            reply.user.firstName.isNotEmpty
                                                ? reply.user.firstName[0].toUpperCase()
                                                : '?',
                                            style: TextStyle(color: rColor, fontWeight: FontWeight.bold, fontSize: 10),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    reply.user.displayName,
                                                    style: GoogleFonts.cairo(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _getTimeAgo(reply.createdAt),
                                                    style: GoogleFonts.cairo(
                                                      fontSize: 9,
                                                      color: AppColors.textHint,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                reply.content,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Input Box at bottom
            Builder(
              builder: (ctx) => SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border, width: 1.2),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _controller,
                            maxLength: 2000,
                            minLines: 1,
                            maxLines: 4,
                            style: GoogleFonts.cairo(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'اكتب استفسارك أو تعليقك...',
                              counterText: '',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => _post(ctx),
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
