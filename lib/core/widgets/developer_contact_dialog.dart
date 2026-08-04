import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../localization/app_localizations.dart';
import 'custom_snack_bar.dart';

/// Opens an elegant dialog / bottom sheet to contact the lead developer Eng / Ebrahim Samir.
void showDeveloperContactModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _DeveloperContactSheet(),
  );
}

class _DeveloperContactSheet extends StatelessWidget {
  const _DeveloperContactSheet();

  static const String devWhatsApp = '201055673184';
  static const String devEmail = '01055673184hs@gmail.com';

  Future<void> _launchWhatsApp(BuildContext context) async {
    const message = "مرحباً م/ إبراهيم سمير 👋🏼\nأشكرك على تطوير تطبيق وموقع Deutsch Welt Akademie! 🚀🇩🇪";
    final encodedMsg = Uri.encodeComponent(message);
    final url = "https://wa.me/$devWhatsApp?text=$encodedMsg";

    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'تعذر فتح تطبيق الواتساب',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    const subject = "تواصل بخصوص منصة Deutsch Welt";
    const body = "مرحباً م/ إبراهيم سمير 👋🏼\nأود التواصل معك بخصوص تطبيق وموقع Deutsch Welt.";
    final uri = Uri(
      scheme: 'mailto',
      path: devEmail,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        CustomSnackBar.show(
          context,
          message: 'تعذر فتح تطبيق البريد الإلكتروني',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          
          // Header Badge
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.code_rounded,
              color: AppColors.primaryBlue,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Eng / Ebrahim Samir',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'Full-Stack Developer & Software Engineer 🚀',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          // Contact via WhatsApp Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                _launchWhatsApp(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF25D366),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تواصل عبر واتساب',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '+20 105 567 3184',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF25D366),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Contact via Email Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                _launchEmail(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.email_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إرسال بريد إلكتروني',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            devEmail,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// A compact, elegant "Powered by Eng / Ebrahim Samir" widget to insert in footers.
class PoweredByDeveloperWidget extends StatelessWidget {
  final bool isDarkBackground;

  const PoweredByDeveloperWidget({
    super.key,
    this.isDarkBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final devColor = isDarkBackground
        ? const Color(0xFFFACC15) // Soft Gold
        : AppColors.primaryBlue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showDeveloperContactModal(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.translate('developer_credits'),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: devColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.verified_rounded,
                  size: 14,
                  color: devColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
