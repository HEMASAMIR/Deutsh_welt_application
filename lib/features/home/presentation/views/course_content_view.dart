import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

class CourseContentView extends StatefulWidget {
  final String title;
  final String type; // 'lectures', 'exams', 'support'

  const CourseContentView({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<CourseContentView> createState() => _CourseContentViewState();
}

class _CourseContentViewState extends State<CourseContentView> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> _lessons = [
    {
      'lessonNumber': '01',
      'title': 'الدرس الأول: التحيات والتعارف',
      'videoTitle': 'شرح التحيات بالألمانية',
      'pdfTitle': 'ملخص الدرس الأول (كلمات وقواعد)',
      'isLocked': false,
    },
    {
      'lessonNumber': '02',
      'title': 'الدرس الثاني: الأبجدية والنطق',
      'videoTitle': 'نطق الحروف الألمانية الصحيح',
      'pdfTitle': 'جدول النطق والكلمات (PDF)',
      'isLocked': false,
    },
    {
      'lessonNumber': '03',
      'title': 'الدرس الثالث: الأرقام والألوان',
      'videoTitle': 'الأرقام من 1 إلى 100 الألوان',
      'pdfTitle': 'تمارين على الأرقام (PDF)',
      'isLocked': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredLessons = _lessons.where((lesson) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final title = (lesson['title'] as String).toLowerCase();
      final videoTitle = (lesson['videoTitle'] as String).toLowerCase();
      final pdfTitle = (lesson['pdfTitle'] as String).toLowerCase();
      return title.contains(q) || videoTitle.contains(q) || pdfTitle.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80, // Increased height for better spacing
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.cairo(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
          _buildSearchBox(),
          const SizedBox(height: 20),
          if (widget.type == 'support') ...[
            _buildSupportSection(),
          ] else ...[
            _buildSectionHeader(
                widget.type == 'exams' ? 'الاختبارات المتاحة' : 'الوحدة الأولى: الأساسيات'),
            const SizedBox(height: 20),
            _buildContentList(filteredLessons),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      onChanged: (val) {
        setState(() {
          _searchQuery = val.trim();
        });
      },
      decoration: InputDecoration(
        hintText: 'ابحث في محتوى الدروس والمذكرات...',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white12 : AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Column(
      children: [
        _buildContentCard(
          title: 'تواصل عبر واتساب',
          duration: 'متاح 24/7',
          type: 'whatsapp',
          isLocked: false,
          delay: 100,
        ),
        _buildContentCard(
          title: 'اتصال هاتفي مباشر',
          duration: 'من 9 صباحاً لـ 9 مساءً',
          type: 'phone',
          isLocked: false,
          delay: 200,
        ),
      ],
    );
  }

  Widget _buildContentList(List<Map<String, dynamic>> lessonsList) {
    if (lessonsList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'لا يوجد نتائج تطابق بحثك',
                style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: lessonsList.map((item) {
        return _buildLessonGroup(
          lessonNumber: item['lessonNumber'],
          title: item['title'],
          videoTitle: item['videoTitle'],
          pdfTitle: item['pdfTitle'],
          isLocked: item['isLocked'] ?? false,
          delay: 100,
        );
      }).toList(),
    );
  }

  Widget _buildLessonGroup({
    required String lessonNumber,
    required String title,
    required String videoTitle,
    required String pdfTitle,
    bool isLocked = false,
    required int delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Lesson Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.03),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        lessonNumber,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Lesson Items
              _buildSubItem(
                title: videoTitle,
                type: 'video',
                isLocked: isLocked,
                cardBg: cardBg,
              ),
              Divider(height: 1, color: isDark ? Colors.white10 : const Color(0xFFF1F5F9), indent: 20, endIndent: 20),
              _buildSubItem(
                title: pdfTitle,
                type: 'pdf',
                isLocked: isLocked,
                cardBg: cardBg,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeInRight(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accentGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubItem({
    required String title,
    required String type,
    required bool isLocked,
    required Color cardBg,
  }) {
    final isVideo = type == 'video';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (isVideo ? AppColors.primaryBlue : AppColors.accentGold).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isVideo ? Icons.play_circle_fill_rounded : Icons.picture_as_pdf_rounded,
          color: isVideo ? AppColors.primaryBlue : AppColors.accentGold,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isLocked ? Colors.grey : (isDark ? Colors.white : AppColors.textPrimary),
        ),
      ),
      trailing: Icon(
        isLocked ? Icons.lock_outline_rounded : Icons.arrow_forward_ios_rounded,
        size: 14,
        color: isLocked ? Colors.grey[400] : AppColors.textSecondary.withValues(alpha: 0.5),
      ),
      onTap: isLocked ? null : () {},
    );
  }

  Widget _buildContentCard({
    required String title,
    required String duration,
    required String type,
    required bool isLocked,
    required int delay,
  }) {
    IconData getIcon() {
      switch (type) {
        case 'video': return Icons.play_circle_fill_rounded;
        case 'pdf': return Icons.picture_as_pdf_rounded;
        case 'exam': return Icons.quiz_rounded;
        case 'whatsapp': return Icons.chat_bubble_rounded;
        case 'phone': return Icons.phone_forwarded_rounded;
        default: return Icons.insert_drive_file_rounded;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return FadeInUp(
      delay: Duration(milliseconds: delay),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (type == 'video' || type == 'whatsapp' ? AppColors.primaryBlue : AppColors.accentGold).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getIcon(),
                color: (type == 'video' || type == 'whatsapp' ? AppColors.primaryBlue : AppColors.accentGold),
                size: 26,
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              duration,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
            trailing: Icon(
              isLocked ? Icons.lock_outline_rounded : Icons.arrow_forward_ios_rounded,
              color: isLocked ? Colors.grey[400] : AppColors.primaryBlue.withValues(alpha: 0.5),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
