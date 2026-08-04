import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';

class InstructorBioView extends StatelessWidget {
  const InstructorBioView({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildBioSection(),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildSocialSection(),
                  ),
                  const SizedBox(height: 50),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildTimelineSection(),
                  ),
                  const SizedBox(height: 50),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildSummarySection(),
                  ),
                  const SizedBox(height: 40),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: _buildQuoteSection(),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'هير خالد الحلواني',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Using a nice gradient background for the instructor profile
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryBlueDark,
                  ],
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.school_rounded,
                    size: 200,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            // Profile image placeholder or actual image if available
            Center(
              child: Hero(
                tag: 'herr_khaled_hero_avatar',
                child: Container(
                  width: 135,
                  height: 135,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF59E0B), width: 3.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.5),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/khaled.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 28),
            const SizedBox(width: 12),
            Text(
              'نبذة بسيطة',
              style: GoogleFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            'أنا اتخرجت في كلية الالسن جامعة عين شمس قسم اللغة الالمانية سنة 2015. اشتغلت في مجال التدريس من سنة 2013 و كنت مساعد لواحد من افضل مدرسين مصر في التدريس.\n\n'
            'بجانب الكورسات انا محاضر لكوسات طبية و كوسات التحضير للامتحانات الدولية و بفضل ربنا اكتر من 5000 طالب درس اللغة و خققوا التارجت بتاعهم.\n\n'
            'عصارة كل دة ان بفضل ربنا الخبرات ديه هي الللي علمتني ان الرزق كله بتاع ربنا و ان ما علي الانسان الا السعي و النتيجة بتاعت ربنا.',
            style: GoogleFonts.cairo(
              fontSize: 16,
              height: 1.8,
              color: AppColors.textPrimary.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تواصل مباشر',
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialItem(
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                label: 'فيسبوك',
                onTap: () => _launchUrl('https://www.facebook.com/share/1Csuf2zQJh/?mibextid=wwXIfr'),
              ),
              _socialItem(
                icon: Icons.play_circle_fill_rounded,
                color: const Color(0xFFFF0000),
                label: 'يوتيوب',
                onTap: () => _launchUrl('https://youtube.com/@gatewaytogermany?si=yRCFnjEcBO3hPL7G'),
              ),
              _socialItem(
                icon: Icons.camera_alt_rounded,
                color: const Color(0xFFE4405F),
                label: 'انستجرام',
                onTap: () => _launchUrl('https://www.instagram.com/khaledelhalwany?igsh=YXlvMWxreGIwcTdq'),
              ),
              _socialItem(
                icon: Icons.music_note_rounded,
                color: Colors.black,
                label: 'تيك توك',
                onTap: () => _launchUrl('https://www.tiktok.com/@khaled.elhalawany8?_r=1&_t=ZS-96Pa0iBqwq1'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _socialItem({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.timeline_rounded, color: AppColors.primaryBlue, size: 28),
            const SizedBox(width: 12),
            Text(
              'محطات في الكارير',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        _timelineCard(
          year: '2013',
          title: 'بداية التدريس و RTC',
          desc: 'انستراكتور لغة ألمانية بجمعية رسالة ومساعد لأحد كبار مدرسي مصر.',
          icon: Icons.school_outlined,
        ),
        _timelineCard(
          year: '2015',
          title: 'الألسن و Vodafone',
          desc: 'تخرج من كلية الألسن والعمل بـ Vodafone خدمة عملاء بالألمانية.',
          icon: Icons.work_outline_rounded,
        ),
        _timelineCard(
          year: '2017',
          title: 'الجيش و Vodafone HR',
          desc: 'HR Phone Screen وتأسيس أول معهد لتدريس اللغة الألمانية.',
          icon: Icons.person_search_outlined,
        ),
        _timelineCard(
          year: '2019',
          title: 'Incident Management',
          desc: 'العمل بمجال الـ Technical بـ Vodafone لمدة سنة.',
          icon: Icons.settings_suggest_outlined,
        ),
        _timelineCard(
          year: '2020',
          title: 'Microsoft & Concentrix',
          desc: 'دعم Microsoft حتى نهاية 2022 بجانب التدريس المستمر.',
          icon: Icons.computer_rounded,
        ),
        _timelineCard(
          year: '2023',
          title: 'الاحتراف الكامل والـ Upskilling',
          desc: 'عقد مع Deutsche Welt و Concentrix كمحاضر لكورسات الـ Upskilling.',
          icon: Icons.star_outline_rounded,
        ),
      ],
    );
  }

  Widget _timelineCard({required String year, required String title, required String desc, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    year,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text(
            'ملخص الخبرات',
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _summaryRow(Icons.history_edu_rounded, 'خبرة تدريس', '10 سنوات'),
          _divider(),
          _summaryRow(Icons.support_agent_rounded, 'Vodafone (DE)', '5 سنوات'),
          _divider(),
          _summaryRow(Icons.computer_rounded, 'IT (Microsoft)', '3 سنوات'),
          _divider(),
          _summaryRow(Icons.badge_outlined, 'HR Management', 'سنة واحدة'),
          _divider(),
          _summaryRow(Icons.groups_rounded, 'عدد الطلاب', '+5000 طالب'),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: GoogleFonts.cairo(color: Colors.white, fontSize: 15),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.white.withValues(alpha: 0.1), height: 1);

  Widget _buildQuoteSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.primaryBlue, size: 40),
          const SizedBox(height: 16),
          Text(
            'السعي ثم السعي ثم السعي\nالرزق كله بتاع ربنا و إن ما علي الإنسان إلا السعي والنتيجة بتاع ربنا',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
