import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:herr_khaled/features/auth/data/repos/auth_repo.dart';
import 'package:herr_khaled/features/auth/data/repos/auth_repo_impl.dart';
import 'package:herr_khaled/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:herr_khaled/core/network/api_client.dart';
import 'package:herr_khaled/core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:herr_khaled/core/cubit/language_cubit.dart';
import 'package:herr_khaled/core/cubit/theme_cubit.dart';
import 'package:herr_khaled/core/services/secure_storage_service.dart';

// ── Courses Feature ──────────────────────────────────────────────────────────
import 'package:herr_khaled/features/courses/data/repos/courses_repo.dart';
import 'package:herr_khaled/features/courses/data/repos/courses_repo_impl.dart';
import 'package:herr_khaled/features/courses/presentation/cubit/levels/levels_cubit.dart';
import 'package:herr_khaled/features/courses/presentation/cubit/videos/videos_cubit.dart';
import 'package:herr_khaled/features/courses/presentation/cubit/comments/comments_cubit.dart';
import 'package:herr_khaled/features/courses/presentation/cubit/admin/admin_courses_cubit.dart';

// ── Books Feature ────────────────────────────────────────────────────────────
import 'package:herr_khaled/features/books/data/repos/books_repo.dart';
import 'package:herr_khaled/features/books/data/repos/books_repo_impl.dart';
import 'package:herr_khaled/features/books/presentation/cubit/books_cubit.dart';
import 'package:herr_khaled/features/books/presentation/cubit/admin_books_cubit.dart';

// ── User Management Feature ───────────────────────────────────────────────────
import 'package:herr_khaled/features/user_management/data/repos/user_manage_repo.dart';
import 'package:herr_khaled/features/user_management/data/repos/user_manage_repo_impl.dart';
import 'package:herr_khaled/features/user_management/presentation/cubit/user_manage_cubit.dart';
import 'package:herr_khaled/features/user_management/data/repos/user_groups_repo.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ─── External ───────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<StorageService>(() => StorageService(sl()));
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());

  // ─── Network ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<Dio>(() => ApiClient.createDio(sl()));

  // ─── Repositories ──────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      dio: sl<Dio>(),
      storageService: sl<StorageService>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // ─── Courses Repositories ───────────────────────────────────────────────
  sl.registerLazySingleton<CoursesRepo>(
    () => CoursesRepoImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AdminCoursesRepo>(
    () => AdminCoursesRepoImpl(dio: sl<Dio>()),
  );

  // ─── Books Repositories ─────────────────────────────────────────────────
  sl.registerLazySingleton<BooksRepo>(
    () => BooksRepoImpl(dio: sl<Dio>()),
  );
  sl.registerLazySingleton<AdminBooksRepo>(
    () => AdminBooksRepoImpl(dio: sl<Dio>()),
  );

  // ─── User Groups Repository ─────────────────────────────────────────────
  sl.registerLazySingleton<UserGroupsRepo>(
    () => UserGroupsRepoImpl(dio: sl<Dio>()),
  );

  // ─── Cubits ────────────────────────────────────────────────────────────
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(authRepo: sl<AuthRepo>()),
  );
  sl.registerLazySingleton<LanguageCubit>(
    () => LanguageCubit(sl<StorageService>()),
  );
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<StorageService>()),
  );

  // Courses cubits — registerFactory so each screen gets a fresh instance
  sl.registerFactory<LevelsCubit>(
    () => LevelsCubit(coursesRepo: sl<CoursesRepo>()),
  );
  sl.registerFactory<VideosCubit>(
    () => VideosCubit(coursesRepo: sl<CoursesRepo>()),
  );
  sl.registerFactory<CommentsCubit>(
    () => CommentsCubit(coursesRepo: sl<CoursesRepo>()),
  );
  sl.registerFactory<AdminCoursesCubit>(
    () => AdminCoursesCubit(adminRepo: sl<AdminCoursesRepo>()),
  );

  // Books cubits — registerFactory for fresh instances per screen
  sl.registerFactory<BooksCubit>(
    () => BooksCubit(booksRepo: sl<BooksRepo>()),
  );
  sl.registerFactory<AdminBooksCubit>(
    () => AdminBooksCubit(adminBooksRepo: sl<AdminBooksRepo>()),
  );

  // ── User Management ────────────────────────────────────────────────────────
  sl.registerLazySingleton<UserManageRepo>(
    () => UserManageRepoImpl(dio: sl<Dio>()),
  );
  sl.registerFactory<UserManageCubit>(
    () => UserManageCubit(repo: sl<UserManageRepo>()),
  );
}

