import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../di/service_locator.dart';
import 'storage_service.dart';

class SecurityService {
  static const MethodChannel _channel =
      MethodChannel('com.deutschwelt.academy/security');

  static bool _isSecure = true;

  static bool get isSecure => _isSecure;

  /// Check if the currently logged in user is allowed to bypass screenshot protection
  static bool isUserAllowedToScreenshot() {
    try {
      final userStr = sl<StorageService>().user;
      if (userStr != null) {
        final data = jsonDecode(userStr);
        final email = (data['email'] ?? '').toString().toLowerCase().trim();
        final role = (data['role'] ?? '').toString().toLowerCase().trim();
        final isStaff = data['is_staff'] == true ||
            data['is_superuser'] == true ||
            data['is_admin'] == true;

        // Explicitly allowed admin emails for screen recording & screenshot permissions
        final allowedEmails = [
          '01055673184hs@gmail.com',
          'nwrhanmhmwdahmd1@gmail.com',
          'khaled.nabil26@gmail.com',
          'admin@deutschwelt.com',
        ];

        if (role == 'admin' ||
            role == 'superadmin' ||
            role == 'staff' ||
            isStaff ||
            allowedEmails.contains(email)) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// Enforce FLAG_SECURE / Screen Protection
  static Future<void> enableSecureScreen() async {
    try {
      await _channel.invokeMethod('enableSecureScreen');
      _isSecure = true;
    } catch (_) {
      // Platform unsupported or Web
    }
  }

  /// Disable FLAG_SECURE (for admins or allowed users to enable screenshot)
  static Future<void> disableSecureScreen() async {
    try {
      await _channel.invokeMethod('disableSecureScreen');
      _isSecure = false;
    } catch (_) {
      // Platform unsupported
    }
  }
}

/// Advanced & Sleek DRM Security Protection Screen
class SecureScreenWrapper extends StatefulWidget {
  final Widget child;
  final bool enableProtection;
  final String? customMessage;

  const SecureScreenWrapper({
    super.key,
    required this.child,
    this.enableProtection = true,
    this.customMessage,
  });

  @override
  State<SecureScreenWrapper> createState() => _SecureScreenWrapperState();
}

class _SecureScreenWrapperState extends State<SecureScreenWrapper>
    with WidgetsBindingObserver {
  bool _isInBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _applySecurity();
  }

  void _applySecurity() {
    if (widget.enableProtection) {
      if (SecurityService.isUserAllowedToScreenshot()) {
        // Disables FLAG_SECURE for Admins & 01055673184hs@gmail.com
        SecurityService.disableSecureScreen();
      } else {
        // Enables FLAG_SECURE for normal students
        SecurityService.enableSecureScreen();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _applySecurity();
    if (widget.enableProtection && !SecurityService.isUserAllowedToScreenshot()) {
      setState(() {
        // Trigger protective screen overlay when app goes to background / recents
        _isInBackground = (state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused);
      });
    } else {
      if (_isInBackground) {
        setState(() => _isInBackground = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAllowed = SecurityService.isUserAllowedToScreenshot();
    if (widget.enableProtection) {
      if (isAllowed) {
        SecurityService.disableSecureScreen();
      } else {
        SecurityService.enableSecureScreen();
      }
    }

    if (_isInBackground && !isAllowed) {
      // Retrieve logged in student details to personalize security shield
      String studentName = 'طالب أكاديمية Deutsch Welt';
      String studentPhone = '';
      try {
        final userStr = sl<StorageService>().user;
        if (userStr != null) {
          final data = jsonDecode(userStr);
          final first = data['first_name'] ?? '';
          final last = data['last_name'] ?? '';
          studentName = '$first $last'.trim();
          studentPhone = data['phone'] ?? data['phone_number'] ?? '';
        }
      } catch (_) {}

      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF060913), Color(0xFF0F172A), Color(0xFF1E1B4B)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Glowing Animated Security Shield Badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2),
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Brand Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.lock_rounded,
                            color: Color(0xFFF87171), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Deutsch Welt DRM Protection 🛡️',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF60A5FA),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Advanced Warning Title
                  Text(
                    'محتوى الأكاديمية محمي ضد التسجيل والتصوير 🔒',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Advanced Subtitle Notice
                  Text(
                    widget.customMessage ??
                        'تم تفعيل نظام الحماية الرقمية الفائق لحماية حقوق المحاضرات والكتب المطبوعة الخاصة بـ Herr خالد الحلواني.\nيتم إخفاء الرؤية تلقائياً عند استخدام برامج تسجيل الشاشة أو التبديل بين التطبيقات.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),

                  const Spacer(),

                  // Account Fingerprint Badge (scares away leakers)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint_rounded,
                            color: Color(0xFF10B981), size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'الحساب المفتوح: $studentName ${studentPhone.isNotEmpty ? "($studentPhone)" : ""}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: Colors.white70,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
