import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../data/models/managed_user_model.dart';
import '../cubit/user_manage_cubit.dart';

/// Unified Create / Edit screen for Admin User Management.
/// - [user] == null → Create mode (POST)
/// - [user] != null → Edit mode (PUT / PATCH)
class UserManageFormScreen extends StatefulWidget {
  final ManagedUserModel? user;

  const UserManageFormScreen({super.key, this.user});

  @override
  State<UserManageFormScreen> createState() => _UserManageFormScreenState();
}

class _UserManageFormScreenState extends State<UserManageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _passwordCtrl;
  late bool _isActive;
  late bool _isStaff;
  late bool _isSuperuser;
  bool _showPassword = false;
  bool _isSaving = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _usernameCtrl = TextEditingController(text: u?.username ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _firstNameCtrl = TextEditingController(text: u?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: u?.lastName ?? '');
    _phoneCtrl = TextEditingController(text: u?.phoneNumber ?? '');
    _passwordCtrl = TextEditingController();
    _isActive = u?.isActive ?? true;
    _isStaff = u?.isStaff ?? false;
    _isSuperuser = u?.isSuperuser ?? false;
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final cubit = context.read<UserManageCubit>();

    if (_isEditing) {
      // Use PATCH for partial update — only modified fields
      await cubit.partialUpdateUser(
        userId: widget.user!.id,
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        phoneNumber:
            _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        isActive: _isActive,
        isStaff: _isStaff,
        isSuperuser: _isSuperuser,
        password: _passwordCtrl.text.isEmpty ? null : _passwordCtrl.text,
      );
    } else {
      // Create new user
      if (_passwordCtrl.text.isEmpty) {
        CustomSnackBar.show(context,
            message: 'كلمة المرور مطلوبة لإنشاء مستخدم جديد',
            type: SnackBarType.warning);
        setState(() => _isSaving = false);
        return;
      }
      await cubit.createUser(
        CreateUserPayload(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          phoneNumber:
              _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          isActive: _isActive,
          isStaff: _isStaff,
          isSuperuser: _isSuperuser,
        ),
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          _isEditing ? 'تعديل المستخدم' : 'إضافة مستخدم جديد',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocListener<UserManageCubit, UserManageState>(
        listenWhen: (_, s) => s is UserManageError,
        listener: (context, state) {
          if (state is UserManageError) {
            setState(() => _isSaving = false);
            CustomSnackBar.show(context,
                message: state.message, type: SnackBarType.error);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('البيانات الأساسية', Icons.person_rounded),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(
                      child: _buildField(
                    controller: _firstNameCtrl,
                    label: 'الاسم الأول',
                    icon: Icons.badge_outlined,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildField(
                    controller: _lastNameCtrl,
                    label: 'الاسم الأخير',
                    icon: Icons.badge_outlined,
                  )),
                ]),
                const SizedBox(height: 14),
                _buildField(
                  controller: _usernameCtrl,
                  label: 'اسم المستخدم *',
                  icon: Icons.alternate_email_rounded,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني *',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'مطلوب';
                    if (!v.contains('@')) return 'بريد إلكتروني غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                _buildField(
                  controller: _phoneCtrl,
                  label: 'رقم الهاتف',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  _isEditing
                      ? 'كلمة المرور (اتركها فارغة للإبقاء على الحالية)'
                      : 'كلمة المرور *',
                  Icons.lock_outline_rounded,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: !_showPassword,
                  style: GoogleFonts.cairo(fontSize: 14),
                  decoration: _inputDeco(
                    label:
                        _isEditing ? 'كلمة مرور جديدة (اختياري)' : 'كلمة المرور',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                        color: AppColors.primaryBlue,
                      ),
                      onPressed: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  validator: _isEditing
                      ? null
                      : (v) {
                          if (v == null || v.isEmpty) return 'مطلوب';
                          if (v.length < 8) {
                            return 'يجب أن تكون 8 أحرف على الأقل';
                          }
                          return null;
                        },
                ),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    'الصلاحيات والحالة', Icons.admin_panel_settings_outlined),
                const SizedBox(height: 14),
                _buildSwitchCard(
                  label: 'حساب نشط',
                  subtitle: 'يمكن للمستخدم تسجيل الدخول',
                  icon: Icons.toggle_on_rounded,
                  iconColor: AppColors.success,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 10),
                _buildSwitchCard(
                  label: 'مشرف (Staff)',
                  subtitle: 'صلاحية الوصول للوحة الإدارة',
                  icon: Icons.manage_accounts_rounded,
                  iconColor: const Color(0xFF0891B2),
                  value: _isStaff,
                  onChanged: (v) => setState(() => _isStaff = v),
                ),
                const SizedBox(height: 10),
                _buildSwitchCard(
                  label: 'مدير عام (Superuser)',
                  subtitle: 'صلاحيات كاملة بدون قيود',
                  icon: Icons.security_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  value: _isSuperuser,
                  onChanged: (v) => setState(() {
                    _isSuperuser = v;
                    if (v) _isStaff = true;
                  }),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      disabledBackgroundColor:
                          AppColors.primaryBlue.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isEditing
                                    ? Icons.save_rounded
                                    : Icons.person_add_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _isEditing ? 'حفظ التغييرات' : 'إنشاء المستخدم',
                                style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: AppColors.border, height: 1)),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: _inputDeco(label: label, icon: icon),
    );
  }

  InputDecoration _inputDeco({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.textHint),
      prefixIcon: Icon(icon, size: 20, color: AppColors.primaryBlue),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: value ? iconColor.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value ? iconColor.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(subtitle,
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: iconColor,
            activeTrackColor: iconColor.withValues(alpha: 0.35),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
