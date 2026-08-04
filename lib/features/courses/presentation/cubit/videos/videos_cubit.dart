import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../data/models/video_model.dart';
import '../../../data/repos/courses_repo.dart';
import '../../../../../../core/errors/failures.dart';

part 'videos_state.dart';

class VideosCubit extends Cubit<VideosState> {
  final CoursesRepo _coursesRepo;

  VideosCubit({required CoursesRepo coursesRepo})
      : _coursesRepo = coursesRepo,
        super(const VideosInitial());

  // ─── Fetch Videos for a Level ──────────────────────────────────────────────
  Future<void> fetchVideos(int levelId) async {
    emit(const VideosLoading());

    // 1. Connectivity check
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(const VideosError(
        'لا يوجد اتصال بالإنترنت. تحتاج إلى الإنترنت لتشغيل الدروس.',
        isNoInternet: true,
      ));
      return;
    }

    final result = await _coursesRepo.getLevelVideos(levelId);

    result.fold(
      (failure) {
        if (failure is ForbiddenFailure) {
          emit(const VideosAccessDenied());
        } else if (failure is UnauthorizedFailure) {
          return;
        } else {
          emit(VideosError(
            failure.message,
            isNoInternet: failure is NetworkFailure,
          ));
        }
      },
      (data) => emit(VideosLoaded(data)),
    );
  }

  // ─── Reset ─────────────────────────────────────────────────────────────────
  void reset() => emit(const VideosInitial());

  // ─── Download Course File ──────────────────────────────────────────────────
  /// Streams the file bytes back; caller decides how to save/open them.
  /// Returns the raw bytes on success or emits [FileDownloadError].
  Future<List<int>?> downloadCourseFile({
    required int levelId,
    required int fileId,
  }) async {
    emit(FileDownloading(fileId));
    final result = await _coursesRepo.downloadCourseFile(
        levelId: levelId, fileId: fileId);
    return result.fold(
      (failure) {
        emit(FileDownloadError(failure.message));
        return null;
      },
      (response) {
        // Restore the last loaded state so UI doesn't flicker
        emit(const VideosInitial());
        return response.data;
      },
    );
  }
}
