import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/auth/data/repos/auth_repo.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/cubit/theme_cubit.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    final result = await sl<AuthRepo>().getCurrentUser();
    result.fold(
      (failure) => debugPrint('Profile refresh failed: ${failure.message}'),
      (user) async {
        final oldUserStr = sl<StorageService>().user;
        if (oldUserStr != null) {
          final Map<String, dynamic> oldData = jsonDecode(oldUserStr);
          final Map<String, dynamic> newData = user.toJson();

          // CRITICAL: NEVER overwrite a valid email with an empty one from a partial API
          if ((newData['email'] == null || newData['email'] == '') &&
              (oldData['email'] != null && oldData['email'] != '')) {
            newData['email'] = oldData['email'];
          }

          // Same for ID and other critical fields the API might omit
          if (newData['id'] == 0 && oldData['id'] != 0) {
            newData['id'] = oldData['id'];
          }
          if (newData['is_active'] == false && oldData['isActive'] == true) {
            newData['is_active'] = true;
          }

          await sl<StorageService>().saveUser(jsonEncode(newData));
        } else {
          await sl<StorageService>().saveUser(jsonEncode(user.toJson()));
        }
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userStr = sl<StorageService>().user;
    final userData = userStr != null ? jsonDecode(userStr) : null;
    final firstName = userData?['first_name'] ?? context.translate('user_fallback');
    final lastName = userData?['last_name'] ?? '';
    final email = userData?['email'] ?? 'No Email';
    final phone = userData?['phone_number'] ?? context.translate('no_phone');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          context.translate('profile'),
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                FadeInDown(
                  child: _buildProfileHeader(firstName, lastName, userData),
                ),
                const SizedBox(height: 30),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child:
                      _buildInfoCard(context.translate('email'), email, Icons.email_outlined),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child:
                      _buildInfoCard(context.translate('phone'), phone, Icons.phone_outlined),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: _buildInfoCard(
                      context.translate('account_status'), context.translate('active_status'), Icons.check_circle_outline),
                ),
                FadeInUp(
                  delay: const Duration(milliseconds: 700),
                  child: _buildThemeToggleTile(context),
                ),
                const SizedBox(height: 40),
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => _showEditProfileDialog(firstName, phone),
                    child: Text(
                      context.translate('edit_profile'),
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  delay: const Duration(milliseconds: 900),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _showChangePasswordDialog,
                    child: Text(
                      context.translate('change_password'),
                      style: GoogleFonts.cairo(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isUpdating)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
      String first, String last, Map<String, dynamic>? userData) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          backgroundImage: userData?['profile_photo'] != null
              ? NetworkImage(userData!['profile_photo'])
              : const AssetImage('assets/images/deutsch_welt.jpeg')
                  as ImageProvider,
        ),
      ),
      const SizedBox(height: 20),
      Text(
        '$first $last',
        style: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    ]);
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleTile(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark;
        final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              tileColor: cardColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            title: Text(
              isDark
                  ? context.translate('dark_mode')
                  : context.translate('light_mode'),
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: textColor,
              ),
            ),
            subtitle: Text(
              isDark ? 'الوضع المظلم مفعّل' : 'الوضع الفاتح مفعّل',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
              activeTrackColor: AppColors.primaryBlue,
            ),
          ),
        ),
        );
      },
    );
  }

  void _showEditProfileDialog(String currentName, String currentPhone) {
    final nameController = TextEditingController(text: currentName);
    final phoneController = TextEditingController(text: currentPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.translate('edit_personal_info'),
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 25),
            _buildTextField(
                nameController, context.translate('first_name'), Icons.person_outline),
            const SizedBox(height: 15),
            _buildTextField(phoneController, context.translate('phone'), Icons.phone_outlined,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () async {
                Navigator.pop(context);
                await _updateProfile(nameController.text, phoneController.text);
              },
              child: Text(
                context.translate('save_edits'),
                style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  Future<void> _updateProfile(String name, String phone) async {
    setState(() => _isUpdating = true);

    final result = await sl<AuthRepo>().updateProfile(name: name, phone: phone);

    setState(() => _isUpdating = false);

    result.fold(
      (failure) => CustomSnackBar.show(
        context,
        message: context.translate('update_failed'),
        type: SnackBarType.error,
      ),
      (updatedUser) async {
        // Save full updated user from server
        await sl<StorageService>().saveUser(jsonEncode(updatedUser.toJson()));

        if (mounted) {
          CustomSnackBar.show(
            context,
            message: context.translate('update_success'),
            type: SnackBarType.success,
          );
          // Refresh the UI
          setState(() {});
        }
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 30,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.translate('change_password'),
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 25),
                
                // Old Password
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: obscureOld,
                  validator: (value) {
                    if (value == null || value.isEmpty) return context.translate('field_required');
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: context.translate('current_password'),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                    suffixIcon: IconButton(
                      icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setModalState(() => obscureOld = !obscureOld),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // New Password
                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  validator: (value) {
                    if (value == null || value.isEmpty) return context.translate('field_required');
                    if (value.length < 8) return context.translate('password_min_length');
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: context.translate('new_password'),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setModalState(() => obscureNew = !obscureNew),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  validator: (value) {
                    if (value == null || value.isEmpty) return context.translate('field_required');
                    if (value != newPasswordController.text) return context.translate('passwords_dont_match');
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: context.translate('confirm_new_password'),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryBlue),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      await _changePassword(oldPasswordController.text, newPasswordController.text);
                    }
                  },
                  child: Text(
                    context.translate('update_password'),
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    setState(() => _isUpdating = true);

    final result = await sl<AuthRepo>().changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    setState(() => _isUpdating = false);

    result.fold(
      (failure) => CustomSnackBar.show(
        context,
        message: failure.message.isNotEmpty ? failure.message : context.translate('password_change_failed'),
        type: SnackBarType.error,
      ),
      (_) {
        CustomSnackBar.show(
          context,
          message: context.translate('password_change_success'),
          type: SnackBarType.success,
        );
      },
    );
  }
}
