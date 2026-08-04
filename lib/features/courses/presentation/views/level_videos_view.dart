import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/app_settings_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../data/models/video_model.dart';
import '../cubit/videos/videos_cubit.dart';

// ─── Chapter Model ─────────────────────────────────────────────────────────────
/// Groups 2 consecutive videos into one Chapter with an optional PDF
class _Chapter {
  final int index; // 1-based chapter number
  final VideoModel video1;
  final VideoModel? video2; // null for last chapter if odd number
  final CourseFileModel? pdf; // optional chapter PDF

  const _Chapter({
    required this.index,
    required this.video1,
    this.video2,
    this.pdf,
  });

  int get videoCount => video2 != null ? 2 : 1;
}

/// Groups videos into chapters (2 per chapter) and maps PDFs by chapter index
List<_Chapter> _buildChapters(
    List<VideoModel> videos, List<CourseFileModel> files) {
  final sorted = List<VideoModel>.from(videos)
    ..sort((a, b) => a.order.compareTo(b.order));
  final activePdfs = files.where((f) => f.isActive).toList();

  final chapters = <_Chapter>[];
  for (int i = 0; i < sorted.length; i += 2) {
    final chapterIndex = (i ~/ 2) + 1; // 1-based
    chapters.add(_Chapter(
      index: chapterIndex,
      video1: sorted[i],
      video2: i + 1 < sorted.length ? sorted[i + 1] : null,
      // Map PDF by chapter index (chapter 1 → pdf[0], chapter 2 → pdf[1])
      pdf: activePdfs.length >= chapterIndex
          ? activePdfs[chapterIndex - 1]
          : null,
    ));
  }
  return chapters;
}

// ─── Motivational Messages ─────────────────────────────────────────────────────
const _motivationalMessages = [
  ('🇩🇪 Sehr gut! كمال كدا وهتتقن الألمانية 💪', Colors.blue),
  ('🔥 أنت بتتقدم بشكل رائع يا بطل!', Colors.orange),
  ('🌟 كل درس بتخلصه هو خطوة للـ B2!', Colors.purple),
  ('🎯 تركيزك ده هيوصلك لأهدافك!', Colors.teal),
  ('💡 الألمانية مش صعبة، إنت اللي بيعملها سهلة!', Colors.green),
  ('⚡ Weiter so! استمر وأنت على المسار الصح!', Colors.indigo),
  ('🏆 Wunderbar! استمر يا نجم!', Colors.amber),
  ('📚 كل Kapitel خلصته بيفرق كتير!', Colors.cyan),
];

// ─── Main View ────────────────────────────────────────────────────────────────
class LevelVideosView extends StatelessWidget {
  final int levelId;
  final String levelName;
  const LevelVideosView(
      {super.key, required this.levelId, required this.levelName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VideosCubit>()..fetchVideos(levelId),
      child: _LevelVideosBody(levelId: levelId, levelName: levelName),
    );
  }
}

class _LevelVideosBody extends StatefulWidget {
  final int levelId;
  final String levelName;
  const _LevelVideosBody(
      {required this.levelId, required this.levelName});

  @override
  State<_LevelVideosBody> createState() => _LevelVideosBodyState();
}

class _LevelVideosBodyState extends State<_LevelVideosBody>
    with TickerProviderStateMixin {
  // Track watched videos (stored locally per level)
  Set<String> _watchedVideoIds = {};
  late final String _prefsKey;

  // Floating motivational message state
  int _motIndex = 0;
  late final AnimationController _motController;
  late final Animation<double> _motFade;

  @override
  void initState() {
    super.initState();
    _prefsKey = 'watched_videos_level_${widget.levelId}';
    _loadWatched();

    // Rotating motivational message animation
    _motController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 4), () {
            if (!mounted) return;
            _motController.reverse();
          });
        } else if (status == AnimationStatus.dismissed) {
          if (!mounted) return;
          setState(() {
            _motIndex = (_motIndex + 1) % _motivationalMessages.length;
          });
          _motController.forward();
        }
      });

    _motFade = CurvedAnimation(
      parent: _motController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _motController.forward();
    });
  }

  @override
  void dispose() {
    _motController.dispose();
    super.dispose();
  }

  Future<void> _loadWatched() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefsKey) ?? [];
    if (mounted) setState(() => _watchedVideoIds = ids.toSet());
  }

  Future<void> _markWatched(String videoId) async {
    if (_watchedVideoIds.contains(videoId)) return;
    _watchedVideoIds.add(videoId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _watchedVideoIds.toList());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: BlocConsumer<VideosCubit, VideosState>(
        listenWhen: (_, s) => s is FileDownloadError || s is FileDownloading,
        listener: (context, state) {
          if (state is FileDownloadError) {
            CustomSnackBar.show(context,
                message: state.message, type: SnackBarType.error);
          }
          if (state is FileDownloading) {
            CustomSnackBar.show(context,
                message: 'جاري تحميل الملف... ⏳', type: SnackBarType.info);
          }
        },
        buildWhen: (_, s) =>
            s is VideosLoading ||
            s is VideosInitial ||
            s is VideosLoaded ||
            s is VideosAccessDenied ||
            s is VideosError,
        builder: (context, state) {
          if (state is VideosLoading || state is VideosInitial) {
            return CustomShimmer.list(count: 5, height: 130);
          }
          if (state is VideosAccessDenied) {
            return const _AccessDenied();
          }
          if (state is VideosError) {
            return _VideosError(
              message: state.message,
              isNoInternet: state.isNoInternet,
              onRetry: () =>
                  context.read<VideosCubit>().fetchVideos(widget.levelId),
            );
          }

          final loaded = state as VideosLoaded;
          final chapters =
              _buildChapters(loaded.data.videos, loaded.data.files);
          final totalVideos = loaded.data.videos.length;
          final watchedCount =
              _watchedVideoIds.intersection(
                  loaded.data.videos.map((v) => v.id).toSet()).length;

          if (chapters.isEmpty) {
            return _emptyState(context);
          }

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () =>
                context.read<VideosCubit>().fetchVideos(widget.levelId),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        // ── Group Link Card ──────────────────────────────────
                        _CourseGroupHeaderCard(
                            levelName: widget.levelName),
                        const SizedBox(height: 16),

                        // ── Overall Progress Card ────────────────────────────
                        _ProgressCard(
                          levelName: widget.levelName,
                          watched: watchedCount,
                          total: totalVideos,
                        ),
                        const SizedBox(height: 16),

                        // ── Motivational floating message ────────────────────
                        FadeTransition(
                          opacity: _motFade,
                          child: _MotivationalBanner(
                            message:
                                _motivationalMessages[_motIndex].$1,
                            color: _motivationalMessages[_motIndex].$2,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Chapters Header ──────────────────────────────────
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.menu_book_rounded,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'الكابيتالات 📖',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${chapters.length} كابيتال',
                              style: GoogleFonts.cairo(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // ── Chapter cards ────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final chapter = chapters[i];
                        return FadeInUp(
                          duration:
                              Duration(milliseconds: 200 + (i * 100)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ChapterCard(
                              chapter: chapter,
                              levelId: widget.levelId,
                              watchedVideoIds: _watchedVideoIds,
                              onVideoTap: (video) {
                                _markWatched(video.id);
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.videoPlayer,
                                  arguments: {
                                    'video': video,
                                    'levelId': widget.levelId,
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                      childCount: chapters.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      title: Text(
        'دروس ${widget.levelName}',
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      actions: [
        IconButton(
          tooltip: 'تحديث',
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () =>
              context.read<VideosCubit>().fetchVideos(widget.levelId),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_rounded,
              size: 72,
              color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'لا توجد دروس متاحة حالياً.',
            style: GoogleFonts.cairo(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Card ─────────────────────────────────────────────────────────────
class _ProgressCard extends StatelessWidget {
  final String levelName;
  final int watched;
  final int total;

  const _ProgressCard({
    required this.levelName,
    required this.watched,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : watched / total;
    final pct = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تقدمك في $levelName',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$watched من $total درس شاهدته',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                builder: (_, val, __) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: val,
                          strokeWidth: 5,
                          backgroundColor:
                              AppColors.primaryBlue.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pct >= 100
                                ? AppColors.success
                                : AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Linear bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOut,
            builder: (_, val, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: val,
                  minHeight: 8,
                  backgroundColor:
                      AppColors.primaryBlue.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct >= 100
                        ? AppColors.success
                        : AppColors.primaryBlue,
                  ),
                ),
              );
            },
          ),
          if (pct >= 100) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: Colors.amber, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Herzlichen Glückwunsch! أتممت الكورس 🎉',
                  style: GoogleFonts.cairo(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Motivational Banner ───────────────────────────────────────────────────────
class _MotivationalBanner extends StatelessWidget {
  final String message;
  final Color color;

  const _MotivationalBanner({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cairo(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chapter Card ──────────────────────────────────────────────────────────────
class _ChapterCard extends StatefulWidget {
  final _Chapter chapter;
  final int levelId;
  final Set<String> watchedVideoIds;
  final void Function(VideoModel video) onVideoTap;

  const _ChapterCard({
    required this.chapter,
    required this.levelId,
    required this.watchedVideoIds,
    required this.onVideoTap,
  });

  @override
  State<_ChapterCard> createState() => _ChapterCardState();
}

class _ChapterCardState extends State<_ChapterCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _expandController;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(
        parent: _expandController, curve: Curves.easeInOut);
    // First chapter opens by default
    if (widget.chapter.index == 1) {
      _expanded = true;
      _expandController.forward();
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  bool get _video1Watched =>
      widget.watchedVideoIds.contains(widget.chapter.video1.id);
  bool get _video2Watched => widget.chapter.video2 != null &&
      widget.watchedVideoIds.contains(widget.chapter.video2!.id);

  int get _watchedCount =>
      (_video1Watched ? 1 : 0) + (_video2Watched ? 1 : 0);

  double get _chapterProgress =>
      widget.chapter.videoCount == 0 ? 0 : _watchedCount / widget.chapter.videoCount;

  bool get _chapterDone => _watchedCount == widget.chapter.videoCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _chapterDone
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
          width: _chapterDone ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_chapterDone ? AppColors.success : AppColors.primaryBlue)
                .withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Chapter Header ────────────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() => _expanded = !_expanded);
              if (_expanded) {
                _expandController.forward();
              } else {
                _expandController.reverse();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Chapter number badge
                      _ChapterBadge(
                        number: widget.chapter.index,
                        isDone: _chapterDone,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الكابيتال ${widget.chapter.index}',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.play_circle_outline_rounded,
                                    size: 13,
                                    color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.chapter.videoCount} فيديو',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                if (widget.chapter.pdf != null) ...[
                                  const SizedBox(width: 10),
                                  Icon(Icons.picture_as_pdf_rounded,
                                      size: 13,
                                      color: const Color(0xFFEF4444)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PDF',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      color: const Color(0xFFEF4444),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Done badge
                      if (_chapterDone)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.success, size: 13),
                              const SizedBox(width: 3),
                              Text(
                                'تمام ✅',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 280),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Chapter progress bar
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _chapterProgress),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOut,
                    builder: (_, val, __) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: val,
                          minHeight: 5,
                          backgroundColor:
                              AppColors.primaryBlue.withValues(alpha: 0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _chapterDone
                                ? AppColors.success
                                : AppColors.primaryBlue,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable Content ────────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF334155)
                        : AppColors.border),

                // Videos
                _VideoRow(
                  video: widget.chapter.video1,
                  videoNumber: 1,
                  chapterNumber: widget.chapter.index,
                  isWatched: _video1Watched,
                  onTap: () => widget.onVideoTap(widget.chapter.video1),
                  isDark: isDark,
                ),
                if (widget.chapter.video2 != null) ...[
                  Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: isDark
                          ? const Color(0xFF334155)
                          : AppColors.border),
                  _VideoRow(
                    video: widget.chapter.video2!,
                    videoNumber: 2,
                    chapterNumber: widget.chapter.index,
                    isWatched: _video2Watched,
                    onTap: () =>
                        widget.onVideoTap(widget.chapter.video2!),
                    isDark: isDark,
                  ),
                ],

                // PDF Row
                if (widget.chapter.pdf != null) ...[
                  Divider(
                      height: 1,
                      color: isDark
                          ? const Color(0xFF334155)
                          : AppColors.border),
                  _PdfRow(
                    file: widget.chapter.pdf!,
                    levelId: widget.levelId,
                    isDark: isDark,
                  ),
                ],
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chapter Badge ─────────────────────────────────────────────────────────────
class _ChapterBadge extends StatelessWidget {
  final int number;
  final bool isDone;

  const _ChapterBadge({required this.number, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: isDone
            ? const LinearGradient(
                colors: [AppColors.success, Color(0xFF34D399)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDone ? AppColors.success : AppColors.primaryBlue)
                .withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: isDone
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
            : Text(
                '$number',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}

// ─── Video Row ─────────────────────────────────────────────────────────────────
class _VideoRow extends StatelessWidget {
  final VideoModel video;
  final int videoNumber;
  final int chapterNumber;
  final bool isWatched;
  final VoidCallback onTap;
  final bool isDark;

  const _VideoRow({
    required this.video,
    required this.videoNumber,
    required this.chapterNumber,
    required this.isWatched,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Video icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isWatched
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isWatched
                    ? Icons.check_circle_rounded
                    : Icons.play_arrow_rounded,
                color: isWatched ? AppColors.success : AppColors.primaryBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'جزء $videoNumber',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.schedule_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        video.formattedDuration,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isWatched) ...[
                        const SizedBox(width: 8),
                        Text(
                          '✅ شاهدته',
                          style: GoogleFonts.cairo(
                            fontSize: 10,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PDF Row ───────────────────────────────────────────────────────────────────
class _PdfRow extends StatelessWidget {
  final CourseFileModel file;
  final int levelId;
  final bool isDark;

  const _PdfRow(
      {required this.file, required this.levelId, required this.isDark});

  Future<void> _download(BuildContext context) async {
    final cubit = context.read<VideosCubit>();
    final bytes =
        await cubit.downloadCourseFile(levelId: levelId, fileId: file.id);
    if (bytes == null || !context.mounted) return;
    try {
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/${file.name.replaceAll(' ', '_')}.pdf';
      final f = File(filePath);
      await f.writeAsBytes(bytes);
      final uri = Uri.file(filePath);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          CustomSnackBar.show(context,
              message: 'تم تنزيل الملف ✅ لكن تعذر فتحه تلقائياً',
              type: SnackBarType.info);
        }
      }
    } catch (_) {
      if (context.mounted) {
        CustomSnackBar.show(context,
            message: 'تعذر حفظ الملف على الجهاز',
            type: SnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _download(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF7F1D1D).withValues(alpha: 0.2)
              : const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                : const Color(0xFFFED7AA),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Color(0xFFEF4444), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'ملف PDF الخاص بهذا الكابيتال 📥',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<VideosCubit, VideosState>(
              buildWhen: (_, s) =>
                  s is FileDownloading ||
                  s is VideosLoaded ||
                  s is VideosInitial,
              builder: (context, state) {
                final downloading =
                    state is FileDownloading && state.fileId == file.id;
                return downloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFEF4444),
                        ),
                      )
                    : const Icon(Icons.download_rounded,
                        color: Color(0xFFEF4444), size: 20);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Existing Widgets (unchanged) ─────────────────────────────────────────────
class _AccessDenied extends StatelessWidget {
  const _AccessDenied();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded,
                  size: 48, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              'عفواً، لا تملك صلاحية المشاهدة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'دروس هذا الكورس مقفلة لحسابك.\nيرجى التواصل مع الدعم الفني للاشتراك وتفعيل المحتوى.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideosError extends StatelessWidget {
  final String message;
  final bool isNoInternet;
  final VoidCallback onRetry;

  const _VideosError({
    required this.message,
    required this.isNoInternet,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNoInternet
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              color: isNoInternet ? AppColors.textHint : AppColors.error,
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
            )
          ],
        ),
      ),
    );
  }
}

// ─── Course Group Header Card ──────────────────────────────────────────────────
class _CourseGroupHeaderCard extends StatelessWidget {
  final String levelName;
  const _CourseGroupHeaderCard({required this.levelName});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSettingsModel>(
      future: AppSettingsService.loadSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final settings = snapshot.data!;

        String groupUrl = settings.groupLinkA1;
        final nameUpper = levelName.toUpperCase();
        if (nameUpper.contains('A2')) {
          groupUrl = settings.groupLinkA2;
        } else if (nameUpper.contains('B1')) {
          groupUrl = settings.groupLinkB1;
        } else if (nameUpper.contains('B2')) {
          groupUrl = settings.groupLinkB2;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF0284C7)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.forum_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جروب $levelName التفاعلي 💬',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'انضم لمجموعة المناقشات والتفاعل الخاصة بطلاب هذا المستوى 🇩🇪🚀',
                      style: GoogleFonts.cairo(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1E3A8A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (groupUrl.isNotEmpty) {
                    await launchUrl(Uri.parse(groupUrl),
                        mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text(
                  'انضم الان',
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
