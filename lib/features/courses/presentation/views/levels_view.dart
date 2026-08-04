import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../../../core/services/coupon_service.dart';
import '../../../../core/services/storage_service.dart';
import '../cubit/levels/levels_cubit.dart';

class LevelsView extends StatelessWidget {
  const LevelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LevelsCubit>()..fetchLevels(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 180.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primaryBlue,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  title: Text(
                    'مستويات الألمانية',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF172554)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -30,
                        top: -30,
                        child: CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 40,
                        child: FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Deutsch Welt 🇩🇪',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: BlocBuilder<LevelsCubit, LevelsState>(
            builder: (context, state) {
              if (state is LevelsLoading || state is LevelsInitial) {
                return CustomShimmer.list(count: 4, height: 130);
              }
              if (state is LevelsError) {
                return _ErrorState(
                  message: state.message,
                  onRetry: () => context.read<LevelsCubit>().fetchLevels(),
                );
              }
              final loaded = state as LevelsLoaded;
              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: () => context.read<LevelsCubit>().refreshLevels(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: loaded.levels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final level = loaded.levels[index];
                    return FadeInUp(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: level.hasAccess
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              if (!level.hasAccess) {
                                _showSubscribeWithCouponBottomSheet(
                                    context, level.name, level.title, 1500.0);
                                return;
                              }
                              Navigator.pushNamed(
                                context,
                                AppRoutes.levelVideos,
                                arguments: {'levelId': level.id, 'levelName': level.name},
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Circle Avatar with Lock / Play
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: (level.hasAccess
                                              ? AppColors.success
                                              : AppColors.textSecondary)
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        level.hasAccess
                                            ? Icons.play_circle_fill_rounded
                                            : Icons.lock_rounded,
                                        color: level.hasAccess
                                            ? AppColors.success
                                            : AppColors.textSecondary,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              level.name.toUpperCase(),
                                              style: GoogleFonts.cairo(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 20,
                                                color: level.hasAccess
                                                    ? AppColors.primaryBlue
                                                    : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: level.hasAccess
                                                    ? AppColors.success.withValues(alpha: 0.12)
                                                    : AppColors.border,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                level.hasAccess ? 'نشط' : 'غير مشترك',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: level.hasAccess
                                                      ? AppColors.success
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          level.title,
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          level.description,
                                          style: GoogleFonts.cairo(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                        if (!level.hasAccess && level.formattedPrice.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Text(
                                                level.formattedPrice,
                                                style: GoogleFonts.cairo(
                                                  color: AppColors.primaryBlue,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              if (level.oldPrice != null) ...[
                                                const SizedBox(width: 8),
                                                Text(
                                                  level.formattedOldPrice,
                                                  style: GoogleFonts.cairo(
                                                    color: AppColors.textHint,
                                                    fontSize: 13,
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 14),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.textHint,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSubscribeWithCouponBottomSheet(
      BuildContext context, String levelName, String levelTitle, double originalPrice) {
    final couponController = TextEditingController();
    CouponValidationResult? appliedResult;
    bool isApplying = false;

    // Retrieve logged-in student phone number
    String studentPhone = '';
    final userStr = sl<StorageService>().user;
    if (userStr != null) {
      try {
        final userData = jsonDecode(userStr);
        studentPhone = userData['phone'] ?? userData['phone_number'] ?? '';
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final currentPrice = appliedResult?.isValid == true
              ? appliedResult!.discountedPrice
              : originalPrice;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 24,
              left: 24,
              right: 24,
            ),
            child: SingleChildScrollView(
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

                  // Header Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium_rounded,
                            color: AppColors.primaryBlue, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الاشتراك في $levelName - $levelTitle 🚀',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            Text(
                              'منصة أكاديمية Deutsch Welt مع Herr خالد الحلواني 🇩🇪',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price Details Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'سعر الكورس الأصلي:',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${originalPrice.toInt()} ج.م',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                decoration: appliedResult?.isValid == true
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: appliedResult?.isValid == true
                                    ? AppColors.textHint
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (appliedResult?.isValid == true) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'قيمة الخصم (${appliedResult!.coupon!.code}):',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '- ${appliedResult!.discountAmount.toInt()} ج.م 🏷️',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'السعر النهائي المطلوب:',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              Text(
                                '${currentPrice.toInt()} ج.م',
                                style: GoogleFonts.cairo(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Promo Code Input Row
                  Text(
                    'هل لديك كود خصم؟ 🏷️',
                    style: GoogleFonts.cairo(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: couponController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'أدخل كود الخصم (مثال: DEUTSCH20)',
                            hintStyle: GoogleFonts.cairo(fontSize: 12),
                            prefixIcon: const Icon(Icons.local_offer_outlined,
                                color: AppColors.primaryBlue),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isApplying
                            ? null
                            : () async {
                                setSheetState(() => isApplying = true);
                                final result = await CouponService.applyCoupon(
                                  inputCode: couponController.text,
                                  originalPrice: originalPrice,
                                  courseName: levelName,
                                  studentPhone: studentPhone,
                                );
                                setSheetState(() {
                                  appliedResult = result;
                                  isApplying = false;
                                });

                                if (context.mounted) {
                                  CustomSnackBar.show(
                                    context,
                                    message: result.message,
                                    type: result.isValid
                                        ? SnackBarType.success
                                        : SnackBarType.error,
                                  );
                                }
                              },
                        child: isApplying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'تطبيق 🏷️',
                                style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                      ),
                    ],
                  ),

                  if (appliedResult != null && !appliedResult!.isValid) ...[
                    const SizedBox(height: 8),
                    Text(
                      appliedResult!.message,
                      style: GoogleFonts.cairo(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Confirm Subscription via WhatsApp Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      if (appliedResult?.isValid == true) {
                        await CouponService.incrementCouponUsage(
                          appliedResult!.coupon!.code,
                          studentPhone: studentPhone,
                        );
                      }

                      final couponInfo = appliedResult?.isValid == true
                          ? "\n🏷️ كود الخصم المطبق: ${appliedResult!.coupon!.code} (خصم ${appliedResult!.discountAmount.toInt()} ج.م)"
                          : "";

                      final msg =
                          "مرحباً هير خالد 👋🏼\nأرغب في الاشتراك بكورس $levelName ($levelTitle) بسعر ${currentPrice.toInt()} ج.م$couponInfo\nأرجو تفعيل حسابي الآن! 🚀🇩🇪";

                      final encoded = Uri.encodeComponent(msg);
                      final url = "https://wa.me/201055287454?text=$encoded";
                      Navigator.pop(ctx);
                      await launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.send_rounded, size: 24),
                    label: Text(
                      'تأكيد الاشتراك عبر واتساب (${currentPrice.toInt()} ج.م) 🚀',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 64),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: Text('إعادة المحاولة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
}
