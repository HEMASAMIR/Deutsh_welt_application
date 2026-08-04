import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/certificate_service.dart';
import '../theme/app_colors.dart';

/// A full-screen celebratory overlay shown when a student completes a level.
/// Retrieves the student's name from SharedPreferences key `user_name`.
class CertificateDialog extends StatefulWidget {
  final String levelName;

  const CertificateDialog({super.key, required this.levelName});

  /// Convenience method to show the dialog.
  static Future<void> show(BuildContext context, String levelName) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (_) => CertificateDialog(levelName: levelName),
    );
  }

  @override
  State<CertificateDialog> createState() => _CertificateDialogState();
}

class _CertificateDialogState extends State<CertificateDialog>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  bool _isGenerating = false;
  String _studentName = '';

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(
      parent: _scaleCtrl,
      curve: Curves.elasticOut,
    );
    _scaleCtrl.forward();
    _loadStudentName();
  }

  Future<void> _loadStudentName() async {
    final prefs = await SharedPreferences.getInstance();
    // Try multiple common keys used across the app
    final name = prefs.getString('user_name') ??
        prefs.getString('student_name') ??
        prefs.getString('name') ??
        '';
    if (mounted) setState(() => _studentName = name);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Future<void> _downloadCertificate() async {
    if (_isGenerating) return;
    final nameToUse = _studentName.trim().isEmpty
        ? 'الطالب الكريم'
        : _studentName;

    setState(() => _isGenerating = true);
    try {
      await CertificateService.shareOrSave(
        studentName: nameToUse,
        levelName: widget.levelName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء توليد الشهادة: $e',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.25),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Gradient header ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    // Trophy animation
                    ElasticIn(
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFD4AF37), width: 2),
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 42,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    FadeInDown(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        '🎉 Herzlichen Glückwunsch!',
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xFFF5E6A3),
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeInDown(
                      delay: const Duration(milliseconds: 500),
                      child: Text(
                        'مبروك! أتممت المستوى بنجاح 🏆',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Level chip
                    FadeInUp(
                      delay: const Duration(milliseconds: 550),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'مستوى ${widget.levelName}',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Certificate preview card
                    FadeInUp(
                      delay: const Duration(milliseconds: 650),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.workspace_premium_rounded,
                                    color: Color(0xFFD4AF37),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'شهادة إتمام المستوى',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Deutsch Welt Akademie',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),
                            Divider(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : AppColors.border,
                            ),
                            const SizedBox(height: 10),

                            // What's on the cert
                            _CertFeatureRow(
                              icon: Icons.person_rounded,
                              label: 'اسمك بالكامل على الشهادة',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            _CertFeatureRow(
                              icon: Icons.military_tech_rounded,
                              label: 'مستوى ${widget.levelName} — موثّق',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            _CertFeatureRow(
                              icon: Icons.calendar_today_rounded,
                              label: 'تاريخ الإتمام الرسمي',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            _CertFeatureRow(
                              icon: Icons.draw_rounded,
                              label: 'توقيع الهير خالد الحلواني',
                              isDark: isDark,
                            ),
                            const SizedBox(height: 8),
                            _CertFeatureRow(
                              icon: Icons.picture_as_pdf_rounded,
                              label: 'PDF جاهز للطباعة والمشاركة',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Download button
                    FadeInUp(
                      delay: const Duration(milliseconds: 750),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed:
                              _isGenerating ? null : _downloadCertificate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: const Color(0xFF1E3A8A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            shadowColor:
                                const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          ),
                          child: _isGenerating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.download_rounded, size: 22),
                                    const SizedBox(width: 10),
                                    Text(
                                      'تحميل الشهادة 🏅',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Close button
                    FadeInUp(
                      delay: const Duration(milliseconds: 800),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'لاحقاً',
                          style: GoogleFonts.cairo(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper Row Widget ────────────────────────────────────────────────────────
class _CertFeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _CertFeatureRow({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(icon, size: 15, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
        ),
        const Icon(Icons.check_circle_rounded,
            size: 14, color: AppColors.success),
      ],
    );
  }
}
