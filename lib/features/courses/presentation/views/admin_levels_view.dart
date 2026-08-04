import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../data/models/level_model.dart';
import '../cubit/admin/admin_courses_cubit.dart';

/// Admin-only screen: full management of German levels (CRUD + grant/revoke).
class AdminLevelsView extends StatelessWidget {
  const AdminLevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminCoursesCubit>()..fetchAdminLevels(),
      child: const _AdminLevelsBody(),
    );
  }
}

class _AdminLevelsBody extends StatelessWidget {
  const _AdminLevelsBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF172554),
        foregroundColor: Colors.white,
        title: Text(
          'إدارة مستويات الكورسات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: 'إضافة مستوى جديد',
            icon: const Icon(Icons.add_rounded),
            onPressed: () =>
                _showLevelForm(context, context.read<AdminCoursesCubit>()),
          ),
        ],
      ),
      body: BlocConsumer<AdminCoursesCubit, AdminCoursesState>(
        listener: (context, state) {
          if (state is AdminCoursesError) {
            CustomSnackBar.show(context,
                message: state.message, type: SnackBarType.error);
          }
          if (state is AdminCacheRefreshed) {
            CustomSnackBar.show(context,
                message: 'تم تحديث قائمة الفيديوهات بنجاح. ✅',
                type: SnackBarType.success);
          }
          if (state is AdminLevelCreated) {
            CustomSnackBar.show(context,
                message: 'تم إنشاء المستوى "${state.level.name}" بنجاح.',
                type: SnackBarType.success);
          }
          if (state is AdminLevelUpdated) {
            CustomSnackBar.show(context,
                message: 'تم تحديث المستوى "${state.level.name}" بنجاح.',
                type: SnackBarType.success);
          }
          if (state is AdminLevelDeleted) {
            CustomSnackBar.show(context,
                message: 'تم حذف المستوى بنجاح.',
                type: SnackBarType.success);
          }
        },
        builder: (context, state) {
          if (state is AdminCoursesLoading || state is AdminCoursesInitial) {
            return CustomShimmer.list(count: 4, height: 120);
          }

          if (state is! AdminLevelsLoaded) {
            if (state is AdminCoursesError) {
              return _ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<AdminCoursesCubit>().fetchAdminLevels(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }

          final levels = state.levels;

          if (levels.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_outlined,
                      size: 72,
                      color: AppColors.textHint.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('لا توجد مستويات حتى الآن.',
                      style: GoogleFonts.cairo(
                          color: AppColors.textSecondary, fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showLevelForm(
                        context, context.read<AdminCoursesCubit>()),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text('إضافة أول مستوى',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: () =>
                context.read<AdminCoursesCubit>().fetchAdminLevels(),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final level = levels[index];
                return FadeInUp(
                  duration: Duration(milliseconds: 300 + index * 80),
                  child: _LevelCard(
                    level: level,
                    onEdit: () => _showLevelForm(
                        context, context.read<AdminCoursesCubit>(),
                        existing: level),
                    onDelete: () => _confirmDelete(
                        context, context.read<AdminCoursesCubit>(), level),
                    onRefreshCache: () => context
                        .read<AdminCoursesCubit>()
                        .refreshCache(level.id),
                    onManageUsers: () => Navigator.pushNamed(
                      context,
                      AppRoutes.adminLevelUsers,
                      arguments: {
                        'levelId': level.id,
                        'levelName': level.name,
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<AdminCoursesCubit, AdminCoursesState>(
        buildWhen: (_, s) => s is AdminLevelsLoaded,
        builder: (context, state) {
          if (state is! AdminLevelsLoaded) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            onPressed: () =>
                _showLevelForm(context, context.read<AdminCoursesCubit>()),
            icon: const Icon(Icons.add_rounded),
            label: Text('مستوى جديد',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  // ─── Create / Edit Form Dialog ─────────────────────────────────────────────
  void _showLevelForm(BuildContext context, AdminCoursesCubit cubit,
      {AdminLevelModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final priceCtrl = TextEditingController(text: existing?.price ?? '');
    final oldPriceCtrl =
        TextEditingController(text: existing?.oldPrice ?? '');
    final bunnyCtrl =
        TextEditingController(text: existing?.bunnyCollectionId ?? '');
    final orderCtrl =
        TextEditingController(text: (existing?.order ?? 1).toString());
    bool isActive = existing?.isActive ?? true;
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  existing != null
                      ? Icons.edit_rounded
                      : Icons.add_circle_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                existing != null ? 'تعديل المستوى' : 'إضافة مستوى جديد',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _dialogField(nameCtrl, 'الاسم المختصر (e.g. A1)',
                        Icons.label_outline_rounded,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'مطلوب' : null),
                    const SizedBox(height: 12),
                    _dialogField(titleCtrl, 'العنوان الكامل',
                        Icons.title_rounded,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'مطلوب' : null),
                    const SizedBox(height: 12),
                    _dialogField(descCtrl, 'وصف المستوى',
                        Icons.description_outlined,
                        maxLines: 3),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: _dialogField(
                              priceCtrl, 'السعر', Icons.sell_outlined,
                              keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _dialogField(oldPriceCtrl, 'السعر القديم',
                              Icons.money_off_rounded,
                              keyboardType: TextInputType.number)),
                    ]),
                    const SizedBox(height: 12),
                    _dialogField(bunnyCtrl, 'Bunny Collection ID',
                        Icons.video_library_outlined),
                    const SizedBox(height: 12),
                    _dialogField(
                        orderCtrl, 'الترتيب', Icons.sort_rounded,
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    // Active toggle
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success.withValues(alpha: 0.06)
                            : AppColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isActive
                                ? AppColors.success.withValues(alpha: 0.2)
                                : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.toggle_on_rounded,
                              color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text('المستوى نشط',
                                  style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13))),
                          Switch(
                            value: isActive,
                            activeThumbColor: AppColors.success,
                            activeTrackColor:
                                AppColors.success.withValues(alpha: 0.3),
                            onChanged: (v) =>
                                setDialogState(() => isActive = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('إلغاء',
                  style: GoogleFonts.cairo(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final data = {
                  'name': nameCtrl.text.trim(),
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  if (priceCtrl.text.trim().isNotEmpty)
                    'price': priceCtrl.text.trim(),
                  if (oldPriceCtrl.text.trim().isNotEmpty)
                    'old_price': oldPriceCtrl.text.trim(),
                  if (bunnyCtrl.text.trim().isNotEmpty)
                    'bunny_collection_id': bunnyCtrl.text.trim(),
                  'order': int.tryParse(orderCtrl.text.trim()) ?? 1,
                  'is_active': isActive,
                };
                Navigator.pop(dialogContext);
                if (existing != null) {
                  cubit.updateLevel(existing.id, data);
                } else {
                  cubit.createLevel(data);
                }
              },
              child: Text(
                existing != null ? 'حفظ التغييرات' : 'إنشاء المستوى',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.cairo(fontSize: 12, color: AppColors.textHint),
        prefixIcon: Icon(icon, size: 18, color: AppColors.primaryBlue),
        filled: true,
        fillColor: AppColors.backgroundLight,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryBlue, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // ─── Confirm Delete Dialog ─────────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context,
      AdminCoursesCubit cubit, AdminLevelModel level) async {
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
              child:
                  const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: 12),
            Text('حذف المستوى',
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف مستوى "${level.name}"؟\nسيتم حذف جميع البيانات المرتبطة به نهائياً.',
          style: GoogleFonts.cairo(
              color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child:
                Text('حذف نهائي', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true) cubit.deleteLevel(level.id);
  }
}

// ─── Level Card ───────────────────────────────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final AdminLevelModel level;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefreshCache;
  final VoidCallback onManageUsers;

  const _LevelCard({
    required this.level,
    required this.onEdit,
    required this.onDelete,
    required this.onRefreshCache,
    required this.onManageUsers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          color: level.isActive
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Badge + Name + Status
            Row(
              children: [
                // Level Badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      level.name.toUpperCase(),
                      style: GoogleFonts.cairo(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.description,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Active status chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: level.isActive
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    level.isActive ? 'نشط' : 'مُعطَّل',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: level.isActive
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Stats Row
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.people_alt_rounded,
                    label: 'الطلاب',
                    value: '${level.accessCount}',
                    color: const Color(0xFF0891B2),
                  ),
                  const _StatDivider(),
                  _StatItem(
                    icon: Icons.sell_outlined,
                    label: 'السعر',
                    value: level.formattedPrice.isEmpty
                        ? 'مجاني'
                        : level.formattedPrice,
                    color: AppColors.primaryBlue,
                  ),
                  const _StatDivider(),
                  _StatItem(
                    icon: Icons.format_list_numbered_rounded,
                    label: 'الترتيب',
                    value: '#${level.order}',
                    color: const Color(0xFF7C3AED),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Actions Row
            Row(
              children: [
                // Manage Users
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onManageUsers,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: BorderSide(
                          color: AppColors.primaryBlue.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    icon:
                        const Icon(Icons.manage_accounts_rounded, size: 16),
                    label: Text('إدارة الطلاب',
                        style: GoogleFonts.cairo(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                // Refresh Cache
                IconButton(
                  tooltip: 'تحديث الفيديوهات',
                  onPressed: onRefreshCache,
                  icon: const Icon(Icons.sync_rounded, size: 20),
                  color: const Color(0xFF0891B2),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF0891B2).withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 6),
                // Edit
                IconButton(
                  tooltip: 'تعديل المستوى',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppColors.primaryBlue,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryBlue.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(width: 6),
                // Delete
                IconButton(
                  tooltip: 'حذف المستوى',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: AppColors.error,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppColors.error.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.textPrimary)),
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30,
        color: AppColors.border,
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.error, size: 64),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                    color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('إعادة المحاولة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
