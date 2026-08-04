import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../../features/courses/presentation/cubit/levels/levels_cubit.dart';
import '../../../../core/widgets/developer_contact_dialog.dart';
import '../../../../core/cubit/theme_cubit.dart';

class StudentDashboardView extends StatelessWidget {
  const StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LevelsCubit>()..fetchLevels(),
      child: const _StudentDashboardBody(),
    );
  }
}

class _StudentDashboardBody extends StatelessWidget {
  const _StudentDashboardBody();

  Map<String, dynamic>? _getUserData() {
    final userStr = sl<StorageService>().user;
    if (userStr == null) return null;
    try {
      return jsonDecode(userStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = _getUserData();
    final firstName = userData?['first_name'] as String? ?? 'الطالب';
    final lastName = userData?['last_name'] as String? ?? '';
    final email = userData?['email'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    final initials = _getInitials(fullName);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          CustomSnackBar.show(context,
              message: 'تم تسجيل الخروج. إلى اللقاء! 👋',
              type: SnackBarType.success);
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.login, (route) => false);
        } else if (state is LogoutFailure) {
          CustomSnackBar.show(context,
              message: state.message, type: SnackBarType.error);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF172554),
              foregroundColor: Colors.white,
              actions: [
                // Theme toggle button
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) {
                    final isDark = mode == ThemeMode.dark;
                    return IconButton(
                      tooltip: isDark ? 'الوضع الفاتح' : 'الوضع المظلم',
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                    );
                  },
                ),
                // Profile button
                IconButton(
                  tooltip: 'الملف الشخصي',
                  icon: const Icon(Icons.person_outline_rounded),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.profile),
                ),
                // Logout button
                IconButton(
                  tooltip: 'تسجيل الخروج',
                  icon: const Icon(Icons.logout_rounded,
                      color: Colors.white70),
                  onPressed: () =>
                      _confirmLogout(context),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: avatar + greeting
                          Row(
                            children: [
                              FadeInLeft(
                                duration:
                                    const Duration(milliseconds: 500),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Colors.white
                                      .withValues(alpha: 0.15),
                                  child: Text(
                                    initials,
                                    style: GoogleFonts.cairo(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              FadeInRight(
                                duration:
                                    const Duration(milliseconds: 500),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'أهلاً، $firstName 👋',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      email,
                                      style: GoogleFonts.cairo(
                                        color: Colors.white
                                            .withValues(alpha: 0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Status Banner
                          FadeInUp(
                            duration:
                                const Duration(milliseconds: 600),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withValues(alpha: 0.10),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.school_rounded,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'لوحة تحكم الطالب — Deutsch Welt Akademie',
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: BlocBuilder<LevelsCubit, LevelsState>(
            builder: (context, state) {
              if (state is LevelsLoading || state is LevelsInitial) {
                return CustomShimmer.list(count: 4, height: 130);
              }

              if (state is LevelsError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 64, color: AppColors.error),
                        const SizedBox(height: 14),
                        Text(state.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                          onPressed: () => context
                              .read<LevelsCubit>()
                              .fetchLevels(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text('إعادة المحاولة',
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final loaded = state as LevelsLoaded;
              final levels = loaded.levels;
              final activeCount =
                  levels.where((l) => l.hasAccess).length;
              final lockedCount = levels.length - activeCount;

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: () =>
                    context.read<LevelsCubit>().refreshLevels(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    // ─ Quick Stats ─────────────────────────────────
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Row(
                        children: [
                          Expanded(
                            child: _QuickStat(
                              icon: Icons.lock_open_rounded,
                              label: 'مستويات مفتوحة',
                              value: '$activeCount',
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickStat(
                              icon: Icons.lock_rounded,
                              label: 'مستويات مغلقة',
                              value: '$lockedCount',
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickStat(
                              icon: Icons.school_rounded,
                              label: 'إجمالي',
                              value: '${levels.length}',
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ─ Active Courses ────────────────────────────────
                    if (activeCount > 0) ...[
                      FadeInLeft(
                        duration: const Duration(milliseconds: 400),
                        child: _SectionHeader(
                          icon: Icons.play_circle_fill_rounded,
                          title: 'كورساتي المشترك بها 🎓',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...levels
                          .where((l) => l.hasAccess)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) {
                        final idx = e.key;
                        final level = e.value;
                        return FadeInUp(
                          duration: Duration(
                              milliseconds: 400 + idx * 100),
                          child: _LevelCourseCard(
                            level: level,
                            isActive: true,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.levelVideos,
                              arguments: {
                                'levelId': level.id,
                                'levelName': level.name,
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 28),
                    ],

                    // ─ Locked Courses ─────────────────────────────────
                    if (lockedCount > 0) ...[
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        child: _SectionHeader(
                          icon: Icons.lock_outline_rounded,
                          title: 'مستويات غير مشترك بها',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ...levels
                          .where((l) => !l.hasAccess)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) {
                        final idx = e.key;
                        final level = e.value;
                        return FadeInUp(
                          duration: Duration(
                              milliseconds: 500 + idx * 80),
                          child: _LevelCourseCard(
                            level: level,
                            isActive: false,
                            onTap: () {
                              CustomSnackBar.show(
                                context,
                                message:
                                    'مستوى "${level.name}" مغلق. يرجى التواصل مع الإدارة للاشتراك.',
                                type: SnackBarType.warning,
                                title: 'تنبيه الاشتراك',
                              );
                            },
                          ),
                        );
                      }),
                    ],

                    if (levels.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(Icons.school_outlined,
                                size: 72,
                                color: AppColors.textHint
                                    .withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد مستويات متاحة حالياً.',
                              style: GoogleFonts.cairo(
                                  color: AppColors.textSecondary,
                                  fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Center(
                      child: PoweredByDeveloperWidget(isDarkBackground: false),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '؟';
    if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    if (parts[0].isEmpty) return '؟';
    return '${parts[0][0]}${parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : ''}'
        .toUpperCase();
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Text('تسجيل الخروج',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
          style: GoogleFonts.cairo(
              color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء',
                style:
                    GoogleFonts.cairo(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              final refreshToken =
                  sl<StorageService>().refreshToken ?? '';
              context
                  .read<AuthCubit>()
                  .logout(refresh: refreshToken);
            },
            child: Text('تسجيل الخروج',
                style:
                    GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Stat Widget ────────────────────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.12), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Section Header Widget ────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Divider(
                color: AppColors.border.withValues(alpha: 0.6),
                height: 1)),
      ],
    );
  }
}

// ─── Level Course Card ────────────────────────────────────────────────────────
class _LevelCourseCard extends StatelessWidget {
  final dynamic level; // LevelModel
  final bool isActive;
  final VoidCallback onTap;

  const _LevelCourseCard({
    required this.level,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isActive
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Level badge circle
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: (isActive
                            ? AppColors.success
                            : AppColors.textSecondary)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isActive
                        ? const Icon(Icons.play_circle_fill_rounded,
                            color: AppColors.success, size: 30)
                        : Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_rounded,
                                  color: AppColors.textSecondary,
                                  size: 18),
                              Text(
                                level.name.toUpperCase(),
                                style: GoogleFonts.cairo(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            level.name.toUpperCase(),
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: isActive
                                  ? AppColors.primaryBlue
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.success
                                      .withValues(alpha: 0.1)
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isActive ? 'نشط' : 'مغلق',
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.description,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isActive &&
                          level.formattedPrice.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          level.formattedPrice,
                          style: GoogleFonts.cairo(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isActive
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.lock_outline_rounded,
                  color: isActive
                      ? AppColors.textHint.withValues(alpha: 0.6)
                      : AppColors.textHint.withValues(alpha: 0.4),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
