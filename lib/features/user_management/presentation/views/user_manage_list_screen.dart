import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../data/models/managed_user_model.dart';
import '../cubit/user_manage_cubit.dart';
import 'user_manage_form_screen.dart';

class UserManageListScreen extends StatefulWidget {
  const UserManageListScreen({super.key});

  @override
  State<UserManageListScreen> createState() => _UserManageListScreenState();
}

class _UserManageListScreenState extends State<UserManageListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<UserManageCubit>().fetchUsers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      floatingActionButton: _buildFab(),
      body: BlocConsumer<UserManageCubit, UserManageState>(
        listenWhen: (_, s) =>
            s is UserManageCreated ||
            s is UserManageUpdated ||
            s is UserManageDeleted ||
            s is UserManageError,
        listener: (context, state) {
          if (state is UserManageCreated) {
            CustomSnackBar.show(context,
                message: 'تم إنشاء المستخدم بنجاح ✓',
                type: SnackBarType.success);
          } else if (state is UserManageUpdated) {
            CustomSnackBar.show(context,
                message: 'تم تحديث المستخدم بنجاح ✓',
                type: SnackBarType.success);
          } else if (state is UserManageDeleted) {
            CustomSnackBar.show(context,
                message: 'تم حذف المستخدم بنجاح',
                type: SnackBarType.success);
          } else if (state is UserManageError) {
            CustomSnackBar.show(context,
                message: state.message, type: SnackBarType.error);
          }
        },
        buildWhen: (_, s) =>
            s is UserManageLoading ||
            s is UserManageLoaded ||
            s is UserManageActionLoading ||
            s is UserManageInitial,
        builder: (context, state) {
          if (state is UserManageLoading) return _buildShimmerList();

          if (state is UserManageLoaded || state is UserManageActionLoading) {
            final users = state is UserManageLoaded
                ? state.filteredUsers
                : (state as UserManageActionLoading).users;
            final isActionLoading = state is UserManageActionLoading;
            final loaded = state is UserManageLoaded ? state : null;

            return Column(
              children: [
                _buildSearchAndFilters(context, loaded),
                if (isActionLoading)
                  const LinearProgressIndicator(
                    backgroundColor: Color(0xFFE0E7FF),
                    color: AppColors.primaryBlue,
                    minHeight: 3,
                  ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.primaryBlue,
                    onRefresh: () =>
                        context.read<UserManageCubit>().refresh(),
                    child: users.isEmpty
                        ? _buildEmpty()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: users.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) =>
                                _UserCard(user: users[i]),
                          ),
                  ),
                ),
              ],
            );
          }
          return _buildShimmerList();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('إدارة المستخدمين',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          Text('Admin Only',
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'تحديث',
          onPressed: () => context.read<UserManageCubit>().refresh(),
        ),
      ],
    );
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      onPressed: () => _openForm(context, null),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.person_add_rounded),
      label: Text('مستخدم جديد', style: GoogleFonts.cairo()),
    );
  }

  Widget _buildSearchAndFilters(
      BuildContext context, UserManageLoaded? state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          // Search bar
          TextFormField(
            controller: _searchCtrl,
            style: GoogleFonts.cairo(fontSize: 14),
            onChanged: (q) =>
                context.read<UserManageCubit>().applySearch(q),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم أو الإيميل...',
              hintStyle:
                  GoogleFonts.cairo(fontSize: 13, color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.primaryBlue, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        context.read<UserManageCubit>().applySearch('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'الكل',
                  selected: state?.filterActive == null &&
                      state?.filterStaff == null,
                  onTap: () =>
                      context.read<UserManageCubit>().clearFilters(),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'نشط',
                  selected: state?.filterActive == true,
                  color: AppColors.success,
                  onTap: () => context
                      .read<UserManageCubit>()
                      .applyFilterActive(
                          state?.filterActive == true ? null : true),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'غير نشط',
                  selected: state?.filterActive == false,
                  color: AppColors.error,
                  onTap: () => context
                      .read<UserManageCubit>()
                      .applyFilterActive(
                          state?.filterActive == false ? null : false),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'مشرفين',
                  selected: state?.filterStaff == true,
                  color: const Color(0xFF7C3AED),
                  onTap: () => context
                      .read<UserManageCubit>()
                      .applyFilterStaff(
                          state?.filterStaff == true ? null : true),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'طلاب',
                  selected: state?.filterStaff == false,
                  color: AppColors.primaryBlue,
                  onTap: () => context
                      .read<UserManageCubit>()
                      .applyFilterStaff(
                          state?.filterStaff == false ? null : false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('لا يوجد مستخدمون',
              style: GoogleFonts.cairo(
                  fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => _ShimmerCard(),
    );
  }

  void _openForm(BuildContext context, ManagedUserModel? user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<UserManageCubit>(),
          child: UserManageFormScreen(user: user),
        ),
      ),
    );
  }
}

// ─── User Card ────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final ManagedUserModel user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openEditForm(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(child: _buildInfo()),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    Color avatarColor = AppColors.primaryBlue;
    if (user.isSuperuser) avatarColor = const Color(0xFF7C3AED);
    if (user.isStaff && !user.isSuperuser) {
      avatarColor = const Color(0xFF0891B2);
    }

    return Stack(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: avatarColor.withValues(alpha: 0.12),
          child: Text(
            user.initials,
            style: GoogleFonts.cairo(
              color: avatarColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: user.isActive ? AppColors.success : AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.fullName,
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            _RoleBadge(user: user),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          user.email,
          style: GoogleFonts.cairo(
              fontSize: 12, color: AppColors.textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
          Text(
            user.phoneNumber!,
            style: GoogleFonts.cairo(
                fontSize: 11, color: AppColors.textHint),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_rounded,
              color: AppColors.primaryBlue, size: 20),
          onPressed: () => _openEditForm(context),
          tooltip: 'تعديل',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.error, size: 20),
          onPressed: () => _confirmDelete(context),
          tooltip: 'حذف',
        ),
      ],
    );
  }

  void _openEditForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<UserManageCubit>(),
          child: UserManageFormScreen(user: user),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('تأكيد الحذف',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(
          'هل تريد حذف "${user.fullName}" نهائياً؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<UserManageCubit>().deleteUser(user.id);
            },
            child: Text('حذف',
                style: GoogleFonts.cairo(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Role Badge ───────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final ManagedUserModel user;
  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.primaryBlue;
    if (user.isSuperuser) color = const Color(0xFF7C3AED);
    if (user.isStaff && !user.isSuperuser) color = const Color(0xFF0891B2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        user.roleLabel,
        style: GoogleFonts.cairo(
            fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color = AppColors.primaryBlue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── Shimmer Placeholder Card ─────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _shimmerBox(52, 52, isCircle: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(14, double.infinity),
                  const SizedBox(height: 8),
                  _shimmerBox(11, 180),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double h, double w, {bool isCircle = false}) {
    return Opacity(
      opacity: _anim.value,
      child: Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
              isCircle ? BorderRadius.circular(h) : BorderRadius.circular(6),
        ),
      ),
    );
  }
}
