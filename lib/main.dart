import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/service_locator.dart';
import 'core/network/api_client.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/views/auth_wrapper.dart';
import 'features/home/presentation/views/home_view.dart';
import 'features/dashboard/presentation/views/student_dashboard_view.dart';
import 'features/admin/presentation/views/admin_dashboard_view.dart';
import 'features/home/presentation/views/book_view.dart';
import 'features/admin/presentation/views/admin_book_manage_screen.dart';
import 'features/admin/presentation/cubit/admin_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/cubit/network_cubit.dart';
import 'core/widgets/no_internet_widget.dart';

import 'features/home/presentation/views/course_content_view.dart';
import 'features/home/presentation/views/instructor_bio_view.dart';
import 'features/home/presentation/views/privacy_view.dart';
import 'features/home/presentation/views/profile_view.dart';
import 'features/courses/presentation/views/levels_view.dart';
import 'features/courses/presentation/views/level_videos_view.dart';
import 'features/courses/presentation/views/video_player_view.dart';
import 'features/courses/presentation/views/video_comments_view.dart';
import 'features/courses/presentation/views/admin_levels_view.dart';
import 'features/courses/presentation/views/admin_level_users_view.dart';
import 'features/courses/data/models/video_model.dart';
import 'features/user_management/presentation/views/user_manage_list_screen.dart';
import 'features/user_management/presentation/cubit/user_manage_cubit.dart';
import 'features/admin/presentation/views/admin_app_settings_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/cubit/language_cubit.dart';
import 'core/cubit/theme_cubit.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/services/security_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── Maximize image cache for 5K-quality review display ────────────────────
  PaintingBinding.instance.imageCache.maximumSize = 200;      // max 200 images
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      200 * 1024 * 1024; // 200 MB cache

  // Setup dependency injection
  await setupServiceLocator();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF7F7F7),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<NetworkCubit>(
          create: (context) => NetworkCubit(),
        ),
        BlocProvider<LanguageCubit>(
          create: (context) => sl<LanguageCubit>(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => sl<ThemeCubit>(),
        ),
        BlocProvider<AdminCubit>(
          create: (context) => AdminCubit(),
        ),
      ],
      child: const DeutschWeltApp(),
    ),
  );
}

class DeutschWeltApp extends StatelessWidget {
  const DeutschWeltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        final isArabic = locale.languageCode == 'ar';
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            // Update system UI overlay style based on theme
            final isDark = themeMode == ThemeMode.dark;
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                systemNavigationBarColor:
                    isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F7F7),
                systemNavigationBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
              ),
            );
            return ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (screenUtilContext, screenUtilChild) {
                return MaterialApp(
                  navigatorKey: ApiClient.navigatorKey,
                  title: isArabic
                      ? 'دويتش فيلت - منصة تعلم الألمانية'
                      : 'Deutsch Welt - Akademie',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeMode,
                  locale: locale,
                  supportedLocales: const [
                    Locale('ar'),
                    Locale('de'),
                  ],
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  // Connectivity & Localization support (Dynamic TextDirection)
                  builder: (materialAppContext, materialAppChild) {
                    return BlocBuilder<NetworkCubit, NetworkStatus>(
                      builder: (context, status) {
                        return Directionality(
                          textDirection:
                              isArabic ? TextDirection.rtl : TextDirection.ltr,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Stack(
                              children: [
                                SecureScreenWrapper(
                                  child: materialAppChild!,
                                ),
                                if (status == NetworkStatus.disconnected)
                                  const NoInternetWidget(),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  initialRoute: AppRoutes.home,
                  onGenerateRoute: (settings) {
                    debugPrint('Root Navigator: Navigating to ${settings.name}');
                    switch (settings.name) {
                      case AppRoutes.home:
                        debugPrint('Root Navigator: Building HomeView');
                        return MaterialPageRoute(builder: (_) => const HomeView());
                      case AppRoutes.studentDashboard:
                        return MaterialPageRoute(
                            builder: (_) => const StudentDashboardView());
                      case AppRoutes.adminDashboard:
                        return MaterialPageRoute(
                            builder: (_) => const AdminDashboardView());
                      case AppRoutes.courseContent:
                        final args = settings.arguments as Map<String, dynamic>;
                        return MaterialPageRoute(
                          builder: (_) => CourseContentView(
                            title: args['title'] as String,
                            type: args['type'] as String,
                          ),
                        );
                      case AppRoutes.levels:
                        return MaterialPageRoute(builder: (_) => const LevelsView());
                      case AppRoutes.levelVideos:
                        final args = settings.arguments as Map<String, dynamic>;
                        return MaterialPageRoute(
                          builder: (_) => LevelVideosView(
                            levelId: args['levelId'] as int,
                            levelName: args['levelName'] as String,
                          ),
                        );
                      case AppRoutes.videoPlayer:
                        final args = settings.arguments as Map<String, dynamic>;
                        return MaterialPageRoute(
                          builder: (_) => CourseVideoPlayerView(
                            video: args['video'] as VideoModel,
                            levelId: args['levelId'] as int,
                          ),
                        );
                      case AppRoutes.videoComments:
                        final args = settings.arguments as Map<String, dynamic>;
                        return MaterialPageRoute(
                          builder: (_) => VideoCommentsView(
                            video: args['video'] as VideoModel,
                            levelId: args['levelId'] as int,
                          ),
                        );
                      case AppRoutes.adminLevels:
                        return MaterialPageRoute(builder: (_) => const AdminLevelsView());
                      case AppRoutes.adminLevelUsers:
                        final args = settings.arguments as Map<String, dynamic>;
                        return MaterialPageRoute(
                          builder: (_) => AdminLevelUsersView(
                            levelId: args['levelId'] as int,
                            levelName: args['levelName'] as String,
                          ),
                        );
                      case AppRoutes.instructorBio:
                        return MaterialPageRoute(
                            builder: (_) => const InstructorBioView());
                      case AppRoutes.privacy:
                        return MaterialPageRoute(builder: (_) => const PrivacyView());
                      case AppRoutes.profile:
                        return MaterialPageRoute(builder: (_) => const ProfileView());
                      case AppRoutes.book:
                        return MaterialPageRoute(builder: (_) => const BookView());
                      case AppRoutes.adminBookManage:
                        return MaterialPageRoute(
                            builder: (_) => const AdminBookManageScreen());
                      case AppRoutes.userManage:
                        return MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<UserManageCubit>(),
                            child: const UserManageListScreen(),
                          ),
                        );
                      case AppRoutes.adminAppSettings:
                        return MaterialPageRoute(
                            builder: (_) => const AdminAppSettingsScreen());
                      case AppRoutes.login:
                      case AppRoutes.signUp:
                      case AppRoutes.forgotPassword:
                        return PageRouteBuilder(
                          settings: settings,
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              AuthWrapper(
                                  initialRoute: settings.name ?? AppRoutes.login),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                        );
                      default:
                        return MaterialPageRoute(
                          builder: (_) => const HomeView(),
                        );
                    }
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
