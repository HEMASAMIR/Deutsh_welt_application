import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/admin_drawer.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/video_model.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../../../core/widgets/custom_snack_bar.dart';
import 'admin_student_edit_screen.dart';
import 'admin_student_list_screen.dart';
import '../../../../core/services/coupon_service.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  bool _isSpeedDialOpen = false;

  /// Shows a beautiful animated check/confirmation overlay with Material support to prevent yellow underlines
  void _showActionFeedback(BuildContext context, String title, String subtitle, {Color? color}) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: IgnorePointer(
          child: Center(
            child: FadeIn(
              duration: const Duration(milliseconds: 300),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: (color ?? AppColors.primaryBlue).withValues(alpha: 0.18),
                        blurRadius: 40,
                        spreadRadius: 2,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ZoomIn(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                (color ?? AppColors.primaryBlue),
                                (color ?? AppColors.primaryBlue).withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlayState.insert(entry);
    Future.delayed(const Duration(milliseconds: 2200), () => entry.remove());
  }

  /// Simulates push notification dispatch with custom elegant messages for upload, update, and delete actions
  void _showNotificationSendingOverlay(BuildContext context, String level, String videoTitle, {String action = 'upload'}) {
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;
    
    // Choose custom elegant message based on level and action type
    String message = '';
    String actionTag = '';
    Color actionColor = AppColors.primaryBlue;
    IconData actionIcon = Icons.notifications_active_rounded;

    if (action == 'upload') {
      actionTag = 'إشعار رفع فيديو جديد 🎥';
      actionColor = AppColors.success;
      actionIcon = Icons.video_call_rounded;
      if (level == 'A1') {
        message = "🇩🇪 خبر عاجل يا أبطال الـ A1! 🚀\nهير خالد نزلكم فيديو جديد روعة: $videoTitle! \nادخلوا شوفوه دلوقتي وخلونا نقفل الألماني سوا! 💪✨";
      } else if (level == 'A2') {
        message = "🇩🇪 يا دفعة الـ A2 الجامدين! 🔥\nفيديو جديد نزل لكم حالاً على المنصة: $videoTitle! \nالهير بيظبطكم بأقوى التركات، يلا همتكم يا وحوش! 🎯📚";
      } else if (level == 'B1') {
        message = "🇩🇪 طلابنا العظماء في الـ B1! 🌟\nمحاضرة جديدة من ذهب نزلت لكم دلوقتي: $videoTitle! \nخطوة كمان نحو طلاقة الألمانية وامتحان الـ Goethe. بالتوفيق يا دكاترة! 🎓❤️";
      } else {
        message = "🇩🇪 طلابنا الأفاضل! ✨\nتم إضافة محاضرة جديدة بعنوان: $videoTitle! \nنتمنى لكم مشاهدة ممتعة وتوفيقاً مستمراً. 🇩🇪📖";
      }
    } else if (action == 'update') {
      actionTag = 'تنبيه تحديث محتوى 🔄';
      actionColor = AppColors.primaryBlue;
      actionIcon = Icons.sync_rounded;
      if (level == 'A1') {
        message = "🇩🇪 تنبيه هام يا أبطال الـ A1! 📢\nتم تحديث محتوى فيديو: $videoTitle! \nتأكدوا من إعادة مراجعته لرؤية التحديثات الجديدة! 🎯✨";
      } else if (level == 'A2') {
        message = "🇩🇪 دفعة الـ A2 الرائعين! 📢\nتم تعديل وإضافة تفاصيل جديدة للفيديو: $videoTitle! \nادخلوا للاستفادة من الإضافات فوراً! 📚🔥";
      } else if (level == 'B1') {
        message = "🇩🇪 طلابنا الكرام في الـ B1! 📢\nتم تحديث وتطوير المحاضرة: $videoTitle! \nالتحديث يحتوي على ملاحظات إضافية وهامة للامتحانات! 🎓🎯";
      } else {
        message = "🇩🇪 تنويه لطلابنا الكرام! 📢\nتم إجراء تحديث على الدرس: $videoTitle. نتمنى لكم دراسة موفقة! 🇩🇪📖";
      }
    } else if (action == 'delete') {
      actionTag = 'تنبيه إزالة محتوى 🗑️';
      actionColor = AppColors.error;
      actionIcon = Icons.delete_sweep_rounded;
      if (level == 'A1') {
        message = "🇩🇪 تنويه هام لطلاب الـ A1! 🗑️\nتمت إزالة الدرس المؤقت: $videoTitle \nنظراً لإعداد شرح أكثر شمولاً ودقة سنرفعه قريباً جداً! ⏳💪";
      } else if (level == 'A2') {
        message = "🇩🇪 طلاب الـ A2 الأعزاء! 🗑️\nتم حذف الفيديو: $videoTitle \nوجاري رفع النسخة المطورة والمحدثة بالكامل اليوم! 🎯🔥";
      } else if (level == 'B1') {
        message = "🇩🇪 طلاب الـ B1 الكرام! 🗑️\nتمت أرشفة وإزالة المحاضرة: $videoTitle \nاستعداداً لإطلاق الشرح الأقوى والنهائي للمراجعة! 🎓🌟";
      } else {
        message = "🇩🇪 تنبيه من إدارة المنصة! 🗑️\nتمت إزالة الدرس: $videoTitle كجزء من عملية تنظيم وتحديث المحتوى الدراسي. 🇩🇪";
      }
    }

    double progress = 0.0;
    bool isCompleted = false;

    entry = OverlayEntry(
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Start progress animation
            if (progress == 0.0) {
              Future.delayed(const Duration(milliseconds: 50), () {
                void updateProgress() {
                  if (progress < 1.0) {
                    setState(() {
                      progress += 0.06;
                    });
                    Future.delayed(const Duration(milliseconds: 80), updateProgress);
                  } else {
                    setState(() {
                      progress = 1.0;
                      isCompleted = true;
                    });
                    // Auto-remove after 5.5 seconds to read the premium message
                    Future.delayed(const Duration(milliseconds: 5500), () {
                      if (entry.mounted) {
                        entry.remove();
                      }
                    });
                  }
                }
                updateProgress();
              });
            }

            return Scaffold(
              backgroundColor: Colors.black.withValues(alpha: 0.65),
              body: Center(
                child: ZoomIn(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: actionColor.withValues(alpha: 0.2),
                          blurRadius: 35,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Action Badge Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: actionColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            actionTag,
                            style: GoogleFonts.cairo(
                              color: actionColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Pulsing / Progress Animation
                        isCompleted
                          ? Bounce(
                              duration: const Duration(milliseconds: 700),
                              child: Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [actionColor, actionColor.withValues(alpha: 0.7)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: actionColor.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(actionIcon, color: Colors.white, size: 40),
                              ),
                            )
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 84,
                                  height: 84,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                    value: progress,
                                    valueColor: AlwaysStoppedAnimation<Color>(actionColor),
                                    backgroundColor: actionColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                Icon(Icons.wifi_tethering_rounded, color: actionColor, size: 36),
                              ],
                            ),
                        const SizedBox(height: 24),
                        Text(
                          isCompleted ? 'تم بث الإشعار للطلاب! 📡🔔' : 'جاري تشفير وبث التنبيهات... 📡',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isCompleted
                              ? 'وصل التنبيه فورياً لجميع المشتركين في $level'
                              : 'يتم الآن الاتصال بقنوات الإشعارات وبث التنبيه لطلاب كورس $level',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Live Progress Bar (During sending)
                        if (!isCompleted) ...[
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[100],
                            valueColor: AlwaysStoppedAnimation<Color>(actionColor),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'نسبة الإرسال: ${(progress * 100).toInt()}%',
                            style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: actionColor),
                          ),
                        ],
                        // Lock screen notification mockup (On completion)
                        if (isCompleted) ...[
                          FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          'assets/images/deutsch_welt.jpeg',
                                          height: 28,
                                          width: 28,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Deutsch Welt Academy 🇩🇪',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              'الآن • من هير خالد الحلواني',
                                              style: GoogleFonts.cairo(
                                                fontSize: 9,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.lock_outline_rounded, color: Colors.grey.shade400, size: 14),
                                    ],
                                  ),
                                  const Divider(height: 20),
                                  Text(
                                    message,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    overlayState.insert(entry);
  }


  /// Form dialog to add a new video
  void _showAddVideoBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    final durationController = TextEditingController(text: '15:00');
    String selectedLevel = 'A1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
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
              Text(
                'إضافة فيديو جديد للمنصة 🎥',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                'سيتم نشر الفيديو وإرسال إشعار فوري لطلاب المستوى المحدد',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الدرس / الفيديو',
                  labelStyle: GoogleFonts.cairo(fontSize: 13),
                  prefixIcon: const Icon(Icons.title, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'رابط الفيديو (YouTube / Drive)',
                  labelStyle: GoogleFonts.cairo(fontSize: 13),
                  prefixIcon: const Icon(Icons.link, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: InputDecoration(
                        labelText: 'المستوى الدراسي',
                        labelStyle: GoogleFonts.cairo(fontSize: 13),
                        prefixIcon: const Icon(Icons.school, color: AppColors.primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textPrimary),
                      items: ['A1', 'A2', 'B1', 'B2']
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level, style: GoogleFonts.cairo()),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) selectedLevel = val;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      decoration: InputDecoration(
                        labelText: 'المدة',
                        labelStyle: GoogleFonts.cairo(fontSize: 13),
                        prefixIcon: const Icon(Icons.timer, color: AppColors.primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'إضافة وإرسال إشعار 🚀',
                        style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty || urlController.text.trim().isEmpty) {
                          CustomSnackBar.show(
                            context,
                            message: 'برجاء ملء جميع الحقول أولاً!',
                            type: SnackBarType.warning,
                          );
                          return;
                        }

                        // Add video
                        final newVideo = VideoModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          courseId: selectedLevel == 'A1' ? '1' : selectedLevel == 'A2' ? '2' : selectedLevel == 'B1' ? '3' : '4',
                          courseTitle: 'كورس $selectedLevel - ${selectedLevel == 'A1' ? 'المبتدئين' : selectedLevel == 'A2' ? 'التأسيس' : selectedLevel == 'B1' ? 'المتوسط' : 'المتقدم'}',
                          title: titleController.text.trim(),
                          videoUrl: urlController.text.trim(),
                          duration: durationController.text.trim(),
                          lessonNumber: 1,
                          isLocked: false,
                        );

                        context.read<AdminCubit>().addVideo(newVideo);
                        Navigator.pop(ctx);

                        // Trigger notifications sending simulator
                        _showNotificationSendingOverlay(context, selectedLevel, titleController.text.trim());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// General notification dialog
  void _showGeneralNotificationBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
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
              Text(
                'إرسال إشعار عام للطلاب 📣',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                'سيتم بث هذا التنبيه لجميع الطلاب المسجلين بالمنصة',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان التنبيه (مثال: هام جداً 🚨)',
                  labelStyle: GoogleFonts.cairo(fontSize: 13),
                  prefixIcon: const Icon(Icons.campaign, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bodyController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'تفاصيل الرسالة التنبيهية',
                  labelStyle: GoogleFonts.cairo(fontSize: 13),
                  prefixIcon: const Icon(Icons.message, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'إرسال الآن 🚀',
                        style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
                          CustomSnackBar.show(
                            context,
                            message: 'برجاء ملء جميع الحقول أولاً!',
                            type: SnackBarType.warning,
                          );
                          return;
                        }

                        Navigator.pop(ctx);
                        _showNotificationSendingOverlay(context, 'الكل', bodyController.text.trim());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/deutsch_welt.jpeg',
                height: 32,
                width: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'لوحة تحكم الإدارة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () => _showActionFeedback(
              context,
              'لا توجد إشعارات جديدة',
              'ستصلك إشعارات عند وصول طلبات جديدة',
            ),
          )
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoadingState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CustomShimmer.list(count: 2, height: 120, padding: EdgeInsets.zero),
                  const SizedBox(height: 20),
                  CustomShimmer.list(count: 3, height: 80, padding: EdgeInsets.zero),
                ],
              ),
            );
          }
          if (state is AdminLoadedState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    child: _buildStatsGrid(state),
                  ),
                  const SizedBox(height: 30),
                  
                  FadeInLeft(
                    child: Text(
                      'إجراءات سريعة',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    child: _buildQuickActions(state),
                  ),
                  const SizedBox(height: 30),

                  FadeInLeft(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'طلبات الانضمام المعلقة',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('عرض الكل'),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FadeInUp(
                    child: _buildPendingRequestsList(),
                  ),
                  const SizedBox(height: 30),

                  FadeInLeft(
                    child: Text(
                      'مراجعة تعليقات الطلاب 💬',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCommentsModerationSection(context, state.comments),
                  const SizedBox(height: 30),

                  FadeInLeft(
                    child: Text(
                      'آخر النشاطات',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInUp(
                    child: _buildRecentActivity(),
                  ),
                  const SizedBox(height: 30),

                  FadeInLeft(
                    child: Text(
                      'إدارة الطلاب',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── User Management (Admin Only) Card ──────────────────────
                  FadeInUp(
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, '/admin-user-manage'),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF1E3A8A).withValues(alpha: 0.30),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.manage_accounts_rounded,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إدارة المستخدمين',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'إضافة · تعديل · حذف · تغيير الصلاحيات',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white54, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FadeInUp(
                    child: _buildManageUsersSection(context),
                  ),
                  const SizedBox(height: 40),

                ],
              ),
            );
          }
          return const Center(child: Text('حدث خطأ غير متوقع'));
        },
      ),
      floatingActionButton: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is! AdminLoadedState) return const SizedBox.shrink();
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isSpeedDialOpen) ...[
                // Add Video option
                _buildSpeedDialItem(
                  label: 'إضافة فيديو جديد 🎥',
                  icon: Icons.video_call_rounded,
                  color: AppColors.success,
                  onPressed: () {
                    setState(() => _isSpeedDialOpen = false);
                    _showAddVideoBottomSheet(context);
                  },
                ),
                const SizedBox(height: 12),
                // Manage Videos option
                _buildSpeedDialItem(
                  label: 'إدارة الفيديوهات ⚙️',
                  icon: Icons.video_settings_rounded,
                  color: AppColors.primaryBlue,
                  onPressed: () {
                    setState(() => _isSpeedDialOpen = false);
                    _showManageVideosBottomSheet(context, state);
                  },
                ),
                const SizedBox(height: 12),
                // Add Student option
                _buildSpeedDialItem(
                  label: 'إضافة طالب 👤',
                  icon: Icons.person_add_rounded,
                  color: AppColors.primaryBlueLight,
                  onPressed: () {
                    setState(() => _isSpeedDialOpen = false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminStudentEditScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Send Alert option
                _buildSpeedDialItem(
                  label: 'إرسال تنويه عام 📣',
                  icon: Icons.campaign_rounded,
                  color: AppColors.warning,
                  onPressed: () {
                    setState(() => _isSpeedDialOpen = false);
                    _showGeneralNotificationBottomSheet(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
              // Main FAB Button
              FloatingActionButton(
                heroTag: 'admin_main_fab',
                onPressed: () {
                  setState(() {
                    _isSpeedDialOpen = !_isSpeedDialOpen;
                  });
                },
                backgroundColor: _isSpeedDialOpen ? AppColors.error : AppColors.primaryBlue,
                child: AnimatedRotation(
                  turns: _isSpeedDialOpen ? 0.125 : 0.0, // Rotates 45 degrees so '+' becomes 'x'
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(AdminLoadedState state) {
    final activeCount = state.students.where((s) => s.isActive).length;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'إجمالي الأرباح',
            value: '45,000 ج',
            icon: Icons.attach_money,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'الطلاب النشطين',
            value: activeCount.toString(),
            icon: Icons.people_outline,
            color: AppColors.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.cairo(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: const Icon(Icons.person, color: AppColors.textHint),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('محمود عبد الله', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    Text('طلب كورس A1', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: AppColors.success),
                    onPressed: () => _showActionFeedback(
                      context,
                      'تم القبول! ✅',
                      'تمت الموافقة على طلب الانضمام بنجاح',
                      color: AppColors.success,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.error),
                    onPressed: () => _showActionFeedback(
                      context,
                      'تم الرفض',
                      'تم رفض طلب الانضمام',
                      color: AppColors.error,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentsModerationSection(BuildContext context, List<CommentModel> comments) {
    final pendingComments = comments.where((c) => !c.isApproved).toList();
    
    if (pendingComments.isEmpty) {
      return FadeIn(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.mark_chat_read_rounded, color: AppColors.success.withValues(alpha: 0.6), size: 48),
                const SizedBox(height: 12),
                Text(
                  'لا توجد تعليقات معلقة للمراجعة 🎉',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'كل التعليقات تمت مراجعتها والموافقة عليها بنجاح',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pendingComments.length,
      itemBuilder: (context, index) {
        final comment = pendingComments[index];
        return FadeInUp(
          duration: Duration(milliseconds: 300 + (index * 100)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryBlueLight.withValues(alpha: 0.1),
                      child: Text(
                        comment.userName.isNotEmpty ? comment.userName[0] : 'U',
                        style: GoogleFonts.cairo(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.userName,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            comment.courseTitle,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                          onPressed: () {
                            context.read<AdminCubit>().approveComment(comment.id);
                            _showActionFeedback(
                              context,
                              'تم قبول التعليق! 💬✅',
                              'تم الموافقة على نشر التعليق بنجاح',
                              color: AppColors.success,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_rounded, color: AppColors.error, size: 28),
                          onPressed: () {
                            context.read<AdminCubit>().deleteComment(comment.id);
                            _showActionFeedback(
                              context,
                              'تم حذف التعليق! 🗑️❌',
                              'تم إزالة وحذف تعليق الطالب بنجاح',
                              color: AppColors.error,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    comment.commentText,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManageUsersSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ListTile(
              tileColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.primaryBlueLight.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(Icons.person_add, color: AppColors.primaryBlue),
              ),
              title: Text('إضافة طالب جديد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminStudentEditScreen()),
              ),
            ),
            const Divider(),
            ListTile(
              tileColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person_remove, color: AppColors.error),
              ),
              title: Text('عرض وحذف الطلاب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminStudentListScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(AdminLoadedState state) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'إضافة فيديو 🎥',
                icon: Icons.video_call_rounded,
                color: AppColors.success,
                onPressed: () => _showAddVideoBottomSheet(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'إدارة الفيديوهات ⚙️',
                icon: Icons.video_settings_rounded,
                color: AppColors.primaryBlue,
                onPressed: () => _showManageVideosBottomSheet(context, state),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'إرسال تنويه عام 📣',
                icon: Icons.campaign_rounded,
                color: AppColors.warning,
                onPressed: () => _showGeneralNotificationBottomSheet(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'إنشاء كوبون خصم 🏷️',
                icon: Icons.local_offer,
                color: AppColors.primaryBlueLight,
                onPressed: () => _showCreateCouponBottomSheet(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Interactive Coupon Creation Bottom Sheet
  void _showCreateCouponBottomSheet(BuildContext context) {
    final codeController = TextEditingController(
        text: 'DEUTSCH${(100 + (DateTime.now().millisecondsSinceEpoch % 900))}');
    final discountController = TextEditingController(text: '20');
    final usageLimitController = TextEditingController(text: '50');
    final expiryDaysController = TextEditingController(text: '7');
    final targetPhoneController = TextEditingController();
    bool singleUsePerStudent = true;
    String selectedTarget = 'جميع الكورسات والكتب';
    String discountType = 'نسبة مئوية (%)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlueLight.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_offer_rounded,
                            color: AppColors.primaryBlue, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إنشاء كوبون خصم محمي 🏷️🔒',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            Text(
                              'كوبونات محمية من التشارك والتداول بين الأصدقاء',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Coupon Code Field + Auto Generate Button
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'كود الخصم (Coupon Code)',
                            labelStyle: GoogleFonts.cairo(fontSize: 13),
                            prefixIcon: const Icon(Icons.qr_code_rounded,
                                color: AppColors.primaryBlue),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryBlue.withValues(alpha: 0.1),
                          foregroundColor: AppColors.primaryBlue,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () {
                          setSheetState(() {
                            final randomNum = 100 +
                                (DateTime.now().microsecondsSinceEpoch % 900);
                            codeController.text = 'DEUTSCH$randomNum';
                          });
                        },
                        child: Text(
                          'توليد 🔄',
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Discount Type & Percentage/Amount Row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: discountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: discountType.contains('%')
                                ? 'نسبة الخصم (%)'
                                : 'مبلغ الخصم (ج.م)',
                            labelStyle: GoogleFonts.cairo(fontSize: 13),
                            prefixIcon: Icon(
                              discountType.contains('%')
                                  ? Icons.percent_rounded
                                  : Icons.attach_money_rounded,
                              color: AppColors.success,
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          style: GoogleFonts.cairo(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          value: discountType,
                          decoration: InputDecoration(
                            labelText: 'نوع الخصم',
                            labelStyle: GoogleFonts.cairo(fontSize: 11),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 14),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold),
                          items: ['نسبة مئوية (%)', 'مبلغ ثابت (ج.م)']
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type,
                                        style: GoogleFonts.cairo(fontSize: 12)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => discountType = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Applied Course Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedTarget,
                    decoration: InputDecoration(
                      labelText: 'صالح لـ (الكورس / الكتاب)',
                      labelStyle: GoogleFonts.cairo(fontSize: 13),
                      prefixIcon: const Icon(Icons.school_rounded,
                          color: AppColors.primaryBlue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold),
                    items: [
                      'جميع الكورسات والكتب',
                      'كورس A1',
                      'كورس A2',
                      'كورس B1',
                      'كورس B2',
                      'كتب الشرح والأسئلة'
                    ]
                        .map((target) => DropdownMenuItem(
                              value: target,
                              child: Text(target,
                                  style: GoogleFonts.cairo(fontSize: 12)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setSheetState(() => selectedTarget = val);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Target Student Phone Number (Optional)
                  TextField(
                    controller: targetPhoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'تخصيص الكوبون لطالب محدد برقم هاتفه (اختياري)',
                      hintText: 'مثال: 01055287454 (يمنع أي طالب آخر من استخدامه)',
                      hintStyle: GoogleFonts.cairo(fontSize: 11),
                      prefixIcon: const Icon(Icons.phone_android_rounded,
                          color: AppColors.primaryBlue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  // Single Use Per Student Checkbox / Switch
                  SwitchListTile(
                    tileColor: Colors.white,
                    value: singleUsePerStudent,
                    onChanged: (val) => setSheetState(() => singleUsePerStudent = val),
                    title: Text(
                      'استخدام مرة واحدة فقط لكل حساب طالب 🔒',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'يمنع الطالب نفسه من إعادة استخدام الكوبون مرتين أو مشاركته مع زملائه',
                      style: GoogleFonts.cairo(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  // Max Users & Expiry Days Row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: usageLimitController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'العدد الإجمالي (طلاب)',
                            labelStyle: GoogleFonts.cairo(fontSize: 12),
                            prefixIcon: const Icon(Icons.people_alt_rounded,
                                color: AppColors.primaryBlue),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: expiryDaysController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'مدة الصلاحية (أيام)',
                            labelStyle: GoogleFonts.cairo(fontSize: 12),
                            prefixIcon: const Icon(Icons.timer_rounded,
                                color: AppColors.warning),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15)),
                          ),
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          child: Text('إلغاء',
                              style: GoogleFonts.cairo(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold)),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.check_circle_rounded,
                              color: Colors.white),
                          label: Text(
                            'حفظ وتفعيل الكوبون المحمي 🏷️🔒',
                            style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                          onPressed: () async {
                            final code = codeController.text.trim();
                            final discountVal =
                                double.tryParse(discountController.text.trim()) ?? 0.0;
                            final maxUsers =
                                int.tryParse(usageLimitController.text.trim()) ?? 50;
                            final expiryDays =
                                int.tryParse(expiryDaysController.text.trim()) ?? 7;
                            final targetPhone = targetPhoneController.text.trim();

                            if (code.isEmpty || discountVal <= 0) {
                              CustomSnackBar.show(
                                context,
                                message: 'يرجى إدخال كود الخصم والنسبة/المبلغ الصحيح!',
                                type: SnackBarType.warning,
                              );
                              return;
                            }

                            final newCoupon = CouponModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              code: code,
                              discountValue: discountVal,
                              isPercentage: discountType.contains('%'),
                              maxUsers: maxUsers,
                              expiryDays: expiryDays,
                              createdAt: DateTime.now(),
                              targetCourse: selectedTarget,
                              singleUsePerStudent: singleUsePerStudent,
                              targetStudentPhone: targetPhone.isNotEmpty ? targetPhone : null,
                            );

                            await CouponService.addCoupon(newCoupon);

                            if (context.mounted) {
                              Navigator.pop(ctx);
                              final labelText = discountType.contains('%')
                                  ? '${discountVal.toInt()}%'
                                  : '${discountVal.toInt()} ج.م';
                              final phoneInfo = targetPhone.isNotEmpty ? ' مخصص للهاتف ($targetPhone)' : '';
                              _showActionFeedback(
                                context,
                                'تم تفعيل الكوبون المحمي ($code) بنجاح! 🏷️🔒',
                                'خصم $labelText صالح لـ $maxUsers طالب لمرة واحدة لكل حساب$phoneInfo',
                                color: AppColors.primaryBlue,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Manage existing videos bottom sheet
  void _showManageVideosBottomSheet(BuildContext context, AdminLoadedState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final videos = state.videos;
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(24),
              child: Column(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'إدارة فيديوهات المنصة 🎥',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'عدد الفيديوهات: ${videos.length}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'تعديل وحذف الفيديوهات سيبث إشعاراً مباشراً للطلاب المسجلين في هذا المستوى لتنبيههم بالإجراء.',
                    style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: videos.isEmpty
                        ? Center(
                            child: Text(
                              'لا توجد فيديوهات مرفوعة حالياً',
                              style: GoogleFonts.cairo(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.builder(
                            itemCount: videos.length,
                            itemBuilder: (context, index) {
                              final video = videos[index];
                              final String level = video.courseId == '1'
                                  ? 'A1'
                                  : video.courseId == '2'
                                      ? 'A2'
                                      : video.courseId == '3'
                                          ? 'B1'
                                          : 'B2';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.play_circle_fill_rounded,
                                          color: AppColors.primaryBlue, size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            video.title,
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.success.withValues(alpha: 0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  level,
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.success,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'مدة: ${video.duration}',
                                                style: GoogleFonts.cairo(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_rounded, color: AppColors.primaryBlue),
                                          onPressed: () {
                                            _showEditVideoBottomSheet(context, video);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_rounded, color: AppColors.error),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (dialogCtx) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(24)),
                                                title: Text(
                                                  'تأكيد الحذف 🗑️',
                                                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                                                ),
                                                content: Text(
                                                  'هل أنت متأكد من حذف درس "${video.title}"؟\nسيتم بث إشعار فوري لطلاب الـ $level يفيد بإلغاء/حذف المحتوى.',
                                                  style: GoogleFonts.cairo(fontSize: 14),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    child: Text('إلغاء',
                                                        style: GoogleFonts.cairo(color: AppColors.textSecondary)),
                                                    onPressed: () => Navigator.pop(dialogCtx),
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppColors.error,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12)),
                                                    ),
                                                    child: Text('حذف وبث التنبيه',
                                                        style: GoogleFonts.cairo(
                                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                                    onPressed: () {
                                                      Navigator.pop(dialogCtx);
                                                      Navigator.pop(context); // Close manage sheet
                                                      context.read<AdminCubit>().deleteVideo(video.id);
                                                      _showNotificationSendingOverlay(context, level, video.title,
                                                          action: 'delete');
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Edit existing video bottom sheet
  void _showEditVideoBottomSheet(BuildContext context, VideoModel video) {
    final titleController = TextEditingController(text: video.title);
    final urlController = TextEditingController(text: video.videoUrl);
    final durationController = TextEditingController(text: video.duration);
    String selectedLevel = video.courseId == '1'
        ? 'A1'
        : video.courseId == '2'
            ? 'A2'
            : video.courseId == '3'
                ? 'B1'
                : 'B2';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (editCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(editCtx).viewInsets.bottom,
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
              Text(
                'تعديل بيانات الفيديو 🔄',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              Text(
                'سيتم تحديث تفاصيل الدرس وإرسال إشعار فوري لطلاب المستوى بنوع التعديل',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الدرس / الفيديو',
                  labelStyle: GoogleFonts.cairo(fontSize: 13),
                  prefixIcon: const Icon(Icons.title, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  labelText: 'رابط الفيديو (YouTube / Drive)',
                  labelStyle: GoogleFonts.cairo(fontSize: 13),
                  prefixIcon: const Icon(Icons.link, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
                style: GoogleFonts.cairo(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedLevel,
                      decoration: InputDecoration(
                        labelText: 'المستوى الدراسي',
                        labelStyle: GoogleFonts.cairo(fontSize: 13),
                        prefixIcon: const Icon(Icons.school, color: AppColors.primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textPrimary),
                      items: ['A1', 'A2', 'B1', 'B2']
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level, style: GoogleFonts.cairo()),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) selectedLevel = val;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: durationController,
                      decoration: InputDecoration(
                        labelText: 'المدة',
                        labelStyle: GoogleFonts.cairo(fontSize: 13),
                        prefixIcon: const Icon(Icons.timer, color: AppColors.primaryBlue),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      style: GoogleFonts.cairo(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      child: Text('إلغاء',
                          style: GoogleFonts.cairo(color: AppColors.error, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.pop(editCtx),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'تعديل وإرسال إشعار 🚀',
                        style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      onPressed: () {
                        if (titleController.text.trim().isEmpty || urlController.text.trim().isEmpty) {
                          CustomSnackBar.show(
                            context,
                            message: 'برجاء ملء جميع الحقول أولاً!',
                            type: SnackBarType.warning,
                          );
                          return;
                        }

                        final updatedVideo = VideoModel(
                          id: video.id,
                          courseId: selectedLevel == 'A1'
                              ? '1'
                              : selectedLevel == 'A2'
                                  ? '2'
                                  : selectedLevel == 'B1'
                                      ? '3'
                                      : '4',
                          courseTitle:
                              'كورس $selectedLevel - ${selectedLevel == 'A1' ? 'المبتدئين' : selectedLevel == 'A2' ? 'التأسيس' : selectedLevel == 'B1' ? 'المتوسط' : 'المتقدم'}',
                          title: titleController.text.trim(),
                          videoUrl: urlController.text.trim(),
                          duration: durationController.text.trim(),
                          lessonNumber: video.lessonNumber,
                          isLocked: video.isLocked,
                        );

                        context.read<AdminCubit>().updateVideo(updatedVideo);
                        Navigator.pop(editCtx);
                        Navigator.pop(context); // Close manage sheet

                        // Trigger notifications sending simulator with 'update' action
                        _showNotificationSendingOverlay(context, selectedLevel, titleController.text.trim(),
                            action: 'update');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActivityItem('تم انضمام طالب جديد: علي حسن', 'منذ 10 دقائق', Icons.person_add, AppColors.success),
          const Divider(),
          _buildActivityItem('شراء كورس B1: منى أحمد', 'منذ ساعة', Icons.shopping_cart, AppColors.primaryBlue),
          const Divider(),
          _buildActivityItem('تم تفعيل كوبون الخصم: GERMANY26', 'منذ ساعتين', Icons.local_offer, AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(time, style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDialItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return FadeInRight(
      duration: const Duration(milliseconds: 250),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: 'fab_${label.hashCode}',
            onPressed: onPressed,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
