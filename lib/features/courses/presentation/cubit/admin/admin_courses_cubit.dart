import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/errors/failures.dart';
import '../../../data/models/level_model.dart';
import '../../../data/models/user_access_model.dart';
import '../../../data/repos/courses_repo.dart';

part 'admin_courses_state.dart';

class AdminCoursesCubit extends Cubit<AdminCoursesState> {
  final AdminCoursesRepo _adminRepo;

  // Local cache for optimistic UI
  List<AdminLevelModel> _levels = [];
  List<UserAccessModel> _levelUsers = [];
  int? _currentLevelId;

  AdminCoursesCubit({required AdminCoursesRepo adminRepo})
      : _adminRepo = adminRepo,
        super(const AdminCoursesInitial());

  // ─── List Admin Levels ─────────────────────────────────────────────────────
  Future<void> fetchAdminLevels() async {
    emit(const AdminCoursesLoading());

    final result = await _adminRepo.getAdminLevels();

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(AdminCoursesError(failure.message));
      },
      (levels) {
        _levels = levels;
        emit(AdminLevelsLoaded(List.unmodifiable(_levels)));
      },
    );
  }

  // ─── Create Level ──────────────────────────────────────────────────────────
  Future<void> createLevel(Map<String, dynamic> data) async {
    emit(const AdminActionLoading());

    final result = await _adminRepo.createLevel(data);

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(AdminCoursesError(failure.message));
      },
      (level) {
        _levels = [level, ..._levels];
        emit(AdminLevelCreated(level));
        emit(AdminLevelsLoaded(List.unmodifiable(_levels)));
      },
    );
  }

  // ─── Update Level ──────────────────────────────────────────────────────────
  Future<void> updateLevel(int levelId, Map<String, dynamic> data) async {
    emit(const AdminActionLoading());

    final result = await _adminRepo.updateLevel(levelId, data);

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(AdminCoursesError(failure.message));
      },
      (updated) {
        final idx = _levels.indexWhere((l) => l.id == levelId);
        if (idx != -1) _levels[idx] = updated;
        emit(AdminLevelUpdated(updated));
        emit(AdminLevelsLoaded(List.unmodifiable(_levels)));
      },
    );
  }

  // ─── Delete Level ──────────────────────────────────────────────────────────
  Future<void> deleteLevel(int levelId) async {
    // Optimistic remove
    final backup = List<AdminLevelModel>.from(_levels);
    _levels.removeWhere((l) => l.id == levelId);
    emit(AdminLevelsLoaded(List.unmodifiable(_levels)));

    final result = await _adminRepo.deleteLevel(levelId);

    result.fold(
      (failure) {
        _levels = backup; // rollback
        emit(AdminLevelsLoaded(List.unmodifiable(_levels)));
        if (failure is UnauthorizedFailure) return;
        emit(AdminCoursesError(failure.message));
      },
      (_) => emit(AdminLevelDeleted(levelId)),
    );
  }

  // ─── List Users With Access ────────────────────────────────────────────────
  Future<void> fetchLevelUsers(int levelId) async {
    _currentLevelId = levelId;
    emit(const AdminCoursesLoading());

    final result = await _adminRepo.getLevelUsers(levelId);

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(AdminCoursesError(failure.message));
      },
      (users) {
        _levelUsers = users;
        emit(AdminLevelUsersLoaded(List.unmodifiable(_levelUsers), levelId));
      },
    );
  }

  // ─── Grant Access ──────────────────────────────────────────────────────────
  Future<void> grantAccess({
    required int levelId,
    required int userId,
    String? notes,
  }) async {
    emit(const AdminActionLoading());

    final result = await _adminRepo.grantAccess(
      levelId: levelId,
      userId: userId,
      notes: notes,
    );

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(AdminCoursesError(failure.message));
      },
      (access) {
        _levelUsers = [access, ..._levelUsers];
        emit(AdminAccessGranted(access));
        emit(AdminLevelUsersLoaded(
            List.unmodifiable(_levelUsers), _currentLevelId ?? levelId));
      },
    );
  }

  // ─── Revoke Access ─────────────────────────────────────────────────────────
  Future<void> revokeAccess({
    required int levelId,
    required int userId,
  }) async {
    // Optimistic remove
    final backup = List<UserAccessModel>.from(_levelUsers);
    _levelUsers.removeWhere((u) => u.user == userId);
    emit(AdminLevelUsersLoaded(
        List.unmodifiable(_levelUsers), _currentLevelId ?? levelId));

    final result = await _adminRepo.revokeAccess(
      levelId: levelId,
      userId: userId,
    );

    result.fold(
      (failure) {
        _levelUsers = backup;
        emit(AdminLevelUsersLoaded(
            List.unmodifiable(_levelUsers), _currentLevelId ?? levelId));
        if (failure is UnauthorizedFailure) return;
        emit(AdminCoursesError(failure.message));
      },
      (_) => emit(AdminAccessRevoked(levelId, userId)),
    );
  }

  // ─── Refresh Cache ─────────────────────────────────────────────────────────
  Future<void> refreshCache(int levelId) async {
    emit(const AdminActionLoading());

    final result = await _adminRepo.refreshVideoCache(levelId);

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(AdminCoursesError(failure.message));
      },
      (_) {
        emit(AdminCacheRefreshed(levelId));
        emit(AdminLevelsLoaded(List.unmodifiable(_levels)));
      },
    );
  }
}
