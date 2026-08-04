import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../data/models/user_access_model.dart';
import '../cubit/admin/admin_courses_cubit.dart';

/// Admin-only: View & manage students who have access to a specific level.
class AdminLevelUsersView extends StatelessWidget {
  final int levelId;
  final String levelName;
  const AdminLevelUsersView(
      {super.key, required this.levelId, required this.levelName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminCoursesCubit>()..fetchLevelUsers(levelId),
      child: _AdminLevelUsersBody(levelId: levelId, levelName: levelName),
    );
  }
}

class _AdminLevelUsersBody extends StatelessWidget {
  final int levelId;
  final String levelName;
  const _AdminLevelUsersBody(
      {required this.levelId, required this.levelName});

  void _showGrantDialog(BuildContext context, AdminCoursesCubit cubit) {
    final userIdCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_add_alt_1_rounded,
                  color: AppColors.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'منح صلاحية: $levelName',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أدخل رقم المستخدم (ID) الذي تريد منحه صلاحية الوصول لهذا المستوى.',
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: userIdCtrl,
                keyboardType: TextInputType.number,
                style: GoogleFonts.cairo(fontSize: 14),
                decoration: InputDecoration(
                  labelText: 'رقم المستخدم (User ID) *',
                  labelStyle: GoogleFonts.cairo(
                      fontSize: 12, color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.tag_rounded,
                      size: 18, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primaryBlue, width: 1.5),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'مطلوب';
                  if (int.tryParse(v.trim()) == null) {
                    return 'يجب أن يكون رقماً صحيحاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesCtrl,
                maxLines: 2,
                style: GoogleFonts.cairo(fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'ملاحظات الدفع (اختياري)',
                  labelStyle: GoogleFonts.cairo(
                      fontSize: 12, color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.notes_rounded,
                      size: 18, color: AppColors.primaryBlue),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء',
                style:
                    GoogleFonts.cairo(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final userId = int.parse(userIdCtrl.text.trim());
              final notes = notesCtrl.text.trim();
              Navigator.pop(context);
              cubit.grantAccess(
                levelId: levelId,
                userId: userId,
                notes: notes.isEmpty ? null : notes,
              );
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text('منح الصلاحية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRevoke(BuildContext context, AdminCoursesCubit cubit,
      UserAccessModel user) async {
    final confirmed = await showDialog<bool>(
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
              child: const Icon(Icons.person_remove_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Text('سحب الصلاحية',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'هل تريد سحب صلاحية وصول "${user.userFullName}" من مستوى $levelName؟',
          style: GoogleFonts.cairo(
              color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
            onPressed: () => Navigator.pop(context, true),
            child: Text('سحب الصلاحية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      cubit.revokeAccess(levelId: levelId, userId: user.user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF172554),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طلاب مستوى $levelName',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'إدارة صلاحيات الوصول',
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'منح صلاحية جديدة',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () => _showGrantDialog(
                context, context.read<AdminCoursesCubit>()),
          ),
        ],
      ),
      body: BlocConsumer<AdminCoursesCubit, AdminCoursesState>(
        listener: (context, state) {
          if (state is AdminCoursesError) {
            CustomSnackBar.show(context,
                message: state.message, type: SnackBarType.error);
          }
          if (state is AdminAccessGranted) {
            CustomSnackBar.show(
              context,
              message:
                  'تم منح الصلاحية لـ "${state.access.userFullName}" بنجاح. ✅',
              type: SnackBarType.success,
            );
          }
          if (state is AdminAccessRevoked) {
            CustomSnackBar.show(
              context,
              message: 'تم سحب الصلاحية بنجاح.',
              type: SnackBarType.success,
            );
          }
        },
        builder: (context, state) {
          if (state is AdminCoursesLoading || state is AdminCoursesInitial) {
            return CustomShimmer.list(count: 5, height: 90);
          }

          if (state is AdminCoursesError && state is! AdminLevelUsersLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 52),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style:
                          GoogleFonts.cairo(color: AppColors.textSecondary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AdminCoursesCubit>()
                        .fetchLevelUsers(levelId),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is! AdminLevelUsersLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = state.users;

          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded,
                      size: 72,
                      color:
                          AppColors.textHint.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'لا يوجد طلاب مشتركون في هذا المستوى.',
                    style: GoogleFonts.cairo(
                        color: AppColors.textSecondary, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showGrantDialog(
                        context, context.read<AdminCoursesCubit>()),
                    icon: const Icon(Icons.person_add_alt_1_rounded,
                        size: 18),
                    label: Text('منح أول صلاحية',
                        style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header stats banner
              Container(
                color: const Color(0xFF172554),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.people_alt_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${users.length} طالب مشترك',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primaryBlue,
                  onRefresh: () => context
                      .read<AdminCoursesCubit>()
                      .fetchLevelUsers(levelId),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final initials = _getInitials(user.userFullName);
                      final avatarColor = _getColor(user.userFullName);
                      return FadeInUp(
                        duration: Duration(
                            milliseconds: 300 + index * 60),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                                color: AppColors.border, width: 1.2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: avatarColor
                                      .withValues(alpha: 0.12),
                                  child: Text(
                                    initials,
                                    style: TextStyle(
                                      color: avatarColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.userFullName.isEmpty
                                            ? 'مستخدم ${user.user}'
                                            : user.userFullName,
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.userEmail,
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_rounded,
                                            size: 11,
                                            color: AppColors.textHint,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'منذ: ${_formatDate(user.grantedAt)}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 10,
                                              color: AppColors.textHint,
                                            ),
                                          ),
                                          if (user.notes != null &&
                                              user.notes!.isNotEmpty) ...[
                                            const SizedBox(width: 10),
                                            Icon(Icons.notes_rounded,
                                                size: 11,
                                                color:
                                                    AppColors.textHint),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                user.notes!,
                                                style: GoogleFonts.cairo(
                                                  fontSize: 10,
                                                  color: AppColors.textHint,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Revoke button
                                IconButton(
                                  tooltip: 'سحب الصلاحية',
                                  onPressed: () => _confirmRevoke(
                                    context,
                                    context.read<AdminCoursesCubit>(),
                                    user,
                                  ),
                                  icon: const Icon(
                                      Icons.person_remove_rounded,
                                      size: 18),
                                  color: AppColors.error,
                                  style: IconButton.styleFrom(
                                    backgroundColor: AppColors.error
                                        .withValues(alpha: 0.08),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<AdminCoursesCubit, AdminCoursesState>(
        buildWhen: (_, s) => s is AdminLevelUsersLoaded,
        builder: (context, state) {
          if (state is! AdminLevelUsersLoaded) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            onPressed: () => _showGrantDialog(
                context, context.read<AdminCoursesCubit>()),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text('منح صلاحية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || name.trim().isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getColor(String name) {
    final colors = [
      const Color(0xFF1E3A8A),
      const Color(0xFF0D9488),
      const Color(0xFF7C3AED),
      const Color(0xFFB45309),
      const Color(0xFFDB2777),
      const Color(0xFF0369A1),
    ];
    final index = name.codeUnits
            .fold<int>(0, (prev, e) => prev + e) %
        colors.length;
    return colors[index];
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
