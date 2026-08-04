import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/managed_user_model.dart';
import '../../data/repos/user_manage_repo.dart';

part 'user_manage_state.dart';

/// Cubit that manages the full Admin User Management lifecycle.
///
/// Responsibilities:
/// - Fetch & filter user list
/// - Create / Read / Update (PUT + PATCH) / Delete users
/// - Optimistic UI updates where possible
class UserManageCubit extends Cubit<UserManageState> {
  final UserManageRepo _repo;

  UserManageCubit({required UserManageRepo repo})
      : _repo = repo,
        super(const UserManageInitial());

  // ─── Fetch List ─────────────────────────────────────────────────────────────

  Future<void> fetchUsers({
    String? search,
    bool? isActive,
    bool? isStaff,
  }) async {
    emit(const UserManageLoading());

    final result = await _repo.listUsers(
      search: search,
      isActive: isActive,
      isStaff: isStaff,
    );

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(UserManageError(failure.message));
      },
      (users) => emit(UserManageLoaded(
        users: users,
        searchQuery: search ?? '',
        filterActive: isActive,
        filterStaff: isStaff,
      )),
    );
  }

  // ─── Refresh (pull to refresh) ──────────────────────────────────────────────

  Future<void> refresh() async {
    String query = '';
    bool? filterActive;
    bool? filterStaff;

    if (state is UserManageLoaded) {
      final s = state as UserManageLoaded;
      query = s.searchQuery;
      filterActive = s.filterActive;
      filterStaff = s.filterStaff;
    }

    await fetchUsers(
      search: query.isNotEmpty ? query : null,
      isActive: filterActive,
      isStaff: filterStaff,
    );
  }

  // ─── Client-side Filtering ──────────────────────────────────────────────────

  void applySearch(String query) {
    if (state is UserManageLoaded) {
      emit((state as UserManageLoaded).copyWith(searchQuery: query));
    }
  }

  void applyFilterActive(bool? isActive) {
    if (state is UserManageLoaded) {
      emit((state as UserManageLoaded)
          .copyWith(filterActive: isActive));
    }
  }

  void applyFilterStaff(bool? isStaff) {
    if (state is UserManageLoaded) {
      emit((state as UserManageLoaded).copyWith(filterStaff: isStaff));
    }
  }

  void clearFilters() {
    if (state is UserManageLoaded) {
      emit((state as UserManageLoaded).copyWith(
        searchQuery: '',
        filterActive: null,
        filterStaff: null,
      ));
    }
  }

  // ─── Get User Details ────────────────────────────────────────────────────────

  Future<void> fetchUserDetails(int userId) async {
    emit(const UserManageLoading());

    final result = await _repo.getUserDetails(userId);

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(UserManageError(failure.message));
      },
      (user) => emit(UserManageDetailLoaded(user)),
    );
  }

  // ─── Create User ─────────────────────────────────────────────────────────────

  Future<void> createUser(CreateUserPayload payload) async {
    final currentUsers = _currentUsers();

    emit(UserManageActionLoading(
      users: currentUsers,
      searchQuery: _currentSearchQuery(),
      filterActive: _currentFilterActive(),
      filterStaff: _currentFilterStaff(),
    ));

    final result = await _repo.createUser(payload);

    result.fold(
      (failure) {
        // Restore list on error
        emit(UserManageLoaded(
          users: currentUsers,
          searchQuery: _currentSearchQuery(),
          filterActive: _currentFilterActive(),
          filterStaff: _currentFilterStaff(),
        ));
        if (failure is UnauthorizedFailure) return;
        emit(UserManageError(failure.message));
      },
      (newUser) {
        final updatedList = [newUser, ...currentUsers];
        emit(UserManageLoaded(
          users: updatedList,
          searchQuery: _currentSearchQuery(),
          filterActive: _currentFilterActive(),
          filterStaff: _currentFilterStaff(),
        ));
        emit(UserManageCreated(newUser));
      },
    );
  }

  // ─── Update User (PUT) ───────────────────────────────────────────────────────

  Future<void> updateUser({
    required int userId,
    required ManagedUserModel user,
    String? newPassword,
  }) async {
    final currentUsers = _currentUsers();

    emit(UserManageActionLoading(
      users: currentUsers,
      searchQuery: _currentSearchQuery(),
      filterActive: _currentFilterActive(),
      filterStaff: _currentFilterStaff(),
    ));

    final result = await _repo.updateUser(
      userId: userId,
      user: user,
      newPassword: newPassword,
    );

    result.fold(
      (failure) {
        emit(UserManageLoaded(
          users: currentUsers,
          searchQuery: _currentSearchQuery(),
          filterActive: _currentFilterActive(),
          filterStaff: _currentFilterStaff(),
        ));
        if (failure is UnauthorizedFailure) return;
        emit(UserManageError(failure.message));
      },
      (updatedUser) {
        final updatedList = currentUsers
            .map((u) => u.id == updatedUser.id ? updatedUser : u)
            .toList();
        emit(UserManageLoaded(
          users: updatedList,
          searchQuery: _currentSearchQuery(),
          filterActive: _currentFilterActive(),
          filterStaff: _currentFilterStaff(),
        ));
        emit(UserManageUpdated(updatedUser));
      },
    );
  }

  // ─── Partial Update User (PATCH) ─────────────────────────────────────────────

  Future<void> partialUpdateUser({
    required int userId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isActive,
    bool? isStaff,
    bool? isSuperuser,
    String? password,
  }) async {
    final currentUsers = _currentUsers();

    emit(UserManageActionLoading(
      users: currentUsers,
      searchQuery: _currentSearchQuery(),
      filterActive: _currentFilterActive(),
      filterStaff: _currentFilterStaff(),
    ));

    final result = await _repo.partialUpdateUser(
      userId: userId,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      isActive: isActive,
      isStaff: isStaff,
      isSuperuser: isSuperuser,
      password: password,
    );

    result.fold(
      (failure) {
        emit(UserManageLoaded(
          users: currentUsers,
          searchQuery: _currentSearchQuery(),
          filterActive: _currentFilterActive(),
          filterStaff: _currentFilterStaff(),
        ));
        if (failure is UnauthorizedFailure) return;
        emit(UserManageError(failure.message));
      },
      (updatedUser) {
        final updatedList = currentUsers
            .map((u) => u.id == updatedUser.id ? updatedUser : u)
            .toList();
        emit(UserManageLoaded(
          users: updatedList,
          searchQuery: _currentSearchQuery(),
          filterActive: _currentFilterActive(),
          filterStaff: _currentFilterStaff(),
        ));
        emit(UserManageUpdated(updatedUser));
      },
    );
  }

  // ─── Delete User ─────────────────────────────────────────────────────────────

  Future<void> deleteUser(int userId) async {
    final currentUsers = _currentUsers();

    // Optimistic removal from the list immediately
    final optimisticList =
        currentUsers.where((u) => u.id != userId).toList();

    emit(UserManageLoaded(
      users: optimisticList,
      searchQuery: _currentSearchQuery(),
      filterActive: _currentFilterActive(),
      filterStaff: _currentFilterStaff(),
    ));

    final result = await _repo.deleteUser(userId);

    result.fold(
      (failure) {
        // Rollback on error
        emit(UserManageLoaded(
          users: currentUsers,
          searchQuery: _currentSearchQuery(),
          filterActive: _currentFilterActive(),
          filterStaff: _currentFilterStaff(),
        ));
        if (failure is UnauthorizedFailure) return;
        emit(UserManageError(failure.message));
      },
      (_) => emit(UserManageDeleted(userId)),
    );
  }

  // ─── Assign Groups ────────────────────────────────────────────────────────────

  Future<void> assignUserGroups({
    required int userId,
    required List<String> groups,
  }) async {
    final result = await _repo.assignUserGroups(userId: userId, groups: groups);

    result.fold(
      (failure) {
        if (failure is UnauthorizedFailure) return;
        emit(UserManageError(failure.message));
      },
      (_) => refresh(),
    );
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────────


  List<ManagedUserModel> _currentUsers() {
    if (state is UserManageLoaded) return (state as UserManageLoaded).users;
    if (state is UserManageActionLoading) {
      return (state as UserManageActionLoading).users;
    }
    return [];
  }

  String _currentSearchQuery() {
    if (state is UserManageLoaded) return (state as UserManageLoaded).searchQuery;
    if (state is UserManageActionLoading) {
      return (state as UserManageActionLoading).searchQuery;
    }
    return '';
  }

  bool? _currentFilterActive() {
    if (state is UserManageLoaded) return (state as UserManageLoaded).filterActive;
    if (state is UserManageActionLoading) {
      return (state as UserManageActionLoading).filterActive;
    }
    return null;
  }

  bool? _currentFilterStaff() {
    if (state is UserManageLoaded) return (state as UserManageLoaded).filterStaff;
    if (state is UserManageActionLoading) {
      return (state as UserManageActionLoading).filterStaff;
    }
    return null;
  }
}
