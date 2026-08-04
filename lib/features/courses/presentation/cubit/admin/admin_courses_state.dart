part of 'admin_courses_cubit.dart';

abstract class AdminCoursesState extends Equatable {
  const AdminCoursesState();

  @override
  List<Object?> get props => [];
}

class AdminCoursesInitial extends AdminCoursesState {
  const AdminCoursesInitial();
}

class AdminCoursesLoading extends AdminCoursesState {
  const AdminCoursesLoading();
}

class AdminActionLoading extends AdminCoursesState {
  const AdminActionLoading();
}

// ─── Levels States ─────────────────────────────────────────────────────────────
class AdminLevelsLoaded extends AdminCoursesState {
  final List<AdminLevelModel> levels;
  const AdminLevelsLoaded(this.levels);

  @override
  List<Object?> get props => [levels];
}

class AdminLevelCreated extends AdminCoursesState {
  final AdminLevelModel level;
  const AdminLevelCreated(this.level);

  @override
  List<Object?> get props => [level];
}

class AdminLevelUpdated extends AdminCoursesState {
  final AdminLevelModel level;
  const AdminLevelUpdated(this.level);

  @override
  List<Object?> get props => [level];
}

class AdminLevelDeleted extends AdminCoursesState {
  final int levelId;
  const AdminLevelDeleted(this.levelId);

  @override
  List<Object?> get props => [levelId];
}

// ─── User Access States ────────────────────────────────────────────────────────
class AdminLevelUsersLoaded extends AdminCoursesState {
  final List<UserAccessModel> users;
  final int levelId;
  const AdminLevelUsersLoaded(this.users, this.levelId);

  @override
  List<Object?> get props => [users, levelId];
}

class AdminAccessGranted extends AdminCoursesState {
  final UserAccessModel access;
  const AdminAccessGranted(this.access);

  @override
  List<Object?> get props => [access];
}

class AdminAccessRevoked extends AdminCoursesState {
  final int levelId;
  final int userId;
  const AdminAccessRevoked(this.levelId, this.userId);

  @override
  List<Object?> get props => [levelId, userId];
}

// ─── Cache State ───────────────────────────────────────────────────────────────
class AdminCacheRefreshed extends AdminCoursesState {
  final int levelId;
  const AdminCacheRefreshed(this.levelId);

  @override
  List<Object?> get props => [levelId];
}

// ─── Error State ───────────────────────────────────────────────────────────────
class AdminCoursesError extends AdminCoursesState {
  final String message;
  const AdminCoursesError(this.message);

  @override
  List<Object?> get props => [message];
}
