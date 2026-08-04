import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/auth/data/repos/auth_repo.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_switcher_dialog.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../features/auth/presentation/widgets/logout_dialog.dart';
import '../../../../core/widgets/developer_contact_dialog.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  Future<void> _openWhatsApp(BuildContext context) async {
    final Uri whatsappUrl = Uri.parse(
        'https://wa.me/201234567890?text=مرحباً%20أحتاج%20للاجتماع%20الأكاديمي');
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'لا يمكن فتح واتساب في هذا الجهاز.',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    return Drawer(
      backgroundColor: drawerBg,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: context.translate('admin_dashboard'),
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.manage_accounts_rounded,
                  label: '👥 إدارة المستخدمين والطلاب (Admin Only)',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.userManage);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.library_books_rounded,
                  label: context.translate('course_management'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.adminLevels);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.menu_book_rounded,
                  label: '📚 إدارة كتاب Herr / خالد الحلواني',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.adminBookManage);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.payments_rounded,
                  label: context.translate('earnings_collection'),
                  onTap: () async {
                    Navigator.pop(context);
                    await _openWhatsApp(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_active_rounded,
                  label: context.translate('send_alerts'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.language_rounded,
                  label: context.translate('select_language'),
                  onTap: () {
                    Navigator.pop(context);
                    showLanguageSwitcherDialog(context);
                  },
                ),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) {
                    final isDark = mode == ThemeMode.dark;
                    final itemColor = isDark ? const Color(0xFF1E293B) : Colors.white;
                    final textColor = isDark ? Colors.white : AppColors.textPrimary;
                    return Material(
                      color: itemColor,
                      child: ListTile(
                        leading: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: AppColors.primaryBlue,
                        ),
                        title: Text(
                          isDark
                              ? context.translate('dark_mode')
                              : context.translate('light_mode'),
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        trailing: Switch(
                          value: isDark,
                          onChanged: (_) {
                            context.read<ThemeCubit>().toggleTheme();
                          },
                          activeTrackColor: AppColors.primaryBlue,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 25),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                ),
                const Divider(indent: 20, endIndent: 20, height: 40),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  label: '⚙️ إعدادات التطبيق والأسعار والتواصل',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.adminAppSettings);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.logout_rounded,
                  label: context.translate('logout'),
                  onTap: () async {
                    Navigator.pop(context);
                    final confirmed =
                        await showLogoutConfirmationDialog(context);
                    if (!confirmed) return;

                    // Extract first name for personalized overlay
                    final userStr = sl<StorageService>().user;
                    final Map<String, dynamic>? userData = userStr != null ? jsonDecode(userStr) : null;
                    final String firstName = userData?['first_name'] ?? '';

                    final refresh = sl<StorageService>().refreshToken;
                    await sl<AuthRepo>().logout(refresh: refresh ?? '');
                    if (context.mounted) {
                      await showLogoutSuccessOverlay(context, firstName: firstName);
                    }
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final userStr = sl<StorageService>().user;
    final Map<String, dynamic>? userData = userStr != null ? jsonDecode(userStr) : null;
    
    String name = context.translate('system_admin');
    String email = context.translate('deutsch_welt_academy');
    
    if (userData != null) {
      final String first = userData['first_name'] ?? '';
      final String last = userData['last_name'] ?? '';
      final fullName = '$first $last'.trim();
      if (fullName.isNotEmpty) {
        name = fullName;
      }
      if (userData['email'] != null) {
        email = userData['email'];
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlueDark,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/images/deutsch_welt.jpeg'),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.cairo(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final itemColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        return Material(
          color: itemColor,
          child: ListTile(
            leading: Icon(icon, color: AppColors.primaryBlueDark),
            title: Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 25),
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Builder(builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Admin Portal v1.0.0',
              style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            PoweredByDeveloperWidget(isDarkBackground: isDark),
          ],
        ),
      );
    });
  }
}
