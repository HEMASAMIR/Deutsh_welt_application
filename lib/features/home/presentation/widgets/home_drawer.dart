import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../features/auth/data/repos/auth_repo.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../features/auth/presentation/widgets/logout_dialog.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/language_switcher_dialog.dart';
import '../../../../core/widgets/developer_contact_dialog.dart';
import '../../../../core/cubit/theme_cubit.dart';
import '../../../../core/widgets/theme_change_dialog.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final drawerBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    return Drawer(
      backgroundColor: drawerBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  label: context.translate('home'),
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.school_rounded,
                  label: context.translate('courses'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  label: context.translate('profile'),
                  onTap: () async {
                    Navigator.pop(context);
                    final isLoggedIn = await sl<AuthRepo>().isLoggedIn();
                    if (isLoggedIn) {
                      if (context.mounted) {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      }
                    } else {
                      if (context.mounted) {
                        CustomSnackBar.show(
                          context,
                          message: context.translate('access_denied_desc'),
                          type: SnackBarType.warning,
                        );
                        Navigator.pushNamed(context, AppRoutes.login);
                      }
                    }
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: context.translate('who_is_herr_khaled'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.instructorBio);
                  },
                ),
                // ─── Book of Herr Khaled ───────────────────────────────
                _buildDrawerItem(
                  icon: Icons.menu_book_rounded,
                  label: '📚 كتاب Herr / خالد الحلواني',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.book);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.local_offer_rounded,
                  label: '🏷️ إدخال كود خصم الكورسات',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.levels);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.privacy_tip_outlined,
                  label: context.translate('privacy_policy'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.privacy);
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
                            ThemeChangeDialog.show(context, isDarkNow: !isDark);
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
                _buildLogoutOrLogin(context),
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
    
    String name = context.translate('new_visitor');
    String email = context.translate('welcome_academy');
    
    if (userData != null) {
      final String first = userData['first_name'] ?? '';
      final String last = userData['last_name'] ?? '';
      name = '$first $last'.trim();
      if (name.isEmpty) name = 'مستخدم بدون اسم';
      email = userData['email'] ?? 'لا يوجد بريد إلكتروني';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              backgroundImage: userData?['profile_photo'] != null
                  ? NetworkImage(userData!['profile_photo'])
                  : const AssetImage('assets/images/deutsch_welt.jpeg') as ImageProvider,
            ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    BuildContext? ctx,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final itemColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        return Material(
          color: itemColor,
          child: ListTile(
            leading: Icon(icon, color: AppColors.primaryBlue),
            title: Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 25),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  Widget _buildLogoutOrLogin(BuildContext context) {
    return FutureBuilder<bool>(
      future: sl<AuthRepo>().isLoggedIn(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data ?? false;
        if (isLoggedIn) {
          return _buildDrawerItem(
            icon: Icons.logout_rounded,
            label: context.translate('logout'),
            onTap: () async {
              // Close the drawer first
              Navigator.pop(context);

              // 1. Show animated confirmation dialog
              final confirmed = await showLogoutConfirmationDialog(context);
              if (!confirmed) return;

              // Extract first name for personalized overlay
              final userStr = sl<StorageService>().user;
              final Map<String, dynamic>? userData = userStr != null ? jsonDecode(userStr) : null;
              final String firstName = userData?['first_name'] ?? '';

              // 2. Perform the actual logout before confirming success.
              final refresh = sl<StorageService>().refreshToken;
              await sl<AuthRepo>().logout(refresh: refresh ?? '');

              // 3. Show the success animation only after local data is cleared.
              if (context.mounted) {
                await showLogoutSuccessOverlay(context, firstName: firstName);
              }

              // 4. Navigate to login screen and clear stack.
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
          );
        } else {
          return _buildDrawerItem(
            icon: Icons.login_rounded,
            label: context.translate('login'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.login);
            },
          );
        }
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
              'Deutsch Welt v1.0.0',
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            PoweredByDeveloperWidget(isDarkBackground: isDark),
          ],
        ),
      );
    });
  }
}
