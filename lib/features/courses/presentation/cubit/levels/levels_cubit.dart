import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../data/models/level_model.dart';
import '../../../data/repos/courses_repo.dart';
import '../../../../../../core/errors/failures.dart';

part 'levels_state.dart';

class LevelsCubit extends Cubit<LevelsState> {
  final CoursesRepo _coursesRepo;

  LevelsCubit({required CoursesRepo coursesRepo})
      : _coursesRepo = coursesRepo,
        super(const LevelsInitial());

  // ─── Fetch Levels ──────────────────────────────────────────────────────────
  Future<void> fetchLevels() async {
    emit(const LevelsLoading());
    await _loadLevels();
  }

  // ─── Pull-to-Refresh ───────────────────────────────────────────────────────
  Future<void> refreshLevels() async {
    // Show the current data with a refreshing indicator if already loaded
    if (state is LevelsLoaded) {
      emit(LevelsLoaded(
        (state as LevelsLoaded).levels,
        isRefreshing: true,
      ));
    } else {
      emit(const LevelsLoading());
    }
    await _loadLevels();
  }

  // ─── Internal loader ──────────────────────────────────────────────────────
  Future<void> _loadLevels() async {
    // 1. Check connectivity before making the network call
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(const LevelsError(
        'لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.',
        isNoInternet: true,
      ));
      return;
    }

    final result = await _coursesRepo.getLevels();

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) {
          return;
        }
        emit(LevelsError(
          failure.message,
          isNoInternet: failure is NetworkFailure,
        ));
      },
      (levels) => emit(LevelsLoaded(levels)),
    );
  }
}
