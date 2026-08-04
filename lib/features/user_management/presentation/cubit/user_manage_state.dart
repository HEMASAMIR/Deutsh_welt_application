part of 'user_manage_cubit.dart';

abstract class UserManageState {
  const UserManageState();
}

/// Initial state — no data has been loaded yet.
class UserManageInitial extends UserManageState {
  const UserManageInitial();
}

/// Loading spinner for list fetch or any action.
class UserManageLoading extends UserManageState {
  const UserManageLoading();
}

/// An action (create/update/delete) is in progress — list stays visible.
class UserManageActionLoading extends UserManageState {
  final List<ManagedUserModel> users;
  final String searchQuery;
  final bool? filterActive;
  final bool? filterStaff;
  const UserManageActionLoading({
    required this.users,
    this.searchQuery = '',
    this.filterActive,
    this.filterStaff,
  });
}

/// Users list has been successfully loaded.
class UserManageLoaded extends UserManageState {
  final List<ManagedUserModel> users;
  final String searchQuery;
  final bool? filterActive;  // null = all, true = active, false = inactive
  final bool? filterStaff;   // null = all, true = staff, false = students

  const UserManageLoaded({
    required this.users,
    this.searchQuery = '',
    this.filterActive,
    this.filterStaff,
  });

  List<ManagedUserModel> get filteredUsers {
    var result = users.where((u) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!u.fullName.toLowerCase().contains(q) &&
            !u.email.toLowerCase().contains(q) &&
            !u.username.toLowerCase().contains(q)) {
          return false;
        }
      }
      // Active filter
      if (filterActive != null && u.isActive != filterActive) return false;
      // Staff filter
      if (filterStaff != null && u.isStaff != filterStaff) return false;
      return true;
    }).toList();
    return result;
  }

  UserManageLoaded copyWith({
    List<ManagedUserModel>? users,
    String? searchQuery,
    Object? filterActive = _sentinel,
    Object? filterStaff = _sentinel,
  }) {
    return UserManageLoaded(
      users: users ?? this.users,
      searchQuery: searchQuery ?? this.searchQuery,
      filterActive:
          filterActive == _sentinel ? this.filterActive : filterActive as bool?,
      filterStaff:
          filterStaff == _sentinel ? this.filterStaff : filterStaff as bool?,
    );
  }
}

/// A single user has been successfully fetched.
class UserManageDetailLoaded extends UserManageState {
  final ManagedUserModel user;
  const UserManageDetailLoaded(this.user);
}

/// A user was successfully created.
class UserManageCreated extends UserManageState {
  final ManagedUserModel user;
  const UserManageCreated(this.user);
}

/// A user was successfully updated (PUT or PATCH).
class UserManageUpdated extends UserManageState {
  final ManagedUserModel user;
  const UserManageUpdated(this.user);
}

/// A user was successfully deleted.
class UserManageDeleted extends UserManageState {
  final int userId;
  const UserManageDeleted(this.userId);
}

/// An error occurred.
class UserManageError extends UserManageState {
  final String message;
  const UserManageError(this.message);
}

// Sentinel for nullable copyWith params
const Object _sentinel = Object();
