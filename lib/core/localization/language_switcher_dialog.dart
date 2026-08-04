import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../cubit/language_cubit.dart';
import '../di/service_locator.dart';
import 'app_localizations.dart';

/// Shows an animated language selection dialog.
Future<void> showLanguageSwitcherDialog(BuildContext context) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'language_barrier',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 350),
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return ScaleTransition(scale: curved, child: child);
    },
    pageBuilder: (ctx, _, __) => const _LanguageConfirmDialog(),
  );
}

/// Shows a beautiful, animated full-screen overlay to announce the language change.
Future<void> showLanguageChangeSuccessOverlay(BuildContext context, String langName) async {
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'lang_success_barrier',
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (ctx, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    pageBuilder: (ctx, _, __) => _LanguageSuccessOverlay(langName: langName),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Language Switcher Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageConfirmDialog extends StatelessWidget {
  const _LanguageConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final languageCubit = sl<LanguageCubit>();
    final currentLangCode = languageCubit.state.languageCode;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.03),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated Globe Icon ──
                ElasticIn(
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1E3A8A),
                          Color(0xFF3B82F6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Title ──
                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    context.translate('select_language'),
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Language Options ──
                FadeInUp(
                  delay: const Duration(milliseconds: 250),
                  child: Column(
                    children: [
                      _buildLanguageTile(
                        context: context,
                        title: 'العربية',
                        subtitle: 'Arabic',
                        flag: '🇪🇬',
                        isSelected: currentLangCode == 'ar',
                        onTap: () => _handleLanguageChange(context, 'ar', 'العربية'),
                      ),
                      const SizedBox(height: 12),
                      _buildLanguageTile(
                        context: context,
                        title: 'Deutsch',
                        subtitle: 'German',
                        flag: '🇩🇪',
                        isSelected: currentLangCode == 'de',
                        onTap: () => _handleLanguageChange(context, 'de', 'Deutsch'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Close Button ──
                FadeInUp(
                  delay: const Duration(milliseconds: 350),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      context.translate('close'),
                      style: GoogleFonts.cairo(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue.withValues(alpha: 0.06)
                : const Color(0xFFF8FAFC),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleLanguageChange(BuildContext context, String code, String name) async {
    Navigator.of(context).pop(); // Close switcher dialog first
    
    // Show premium overlay
    await showLanguageChangeSuccessOverlay(context, name);
    
    // Apply lang change
    sl<LanguageCubit>().changeLanguage(code);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Language Success Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _LanguageSuccessOverlay extends StatefulWidget {
  final String langName;
  const _LanguageSuccessOverlay({required this.langName});

  @override
  State<_LanguageSuccessOverlay> createState() => _LanguageSuccessOverlayState();
}

class _LanguageSuccessOverlayState extends State<_LanguageSuccessOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // Auto-dismiss after 1.8s
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: FadeInUp(
          duration: const Duration(milliseconds: 500),
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.02),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 35,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Spin Globe Check Icon ──
                RotationTransition(
                  turns: CurvedAnimation(
                    parent: _spinController,
                    curve: Curves.easeOutBack,
                  ),
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    context.translate('language_changed_title'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    '${context.translate('language_changed_desc')} (${widget.langName})',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
